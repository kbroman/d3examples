#!/usr/bin/env python
#
# set up local server to handle requests to mongoDB with anscombe's quartet
#
# to get third data set, go to http://localhost:8080/anscombe/III

import pymongo
from flask import Flask, jsonify

client = pymongo.MongoClient()
dbcoll = client.anscombe.quartet

app = Flask(__name__)

@app.route('/anscombe/<name>', methods=['GET'])
def grab_record(name):
    response = jsonify( dbcoll.find_one({'name':name}, {'_id':False}) )
    response.headers.add('Access-Control-Allow-Origin', '*')
    return response

if __name__ == '__main__':
    app.run(host='localhost', port=8080, debug=True)
