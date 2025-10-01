fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'JRScripts'
description 'JRScripts Speed Limiter with Class-based MPH caps, Whitelist, SQL Support, and Admin Controls'
version '1.0.0'

-- Dependencies
dependency 'es_extended'
dependency 'ox_lib'
dependency 'mysql-async' -- or 'oxmysql' depending on your setup

-- Shared configuration
shared_script 'config.lua'

-- Client-side logic
client_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'client/client.lua'
}

-- Server-side logic
server_scripts {
    '@mysql-async/lib/MySQL.lua', -- or '@oxmysql/lib/MySQL.lua' if using oxmysql
    '@es_extended/locale.lua',
    'server/server.lua'
}
