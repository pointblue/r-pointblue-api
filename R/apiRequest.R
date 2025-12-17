#' Fetch Point Count Data from the Point Blue API
#'
#' Retrieves point count survey data from the Point Blue data warehouse API
#' for one or more projects and returns the results as a data frame.
#'
#' The function requires a valid API token to be set in the environment
#' variable \code{PB_API_KEY}.
#'
#' @param surveyType The survey type to request (defaults to \code{"PointCount"}).
#' @param projects Optional character vector of project codes to query (e.g. \code{"ADOB"}). If none given, all accessible project data are fetched.
#' @param dateBegin Optional ISO date string for the beginning of the date range.
#' @param dateEnd Optional ISO date string for the end of the date range.
#' @param protocol Optional single protocol name or comma-separated protocols. When
#'   supplied, restricts results to those protocols.
#'
#' @return A tibble containing point count survey records.
#'
#' @details
#' The query uses the supplied \code{surveyType}. Optionally, specify
#' \code{dateBegin} and/or \code{dateEnd} to filter results by date, and/or
#' supply \code{protocol} to limit results to one or more protocols.
#'
#' @examples
#' \dontrun{
#' Sys.setenv(PB_API_KEY = "your_api_key_here")
#' df <- pbApiRequest(
#'   surveyType = "PointCount",
#'   projects = c("ADOB", "ABC"),
#'   dateBegin = "2001-01-01",
#'   dateEnd = "2020-12-31",
#'   protocol = "ProtocolA,ProtocolB"
#' )
#' }
#'
#' @export
pbApiRequest <- function(surveyType = "PointCount",
                         projects = NULL,
                         dateBegin = NULL,
                         dateEnd = NULL,
                         protocol = NULL) {

  #TODO: Incorporate the notion of program

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

  # Fetch CSV data from the API
  query <- list(
    surveyType = surveyType,
    project    = projects,
    dateBegin  = dateBegin,
    dateEnd    = dateEnd,
    protocol   = protocol
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
