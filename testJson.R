library(dplyr)
library(tidyjson)
# Define a simple people JSON collection
people <- c('{"age": 32, "name": {"first": "Bob",   "last": "Smith"}}',
            '{"age": 54, "name": {"first": "Susan", "last": "Doe"}}',
            '{"age": 18, "name": {"first": "Ann",   "last": "Jones"}}')

# Tidy the JSON data
people %>% spread_all
#> # A tbl_json: 3 x 5 tibble with a "JSON" attribute
#>   ..JSON                  document.id   age name.first name.last
#>   <chr>                         <int> <dbl> <chr>      <chr>    
#> 1 "{\"age\":32,\"name..."           1    32 Bob        Smith    
#> 2 "{\"age\":54,\"name..."           2    54 Susan      Doe      
#> 3 "{\"age\":18,\"name..."           3    18 Ann        Jones


