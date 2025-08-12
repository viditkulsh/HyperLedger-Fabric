'use strict';

const { Contract } = require('fabric-contract-api');

class AssetTransfer extends Contract {

    async InitLedger(ctx) {
        console.info('Ledger initialized');
    }

    async CreateAsset(ctx, assetID, owner, value) {
        // For testing purposes, we'll simulate roles based on userId
        const userId = ctx.clientIdentity.getID();
        let role = 'user'; // default role
        
        // Simple role assignment based on user ID for testing
        if (userId.includes('adminUser') || userId.includes('Admin')) {
            role = 'admin';
        } else if (userId.includes('auditorUser')) {
            role = 'auditor';
        } else if (userId.includes('regularUser')) {
            role = 'user';
        }

        console.log(`User ${userId} acting with role: ${role}`);

        const callerID = ctx.clientIdentity.getID();

        // Admin can create assets for anyone
        if (role === 'admin') {
            const exists = await this.AssetExists(ctx, assetID);
            if (exists) {
                throw new Error(`The asset ${assetID} already exists`);
            }
            const asset = { ID: assetID, Owner: owner, Value: value };
            await ctx.stub.putState(assetID, Buffer.from(JSON.stringify(asset)));
            return JSON.stringify(asset);
        }

        // Regular users can create assets, but only owned by themselves
        if (role === 'user') {
            const exists = await this.AssetExists(ctx, assetID);
            if (exists) {
                throw new Error(`The asset ${assetID} already exists`);
            }
            const asset = { ID: assetID, Owner: callerID, Value: value };
            await ctx.stub.putState(assetID, Buffer.from(JSON.stringify(asset)));
            return JSON.stringify(asset);
        }

        throw new Error('You are not authorized to create assets');
    }

    async ReadAsset(ctx, assetID) {
        const assetJSON = await ctx.stub.getState(assetID);
        if (!assetJSON || assetJSON.length === 0) {
            throw new Error(`The asset ${assetID} does not exist`);
        }

        const asset = JSON.parse(assetJSON.toString());
        const userId = ctx.clientIdentity.getID();
        let role = 'user';
        
        if (userId.includes('adminUser') || userId.includes('Admin')) {
            role = 'admin';
        } else if (userId.includes('auditorUser')) {
            role = 'auditor';
        }

        const callerID = ctx.clientIdentity.getID();

        if (role === 'admin' || role === 'auditor' || asset.Owner === callerID) {
            return assetJSON.toString();
        }
        throw new Error('You can only view assets you own');
    }

    async UpdateAsset(ctx, assetID, newValue) {
        const exists = await this.AssetExists(ctx, assetID);
        if (!exists) {
            throw new Error(`The asset ${assetID} does not exist`);
        }

        const asset = JSON.parse((await ctx.stub.getState(assetID)).toString());
        const callerID = ctx.clientIdentity.getID();

        if (asset.Owner !== callerID) {
            throw new Error('Only the asset owner can update it');
        }

        asset.Value = newValue;
        await ctx.stub.putState(assetID, Buffer.from(JSON.stringify(asset)));
        return JSON.stringify(asset);
    }

    async DeleteAsset(ctx, assetID) {
        const exists = await this.AssetExists(ctx, assetID);
        if (!exists) {
            throw new Error(`The asset ${assetID} does not exist`);
        }

        const asset = JSON.parse((await ctx.stub.getState(assetID)).toString());
        const callerID = ctx.clientIdentity.getID();

        if (asset.Owner !== callerID) {
            throw new Error('Only the asset owner can delete it');
        }

        await ctx.stub.deleteState(assetID);
    }

    async GetAllAssets(ctx) {
        const userId = ctx.clientIdentity.getID();
        let role = 'user';
        
        if (userId.includes('auditorUser')) {
            role = 'auditor';
        }

        if (role !== 'auditor') {
            throw new Error('Only Auditor can view all assets');
        }

        const iterator = await ctx.stub.getStateByRange('', '');
        const results = [];
        let res = await iterator.next();
        while (!res.done) {
            const strValue = res.value.value.toString('utf8');
            let record;
            try {
                record = JSON.parse(strValue);
            } catch (err) {
                record = strValue;
            }
            results.push(record);
            res = await iterator.next();
        }
        return JSON.stringify(results);
    }

    async AssetExists(ctx, assetID) {
        const assetJSON = await ctx.stub.getState(assetID);
        return assetJSON && assetJSON.length > 0;
    }
}

module.exports = AssetTransfer;
