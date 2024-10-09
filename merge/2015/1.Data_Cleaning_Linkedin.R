#Author: Miguel Nunes
#mail: miguel.nunes@
#date: August, 2024
#Description: Accounts treatment for NOVA/ISEG/ISCTE/Católica


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
#install.packages("summarytools")
library(summarytools)
#install.packages("vroom")
library(vroom)

setwd("C:/Users/Miguel Nunes/Desktop/merge/2015")
source("functions.R")

# Define a list of university names and corresponding filenames
  universities <- c("nova", "catolica_lsbe", "iscte","iseg","univ_catolica","iscte_bshool")
# Define the raw data directory
  base_dir <- 'C:/Users/Miguel Nunes/Desktop/merge/2015/data_linkedin'
# Define the temporary data directory
  temp_dir <- 'C:/Users/Miguel Nunes/Desktop/merge/2015/data_linkedin/temp_data'
  
#Clean the Profile Name and Basic corrections  
############################################## 
# Loop through each university
for (university in universities) {
# Construct the filenames
  csv_filename <- paste0(university, "_final.csv")
  output_csv_filename <- paste0("temp_",university, "_processed.csv")
  output_xlsx_filename <- paste0("temp_name_corr_", university, ".xlsx")
  
  #Check if the file exists if so erase it       
  if (file.exists(output_csv_filename)) {
    file.remove(output_csv_filename)
  } 
  
    
# Set the working directory
  setwd(base_dir)
    
# Function that processes the data: takes out ",exp" and identifies lenght=1 or "." in the name
  processed <- process_data_for_correction(csv_filename) 
  
  name_corr <- processed$name_corr
  data <- processed$data 
  
  # Check if 'Unnamed: 2' exists in the dataframe
  if ("Unnamed: 2" %in% names(data)) {
    # Remove the column if it exists
    data <- data %>%
      select(-`Unnamed: 2`)
  }
  
  rm(processed)
  
# Set the working directory to the temporary data_folder
  setwd(temp_dir)  
  
  write_csv(data, output_csv_filename)
  #write.xlsx(name_corr, output_xlsx_filename)
  
  rm(name_corr,data)
}


#Finish Cleaning the Profile Name and Reshape Dataset - Obs. level Entry-Experience/Education  
##############################################################################################  
# Loop through each university
for (university in universities) {
  
  # Construct the filenames
  processed_filename <- paste0("temp_", university , "_processed.csv")  
  corr_filename <- paste0("temp_name_corr_", university, ".xlsx")
  processed_filename_save <- paste0("temp_", university , "_processed.xlsx")
  
  setwd(temp_dir)
  
  #Read the dataset with name of the students
  correction <- read.xlsx(corr_filename) %>%
                mutate(merge=1) %>%  
                select(username, Profile_Name, merge) %>% #keep the variables of interest
                distinct() # drop duplicates
  
  #Check if there still are duplicates
  correction_dup <- duplicates(correction,"username")   
  tabulate(correction_dup,"count")              
    
  # Read the previously processed CSV file
  data <- read_csv(processed_filename) %>% 
          mutate(university=university) %>%
          left_join(correction,by="username") %>% #merge the dataset with the corrected names
          mutate(First_Name=trimws(First_Name),
                 Last_Name=trimws(Last_Name),
                 ok=ifelse(is.na(Profile_Name),1,0),
                 Profile_Name=ifelse(ok==1,paste(First_Name, Last_Name, sep = " "),Profile_Name)) %>%
          mutate(across(starts_with(c("1_", "2_", "3_", "4_", "5_")), as.character)) %>%  # Convert to character
          pivot_longer( # Pivot longer to get a row for each Category, Type(Education/Experience), Type_ID
            cols = starts_with("1_") | starts_with("2_") | starts_with("3_") | starts_with("4_") | starts_with("5_"),
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
          ) %>%
          select(-c(First_Name, Last_Name,`Profile Name`,incorrect_name, merge, ok,rn)) %>%
          arrange(username,Type,Entry)
          
    #Check if the file exists if so erase it       
    if (file.exists(processed_filename)) {
        file.remove(processed_filename)
        file.remove(processed_filename_save)
    } 
          
    write.xlsx(data, processed_filename_save)  
    
    #Remove unecessary datasets
    rm(correction_dup,correction,data) 
}  

#Bind all the "cleaned" datasets    
################################################################################
  # Get a list of all CSV files in the directory
  file_list <- list.files(pattern = "\\processed.xlsx$", full.names = TRUE)
  
  # Read and combine all CSV files
  combined_data <- file_list %>%
                   lapply(read.xlsx) %>% # Read each CSV file into a list of dataframes
                   bind_rows() %>%  # Combine all dataframes into one
                   mutate(Profile_Name = gsub("\\s+", " ", Profile_Name),  # Replace multiple spaces with a single space
                   Profile_Name = gsub("\\.", "", Profile_Name),           # Remove all periods
                   Profile_Name = gsub(" - CEFA", "", Profile_Name), 
                   Profile_Name = gsub(" CFA", "", Profile_Name),
                   name  = tolower(as.character(Profile_Name)), #Variable to lower case
                   name2 = stri_trans_general(name, "Latin-ASCII"), # Remove special characters 
                   name_1 = gsub("'", " ", gsub("-", " ", name)),
                   name2_1 = gsub("'", " ", gsub("-", " ", name2)),
                   space_count = str_count(name, " "),
                   space_count_1 = str_count(name_1, " ")) 
  
  #Maximum number of reported names
  max_names <- max(combined_data$space_count) +1
  max_names_1 <- max(combined_data$space_count_1) +1
  
  # Create dynamic column names
  column_names <- paste0("name__", seq_len(max_names))
  column_names2 <- paste0("name2__", seq_len(max_names))
  
  column_names_1 <- paste0("name_1__", seq_len(max_names_1))
  column_names2_1 <- paste0("name2_1__", seq_len(max_names_1))
  
  
  #Split Names, correct for duplicates
  temp_split_names <- combined_data %>% 
    distinct(username,name,name2,name_1,name2_1) %>%  
    separate(name, into = column_names, sep=" ", fill = "right", extra = "merge") %>%
    separate(name2, into = column_names2, sep=" ", fill = "right", extra = "merge") %>%
    separate(name_1, into = column_names_1, sep=" ", fill = "right", extra = "merge") %>%
    separate(name2_1, into = column_names2_1, sep=" ", fill = "right", extra = "merge") %>%
    mutate(merge=1)  %>%
    group_by(username) %>% 
    arrange(username) %>%
    ungroup() 
  
  split_names <- temp_split_names %>%
    distinct(username, across(all_of(column_names))) %>%
    # Unite all names into a single list for each row
    mutate(all_names = pmap(across(all_of(column_names)), 
                            ~ c(...))) %>%
    # Remove NA values from the list of names
    mutate(all_names = map(all_names, ~ .x[!is.na(.x)])) %>%
    # Create all ordered combinations of pairs from the names
    mutate(name_combinations = map(all_names, ~ combn(.x, 2, FUN = paste, collapse = " ", simplify = FALSE))) %>%
    unnest(name_combinations) %>% select(username, name_combinations)
  
  
  split_names_1 <- temp_split_names %>%
    distinct(username, across(all_of(column_names_1))) %>%
    # Unite all names into a single list for each row
    mutate(all_names = pmap(across(all_of(column_names_1)), 
                            ~ c(...))) %>%
    # Remove NA values from the list of names
    mutate(all_names = map(all_names, ~ .x[!is.na(.x)])) %>%
    # Create all ordered combinations of pairs from the names
    mutate(name_combinations = map(all_names, ~ combn(.x, 2, FUN = paste, collapse = " ", simplify = FALSE))) %>%
    unnest(name_combinations) %>% select(username, name_combinations)
  
  split_names2 <- temp_split_names %>%
    distinct(username, across(all_of(column_names2))) %>%
    # Unite all names into a single list for each row
    mutate(all_names = pmap(across(all_of(column_names2)), 
                            ~ c(...))) %>%
    # Remove NA values from the list of names
    mutate(all_names = map(all_names, ~ .x[!is.na(.x)])) %>%
    # Create all ordered combinations of pairs from the names
    mutate(name_combinations = map(all_names, ~ combn(.x, 2, FUN = paste, collapse = " ", simplify = FALSE))) %>%
    unnest(name_combinations) %>% select(username, name_combinations)
  
  split_names2_1 <- temp_split_names %>%
    distinct(username, across(all_of(column_names2_1))) %>%
    # Unite all names into a single list for each row
    mutate(all_names = pmap(across(all_of(column_names2_1)), 
                            ~ c(...))) %>%
    # Remove NA values from the list of names
    mutate(all_names = map(all_names, ~ .x[!is.na(.x)])) %>%
    # Create all ordered combinations of pairs from the names
    mutate(name_combinations = map(all_names, ~ combn(.x, 2, FUN = paste, collapse = " ", simplify = FALSE))) %>%
    unnest(name_combinations) %>% select(username, name_combinations)
  
  split_names_comb <- rbind(split_names,split_names_1,split_names2_1,split_names2) %>%
    distinct()
    
  file.remove(file_list)
  
tabulate(combined_data,"merge")  

tabulate(combined_data,"university") 

#catolica    iscte     iseg     nova 
#    7464    27688    16128    12008 

#Basic check on the number of variables (at 10/09) 8 units per username/uni
count_username <- combined_data %>% 
                  group_by(username,university) %>%
                  summarise(user_count=n())

data_edu <- combined_data %>% 
            filter(Type=="Education") %>% 
            select(-c(CompanyName, LocationName, Title,space_count)) %>%
            mutate(missing_educ=rowSums(is.na(select(., DegreeName:StartDate))),
                   missing_all_educ=ifelse(missing_educ==5,1,0)) %>%
            group_by(username, university) %>%
            mutate(total_missing_all_educ = sum(missing_all_educ, na.rm = TRUE)) %>% #Number of entries with missing  
            ungroup()  # Optionally ungroup the data if no further grouping is needed

tabulate(data_edu,"total_missing_all_educ")/3 

# 0    1     2    3 
# 5156 1883  632  240  

data_exp <- combined_data %>% 
            filter(Type=="Experience") %>% 
            select(-c(DegreeName, FieldOfStudy, SchoolName,space_count)) %>%
            mutate(missing_exp=rowSums(is.na(select(., EndDate:Title))),
            missing_all_exp=ifelse(missing_exp==5,1,0)) %>%
            group_by(username, university) %>%
            mutate(total_missing_all_exp = sum(missing_all_exp, na.rm = TRUE)) %>% #
            ungroup() 

# 0     1    2    3    4    5 
# 5206  814  618  394  302  577 

tabulate(data_exp,"total_missing_all_exp")/5 

rm(count_username,combined_data, split_names)

universities <- data_edu %>% 
                filter(StartDate==2014) %>%
                distinct(SchoolName)

processed_filename_save <- "temp_univeristies_2014.xlsx"
#write.xlsx(universities, processed_filename_save)
universities <- read.xlsx(processed_filename_save)

degrees <- data_edu %>% 
           filter(StartDate==2014) %>%
           left_join(universities, by="SchoolName") %>%
           distinct(DegreeName) 

processed_filename_save <- "temp_degrees_2014.xlsx"
#write.xlsx(degrees, processed_filename_save)
degrees <- read.xlsx(processed_filename_save)

fields <- data_edu %>% 
           filter(StartDate==2014) %>%
           left_join(universities, by="SchoolName") %>%
           filter(keep==1) %>%
           left_join(degrees, by="DegreeName") %>% 
           filter(drop==0) %>%
           distinct(FieldOfStudy) 

processed_filename_save <- "temp_fields_2014.xlsx"
#write.xlsx(fields, processed_filename_save)
fields <- read.xlsx(processed_filename_save)


data_edu2 <- data_edu %>% 
              filter(StartDate==2014) %>%
              left_join(universities, by="SchoolName") %>%
              filter(keep==1) %>%
              left_join(degrees, by="DegreeName") %>% 
              filter(drop==0) %>% select(-drop) %>%
              left_join(fields, by="FieldOfStudy") %>% 
              filter(drop==0) %>%
              mutate(StartDate = as.numeric(StartDate),
                     EndDate = as.numeric(EndDate),
                     num_years = EndDate - StartDate) %>%
              left_join( data_exp %>% distinct(username,university,total_missing_all_exp), by=c("username","university")) %>%
              filter(total_missing_all_educ!=2 | total_missing_all_exp!=5) %>%
              filter(!is.na(num_years) & num_years>2)


tabulate(data_edu2,"university")

#catolica    iscte     iseg     nova 
#185         724       373      314 

# Set the working directory to the temporary data_folder
setwd(base_dir)
#Save a dataset with those that we are sure about the situation
write.xlsx(data_edu2, "education_2014.xlsx")
write.xlsx(split_names_comb, "names_linkedin_2014.xlsx")

data_edu2 <- data_edu %>% 
             filter(StartDate>=2014) %>%
             distinct(username,name,university)

write.xlsx(data_edu2, "education_gen_2014.xlsx")


