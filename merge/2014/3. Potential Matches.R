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


setwd("C:/Users/Miguel Nunes/Desktop/merge")
source("functions.R")

# Define the raw data directory
base_dir <- 'C:/Users/Miguel Nunes/Desktop/merge/data_linkedin'
# Define the temporary data directory
temp_dir <- 'C:/Users/Miguel Nunes/Desktop/merge/data_linkedin/temp_data'

setwd(base_dir)

names_colocados <- read.xlsx("names_colocados_2014.xlsx")
names_linkedin <- read.xlsx("names_linkedin_2014.xlsx")

combined_names <- names_colocados %>% 
                  left_join(names_linkedin,by="name_combinations") %>%
                  group_by(candidato,username) %>%
                  mutate(count_profile=ifelse(!is.na(username),n(),NA)) %>%
                  distinct(candidato,username,.keep_all = TRUE) %>%
                  select(-name_combinations)

write.xlsx(combined_names, "potential_matches.xlsx")
