library(tidyverse)
library(readr)
library(magrittr)
setwd("C:/Users/Guadalupe/Documents/IT/R/weather_data")

global_w <- read.csv("GlobalWeatherRepository.csv",header=TRUE, sep = ",", fill = TRUE)

## Which locations display similar weather trends according to the observations in this db?
## Which locations display greater weather changes in the same period of time?

#View(global_w)

str(global_w)

glimpse(global_w)


selected_gw <- global_w %>%
  select(country, location_name,last_updated,temperature_celsius,pressure_mb,precip_mm,wind_kph,
         humidity,uv_index,air_quality_Carbon_Monoxide,air_quality_Ozone,air_quality_Nitrogen_dioxide,air_quality_Sulphur_dioxide)

str(selected_gw)

#Check data uniformity and consistency. Manage inconsistencies.

summary(selected_gw) #<- pressure_mb, precip_mm, wind, and uv_index have remarkable max values 
                     # while air_quality_CO2 and air_quality_SO2 have unusual min values
                     # min uv_index is zero which means no sunlight and should be looked into

#Find outliers and manage data appropriately.


#Find and manage null values.

#Filter observations made within the same timeframe.

#Aggregate and summarize relevant data.


