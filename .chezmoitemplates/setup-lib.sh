set -euo pipefail

src={{ .chezmoi.sourceDir | quote }}

# put MODE PATH: copy system/PATH to /PATH
put() {
    sudo install -Dm "$1" "$src/system$2" "$2"
}
