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

Each run creates a fresh random workdir `/tmp/grecon.XXXXXXXX`, saved as the
universal variable `gdir`, and removes the previous run's workdir. Outputs
land in `$gdir/output/`, in greppable format where the tool supports it.

Because the script runs as its own process, it can't change your shell's
directory. When the scans finish, it copies `cd <workdir>` to your clipboard
(via `wl-copy`, `xclip` or `xsel`), so you can paste and press Enter. Otherwise
run:

```fish
cd $gdir
```

## Requirements

`nmap`, `gobuster`, and the `/usr/share/wordlists/dirb/big.txt` wordlist.
