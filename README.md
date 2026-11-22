# dotfiles-cachyos

Config for the couch gaming PC (CachyOS, gamescope session). macOS dotfiles live in
[kovapatrik/dotfiles](https://github.com/kovapatrik/dotfiles).

## Setup
```sh
sudo pacman -S --needed chezmoi
chezmoi init --apply kovapatrik/dotfiles-cachyos
```
`chezmoi init` asks for the LAN subnet, where to report TV on/off (`tvTarget`), that target's
webhook details and the (optional) Homebridge / Home Assistant SSH keys for `pc-power` (kept
locally in `~/.config/chezmoi/chezmoi.toml`, not in this repo).

### Switching the TV webhook between Home Assistant and Homebridge
```sh
chezmoi edit-config   # set tvTarget = "homeassistant" or "homebridge"
chezmoi init          # prompts only for the new target's details if they are missing
chezmoi apply         # re-renders /etc/pc-tv.conf
```
The other target's details stay in the config, so switching back asks nothing.

## Layout
| Path | What |
| --- | --- |
| `packages.txt` | Packages installed from the repos |
| `system/` | Files copied to `/` (e.g. `system/etc/xbindkeysrc` → `/etc/xbindkeysrc`) |
| `dot_config/hermes/` | Hermes streaming config → `~/.config/hermes/` |
| `.chezmoitemplates/pc-tv.conf` | `/etc/pc-tv.conf`: `tvTarget` plus that target's webhook details |
| `.chezmoiscripts/run_onchange_after_setup.sh.tmpl` | Installs everything above; re-runs when any of it changes |

## What it sets up
- **Hermes** streaming (release package + Hermes-KMS driver built from source)
- **TV on/off webhook** on boot, suspend, resume, shutdown, to either target (`tvTarget`):
  Home Assistant (`{"state":"on"|"off"}` to an automation webhook) or Homebridge (Dummy
  button: single press = on, double press = off)
- **`pc-power` SSH user** that can only suspend/poweroff, accepting Homebridge's and/or Home
  Assistant's key (independent of `tvTarget`) - used by their Wake-on-LAN switches to put the PC to sleep
- **Wake-on-LAN** (also enable it in the BIOS) and **Bluetooth controller wakeup**
- **RGB off** at boot (OpenRGB)
- **Ctrl+Alt+D** in the gamescope session switches to Plasma
- **ufw**: Tailscale, plus streaming and SSH from the LAN only

## Manual steps after a reinstall
- `sudo tailscale up --login-server=<headscale URL> --ssh`
- Re-pair Moonlight clients with Hermes
