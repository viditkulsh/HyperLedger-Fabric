# Hyperledger Fabric Project

A complete Hyperledger Fabric blockchain network implementation with REST API integration, demonstrating enterprise blockchain development skills.

## 🚀 Project Overview

This project showcases a full-stack blockchain application built on Hyperledger Fabric, including:

- **Custom REST API** (`fabric-api/`) - Node.js backend with Fabric SDK integration
- **Network Configuration** (`test-network/`) - Custom peer, orderer, and CA configurations  
- **Smart Contracts** (`chaincode/`) - Custom chaincode implementation
- **Network Automation** - Scripts for deployment and management

## 🏗️ Architecture

```
hyperledger-fabric-project/
│
├── fabric-api/                 # Node.js REST API
│   ├── server.js              # Express server with Fabric SDK
│   ├── enrollAdmin.js         # Admin enrollment
│   ├── enrollUsers.js         # User registration
│   ├── fabric.js              # Fabric SDK utilities
│   └── package.json           # Dependencies
│
├── test-network/              # Blockchain network config
│   ├── compose/               # Docker compose files
│   ├── configtx/              # Channel configuration
│   ├── scripts/               # Network automation scripts
│   └── README.md              # Network setup guide
│
├── chaincode/                 # Smart contracts
│   └── asset-transfer-abac/   # Custom chaincode
│
└── README.md                  # This file
```

## 🛠️ Technologies Used

- **Hyperledger Fabric** - Enterprise blockchain platform
- **Node.js** - Backend API development
- **Docker** - Containerization
- **Express.js** - REST API framework
- **Fabric SDK for Node.js** - Blockchain interaction
- **JavaScript** - Smart contract development

## ⚡ Quick Start

### Prerequisites
- Docker & Docker Compose
- Node.js 14+ and npm
- Git

### 1. Clone & Setup
```bash
git clone <your-repo-url>
cd hyperledger-fabric-project
```

### 2. Start the Network
```bash
cd test-network
./network.sh up createChannel -ca
./network.sh deployCC -ccn basic -ccp ../chaincode/asset-transfer-basic -ccl javascript
```

### 3. Setup API
```bash
cd ../fabric-api
npm install
node enrollAdmin.js
node enrollUsers.js
```

### 4. Start the API Server
```bash
node server.js
```

The API will be available at `http://localhost:3000`

## 🔗 API Endpoints

- `GET /api/query` - Query blockchain state
- `POST /api/invoke` - Submit transactions
- `GET /api/assets` - List all assets
- `POST /api/assets` - Create new asset
- `PUT /api/assets/:id` - Update asset
- `DELETE /api/assets/:id` - Delete asset

## 📋 Key Features Demonstrated

### Blockchain Development
- ✅ Custom network configuration
- ✅ Multi-organization setup
- ✅ Certificate Authority integration
- ✅ Channel and chaincode deployment

### Backend Development  
- ✅ REST API with Express.js
- ✅ Fabric SDK integration
- ✅ User enrollment and authentication
- ✅ Transaction submission and querying
- ✅ Error handling and validation

### DevOps Skills
- ✅ Docker containerization
- ✅ Network automation scripts
- ✅ Environment configuration
- ✅ CI/CD ready structure

## 🎯 What Makes This Project Special

1. **Production-Ready Structure** - Organized codebase following best practices
2. **Complete Integration** - Full stack from blockchain to REST API
3. **Custom Configuration** - Modified network settings and chaincode
4. **Automation Scripts** - One-command network deployment
5. **Documentation** - Clear setup and usage instructions

## 🔧 Development

### Network Management
```bash
# Start network
./test-network/network.sh up createChannel -ca

# Deploy chaincode
./test-network/network.sh deployCC -ccn mycc -ccp ./chaincode/mycc

# Stop network
./test-network/network.sh down
```

### API Development
```bash
cd fabric-api
npm run dev  # Start with nodemon for development
npm test     # Run API tests
```

## 📖 Learning Resources

- [Hyperledger Fabric Documentation](https://hyperledger-fabric.readthedocs.io/)
- [Fabric SDK for Node.js](https://fabric-sdk-node.github.io/)
- [Chaincode Development](https://hyperledger-fabric.readthedocs.io/en/release-2.5/chaincode.html)

## 🤝 Contributing

This is a showcase project demonstrating blockchain development skills. Feel free to explore the code and suggest improvements!

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Note**: This project demonstrates enterprise blockchain development capabilities using Hyperledger Fabric. It showcases skills in distributed systems, cryptography, REST API development, and containerization.
