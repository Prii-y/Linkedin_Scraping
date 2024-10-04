import os
import pandas as pd
import ftfy
from urllib.parse import unquote

# Function to fix the encoding of a given text
def fix_text_encoding(text):
    if isinstance(text, str):
        return ftfy.fix_text(text)
    return text

# Define the folder containing the CSV files
folder_path = r'C:\Users\priiy\Downloads\SCRAPING\excel_profiles\iscte\2015'

# List to store individual DataFrames
dataframes = []

# Loop through all files in the folder
for filename in os.listdir(folder_path):
    file_path = os.path.join(folder_path, filename)
    
    # Ensure it is a CSV file and not a directory
    if filename.endswith(".csv") and os.path.isfile(file_path):
        # print(f"Processing file: {file_path}")  # Debugging output
        try:
            # Read the current CSV file
            df = pd.read_csv(file_path, encoding='utf-8-sig')
            # Append the DataFrame to the list
            dataframes.append(df)
        except Exception as e:
            print(f"Error reading {file_path}: {e}")

# Combine all DataFrames into a single DataFrame if there are any CSVs processed
if dataframes:
    combined_df = pd.concat(dataframes, ignore_index=True)

    # Drop duplicates based on the 'LinkedIn URL' column
    combined_df_cleaned = combined_df.drop_duplicates(subset=['LinkedIn URL']).copy()

    # Remove any BOM from column names
    combined_df_cleaned.columns = combined_df_cleaned.columns.str.replace('ï»¿', '')

    # Extract the LinkedIn usernames from the URLs and decode them
    combined_df_cleaned.loc[:, 'username'] = combined_df_cleaned['LinkedIn URL'].str.extract(r'https://www\.linkedin\.com/in/([^?]+)')
    combined_df_cleaned.loc[:, 'username'] = combined_df_cleaned['username'].apply(unquote)

    # Fix any misencoded text in the usernames and Profile Name column
    combined_df_cleaned.loc[:, 'username'] = combined_df_cleaned['username'].apply(fix_text_encoding)
    combined_df_cleaned.loc[:, 'Profile Name'] = combined_df_cleaned['Profile Name'].apply(fix_text_encoding)

    # Specify the output file path for the cleaned and processed data
    output_file_path = r"C:\Users\priiy\Downloads\SCRAPING\excel_profiles\iscte_bschool\2015\iscte_combined_2015.csv"

    # Write the cleaned, combined DataFrame with the username column to a CSV file
    combined_df_cleaned.to_csv(output_file_path, index=False, encoding="utf-8-sig")

    print(f"All CSV files have been combined, duplicates removed, usernames extracted, and saved to {output_file_path}")
else:
    print("No valid CSV files were found.")
