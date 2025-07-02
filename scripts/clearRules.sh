#!/bin/sh
set -x
# This script cleans specific iptables rules and logging chains without affecting Docker-related configurations.
# It targets the FILTERS chain and removes rules that don't involve "ESTABLISHED" states.
# It also clears logging chains used for tracking accepted or dropped traffic.

# Print a message to indicate the script's purpose
echo "Cleaning specific rules without affecting Docker configurations"

# List all rules in the FILTERS chain with line numbers, exclude rules containing "ESTABLISHED",
# extract the line numbers, skip the first two lines (headers), sort in reverse order (to avoid index issues),
# and delete each rule by its line number using iptables -D.
iptables -L FILTERS --line-number | grep -v ESTABLISHED | awk '{print $1}' | tail +3 | sort -n -r | xargs -i iptables -D FILTERS {}

# Clear logging chains used to track dropped or accepted traffic.
# LOGDROPG: Likely logs dropped packets.
echo "Clearing LOGDROPG chain"
iptables -F LOGDROPG
# LOGACCEPTG: Likely logs accepted packets.
echo "Clearing LOGACCEPTG chain"
iptables -F LOGACCEPTG
# NOLOGDROPG: Likely used for dropped packets without logging.
echo "Clearing NOLOGDROPG chain"
iptables -F NOLOGDROPG
