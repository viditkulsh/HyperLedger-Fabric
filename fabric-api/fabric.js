const { Gateway, Wallets } = require('fabric-network');
const path = require('path');
const fs = require('fs');

async function getContract(userId) {
    const ccpPath = path.resolve(
        __dirname,
        '../test-network/organizations/peerOrganizations/org1.example.com/connection-org1.json'
    );
    const ccp = JSON.parse(fs.readFileSync(ccpPath, 'utf8'));

    const walletPath = path.join(process.cwd(), 'wallet');
    const wallet = await Wallets.newFileSystemWallet(walletPath);

    const identity = await wallet.get(userId);
    if (!identity) {
        throw new Error(`Identity for user ${userId} not found in wallet`);
    }

    const gateway = new Gateway();
    await gateway.connect(ccp, {
        wallet,
        identity: userId,
        discovery: { enabled: true, asLocalhost: true }
    });

    const network = await gateway.getNetwork('mychannel');
    return network.getContract('asset-transfer-abac');
}

module.exports = { getContract };
