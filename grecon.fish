#!/usr/bin/env fish
read -P "Target IP: " target
if test -z "$target"
    echo "No target IP given. Aborting."
    exit 1
end
set -U tip $target

read -P "Interface [tun0]: " iface
test -z "$iface"; and set iface tun0
set -l myip (ip -4 -o addr show dev $iface 2>/dev/null | string match -rg 'inet (\S+?)/')
if test -z "$myip"
    echo "Could not read an IP from interface '$iface' (continuing anyway)."
else
    set -U mip $myip
    echo "Your IP ($iface): $mip"
end

set -l outdir ./output
mkdir -p $outdir
echo "Target: $tip  |  Output: $outdir/"
echo "Launching scans in parallel..."
echo

echo "[gobuster] launching :80 and :443 in the background..."
gobuster dir -w /usr/share/wordlists/dirb/big.txt -u http://$tip:80 \
    -x html,txt,pdf,php -q -o $outdir/gobuster-80.txt &
gobuster dir -w /usr/share/wordlists/dirb/big.txt -u http://$tip:443 \
    -x html,txt,pdf,php -q -o $outdir/gobuster-443.txt &

echo "[nmap] 1/3 full port scan (all 65535, open only)..."
nmap -p- --open -T4 -Pn -oG $outdir/nmap-ports.grep $tip >/dev/null

# pull open ports out of the greppable output -> "22,80,443"
set -l ports (grep -oE '[0-9]+/open' $outdir/nmap-ports.grep \
    | string replace '/open' '' | string join ,)

if test -z "$ports"
    echo "[nmap] no open ports found - skipping service/vuln scans."
else
    echo "[nmap] open ports: $ports"
    echo "[nmap] 2/3 service + default-script scan on found ports..."
    nmap -sV -sC -Pn -p $ports \
        -oN $outdir/nmap-services.txt \
        -oG $outdir/nmap-services.grep $tip >/dev/null

    echo "[nmap] 3/3 vuln scan on found services..."
    nmap -sV -Pn --script vuln -p $ports \
        -oN $outdir/nmap-vuln.txt \
        -oG $outdir/nmap-vuln.grep $tip >/dev/null
    echo "[nmap] done -> $outdir/nmap-*.txt"
end

echo
echo "nmap chain done; waiting for gobuster to finish..."
wait
echo "All scans complete. Results in $outdir/"
