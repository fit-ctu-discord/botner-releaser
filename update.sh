#!/bin/sh

RED='\e[1;31m'
YELLOW='\e[1;33m'
GREEN='\e[1;32m'
NC='\e[0m' # No Color

BOT_LOCATION="/home/bot/app"

function info {
    printf "${GREEN}INFO${NC}>  $1\n"
}

function warn {
    printf "${YELLOW}WARN${NC}>  $1\n"
}

function error {
    printf "${RED}ERROR${NC}> $1\n"
}

function checkResult {
    if [ $1 -ne 0 ]; then 
        error "$2"; 
        rm -rf botner.tar.gz
        rm -rf botner-linux-musl-x64
        /etc/init.d/botner start # try it...

        error "Aborting."

        exit 1
    fi
}

info "Starting updating Honza Botner..."

version="${1:-"latest"}"

if [ "latest" == "$version" ]; then
    info "Downloading latest version of Botner"
    wget https://github.com/fit-ctu-discord/honza-botner/releases/latest/download/botner-linux-musl-x64.tar.gz -O "botner.tar.gz" 1&>/dev/null 2&>/dev/null
else
    info "Downloading version $version of Botner"
    wget https://github.coam/fit-ctu-discord/honza-botner/releases/download/v2022.2/botner-linux-musl-x64.tar.gz -O "botner.tar.gz" 1&>/dev/null 2&>/dev/null
fi

checkResult $? "Couldnt download Botner (version: $version)"; 

info "Binaries downloaded"

mkdir -p "bot_binaries"
tar xzf "botner.tar.gz" -C "bot_binaries"
checkResult $? "Couldnt extract binaries"

/etc/init.d/botner stop
checkResult $? "Couldnt stop service"
info "Stoped bot service"

rm -rf "$BOT_LOCATION.bkp"
checkResult $? "Couldnt remove old backup"

mv "$BOT_LOCATION" "$BOT_LOCATION.bkp" # backup old version
checkResult $? "Couldnt make new backup"

info "Backuped old files"

cp -R "./bot_binaries/botner-linux-musl-x64" "$BOT_LOCATION"
checkResult $? "Couldnt move binnaries"
info "Copied over new binnaries"

/etc/init.d/botner start
checkResult $? "Couldnt start service"
info "Started service"
