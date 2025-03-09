fx_version "cerulean"
game "gta5"
lua54 "yes"

name "mnr_monitor"
description "Player Monitor Dependency for Monarch Development scripts"
author "IlMelons"
version "1.0.0"
repository "https://github.com/Monarch-Development/mnr_monitor"

shared_scripts {
    "@ox_lib/init.lua",
}

client_scripts {
    "client/*.lua",
}

server_scripts {
    "checker.lua",
}