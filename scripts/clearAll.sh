#!/bin/sh
# This script completely resets iptables firewall rules and disables IP forwarding.
# It clears all rules, deletes user-defined chains, and sets permissive policies,
# ensuring a clean slate for firewall configurations. Use with caution, as it may
# disrupt Docker or other network services.

# Find the path to the iptables binary (used to configure IPv4 firewall rules)
IPTABLES=`whereis -b iptables| awk '{print $2}'`
# IP6TABLES is commented out, so this script only handles IPv4 rules
#IP6TABLES=`whereis -b ip6tables| awk '{print $2}'`

# Set the default policy for INPUT to ACCEPT, allowing all incoming traffic
$IPTABLES -P INPUT ACCEPT
# Set the default policy for FORWARD to ACCEPT, allowing all forwarded traffic
# (e.g., between Docker containers or to external networks)
$IPTABLES -P FORWARD ACCEPT

# Clear all rules in the NAT table, which Docker uses for port mapping
$IPTABLES -t nat -F
# Clear all rules in the default filter table (used for most firewall rules)
$IPTABLES -F
# Delete all user-defined chains (e.g., FILTERS, DOCKER-USER)
$IPTABLES -X
# Explicitly clear the INPUT chain (rules for incoming traffic)
$IPTABLES -F INPUT
# Explicitly clear the OUTPUT chain (rules for outgoing traffic)
$IPTABLES -F OUTPUT
# Explicitly clear the FORWARD chain (rules for forwarded traffic, critical for Docker)
$IPTABLES -F FORWARD

# Disable IP forwarding by setting /proc/sys/net/ipv4/ip_forward to 0
# This prevents the system from routing traffic between network interfaces
echo 0 > /proc/sys/net/ipv4/ip_forward
