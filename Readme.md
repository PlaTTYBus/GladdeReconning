> **Gladde Reconning** — recon sweep

Prompts for the target IP and your interface, saves them as
universal variables (`tip` / `mip`, available in every fish terminal), then runs
a port scan chain and two gobuster scans in parallel.

The full port sweep uses rustscan; the service and vuln scans on the open ports
use nmap.

## Run it

```fish
grecon          # full port sweep with rustscan
grecon --nmap   # full port sweep with nmap instead
```

If rustscan isn't installed, the script falls back to nmap automatically.

## Install
This will install the script as a symlink so that `git pull` keeps it updated:

```fish
ln -sf (realpath grecon.fish) ~/.local/bin/grecon
```

## Output

Each run creates a new random workdir `~/grecon/XXXXXXXX` and points the
universal variable `gdir` at it. Old workdirs are never deleted, so clean up
`~/grecon/` yourself when you're done with a box. Outputs land in
`$gdir/output/`, in greppable format where the tool supports it.

When the scans finish, it copies `cd <workdir>` to your clipboard
(via `wl-copy`, `xclip` or `xsel`, depending on the environment), so you can paste and press Enter. Otherwise
run:

```fish
cd $gdir
```

## Requirements

`nmap`, `gobuster`, and the `/usr/share/wordlists/dirb/big.txt` wordlist, which are all pre-installed on kali linux.

\* `rustscan` (optional): used for the full port sweep. Without it, or with
`--nmap`, nmap does the sweep instead.
