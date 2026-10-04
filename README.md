# dotfiles-cachyos

Config for the couch gaming PC (CachyOS, gamescope session). macOS dotfiles live in
[kovapatrik/dotfiles](https://github.com/kovapatrik/dotfiles).

## Setup
```sh
sudo pacman -S --needed chezmoi
chezmoi init --apply kovapatrik/dotfiles-cachyos
```
`chezmoi init` asks for the LAN subnet and the Homebridge details (kept locally in
`~/.config/chezmoi/chezmoi.toml`, not in this repo).

## Layout
| Path | What |
| --- | --- |
| `packages.txt` | Packages installed from the repos |
| `system/` | Files copied to `/` (e.g. `system/etc/xbindkeysrc` → `/etc/xbindkeysrc`) |
| `dot_config/hermes/` | Hermes streaming config → `~/.config/hermes/` |
| `.chezmoitemplates/pc-tv.conf` | `/etc/pc-tv.conf`, filled in from the Homebridge prompts |
| `.chezmoiscripts/run_onchange_after_setup.sh.tmpl` | Installs everything above; re-runs when any of it changes |

## What it sets up
- **Hermes** streaming (release package + Hermes-KMS driver built from source)
- **Homebridge**: `pc-power` SSH user that can only suspend/poweroff; TV on/off webhook on boot, suspend, resume, shutdown
- **Wake-on-LAN** (also enable it in the BIOS) and **Bluetooth controller wakeup**
- **RGB off** at boot (OpenRGB)
- **Ctrl+Alt+D** in the gamescope session switches to Plasma
- **ufw**: Tailscale, plus streaming and SSH from the LAN only

## Manual steps after a reinstall
- `sudo tailscale up --login-server=<headscale URL> --ssh`
- Re-pair Moonlight clients with Hermes
