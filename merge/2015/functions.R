duplicates <- function(data, group_vars) {
  # Ensure the columns exist in the data
  if(!all(group_vars %in% colnames(data))) {
    stop("Not all group_vars are present in the dataset")
  }
  
  # Group by the specified variables and count occurrences
  data %>%
    group_by(across(all_of(group_vars))) %>%
    summarise(count = n(), .groups = 'drop') %>%
    filter(count>1)
}

# Define the function
process_data_for_correction <- function(csv_filename) {
  
  # Read and process the CSV file
  data <- read_csv(csv_filename) %>%
    distinct() %>%  # Remove duplicates
    mutate(
      profile_name = sub(",.*", "", profile_name),  # Remove everything after a comma in the name
    )
  
  # Generate name data to be corrected manually
  name_corr <- data %>% 
    select(profile_name, username)
  
  # Return the result
  return(list(name_corr = name_corr, data = data))
}

# Define the function
tabulate <- function(data, ...) {
  variables <- list(...)
  
  if (length(variables) == 1) {
    # Tabulate for one variable
    tabulated <- table(data[[variables[[1]]]])
  } else if (length(variables) == 2) {
    # Tabulate for two variables
    tabulated <- table(data[[variables[[1]]]], data[[variables[[2]]]])
  } else {
    stop("The function only supports one or two variables.")
  }
  
  print(tabulated)
}

# Function to split names into separate columns
split_names <- function(profile_name) {
  # Split the profile name by space
  names <- unlist(strsplit(profile_name, " "))
  # Create a vector with NA for missing columns
  length(names) <- max(sapply(combined_data$Profile_Name, function(x) length(unlist(strsplit(x, " ")))))
  return(names)
}