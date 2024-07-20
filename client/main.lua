local ox_lib = exports.ox_lib
local ox_target = exports.ox_target
ESX = exports["es_extended"]:getSharedObject()

local function notify(title, description, type)
    if Config.Notifytype == 'ox' then
        lib.notify({
            title = title,
            description = description,
            type = type,
            position = 'top-center',
            style = { ['z-index'] = 9999 }
        })
    else
        if type == 'success' then
            ESX.ShowNotification(description)
        elseif type == 'error' then
            ESX.ShowNotification('~r~' .. description)
        elseif type == 'info' then
            ESX.ShowNotification('~b~' .. description)
        end
    end
end

for id, shop in pairs(Config.Shopcoords) do
    if Config.oxtarget then
        ox_target:addSphereZone({
            coords = shop.Coords,
            radius = 2.0,
            options = {
                {
                    label = Config.Lang.robLabel,
                    icon = 'fa-solid fa-mask',
                    canInteract = function()
                        return not lib.progressActive()
                    end,
                    onSelect = function()
                        TriggerServerEvent('storeRobbery:attemptRobbery', id)
                    end
                }
            }
        })
    else
        CreateThread(function()
            local coords = shop.Coords
            local showing = false

            while true do
                local playerCoords = GetEntityCoords(PlayerPedId())
                local distance = #(playerCoords - coords)

                if distance < 2.0 then
                    if not showing then
                        lib.showTextUI(Config.Lang.robPrompt, {
                            position = "top-center",
                            icon = 'fa-solid fa-mask',
                            style = {
                                borderRadius = 0,
                                backgroundColor = '#48BB78',
                                color = 'white'
                            }
                        })
                        showing = true
                    end

                    if IsControlJustReleased(0, 38) then
                        TriggerServerEvent('storeRobbery:attemptRobbery', id)
                    end
                else
                    if showing then
                        lib.hideTextUI()
                        showing = false
                    end
                end

                Wait(0)
            end
        end)
    end
end

RegisterNetEvent('storeRobbery:startRobbery')
AddEventHandler('storeRobbery:startRobbery', function(shopId)
    local shop = Config.Shopcoords[shopId]
    local coords = shop.Coords
    local playerPed = PlayerPedId()
    local success = false
    local robberyOngoing = true

    CreateThread(function()
        while robberyOngoing do
            Wait(1000)
            local playerCoords = GetEntityCoords(playerPed)
            local distance = #(playerCoords - coords)

            if distance > Config.MaxDistance then
                robberyOngoing = false
                if lib.progressActive() then
                    lib.cancelProgress()
                end
                TriggerServerEvent('storeRobbery:cancelRobbery', shopId, coords)
            end
        end
    end)

    success = lib.progressBar({
        duration = shop.duration,
        label = Config.Lang.startRobbery,
        canCancel = false
    })

    if success and robberyOngoing then
        TriggerServerEvent('storeRobbery:completeRobbery', shopId)
    end
end)

RegisterNetEvent('storeRobbery:addBlip')
AddEventHandler('storeRobbery:addBlip', function(coords)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, 161)
    SetBlipScale(blip, 1.0)
    SetBlipColour(blip, 1)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.Lang.notifyPoliceTitle)
    EndTextCommandSetBlipName(blip)

    Wait(Config.PoliceBlipDuration)
    RemoveBlip(blip)
end)

RegisterNetEvent('storeRobbery:cancelRobbery')
AddEventHandler('storeRobbery:cancelRobbery', function(coords)
    notify(Config.Lang.cancelRobbery, Config.Lang.cancelRobberyDescription, 'error')

    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    RemoveBlip(blip)
end)

RegisterNetEvent('storeRobbery:notifyCooldown')
AddEventHandler('storeRobbery:notifyCooldown', function(remainingTime)
    notify('error', Config.Lang.cooldownMessage .. math.ceil(remainingTime / 60) .. Config.Lang.minutes, 'error')
end)

RegisterNetEvent('storeRobbery:notify')
AddEventHandler('storeRobbery:notify', function(data)
    notify(data.title, data.description, data.type)
end)