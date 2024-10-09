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

matches <- read.xlsx("compiled_matches.xlsx") %>% mutate(merge=1)

colocados <- read.xlsx("colocados_2014.xlsx") %>%
             filter(str_detect(nome_curso, "Economia|Gestão|Finanças")) %>%
             group_by(candidato)                                        %>%
             filter(fase==min(fase))                                    %>%
             ungroup()                                                  %>%  
             left_join(matches,by="candidato")                          %>% 
             filter(merge==1)

  
profiles <- read_csv("profiles_2014.csv")                     %>%
  rename_with(~ str_replace(., "_company_name$", "_companyname"), 
              ends_with("_company_name"))                     %>%
  rename_with(~ str_replace(., "_end_date$", "_enddate"), 
              ends_with("_end_date"))                         %>%
  rename_with(~ str_replace(., "_start_date$", "_startdate"), 
              ends_with("_start_date"))   %>%
  mutate(across(matches("^([1-9]|1[0-9]|2[0-9]30)_"), as.character)) %>%  # Convert to character
  pivot_longer( # Pivot longer to get a row for each Category, Type(Education/Experience), Type_ID
    cols = matches("^([1-9]|1[0-9]|2[0-9]|30)_"),
    names_to = c("Entry", "Type", "Category"),
    names_sep = "_",
    values_to = "Name"
  ) %>% distinct(username, Type, Entry, Category, Name, .keep_all = TRUE) %>% 
  group_by(username,Type,Entry,Category) %>% 
  arrange(username,Type,Entry,Category,Name) %>%
  mutate(rn=row_number()) %>% filter(rn==1) %>%
  pivot_wider(  # Pivot wider to get one column for each Category
    names_from = Category,
    values_from = Name
  ) 

data_edu <- profiles %>% 
  ungroup() %>%
  filter(Type=="education") %>% 
  select(-c(companyname, location, title)) %>%
  mutate(missing_educ=rowSums(is.na(select(., degree:startdate))),
         missing_all_educ=ifelse(missing_educ==4,1,0)) %>%
  group_by(username) %>%
  mutate(total_missing_all_educ = sum(missing_all_educ, na.rm = TRUE)) %>% #Number of entries with missing  
  ungroup() %>%
  filter(missing_all_educ!=1)

dup_data_edu <- duplicates(data_edu,c("username","degree","enddate","institution","startdate"))

data_exp <- profiles %>% 
  ungroup() %>%
  filter(Type=="experience") %>% 
  select(-c(degree, institution)) %>%
  mutate(missing_exp=rowSums(is.na(select(., enddate:title))),
         missing_all_exp=ifelse(missing_exp==5,1,0)) %>%
  group_by(username) %>%
  mutate(total_missing_all_exp = sum(missing_all_exp, na.rm = TRUE)) %>% #Number of entries with missing  
  ungroup() %>%
  filter(missing_all_exp!=1) 

dup_data_exp <- duplicates(data_exp,c("username","title","enddate","companyname","startdate","location"))

profiles_scraped <- profiles %>% ungroup() %>% distinct(username) %>% mutate(scraped=1)

no_matches <- matches %>% 
  left_join(profiles_scraped, by="username") %>% 
  filter(is.na(scraped))

tabulate(matches,"scraped")
