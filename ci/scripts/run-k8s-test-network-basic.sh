#!/bin/bash
#
# SPDX-License-Identifier: Apache-2.0
#

set -euo pipefail

# Set default values
CLIENT_LANGUAGE=${CLIENT_LANGUAGE:-"typescript"}
CHAINCODE_LANGUAGE=${CHAINCODE_LANGUAGE:-"java"}
CHAINCODE_NAME=${CHAINCODE_NAME:-"basic"}
CHAINCODE_BUILDER=${CHAINCODE_BUILDER:-"ccaas"}
FABRIC_VERSION=${FABRIC_VERSION:-"2.5.13"}
ORDERER_TYPE=${ORDERER_TYPE:-"etcdraft"}

# Namespace variables
ORG0_NS=${ORG0_NS:-"org0"}
ORG1_NS=${ORG1_NS:-"org1"}
ORG2_NS=${ORG2_NS:-"org2"}

echo "Starting Kubernetes Test Network test..."
echo "Client Language: $CLIENT_LANGUAGE"
echo "Chaincode Language: $CHAINCODE_LANGUAGE"
echo "Chaincode Name: $CHAINCODE_NAME"
echo "Chaincode Builder: $CHAINCODE_BUILDER"
echo "Fabric Version: $FABRIC_VERSION"
echo "Orderer Type: $ORDERER_TYPE"

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "kubectl is not available. Installing kind and kubectl..."
    
    # Install kubectl
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
    
    # Install kind
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/
fi

# Create kind cluster if it doesn't exist
if ! kind get clusters | grep -q "kind"; then
    echo "Creating kind cluster..."
    kind create cluster
fi

# Check if the test-network-k8s directory exists
if [ ! -d "kustomize" ]; then
    echo "Error: This script should be run from the test-network-k8s directory"
    echo "Current directory: $(pwd)"
    echo "Available directories:"
    ls -la
    exit 1
fi

# Install the network
echo "Installing Kubernetes test network..."
export ORG0_NS=$ORG0_NS
export ORG1_NS=$ORG1_NS  
export ORG2_NS=$ORG2_NS
export FABRIC_VERSION=$FABRIC_VERSION

./network kind

# Deploy chaincode
echo "Deploying chaincode..."
if [ "$CHAINCODE_BUILDER" = "k8s" ]; then
    ./network cc deploy $CHAINCODE_NAME ../asset-transfer-basic/chaincode-$CHAINCODE_LANGUAGE $CHAINCODE_LANGUAGE
else
    # CCAAS deployment
    if [ "$CHAINCODE_LANGUAGE" = "external" ]; then
        ./network ccaas deploy $CHAINCODE_NAME ../asset-transfer-basic/chaincode-external
    else
        ./network ccaas deploy $CHAINCODE_NAME ../asset-transfer-basic/chaincode-$CHAINCODE_LANGUAGE $CHAINCODE_LANGUAGE
    fi
fi

# Run application tests
echo "Running application tests..."
if [ -d "../asset-transfer-basic/application-$CLIENT_LANGUAGE" ]; then
    cd ../asset-transfer-basic/application-$CLIENT_LANGUAGE
    
    if [ "$CLIENT_LANGUAGE" = "typescript" ] || [ "$CLIENT_LANGUAGE" = "javascript" ]; then
        npm install
        npm start
    elif [ "$CLIENT_LANGUAGE" = "java" ]; then
        ./gradlew run
    elif [ "$CLIENT_LANGUAGE" = "go" ]; then
        go run .
    fi
    
    cd - > /dev/null
else
    echo "Warning: Application directory not found for $CLIENT_LANGUAGE"
fi

echo "Kubernetes Test Network test completed successfully!"

# Clean up
echo "Cleaning up..."
./network down
kind delete cluster
