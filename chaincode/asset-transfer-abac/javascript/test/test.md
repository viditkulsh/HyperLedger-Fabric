Step 1: Test as Admin
Switch to Admin
bash
Copy code
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/../../../organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/../../../organizations/peerOrganizations/org1.example.com/users/adminUser@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051
Create a new asset
bash
Copy code
peer chaincode invoke \
  -o localhost:7050 \
  --ordererTLSHostnameOverride orderer.example.com \
  --tls \
  --cafile ${PWD}/../../../organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem \
  -C mychannel \
  -n asset-transfer-abac \
  --peerAddresses localhost:7051 \
  --tlsRootCertFiles ${PWD}/../../../organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt \
  -c '{"function":"CreateAsset","Args":["asset100","regularUser","500"]}'
✅ Expected → Asset created successfully.

🔹 Step 2: Test as Auditor
Switch to Auditor
bash
Copy code
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/../../../organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/../../../organizations/peerOrganizations/org1.example.com/users/auditorUser@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051
Get all assets
bash
Copy code
peer chaincode query \
  -C mychannel \
  -n asset-transfer-abac \
  -c '{"function":"GetAllAssets","Args":[]}'
✅ Expected → A list of all assets, including asset100.

🔹 Step 3: Test as Regular User
Switch to Regular User
bash
Copy code
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/../../../organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/../../../organizations/peerOrganizations/org1.example.com/users/regularUser@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051
Try reading asset owned by Regular User
bash
Copy code
peer chaincode query \
  -C mychannel \
  -n asset-transfer-abac \
  -c '{"function":"ReadAsset","Args":["asset100"]}'
✅ Expected → Returns details of asset100.

Try reading asset owned by someone else
bash
Copy code
peer chaincode query \
  -C mychannel \
  -n asset-transfer-abac \
  -c '{"function":"ReadAsset","Args":["asset1"]}'
❌ Expected → Error: You can only view assets you own

Try creating a new asset
bash
Copy code
peer chaincode invoke \
  -o localhost:7050 \
  --ordererTLSHostnameOverride orderer.example.com \
  --tls \
  --cafile ${PWD}/../../../organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem \
  -C mychannel \
  -n asset-transfer-abac \
  --peerAddresses localhost:7051 \
  --tlsRootCertFiles ${PWD}/../../../organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt \
  -c '{"function":"CreateAsset","Args":["asset200","regularUser","600"]}'
❌ Expected → Error: Only Admin can create assets