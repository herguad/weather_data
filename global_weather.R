library(devtools)
library(tidyverse)
library(dplyr)
library(readr)
library(countries)
#library(magrittr)
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

summary(selected_gw) #<- pressure_mb, wind_kph, and uv_index have remarkable max values 
                     # while air_quality_CO2 and air_quality_SO2 have unusual min values
                     # min uv_index is zero which means no sunlight and should be looked into

#Find outliers and manage data appropriately.

uvi_values <- tibble(selected_gw$uv_index)
aqco2_values<- tibble(selected_gw$air_quality_Carbon_Monoxide)
aqso2_values <- tibble(selected_gw$air_quality_Sulphur_dioxide)

str(uvi_values)
str(aqco2_values)
str(aqso2_values)

uvi_co2_so2 <- bind_cols(uvi_values,aqco2_values,aqso2_values)
colnames(uvi_co2_so2) <- c("UV_index","aqCO2","aqSO2")

#str(uvi_co2_so2)

uv_co2_so2_valid <- uvi_co2_so2 %>%
  filter(UV_index > 0, aqCO2 > 0, aqSO2 > 0)

str(uv_co2_so2_valid) # <-- 47,778 observations (out of the original 56,906)

#Remove observations where value of these variables is equal or below 0 from the main df.

filtered_gw <- selected_gw %>%
  filter(uv_index > 0, air_quality_Carbon_Monoxide > 0, air_quality_Sulphur_dioxide > 0)

str(filtered_gw)
  

#Find and manage unusual max values for pressure_mb, wind_kph and uv_index have remarkable max values.

press_values <- tibble(filtered_gw$pressure_mb)
wind_values<- tibble(filtered_gw$wind_kph)

str(press_values) # <- quick search shows 1085 is max possible value, so values over that could be filtered out.
str(wind_values)  # <- quick search shows 370-410 is max recorded value (excluding tornadoes) so values over that could be filtered out.

# As regards uv_index quick search shows 11+ is max possible value for human tolerance.
# However, many spots on the Earth get higher values.
# I'll just filter those locations with max human tolerance value.

filtered_gw <- filtered_gw %>%
  filter(uv_index < 12, pressure_mb < 1086, wind_kph < 400)

str(filtered_gw) # <-- 46332 observations (out of the original 56,906)

#Filter observations made within the same timeframe.

#Time data as recorded in last_updated appears as a chr type 
#so this column should be unified in a convenient time format first.

weather_date <- filtered_gw %>%
  mutate(last_updated=ymd_hm(last_updated))

str(weather_date) #<- check results. OK.

#Group by country and check how many observations there are for each location_name.
weather_locs <- weather_date%>%
  group_by(country)%>%
  distinct(location_name)%>%
  mutate(count=n())%>%
  arrange(desc(count))

#view(weather_locs) #<- some locations include +1 observation (up to 4) on different times.

#Use countries package to filter observations only for capital cities.

cap_cities <- country_info()$capital

#view(cap_cities) #<- array of capital cities

weather_caps <- weather_date %>%
  filter(location_name %in% cap_cities)%>%
  arrange(location_name)

#view(weather_caps) #<-39,660 observations

#Filter obs for a specific period of time. In this case the months of 

capital_w <- weather_caps %>%
  mutate(m = month(last_updated))%>%
  filter(between(m,5,6))%>%
  arrange(country)

#view(capital_w) #<- 7,453 observations

#Count observations per capital city in that period of time.

capital_w_unique <- capital_w%>%
  group_by(country,location_name)%>%
  distinct(last_updated,location_name)%>%
  mutate(count=n())%>%
  arrange(desc(count))

#view(capital_w_unique) #<- obs for different capital cities vary between just 1 and 47 in the same period of time

#Filter cities with more than the average number of observations in that period of time,

avg_obs_cities <- capital_w_unique %>%
  filter(count > quantile(capital_w_unique$count,0.25))

#view(avg_obs_cities) #<- 4982 observations

capital_weather <- capital_w%>%
  group_by(location_name,last_updated)%>%
  filter(location_name %in% avg_obs_cities$location_name | last_updated %in% avg_obs_cities$last_updated)%>%
  arrange(country)

#view(capital_weather) # <- 7,063 obs

#repeat count of obsv to see discrepancies
capital_unique <- capital_weather%>%
  group_by(country,location_name)%>%
  distinct(last_updated,location_name)%>%
  mutate(count=n())%>%
  arrange(desc(count))

#view(capital_unique) # <- Not as many observations in March and none in April for different cities.

#-> change months in above filter to only include May through June observations.
#check final dfs
view(capital_unique)

#Aggregate and summarize relevant data.

#Plot distribution of relevant variables.
