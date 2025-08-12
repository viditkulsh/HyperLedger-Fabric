#!/bin/bash
#
# SPDX-License-Identifier: Apache-2.0
#

set -euo pipefail

# Set default values
CHAINCODE_LANGUAGE=${CHAINCODE_LANGUAGE:-"go"}
CHANNEL_NAME=${CHANNEL_NAME:-"mychannel"}

echo "Starting Test Network Private Data test with chaincode language: $CHAINCODE_LANGUAGE"

# Source utility functions
. scripts/utils.sh

# Bring up the test network
echo "Bringing up test network..."
./network.sh up createChannel -ca -c $CHANNEL_NAME -s couchdb

# Deploy private data chaincode
echo "Deploying private data chaincode..."
if [ "$CHAINCODE_LANGUAGE" = "go" ]; then
    CC_SRC_PATH="../asset-transfer-private-data/chaincode-go"
elif [ "$CHAINCODE_LANGUAGE" = "javascript" ]; then
    CC_SRC_PATH="../asset-transfer-private-data/chaincode-javascript"
elif [ "$CHAINCODE_LANGUAGE" = "typescript" ]; then
    CC_SRC_PATH="../asset-transfer-private-data/chaincode-typescript"
elif [ "$CHAINCODE_LANGUAGE" = "java" ]; then
    CC_SRC_PATH="../asset-transfer-private-data/chaincode-java"
else
    echo "Unsupported chaincode language: $CHAINCODE_LANGUAGE"
    exit 1
fi

# Check if private data chaincode exists, fallback to basic
if [ ! -d "$CC_SRC_PATH" ]; then
    echo "Private data chaincode not found at $CC_SRC_PATH"
    echo "Using basic chaincode for testing..."
    if [ "$CHAINCODE_LANGUAGE" = "go" ]; then
        CC_SRC_PATH="../asset-transfer-basic/chaincode-go"
    elif [ "$CHAINCODE_LANGUAGE" = "javascript" ]; then
        CC_SRC_PATH="../asset-transfer-basic/chaincode-javascript"
    elif [ "$CHAINCODE_LANGUAGE" = "typescript" ]; then
        CC_SRC_PATH="../asset-transfer-basic/chaincode-typescript"
    elif [ "$CHAINCODE_LANGUAGE" = "java" ]; then
        CC_SRC_PATH="../asset-transfer-basic/chaincode-java"
    fi
fi

# Deploy with private data collection config if available
COLLECTIONS_CONFIG=""
if [ -f "$CC_SRC_PATH/../collections_config.json" ]; then
    COLLECTIONS_CONFIG="-cccg $CC_SRC_PATH/../collections_config.json"
fi

./network.sh deployCC -ccn private -ccp $CC_SRC_PATH -ccl $CHAINCODE_LANGUAGE $COLLECTIONS_CONFIG

# Test private data operations
echo "Testing private data operations..."

# Initialize ledger
echo "Initializing ledger..."
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "$PWD/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C $CHANNEL_NAME -n private --peerAddresses localhost:7051 --tlsRootCertFiles "$PWD/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "$PWD/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"InitLedger","Args":[]}'

sleep 3

# Test basic operations
echo "Testing basic operations with private data..."
peer chaincode query -C $CHANNEL_NAME -n private -c '{"function":"GetAllAssets","Args":[]}'

echo "Private data test completed successfully!"

# Clean up
echo "Cleaning up..."
./network.sh down
