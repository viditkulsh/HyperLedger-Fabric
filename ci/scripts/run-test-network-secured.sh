#!/bin/bash
#
# SPDX-License-Identifier: Apache-2.0
#

set -euo pipefail

# Set default values
CHAINCODE_LANGUAGE=${CHAINCODE_LANGUAGE:-"go"}
CHANNEL_NAME=${CHANNEL_NAME:-"mychannel"}

echo "Starting Test Network Secured test with chaincode language: $CHAINCODE_LANGUAGE"

# Source utility functions
. scripts/utils.sh

# Bring up the test network with security enhancements
echo "Bringing up test network with security configurations..."
./network.sh up createChannel -ca -c $CHANNEL_NAME -s couchdb

# Deploy secured chaincode
echo "Deploying secured chaincode..."
if [ "$CHAINCODE_LANGUAGE" = "go" ]; then
    CC_SRC_PATH="../asset-transfer-secured-agreement/chaincode-go"
elif [ "$CHAINCODE_LANGUAGE" = "javascript" ]; then
    CC_SRC_PATH="../asset-transfer-secured-agreement/chaincode-javascript"
elif [ "$CHAINCODE_LANGUAGE" = "typescript" ]; then
    CC_SRC_PATH="../asset-transfer-secured-agreement/chaincode-typescript"
elif [ "$CHAINCODE_LANGUAGE" = "java" ]; then
    CC_SRC_PATH="../asset-transfer-secured-agreement/chaincode-java"
else
    echo "Unsupported chaincode language: $CHAINCODE_LANGUAGE"
    exit 1
fi

# Check if secured chaincode exists, fallback to basic
if [ ! -d "$CC_SRC_PATH" ]; then
    echo "Secured chaincode not found at $CC_SRC_PATH"
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

./network.sh deployCC -ccn secured -ccp $CC_SRC_PATH -ccl $CHAINCODE_LANGUAGE

# Test secured operations
echo "Testing secured operations..."

# Initialize ledger
echo "Initializing ledger with security..."
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "$PWD/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C $CHANNEL_NAME -n secured --peerAddresses localhost:7051 --tlsRootCertFiles "$PWD/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "$PWD/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"InitLedger","Args":[]}'

sleep 3

# Test secured asset creation
echo "Testing secured asset creation..."
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "$PWD/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C $CHANNEL_NAME -n secured --peerAddresses localhost:7051 --tlsRootCertFiles "$PWD/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "$PWD/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"CreateAsset","Args":["secured-asset","green","8","SecureTest","800"]}'

sleep 3

# Query assets to verify security worked
echo "Verifying secured assets..."
peer chaincode query -C $CHANNEL_NAME -n secured -c '{"function":"GetAllAssets","Args":[]}'

echo "Secured test completed successfully!"

# Clean up
echo "Cleaning up..."
./network.sh down
