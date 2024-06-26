------------------------------------| Variable Declaration |---------------------------------
local Sperrzonen = {}
local ESX = nil
------------------------------------| Initial ESX |------------------------------------------
if Config.UseOldESX then
    Citizen.CreateThread(function()
        while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
        end
    end)
else
    ESX = exports['es_extended']:getSharedObject()
end
------------------------------------| Usfull Functions |-------------------------------------
local function ImACop()
    local playerdata = ESX.GetPlayerData()
    local rc = false -- returncode

    -- check if player is an Cop
    for k, v in ipairs(Config.PoliceJobs) do
        if v == playerdata.job.name then
            rc = true
            break
        end
    end

    return rc
end
-- check if Sperrzone with server 
local function IsSperrzoneLocalSynced(info)
    for k, v in pairs(Sperrzonen) do
        if v.id == info.id then
            return true
        end
    end
    return false
end

-- notification Handler
function notificationHandler(icon,title,msg,color,sound)
	if Config.Notification.System ~= 'lp_notify' then
		ESX.ShowNotification(title..", "..msg)
	else
		TriggerEvent("lifepeak.notify",icon,title,msg,color,true,Config.Notification.Postion,Config.Notification.displaytime,sound)
	end
end
------------------------------------| Register Net Events |-------------------------------------

RegisterNetEvent('lp_sperrzone:render', function(info)
    if not IsSperrzoneLocalSynced(info) then
        --print("Sperrzone will be created locally")
        SperrzoneBlip = AddBlipForRadius(info.coords.x, info.coords.y, info.coords.z, info.radius+0.0)
        SetBlipHighDetail(SperrzoneBlip, true)
        SetBlipColour(SperrzoneBlip, 75)
        SetBlipAlpha(SperrzoneBlip, 60)

        info.blip = SperrzoneBlip

        table.insert(Sperrzonen, info)
    --else
        --print("Sperrzone will not be created locally, we know it already.")
    end
end)

RegisterNetEvent('lp_sperrzone:expire', function(info)
    if IsSperrzoneLocalSynced(info) then
        for k, v in ipairs(Sperrzonen) do
            if v.id == info.id then
                RemoveBlip(v.blip)
                table.remove(Sperrzonen, k)
            end
        end
    end
end)

RegisterNetEvent('esx:playerLoaded', function(playerData)
    TriggerServerEvent('lp_sperrzone:get_all_sperrzonen')
end)
------------------------------------| Register Commands |-------------------------------------

RegisterCommand(Config.Command, function(source, args, rawCommand)
    
    if not ImACop() then
       
        return
    end
    local radius = tonumber(args[1])
    local length = tonumber(args[2])
    local locationName = args[3]

    if radius == nil then
        notificationHandler("exclamation triangle",_U('require_args'),_U('require_radius'),"red","error.mp3")
        return
    end
    if length == nil then
        notificationHandler("exclamation triangle",_U('require_args'),_U('require_length'),"red","error.mp3")
    return end
    if locationName == nil then
        notificationHandler("exclamation triangle",_U('require_args'),_U('require_location_name'),"red","error.mp3")
        return
    end

    if length > Config.MaxTime then
        print("!A4")
        notificationHandler("exclamation triangle",_U('require_args'),_U('max_lenght',Config.MaxTime),"red","error.mp3")
        return
    end
    if radius > Config.MaxRadius then
        print("!A5")
        notificationHandler("exclamation triangle",_U('require_args'),_U('max_radius',Config.MaxRadius),"red","error.mp3")
        return
    end

    local ped           = PlayerPedId()
    local playerCoords  = GetEntityCoords(ped)

    TriggerServerEvent('lp_sperrzone:create', playerCoords, radius, length, locationName)
end, false)

RegisterCommand(Config.CommandWayPoint, function(source, args, rawCommand)
    if not ImACop() then
        return
    end

    local radius = tonumber(args[1])
    local length = tonumber(args[2])
    local locationName = args[3]

    if radius == nil then
        notificationHandler("exclamation triangle",_U('require_args'),_U('require_radius'),"red","error.mp3")
        return end
    if length == nil then
        notificationHandler("exclamation triangle",_U('require_args'),_U('require_length'),"red","error.mp3")
        return
    end
    if locationName == nil then
        notificationHandler("exclamation triangle",_U('require_args'),_U('require_location_name'),"red","error.mp3")
        return
    end
    if length > Config.MaxTime then
        notificationHandler("exclamation triangle",_U('require_args'),_U('max_lenght',Config.MaxTime),"red","error.mp3")
        return end
    if radius > Config.MaxRadius then
        notificationHandler("exclamation triangle",_U('require_args'),_U('max_radius',Config.MaxRadius),"red","error.mp3")
        return
    end

    local WaypointBlip = GetFirstBlipInfoId( 8 )

    if WaypointBlip ~= 0 then
        local coords = Citizen.InvokeNative( 0xFA7C7F0AADF25D09, WaypointBlip, Citizen.ResultAsVector( ) )
        
        TriggerServerEvent('lp_sperrzone:create', coords, radius, length, locationName)
    else
        notificationHandler("exclamation triangle",_U('require_args'),_U('require_waypoint'),"red","error.mp3")
    end
end, false)

RegisterCommand(Config.CommandRemove, function(source, args, rawCommand)
    if not ImACop() then
        return
    end

    local locationName = args[1]

    if locationName == nil then
        notificationHandler("exclamation triangle",_U('require_args'),_U('require_location_name'),"red","error.mp3")
        return
    end

    for k, v in pairs(Sperrzonen) do
        if v.locationName == locationName then
            TriggerServerEvent('lp_sperrzone:revoke', v)
        end
    end
end, false)

RegisterCommand(Config.CommandRemoveAll, function(source, args, rawCommand)
    if not ImACop() then
        return
    end

    for k, v in pairs(Sperrzonen) do
        TriggerServerEvent('lp_sperrzone:revoke', v)
    end
end, false)
------------------------------------| Chat Suggestion |-------------------------------------
TriggerEvent('chat:addSuggestion', tostring("/".. Config.CommandWayPoint), _U('chat_suggestion_command_waypoint_title',Config.CommandWayPoint), {
    { name = "radius", help = _U('chat_suggestion_command_arg_radius') },
    { name = "length", help = _U('chat_suggestion_command_arg_length') },
    { name = "location", help = _U('chat_suggestion_command_arg_location') }
})
TriggerEvent('chat:addSuggestion', tostring("/".. Config.Command), _U('chat_suggestion_command_sperrzone_title',Config.Command), {
    { name = "radius", help = _U('chat_suggestion_command_arg_radius') },
    { name = "length", help = _U('chat_suggestion_command_arg_length') },
    { name = "location", help = _U('chat_suggestion_command_arg_location') }
})
TriggerEvent('chat:addSuggestion', tostring("/".. Config.CommandRemove), _U('chat_suggestion_command_removesperrzone_title',Config.CommandRemove), {
    { name = "location", help = _U('chat_suggestion_command_arg_location_remove') }
})
TriggerEvent('chat:addSuggestion', tostring("/".. Config.CommandRemoveAll), _U('chat_suggestion_command_arg_location_remove',Config.CommandRemoveAll), {})