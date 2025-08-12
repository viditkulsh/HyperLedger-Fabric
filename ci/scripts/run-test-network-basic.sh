#!/bin/bash
#
# SPDX-License-Identifier: Apache-2.0
#

set -euo pipefail

# Set default values
CHAINCODE_LANGUAGE=${CHAINCODE_LANGUAGE:-"go"}
CHANNEL_NAME=${CHANNEL_NAME:-"mychannel"}
DELAY=${DELAY:-"3"}
MAX_RETRY=${MAX_RETRY:-"5"}
VERBOSE=${VERBOSE:-"false"}

echo "Starting Test Network Basic test with chaincode language: $CHAINCODE_LANGUAGE"

# Source utility functions
. scripts/utils.sh

# Bring up the test network
echo "Bringing up test network..."
./network.sh up createChannel -ca -c $CHANNEL_NAME -s couchdb

# Deploy chaincode
echo "Deploying chaincode..."
if [ "$CHAINCODE_LANGUAGE" = "go" ]; then
    CC_SRC_PATH="../asset-transfer-basic/chaincode-go"
elif [ "$CHAINCODE_LANGUAGE" = "javascript" ]; then
    CC_SRC_PATH="../asset-transfer-basic/chaincode-javascript"
elif [ "$CHAINCODE_LANGUAGE" = "typescript" ]; then
    CC_SRC_PATH="../asset-transfer-basic/chaincode-typescript"
elif [ "$CHAINCODE_LANGUAGE" = "java" ]; then
    CC_SRC_PATH="../asset-transfer-basic/chaincode-java"
else
    echo "Unsupported chaincode language: $CHAINCODE_LANGUAGE"
    exit 1
fi

./network.sh deployCC -ccn basic -ccp $CC_SRC_PATH -ccl $CHAINCODE_LANGUAGE

# Run basic chaincode operations
echo "Testing basic chaincode operations..."

# Initialize the ledger
echo "Initializing ledger..."
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "$PWD/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C $CHANNEL_NAME -n basic --peerAddresses localhost:7051 --tlsRootCertFiles "$PWD/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "$PWD/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"InitLedger","Args":[]}'

# Wait for the transaction to be committed
sleep $DELAY

# Query all assets
echo "Querying all assets..."
peer chaincode query -C $CHANNEL_NAME -n basic -c '{"function":"GetAllAssets","Args":[]}'

# Create a new asset
echo "Creating a new asset..."
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "$PWD/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C $CHANNEL_NAME -n basic --peerAddresses localhost:7051 --tlsRootCertFiles "$PWD/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "$PWD/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"CreateAsset","Args":["asset007","blue","5","Tom","1300"]}'

# Wait for the transaction to be committed
sleep $DELAY

# Query the new asset
echo "Querying the new asset..."
peer chaincode query -C $CHANNEL_NAME -n basic -c '{"function":"ReadAsset","Args":["asset007"]}'

echo "Test Network Basic test completed successfully!"

# Clean up
echo "Cleaning up..."
./network.sh down
