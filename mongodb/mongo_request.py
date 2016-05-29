#!/usr/bin/env python
#
# set up local server to handle requests to mongoDB with anscombe's quartet
#
# to get third data set, go to http://localhost:8080/anscombe/III

import bottle, pymongo

client = pymongo.MongoClient()
dbcoll = client.anscombe.quartet

@bottle.route('/anscombe/<name>')
def grab_record(name):
    bottle.response.headers['Access-Control-Allow-Origin'] = '*' # <- needed to allow request from D3
    return dbcoll.find_one({'name':name}, {'_id':False})

bottle.run(host='localhost', port=8080, debug=True)
