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
cp ./grecon.fish ~/.local/bin/grecon  
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
