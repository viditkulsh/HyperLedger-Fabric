#!/bin/bash
#
# SPDX-License-Identifier: Apache-2.0
#

set -euo pipefail

echo "Linting JavaScript code..."

# Find all JavaScript package.json files
PACKAGE_FILES=$(find . -name "package.json" | grep -v node_modules/ | grep -v .npm/ || true)

if [ -z "$PACKAGE_FILES" ]; then
    echo "No JavaScript projects found to lint"
    exit 0
fi

# Lint each JavaScript project
for package_file in $PACKAGE_FILES; do
    project_dir=$(dirname "$package_file")
    echo "Linting JavaScript project in $project_dir..."
    
    cd "$project_dir"
    
    # Check if this is a JavaScript project (not TypeScript)
    if grep -q '"main".*\.js' package.json && ! grep -q '"typescript"' package.json; then
        # Install dependencies if needed
        if [ ! -d "node_modules" ]; then
            echo "Installing dependencies..."
            npm install
        fi
        
        # Check for common linting tools
        if npm list eslint &>/dev/null || grep -q '"eslint"' package.json; then
            echo "Running ESLint..."
            npx eslint . --ext .js --ignore-pattern node_modules/
        else
            echo "No ESLint configuration found, running basic syntax check..."
            # Basic syntax check for all JS files
            find . -name "*.js" -not -path "./node_modules/*" -exec node -c {} \;
        fi
    fi
    
    cd - > /dev/null
done

echo "JavaScript linting completed successfully!"
