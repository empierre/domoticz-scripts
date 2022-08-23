# Authenticate to the Airthings API and get the latest data from a particular device.
# Requires an API client created in the web gui: https://dashboard.airthings.com/integrations/api-integration
# Update script with client id and device id which can be retrieved from the devices page: https://dashboard.airthings.com/devices
# export the api secret to an environment variable called secret (Bash export secret="secret-key"
# Requires the requests package (pip install requests into the virutal environment of container).
# Python version 3.6 or above needed for f strings.
# Matthew Davis July 2022
# empierre August 2022
# to install: pip install -r requirements.txt
import os
import logging
import pprint
import requests
from requests import HTTPError


client_id = "23255cb2-5692-4c0c-ada3-4399ece27576"
device_id = "2989005181"
client_secret = "9f73a31c-3116-4706-8fb9-0b971a948980"
authorisation_url = "https://accounts-api.airthings.com/v1/token"
device_url = f"https://ext-api.airthings.com/v1/devices/{device_id}/latest-samples"
token_req_payload = {
    "grant_type": "client_credentials",
    "scope": "read:device:current_values",
}


# Request Access Token from auth server
try:
    token_response = requests.post(
        authorisation_url,
        data=token_req_payload,
        allow_redirects=False,
        auth=(client_id, client_secret),
    )
except HTTPError as e:
    logging.error(e)

token = token_response.json()["access_token"]
# end auth token

# Get the latest data for the device from the Airthings API.
try:
    api_headers = {"Authorization": f"Bearer {token}"}
    response = requests.get(url=device_url, headers=api_headers)
except HTTPError as e:
    logging.error(e)

print(pprint.pprint(response.json()))
#print(f"co2: {response.json()['data']['co2']}")
print(f"rad: {response.json()['data']['radonShortTermAvg']}")
