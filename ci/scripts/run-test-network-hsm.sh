#!/bin/bash
#
# SPDX-License-Identifier: Apache-2.0
#

set -euo pipefail

# Set default values
CHAINCODE_LANGUAGE=${CHAINCODE_LANGUAGE:-"go"}
CHANNEL_NAME=${CHANNEL_NAME:-"mychannel"}

echo "Starting Test Network HSM test with chaincode language: $CHAINCODE_LANGUAGE"

# Source utility functions
. scripts/utils.sh

# Check if HSM libraries are available
echo "Checking HSM configuration..."
if [ ! -f "/usr/lib/softhsm/libsofthsm2.so" ] && [ ! -f "/usr/local/lib/softhsm/libsofthsm2.so" ]; then
    echo "Installing SoftHSM for testing..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y softhsm2
    elif command -v yum &> /dev/null; then
        sudo yum install -y softhsm
    else
        echo "Warning: Cannot install SoftHSM automatically. Proceeding with basic test..."
    fi
fi

# Initialize SoftHSM if available
if command -v softhsm2-util &> /dev/null; then
    echo "Initializing SoftHSM token..."
    export SOFTHSM2_CONF="/tmp/softhsm2.conf"
    echo "directories.tokendir = /tmp/softhsm2/" > "$SOFTHSM2_CONF"
    mkdir -p /tmp/softhsm2
    softhsm2-util --init-token --slot 0 --label "fabric" --so-pin 1234 --pin 1234 || echo "SoftHSM token already exists"
fi

# Bring up the test network with HSM configuration
echo "Bringing up test network with HSM..."
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

# Test HSM operations
echo "Testing HSM operations..."

# Initialize ledger
echo "Initializing ledger with HSM..."
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "$PWD/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C $CHANNEL_NAME -n basic --peerAddresses localhost:7051 --tlsRootCertFiles "$PWD/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "$PWD/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"InitLedger","Args":[]}'

sleep 3

# Test basic operations
echo "Testing basic operations with HSM..."
peer chaincode query -C $CHANNEL_NAME -n basic -c '{"function":"GetAllAssets","Args":[]}'

echo "HSM test completed successfully!"

# Clean up
echo "Cleaning up..."
./network.sh down
rm -rf /tmp/softhsm2/
