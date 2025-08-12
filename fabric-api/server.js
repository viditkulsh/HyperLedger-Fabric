const express = require("express");
const bodyParser = require("body-parser");
const { getContract } = require("./fabric");

const app = express();
app.use(bodyParser.json());

// ✅ Create Asset (already working)
app.post("/assets", async (req, res) => {
  try {
    const { id, owner, value } = req.body;
    const contract = await getContract("adminUser"); // Only Admin can create
    const result = await contract.submitTransaction("CreateAsset", id, owner, value);
    res.json(JSON.parse(result.toString()));
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ✅ Get Asset by ID
app.get("/assets/:id", async (req, res) => {
  try {
    const contract = await getContract("regularUser"); // Regular user can read their own
    const result = await contract.evaluateTransaction("ReadAsset", req.params.id);
    res.json(JSON.parse(result.toString()));
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ✅ Update Asset
app.put("/assets/:id", async (req, res) => {
  try {
    const { newValue } = req.body;
    const contract = await getContract("adminUser"); // Only Admin allowed to update
    const result = await contract.submitTransaction("UpdateAsset", req.params.id, newValue);
    res.json(JSON.parse(result.toString()));
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ✅ Delete Asset
app.delete("/assets/:id", async (req, res) => {
  try {
    const contract = await getContract("adminUser"); // Only Admin allowed
    await contract.submitTransaction("DeleteAsset", req.params.id);
    res.json({ message: `Asset ${req.params.id} deleted successfully` });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ✅ Get All Assets (only Auditor)
app.get("/assets", async (req, res) => {
  try {
    const contract = await getContract("auditorUser"); // Only Auditor can view all
    const result = await contract.evaluateTransaction("GetAllAssets");
    res.json(JSON.parse(result.toString()));
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`🚀 Fabric API server running at http://localhost:${PORT}`);
});
