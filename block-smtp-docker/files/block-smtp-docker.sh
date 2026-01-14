#!/bin/bash

# Script to block SMTP (port 25) traffic for Docker containers
# This prevents unauthorized email sending from containers

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Docker SMTP Traffic Blocker ===${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Error: This script must be run as root${NC}"
    exit 1
fi

# Function to remove existing port 25 rules
cleanup_existing_rules() {
    echo -e "${YELLOW}Cleaning up any existing port 25 rules...${NC}"
    
    # Remove from OUTPUT chain
    iptables -D OUTPUT -p tcp -m tcp --dport 25 -j DROP 2>/dev/null || true
    iptables -D OUTPUT -p tcp -m tcp --dport 25 -j REJECT --reject-with icmp-port-unreachable 2>/dev/null || true
    
    # Remove from INPUT chain
    iptables -D INPUT -p tcp -m tcp --dport 25 -j DROP 2>/dev/null || true
    iptables -D INPUT -p tcp -m tcp --dport 25 -j REJECT --reject-with icmp-port-unreachable 2>/dev/null || true
    
    # Remove from FORWARD chain (might be multiple, remove all)
    while iptables -D FORWARD -p tcp --dport 25 -j REJECT --reject-with icmp-port-unreachable 2>/dev/null; do
        :
    done
    
    # Remove from DOCKER-USER chain
    while iptables -D DOCKER-USER -p tcp --dport 25 -j REJECT --reject-with icmp-port-unreachable 2>/dev/null; do
        :
    done
    
    # Remove from ufw-before-forward chain
    while iptables -D ufw-before-forward -p tcp --dport 25 -j REJECT --reject-with icmp-port-unreachable 2>/dev/null; do
        :
    done
    
    echo -e "${GREEN}Cleanup complete.${NC}"
}

# Function to add blocking rules
add_blocking_rules() {
    echo -e "${YELLOW}Adding SMTP blocking rules...${NC}"
    
    # Block in DOCKER-USER chain (catches Docker container traffic)
    # This is the most important rule for Docker
    iptables -I DOCKER-USER 1 -p tcp --dport 25 -j REJECT --reject-with icmp-port-unreachable
    echo "  ✓ Added rule to DOCKER-USER chain"
    
    # Block in FORWARD chain (early in the chain)
    iptables -I FORWARD 1 -p tcp --dport 25 -j REJECT --reject-with icmp-port-unreachable
    echo "  ✓ Added rule to FORWARD chain"
    
    # Block in ufw-before-forward (if using UFW)
    if iptables -L ufw-before-forward -n >/dev/null 2>&1; then
        iptables -I ufw-before-forward 1 -p tcp --dport 25 -j REJECT --reject-with icmp-port-unreachable
        echo "  ✓ Added rule to ufw-before-forward chain"
    fi
    
    echo -e "${GREEN}Blocking rules added successfully.${NC}"
}

# Function to verify rules
verify_rules() {
    echo ""
    echo -e "${YELLOW}Verifying rules...${NC}"
    echo ""
    
    echo "DOCKER-USER chain:"
    iptables -L DOCKER-USER -n -v --line-numbers | grep -E "(Chain|dpt:25)" || echo "  No port 25 rules found"
    
    echo ""
    echo "FORWARD chain (first 3 rules):"
    iptables -L FORWARD -n -v --line-numbers | head -n 5 | grep -E "(Chain|num|dpt:25)" || echo "  No port 25 rules found"
    
    echo ""
}

# Function to save rules permanently
save_rules() {
    echo -e "${YELLOW}Saving iptables rules...${NC}"
    
    # Create directory if it doesn't exist
    mkdir -p /etc/iptables/
    
    # Save current rules
    iptables-save > /etc/iptables/rules.v4
    echo -e "${GREEN}Rules saved to /etc/iptables/rules.v4${NC}"
    
    # Try to use netfilter-persistent if available
    if command -v netfilter-persistent &> /dev/null; then
        netfilter-persistent save
        echo -e "${GREEN}Rules saved with netfilter-persistent${NC}"
    else
        echo -e "${YELLOW}Note: netfilter-persistent not found. Rules saved manually.${NC}"
        echo -e "${YELLOW}To make persistent across reboots, install: apt-get install iptables-persistent${NC}"
    fi
}

# Function to show monitoring commands
show_monitoring() {
    echo ""
    echo -e "${GREEN}=== Monitoring Commands ===${NC}"
    echo ""
    echo "To monitor if rules are blocking traffic:"
    echo "  watch -n 1 'iptables -L DOCKER-USER -n -v --line-numbers'"
    echo ""
    echo "To check for port 25 connections:"
    echo "  ss -tnp | grep :25"
    echo ""
    echo "To monitor with tcpdump:"
    echo "  tcpdump -i ens18 -nn 'port 25'"
    echo ""
    echo "To view kernel logs for blocked attempts:"
    echo "  tail -f /var/log/kern.log | grep REJECT"
    echo ""
}

# Main execution
case "${1:-install}" in
    install)
        cleanup_existing_rules
        add_blocking_rules
        verify_rules
        save_rules
        show_monitoring
        echo ""
        echo -e "${GREEN}✓ SMTP blocking successfully installed!${NC}"
        ;;
    
    remove)
        echo -e "${YELLOW}Removing SMTP blocking rules...${NC}"
        cleanup_existing_rules
        save_rules
        echo -e "${GREEN}✓ SMTP blocking removed!${NC}"
        ;;
    
    status)
        verify_rules
        echo ""
        echo "Current port 25 connections:"
        ss -tnp | grep :25 || echo "  No active port 25 connections"
        ;;
    
    *)
        echo "Usage: $0 {install|remove|status}"
        echo ""
        echo "  install - Add SMTP blocking rules (default)"
        echo "  remove  - Remove SMTP blocking rules"
        echo "  status  - Show current rules and connections"
        exit 1
        ;;
esac

exit 0
