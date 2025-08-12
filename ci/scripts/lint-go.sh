#!/bin/bash
#
# SPDX-License-Identifier: Apache-2.0
#

set -euo pipefail

echo "Linting Go code..."

# Find all Go files
GO_FILES=$(find . -name "*.go" | grep -v vendor/ | grep -v node_modules/ || true)

if [ -z "$GO_FILES" ]; then
    echo "No Go files found to lint"
    exit 0
fi

# Check Go formatting
echo "Checking Go formatting..."
UNFORMATTED=$(gofmt -l $GO_FILES)
if [ -n "$UNFORMATTED" ]; then
    echo "The following Go files are not formatted:"
    echo "$UNFORMATTED"
    echo "Please run 'gofmt -w' on these files"
    exit 1
fi

# Check Go imports
echo "Checking Go imports..."
UNFORMATTED_IMPORTS=$(goimports -l $GO_FILES)
if [ -n "$UNFORMATTED_IMPORTS" ]; then
    echo "The following Go files have incorrect imports:"
    echo "$UNFORMATTED_IMPORTS"
    echo "Please run 'goimports -w' on these files"
    exit 1
fi

# Run go vet on all modules
echo "Running go vet..."
for dir in $(find . -name "go.mod" -exec dirname {} \;); do
    echo "Checking $dir..."
    (cd "$dir" && go vet ./...)
done

echo "Go linting completed successfully!"
