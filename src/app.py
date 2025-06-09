from flask import Flask, request, redirect, url_for
import requests
import os
import logging

app = Flask(__name__)

# Add a logger
logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)
logger.addHandler(logging.StreamHandler())

@app.route('/address/exposure/direct',  methods=['GET'])
def address_exposure_direct():
  address  = request.args.get('address', '')
  start_date = request.args.get('start_date', '0001-01-01T00:00:00Z')
  end_date = request.args.get('end_date', '9999-12-31T23:59:59Z')
  flow_type = request.args.get('flow_type', 'both')
  limit = request.args.get('limit', 100)
  offset = request.args.get('offset', 0)

  try:
    data = [
          { "address": "1FGhgLbMzrUV5mgwX9nkEeqHbKbUK29nbQ", "inflows": "0", "outflows": "0.01733177", "total_flows": "0.01733177" },
                { "address": "1Huro4zmi1kD1Ln4krTgJiXMYrAkEd4YSh", "inflows": "0.01733177", "outflows": "0", "total_flows": "0.01733177" },
                    ],
    res = {
      "data": data,
      "success": True
    }
  except:
    res = {
      "data": [],
      "success": False
    }

  return res

# From the docs:
# https://docs.infura.io/infura/networks/ethereum/json-rpc-api/eth_getbalance
'''
curl https://mainnet.infura.io/v3/<YOUR-API-KEY> \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc": "2.0","method": "eth_getBalance", "params": ["address", "latest"], "id": 1}'
'''
@app.route('/address/balance/<address>')
def address_balance(address):
  try:
    # Get the INFURA_API_KEY from environment variables
    infura_api_key = os.environ.get('INFURA_API_KEY')
    if not infura_api_key:
      return {
        "data": {},
        "success": False,
        "error": "INFURA_API_KEY not found"
      }

    # Make the API call to Infura
    url = f"https://mainnet.infura.io/v3/{infura_api_key}"
    headers = {"Content-Type": "application/json"}
    payload = {
      "jsonrpc": "2.0",
      "method": "eth_getBalance",
      "params": [address, "latest"],
      "id": 1
    }

    response = requests.post(url, json=payload, headers=headers)
    response_data = response.json()

    if response.status_code == 200 and 'result' in response_data:
      # Convert hex balance to decimal (Wei)
      balance_wei = int(response_data['result'], 16)
      # Convert Wei to ETH (1 ETH = 10^18 Wei)
      balance_eth = balance_wei / 10**18

      res = {
        "balance": balance_eth
      }
    else:
      res = {
        "data": {},
        "success": False,
        "error": response_data.get('error', 'Unknown error')
      }

  except Exception as e:
    res = {
      "data": {},
      "success": False,
      "error": str(e)
    }

  return res

@app.route('/eth_gettransactionbyhash/<hash>')
def eth_gettransactionbyhash(hash):
  try:
    # Get the INFURA_API_KEY from environment variables
    infura_api_key = os.environ.get('INFURA_API_KEY')
    if not infura_api_key:
      return {
        "data": {},
        "success": False,
        "error": "INFURA_API_KEY not found"
      }

    # Make the API call to Infura
    # https://docs.metamask.io/services/reference/ethereum/json-rpc-methods/eth_gettransactionbyhash/
    url = f"https://mainnet.infura.io/v3/{infura_api_key}"
    headers = {"Content-Type": "application/json"}
    payload = {
      "jsonrpc": "2.0",
      "method": "eth_getTransactionByHash",
      "params": [hash],
      "id": 1
    }

    response = requests.post(url, json=payload, headers=headers)
    response_data = response.json()

    if response.status_code == 200 and 'result' in response_data:
      res = {
        "data": response_data['result']
      }
    else:
      res = {
        "data": {},
        "success": False,
        "error": response_data.get('error', 'Unknown error')
      }
  except Exception as e:
    res = {
      "data": {},
      "success": False,
      "error": str(e)
    }

  return res

@app.route('/')
def index():
  # Redirect to /address/exposure/direct
  return redirect(url_for('address_exposure_direct'))




# vim: ts=2 sts=2 sw=2 et
