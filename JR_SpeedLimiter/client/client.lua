local mphToMS = 0.44704
local hasBypass = false
local syncedWhitelist = {}
local lastVehicle = nil
local lastSpeed = nil

-- Debug print using red color
local function debugPrint(msg)
    if Config.Debug then
        print("^1[JR_SpeedLimiter DEBUG]^7 " .. tostring(msg))
    end
end

-- Apply or update vehicle speed limiter
local function applyOrRemoveLimit()
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) then
        lastVehicle, lastSpeed = nil, nil
        return
    end

    local veh = GetVehiclePedIsIn(ped, false)
    if GetPedInVehicleSeat(veh, -1) ~= ped then return end

    local model = GetEntityModel(veh)
    local spawnCode = string.upper(GetDisplayNameFromVehicleModel(model))
    local class = GetVehicleClass(veh)

    -- Skip reapplying unless vehicle changes
    if veh == lastVehicle then return end

    if hasBypass then
        debugPrint("Bypass active – limiter not applied.")
        lastVehicle, lastSpeed = veh, nil
        return
    end

    local targetSpeed = nil

    if syncedWhitelist[spawnCode] then
        targetSpeed = syncedWhitelist[spawnCode]
        debugPrint(("Applied custom speed for %s: %d MPH"):format(spawnCode, targetSpeed))
    else
        targetSpeed = Config.SpeedLimits[class]
        if targetSpeed then
            debugPrint(("Applied fallback speed for class %d: %d MPH"):format(class, targetSpeed))
        else
            debugPrint("No speed limit found for vehicle or class.")
            lastVehicle, lastSpeed = veh, nil
            return
        end
    end

    SetVehicleMaxSpeed(veh, targetSpeed * mphToMS)

    lastVehicle, lastSpeed = veh, targetSpeed
end

-- Periodic check every second
CreateThread(function()
    while true do
        applyOrRemoveLimit()
        Wait(1000)
    end
end)

-- Sync whitelist from server
RegisterNetEvent('jr_speedlimiter:syncWhitelist', function(data)
    syncedWhitelist = data
    debugPrint("Received updated whitelist from server.")
    lastVehicle, lastSpeed = nil, nil -- force reapply on next tick
end)

-- Toggle bypass result
RegisterNetEvent('jr_speedlimiter:toggleBypass', function(state)
    hasBypass = state
    lib.notify({
        title = 'Speed Limiter',
        description = state and 'Speed limiter bypass ENABLED.' or 'Speed limiter bypass DISABLED.',
        type = state and 'success' or 'error',
        position = 'top'
    })
    debugPrint("Bypass toggled: " .. tostring(state))
    lastVehicle, lastSpeed = nil, nil
end)

-- Show ox_lib context menu
RegisterNetEvent('ox_lib:showContextMenu', function(data)
    lib.registerContext(data)
    lib.showContext(data.id)
end)

-- /speedbypass
RegisterCommand('speedbypass', function()
    debugPrint("Command executed: /speedbypass")
    TriggerServerEvent('jr_speedlimiter:toggleBypass')
end)

-- /addwhitelist
RegisterCommand('addwhitelist', function()
    debugPrint("Command executed: /addwhitelist")

    local input = lib.inputDialog('Add Vehicle to Whitelist', {
        {type = 'input', label = 'Vehicle Spawn Code', name = 'spawncode', required = true},
        {type = 'number', label = 'Max Speed (MPH)', name = 'speed', required = true, min = 1}
    })

    if input then
        debugPrint("Sending to server: " .. json.encode(input))
        TriggerServerEvent('jr_speedlimiter:addWhitelist', input)
    else
        debugPrint("Input cancelled or empty (add).")
    end
end)

-- /removewhitelist
RegisterCommand('removewhitelist', function()
    debugPrint("Command executed: /removewhitelist")

    local input = lib.inputDialog('Remove Vehicle from Whitelist', {
        {type = 'input', label = 'Vehicle Spawn Code', name = 'spawncode', required = true}
    })

    if input then
        debugPrint("Sending to server: " .. json.encode(input))
        TriggerServerEvent('jr_speedlimiter:removeWhitelist', input)
    else
        debugPrint("Input cancelled or empty (remove).")
    end
end)

-- Export to change speed limit per class
exports("SetSpeedLimit", function(classId, mph)
    Config.SpeedLimits[classId] = mph
    debugPrint(("Speed limit updated for class %d: %d MPH"):format(classId, mph))
    lastVehicle, lastSpeed = nil, nil
end)