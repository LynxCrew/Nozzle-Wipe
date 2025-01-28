#!/bin/bash

CONFIG_PATH="${HOME}/printer_data/config"
REPO_PATH="${HOME}/nozzle-wipe"
VARIABLES=("nozzle_wipe")

set -eu
export LC_ALL=C


function preflight_checks {
    if [ "$EUID" -eq 0 ]; then
        echo "[PRE-CHECK] This script must not be run as root!"
        exit -1
    fi

    if [ "$(sudo systemctl list-units --full -all -t service --no-legend | grep -F 'klipper.service')" ]; then
        printf "[PRE-CHECK] Klipper service found! Continuing...\n\n"
    else
        echo "[ERROR] Klipper service not found, please install Klipper first!"
        exit -1
    fi
}

function check_download {
    local nozzlewipedirname nozzlewipebasename
    nozzlewipedirname="$(dirname ${REPO_PATH})"
    nozzlewipebasename="$(basename ${REPO_PATH})"

    if [ ! -d "${REPO_PATH}" ]; then
        echo "[DOWNLOAD] Downloading Nozzle-Wipe repository..."
        if git -C $nozzlewipedirname clone https://github.com/LynxCrew/Nozzle-Wipe.git $nozzlewipebasename; then
            chmod +x ${REPO_PATH}/install.sh
            chmod +x ${REPO_PATH}/update.sh
            chmod +x ${REPO_PATH}/uninstall.sh
            printf "[DOWNLOAD] Download complete!\n\n"
        else
            echo "[ERROR] Download of Nozzle-Wipe git repository failed!"
            exit -1
        fi
    else
        printf "[DOWNLOAD] Nozzle-Wipe repository already found locally. Continuing...\n\n"
    fi
}

function link_extension {
    echo "[INSTALL] Linking extension to Klipper..."
    
    if [ -d "${CONFIG_PATH}/Nozzle-Wipe" ]; then
        chmod -R 777 "${CONFIG_PATH}/Nozzle-Wipe"
        rm -R "${CONFIG_PATH}/Nozzle-Wipe"
    fi

    cp -rf "${REPO_PATH}/Nozzle-Wipe" "${CONFIG_PATH}/Nozzle-Wipe"
    chmod 755 "${CONFIG_PATH}/Nozzle-Wipe"
    for FILE in "${CONFIG_PATH}/Nozzle-Wipe/*"; do
        chmod 644 $FILE
    done


    mkdir -p "${CONFIG_PATH}/Overrides"
    for OVERRIDE in ${OVERRIDES[@]}; do
        if [ -f "${CONFIG_PATH}/Overrides/override_${OVERRIDE}.cfg" ]; then
            chmod -R 777 "${CONFIG_PATH}/Overrides/override_${OVERRIDE}.cfg"
            rm -R "${CONFIG_PATH}/Overrides/override_${OVERRIDE}.cfg"
        fi
        cp -rf "${REPO_PATH}/Overrides/override_${OVERRIDE}.cfg" "${CONFIG_PATH}/Overrides/override_${OVERRIDE}.cfg"
    done
    
    chmod 755 "${CONFIG_PATH}/Overrides"
    for FILE in "${CONFIG_PATH}/Overrides/*"; do
        chmod 644 $FILE
    done


    mkdir -p "${CONFIG_PATH}/Variables"
    for VARIABLE in ${VARIABLES[@]}; do
        if [ ! -f "${CONFIG_PATH}/Variables/${VARIABLE}_variables.cfg" ]; then
            cp -f "${REPO_PATH}/Variables/${VARIABLE}_variables.cfg" "${CONFIG_PATH}/Variables/${VARIABLE}_variables.cfg"
        else
            echo "${VARIABLE}-variables file already exists"
        fi
    done

    chmod 755 "${CONFIG_PATH}/Variables"
    for FILE in "${CONFIG_PATH}/Variables/*"; do
        chmod 644 $FILE
    done
}

function restart_klipper {
    echo "[POST-INSTALL] Restarting Klipper..."
    sudo systemctl restart klipper
}


printf "\n======================================\n"
echo "- Nozzle-Wipe install script -"
printf "======================================\n\n"


# Run steps
preflight_checks
check_download
link_extension
restart_klipper
