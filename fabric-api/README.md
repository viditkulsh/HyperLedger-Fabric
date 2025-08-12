# Fabric API Setup Guide

## Steps to fix the "Identity for user undefined" error:

### 1. Install Dependencies
```bash
cd fabric-samples/fabric-api
npm install
```

### 2. Enroll Users into Wallet
```bash
node enrollUsers.js
```

This will create wallet identities for:
- `adminUser` (admin role)
- `auditorUser` (auditor role) 
- `regularUser` (user role)

### 3. Start the Server
```bash
node server.js
```

### 4. Test the API
```bash
node testAPI.js
```

## API Endpoints

### Create Asset
```bash
curl -X POST http://localhost:3000/assets \
  -H "Content-Type: application/json" \
  -d '{
    "assetID": "asset001",
    "owner": "user123",
    "value": "1000",
    "userId": "adminUser"
  }'
```

### Read Asset
```bash
curl http://localhost:3000/assets/asset001?userId=adminUser
```

### Update Asset
```bash
curl -X PUT http://localhost:3000/assets/asset001 \
  -H "Content-Type: application/json" \
  -d '{
    "newValue": "1500",
    "userId": "adminUser"
  }'
```

### Delete Asset
```bash
curl -X DELETE http://localhost:3000/assets/asset001?userId=adminUser
```

### Get All Assets (Auditor only)
```bash
curl http://localhost:3000/assets?userId=auditorUser
```

## User Roles & Permissions

- **Admin (`adminUser`)**: Can create assets for anyone, read any asset
- **Auditor (`auditorUser`)**: Can read any asset, view all assets
- **Regular User (`regularUser`)**: Can create assets (only for themselves), read own assets
- **Asset Owners**: Can update/delete their own assets

## Troubleshooting

1. **"Identity for user undefined"**: Run `node enrollUsers.js` first
2. **"Couldn't connect to server"**: Make sure Fabric network is running and server started
3. **"Asset already exists"**: Use different assetID or delete existing asset first
