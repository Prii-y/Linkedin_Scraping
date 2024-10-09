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

colocados <- read.xlsx("colocados_2014.xlsx")
linkedin <- read.xlsx("education_2014.xlsx") %>% 
            select(username, SchoolName, name, DegreeName,FieldOfStudy) %>%
            rename(name_linkedin=name)

potential_matches <- read.xlsx("potential_matches_2014.xlsx")

combined_data <- colocados %>% 
                  select(estab,nome_curso, name, candidato) %>%
                  left_join(potential_matches,by="candidato") %>%
                  left_join(linkedin,by="username") %>%
                  select(name,name_linkedin, username, estab, SchoolName,
                         nome_curso,DegreeName,FieldOfStudy, everything()) %>%
                  arrange(name,-count_profile) %>%
                  filter(!is.na(name_linkedin))
                  

##################################write.xlsx(combined_data, "check_matches.xlsx")

matches <- read.xlsx("check_matches_2014.xlsx") %>% filter(!is.na(match)) %>% 
           select(username,candidato) 

dup <- duplicates(matches, c("candidato"))  

remind_colocados <- colocados %>%
                    left_join(matches,by="candidato") %>%
                    filter(is.na(username)) %>% 
                    select(estab,nome_curso, name, candidato)

write.xlsx(remind_colocados, "remind_colocados_2014.xlsx")                    

tabulate(remind_colocados,"nome_curso")

dup <- duplicates(matches, c("username"))  

remind_linkedin <- linkedin %>%
                   left_join(matches,by="username") %>%
                   filter(is.na(candidato)) %>% 
                   select(username, SchoolName, name_linkedin, DegreeName,FieldOfStudy)  

write.xlsx(remind_linkedin, "remind_linkedin_2014.xlsx") 
