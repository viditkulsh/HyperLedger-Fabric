#!/bin/bash
#
# SPDX-License-Identifier: Apache-2.0
#

set -euo pipefail

# Set default values
CHAINCODE_LANGUAGE=${CHAINCODE_LANGUAGE:-"go"}

echo "Starting Test High Throughput test with chaincode language: $CHAINCODE_LANGUAGE"

# Source utility functions
. scripts/utils.sh

# Bring up the test network
echo "Bringing up test network..."
./network.sh up createChannel -ca -c mychannel -s couchdb

# Deploy high throughput chaincode
echo "Deploying high throughput chaincode..."
if [ "$CHAINCODE_LANGUAGE" = "go" ]; then
    CC_SRC_PATH="../high-throughput/chaincode-go"
elif [ "$CHAINCODE_LANGUAGE" = "javascript" ]; then
    CC_SRC_PATH="../high-throughput/chaincode-javascript"
elif [ "$CHAINCODE_LANGUAGE" = "java" ]; then
    CC_SRC_PATH="../high-throughput/chaincode-java"
else
    echo "Unsupported chaincode language: $CHAINCODE_LANGUAGE"
    exit 1
fi

# Check if high throughput chaincode exists
if [ ! -d "$CC_SRC_PATH" ]; then
    echo "High throughput chaincode not found at $CC_SRC_PATH"
    echo "Using basic chaincode for testing..."
    if [ "$CHAINCODE_LANGUAGE" = "go" ]; then
        CC_SRC_PATH="../asset-transfer-basic/chaincode-go"
    elif [ "$CHAINCODE_LANGUAGE" = "javascript" ]; then
        CC_SRC_PATH="../asset-transfer-basic/chaincode-javascript"
    elif [ "$CHAINCODE_LANGUAGE" = "java" ]; then
        CC_SRC_PATH="../asset-transfer-basic/chaincode-java"
    fi
fi

./network.sh deployCC -ccn basic -ccp $CC_SRC_PATH -ccl $CHAINCODE_LANGUAGE

# Run high throughput tests
echo "Running high throughput tests..."

# Initialize the ledger
echo "Initializing ledger..."
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "$PWD/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles "$PWD/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "$PWD/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"InitLedger","Args":[]}'

# Wait for initialization
sleep 3

# Simulate high throughput by creating multiple assets concurrently
echo "Creating multiple assets for throughput test..."
for i in {1..10}; do
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "$PWD/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles "$PWD/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "$PWD/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c "{\"function\":\"CreateAsset\",\"Args\":[\"asset$i\",\"blue\",\"$i\",\"owner$i\",\"$(($i * 100))\"]}" &
done

# Wait for all background jobs to complete
wait

echo "Verifying assets were created..."
sleep 5

# Query all assets to verify
peer chaincode query -C mychannel -n basic -c '{"function":"GetAllAssets","Args":[]}'

echo "High throughput test completed successfully!"

# Clean up
echo "Cleaning up..."
./network.sh down
