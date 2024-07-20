fx_version 'cerulean'
game 'gta5'

author 'Superstar' -- superstar_.
description 'Shop Robbery'
version '1.0.0'
lua54 'yes'

client_script {
    'client/main.lua'
}

server_script {
    'server/main.lua',
    'LogConfig.lua'
}

shared_script {
    'config.lua',
    '@ox_lib/init.lua'
}

dependencies {
    'ox_lib',
    'oxmysql',
    'es_extended'
}