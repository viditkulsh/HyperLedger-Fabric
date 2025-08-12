#!/bin/bash
#
# SPDX-License-Identifier: Apache-2.0
#

set -euo pipefail

# Set default values
CHAINCODE_LANGUAGE=${CHAINCODE_LANGUAGE:-"go"}
CHANNEL_NAME=${CHANNEL_NAME:-"mychannel"}
CONSENSUS_TYPE=${CONSENSUS_TYPE:-"cryptogen"}

echo "Starting Test Network BFT Orderer test with chaincode language: $CHAINCODE_LANGUAGE and consensus type: $CONSENSUS_TYPE"

# Check if we're on main branch (BFT requires Fabric 3.0+)
if [ "${FABRIC_VERSION:-}" != "3.1" ]; then
    echo "BFT Orderer requires Fabric 3.0 or later. Setting FABRIC_VERSION to 3.1"
    export FABRIC_VERSION=3.1
fi

# Source utility functions
. scripts/utils.sh

# Bring up the test network with BFT ordering
echo "Bringing up test network with BFT ordering..."
if [ "$CONSENSUS_TYPE" = "ca" ]; then
    ./network.sh up createChannel -bft -ca -c $CHANNEL_NAME -s couchdb
else
    ./network.sh up createChannel -bft -c $CHANNEL_NAME -s couchdb
fi

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

# Test BFT ordering service
echo "Testing BFT ordering service..."

# Initialize the ledger
echo "Initializing ledger with BFT..."
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "$PWD/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C $CHANNEL_NAME -n basic --peerAddresses localhost:7051 --tlsRootCertFiles "$PWD/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "$PWD/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"InitLedger","Args":[]}'

sleep 3

# Test multiple transactions to verify BFT consensus
echo "Testing multiple transactions with BFT..."
for i in {1..5}; do
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "$PWD/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C $CHANNEL_NAME -n basic --peerAddresses localhost:7051 --tlsRootCertFiles "$PWD/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "$PWD/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c "{\"function\":\"CreateAsset\",\"Args\":[\"bft-asset$i\",\"purple\",\"$i\",\"BFTTest$i\",\"$(($i * 100))\"]}"
    sleep 1
done

sleep 3

# Query assets to verify BFT worked
echo "Verifying BFT consensus worked..."
peer chaincode query -C $CHANNEL_NAME -n basic -c '{"function":"GetAllAssets","Args":[]}'

echo "BFT Orderer test completed successfully!"

# Clean up
echo "Cleaning up..."
./network.sh down
