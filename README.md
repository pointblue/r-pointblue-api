# Point Blue Warehouse API (R package)  

Install the pbWarehouseApi package  
```
install.packages("remotes")
remotes::install_github("pointblue/r-pointblue-api", force = TRUE)
```

Load the package  
```
library(pbWarehouseApi)
```

Set your API access key  
```
Sys.setenv(PB_API_KEY = "your_api_key_here")
```

Fetch all accessible point count data
```
df <- pbApiRequest(surveyType = "PointCount")
```

Fetch point count data for a specific project(s)
```
df <- pbApiRequest(surveyType = "PointCount", projects = c("BAYBACKNWR"))
df <- pbApiRequest(surveyType = "PointCount", projects = c("BACKBAYNWR", "BIGOAKSNWR"))
```

Fetch all accessible data for a specific protocol
```
df <- pbApiRequest(protocol = "3_5m50M+_NWRS_R5_LAND")
```

Filter by date
```
df <- pbApiRequest(surveyType = "PointCount", dateBegin = 2003-01-01)
```

Mix and match  

```
df <- pbApiRequest(surveyType = "PointCount", projects = c("BACKBAYNWR", "BIGOAKSNWR"), dateBegin = 2003-01-01, protocol = "3_5m50M+_NWRS_R5_LAND")
```

Write to CSV file  
```
write.csv(df, "output.csv", row.names = FALSE)
```


