local vehicles = {}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)
        if vehicle ~= 0 then
            local plate = GetVehicleNumberPlateText(vehicle)
            if not vehicles[plate] then
                vehicles[plate] = {
                    health = GetVehicleEngineHealth(vehicle),
                    bodyHealth = GetVehicleBodyHealth(vehicle),
                    showText = false,
                    textTime = 0
                }
            else
                local prevHealth = vehicles[plate].health
                local prevBodyHealth = vehicles[plate].bodyHealth
                local health = GetVehicleEngineHealth(vehicle)
                local bodyHealth = GetVehicleBodyHealth(vehicle)
                if health < prevHealth then
                    local damage = (prevHealth - health) * Config.DamageMultiplier * 6 -- erhöht den Schaden noch mehr
                    SetVehicleEngineHealth(vehicle, health - damage)
                end
                if bodyHealth < prevBodyHealth then
                    local damage = (prevBodyHealth - bodyHealth) * Config.BodyDamageMultiplier * 8 -- erhöht den Schaden noch mehr
                    SetVehicleBodyHealth(vehicle, bodyHealth - damage)
                end
                vehicles[plate].health = GetVehicleEngineHealth(vehicle)
                vehicles[plate].bodyHealth = GetVehicleBodyHealth(vehicle)

                if vehicles[plate].health <= 100 and not vehicles[plate].showText then -- wenn das Fahrzeug kaputt ist und der Text noch nicht angezeigt wird
                    vehicles[plate].showText = true
                    vehicles[plate].textTime = GetGameTimer() + 5000 -- Text für 5 Sekunden anzeigen
                end

                if vehicles[plate].showText then
                    if GetGameTimer() < vehicles[plate].textTime then
                        local x,y,z = table.unpack(GetEntityCoords(vehicle))
                        Draw3DText(x,y,z+1.0, "Dieses Fahrzeug ist kaputt", 4, 0.1, 0.1) -- Text näher am Boden anzeigen
                    else
                        vehicles[plate].showText = false
                    end
                end
            end
        end
    end
end)

function Draw3DText(x,y,z,textInput,fontId,scaleX,scaleY)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz,x,y,z,1)    
    local scale = (1/dist)*20
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov   
    SetTextScale(scaleX*scale,scaleY*scale)
    SetTextFont(fontId)
    SetTextProportional(1)
    SetTextColour(255, 0, 0, 215) -- Textfarbe auf rot ändern
    SetTextDropshadow(1, 1, 1, 0, 155)
    SetTextEdge(2, 0, 0, 0, 250)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(textInput)
    SetDrawOrigin(x,y,z+2,0)
    DrawText(0.0,0.0)
    ClearDrawOrigin()
end

AddEventHandler('playerSpawned', function()
    vehicles = {}
end)

AddEventHandler('playerLoaded', function(playerData)
    vehicles = {}
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for k,v in pairs(vehicles) do
            SetVehicleEngineHealth(GetVehiclePedIsIn(PlayerPedId(), false), v.health)
            SetVehicleBodyHealth(GetVehiclePedIsIn(PlayerPedId(), false), v.bodyHealth)
        end
    end
end)
