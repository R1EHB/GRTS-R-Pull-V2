'''
Python Code to fetch json data from GRTS Server by HUC12,
disentagle it, and write to a file for further analysis via R.

Switching to a mixed environment from pure R because I think
python handles messy nested JSON better than R.

Date of last mod: 2 April 2025

######

New Plan for this code, to simplify reading and fixing it.

Create a class for handling the output files, and methods to write
data accordingly.

Keep the class for custom http, and separate method for opening a
legacy session.

Objective is to make the nested if /for loops easier to deal with.

Concrete problem to fix is output format for machine json and csv is
wrong.



'''

# Main Import Block
import csv
import sys
import ssl
import time
import pickle
import inspect

import requests
import urllib3
import json


from urllib3.util.retry import Retry

class CustomHttpAdapter (requests.adapters.HTTPAdapter):
    ## "Transport adapter" that allows us to use custom ssl_context.
    # Special Handler to cope with SSl Renegotiation Failure from
    # TLS 1.3 to TLS 1.2: RFC 5746 Error
    # Per: https://stackoverflow.com/questions/71603314/ssl-error-unsafe-legacy-renegotiation-disabled


    def __init__(self, ssl_context=None, **kwargs):
        ## The constructor
        self.ssl_context = ssl_context
        super().__init__(**kwargs)

    def init_poolmanager(self, connections, maxsize, block=False):
        # retries = Retry(total=5, backoff_factor=0.1, status_forcelist=[500, 502, 503, 504])
        # retries = Retry(connect=5, read=2, redirect=5)
        self.poolmanager = urllib3.poolmanager.PoolManager(
            num_pools=connections, maxsize=maxsize,
            block=block, ssl_context=self.ssl_context,retries=5)


def get_legacy_session():
    ## Special handler for https sessions
    # Given RFC 5746
    # Problem pops up on Windows with EPA's gateway Apache server

    ctx = ssl.create_default_context(ssl.Purpose.SERVER_AUTH)
    ctx.options |= 0x4  # OP_LEGACY_SERVER_CONNECT
    session = requests.session()
    session.mount('https://', CustomHttpAdapter(ctx))
    return session




# Open CSV file with HUC12 codes and other information desired
# Isolate the HUC12 codes from other material in the CSV file (such as
# state, square area, etc)

# Globals, for class variables

G_LINE_END_DOS='\r'
G_LINE_END_UNIX='\r\n'
G_OUTPUT_BASE_NAME = './DataOutput/HUC-NewEng-test'
G_INPUT_HUC12_FILE = '../HUC-it/HUC-Data-Lists/New_England_HUCs.csv'
G_SLEEP_TIME = 1

G_API_BASE = 'https://ordspub.epa.gov/ords/grts_rest/grts_rest_apex/grts_rest_apex/GetProjectsByHUC12/'

# Change this as needed
line_end = G_LINE_END_DOS

class HUC12List:

    def __init__(self, infile_name=G_INPUT_HUC12_FILE ):
        self.infile_name = infile_name
        self.huc12_list = []
        print (self.infile_name)

        with open (self.infile_name, newline='') as self.csvfile:
            self.filereader = csv.DictReader(self.csvfile, delimiter = ',',
                quotechar='"')
                
            for row in self.filereader:
                #print (row)
                self.huc12_list.append(row)

    def print_hucs(self):
        print (self.huc12_list)

    def __del__(self):
        # Close File
        self.csvfile.close()
            
class GRTSDataParent:
    output_base_name = G_OUTPUT_BASE_NAME
    grts_data_by_huc = []
    grts_response_by_huc = []
    grts_status_by_huc =[]
    input_huc12_data = []
    
    def __init__(self,  huc12_data_list, output_file_type='parent'):
        '''
        huc12_data is an instance of class HUC12LIST
        '''
                 
        self.output_file_type = output_file_type
        self.input_huc12_data = huc12_data_list
        self.output_file_name = self.output_base_name + '.' + self.output_file_type

    def retrieve_GRTS_data (self, HUC_12_number, api_base=G_API_BASE):
        grts_response = get_legacy_session().get(api_base+HUC_12_number)
        # grts_response = requests.get(api_base+HUC_12_number)
        # Probably need better error handling (better ways to recover, pause, resume)
        while grts_response.status_code != 200: 
            # get a big record, see 010600030901
            # grab error codes to analyze?
            print ("Response Code: " + grts_response.status_code)
            time.sleep (3)
            # flush()
            grts_response = get_legacy_session().get(api_base+HUC_12_number)
            # grts_response = requests.get(api_base+HUC_12_number)
        print ("encoding: " + grts_response.encoding)
        print ("Status Code:")
        print (grts_response.status_code)
        print ("Text: " + grts_response.text)
        print ("Json: " + json.loads(grts_response.json()))
        self.grts_data_by_huc.append(json.loads(grts_response.content))
        self.grts_status_by_huc.append(grts_response.status_code)
        print ("****")
        # print (json.loads(grts_response))
        return (json.loads(grts_response.content))


class GRTSDataPickled(GRTSDataParent):
    ''' Pickled data dump '''
    
    def __init__(self,output_file_type='pickled'):
        self.output_file_type=output_file_type
        self.output_file_name = self.output_base_name + '.' + self.output_file_type
        self.output_file = open (self.output_file_name,'wb')

    def dump_data_to_disk(self):
        ''' Whole dataset at once '''
        pickle.dump(self.grts_data_by_huc, self.output_file)

    def __del__(self):
        self.output_file.close()

class GRTSDataJson(GRTSDataParent):
    def __init__(self,output_file_type='json'):
        self.output_file_type=output_file_type
        self.output_file_name = self.output_base_name + '.' + self.output_file_type
        self.output_file = open (self.output_file_name,'w', encoding="utf-8")
        self.output_file.write('{ "data":')
        print (self.output_file_name)
        
    def write_data_2_disk(self,data_to_write):
        ''' One line at a time '''
        self.output_file.write(json.dumps(data_to_write))
        self.output_file.write(',')

    def __del__(self):
        self.output_file.write('}')
        self.output_file.close()
        
class GRTSDataJsonLD(GRTSDataParent):
    def __init__(self,output_file_type='ld.json'):
        self.output_file_type=output_file_type
        self.output_file_name = self.output_base_name + '.' + self.output_file_type
        self.output_file = open (self.output_file_name,'w', encoding="utf-8")
        
    def write_data_2_disk(self,data_to_write):
        ''' One line at a time '''
        self.output_file.write(json.dumps(data_to_write))
        self.output_file.write(line_end)

    def __del__(self):
        # self.output_file.write(']')
        self.output_file.close()    

class GRTSDataCSV(GRTSDataParent):
    def __init__(self,output_file_type='csv'):
        self.output_file_type=output_file_type
        self.output_file_name = self.output_base_name + '.' + self.output_file_type
        self.output_file = open (self.output_file_name,'w', encoding="utf-8")

        # Write CSV header row
        
        
    def __del__(self):

        # Something here?
        self.output_file.close()
        




def main():
    
    NewE_hucs =  HUC12List(G_INPUT_HUC12_FILE)
    #  NewE_hucs.print_hucs
    GRTS_Data = GRTSDataParent(NewE_hucs.huc12_list)
    pickle_data = GRTSDataPickled()
    json_data = GRTSDataJson()
    jsonLD_data = GRTSDataJsonLD()
    csv_data = GRTSDataCSV()
    
    
    # for row in GRTS_Data.input_huc12_data:
    for row in GRTS_Data.input_huc12_data[1:36:1]:
        # print (row)
        data = GRTS_Data.retrieve_GRTS_data(row['huc12'])
        print ("Data:")
        print (data)
        print (" ")
        json_data.write_data_2_disk(data)
        jsonLD_data.write_data_2_disk(data)
        time.sleep(1) # Sleep to avoid rate limits
        

    # pickle_data.dump_data_to_disk()

    # for in_row in GRTS_DATA.grts_data_by_huc:
        
    
    sys.exit()
    return
    
if __name__ == "__main__":
    main()





