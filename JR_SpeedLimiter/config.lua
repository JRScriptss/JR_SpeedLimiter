Config = {}

Config.Debug = false -- set to false to silence debugPrint()

-- Speed limits per vehicle class (in MPH)
-- Class IDs: https://docs.fivem.net/natives/?_0x29439776AAA00A62
Config.SpeedLimits = {
    [0] = 160,    -- Compacts
    [1] = 160,   -- Sedans
    [2] = 160,   -- SUVs
    [3] = 160,   -- Coupes
    [4] = 160,   -- Muscle
    [5] = 175,   -- Sports Classics
    [6] = 175,   -- Sports
    [7] = 175,   -- Super
    [8] = 145,    -- Motorcycles
    [9] = 145,    -- Off-road
    [10] = 170,   -- Industrial
    [11] = 170,   -- Utility
    [12] = 170,   -- Vans
    [13] = 0,    -- Cycles (not used)
    [14] = 90,    -- Boats
    [15] = 170,    -- Helicopters
    [16] = 200,    -- Planes
    [17] = 170,   -- Service
    [18] = 170,    -- Emergency
    [19] = 0,    -- Military
    [20] = 150,    -- Commercial
    [21] = 0     -- Trains
}

-- Admin groups allowed to use speedbypass and manage whitelist
-- Matches ESX groups (e.g., from `users.group` in your database)
Config.AdminGroups = {
    ['admin'] = true,
    ['superadmin'] = true
}

Config.Jobs = {
	['gov'] = true
}