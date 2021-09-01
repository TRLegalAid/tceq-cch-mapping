# 8/30/21
# Script obtains block group boundaries and ACS 2019 5YR estimates data from the Census Bureau API, produces
# spatial layers of addresses of selected facilities requesting air pollution permits from TCEQ, 1-mile and 6-mile
# buffer zones, and block groups overlapping with those buffer zones. 
# Inputs: Census API key .txt file, geocoded facility addresses .csv file
# Outputs: Five .geojson files


library(tidyverse)
library(tidycensus)
library(sf)
library(data.table)


## ----- Get data from the Census API

# Register for your unique API key here: https://api.census.gov/data/key_signup.html
# Save your key somewhere outside of this project directory, so it won't end up accidentally tracked by Git!

key <- read.delim("../credentials/census_api_key.txt", header = FALSE)

# Add your Census API key to your environment
census_api_key(key)


# Load library of available variables from the ACS 2019 5-Year estimates
# You can View(v19) to get a searchable library of the available variables
v19 <- load_variables(2019, "acs5", cache = TRUE) 


# Obtain block group-level demographic estimates with geometry from the 2019 ACS 5-Year estimates
# Reformat & add fields for percentages
bgs_tx <- get_acs(geography = "block group",
                  variables = c(
                    total_pop = "B03002_001",
                    median_income = "B25119_001",
                    white = "B03002_003", # white non-Hispanic
                    black = "B03002_004",
                    asian = "B03002_006",
                    hispanic = "B03002_012", # Hispanic all races
                    american_indian = "B03002_007"), 
                  state = "TX",
                  geometry = TRUE) %>%
  dplyr::select("GEOID", "variable", "estimate") %>%
  tidyr::spread(variable, estimate) %>%
  mutate(pct_hispanic = (hispanic/total_pop)*100,
         pct_white = (white/total_pop)*100,
         pct_black = (black/total_pop)*100,
         pct_asian = (asian/total_pop)*100,
         pct_hispanic = (hispanic/total_pop)*100)



## ----------- Read in geocoded sites data
# Site addresses previously geocoded with Geocod.io
sites <- fread("input/tceq_cch_facilities_geocodio.csv")

# Convert sites coordinates to a simple features points layer
# Set the crs to match that of the census data (EPSG 4269)
sites_points <- st_as_sf(sites, coords = c(9, 8), crs = st_crs(bgs_tx))


## ------------- Create a 1 mile and 6 mile buffer around the facility location points
# 1 mile = 1.61 km
sites_buffer_1mi <- st_buffer(sites_points, 1610)

# 6 miles = 9.66km
sites_buffer_6mi <- st_buffer(sites_points, 9660)

# Spatial join the buffer data to the bgs, filter to block groups that overlapped
bgs_1mi <- st_join(bgs_tx, sites_buffer_1mi) %>% filter(!is.na(docket_no))
bgs_6mi <- st_join(bgs_tx, sites_buffer_6mi) %>% filter(!is.na(docket_no))


# # write sites points layer
# st_write(sites_points, "output/sites_points.geojson")
# 
# # write buffer layers
# st_write(sites_buffer_1mi, "output/sites_buffer_1mi.geojson")
# st_write(sites_buffer_6mi, "output/sites_buffer_6mi.geojson")
# 
# # write block group subset layers
# st_write(bgs_1mi, "output/bgs_1mi.geojson")
# st_write(bgs_6mi, "output/bgs_buffer_6mi.geojson")


# Potential next steps:
# Include additional ACS variables
# Repeat with block-level data in analysis-decennial-blocks.R
# Find % each race around the sites that were granted & denied, hearings that were granted & denied
# Research environmental justice GIS methodologies




