#!/bin/bash

# API Endpoint Testing Script
# Tests all API endpoints to ensure they are working correctly

# Don't exit on error - we want to run all tests
# set -e

BASE_URL="http://localhost:3000"
FAILED_TESTS=0
PASSED_TESTS=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_test() {
    echo -e "\n${YELLOW}TEST: $1${NC}"
}

pass() {
    echo -e "${GREEN}✓ PASS${NC}: $1"
    ((PASSED_TESTS++))
}

fail() {
    echo -e "${RED}✗ FAIL${NC}: $1"
    ((FAILED_TESTS++))
}

# ============================================
# Test 1: Create a new user (no auth required)
# ============================================
print_test "POST /users - Create new user"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/users" \
  -H 'Content-Type: application/json' \
  -d '{
    "user": {
      "email": "testuser@example.com",
      "password": "testpass123",
      "password_digest": "testpass123"
    }
  }')

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "201" ]; then
    USER_ID=$(echo "$BODY" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
    if [ -n "$USER_ID" ]; then
        pass "User created successfully with ID: $USER_ID"
    else
        fail "User created but no ID returned"
    fi
else
    fail "Expected 201, got $HTTP_CODE. Response: $BODY"
fi

# ============================================
# Test 2: Login with the newly created user
# ============================================
print_test "POST /sessions - Login with new user"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/sessions" \
  -H 'Content-Type: application/json' \
  -d '{
    "email": "testuser@example.com",
    "password": "testpass123"
  }')

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ]; then
    TOKEN=$(echo "$BODY" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
    if [ -n "$TOKEN" ]; then
        pass "Login successful, token: ${TOKEN:0:20}..."
    else
        fail "Login returned 200 but no token found"
    fi
else
    fail "Expected 200, got $HTTP_CODE. Response: $BODY"
fi

# ============================================
# Test 3: Access /users/:id without authentication
# ============================================
print_test "GET /users/$USER_ID - Without authentication (should fail)"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL/users/$USER_ID" \
  -H 'Accept: application/json')

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "400" ]; then
    if echo "$BODY" | grep -q "Authentication required"; then
        pass "Correctly rejected unauthenticated request"
    else
        fail "Got 400 but wrong error message: $BODY"
    fi
else
    fail "Expected 400, got $HTTP_CODE. Response: $BODY"
fi

# ============================================
# Test 4: Access /users/:id WITH authentication
# ============================================
print_test "GET /users/$USER_ID - With authentication"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL/users/$USER_ID" \
  -H 'Accept: application/json' \
  -H "X-Authentication-Token: $TOKEN")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ]; then
    if echo "$BODY" | grep -q "testuser@example.com"; then
        pass "Retrieved user data successfully"
    else
        fail "Got 200 but user data doesn't match: $BODY"
    fi
else
    fail "Expected 200, got $HTTP_CODE. Response: $BODY"
fi

# ============================================
# Test 5: Test IDOR - View another user's data
# ============================================
print_test "GET /users/1 - IDOR test (view admin with regular user token)"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL/users/1" \
  -H 'Accept: application/json' \
  -H "X-Authentication-Token: $TOKEN")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ]; then
    pass "IDOR vulnerability confirmed - can view other users' data"
else
    fail "Expected 200 for IDOR test, got $HTTP_CODE"
fi

# ============================================
# Test 6: Access /posts without authentication
# ============================================
print_test "GET /posts - Without authentication (should fail)"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL/posts.json")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "400" ]; then
    if echo "$BODY" | grep -q "Authentication required"; then
        pass "Correctly rejected unauthenticated request"
    else
        fail "Got 400 but wrong error message: $BODY"
    fi
else
    fail "Expected 400, got $HTTP_CODE. Response: $BODY"
fi

# ============================================
# Test 7: Get posts WITH authentication
# ============================================
print_test "GET /posts - With authentication"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL/posts.json" \
  -H "X-Authentication-Token: $TOKEN")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ]; then
    if echo "$BODY" | grep -q '\['; then
        pass "Retrieved posts list successfully"
    else
        fail "Got 200 but response is not a JSON array: $BODY"
    fi
else
    fail "Expected 200, got $HTTP_CODE. Response: $BODY"
fi

# ============================================
# Test 8: Create a new post
# ============================================
print_test "POST /posts - Create new post"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/posts.json" \
  -H 'Content-Type: application/json' \
  -H "X-Authentication-Token: $TOKEN" \
  -d '{
    "post": {
      "title": "Test Post from API Script",
      "content": "This is a test post created via API"
    }
  }')

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "201" ]; then
    POST_ID=$(echo "$BODY" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
    if [ -n "$POST_ID" ]; then
        pass "Post created successfully with ID: $POST_ID"
    else
        fail "Post created but no ID returned"
    fi
else
    fail "Expected 201, got $HTTP_CODE. Response: $BODY"
fi

# ============================================
# Test 9: Get the newly created post
# ============================================
print_test "GET /posts/$POST_ID - Get specific post"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL/posts/$POST_ID.json" \
  -H "X-Authentication-Token: $TOKEN")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ]; then
    if echo "$BODY" | grep -q "Test Post from API Script"; then
        pass "Retrieved created post successfully"
    else
        fail "Got 200 but post content doesn't match: $BODY"
    fi
else
    fail "Expected 200, got $HTTP_CODE. Response: $BODY"
fi

# ============================================
# Test 10: Update the post
# ============================================
print_test "PUT /posts/$POST_ID - Update post"
RESPONSE=$(curl -s -w "\n%{http_code}" -X PUT "$BASE_URL/posts/$POST_ID.json" \
  -H 'Content-Type: application/json' \
  -H "X-Authentication-Token: $TOKEN" \
  -d '{
    "post": {
      "title": "Updated Test Post",
      "content": "This content has been updated"
    }
  }')

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)

if [ "$HTTP_CODE" = "204" ]; then
    pass "Post updated successfully"
else
    fail "Expected 204, got $HTTP_CODE"
fi

# ============================================
# Test 11: Verify the update
# ============================================
print_test "GET /posts/$POST_ID - Verify update"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL/posts/$POST_ID.json" \
  -H "X-Authentication-Token: $TOKEN")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ]; then
    if echo "$BODY" | grep -q "Updated Test Post"; then
        pass "Post update verified successfully"
    else
        fail "Post retrieved but update not reflected: $BODY"
    fi
else
    fail "Expected 200, got $HTTP_CODE"
fi

# ============================================
# Test 12: Delete the post
# ============================================
print_test "DELETE /posts/$POST_ID - Delete post"
RESPONSE=$(curl -s -w "\n%{http_code}" -X DELETE "$BASE_URL/posts/$POST_ID.json" \
  -H "X-Authentication-Token: $TOKEN")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)

if [ "$HTTP_CODE" = "204" ]; then
    pass "Post deleted successfully"
else
    fail "Expected 204, got $HTTP_CODE"
fi

# ============================================
# Test 13: Verify deletion
# ============================================
print_test "GET /posts/$POST_ID - Verify deletion (should fail)"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL/posts/$POST_ID.json" \
  -H "X-Authentication-Token: $TOKEN")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)

if [ "$HTTP_CODE" = "404" ] || [ "$HTTP_CODE" = "500" ]; then
    pass "Post deletion verified - post not found"
else
    fail "Expected 404 or 500, got $HTTP_CODE"
fi

# ============================================
# Test 14: Swagger UI accessibility
# ============================================
print_test "GET /api-docs - Swagger UI"
RESPONSE=$(curl -s -w "\n%{http_code}" -L -X GET "$BASE_URL/api-docs")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ]; then
    if echo "$BODY" | grep -iq "swagger"; then
        pass "Swagger UI is accessible"
    else
        fail "Got 200 but doesn't look like Swagger UI"
    fi
else
    fail "Expected 200, got $HTTP_CODE"
fi

# ============================================
# Test 15: OpenAPI spec accessibility
# ============================================
print_test "GET /api-docs/v1/swagger.yaml - OpenAPI Spec"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL/api-docs/v1/swagger.yaml")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ]; then
    if echo "$BODY" | grep -q "openapi:"; then
        pass "OpenAPI spec is accessible"
    else
        fail "Got 200 but doesn't look like OpenAPI spec"
    fi
else
    fail "Expected 200, got $HTTP_CODE"
fi

# ============================================
# Test 16: Config endpoint - Information disclosure (Vuln 12)
# ============================================
print_test "GET /config - Information disclosure vulnerability"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL/config")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ]; then
    if echo "$BODY" | grep -q "secret_token"; then
        if echo "$BODY" | grep -q "AIzaSy"; then
            pass "Config endpoint leaks secret token (Google API key detected)"
        else
            pass "Config endpoint leaks secret token"
        fi
    else
        fail "Got 200 but no secret_token in response: $BODY"
    fi
else
    fail "Expected 200, got $HTTP_CODE. Response: $BODY"
fi

# ============================================
# Summary
# ============================================
echo -e "\n=========================================="
echo -e "TEST SUMMARY"
echo -e "=========================================="
echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
echo -e "${RED}Failed: $FAILED_TESTS${NC}"
echo -e "Total:  $((PASSED_TESTS + FAILED_TESTS))"
echo -e "==========================================\n"

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
fi
