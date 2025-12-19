# Point Blue Warehouse API (R package)  

**Install the pbWarehouseApi package**  
```
install.packages("remotes")
remotes::install_github("pointblue/r-pointblue-api", force = TRUE)
```

**Load the package**  
```
library(pbWarehouseApi)
```

**Set your API access key for current session**  
```
Sys.setenv(PB_API_KEY = "your_api_key_here")
```
See [api-key-setup.md](api-key-setup.md) for alternative key setup methods.


**Fetch all accessible point count data**
```
df <- pbApiRequest(surveyType = "PointCount")
```
Omitting the surveyType argument returns only point count data by default.  

Note: This operation can take a few minutes to complete depending on how much
data you have access to.

**Fetch point count data for a specific project(s)**
```
# single project
df <- pbApiRequest(projects = "BACKBAYNWR")

# multiple projects
df <- pbApiRequest(projects = "BACKBAYNWR,BIGOAKSNWR")
```
Omitting the projects argument returns data from all accessible projects

**Fetch all accessible point count data for a specific protocol**
```
# single protocol
df <- pbApiRequest(protocol = "3_5m50M+_NWRS_R5_LAND")

# multiple protocols
df <- pbApiRequest(protocol = "3_5m50M+_NWRS_R5_LAND,FR50")
```
Omitting the protocol argument returns data for all available protocols

**Fetch all accessible data for specific species**
```
# single species
df <- pbApiRequest(surveyType = "PointCount", species = "ATOW")

# multiple species
df <- pbApiRequest(surveyType = "PointCount", species = "ATOW,AMRO")
```
Omitting the species argument returns data for all available species

**Fetch all accessible data for specific regions**
```
# single region
df <- pbApiRequest(surveyType = "PointCount", region = "US_STATES:06")

# multiple regions
df <- pbApiRequest(surveyType = "PointCount", region = "US_STATES:06,US_STATES:04")
```
All supplied regions must share the same domain prefix (e.g. `US_STATES`).  
Omitting the region argument returns data for all accessible regions.  

See [regions.md](regions.md) for the full lookup table.  

**Filter by date**
```
df <- pbApiRequest(surveyType = "PointCount", dateBegin = "2003-01-01")
```
Omitting the date argument returns data from all available dates

**Mix and match**  

```
df <- pbApiRequest(
  surveyType = "PointCount",
  projects = "BACKBAYNWR,BIGOAKSNWR",
  dateBegin = "2003-01-01",
  dateEnd = "2003-12-31",
  protocol = "3_5m50M+_NWRS_R5_LAND",
  species = "ATOW,AMCR",
  region = "US_STATES:06,US_STATES:41"
)
```

**Write to CSV file**  
```
write.csv(df, "output.csv", row.names = FALSE)
```

**To make sure you have the latest updates**  
```
remotes::install_github("pointblue/r-pointblue-api", force = TRUE)
```
The states of this development is a work in progress. To be sure you're using the
latest available code, run this command an restart your R session to be sure 
old code is not being loaded.  

Once the development reaches a stable state, version numbers will be introduced
to locked your code to a specific version if needed.
