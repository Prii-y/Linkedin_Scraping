# Clear the environment
rm(list = ls())


#Necessary Packages
#install.packages("dplyr")
library(dplyr)
#install.packages("stringi")
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

setwd(temp_dir)

cutoffs <- read.xlsx("min_results_08_15.xlsx") %>%
  mutate(estab= as.numeric(estab), cutoff= as.numeric(cutoff))  %>% 
  select(c("estab", "curso", "ano","fase","cutoff"))

colocados <- read.csv("candidaturas_08_15.csv")  %>%
  merge(cutoffs, by = c("estab", "curso", "ano","fase"), all.x = TRUE) %>% 
  mutate(colocado = ifelse(is.na(colocado), 0, colocado)) %>%
  filter(colocado==1)

# Read the  CSV files into a data frame
colocados <- read.csv("candidaturas_08_15.csv")  %>%
  merge(cutoffs, by = c("estab", "curso", "ano","fase"), all.x = TRUE) %>% 
  mutate(colocado = ifelse(is.na(colocado), 0, colocado)) %>%
  mutate(cont_esp = ifelse(colocado == 1 & nota < cutoff, 1, 0)) %>%
  filter(estab==904 | estab==6800 | estab== 1517 | estab==805) %>%
  mutate(estab=ifelse(estab==805,1517,estab)) %>%
  filter(ano==2014 & colocado==1) %>%
  mutate(nome  = gsub("- ", "-", nome),  # Replace "- " with "-"
         nome  = gsub("´", "'", nome),   # Replace "´" with "'"
         nome  = gsub("' ", "'", nome),   # Replace "' " with "'" 
         name  = tolower(as.character(nome)), #Variable to lower case
         name2 = stri_trans_general(name, "Latin-ASCII"), # Remove special characters 
         name_1 = gsub("'", " ", gsub("-", " ", name)),
         name2_1 = gsub("'", " ", gsub("-", " ", name2)),
         space_count = str_count(name, " "),
         space_count_1 = str_count(name_1, " ")) 

#Maximum number of reported names
max_names <- max(colocados$space_count) +1
max_names_1 <- max(colocados$space_count_1) +1

# Create dynamic column names
column_names <- paste0("name__", seq_len(max_names))
column_names2 <- paste0("name2__", seq_len(max_names))

column_names_1 <- paste0("name_1__", seq_len(max_names_1))
column_names2_1 <- paste0("name2_1__", seq_len(max_names_1))


#Split Names, correct for duplicates
temp_split_names <- colocados %>% 
  distinct(candidato,name,name2,name_1,name2_1) %>%  
  separate(name, into = column_names, sep=" ", fill = "right", extra = "merge") %>%
  separate(name2, into = column_names2, sep=" ", fill = "right", extra = "merge") %>%
  separate(name_1, into = column_names_1, sep=" ", fill = "right", extra = "merge") %>%
  separate(name2_1, into = column_names2_1, sep=" ", fill = "right", extra = "merge") %>%
  mutate(merge=1)  %>%
  group_by(candidato) %>% 
  arrange(candidato) %>%
  ungroup() 

split_names <- temp_split_names %>%
  distinct(candidato, across(all_of(column_names))) %>%
  # Unite all names into a single list for each row
  mutate(all_names = pmap(across(all_of(column_names)), 
                          ~ c(...))) %>%
  # Remove NA values from the list of names
  mutate(all_names = map(all_names, ~ .x[!is.na(.x)])) %>%
  # Create all ordered combinations of pairs from the names
  mutate(name_combinations = map(all_names, ~ combn(.x, 2, FUN = paste, collapse = " ", simplify = FALSE))) %>% 
  unnest(name_combinations) %>%
  filter(str_detect(name_combinations, name__1) | str_detect(name_combinations, name__2)) %>% 
  select(candidato, name_combinations)
  
  
split_names_1 <- temp_split_names %>%
  distinct(candidato, across(all_of(column_names_1))) %>%
  # Unite all names into a single list for each row
  mutate(all_names = pmap(across(all_of(column_names_1)), 
                          ~ c(...))) %>%
  # Remove NA values from the list of names
  mutate(all_names = map(all_names, ~ .x[!is.na(.x)])) %>%
  # Create all ordered combinations of pairs from the names
  mutate(name_combinations = map(all_names, ~ combn(.x, 2, FUN = paste, collapse = " ", simplify = FALSE))) %>%
  unnest(name_combinations) %>%
  filter(str_detect(name_combinations, name_1__1) | str_detect(name_combinations, name_1__2))  %>% 
  select(candidato, name_combinations)

split_names2 <- temp_split_names %>%
  distinct(candidato, across(all_of(column_names2))) %>%
  # Unite all names into a single list for each row
  mutate(all_names = pmap(across(all_of(column_names2)), 
                          ~ c(...))) %>%
  # Remove NA values from the list of names
  mutate(all_names = map(all_names, ~ .x[!is.na(.x)])) %>%
  # Create all ordered combinations of pairs from the names
  mutate(name_combinations = map(all_names, ~ combn(.x, 2, FUN = paste, collapse = " ", simplify = FALSE))) %>%
  unnest(name_combinations) %>% 
  filter(str_detect(name_combinations, name2__1) | str_detect(name_combinations, name2__2))  %>% 
  select(candidato, name_combinations)

split_names2_1 <- temp_split_names %>%
  distinct(candidato, across(all_of(column_names2_1))) %>%
  # Unite all names into a single list for each row
  mutate(all_names = pmap(across(all_of(column_names2_1)), 
                          ~ c(...))) %>%
  # Remove NA values from the list of names
  mutate(all_names = map(all_names, ~ .x[!is.na(.x)])) %>%
  # Create all ordered combinations of pairs from the names
  mutate(name_combinations = map(all_names, ~ combn(.x, 2, FUN = paste, collapse = " ", simplify = FALSE))) %>%
  unnest(name_combinations) %>% 
  filter(str_detect(name_combinations, name2_1__1) | str_detect(name_combinations, name2_1__2)) %>%
  select(candidato, name_combinations)

split_names_comb <- rbind(split_names,split_names_1,split_names2_1,split_names2) %>%
                    distinct()

# Set the working directory to the temporary data_folder
setwd(base_dir)
#Save a dataset with those that we are sure about the situation
write.xlsx(colocados, "colocados_2014.xlsx")
write.xlsx(split_names_comb, "names_colocados_2014.xlsx")
