'''
Python Code to fetch json data from GRTS Server by HUC12,
disentagle it, and write to a file for further analysis via R.

Switching to a mixed environment from pure R because I think
python handles messy nested JSON better than R.

Date of last mod: 29 April 2024

'''
# Main Import Block
import csv
import requests
import json
import pandas as Li_Li

# Main Python Routine

# Open CSV file with HUC12 codes and other information desired
# Isolate the HUC12 codes from other material in the CSV file (such as
# state, square area, etc)


'''

'''

with open ('./RI-huc.csv', newline='') as csvfile:
    filereader = csv.DictReader(csvfile, fieldnames=None,delimiter = '\t')
    huc12_list =[]
    
    for row in filereader:
        # print (row['huc12'])
        huc12_list.append(row['huc12'])

h_outfile   = open ('./HUC-Json-Output.human.json',   'w', encoding ="utf-8")
j_outfile   = open ('./HUC-Json-Output.machine.json', 'w', encoding ="utf-8")
csv_outfile = open ('./HUC-Output.spreadsheet.csv',   'w', encoding ="utf-8")

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

# write json data in a couple of different formats

count = 0 

j_outfile.write('{ "data": \n [')

for entries in data_by_huc:
    for subentries in entries['items']:

        h_outfile.write(json.dumps(subentries))
        j_outfile.write(json.dumps(subentries))
        h_outfile.write('\n')        
        j_outfile.write(',')
        if count == 0: # write the data headers
            e_dict = subentries.keys()
            
            for ii in e_dict:
                csv_outfile.write (ii)
                csv_outfile.write (',')
                
            csv_outfile.write ('\n')
            # csv_outfile.write(header....)
            #csv_outfile.write(data...)
            count = count +1
        else:
            # csv_outfile.write(data...)
            count = count+1

            
j_outfile.write('] \n }')

h_outfile.close
j_outfile.close
csv_outfile.close

# csv_outfile.close

# for elmts in subentries


# pandas_outfile = open ('./HUC-Panda-Output.csv', 'w', encoding ="utf-8")

# j_infile = Li_Li.read_json('./HUC-Json-Output.machine.json')

# j_infile.close


exit()


