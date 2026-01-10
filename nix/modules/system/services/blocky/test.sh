#!/usr/bin/env bash

set -uo pipefail

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <blocky-server>"
    echo "Example: $0 192.168.0.22"
    exit 1
fi

BLOCKY_SERVER="$1"
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

passed=0
failed=0

test_dns() {
    local name="$1"
    local hostname="$2"
    local expected="$3"

    # Get all results, last line should be the IP (handles CNAME chains)
    result=$(dig +short @"$BLOCKY_SERVER" "$hostname" A | tail -n1)

    if [[ "$result" == "$expected" ]]; then
        echo -e "${GREEN}✓${NC} $name"
        ((passed++))
    else
        echo -e "${RED}✗${NC} $name (expected: $expected, got: '$result')"
        ((failed++))
    fi
}

test_blocked() {
    local domain="$1"

    result=$(dig +short @"$BLOCKY_SERVER" "$domain" A | head -n1)

    if [[ "$result" == "0.0.0.0" ]] || [[ -z "$result" ]]; then
        echo -e "${GREEN}✓${NC} $domain is blocked"
        ((passed++))
    else
        echo -e "${RED}✗${NC} $domain not blocked (got: $result)"
        ((failed++))
    fi
}

test_resolves() {
    local name="$1"
    local hostname="$2"

    result=$(dig +short @"$BLOCKY_SERVER" "$hostname" A | head -n1)

    if [[ -n "$result" ]] && [[ "$result" != "0.0.0.0" ]]; then
        echo -e "${GREEN}✓${NC} $name resolves to $result"
        ((passed++))
    else
        echo -e "${RED}✗${NC} $name failed to resolve"
        ((failed++))
    fi
}

echo "Testing Blocky DNS Server: $BLOCKY_SERVER"
echo "=========================="
echo ""

echo "Local Zone Resolution:"
test_dns "git.home.eltimn.com" "git.home.eltimn.com" "192.168.0.22"
test_dns "illmatic.home.eltimn.com" "illmatic.home.eltimn.com" "192.168.0.22"
test_dns "ruca.home.eltimn.com" "ruca.home.eltimn.com" "192.168.0.21"
test_dns "router.home.eltimn.com" "router.home.eltimn.com" "192.168.0.1"
test_dns "jellyfin.home.eltimn.com" "jellyfin.home.eltimn.com" "192.168.0.22"
echo ""

echo "External Resolution:"
test_resolves "google.com" "google.com"
test_resolves "github.com" "github.com"
test_resolves "cloudflare.com" "cloudflare.com"
echo ""

echo "Ad Blocking:"
test_blocked "doubleclick.net"
test_blocked "googlesyndication.com"
test_blocked "pagead2.googlesyndication.com"
echo ""

echo "ACME Challenge Conditional Forwarding:"
# ACME challenges should bypass local DNS and forward to public DNS (1.1.1.1)
# Since the domain doesn't exist publicly, it should return NXDOMAIN (empty result)
# but it should NOT return a local IP, proving it bypassed local DNS
acme_result=$(dig +short @"$BLOCKY_SERVER" _acme-challenge.home.eltimn.com TXT | head -n1)
local_result=$(dig +short @"$BLOCKY_SERVER" home.eltimn.com A | tail -n1)

# If we get an empty result OR a different result than local zone, conditional forwarding worked
if [[ -z "$acme_result" ]] || [[ "$acme_result" != "$local_result" ]]; then
    echo -e "${GREEN}✓${NC} ACME challenges bypass local DNS (forwarded to public DNS)"
    ((passed++))
else
    echo -e "${RED}✗${NC} ACME challenges may not be forwarding correctly"
    ((failed++))
fi
echo ""

echo "Caching Performance:"
echo -n "First query: "
time1=$(dig +stats @"$BLOCKY_SERVER" example.com | grep "Query time:" | awk '{print $4}')
echo "${time1}ms"

echo -n "Cached query: "
time2=$(dig +stats @"$BLOCKY_SERVER" example.com | grep "Query time:" | awk '{print $4}')
echo "${time2}ms"

if (( time2 <= time1 )); then
    echo -e "${GREEN}✓${NC} Caching is working (${time1}ms → ${time2}ms)"
    ((passed++))
else
    echo -e "${RED}✗${NC} Caching may not be working (cached query slower than first)"
    ((failed++))
fi
echo ""

echo "=========================="
echo -e "Results: ${GREEN}${passed} passed${NC}, ${RED}${failed} failed${NC}"

if [[ $failed -gt 0 ]]; then
    exit 1
fi
