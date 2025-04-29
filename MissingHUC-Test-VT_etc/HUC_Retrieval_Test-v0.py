# This Python file uses the following encoding: utf-8


import ssl
import requests
import urllib3
import time
import sys
import json

from urllib3.util.retry import Retry


# Globals, for class variables

G_OUTPUT_FILE_NAME = 'test_out.txt'
# G_INPUT_HUC12_FILE = 'foo '
G_INPUT_URLs_FILE_NAME = 'test_in.txt'
# G_OUTPUT_TEST_FILE = 'foo '
G_NORMAL_SLEEP_TIME = 0.75
G_ERROR_SLEEP_TIME = 3
# G_API_BASE = 'https://ordspub.epa.gov/ords/grts_rest/grts_rest_apex/grts_rest_apex/GetProjectsByHUC12/'


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



class GRTSDataTest:

    def __init__(self):

        self.input_file_name = G_INPUT_URLs_FILE_NAME
        self.output_file_name = G_OUTPUT_FILE_NAME
        self.input_file = open (self.input_file_name,'r', encoding='utf-8')
        self.output_file = open (self.output_file_name,'w', encoding='utf-8')

    def retrieve_GRTS_data (self, full_URL):
        # (self, HUC_12_number, api_base=G_API_BASE):
        print (full_URL)
        grts_response = get_legacy_session().get(full_URL)
        if grts_response.status_code !=200:
            self.slow_retrieval(grts_response.status_code)


        return grts_response


    def slow_retrieval (self,r_code):

        print ("Response Code is " )
        print (r_code)
        time.sleep (G_ERROR_SLEEP_TIME)

        return

    def read_URLs(self):
        URL_de_file =  self.input_file.readline()

        return URL_de_file

    def write_data_2_disk(self,data_to_write):
        print (data_to_write.status_code)
        print (data_to_write.text)
        print (data_to_write.content)


        return

    def __del__(self):
        self.input_file.close()
        self.output_file.close()



def main():

    data = GRTSDataTest()

    # while data.input_file:
    the_URL='https://ordspub.epa.gov/ords/grts_rest/grts_rest_apex/grts_rest_apex/GetProjectsByHUC12/041504081101'
    print (the_URL) 
    response = data.retrieve_GRTS_data(the_URL)
    data.write_data_2_disk(response)
    time.sleep(G_NORMAL_SLEEP_TIME) # Sleep to avoid rate limits

    the_URL='https://ordspub.epa.gov/ords/grts_rest/grts_rest_apex/grts_rest_apex/GetProjectsByHUC12/041504020301 '
    print (the_URL) 
    response = data.retrieve_GRTS_data(the_URL)
    data.write_data_2_disk(response)
    time.sleep(G_NORMAL_SLEEP_TIME) # Sleep to avoid rate limits
        
    sys.exit()
    return

if __name__ == "__main__":
    main()
