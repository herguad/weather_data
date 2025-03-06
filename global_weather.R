library(tidyverse)
library(readr)
library(magrittr)
setwd("C:/Users/Guadalupe/Documents/IT/R/weather_data")

global_w <- read.csv("GlobalWeatherRepository.csv",header=TRUE, sep = ",", fill = TRUE)

#View(global_w)

