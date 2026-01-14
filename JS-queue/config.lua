Config = {}

-- Queue Settings
Config.MaxPlayers = 48 -- Maximum players on the server
Config.RefreshRate = 1000 -- Queue refresh rate in milliseconds
Config.EnableDebug = true -- Enable debug messages

-- Token Settings (for website authentication)
Config.EnableTokenAuth = true -- Require tokens from website to join
Config.TokenExpireTime = 300 -- Token expiration time in seconds (5 minutes)


-- Priority Levels (higher number = higher priority)
Config.Priorities = {
    ['owner'] = 1000,
    ['management'] = 900,
    ['admin'] = 800,
    ['moderator'] = 700,
    ['vip_platinum'] = 600,
    ['vip_gold'] = 500,
    ['vip_silver'] = 400,
    ['vip_bronze'] = 300,
    ['member'] = 200,
    ['default'] = 100
}

-- Discord Role IDs (replace with your actual Discord role IDs)
Config.DiscordRoles = {
    ['owner'] = '123456789012345678',
    ['management'] = '123456789012345679',
    ['admin'] = '123456789012345680',
    ['moderator'] = '123456789012345681',
    ['vip_platinum'] = '123456789012345682',
    ['vip_gold'] = '123456789012345683',
    ['vip_silver'] = '123456789012345684',
    ['vip_bronze'] = '123456789012345685',
    ['member'] = '123456789012345686'
}

-- Admin Bypass Settings
Config.AdminBypass = true -- Allow admins to bypass queue
Config.AdminBypassRoles = { -- Roles that can bypass queue
    'owner',
    'management',
    'admin'
}

-- Crash Queue Settings
Config.EnableCrashQueue = true -- Enable crash queue system
Config.CrashQueuePriority = 950 -- Priority for players who crashed
Config.CrashQueueTimeout = 180 -- Time in seconds before crash queue slot expires (3 minutes)

-- Reserved Slots
Config.ReservedSlots = 2 -- Reserved slots for priority/admin players

-- Messages
Config.Messages = {
    ['queue_position'] = 'Queue Position: %s/%s',
    ['connecting'] = 'Connecting to server...',
    ['no_token'] = 'Connection denied: No authentication token provided. Please connect through the website.',
    ['invalid_token'] = 'Connection denied: Invalid or expired token.',
    ['kicked_restart'] = 'Server is restarting.',
    ['crash_queue'] = 'Welcome back! You were returned to your previous queue position.'
}

-- Discord credentials are now stored server-side for security
