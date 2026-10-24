> **Gladde Reconning** — recon sweep

Prompts for the target IP and your interface, saves them as
universal variables (`tip` / `mip`, available in every fish terminal), then runs
an nmap chain and two gobuster scans in parallel.

## Run it

```fish
fish grecon.fish
```

## Or install as a global `grecon` command

```fish
chmod +x grecon.fish
ln -s (realpath grecon.fish) ~/.local/bin/grecon   # ~/.local/bin must be on PATH
grecon
```

## Output

Outputs land in `./output/` (relative to the current directory), greppable where
the tool allows.

## Requirements

`nmap`, `gobuster`, and the `/usr/share/wordlists/dirb/big.txt` wordlist.
