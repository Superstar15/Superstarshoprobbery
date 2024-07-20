Config = {}

Config.Shopcoords = {
    ['1'] = {
        Coords = vector3(1126.8072509766, -980.10198974609, 45.415813446045),
        duration = 300000,
        reward = {500, 1500}
    },
    ['2'] = {
        Coords = vector3(1130.8072509766, -980.10198974609, 45.415813446045),
        duration = 300000,
        reward = {500, 1500}
    }
}

Config.oxtarget = true
Config.Notifytype = 'ox' -- or esx
Config.RequiredPoliceCount = 1 -- police required for shop robbery
Config.MaxDistance = 3.0 -- max distance the player can be from the shop
Config.PoliceBlipDuration = 300000 -- police blip duration (ms)
Config.CooldownTime = 1800 -- cooldown time in seconds (e.g., 1800 seconds = 30 minutes)
Config.alertFactions = {'police', 'sheriff'} -- Factions to receive notifications

-- Language configurations
Config.Lang = {
    startRobbery = 'Robbery in progress...',
    robberySuccess = 'Robbery Successful',
    robberySuccessDescription = 'You successfully robbed the shop and obtained $',
    notifyPoliceTitle = 'Shop Robbery',
    notifyPoliceDescription = 'A camera detected a shop robbery!',
    notifySheriffTitle = 'Shop Robbery (Sheriff Notification)',
    notifySheriffDescription = 'A camera detected a shop robbery! (Sheriff notification)',
    cancelRobbery = 'Robbery Cancelled',
    cancelRobberyDescription = 'You moved too far away from the shop, the robbery was cancelled.',
    policeInsufficient = 'Not enough police officers on duty to start the robbery!',
    cooldownMessage = 'This shop was recently robbed, wait ',
    minutes = ' minutes.',
    robPrompt = '[E] - Shop Robbery',
    robLabel = 'Shop Robbery'
}