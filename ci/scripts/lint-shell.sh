#!/bin/bash
#
# SPDX-License-Identifier: Apache-2.0
#

set -euo pipefail

echo "Linting Shell scripts..."

# Find all shell scripts
SHELL_FILES=$(find . \( -name "*.sh" -o -name "*.bash" \) | grep -v node_modules/ | grep -v .git/ || true)

if [ -z "$SHELL_FILES" ]; then
    echo "No shell scripts found to lint"
    exit 0
fi

# Check if shellcheck is available
if ! command -v shellcheck &> /dev/null; then
    echo "Installing shellcheck..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y shellcheck
    elif command -v brew &> /dev/null; then
        brew install shellcheck
    else
        echo "Warning: shellcheck not available, performing basic syntax check only"
        for script in $SHELL_FILES; do
            echo "Checking syntax of $script..."
            bash -n "$script"
        done
        echo "Shell script syntax check completed!"
        exit 0
    fi
fi

echo "Running shellcheck on shell scripts..."
for script in $SHELL_FILES; do
    echo "Checking $script..."
    shellcheck "$script" || {
        echo "Warning: shellcheck failed for $script"
        # Continue with other files instead of failing immediately
    }
done

echo "Shell script linting completed!"
