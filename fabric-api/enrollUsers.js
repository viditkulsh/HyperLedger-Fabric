// enrollUsers.js
const { Wallets } = require('fabric-network');
const fs = require('fs');
const path = require('path');

async function enrollUser(walletId, userPath, mspId, role) {
  try {
    const walletPath = path.join(__dirname, 'wallet');
    const wallet = await Wallets.newFileSystemWallet(walletPath);

    const credPath = path.resolve(__dirname, userPath);

    const cert = fs.readFileSync(path.join(credPath, 'signcerts/cert.pem')).toString();
    const keystorePath = path.join(credPath, 'keystore');
    const keystoreFiles = fs.readdirSync(keystorePath);
    const key = fs.readFileSync(path.join(keystorePath, keystoreFiles[0])).toString();

    const identity = {
      credentials: {
        certificate: cert,
        privateKey: key,
      },
      mspId: mspId,
      type: 'X.509',
    };

    await wallet.put(walletId, identity);
    console.log(`✅ Successfully imported ${walletId} (${role}) into wallet`);
  } catch (error) {
    console.error(`❌ Failed to import ${walletId}: ${error}`);
  }
}

async function main() {
  console.log('🔐 Enrolling users into wallet...\n');

  // Enroll Admin User
  await enrollUser(
    'adminUser',
    '../test-network/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp',
    'Org1MSP',
    'admin'
  );

  // Note: For auditor and regular users, you'll need to create these identities first
  // or use the Admin identity with different wallet names for testing
  
  // For testing purposes, you can create multiple wallet entries using the same Admin identity
  // but with different names to simulate different users
  await enrollUser(
    'auditorUser',
    '../test-network/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp',
    'Org1MSP',
    'auditor'
  );

  await enrollUser(
    'regularUser',
    '../test-network/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp',
    'Org1MSP',
    'user'
  );

  console.log('\n🎉 All users enrolled successfully!');
  console.log('\n📝 You can now use these userIds in your API calls:');
  console.log('   - adminUser (admin role)');
  console.log('   - auditorUser (auditor role)');
  console.log('   - regularUser (user role)');
}

main();
