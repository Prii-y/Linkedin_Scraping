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

remind_colocados <- read.xlsx("remind_colocados_2014.xlsx")
educ <- read.xlsx("education_gen_2014.xlsx") %>% rename(name_linkedin=name)

matches <- read.xlsx("check_matches_2014.xlsx") %>% filter(!is.na(match)) %>% 
  select(candidato) %>% mutate(solved=1)

combined_data <- read.xlsx("potential_matches.xlsx") %>%
                      left_join(matches,by="candidato") %>%
                      filter(is.na(solved)) %>%
                      left_join(educ,by="username")  %>%
                      left_join(remind_colocados,by="candidato") %>%
                      select(name,name_linkedin, username, estab, university,
                        nome_curso, everything()) %>%
                      arrange(name,name_linkedin) %>%
                      filter(!is.na(name_linkedin))

################################write.xlsx(combined_data, "check_matches2.xlsx")

matches1 <- read.xlsx("check_matches_2014.xlsx") %>% filter(!is.na(match)) %>% 
           select(username,candidato)

matches2 <- read.xlsx("check_matches2_2014.xlsx") %>% filter(!is.na(match)) %>% 
  select(username,candidato)
                       
matches <- rbind(matches1,matches2)

remind_colocados2 <- read.xlsx("colocados_2014.xlsx") %>%
                      left_join(matches,by="candidato") %>%
                      filter(!is.na(username)) %>% 
                      select(estab,nome_curso, name, candidato) %>%
                      filter(str_detect(nome_curso, "Economia|Gestão|Finanças")) %>%
                      arrange(name)

remind_linkedin2 <- read.xlsx("education_2014.xlsx") %>% 
                    select(username, SchoolName, name, DegreeName,FieldOfStudy) %>%
                    rename(name_linkedin=name) %>%
                    left_join(matches,by="username") %>%
                    filter(is.na(candidato)) %>% 
                    select(username, SchoolName, name_linkedin, DegreeName,FieldOfStudy)  


#####################write.xlsx(remind_colocados2, "check_matches3_2014.xlsx")

matches1 <- read.xlsx("check_matches_2014.xlsx") %>% filter(!is.na(match)) %>% 
  select(username,candidato)

matches2 <- read.xlsx("check_matches2_2014.xlsx") %>% filter(!is.na(match)) %>% 
  select(username,candidato)

matches3 <- read.xlsx("check_matches3_2014.xlsx") %>% filter(!is.na(match)) %>% 
  select(username,candidato)

matches <- bind_rows(matches1,matches2,matches3)

write.xlsx(matches, "compiled_matches.xlsx")

dup <- duplicates(matches,"username")

