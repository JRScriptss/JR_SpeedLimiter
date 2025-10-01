local ESX = exports['es_extended']:getSharedObject()
local whitelist = {}

-- Load whitelist from DB
local function loadWhitelist()
    MySQL.Async.fetchAll('SELECT * FROM JR_SpeedLimitWhitelist', {}, function(results)
        whitelist = {}
        for _, row in pairs(results) do
            whitelist[row.spawncode] = row.speed
        end
        --print(('^2[JR_SpeedLimiter]^7 Loaded ^3%s^7 whitelisted vehicles from DB.'):format(#results))
        TriggerClientEvent('jr_speedlimiter:syncWhitelist', -1, whitelist)
    end)
end

-- Send whitelist to single player
local function sendWhitelistToPlayer(src)
    TriggerClientEvent('jr_speedlimiter:syncWhitelist', src, whitelist)
end

-- Add vehicle to whitelist
RegisterNetEvent('jr_speedlimiter:addWhitelist', function(data)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer or not Config.AdminGroups[xPlayer.getGroup()] then return end

    local spawncode = data[1]
    local speed = tonumber(data[2])
    if not spawncode or not speed then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Speed Limiter',
            description = 'Invalid input.',
            type = 'error',
            position = 'top'
        })
        return
    end

    spawncode = string.upper(spawncode)

    MySQL.Async.execute('REPLACE INTO JR_SpeedLimitWhitelist (spawncode, speed) VALUES (?, ?)', {
        spawncode,
        speed
    }, function()
        whitelist[spawncode] = speed
        TriggerClientEvent('jr_speedlimiter:syncWhitelist', -1, whitelist)

        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Speed Limiter',
            description = ('%s added to whitelist at %d MPH.'):format(spawncode, speed),
            type = 'success',
            position = 'top'
        })

        print(('^2[JR_SpeedLimiter]^7 %s added to whitelist at %d MPH by ^3%s^7'):format(spawncode, speed, GetPlayerName(src)))
    end)
end)

-- Remove vehicle from whitelist
RegisterNetEvent('jr_speedlimiter:removeWhitelist', function(data)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer or not Config.AdminGroups[xPlayer.getGroup()] then return end

    local spawncode = data[1]
    if not spawncode then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Speed Limiter',
            description = 'No spawn code provided.',
            type = 'error',
            position = 'top'
        })
        return
    end

    spawncode = string.upper(spawncode)

    MySQL.Async.execute('DELETE FROM JR_SpeedLimitWhitelist WHERE spawncode = ?', {
        spawncode
    }, function()
        whitelist[spawncode] = nil
        TriggerClientEvent('jr_speedlimiter:syncWhitelist', -1, whitelist)

        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Speed Limiter',
            description = ('%s removed from whitelist.'):format(spawncode),
            type = 'inform',
            position = 'top'
        })

        print(('^1[JR_SpeedLimiter]^7 %s removed from whitelist by ^3%s^7'):format(spawncode, GetPlayerName(src)))
    end)
end)

-- Toggle limiter bypass
RegisterNetEvent('jr_speedlimiter:toggleBypass', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer or not Config.AdminGroups[xPlayer.getGroup()] then return end

    TriggerClientEvent('jr_speedlimiter:toggleBypass', src, true)
end)

-- /refreshwhitelist command
RegisterCommand('refreshwhitelist', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or not Config.AdminGroups[xPlayer.getGroup()] then return end

    loadWhitelist()

    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Speed Limiter',
        description = 'Whitelist reloaded from database.',
        type = 'success',
        position = 'top'
    })
end)

-- /whitelistlist command
RegisterCommand('whitelistlist', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    local job = xPlayer.getJob().name
    local group = xPlayer.getGroup()

    -- Check if player has permission via admin group OR job
    if not Config.AdminGroups[group] and not Config.Jobs[job] then
        return
    end

    local entries = {}

    for spawncode, speed in pairs(whitelist) do
        table.insert(entries, {
            title = spawncode,
            description = ('Max Speed: %d MPH'):format(speed)
        })
    end

    if #entries == 0 then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Speed Limiter',
            description = 'Whitelist is empty.',
            type = 'inform',
            position = 'top'
        })
        return
    end

    TriggerClientEvent('ox_lib:showContextMenu', source, {
        id = 'whitelist_menu',
        title = 'Whitelisted Vehicles',
        options = entries
    })
end)

-- Load DB when resource starts
AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        CreateThread(function()
            Wait(1000) -- wait 1 second to let DB & ESX initialize
            loadWhitelist()
            print("^2[JR_SpeedLimiter]^7 Whitelist loaded after startup delay.")
        end)
    end
end)

-- Automatically refresh whitelist every 30 seconds
CreateThread(function()
    while true do
        Wait(30000) -- 30 seconds
        loadWhitelist()
        --print('^3[JR_SpeedLimiter]^7 Whitelist auto-refreshed.')
    end
end)
