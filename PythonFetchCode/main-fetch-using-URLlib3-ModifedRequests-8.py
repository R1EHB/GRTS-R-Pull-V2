# This Python file uses the following encoding: utf-8


#####
#    Something going wrong with 04* HUCs, mainly vermont
#
######
'''
Python Code to fetch json data from GRTS Server by HUC12,
disentagle it, and write to a file for further analysis via R.

Switching to a mixed environment from pure R because I think
python handles messy nested JSON better than R.

Date of last mod: 22 April 2025

Adding some pandas data structures to facilitate conversion to R dataset



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
import pandas as pd
import pyarrow as pa
import pyarrow.feather as feather
import openpyxl
# import xlsxwriter

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
        retries = Retry(connect=5, read=2, redirect=5)
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
G_OUTPUT_BASE_NAME = '../DataOutput/GRTS-Data-NewEng-byHUC'
G_INPUT_HUC12_FILE = '../../HUC-it/HUC-Data-Lists/New_England_HUC12s.csv'
G_NORMAL_SLEEP_TIME = 0.75
G_ERROR_SLEEP_TIME = 3
G_HUC_PROGRESS_FILE = '../DataOutput/HUC-ProgressReport.txt'
G_API_BASE = 'https://ordspub.epa.gov/ords/grts_rest/grts_rest_apex/grts_rest_apex/GetProjectsByHUC12/'

# Change this as needed
line_end = G_LINE_END_DOS

class HUC12List:

    def __init__(self, infile_name=G_INPUT_HUC12_FILE ):
        self.infile_name = infile_name
        self.huc12_list = []
        self.huc_progres_name = G_HUC_PROGRESS_FILE

        self.huc_progres_file = open (self.huc_progres_name,'w',
                                      encoding="utf-8")

        self.huc_progres_file.write("These HUCs Processed: \n")
        
        with open (self.infile_name, newline='') as self.csvfile:
            self.filereader = csv.DictReader(self.csvfile, delimiter = ',',
                quotechar='"')
                
            for row in self.filereader:
                self.huc12_list.append(row)

        
    def print_hucs(self):
        print (self.huc12_list)

    def write_hucs_done(self,huc_data):

        self.huc_progres_file.write(huc_data)
        self.huc_progres_file.write(line_end)
        

    def __del__(self):
        # Close File
        self.csvfile.close()
        self.huc_progres_file.close()
            
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
        if grts_response.status_code !=200:
            self.slow_retrieval(grts_response.status_code)
        
        self.grts_data_by_huc.append(grts_response.json())
        self.grts_status_by_huc.append(grts_response.status_code)
        
        return (json.loads(grts_response.content))
    
    def slow_retrieval (r_code):


        # get a big record, see 010600030901
        # grab error codes to analyze?
        print ("Response Code: " + r_code)
        time.sleep (G_ERROR_SLEEP_TIME)
       
        return

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
        # print (self.output_file_name)
        
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
    def __init__(self,output_file_type='csv.txt'):
        self.output_file_type=output_file_type
        self.field_delim=';' # consider using something else, like | or \t or ¬
        self.output_file_name = self.output_base_name + '_' + self.output_file_type
        self.output_file = open (self.output_file_name,'w', encoding="utf-8")
        self.headr_file = open ("data-Header-Row.txt", 'r',encoding="utf-8")
        # Insert headr line into csv file
        # Write CSV header row
        for headline in self.headr_file:
            self.write_data_2_disk(headline) # should only be one line
        
    def write_data_2_disk(self, data_to_write):
        self.output_file.write(data_to_write)
            
    def __del__(self):

        # Something here?
        self.output_file.close()
        

class GRTSPandasFrame(GRTSDataParent):
    def __init__(self,excel_output_file_type='pandas.xlsx',
                 feather_output_file_type='pandas.feather'):
        self.excel_output_file_name = self.output_base_name + '.' + excel_output_file_type
        self.feather_output_file_name = self.output_base_name + '.' + feather_output_file_type
        self.project_level_info = []
        
        
    def add_data_2_list(self, data_to_add):
        self.project_level_info.append(data_to_add)

    def createDframe(self):
        pandaFrame = pd.DataFrame(self.project_level_info)
        return (pandaFrame)
        
    def write_data_2_excel(self, data_to_write):
        dframe=data_to_write
        print()
        print("writing pandas to excel file")
        dframe.to_excel(self.excel_output_file_name)
        
    def __del__(self):
        print(self.project_level_info)
        
    def write_data_2_feather(self, data_to_write):
        feather.write_feather(data_to_write,self.feather_output_file_name)

def main():
    
    NewE_hucs =  HUC12List(G_INPUT_HUC12_FILE)
    #  NewE_hucs.print_hucs
    GRTS_Data = GRTSDataParent(NewE_hucs.huc12_list)
    pickle_data = GRTSDataPickled()
    json_data = GRTSDataJson()
    jsonLD_data = GRTSDataJsonLD()
    csv_data = GRTSDataCSV()
    p_frame=GRTSPandasFrame()
    
    for row in GRTS_Data.input_huc12_data:
        # print (row)
        data = GRTS_Data.retrieve_GRTS_data(row['huc12'])
        print ("Data:")
        print (data)
        print (" ")
        json_data.write_data_2_disk(data)
        jsonLD_data.write_data_2_disk(data)
        NewE_hucs.write_hucs_done(row['huc12'])
        time.sleep(G_NORMAL_SLEEP_TIME) # Sleep to avoid rate limits
        

    pickle_data.dump_data_to_disk()

    for in_row in GRTS_Data.grts_data_by_huc:
        for subentries in in_row['items']: # Row loop
            e_dict=subentries.keys()
            dict_val=subentries.values()
            for cols in dict_val: # columns/variables
                col_data = str (cols)
                csv_data.write_data_2_disk(col_data)
                csv_data.write_data_2_disk(csv_data.field_delim)
                
            csv_data.write_data_2_disk(line_end)
            p_frame.add_data_2_list(subentries)
            
    dframe=p_frame.createDframe()
    p_frame.write_data_2_excel(dframe)
    p_frame.write_data_2_feather(dframe)
    sys.exit()
    return
    
if __name__ == "__main__":
    main()





