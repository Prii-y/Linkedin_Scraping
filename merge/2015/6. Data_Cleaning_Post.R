# Clear the environment
rm(list = ls())

library(stringi)
#install.packages("readr")
library(readr)
#install.packages("openxlsx")
library(openxlsx)
#install.packages("tools")
library(tools)
#install.packages("mclust")
library(mclust)
#install.packages("tidyverse") 
library(tidyverse)
#install.packages("RColorBrewer")
library(RColorBrewer)


setwd("C:/Users/Miguel Nunes/Desktop/merge/2014")
source("functions.R")

# Define the raw data directory
base_dir <- 'C:/Users/Miguel Nunes/Desktop/merge/2014/data_linkedin'
# Define the temporary data directory
temp_dir <- 'C:/Users/Miguel Nunes/Desktop/merge/2014/data_linkedin/temp_data'

setwd(base_dir)

colocados <- read.xlsx("colocados_2014.xlsx") %>%
             filter(str_detect(nome_curso, "Economia|Gestão|Finanças"))

