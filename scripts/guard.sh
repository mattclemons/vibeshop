#!/usr/bin/env bash
# Dedicated chains only. Never flush DOCKER-USER or another app's rules.
set -euo pipefail
source "$(dirname "$0")/common.sh"
IPT=(iptables -w)
[ "$(id -u)" = 0 ] || IPT=(sudo iptables -w)
"${IPT[@]}" -S DOCKER-USER >/dev/null
for chain in VIBESHOP-IN VIBESHOP-FWD; do
  "${IPT[@]}" -N "$chain" 2>/dev/null || true
  "${IPT[@]}" -F "$chain"
  for net in 127.0.0.0/8 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16 ${CLIENT_NET:+$CLIENT_NET}; do
    "${IPT[@]}" -A "$chain" -s "$net" -j RETURN
  done
  "${IPT[@]}" -A "$chain" -j DROP
done
# Caddy runs on host networking, so INPUT must cover it as well as DOCKER-USER.
ports='80,8080,8081,3000,5432,8025,9000,9001'
"${IPT[@]}" -C INPUT -d "$LAB_IP" -p tcp -m multiport --dports "$ports" -j VIBESHOP-IN 2>/dev/null ||
  "${IPT[@]}" -I INPUT 1 -d "$LAB_IP" -p tcp -m multiport --dports "$ports" -j VIBESHOP-IN
# DOCKER-USER sees DNATted traffic. Match the original host address and port.
for port in 3000 5432 8025 8081 9000 9001; do
  "${IPT[@]}" -C DOCKER-USER -p tcp -m conntrack --ctorigdst "$LAB_IP" --ctorigdstport "$port" -j VIBESHOP-FWD 2>/dev/null ||
    "${IPT[@]}" -I DOCKER-USER 1 -p tcp -m conntrack --ctorigdst "$LAB_IP" --ctorigdstport "$port" -j VIBESHOP-FWD
done
echo "Lab firewall rules installed for $LAB_IP. RFC1918 clients are allowed."
