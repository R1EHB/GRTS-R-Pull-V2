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
import json


# Special Handler to cope with SSl Renegotiation Failure from 
# TLS 1.3 to TLS 1.2: RFC 5746 Error
# Per: https://stackoverflow.com/questions/71603314/ssl-error-unsafe-legacy-renegotiation-disabled 

class CustomHttpAdapter (requests.adapters.HTTPAdapter):
    # "Transport adapter" that allows us to use custom ssl_context.

    def __init__(self, ssl_context=None, **kwargs):
        self.ssl_context = ssl_context
        super().__init__(**kwargs)

    def init_poolmanager(self, connections, maxsize, block=False):
        self.poolmanager = urllib3.poolmanager.PoolManager(
            num_pools=connections, maxsize=maxsize,
            block=block, ssl_context=self.ssl_context)


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
        filereader = csv.DictReader(csvfile, fieldnames=None,delimiter = '\t')
        huc12_list =[]
    
        for row in filereader:
            # print (row['huc12'])
            huc12_list.append(row['huc12'])
    output_dir='./DataOutput/'
    base_name_dir=output_dir+outfile_base
    h_outfile_name=base_name_dir + '.' + 'Json-Output.human.json'
    j_outfile_name=base_name_dir + '.' + 'Json-Output.machine.json'
    csv_outfile_name=base_name_dir + '.' + 'spreadsheet.csv'
    h_outfile   = open (h_outfile_name,   'w', encoding ="utf-8")
    j_outfile   = open (j_outfile_name,   'w', encoding ="utf-8")
    csv_outfile   = open (csv_outfile_name,   'w', encoding ="utf-8")
    # j_outfile   = open ('./HUC-Json-Output.machine.json', 'w', encoding ="utf-8")
    # csv_outfile = open ('./HUC-Output.spreadsheet.csv',   'w', encoding ="utf-8")

    # Build URLs from Base and HUC12's desired

    api_base = 'https://ordspub.epa.gov/ords/grts_rest/grts_rest_apex/grts_rest_apex/GetProjectsByHUC12/'

    huc12_urls=[] 

    for element in huc12_list:
        huc12_urls.append(api_base+element)
    
    # Fetch the data by HUC12 from GRTS
    data_by_huc = []
    status_by_huc = []
    for huc in huc12_urls:
        # huc_response = requests.get(huc)
        huc_response = get_legacy_session().get(huc)
        data_by_huc.append(json.loads(huc_response.content))
        status_by_huc.append(huc_response.status_code)

    # Disentangle muliple projects per HUC12, convert to JSON, write to file
                    
    # write json data in a couple of different formats

    count = 0 

    j_outfile.write('{ "data": \r\n [')

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

    h_outfile.close
    j_outfile.close
    csv_outfile.close
    sys.exit()
    return

def main():
    
    JSON_data2R('./DataInput/RI-huc.csv','HUC-O-test')
    sys.exit()
    return


if __name__ == "__main__":
    main()
    
      

