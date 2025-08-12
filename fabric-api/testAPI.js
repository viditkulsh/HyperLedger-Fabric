// testAPI.js
const axios = require('axios');

const BASE_URL = 'http://localhost:3000';

async function testAPI() {
  console.log('🧪 Testing Fabric API endpoints...\n');

  try {
    // Test 1: Create Asset (Admin)
    console.log('1️⃣ Testing CreateAsset as Admin...');
    const createResponse = await axios.post(`${BASE_URL}/assets`, {
      assetID: 'asset001',
      owner: 'user123',
      value: '1000',
      userId: 'adminUser'
    });
    console.log('✅ Asset created:', createResponse.data);

    // Test 2: Read Asset (Admin)
    console.log('\n2️⃣ Testing ReadAsset as Admin...');
    const readResponse = await axios.get(`${BASE_URL}/assets/asset001?userId=adminUser`);
    console.log('✅ Asset read:', readResponse.data);

    // Test 3: Create Asset (Regular User)
    console.log('\n3️⃣ Testing CreateAsset as Regular User...');
    const createUserResponse = await axios.post(`${BASE_URL}/assets`, {
      assetID: 'asset002',
      owner: 'someoneelse', // This should be ignored for regular users
      value: '500',
      userId: 'regularUser'
    });
    console.log('✅ Asset created by user:', createUserResponse.data);

    // Test 4: Get All Assets (Auditor)
    console.log('\n4️⃣ Testing GetAllAssets as Auditor...');
    const allAssetsResponse = await axios.get(`${BASE_URL}/assets?userId=auditorUser`);
    console.log('✅ All assets:', allAssetsResponse.data);

    // Test 5: Update Asset (Owner)
    console.log('\n5️⃣ Testing UpdateAsset as Owner...');
    const updateResponse = await axios.put(`${BASE_URL}/assets/asset001`, {
      newValue: '1500',
      userId: 'adminUser'
    });
    console.log('✅ Asset updated:', updateResponse.data);

  } catch (error) {
    console.error('❌ Test failed:', error.response?.data || error.message);
  }
}

// Run tests
testAPI();
