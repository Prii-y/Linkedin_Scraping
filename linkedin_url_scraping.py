import os
import random
import time
import csv
import pandas as pd
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.chrome.options import Options
from selenium.common.exceptions import NoSuchElementException, ElementClickInterceptedException
from dotenv import load_dotenv

# Load environment variables from a .env file
load_dotenv()

# access the variables
linked_email = os.getenv('LINKEDIN_EMAIL')
linked_password = os.getenv('LINKEDIN_PASSWORD')



# Function to filter DataFrame based on the year input
def filter_by_year_and_uni(df,uni, year):
    return df[(df['ano'] == year) & (df['nome_estab'] == uni)]


# & (df['nome_estab'] == uni)
# Function to rotate user agents
def get_random_user_agent():
    user_agents = [
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.2 Safari/605.1.15",
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:89.0) Gecko/20100101 Firefox/89.0",
    ]
    return random.choice(user_agents)

# Function to scroll down the page
def scroll_down_page(driver):
    last_height = driver.execute_script("return document.body.scrollHeight")
    while True:
        driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
        time.sleep(random.uniform(4, 6))

        try:
            show_more_button = driver.find_element(By.XPATH, "//button[text()='Show more results']")
            show_more_button.click()
            time.sleep(random.uniform(4, 6))
        except (NoSuchElementException, ElementClickInterceptedException):
            new_height = driver.execute_script("return document.body.scrollHeight")
            if new_height == last_height:
                break
            last_height = new_height
    time.sleep(random.uniform(4, 6))

# Function to scrape profiles and save to CSV
def scrape_profiles(driver, name, directory):
    li_elem = driver.find_elements(By.CSS_SELECTOR, "div.scaffold-finite-scroll__content>ul>li")

    # Create directory if it doesn't exist
    if not os.path.exists(directory):
        os.makedirs(directory)

    file_path = os.path.join(directory, f'{name}_linkedin_profiles.csv')

    with open(file_path, mode='w', newline='', encoding='utf-8-sig') as csv_file:
        fieldnames = ['Profile Name', 'LinkedIn URL']
        writer = csv.DictWriter(csv_file, fieldnames=fieldnames)
        writer.writeheader()

        for li in li_elem:
            if li.find_elements(By.CSS_SELECTOR, ".org-people-profile-card__profile-title"):
                profile_title_div = li.find_element(By.CSS_SELECTOR, ".org-people-profile-card__profile-title")
                if "LinkedIn Member" in profile_title_div.text:
                    print("Access Issue")
                else:
                    profile_name = profile_title_div.text.strip()
                    profile_link = li.find_element(By.CSS_SELECTOR, "a.app-aware-link").get_attribute("href")
                    writer.writerow({'Profile Name': profile_name, 'LinkedIn URL': profile_link})
    time.sleep(random.uniform(4, 6))

# Load and filter the CSV file
file_path = r"C:\Users\priiy\Downloads\SCRAPING\students_nova_iscte_iseg.csv"
try:
    df = pd.read_csv(file_path, encoding='utf-8')
except UnicodeDecodeError:
    df = pd.read_csv(file_path, encoding='ISO-8859-1')

year = 2015
uni='ISCTE - Instituto Universitário de Lisboa'
filtered_df = filter_by_year_and_uni(df,uni,year)
filtered_df = filtered_df['first_name'].unique()

filtered_df = pd.DataFrame(filtered_df)
print(filtered_df)

output_directory = r"C:\Users\priiy\Downloads\iscte\2015"

# Initialize the Chrome WebDriver with configured options
chrome_options = Options()
chrome_options.add_argument("--incognito")
chrome_options.add_argument(f"user-agent={get_random_user_agent()}")
# chrome_options.add_argument("--headless")  # Optionally use headless mode

driver = webdriver.Chrome(options=chrome_options)

# Open LinkedIn and navigate to login page
driver.get("https://www.linkedin.com/login?fromSignIn=true&trk=guest_homepage-basic_nav-header-signin")
time.sleep(random.uniform(2, 5))

username = driver.find_element(By.NAME, "session_key")
password = driver.find_element(By.NAME, "session_password")
signin = driver.find_element(By.CSS_SELECTOR, "button.btn__primary--large.from__button--floating")


time.sleep(random.uniform(2, 5))
username.send_keys(linked_email)  # Replace with your email
time.sleep(random.uniform(2, 5))
password.send_keys(linked_password)  # Replace with your password
time.sleep(random.uniform(2, 5))
signin.click()

print('Logged in')
time.sleep(random.uniform(5, 10))

# Navigate to the university's LinkedIn page
university_name = "iscte"
driver.get(f"https://www.linkedin.com/school/{university_name}/")
time.sleep(random.uniform(3, 6))

# Click on the "Alumni" tab
alumni_tab = driver.find_element(By.LINK_TEXT, 'Alumni')
print('Alumni tab found')
alumni_tab.click()
time.sleep(random.uniform(3, 6))

# Filter the alumni by the graduation year
search_field_start = driver.find_element(By.ID, "people-search-year-start")
search_field_start.send_keys("2015")
search_field_start.send_keys(Keys.RETURN)
time.sleep(random.uniform(3, 5))
search_field_end = driver.find_element(By.ID, "people-search-year-end")
search_field_end.send_keys("2015")
search_field_end.send_keys(Keys.RETURN)
time.sleep(random.uniform(3, 6))

# Iterate over each name in the first_name column
used_names = set()

for name in filtered_df[0]:
    if name not in used_names:
        used_names.add(name)

        file_path = os.path.join(output_directory, f'{name}_linkedin_profiles.csv')
        
        if os.path.exists(file_path):
            print(f"Skipping {name}, file already exists.")
            continue  # Skip this name and move to the next one

        name_search_field = driver.find_element(By.ID, "people-search-keywords")
        name_search_field.clear()
        name_search_field.send_keys(name)
        name_search_field.send_keys(Keys.RETURN)
        time.sleep(random.uniform(3, 6))

        scroll_down_page(driver)
        scrape_profiles(driver, name, output_directory)

        driver.execute_script("window.scrollTo(0, 0);")
        time.sleep(random.uniform(3, 6))

        try:
            name_button = driver.find_element(By.XPATH, f"//span[text()='{name}']/ancestor::button")
            name_button.click()
            time.sleep(random.uniform(3, 6))
        except NoSuchElementException:
            print(f"Button for name {name} not found")
            break

driver.quit()