#!/usr/bin/env python
#
# Read anscombe_quartet.json and insert into mongoDB
# db='ansombe', collection='quartet'

import json, pymongo

# read data from file
anscombe = json.load(open('anscombe_quartet.json'))

# put in mongoDB
mongo_client = pymongo.MongoClient()
mongo_collection = mongo_client.anscombe.quartet
mongo_collection.drop() # throw out what's there
for group in anscombe:
    mongo_collection.insert_one({'name':group, 'data':anscombe[group]})

# create index by name (silly here, but in larger problems this would be useful)
mongo_collection.create_index('name')

# close connection
mongo_client.close()
