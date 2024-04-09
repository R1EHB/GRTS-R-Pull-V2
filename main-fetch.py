'''
Python Code to fetch json data from GRTS Server by HUC12,
disentagle it, and write to a file for further analysis via R.

Switching to a mixed environment from pure R because I think
python handles messy nested JSON better than R.

Date of last mod: 5 April 2024
'''
# Main Import Block
import csv
import requests
import json

# Main Python Routine

# Open CSV file with HUC12 codes and other information desired
# Isolate the HUC12 codes from other material in the CSV file (such as
# state, square area, etc)


'''
with open ('../HUC-Data-Lists/RI-huc.csv', newline='') as csvfile:
    filereader = csv.reader(csvfile, delimiter = '\t')
    for row in filereader:
        print (', '.join(row))
'''

with open ('../HUC-Data-Lists/RI-huc.csv', newline='') as csvfile:
    filereader = csv.DictReader(csvfile, fieldnames=None,delimiter = '\t')
    huc12_list =[]
    
    for row in filereader:
        # print (row['huc12'])
        huc12_list.append(row['huc12'])





# Build URLs from Base and HUC12's desired

api_base = 'https://ordspub.epa.gov/ords/grts_rest/grts_rest_apex/grts_rest_apex/GetProjectsByHUC12/'

huc12_urls=[]

for element in huc12_list:
    huc12_urls.append(api_base+element)
    
# Fetch the data by HUC12 from GRTS
    
data_by_huc = []
status_by_huc = []
for huc in huc12_urls:
    huc_response = requests.get(huc)
    data_by_huc.append(json.loads(huc_response.content))
    status_by_huc.append(huc_response.status_code)

# Disentangle muliple projects per HUC12, convert to JSON, write to file
# Read file in R


for entries in data_by_huc:
    for subentries in entries['items']:
        print (subentries)
        print ()
        
        #print (len(entries['items']))
        # print()



