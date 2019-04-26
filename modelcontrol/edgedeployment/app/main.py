# Licensed under the MIT license. See LICENSE file in the project root for
# full license information.

import json
import os
import io
import subprocess
from subprocess import PIPE
import sys
import fileinput
from os import listdir
from os.path import isfile, join
import pprint

# Imports for the REST API
from flask import Flask, request

app = Flask(__name__)

# 512KB Max request limit
app.config['MAX_CONTENT_LENGTH'] = 0.5 * 1024 * 1024 

# Default route just shows simple text
@app.route('/')
def index():
    return 'Edge Deployment Control API host'

# TODO
@app.route('/control', methods=['POST'])
def predict_image_handler():
    if not request.headers.get('AuthKey') == AUTH_KEY:
        return 'AuthKey is missing', 401

    if not request.content_type == 'application/json':
        return 'Content-type must be application/json', 500

    try:
        payload = request.get_json()

        modelName = None
        if ('model' in payload):
            modelName = payload['model']
        else:
            print('EXCEPTION: no modelname definded')
            return 'No modelname definded', 500

        deviceId = None
        if ('deviceId' in payload):
            deviceId = payload['deviceId']
        else:
            print('EXCEPTION: no deviceId definded')
            return 'No deviceId definded', 500

        hubName = None
        if ('hubName' in payload):
            hubName = payload['hubName']
        else:
            print('EXCEPTION: no hubName definded')
            return 'No hubName definded', 500
        
        # Try Login to Azure
        try:
            subprocess.run(["az", "login", "--identity"])
        except Exception as e:
            print('error while logging in to azure using managed identity:', str(e))

        # Execute set-modules command
        contentfile = DEPLOYMENT_PATH + 'deployment.' + modelName + '.pi.json'
        result = subprocess.run(["az", "iot", "edge", "set-modules", "--device-id", deviceId, "--hub-name", hubName, "--content", contentfile], stdout=PIPE, stderr=PIPE)
        pp = pprint.PrettyPrinter(indent=4)
        pp.pprint(result)

        if len(result.stderr) > 0:
            return result.stderr, 500
        else:   
            return result.stdout, 200

    except Exception as e:
        print('EXCEPTION:', str(e))
        return str(e), 500


if __name__ == '__main__':
    #ENV Variables
    try:
        CONTAINER_REGISTRY_ADDRESS  = os.environ['CONTAINER_REGISTRY_ADDRESS']
        CONTAINER_REGISTRY_USERNAME = os.environ['CONTAINER_REGISTRY_USERNAME']
        CONTAINER_REGISTRY_PASSWORD = os.environ['CONTAINER_REGISTRY_PASSWORD']
        AUTH_KEY = os.environ['AUTH_KEY']
        DEPLOYMENT_PATH = 'deployment/'
    except ValueError as error:
        print ( error )
        sys.exit(1)

    # Modify deployment files
    onlyfiles = [f for f in listdir(DEPLOYMENT_PATH) if isfile(join(DEPLOYMENT_PATH, f))]
    for filename in onlyfiles:
        filename = DEPLOYMENT_PATH + filename
        with open(filename) as f:
            newText=f.read().replace('${CONTAINER_REGISTRY_ADDRESS}', CONTAINER_REGISTRY_ADDRESS)
            newText=newText.replace('${CONTAINER_REGISTRY_USERNAME}', CONTAINER_REGISTRY_USERNAME)
            newText=newText.replace('${CONTAINER_REGISTRY_PASSWORD}', CONTAINER_REGISTRY_PASSWORD)
        
        with open(filename, "w") as f:
            f.write(newText)

    # Run the server
    app.run(host='0.0.0.0', port=80)
    