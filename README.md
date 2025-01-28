# LynxCrew Nozzle-Wipe Macros

## Install:
SSH into you pi and run:
```
cd ~
wget -O - https://raw.githubusercontent.com/LynxCrew/Nozzle-Wipe/main/install.sh | bash
```

then add this to your moonraker.conf:
```
[update_manager nozzle-wipe]
type: git_repo
channel: dev
path: ~/nozzle-wipe
origin: https://github.com/LynxCrew/Nozzle-Wipe.git
managed_services: klipper
primary_branch: main
install_script: install.sh
```

then add `[include Nozzle-Wipe/_.include]` and `[include Variables/nozzle_wipe_variables.cfg]` to your printer.cfg.
