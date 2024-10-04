import json
import csv
import unicodedata
import pandas as pd
import ftfy
from urllib.parse import unquote
import logging

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Function to fix the encoding of a given text
def fix_text_encoding(text):
    if isinstance(text, str):
        return ftfy.fix_text(text)
    return text

# Function to read JSON file with UTF-8 encoding and handle errors
def read_json(file_path):
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            return json.load(file)
    except json.JSONDecodeError as e:
        logging.error(f"Error decoding JSON from file {file_path}: {e}")
        return None
    except FileNotFoundError as e:
        logging.error(f"File not found: {file_path}: {e}")
        return None

# Function to normalize and fix text encoding
def normalize_text(text):
    if isinstance(text, str):
        text = unicodedata.normalize('NFKD', text)
        text = fix_text_encoding(text)
        text = unquote(text)
        return text
    return text

# Function to format date components
def format_date_component(component):
    if component is not None and component != '':
        return str(component)
    return ''

# Function to flatten experience and education data in JSON
def flatten_experience_education(data, required_keys):
    flattened_data = []

    for profile in data:
        flattened_profile = {
            'First_Name': normalize_text(profile.get('firstName', '')),
            'Last_Name': normalize_text(profile.get('lastName', '')),
            'username': normalize_text(profile.get('public_id', '')),
            'Location_Name': normalize_text(profile.get('locationName', '')),
            'Industry_Name': normalize_text(profile.get('industryName', ''))
            
        }

        # Process experience
        experiences = profile.get('experience', [])
        for i, exp in enumerate(experiences):
            exp_num = i + 1
            flattened_profile[f'{exp_num}_Experience_CompanyName'] = normalize_text(exp.get('companyName', ''))
            flattened_profile[f'{exp_num}_Experience_Title'] = normalize_text(exp.get('title', ''))
            flattened_profile[f'{exp_num}_Experience_LocationName'] = normalize_text(exp.get('locationName', ''))
            start_date = exp.get('timePeriod', {}).get('startDate', {})
            end_date = exp.get('timePeriod', {}).get('endDate', {})
            flattened_profile[f'{exp_num}_Experience_StartDate'] = normalize_text(f"{format_date_component(start_date.get('month', ''))}/{format_date_component(start_date.get('year', ''))}") if start_date else ''
            flattened_profile[f'{exp_num}_Experience_EndDate'] = normalize_text(f"{format_date_component(end_date.get('month', ''))}/{format_date_component(end_date.get('year', ''))}") if end_date else 'currently working'

        # Process education
        educations = profile.get('education', [])
        for i, edu in enumerate(educations):
            edu_num = i + 1
            flattened_profile[f'{edu_num}_Education_SchoolName'] = normalize_text(edu.get('schoolName', ''))
            flattened_profile[f'{edu_num}_Education_DegreeName'] = normalize_text(edu.get('degreeName', ''))
            flattened_profile[f'{edu_num}_Education_FieldOfStudy'] = normalize_text(edu.get('fieldOfStudy', ''))
            start_date = edu.get('timePeriod', {}).get('startDate', {})
            end_date = edu.get('timePeriod', {}).get('endDate', {})
            flattened_profile[f'{edu_num}_Education_StartDate'] = normalize_text(f"{format_date_component(start_date.get('year', ''))}") if start_date else ''
            flattened_profile[f'{edu_num}_Education_EndDate'] = normalize_text(f"{format_date_component(end_date.get('year', ''))}") if end_date else ''

        # Ensure all required keys are present
        for key in required_keys:
            if key not in flattened_profile:
                flattened_profile[key] = ''

        flattened_data.append(flattened_profile)

    return flattened_data

# Function to write the flattened data to a CSV file with UTF-8 BOM encoding
def write_csv(flattened_data, csv_file_path):
    if not flattened_data:
        return

    keys = flattened_data[0].keys()
    with open(csv_file_path, 'w', newline='', encoding='utf-8-sig') as csv_file:
        dict_writer = csv.DictWriter(csv_file, fieldnames=keys)
        dict_writer.writeheader()
        dict_writer.writerows(flattened_data)

# Function to combine first and last names, sort by profile name, and save to a new CSV
def combine_and_sort_names(input_csv_path, output_csv_path):
    df = pd.read_csv(input_csv_path, encoding='utf-8-sig')
    df['Profile Name'] = df['First_Name'] + ' ' + df['Last_Name']
    df.sort_values(by='Profile Name', inplace=True)
    df.to_csv(output_csv_path, index=False, encoding='utf-8-sig')

# Required keys identified from the differing keys logs
required_keys = [
    '1_Experience_CompanyName', '1_Experience_Title', '1_Experience_LocationName', '1_Experience_StartDate', '1_Experience_EndDate',
    '2_Experience_CompanyName', '2_Experience_Title', '2_Experience_LocationName', '2_Experience_StartDate', '2_Experience_EndDate',
    '3_Experience_CompanyName', '3_Experience_Title', '3_Experience_LocationName', '3_Experience_StartDate', '3_Experience_EndDate',
    '4_Experience_CompanyName', '4_Experience_Title', '4_Experience_LocationName', '4_Experience_StartDate', '4_Experience_EndDate',
    '5_Experience_CompanyName', '5_Experience_Title', '5_Experience_LocationName', '5_Experience_StartDate', '5_Experience_EndDate',
    '1_Education_SchoolName', '1_Education_DegreeName', '1_Education_FieldOfStudy', '1_Education_StartDate', '1_Education_EndDate',
    '2_Education_SchoolName', '2_Education_DegreeName', '2_Education_FieldOfStudy', '2_Education_StartDate', '2_Education_EndDate',
    '3_Education_SchoolName', '3_Education_DegreeName', '3_Education_FieldOfStudy', '3_Education_StartDate', '3_Education_EndDate'
]

# Paths to the input and output files
input_json_path = r"C:\Users\priiy\Downloads\SCRAPING\json\iscte\merged_iscte.json"
intermediate_csv_path = r"C:\Users\priiy\Downloads\SCRAPING\json\iscte\iscte_intermediate.csv"
output_csv_path = r"C:\Users\priiy\Downloads\SCRAPING\json\iscte\iscte_sorted.csv"

# Read the JSON data
data = read_json(input_json_path)

# Check if data is not None before proceeding
if data is not None:
    # Flatten the JSON data
    flattened_data = flatten_experience_education(data, required_keys)

    # Write the flattened data to a CSV file
    write_csv(flattened_data, intermediate_csv_path)

    # Combine first and last names, sort by profile name, and save to a new CSV
    combine_and_sort_names(intermediate_csv_path, output_csv_path)

    logging.info("Combined and sorted names saved to 'iseg_sorted.csv'.")
else:
    logging.error("No data to process. Exiting.")
