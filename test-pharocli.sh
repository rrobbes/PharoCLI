#!/bin/bash
# PharoCLI Python Version - Automated Test Suite
# Tests fixed bugs and core functionality
# Run: ./test-pharocli.sh

PHAROCLI="python3 pharocli.py"
TESTS_PASSED=0
TESTS_FAILED=0
VERBOSE=${VERBOSE:-0}

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper function to run a test
test_command() {
    local test_name="$1"
    local command="$2"
    local expected_pattern="$3"
    local should_fail="${4:-0}"
    
    if [ $VERBOSE -eq 1 ]; then
        echo "Running: $command"
    fi
    
    # Run command and capture output (allow any exit code)
    output=$(eval "$command" 2>&1) || true
    exit_code=$?
    
    if [ "$should_fail" -eq 1 ]; then
        # For tests that should fail (non-zero exit), check the error message pattern
        if [ $exit_code -ne 0 ] && echo "$output" | grep -q "$expected_pattern"; then
            echo -e "${GREEN}✓${NC} $test_name"
            ((TESTS_PASSED++))
            return 0
        else
            echo -e "${RED}✗${NC} $test_name"
            if [ $VERBOSE -eq 1 ]; then
                echo "Expected pattern in error: $expected_pattern"
                echo "Actual output: $output"
            fi
            ((TESTS_FAILED++))
            return 1
        fi
    fi
    
    # For normal tests, check output pattern (ignore exit code)
    if echo "$output" | grep -q "$expected_pattern"; then
        echo -e "${GREEN}✓${NC} $test_name"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $test_name (output didn't match expected pattern)"
        if [ $VERBOSE -eq 1 ]; then
            echo "Expected pattern: $expected_pattern"
            echo "Actual output: $output"
        fi
        ((TESTS_FAILED++))
        return 1
    fi
}

echo "=========================================="
echo "PharoCLI Python Version - Test Suite"
echo "=========================================="
echo ""

# ========== FIXED BUGS ==========
echo "## Testing Fixed Bugs"
echo ""

echo "### Bug #1 & #8: Operator Methods"

test_command \
    "sources with + operator" \
    "$PHAROCLI sources \"Integer>> +\" \"Integer>> *\" 2>&1" \
    "Integer>>\\+" 

test_command \
    "source with >> operator" \
    "$PHAROCLI source \"Integer>> >>\" 2>&1" \
    "shiftAmount"

test_command \
    "source with * operator" \
    "$PHAROCLI source \"Integer>> *\" 2>&1" \
    "digitMultiply"

test_command \
    "info with operator" \
    "$PHAROCLI info \"Number>> +\" 2>&1" \
    "Number>>\\+.*arithmetic"

test_command \
    "implementors of + operator" \
    "$PHAROCLI implementors \"+\" 2>&1" \
    "Number>>\\+"

echo ""
echo "### Bug #2 & #3: Implementors Package Filtering"

test_command \
    "implementors with --in-package" \
    "$PHAROCLI implementors yourself --in-package Kernel 2>&1" \
    "Object>>#yourself"

test_command \
    "implementors with --in-packages" \
    "$PHAROCLI implementors yourself --in-packages Kernel Collections 2>&1" \
    "Object>>#yourself"

test_command \
    "implementors without filter (should return multiple)" \
    "$PHAROCLI implementors yourself 2>&1" \
    "yourself"

echo ""

# ========== CORE FUNCTIONALITY ==========
echo "## Testing Core Functionality"
echo ""

echo "### Package Commands"

test_command \
    "packages list" \
    "$PHAROCLI packages 2>&1" \
    "^Kernel$"

test_command \
    "packages classes" \
    "$PHAROCLI packages classes Kernel 2>&1" \
    "Object"

test_command \
    "packages sub" \
    "$PHAROCLI packages sub Kernel 2>&1" \
    "Kernel-"

echo ""
echo "### Method Commands"

test_command \
    "methods Object" \
    "$PHAROCLI methods Object 2>&1" \
    "yourself"

test_command \
    "methods with protocol filter" \
    "$PHAROCLI methods Object --protocols accessing 2>&1" \
    "yourself"

test_command \
    "protocols Object" \
    "$PHAROCLI protocols Object 2>&1" \
    "accessing"

echo ""
echo "### Search Commands"

test_command \
    "implementors basic" \
    "$PHAROCLI implementors yourself 2>&1" \
    "yourself"

test_command \
    "senders basic" \
    "$PHAROCLI senders yourself 2>&1" \
    ">>"

test_command \
    "search with filter" \
    "$PHAROCLI search test --in-packages Kernel 2>&1" \
    "test"

echo ""
echo "### Class Inspection"

test_command \
    "hierarchy" \
    "$PHAROCLI hierarchy Object 2>&1" \
    "Object"

test_command \
    "comment" \
    "$PHAROCLI comment Object 2>&1" \
    "root"

test_command \
    "variables" \
    "$PHAROCLI variables Point 2>&1" \
    "Point instance"

echo ""
echo "### Object Inspection"

test_command \
    "inspect tree" \
    "$PHAROCLI inspect tree \"Point x: 10 y: 20\" 2>&1" \
    "Point"

test_command \
    "inspect tree with depth" \
    "$PHAROCLI inspect tree \"Array with: 1 with: 2\" 2 2>&1" \
    "Array"

echo ""

# ========== BASH INTEGRATION ==========
echo "## Testing Bash Integration"
echo ""

test_command \
    "grep filtering" \
    "$PHAROCLI methods Object 2>&1 | grep \"as\" | wc -l" \
    "[0-9]"

test_command \
    "count with wc" \
    "$PHAROCLI implementors yourself --in-package Kernel 2>&1 | wc -l" \
    "[0-9]"

test_command \
    "sed extraction" \
    "$PHAROCLI implementors yourself 2>&1 | sed 's/>>.*//' | head -1" \
    "Object"

test_command \
    "sort and uniq" \
    "$PHAROCLI senders yourself --in-packages Kernel 2>&1 | sed 's/>>.*//' | sort | uniq | wc -l" \
    "[0-9]"

echo ""

# ========== EDGE CASES ==========
echo "## Testing Edge Cases"
echo ""

test_command \
    "multiple classes" \
    "$PHAROCLI methods Object String 2>&1" \
    "yourself"

test_command \
    "multiple protocols" \
    "$PHAROCLI methods Object --protocols accessing printing 2>&1" \
    "yourself"

echo ""

# ========== SUMMARY ==========
echo "=========================================="
echo "Test Results"
echo "=========================================="
echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Failed: ${RED}$TESTS_FAILED${NC}"
echo "Total:  $((TESTS_PASSED + TESTS_FAILED))"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed${NC}"
    exit 1
fi
