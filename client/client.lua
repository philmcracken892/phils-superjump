local RSGCore = exports['rsg-core']:GetCoreObject()
local lib = exports.ox_lib
local isHighJumpActive = false
local isBusy = false
local itemInHand = nil

RegisterNetEvent('highjump:client:activate', function()
    if isBusy then return end
    if isHighJumpActive then
        lib:notify(Config.JumpTonic.notifications.alreadyActive)
        return
    end
    
    isBusy = true
    LocalPlayer.state:set("inv_busy", true, true)
    ExecuteCommand('closeInv')
    
    local ped = cache.ped or PlayerPedId()
    SetCurrentPedWeapon(ped, GetHashKey("weapon_unarmed"))
    local pcoords = GetEntityCoords(ped)
    
    itemInHand = CreateObject(GetHashKey("p_bottleJD01x"), pcoords.x, pcoords.y, pcoords.z, true, false, false)
    AttachEntityToEntity(itemInHand, ped, GetEntityBoneIndexByName(ped, "PH_R_HAND"), 0.00, 0.00, 0.04, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
    
    if not IsPedOnMount(ped) and not IsPedInAnyVehicle(ped) and not IsPedUsingAnyScenario(ped) then
        local dict = 'mech_inventory@drinking@bottle_cylinder_d1-3_h30-5_neck_a13_b2-5'
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(10)
        end
        TaskPlayAnim(ped, dict, 'uncork', 5.0, 5.0, -1, 31, false, false, false)
        Wait(500)
        TaskPlayAnim(ped, dict, 'chug_a', 5.0, 5.0, -1, 31, false, false, false)
        Wait(5000)
        ClearPedTasks(ped)
    elseif IsPedOnMount(ped) or IsPedUsingAnyScenario(ped) then
        TaskItemInteraction_2(ped, 1737033966, itemInHand, GetHashKey("p_bottleJD01x_ph_r_hand"), GetHashKey("DRINK_Bottle_Cylinder_d1-55_H18_Neck_A8_B1-8_QUICK_RIGHT_HAND"), true, 0, 0)
        Citizen.InvokeNative(0x2208438012482A1A, ped, true, true)
        Wait(4000)
    end
    
    DeleteObject(itemInHand)
    itemInHand = nil
    
    isHighJumpActive = true
    lib:notify(Config.JumpTonic.notifications.drinking)
    
    LocalPlayer.state:set("inv_busy", false, true)
    isBusy = false
    
    CreateThread(function()
        while isHighJumpActive do
            local ped = PlayerPedId()
            SetSuperJumpThisFrame(PlayerId())
            Citizen.InvokeNative(0x66F9A0FE, ped, Config.JumpTonic.moveSpeedMultiplier or 1.15) -- Set move rate
            SetPedCanRagdoll(ped, false)
            SetPedCanRagdollFromPlayerImpact(ped, false)
            
            if IsPedFalling(ped) then
                SetEntityHealth(ped, GetEntityHealth(ped))
            end
            
            if IsControlJustPressed(0, 0xD9D0E1C0) then -- INPUT_JUMP (Space)
                if not IsPedInAnyVehicle(ped, false) then
                    local coords = GetEntityCoords(ped)
                    local groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, false)
                    local heightAboveGround = coords.z - groundZ
                    
                    if heightAboveGround < Config.JumpTonic.minHeightForBoost then
                        local velocity = GetEntityVelocity(ped)
                        SetEntityVelocity(ped, velocity.x, velocity.y, velocity.z + Config.JumpTonic.velocityBoost)
                    end
                end
            end
            
            Wait(0)
        end
        
        local ped = PlayerPedId()
        Citizen.InvokeNative(0x66F9A0FE, ped, 1.0) -- Reset move rate
        SetPedCanRagdoll(ped, true)
        SetPedCanRagdollFromPlayerImpact(ped, true)
    end)
    
    
    CreateThread(function()
        Wait(Config.JumpTonic.duration)
        if isHighJumpActive then
           
            TriggerEvent('highjump:client:deactivate')
            lib:notify(Config.JumpTonic.notifications.wornOff)
        end
    end)
end)

RegisterNetEvent('highjump:client:deactivate', function()
    
    isHighJumpActive = false
end)

RegisterNetEvent('RSGCore:Client:OnPlayerLoaded', function()
   
    isHighJumpActive = false
    local ped = PlayerPedId()
    Citizen.InvokeNative(0x66F9A0FE, ped, 1.0) -- Reset move rate
    SetPedCanRagdoll(ped, true)
    SetPedCanRagdollFromPlayerImpact(ped, true)
    TriggerServerEvent('highjump:server:resetMetadata')
end)

CreateThread(function()
    while true do
        if isHighJumpActive then
            local ped = PlayerPedId()
            if IsEntityDead(ped) then
               
                TriggerEvent('highjump:client:deactivate')
                lib:notify(Config.JumpTonic.notifications.wornOff)
            end
        end
        Wait(1000)
    end
end)

