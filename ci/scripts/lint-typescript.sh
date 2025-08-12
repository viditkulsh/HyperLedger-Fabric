#!/bin/bash
#
# SPDX-License-Identifier: Apache-2.0
#

set -euo pipefail

echo "Linting TypeScript code..."

# Find all TypeScript package.json files
PACKAGE_FILES=$(find . -name "package.json" | grep -v node_modules/ | grep -v .npm/ || true)

if [ -z "$PACKAGE_FILES" ]; then
    echo "No TypeScript projects found to lint"
    exit 0
fi

# Lint each TypeScript project
for package_file in $PACKAGE_FILES; do
    project_dir=$(dirname "$package_file")
    echo "Checking TypeScript project in $project_dir..."
    
    cd "$project_dir"
    
    # Check if this is a TypeScript project
    if grep -q '"typescript"' package.json || [ -f "tsconfig.json" ] || find . -name "*.ts" -not -path "./node_modules/*" | grep -q .; then
        echo "Found TypeScript project in $project_dir"
        
        # Install dependencies if needed
        if [ ! -d "node_modules" ]; then
            echo "Installing dependencies..."
            npm install
        fi
        
        # Check for TypeScript compiler
        if npm list typescript &>/dev/null || grep -q '"typescript"' package.json; then
            echo "Running TypeScript compiler check..."
            npx tsc --noEmit --skipLibCheck
        fi
        
        # Check for ESLint with TypeScript
        if npm list @typescript-eslint/parser &>/dev/null || grep -q '"@typescript-eslint"' package.json; then
            echo "Running ESLint for TypeScript..."
            npx eslint . --ext .ts --ignore-pattern node_modules/
        elif npm list eslint &>/dev/null; then
            echo "Running ESLint..."
            npx eslint . --ext .ts --ignore-pattern node_modules/
        fi
    fi
    
    cd - > /dev/null
done

echo "TypeScript linting completed successfully!"
