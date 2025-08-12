// enrollAdmin.js
const { Wallets } = require('fabric-network');
const fs = require('fs');
const path = require('path');

async function main() {
  try {
    const walletPath = path.join(__dirname, 'wallet');
    const wallet = await Wallets.newFileSystemWallet(walletPath);

    const credPath = path.resolve(
      __dirname,
      '../test-network/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp'
    );

    const cert = fs.readFileSync(path.join(credPath, 'signcerts/cert.pem')).toString();
    const key = fs.readFileSync(path.join(credPath, 'keystore', fs.readdirSync(path.join(credPath, 'keystore'))[0])).toString();

    const identity = {
      credentials: {
        certificate: cert,
        privateKey: key,
      },
      mspId: 'Org1MSP',
      type: 'X.509',
    };

    await wallet.put('adminUser', identity);
    console.log('✅ Successfully imported adminUser into wallet');
  } catch (error) {
    console.error(`❌ Failed to import identity: ${error}`);
  }
}

main();
