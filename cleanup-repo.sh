#!/bin/bash

# Script to clean up fabric-samples repository and keep only essential files
# This will create the structure you want for GitHub showcase

echo "🧹 Starting repository cleanup..."

# Create backup directory (optional)
mkdir -p ../fabric-samples-backup
echo "📦 Creating backup in ../fabric-samples-backup..."

# List of directories to KEEP
KEEP_DIRS=(
    "fabric-api"
    "test-network"
    ".git"
    ".github"
)

# List of files to KEEP in root
KEEP_FILES=(
    ".gitignore"
    "README.md"
    "LICENSE"
)

# First, backup important directories
cp -r fabric-api ../fabric-samples-backup/ 2>/dev/null || true
cp -r test-network ../fabric-samples-backup/ 2>/dev/null || true
cp .gitignore ../fabric-samples-backup/ 2>/dev/null || true
cp README.md ../fabric-samples-backup/ 2>/dev/null || true

echo "✅ Backup created"

# Remove all directories except the ones we want to keep
echo "🗑️  Removing unwanted directories..."
for dir in */; do
    dir_name="${dir%/}"
    if [[ ! " ${KEEP_DIRS[@]} " =~ " ${dir_name} " ]]; then
        echo "  Removing directory: $dir_name"
        rm -rf "$dir_name"
    fi
done

# Remove unwanted root files
echo "🗑️  Removing unwanted root files..."
for file in *; do
    if [[ -f "$file" ]]; then
        if [[ ! " ${KEEP_FILES[@]} " =~ " ${file} " ]]; then
            echo "  Removing file: $file"
            rm -f "$file"
        fi
    fi
done

# Clean up fabric-api directory
echo "🧹 Cleaning fabric-api directory..."
cd fabric-api
rm -rf node_modules/ wallet/ package-lock.json 2>/dev/null || true
# Keep essential API files
echo "  Kept essential fabric-api files"
cd ..

# Clean up test-network directory
echo "🧹 Cleaning test-network directory..."
cd test-network
# Remove generated artifacts
rm -rf organizations/ channel-artifacts/ crypto-config/ system-genesis-block/ 2>/dev/null || true
rm -f log.txt *.tar.gz install-fabric.sh 2>/dev/null || true
rm -rf fabric-samples/ 2>/dev/null || true
# Keep essential network files
echo "  Kept essential test-network files"
cd ..

# Create chaincode directory if custom chaincode exists
if [ -d "test-network/chaincode" ]; then
    echo "📁 Moving chaincode to root level..."
    mv test-network/chaincode ./chaincode
fi

echo "✅ Repository cleanup completed!"
echo ""
echo "📋 Current structure:"
find . -type f -name ".*" -prune -o -type f -print | head -20
echo ""
echo "🎯 Your repository now contains only the essential files for GitHub showcase!"
echo "📝 Don't forget to update your README.md with project explanation"
