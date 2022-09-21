------------------------------------| Variable Declaration |---------------------------------

local ESX = nil
local Sperrzonen = {}
local Id         = 0 -- unique Sperrzone Id
------------------------------------| Initial ESX |------------------------------------------
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
------------------------------------| Usfull Functions |-------------------------------------

local function IsJobPoliceJob(job)
    local returncode = false -- returncode
    -- check if players job is Config
    for k, v in ipairs(Config.PoliceJobs) do
        if v == job then
            returncode = true
            break
        end
    end
    return returncode
end

local function IsACopInTheSperrzone(info)
    local xPlayers = ESX.GetPlayers()
    -- check if Any Player with require job in sperrzone
    for k, v in pairs(xPlayers) do
        local xPlayer = ESX.GetPlayerFromId(v)
        if IsJobPoliceJob(xPlayer.job.name) then
            local ped = GetPlayerPed(xPlayer.source)
            local playerHealth = GetEntityHealth(ped)
            if playerHealth > 0 then
                local playerCoords = GetEntityCoords(ped)
                local distance = #(playerCoords.xy - info.coords.xy)
                --print("Policeman " .. xPlayer.source .. " is " .. distance .. "u far away, checking against " .. info.radius)
                if distance <= info.radius then
                    return true
                end
            end
        end
    end
    return false
end

local function CreateSperrzone(player, coords, radius, length, locationName)
    Id = Id + 1

    local zoneInfo = {
        id        = Id,
        player    = player.identifier,
        coords    = coords,
        radius    = radius,
        length    = length,
        locationName = locationName,
        createdAt = os.time()
    }

    Sperrzonen[Id] = zoneInfo

    TriggerClientEvent('lp_sperrzone:render', -1, zoneInfo) --render new zone for all players
    TriggerClientEvent('esx:showAdvancedNotification', -1, _U('showAdvancedNotification_sender'), _U('showAdvancedNotification_subject'), _U('showAdvancedNotification_msg_new_sperrzone',locationName,radius), Config.NotificationPicture, 1, true)
end

local function RevokeSperrzone(info)
    Sperrzonen[info.id] = nil

    TriggerClientEvent('esx:showAdvancedNotification', -1, _U('showAdvancedNotification_sender'), _U('showAdvancedNotification_subject'), _U('showAdvancedNotification_msg_revoke_sperrzone',info.locationName), Config.NotificationPicture, 1)
    TriggerClientEvent('lp_sperrzone:expire', -1, info) -- send expire signal to all clients
end
------------------------------------|   Open Threads |-------------------------------------
Citizen.CreateThread(function()
    while true do
    -- loop through all Zones to revoke them at the expire time
        for k, v in pairs(Sperrzonen) do
            if v.createdAt + v.length < os.time() then
            -- renew zone if Cop is inside
                if IsACopInTheSperrzone(v) then
                    v.createdAt = os.time()
                    -- if commented out, it will be renewed with the same length it was initially created.
                    --v.length = 5 * 60

                    TriggerClientEvent('esx:showAdvancedNotification', -1, _U('showAdvancedNotification_sender'), _U('showAdvancedNotification_subject'),_U('showAdvancedNotification_msg_new_sperrzone',v.locationName,v.radius), Config.NotificationPicture, 1, true)
                else
                    --print("Sperrzone " .. v.id .. " expired after " .. v.length .. " seconds (created at " .. v.createdAt .. ", we have " .. os.time() .. ").")
                    RevokeSperrzone(v)
                end
            end
        end

        Citizen.Wait(1000)
    end
end)

------------------------------------| Register Net Events |-------------------------------------

RegisterServerEvent('lp_sperrzone:create', function(coords, radius, length, locationName)
    local xPlayer = ESX.GetPlayerFromId(source)

    CreateSperrzone(xPlayer, coords, radius, length, locationName)
end)

RegisterServerEvent('lp_sperrzone:revoke', function(info)
    RevokeSperrzone(info)
end)

RegisterServerEvent('lp_sperrzone:get_all_sperrzonen', function()
    for k, v in pairs(Sperrzonen) do
        TriggerClientEvent('lp_sperrzone:render', source, v)
    end
end)