#!/bin/sh
# This script restarts the firewall by cleaning specific rules in the FILTERS chain
# (without affecting Docker configurations) and then reapplying rules from firewallDockerSupported.sh.
# It uses colored output to make the process easier to follow.

# Define colors for terminal output: GREEN for messages, NC to reset to default
GREEN='\033[0;32m'
NC='\033[0m'

# Print a message indicating that specific rules are being cleaned without touching Docker
echo "${GREEN}Cleaning specific rules without affecting Docker configurations...${NC}"
# List all rules in the FILTERS chain with line numbers, exclude rules containing "ESTABLISHED",
# extract the line numbers, skip the first two lines (headers), sort in reverse order (to avoid index issues),
# and delete each rule by its line number using iptables -D
iptables -L FILTERS --line-number | grep -v ESTABLISHED | awk '{print $1}' | tail +3 | sort -n -r | xargs -i iptables -D FILTERS {}

# Print a message indicating that the firewall is being restarted by running selim.sh
echo "${GREEN}Restarting the firewall...${NC}"
sh -x ./firewallDockerSupported.sh
