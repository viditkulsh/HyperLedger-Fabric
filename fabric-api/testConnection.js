const { getContract } = require('./fabric');

async function testConnection() {
    try {
        console.log('🔍 Testing connection to Fabric network...');
        
        const contract = await getContract('adminUser');
        console.log('✅ Successfully connected to contract');
        
        // Try a simple query
        const result = await contract.evaluateTransaction('AssetExists', 'test123');
        console.log('✅ Successfully executed AssetExists query:', result.toString());
        
    } catch (error) {
        console.error('❌ Connection test failed:', error.message);
        console.error('Full error:', error);
    }
}

testConnection();
