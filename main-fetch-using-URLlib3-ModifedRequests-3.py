'''
Python Code to fetch json data from GRTS Server by HUC12,
disentagle it, and write to a file for further analysis via R.

Switching to a mixed environment from pure R because I think
python handles messy nested JSON better than R.

Date of last mod: 29 April 2024

'''
# Main Import Block
import csv
import sys
import requests
import urllib3
import ssl
import time
import json
import pickle
from urllib3.util.retry import Retry


# Special Handler to cope with SSl Renegotiation Failure from 
# TLS 1.3 to TLS 1.2: RFC 5746 Error
# Per: https://stackoverflow.com/questions/71603314/ssl-error-unsafe-legacy-renegotiation-disabled 

class CustomHttpAdapter (requests.adapters.HTTPAdapter):
    # "Transport adapter" that allows us to use custom ssl_context.

    def __init__(self, ssl_context=None, **kwargs):
        self.ssl_context = ssl_context
        super().__init__(**kwargs)

    def init_poolmanager(self, connections, maxsize, block=False):
        # retries = Retry(total=5, backoff_factor=0.1, status_forcelist=[500, 502, 503, 504])
        # retries = Retry(connect=5, read=2, redirect=5)
        self.poolmanager = urllib3.poolmanager.PoolManager(
            num_pools=connections, maxsize=maxsize,
            block=block, ssl_context=self.ssl_context,retries=5)


def get_legacy_session():

    ctx = ssl.create_default_context(ssl.Purpose.SERVER_AUTH)
    ctx.options |= 0x4  # OP_LEGACY_SERVER_CONNECT
    session = requests.session()
    session.mount('https://', CustomHttpAdapter(ctx))
    return session





# Main Python Routine

# Open CSV file with HUC12 codes and other information desired
# Isolate the HUC12 codes from other material in the CSV file (such as
# state, square area, etc)



def JSON_data2R(infile, outfile_base):
    with open (infile, newline='') as csvfile:
        #filereader = csv.DictReader(csvfile, fieldnames=None,delimiter = '\t')
        filereader = csv.DictReader(csvfile, delimiter = ',')
        #print (filereader)
        huc12_list =[]
    
        for row in filereader:
            # print (row['huc12'])
            huc12_list.append(row['huc12'])
    output_dir='./DataOutput/'
    base_name_dir=output_dir+outfile_base
    h_outfile_name=base_name_dir + '.' + 'Json-Output.human.json'
    i_outfile_name=base_name_dir + '.' + 'WriteAlong.json'
    j_outfile_name=base_name_dir + '.' + 'Json-Output.machine.json'
    huc_data_dump_name =base_name_dir + '.' + 'HucDataDump.pickle'
    csv_outfile_name=base_name_dir + '.' + 'spreadsheet.csv'

    h_outfile  = open (h_outfile_name,'w', encoding="utf-8")
    i_outfile  = open (i_outfile_name, 'wb')
    j_outfile  = open (j_outfile_name,'w', encoding ="utf-8")

    # Write opening json structure
    j_outfile.write('{ "data": \r\n [')
    
    huc_data_dump_file = open (huc_data_dump_name, 'wb')
    csv_outfile   = open (csv_outfile_name,   'w', encoding ="utf-8")
   
    
    # Build URLs from Base and HUC12's desired

    api_base = 'https://ordspub.epa.gov/ords/grts_rest/grts_rest_apex/grts_rest_apex/GetProjectsByHUC12/'

    huc12_urls=[] 

    for element in huc12_list:
        huc12_urls.append(api_base+element)
    
    # Fetch the data by HUC12 from GRTS
    data_by_huc = []
    status_by_huc = []
    # for huc in huc12_urls:
    for huc in huc12_urls[1:60:1]:
        
        # huc_response = requests.get(huc)
        
            
        huc_response = get_legacy_session().get(huc)

        while huc_response.status_code != 200:
            time.sleep (3)
            flush()
            huc_response = get_legacy_session().get(huc)
            
        data_by_huc.append(json.loads(huc_response.content))
        status_by_huc.append(huc_response.status_code)
        # print (huc_response.content)
        i_outfile.write(huc_response.content)
        time.sleep(0.33)
        
                    
    i_outfile.close()

    pickle.dump(data_by_huc, huc_data_dump_file)
    huc_data_dump_file.close()


   
    
    
    # write json data in a couple of different formats, entry by entry
    # Sort and write CSV 
    count = 0     
    for entries in data_by_huc:
        for subentries in entries['items']:
            h_outfile.write(json.dumps(subentries))
            j_outfile.write(json.dumps(subentries))
            h_outfile.write('\r\n')        
            j_outfile.write(',')
            e_dict = subentries.keys()
            dict_val = subentries.values()
        
            if count == 0: # write the data headers
                    
                for ii in e_dict:
                    csv_outfile.write (ii)
                    csv_outfile.write (';')

                    csv_outfile.write ('Counter')
                    csv_outfile.write ('\r\n')
        
            
                    for jj in dict_val:
                        jk = str (jj)
            
                        csv_outfile.write(jk)
                        csv_outfile.write(';')
                        csv_outfile.write (str(count))    
                        csv_outfile.write ('\r\n')
                        count = count +1
            
                    else:
                        for lj in dict_val:
                            lk = str (lj)
                                            
                            csv_outfile.write(lk)
                            csv_outfile.write(';')
                            
                            csv_outfile.write (str(count))    
                            csv_outfile.write ('\r\n')

                            count = count+1

            
    j_outfile.write('] \r\n }')

    h_outfile.close()
    j_outfile.close()
    csv_outfile.close()
   
    sys.exit()
    return

def main():
    
    JSON_data2R('./DataInput/HUC12NewEnglandvector.csv','HUC-NewEng-test')
    sys.exit()
    return


if __name__ == "__main__":
    main()
    
      

