#!/bin/bash
#
# SPDX-License-Identifier: Apache-2.0
#

set -euo pipefail

echo "Linting Java code..."

# Find all Java build files
BUILD_FILES=$(find . \( -name "build.gradle" -o -name "pom.xml" \) | grep -v node_modules/ || true)

if [ -z "$BUILD_FILES" ]; then
    echo "No Java projects found to lint"
    exit 0
fi

# Lint each Java project
for build_file in $BUILD_FILES; do
    project_dir=$(dirname "$build_file")
    echo "Linting Java project in $project_dir..."
    
    cd "$project_dir"
    
    if [ -f "build.gradle" ]; then
        echo "Found Gradle project"
        # Check if checkstyle or spotbugs is configured
        if grep -q "checkstyle\|spotbugs\|pmd" build.gradle; then
            echo "Running Gradle checks..."
            ./gradlew check --no-daemon
        else
            echo "Compiling Java code..."
            ./gradlew compileJava --no-daemon
        fi
    elif [ -f "pom.xml" ]; then
        echo "Found Maven project"
        # Check if checkstyle or spotbugs is configured
        if grep -q "checkstyle\|spotbugs\|pmd" pom.xml; then
            echo "Running Maven checks..."
            mvn verify
        else
            echo "Compiling Java code..."
            mvn compile
        fi
    fi
    
    cd - > /dev/null
done

echo "Java linting completed successfully!"
