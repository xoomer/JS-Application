fx_version 'cerulean'
game 'gta5'

author 'Your Name'
description 'Advanced Queue System with Discord Integration & Web Authentication'
version '1.0.0'

server_scripts {
    'config.lua',
    'server.lua'
}

client_scripts {
    'client.lua'
}

dependencies {
    '/server:5848',
    '/onesync'
}
