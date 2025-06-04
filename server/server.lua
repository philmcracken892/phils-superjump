local RSGCore = exports['rsg-core']:GetCoreObject()

RSGCore.Functions.CreateUseableItem('jumptonic', function(source, item)
    local Player = RSGCore.Functions.GetPlayer(source)
    if not Player then return end
    
    if Player.PlayerData.metadata.highjump_active then
        TriggerClientEvent('ox_lib:notify', source, Config.JumpTonic.notifications.alreadyActive)
        return
    end
    
    print("Server: Activating high jump for player " .. source)
    Player.Functions.RemoveItem('jumptonic', 1)
    TriggerClientEvent('inventory:client:ItemBox', source, RSGCore.Shared.Items['jumptonic'], 'remove')
    
    Player.Functions.SetMetaData('highjump_active', true)
    TriggerClientEvent('highjump:client:activate', source)
    
    local activatedNotification = Config.JumpTonic.notifications.activated
    activatedNotification.description = "High jump activated! Effect lasts 15 seconds "
    TriggerClientEvent('ox_lib:notify', source, activatedNotification)
    
    SetTimeout(Config.JumpTonic.duration, function()
        local UpdatedPlayer = RSGCore.Functions.GetPlayer(source)
        if UpdatedPlayer and UpdatedPlayer.PlayerData.metadata.highjump_active then
            
            UpdatedPlayer.Functions.SetMetaData('highjump_active', false)
            TriggerClientEvent('highjump:client:deactivate', source)
            TriggerClientEvent('ox_lib:notify', source, Config.JumpTonic.notifications.wornOff)
        end
    end)
end)

RegisterNetEvent('RSGCore:Server:PlayerUnload', function(playerId)
    local Player = RSGCore.Functions.GetPlayer(playerId)
    if Player and Player.PlayerData.metadata.highjump_active then
        
        Player.Functions.SetMetaData('highjump_active', false)
    end
end)

RegisterNetEvent('RSGCore:Server:OnPlayerLoaded', function()
    local Player = RSGCore.Functions.GetPlayer(source)
    if Player and Player.PlayerData.metadata.highjump_active then
       
        Player.Functions.SetMetaData('highjump_active', false)
    end
end)



RegisterNetEvent('highjump:server:resetMetadata', function()
    local Player = RSGCore.Functions.GetPlayer(source)
    if Player and Player.PlayerData.metadata.highjump_active then
        
        Player.Functions.SetMetaData('highjump_active', false)
    end
end)


AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        print("Server: Resetting highjump_active metadata for all players")
        local Players = RSGCore.Functions.GetPlayers()
        for _, playerId in ipairs(Players) do
            local Player = RSGCore.Functions.GetPlayer(playerId)
            if Player and Player.PlayerData.metadata.highjump_active then
                Player.Functions.SetMetaData('highjump_active', false)
            end
        end
    end
end)