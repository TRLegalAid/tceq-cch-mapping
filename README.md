# tceq-cch-mapping

[Project folder](https://txriogrande.sharepoint.com/:f:/s/DataProjects/Eh-UwzdvvuVMm9-afDolXPkBKcO8SAtv7-V12Ei6P1M1Cg?e=VYNT7T)


## Data Folders

### input

* tceq_cch_facilities.csv - This file should already be in your folder if you've cloned this repository. These are the permit-seeking facility addresses that we previously geocoded with Geocod.io, and manually verified with Google Maps. 

* tl_2020_48_tabblock20 - This is a folder containing a shapefile of all 2020 Texas Census Block boundaries. This file and the files in the next folder are too large to keep on GitHub! Find this file [here](https://www2.census.gov/geo/tiger/TIGER2020/TABBLOCK20/), download it, and unzip it inside the input folder. 

* tx2020.pl - This is a folder containing all of the 2020 Census Redistricting Data released in legacy format on Aug. 16, 2021. Download the folder [here](https://www2.census.gov/programs-surveys/decennial/2020/data/01-Redistricting_File--PL_94-171/Texas/), and unzip it in the input folder.


### interim



### output



## Scripts
### analysis-acs-block-groups.R

This script produces the data layers in this [ArcGIS Online map] (https://arcg.is/Wy5XD)


### pl_all_4_2020_dar.r



### analysis-decennial-blocks.R 

This script is a work in progress that attempts to recreate the data layers in analysis-acs-block-groups.R at the block level, instead of the block group level. 
