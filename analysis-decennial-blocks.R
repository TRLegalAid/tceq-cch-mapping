## IN PROGRESS - see notes throughout
## Repeating analysis with 2020 Decennial Census data on race and ethnicity at the block group level

library(tidyverse)
library(tidycensus)
library(sf)
library(data.table)


## ------ Load 2020 census block boundaries
# Obtained here: https://www.census.gov/geographies/mapping-files/time-series/geo/tiger-line-file.html
blocks <- st_read('input/tl_2020_48_tabblock20/tl_2020_48_tabblock20.shp') %>% st_transform(3083)


## ------ Load 2020 decennial census data

# Census data import is handled in pl_all_4_2020_dar.r, which writes a file to our interim folder

# Load the census data from the interim file, select columns, and filter to rows with a BLOCK number
# NOTE: Can also filter on SUMLEV = 750 to get block-level data. 10:26 of this video: https://www.census.gov/library/video/2021/accessing-2020-census-redistricting-data-from-legacy-format-summary-files.html

census_tx <- fread('interim/census_tx_2020.csv') %>% 
  select(STATE, COUNTY, TRACT, BLOCK, P0020001, P0020002,
         P0020003, P0020004, P0020005,P0020006, P0020007, 
         P0020008, P0020009, P0020010, P0020011) %>%
  filter(!is.na(BLOCK))


# We want these variables from the P2 summary file 
# (P2 contains population counts for Hispanic or Latino, and Not Hispanic or Latino by Race)

#  P0020001  Total:
#  P0020002  Hispanic or Latino
#  P0020003  Not Hispanic or Latino:
#  P0020004  Population of one race:
#  P0020005  White alone
#  P0020006  Black or African American alone
#  P0020007  American Indian and Alaska Native alone
#  P0020008  Asian alone
#  P0020009  Native Hawaiian and Other Pacific Islander alone
#  P0020010  Some Other Race alone
#  P0020011  Population of two or more races:

# convert FIPS fields to string so we can concatenate them to build a GEOID field
census_tx$STATE <- as.character(census_tx$STATE)
census_tx$COUNTY <- as.character(census_tx$COUNTY)
census_tx$TRACT <- as.character(census_tx$TRACT)
census_tx$BLOCK <- as.character(census_tx$BLOCK)

# concatenate FIPS codes to create a GEOID field
census_tx <- census_tx %>% mutate(GEOID20 = paste(STATE, COUNTY, TRACT, BLOCK, sep=""))

# Join census data to blocks polygons on GEOID20. There will be blocks with no data
blocks_tx <- left_join(blocks, census_tx, by="GEOID20")

# NOTE: 35,6393 blocks have no population data. We expect some missing data, but this seems like a lot!
# More research needed to understand the pattern and make sure this is the correct join key
blocks_tx_pop <- blocks_tx %>% filter(!is.na(P0020001))

# At this point you can write to and/or load from interim file if needed:
# st_write(blocks_tx_pop, "interim/blocks_tx_pop.geojson")
# blocks_tx_pop <- st_read("interim/blocks_tx_pop.geojson")


## ----------- Read in geocoded sites data

# Site addresses were geocoded with Geocod.io and manually verified
sites <- fread("input/tceq_cch_facilities_geocodio.csv")

# Convert site coordinates to a simple features points layer
# Set the crs to EPSG 3083 (https://spatialreference.org/ref/epsg/nad83-texas-centric-albers-equal-area/)
sites_points <- st_as_sf(sites, coords = c(9, 8), crs = 3083)


## ----------- Create 1 mile and 6 mile buffer around the site points
# 1 mile = 1.61 km
sites_buffer_1mi <- st_buffer(sites_points, 1610)

# 6 miles = 9.66km
sites_buffer_6mi <- st_buffer(sites_points, 9660)


# Spatial join the buffer data to the blocks and filter to just those blocks that overlap
blocks_1mi <- st_join(blocks_tx_pop, sites_buffer_1mi) %>% filter(!is.na(docket_no))

blocks_6mi <- st_join(blocks_tx_pop, sites_buffer_6mi) %>% filter(!is.na(docket_no))



# Write spatial layers for blocks w/in buffers
# NOTE: In the first attempt at this these were all missing data for population!

# st_write(blocks_1mi, "output/blocks_1mi.geojson")
# st_write(blocks_6mi, "output/blocks_6mi.geojson")

# # Write spatial layers for buffers
# st_write(sites_buffer_1mi, "output/sites_buffer_1mi.geojson")
# st_write(site_buffer_6mi, "output/sites_buffer_6mi.geojson")

