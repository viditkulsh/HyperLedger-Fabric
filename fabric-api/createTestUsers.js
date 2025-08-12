const { Wallets } = require('fabric-network');
const path = require('path');

async function createUsersFromAdmin() {
    try {
        const walletPath = path.join(process.cwd(), 'wallet');
        const wallet = await Wallets.newFileSystemWallet(walletPath);

        // Get the existing admin identity
        const adminIdentity = await wallet.get('admin');
        if (!adminIdentity) {
            console.error('❌ Admin identity not found. Run enrollAdminWithRole.js first.');
            return;
        }

        // Create user identities based on admin but with different names
        const users = [
            { id: 'adminUser', role: 'admin' },
            { id: 'auditorUser', role: 'auditor' },
            { id: 'regularUser', role: 'user' }
        ];

        for (const user of users) {
            const userExists = await wallet.get(user.id);
            if (userExists) {
                console.log(`ℹ️ Identity "${user.id}" already exists in wallet`);
                continue;
            }

            // Create a copy of admin identity with different name
            const userIdentity = {
                credentials: {
                    certificate: adminIdentity.credentials.certificate,
                    privateKey: adminIdentity.credentials.privateKey,
                },
                mspId: adminIdentity.mspId,
                type: adminIdentity.type,
            };

            await wallet.put(user.id, userIdentity);
            console.log(`✅ Created identity "${user.id}" with role "${user.role}"`);
        }

        console.log('\n🎉 All user identities created successfully!');
        console.log('📝 Note: These identities share the same certificate as admin for testing purposes.');
        console.log('   In production, each user should have unique certificates with embedded role attributes.');
        
    } catch (error) {
        console.error(`❌ Failed to create user identities: ${error}`);
    }
}

createUsersFromAdmin();
