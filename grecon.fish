#!/usr/bin/env fish
argparse h/help nmap -- $argv
or exit 1
if set -q _flag_help
    echo "Usage: grecon [--nmap]"
    echo "  --nmap   use nmap instead of rustscan for the full port sweep"
    exit 0
end

# full port sweep: rustscan by default, nmap with --nmap or if rustscan is missing
set -l sweeper rustscan
if set -q _flag_nmap
    set sweeper nmap
else if not command -q rustscan
    echo "rustscan not found - falling back to nmap for the full port sweep."
    set sweeper nmap
end

read -P "Target IP: " target
if test -z "$target"
    echo "No target IP given. Aborting."
    exit 1
end
set -U tip $target

# fresh random workdir per box under ~/grecon/ (old ones are kept)
mkdir -p $HOME/grecon
and set -l newdir (mktemp -d $HOME/grecon/XXXXXXXX)
and set -U gdir $newdir
or begin
    echo "Could not create a workdir in $HOME/grecon. Aborting."
    exit 1
end
cd $gdir
echo "Workdir: $gdir  (in your shell: cd \$gdir)"

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

set -l ports
if test $sweeper = rustscan
    echo "[rustscan] 1/3 full port scan (all 65535)..."
    rustscan -a $tip -r 1-65535 --ulimit 5000 -g >$outdir/rustscan-ports.txt 2>/dev/null
    # greppable output: "10.10.11.5 -> [22,80,443]" -> "22,80,443"
    set ports (string match -rg '\[([0-9,]+)\]' <$outdir/rustscan-ports.txt | string join ,)
else
    echo "[nmap] 1/3 full port scan (all 65535, open only)..."
    nmap -p- --open -T4 -Pn -oG $outdir/nmap-ports.grep $tip >/dev/null
    # pull open ports out of the greppable output -> "22,80,443"
    set ports (grep -oE '[0-9]+/open' $outdir/nmap-ports.grep \
        | string replace '/open' '' | string join ,)
end

if test -z "$ports"
    echo "[$sweeper] no open ports found - skipping service/vuln scans."
else
    echo "[$sweeper] open ports: $ports"
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
echo "All scans complete. Results in $gdir/output/"

# put "cd <workdir>" on the clipboard so the user can just paste it
set -l cdcmd "cd $gdir"
set -l copied 0
if set -q WAYLAND_DISPLAY; and command -q wl-copy
    printf '%s' $cdcmd | wl-copy; and set copied 1
else if command -q xclip
    printf '%s' $cdcmd | xclip -selection clipboard; and set copied 1
else if command -q xsel
    printf '%s' $cdcmd | xsel --clipboard --input; and set copied 1
end
if test $copied -eq 1
    echo "Copied to clipboard: $cdcmd  (paste + Enter to jump there)"
else
    echo "No clipboard tool found (wl-copy/xclip/xsel). Run: $cdcmd"
end

