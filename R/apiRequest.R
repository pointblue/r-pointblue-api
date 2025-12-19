#' Fetch Point Count Data from the Point Blue API
#'
#' Retrieves point count survey data from the Point Blue data warehouse API
#' for one or more projects and returns the results as a data frame.
#'
#' The function requires a valid API token to be set in the environment
#' variable \code{PB_API_KEY}.
#'
#' @param surveyType The survey type to request (defaults to \code{"PointCount"}).
#' @param projects Optional character vector of project codes to query (e.g. \code{"ADOB"}).
#'   Multiple codes may be supplied either as a vector or comma-separated string.
#'   If \code{NULL}, all accessible project data are fetched.
#' @param dateBegin Optional ISO date string for the beginning of the date range.
#' @param dateEnd Optional ISO date string for the end of the date range.
#' @param protocol Optional single protocol name or comma-separated protocols (vectors are
#'   collapsed for convenience). When supplied, restricts results to those protocols.
#' @param species Optional single species code or comma-separated species codes. When supplied,
#'   limits results to the provided species.
#' @param region Optional single region filter in the form
#'   \code{REGION_DOMAIN_ID:REGION_ID} (e.g. \code{"US_STATES:06"}). Supply
#'   multiple regions either as a character vector or comma-separated string,
#'   provided all entries share the same region domain. When supplied, restricts
#'   results to the provided regions.
#'
#' @return A tibble containing point count survey records.
#'
#' @details
#' The query uses the supplied \code{surveyType}. Optionally, specify
#' \code{dateBegin} and/or \code{dateEnd} to filter results by date, and/or
#' supply \code{protocol} to limit results to one or more protocols,
#' \code{species} to restrict the output to particular species codes, and
#' \code{region} (formatted as \code{REGION_DOMAIN_ID:REGION_ID}) to constrain
#' the sampling units returned. When multiple regions are supplied they must all
#' belong to the same region domain because the API accepts a single
#' \code{regionDomainId} per request.
#'
#' @examples
#' \dontrun{
#' Sys.setenv(PB_API_KEY = "your_api_key_here")
#' df <- pbApiRequest(
#'   surveyType = "PointCount",
#'   projects = c("ADOB", "ABC"),
#'   dateBegin = "2001-01-01",
#'   dateEnd = "2020-12-31",
#'   protocol = "ProtocolA,ProtocolB",
#'   species = "ATOW",
#'   region = "US_STATES:06"
#' )
#' }
#'
#' @export
pbApiRequest <- function(surveyType = "PointCount",
                         projects = NULL,
                         dateBegin = NULL,
                         dateEnd = NULL,
                         protocol = NULL,
                         species = NULL,
                         region = NULL) {

  #TODO: Incorporate the notion of program

  #TODO: Can this be generated from the OpenAPI spec?

  # Set up API key
  api_key <- Sys.getenv("PB_API_KEY")
  if (identical(api_key, "")) {
    stop(
      paste(
        "Environment variable PB_API_KEY must be set before calling pbApiRequest().",
        'Use Sys.setenv(PB_API_KEY = "your_api_key_here") to set it.'
      ),
      call. = FALSE
    )
  }

  # Normalize multi-value inputs to comma-separated strings for the API
  collapse_if_needed <- function(value) {
    if (!is.null(value) && length(value) > 1) {
      return(paste(value, collapse = ","))
    }
    value
  }

  projects <- collapse_if_needed(projects)
  protocol <- collapse_if_needed(protocol)
  species <- collapse_if_needed(species)

  parse_region_filters <- function(region_value) {
    if (is.null(region_value)) {
      return(list(regionDomainId = NULL, regionValues = NULL))
    }
    if (!is.character(region_value)) {
      stop(
        'region must be supplied as character data using the format "REGION_DOMAIN_ID:REGION_ID".',
        call. = FALSE
      )
    }

    flattened <- paste(region_value, collapse = ",")
    tokens <- strsplit(flattened, ",", fixed = TRUE)[[1]]
    tokens <- trimws(tokens)
    tokens <- tokens[nzchar(tokens)]
    if (!length(tokens)) {
      return(list(regionDomainId = NULL, regionValues = NULL))
    }

    parts <- strsplit(tokens, ":", fixed = TRUE)
    valid_lengths <- vapply(parts, length, integer(1))
    if (any(valid_lengths != 2)) {
      stop(
        'region values must include a single ":" separator (e.g. "US_STATES:06").',
        call. = FALSE
      )
    }

    domains <- vapply(parts, `[`, character(1), 1)
    region_ids <- vapply(parts, `[`, character(1), 2)

    if (any(!nzchar(domains)) || any(!nzchar(region_ids))) {
      stop(
        "regionDomainId and region identifiers cannot be empty.",
        call. = FALSE
      )
    }

    unique_domains <- unique(domains)
    if (length(unique_domains) > 1) {
      stop(
        paste(
          "All region values must share the same regionDomainId.",
          'For example: region = c("US_STATES:06", "US_STATES:41").'
        ),
        call. = FALSE
      )
    }

    list(
      regionDomainId = unique_domains[1],
      regionValues = paste(region_ids, collapse = ",")
    )
  }

  region_params <- parse_region_filters(region)

  normalize_date <- function(value, arg_name) {
    if (is.null(value)) {
      return(NULL)
    }
    if (inherits(value, c("Date", "POSIXt"))) {
      return(format(value, "%Y-%m-%d"))
    }
    if (!is.character(value)) {
      stop(
        sprintf(
          "%s must be supplied as an ISO date string (e.g. \"1997-01-01\") or a Date/POSIXt object.",
          arg_name
        ),
        call. = FALSE
      )
    }
    return(value)
  }

  dateBegin <- normalize_date(dateBegin, "dateBegin")
  dateEnd <- normalize_date(dateEnd, "dateEnd")

  # Fetch CSV data from the API
  query <- list(
    surveyType = surveyType,
    project    = projects,
    dateBegin  = dateBegin,
    dateEnd    = dateEnd,
    protocol   = protocol,
    species    = species,
    regionDomainId = region_params$regionDomainId,
    region     = region_params$regionValues
  )
  query <- query[!vapply(query, is.null, logical(1))]

  resp <- httr::GET(
    url = "https://data.pointblue.org/api/v3/warehouse/downloaddata",
    query = query,
    httr::add_headers(Authorization = paste("Bearer", api_key))
  )

  # Stop if the request failed
  httr::stop_for_status(resp)

  # Parse CSV into a data frame
  df <- readr::read_csv(
    httr::content(resp, as = "raw"),
    show_col_types = FALSE
  )

  return(df)
}
