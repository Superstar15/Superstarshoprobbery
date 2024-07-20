ESX = exports["es_extended"]:getSharedObject()
local lastRobberyTime = {}

local function isPlayerInJob(playerId, jobNames)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if xPlayer and xPlayer.job and jobNames[xPlayer.job.name] then
        return true
    end
    return false
end

local function sendToDiscord(name, message)
    if not LogConfig.Webhook.enable then
        return
    end

    local connect = {
        {
            ["color"] = LogConfig.Webhook.color,
            ["description"] = message,
            ["author"] = {
                ["name"] = LogConfig.Webhook.botname,
                ["icon_url"] = LogConfig.Webhook.botimage
            },
            ["footer"] = {
                ["icon_url"] = LogConfig.Webhook.botimage,
                ["text"] = "Superstar | " .. os.date("%Y-%m-%d %H:%M:%S")
            },
        }
    }

    PerformHttpRequest(LogConfig.Webhook.url, function(err, text, headers)
    end, 'POST', json.encode({
        username = LogConfig.Webhook.botname,
        avatar_url = LogConfig.Webhook.botimage,
        embeds = connect
    }), { ['Content-Type'] = 'application/json' })
end

RegisterServerEvent('storeRobbery:attemptRobbery')
AddEventHandler('storeRobbery:attemptRobbery', function(shopId)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local currentTime = os.time()

    if lastRobberyTime[shopId] and (currentTime - lastRobberyTime[shopId]) < Config.CooldownTime then
        TriggerClientEvent('storeRobbery:notifyCooldown', source, Config.CooldownTime - (currentTime - lastRobberyTime[shopId]))
        return
    end

    local players = ESX.GetPlayers()
    local policeCount = 0

    for _, playerId in ipairs(players) do
        if isPlayerInJob(playerId, {['police'] = true}) then
            policeCount = policeCount + 1
        end
    end

    if policeCount < Config.RequiredPoliceCount then
        TriggerClientEvent('storeRobbery:notify', source, {
            title = Config.Lang.policeInsufficient,
            description = Config.Lang.policeInsufficient,
            type = 'error'
        })
        return
    end

    for _, playerId in ipairs(players) do
        for _, faction in ipairs(Config.alertFactions) do
            if isPlayerInJob(playerId, {[faction] = true}) then
                TriggerClientEvent('storeRobbery:notify', playerId, {
                    title = Config.Lang.notifyPoliceTitle,
                    description = Config.Lang.notifyPoliceDescription,
                    type = 'info'
                })
                TriggerClientEvent('storeRobbery:addBlip', playerId, GetEntityCoords(GetPlayerPed(source)))
                break
            end
        end
    end

    TriggerClientEvent('storeRobbery:startRobbery', source, shopId)
    lastRobberyTime[shopId] = currentTime

    if LogConfig.Webhook.enable and LogConfig.Webhook.url then
        local steamName = GetPlayerName(source)
        local license = xPlayer.identifier
        local message = string.format("**Robbery Started**\n\n**Name:** %s\n**Steam Name:** %s\n**License:** %s\n**ID:** %d\n**Start Time:** %s",
            xPlayer.getName(), steamName, license, source, os.date("%Y-%m-%d %H:%M:%S", currentTime))
        sendToDiscord(LogConfig.Webhook.botname, message)
    end

    TriggerClientEvent('storeRobbery:notify', source, {
        title = Config.Lang.startRobbery,
        description = Config.Lang.startRobbery,
        type = 'success'
    })
end)

RegisterServerEvent('storeRobbery:completeRobbery')
AddEventHandler('storeRobbery:completeRobbery', function(shopId)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local currentTime = os.time()
    local shop = Config.Shopcoords[shopId]
    local reward = math.random(shop.reward[1], shop.reward[2])
    xPlayer.addMoney(reward)

    if LogConfig.Webhook.enable and LogConfig.Webhook.url then
        local steamName = GetPlayerName(source)
        local license = xPlayer.identifier
        local message = string.format("**Robbery Completed**\n\n**Name:** %s\n**Steam Name:** %s\n**License:** %s\n**ID:** %d\n**Start Time:** %s\n**End Time:** %s\n**Reward:** $%d",
            xPlayer.getName(), steamName, license, source, os.date("%Y-%m-%d %H:%M:%S", lastRobberyTime[shopId]), os.date("%Y-%m-%d %H:%M:%S", currentTime), reward)
        sendToDiscord(LogConfig.Webhook.botname, message)
    end

    TriggerClientEvent('storeRobbery:notify', source, {
        title = Config.Lang.robberySuccess,
        description = Config.Lang.robberySuccessDescription .. reward,
        type = 'success'
    })

    TriggerEvent('log:storeRobbery', xPlayer, true, reward)
end)

RegisterServerEvent('storeRobbery:cancelRobbery')
AddEventHandler('storeRobbery:cancelRobbery', function(shopId, coords)
    TriggerClientEvent('storeRobbery:cancelRobbery', -1, coords)
end)