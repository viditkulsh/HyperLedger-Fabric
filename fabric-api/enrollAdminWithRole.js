const FabricCAServices = require('fabric-ca-client');
const { Wallets } = require('fabric-network');
const fs = require('fs');
const path = require('path');

async function main() {
    try {
        // Load connection profile
        const ccpPath = path.resolve(__dirname, '..', 'test-network', 'organizations', 'peerOrganizations', 'org1.example.com', 'connection-org1.json');
        const ccp = JSON.parse(fs.readFileSync(ccpPath, 'utf8'));

        const caURL = ccp.certificateAuthorities['ca.org1.example.com'].url;
        const ca = new FabricCAServices(caURL);

        const walletPath = path.join(process.cwd(), 'wallet');
        const wallet = await Wallets.newFileSystemWallet(walletPath);

        // Enroll admin
        let adminIdentity = await wallet.get('admin');
        if (!adminIdentity) {
            const enrollment = await ca.enroll({ enrollmentID: 'admin', enrollmentSecret: 'adminpw' });
            const x509Identity = {
                credentials: {
                    certificate: enrollment.certificate,
                    privateKey: enrollment.key.toBytes(),
                },
                mspId: 'Org1MSP',
                type: 'X.509',
            };
            await wallet.put('admin', x509Identity);
            console.log('✅ Successfully enrolled admin user "admin" and imported it into the wallet');
            adminIdentity = await wallet.get('admin'); // Get fresh identity from wallet
        }

        // Register and enroll with roles
        const users = [
            { id: 'adminUser', role: 'admin' },
            { id: 'auditorUser', role: 'auditor' },
            { id: 'regularUser', role: 'regularUser' }
        ];

        const provider = wallet.getProviderRegistry().getProvider(adminIdentity.type);
        const adminUser = await provider.getUserContext(adminIdentity, 'admin');

        for (const user of users) {
            const userExists = await wallet.get(user.id);
            if (userExists) {
                console.log(`ℹ️ An identity for the user "${user.id}" already exists in the wallet`);
                continue;
            }

            try {
                const secret = await ca.register({
                    enrollmentID: user.id,
                    role: 'client',
                    attrs: [{ name: 'role', value: user.role, ecert: true }]
                }, adminUser);

                const enrollment = await ca.enroll({
                    enrollmentID: user.id,
                    enrollmentSecret: secret,
                    attr_reqs: [{ name: 'role', optional: false }]
                });

                const x509Identity = {
                    credentials: {
                        certificate: enrollment.certificate,
                        privateKey: enrollment.key.toBytes(),
                    },
                    mspId: 'Org1MSP',
                    type: 'X.509',
                };
                await wallet.put(user.id, x509Identity);
                console.log(`✅ Successfully registered and enrolled user "${user.id}" with role "${user.role}"`);
            } catch (error) {
                if (error.message.includes('already registered')) {
                    console.log(`ℹ️ User "${user.id}" is already registered in CA, attempting to enroll with existing credentials`);
                    // Try to enroll with a known secret or skip if we can't
                    console.log(`⚠️ Skipping user "${user.id}" - already registered in CA but not in wallet`);
                } else {
                    console.error(`❌ Failed to register/enroll user "${user.id}": ${error.message}`);
                }
            }
        }
    } catch (error) {
        console.error(`❌ Failed to enroll admin/user: ${error}`);
        process.exit(1);
    }
}

main();
