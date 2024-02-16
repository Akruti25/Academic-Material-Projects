import argparse
import json
from urllib.parse import urlparse


def read_harfile(harfile_path):
    harfile = open(harfile_path)
    harfile_json = json.loads(harfile.read())
    i = 0
    for entry in harfile_json['log']['entries']:
        i = i + 1
        url = entry['request']['url']
        content_type = entry['response']['content']['mimeType'] 
        # scripts will have 'javascript' inside content type
        # images will have 'image' inside content type
        print (url, content_type)
        

read_harfile('www.macys.com.har')
