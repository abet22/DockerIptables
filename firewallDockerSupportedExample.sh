#!/bin/bash
set -x
# Find the path to the iptables binary (used to configure IPv4 firewall rules)
IPTABLES=`whereis -b iptables| awk '{print $2}'`
# Find the path to the ip6tables binary (used for IPv6, though not used in this script)
IP6TABLES=`whereis -b ip6tables| awk '{print $2}'`

####################################################################
# SOME VARIABLES 
MAIN_INTERFACE='ens32'		# ENSURE TO ADJUST THIS VARIABLE TO YOUR CASE
####################################################################
# Create two custom chains: "DOCKER-USER" and "FILTERS" if they don't already exist.
# DOCKER-USER is a special chain that Docker respects, allowing us to add custom firewall rules
# that Docker won't override. FILTERS is our custom chain for organizing rules.
$IPTABLES -t filter -L DOCKER-USER >/dev/null 2>&1 || $IPTABLES -t filter -N DOCKER-USER
$IPTABLES -t filter -L FILTERS >/dev/null 2>&1 || $IPTABLES -t filter -N FILTERS

# Set default policies for the main chains:
# INPUT: Controls incoming traffic to the host. ACCEPT allows all by default.
# FORWARD: Controls traffic between containers or to external networks. DROP blocks all by default.
# OUTPUT: Controls outgoing traffic from the host. ACCEPT allows all by default.
$IPTABLES -P INPUT ACCEPT 
$IPTABLES -P FORWARD DROP
$IPTABLES -P OUTPUT ACCEPT

# Clear (flush) existing rules in the INPUT, DOCKER-USER, and FILTERS chains to start fresh.
$IPTABLES -F INPUT
$IPTABLES -F DOCKER-USER
$IPTABLES -F FILTERS

# Allow all traffic on the loopback interface (lo), which is used for local communication
# within the host (e.g., between processes or containers on the same machine).
$IPTABLES -A INPUT -i lo -j ACCEPT
# Allow all ICMP traffic (like ping) for network diagnostics.
$IPTABLES -A INPUT -p icmp --icmp-type any -j ACCEPT
# Send all incoming traffic to the FILTERS chain for further processing.
$IPTABLES -A INPUT -j FILTERS
# Drop any incoming traffic that doesn't match any rule in FILTERS.
$IPTABLES -A INPUT -j DROP

# For Docker traffic coming through the network interface ens32 (likely the main network interface),
# send it to the FILTERS chain to apply our custom rules.
$IPTABLES -A DOCKER-USER -i $MAIN_INTERFACE -j FILTERS
# Allow traffic for connections that are already established or related to existing ones
# (e.g., responses to requests initiated by the host or containers).
$IPTABLES -A FILTERS -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

###################################   SPECIFIC RULES    #######################################
### SSH ###
# Allow incoming SSH traffic (port 22) from the specific IP address 157.63.111.79.
# This ensures only this IP can access the host via SSH, improving security.
$IPTABLES -A FILTERS -m conntrack --ctorigsrc 157.63.111.79 --ctorigdstport 22 -j ACCEPT
###########

### DOCKER ###
# Allow incoming HTTPS traffic (port 443) from the specific IP address 157.63.158.11.
$IPTABLES -A FILTERS -m conntrack --ctorigsrc 157.63.158.11 --ctorigdstport 443 -j ACCEPT         
##############

###################################################################################################

# Drop any traffic in the FILTERS chain that doesn't match the above rules.
$IPTABLES -A FILTERS -j DROP 
# Reject any remaining traffic with an ICMP "host prohibited" message.
# This informs the sender that their request was blocked, rather than silently dropping it.
$IPTABLES -A FILTERS -j REJECT --reject-with icmp-host-prohibited
