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
| `.chezmoidata/packages.yaml` | Packages installed from the repos (`packages.pacman`) |
| `system/` | Files copied to `/` (e.g. `system/etc/xbindkeysrc` → `/etc/xbindkeysrc`) |
| `dot_config/hermes/` | Hermes streaming config → `~/.config/hermes/` |
| `.chezmoitemplates/pc-tv.conf` | `/etc/pc-tv.conf`: `tvTarget` plus that target's webhook details |
| `.chezmoitemplates/setup-lib.sh` | Shared header of the setup scripts (`set -euo pipefail`, `put`) |
| `.chezmoiscripts/run_onchange_after_NN-*.sh.tmpl` | One setup script per area, run in `NN` order; each re-runs only when the files hashed in its header (or its config values) change |

### Setup scripts
| Script | What |
| --- | --- |
| `install-packages` (`run_onchange_before_`, runs first) | `packages.pacman` from `.chezmoidata/packages.yaml` |
| `20-hermes` | Hermes release package + Hermes-KMS (built from source), only when missing; evdi modprobe config; `hermes.service` |
| `30-pc-power` | `pc-power` SSH user, its keys, sudoers; key-only sshd |
| `40-pc-tv` | `pc-tv-notify`, `/etc/pc-tv.conf` and the boot/suspend/resume units |
| `50-rgb-off` | RGB off at boot |
| `60-wakeup` | Wake-on-LAN on every ethernet connection; Bluetooth adapter wakeup udev rule |
| `70-keybind` | Ctrl+Alt+D gamescope -> Plasma |
| `80-network` | Tailscale, ufw rules |

A file under `system/` is only installed if a script `put`s it - add new ones to the matching
script and hash them in its header.

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
