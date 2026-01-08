#!/bin/bash

# Define colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Spectral POC SCOR${NC}\n"

echo -e "--------------------------------------------------------"
echo -e "${GREEN}Test 1: Linting a VALID OpenAPI Specification${NC}"
echo -e "File: specs/customer-api-v1.yaml"
echo -e "--------------------------------------------------------"
./node_modules/.bin/spectral lint specs/customer-api-v1.yaml --ruleset owasp23-ruleset.spectral.yml
EXIT_CODE=$?
echo "Debug: npx exit code is $EXIT_CODE"
if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}Result: PASS - No issues found (or only ignored warnings).${NC}"
else
    echo -e "${RED}Result: FAIL - Issues found.${NC}"
fi

echo -e "\n\n"

echo -e "--------------------------------------------------------"
echo -e "${RED}Test 2: Linting an INSECURE OpenAPI Specification${NC}"
echo -e "File: specs/customer-api-v1-insecure.yaml"
echo -e "--------------------------------------------------------"
./node_modules/.bin/spectral lint specs/customer-api-v1-insecure.yaml --ruleset owasp23-ruleset.spectral.yml
# We expect this to fail
echo -e "\n${GREEN}Note: The above errors/warnings are EXPECTED for this insecure spec to demonstrate the linter capabilities.${NC}"
