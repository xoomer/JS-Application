-- ============================================
-- DISCORD CREDENTIALS (SERVER-SIDE ONLY)
-- ============================================
local DISCORD_BOT_TOKEN = "YOUR_DISCORD_BOT_TOKEN"  -- Replace with your bot token
local DISCORD_GUILD_ID = "YOUR_DISCORD_GUILD_ID"    -- Replace with your guild ID
local DISCORD_WEBHOOK_URL = "YOUR_DISCORD_WEBHOOK_URL" -- Replace with your webhook URL

-- Website API Configuration
local WEBSITE_API_URL = "http://localhost:3000/api/fivem/generate-token"  -- Your website URL
local WEBSITE_API_SECRET = "fM9kL2nX7pQ4vB8wR5jE3hT6yA1cZ0sD9fN2mK5gH8uW7xV4bJ3aL6eP1qR0tY"

-- Queue System Variables
local Queue = {}
local ConnectingPlayers = {}
local CrashQueue = {} -- Stores {identifier = {position = X, name = "Name", timestamp = time}}
local ActiveTokens = {}
local PlayerIdentifiers = {}

-- Utility Functions
local function DebugPrint(message)
    if Config.EnableDebug then
        print("[QUEUE] " .. message)
    end
end

local function GetPlayerCount()
    local count = 0
    for _ in pairs(GetPlayers()) do
        count = count + 1
    end
    return count
end

local function GetAvailableSlots()
    local playerCount = GetPlayerCount()
    local availableSlots = Config.MaxPlayers - playerCount
    return math.max(0, availableSlots)
end

local function SendWebhook(title, description, color)
    if DISCORD_WEBHOOK_URL and DISCORD_WEBHOOK_URL ~= "YOUR_DISCORD_WEBHOOK_URL" then
        PerformHttpRequest(DISCORD_WEBHOOK_URL, function(err, text, headers) end, 'POST', json.encode({
            embeds = {{
                title = title,
                description = description,
                color = color,
                footer = {
                    text = os.date("%Y-%m-%d %H:%M:%S")
                }
            }}
        }), { ['Content-Type'] = 'application/json' })
    end
end

-- Discord Integration
local function GetDiscordRoles(identifier)
    local discordId = nil
    
    for _, id in ipairs(GetPlayerIdentifiers(identifier)) do
        if string.match(id, "discord:") then
            discordId = string.gsub(id, "discord:", "")
            break
        end
    end
    
    if not discordId then
        DebugPrint("No Discord identifier found for player")
        return {}
    end
    
    local roles = {}
    local endpoint = ("https://discord.com/api/guilds/%s/members/%s"):format(DISCORD_GUILD_ID, discordId)
    
    PerformHttpRequest(endpoint, function(statusCode, response, headers)
        if statusCode == 200 then
            local data = json.decode(response)
            if data and data.roles then
                roles = data.roles
                DebugPrint("Found " .. #roles .. " Discord roles for player")
            end
        else
            DebugPrint("Failed to fetch Discord roles. Status: " .. statusCode)
        end
    end, 'GET', '', {
        ['Content-Type'] = 'application/json',
        ['Authorization'] = 'Bot ' .. DISCORD_BOT_TOKEN
    })
    
    Citizen.Wait(1000) -- Wait for async request
    return roles
end

local function GetPlayerPriority(identifier)
    local priority = Config.Priorities['default']
    local playerRoles = GetDiscordRoles(identifier)
    
    -- Check for Discord roles
    for roleName, roleId in pairs(Config.DiscordRoles) do
        for _, playerRoleId in ipairs(playerRoles) do
            if playerRoleId == roleId then
                if Config.Priorities[roleName] and Config.Priorities[roleName] > priority then
                    priority = Config.Priorities[roleName]
                    DebugPrint("Player has role: " .. roleName .. " (Priority: " .. priority .. ")")
                end
            end
        end
    end
    
    return priority
end

local function CanBypassQueue(identifier)
    if not Config.AdminBypass then
        return false
    end
    
    local playerRoles = GetDiscordRoles(identifier)
    
    for roleName, roleId in pairs(Config.DiscordRoles) do
        for _, bypassRole in ipairs(Config.AdminBypassRoles) do
            if roleName == bypassRole then
                for _, playerRoleId in ipairs(playerRoles) do
                    if playerRoleId == roleId then
                        DebugPrint("Player can bypass queue with role: " .. roleName)
                        return true
                    end
                end
            end
        end
    end
    
    return false
end

-- Token Management - Validates with website API
local function ValidateTokenWithWebsite(token, callback)
    if not Config.EnableTokenAuth then
        callback(true, {})
        return
    end
    
    if not token or token == "" then
        DebugPrint("No token provided")
        callback(false, {})
        return
    end
    
    local url = WEBSITE_API_URL .. "?token=" .. token
    
    PerformHttpRequest(url, function(statusCode, response, headers)
        if statusCode == 200 then
            local data = json.decode(response)
            if data and data.valid then
                DebugPrint("Token validated with website: " .. (data.username or "Unknown"))
                callback(true, data)
            else
                DebugPrint("Token validation failed: " .. (data.error or "Unknown error"))
                callback(false, data)
            end
        else
            DebugPrint("Token validation failed with status: " .. statusCode)
            callback(false, {})
        end
    end, 'GET', '', {
        ['Content-Type'] = 'application/json',
        ['x-api-key'] = WEBSITE_API_SECRET
    })
end

-- Token validation is now handled by the website API

-- Crash Queue Management - Saves exact position
local function AddToCrashQueue(identifier, playerName)
    local position = GetQueuePosition(identifier)
    if not position then
        position = 1 -- If not in queue, give them first position
    end
    
    CrashQueue[identifier] = {
        name = playerName,
        position = position,
        timestamp = os.time()
    }
    DebugPrint("Added to crash queue: " .. playerName .. " at position " .. position)
end

local function GetCrashQueueData(identifier)
    if not Config.EnableCrashQueue then
        return nil
    end
    
    if CrashQueue[identifier] then
        local timeDiff = os.time() - CrashQueue[identifier].timestamp
        if timeDiff <= Config.CrashQueueTimeout then
            DebugPrint("Player found in crash queue at position: " .. CrashQueue[identifier].position)
            return CrashQueue[identifier]
        else
            CrashQueue[identifier] = nil
        end
    end
    return nil
end

-- Adaptive Card Functions
local function CreateQueueCard(position, queueSize, playerName, priority)
    return {
        type = "AdaptiveCard",
        body = {
            {
                type = "Container",
                items = {
                    {
                        type = "ColumnSet",
                        columns = {
                            {
                                type = "Column",
                                items = {
                                    {
                                        type = "Image",
                                        url = "https://i.imgur.com/3pzjbY0.png",
                                        size = "Small"
                                    }
                                },
                                width = "auto"
                            },
                            {
                                type = "Column",
                                items = {
                                    {
                                        type = "TextBlock",
                                        text = "Queue System",
                                        weight = "Bolder",
                                        size = "Large",
                                        color = "Accent"
                                    },
                                    {
                                        type = "TextBlock",
                                        text = "Please wait while we connect you",
                                        isSubtle = true,
                                        wrap = true
                                    }
                                },
                                width = "stretch"
                            }
                        }
                    }
                }
            },
            {
                type = "Container",
                separator = true,
                items = {
                    {
                        type = "FactSet",
                        facts = {
                            {
                                title = "👤 Player:",
                                value = playerName
                            },
                            {
                                title = "📊 Queue Position:",
                                value = position .. " of " .. queueSize
                            },
                            {
                                title = "⭐ Priority Level:",
                                value = tostring(priority)
                            },
                            {
                                title = "🎮 Server Status:",
                                value = GetPlayerCount() .. "/" .. Config.MaxPlayers .. " players"
                            }
                        }
                    }
                }
            },
            {
                type = "Container",
                items = {
                    {
                        type = "TextBlock",
                        text = "⏱️ Your position updates automatically every second",
                        wrap = true,
                        size = "Small",
                        isSubtle = true,
                        horizontalAlignment = "Center"
                    }
                }
            }
        },
        ["$schema"] = "http://adaptivecards.io/schemas/adaptive-card.json",
        version = "1.3"
    }
end

local function CreateConnectingCard(playerName)
    return {
        type = "AdaptiveCard",
        body = {
            {
                type = "Container",
                items = {
                    {
                        type = "TextBlock",
                        text = "🎮 Connecting to Server",
                        weight = "Bolder",
                        size = "Large",
                        horizontalAlignment = "Center",
                        color = "Good"
                    },
                    {
                        type = "TextBlock",
                        text = "Welcome " .. playerName .. "!",
                        size = "Medium",
                        horizontalAlignment = "Center",
                        wrap = true
                    },
                    {
                        type = "TextBlock",
                        text = "✅ Authentication successful",
                        size = "Small",
                        horizontalAlignment = "Center",
                        color = "Good"
                    },
                    {
                        type = "TextBlock",
                        text = "Loading game resources...",
                        size = "Small",
                        horizontalAlignment = "Center",
                        isSubtle = true
                    }
                }
            }
        },
        ["$schema"] = "http://adaptivecards.io/schemas/adaptive-card.json",
        version = "1.3"
    }
end

local function CreateAuthCard(message, isError)
    return {
        type = "AdaptiveCard",
        body = {
            {
                type = "Container",
                items = {
                    {
                        type = "TextBlock",
                        text = isError and "❌ Connection Denied" or "🔒 Authentication",
                        weight = "Bolder",
                        size = "Large",
                        horizontalAlignment = "Center",
                        color = isError and "Attention" or "Accent"
                    },
                    {
                        type = "TextBlock",
                        text = message,
                        wrap = true,
                        horizontalAlignment = "Center"
                    },
                    {
                        type = "TextBlock",
                        text = isError and "Please connect through the website." or "Verifying your credentials...",
                        size = "Small",
                        horizontalAlignment = "Center",
                        isSubtle = true,
                        wrap = true
                    }
                }
            }
        },
        ["$schema"] = "http://adaptivecards.io/schemas/adaptive-card.json",
        version = "1.3"
    }
end

-- Queue Management
local function AddToQueue(identifier, deferrals, playerName, token)
    local queueData = {
        identifier = identifier,
        deferrals = deferrals,
        name = playerName,
        token = token,
        joinTime = os.time(),
        priority = GetPlayerPriority(identifier)
    }
    
    -- Check if player was in crash queue
    local crashData = GetCrashQueueData(identifier)
    if crashData then
        -- Insert at their exact previous position
        local insertPos = math.min(crashData.position, #Queue + 1)
        table.insert(Queue, insertPos, queueData)
        CrashQueue[identifier] = nil
        
        -- Show welcome back card
        local crashCard = CreateQueueCard(insertPos, math.max(#Queue, 1), playerName, queueData.priority)
        deferrals.presentCard(crashCard)
        
        DebugPrint("Restored crash queue position: " .. playerName .. " at position " .. insertPos)
        return insertPos
    end
    
    -- Check if player can bypass queue
    if CanBypassQueue(identifier) then
        queueData.priority = 10000 -- Highest priority
    end
    
    table.insert(Queue, queueData)
    DebugPrint("Added to queue: " .. playerName .. " (Priority: " .. queueData.priority .. ")")
    
    return #Queue
end

local function RemoveFromQueue(identifier)
    for i, player in ipairs(Queue) do
        if player.identifier == identifier then
            table.remove(Queue, i)
            DebugPrint("Removed from queue: " .. player.name)
            return true
        end
    end
    return false
end

local function SortQueue()
    table.sort(Queue, function(a, b)
        if a.priority ~= b.priority then
            return a.priority > b.priority
        else
            return a.joinTime < b.joinTime
        end
    end)
end

local function GetQueuePosition(identifier)
    for i, player in ipairs(Queue) do
        if player.identifier == identifier then
            return i
        end
    end
    return nil
end

local function ProcessQueue()
    if #Queue == 0 then
        return
    end
    
    local availableSlots = GetAvailableSlots()
    
    if availableSlots > 0 then
        SortQueue()
        
        for i = 1, math.min(availableSlots, #Queue) do
            local player = Queue[1]
            if player then
                ConnectingPlayers[player.identifier] = true
                
                -- Show connecting card
                local connectCard = CreateConnectingCard(player.name)
                player.deferrals.presentCard(connectCard)
                
                Wait(1000)
                player.deferrals.done()
                table.remove(Queue, 1)
                DebugPrint("Allowing player to connect: " .. player.name)
                
                SendWebhook(
                    "Player Connecting",
                    "**Player:** " .. player.name .. "\n**Priority:** " .. player.priority,
                    3066993
                )
            end
        end
    end
end

-- Update queue positions for all players in queue with adaptive cards
local function UpdateQueue()
    for i, player in ipairs(Queue) do
        local card = CreateQueueCard(i, #Queue, player.name, player.priority)
        player.deferrals.presentCard(card)
    end
end

-- Main Queue Thread
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.RefreshRate)
        ProcessQueue()
        UpdateQueue()
        
        -- Clean up expired tokens
        for token, data in pairs(ActiveTokens) do
            if os.time() - data.createdAt > Config.TokenExpireTime then
                ActiveTokens[token] = nil
            end
        end
    end
end)

-- Connection Handler
AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
    local source = source
    local identifier = GetPlayerIdentifiers(source)[1]
    
    deferrals.defer()
    
    Wait(0)
    
    -- Show authentication card
    local authCard = CreateAuthCard("Checking authentication...", false)
    deferrals.presentCard(authCard)
    
    -- Extract token from player's connection
    local token = nil
    
    -- Check player identifiers for token
    for _, id in ipairs(GetPlayerIdentifiers(source)) do
        if string.match(id, "token:") then
            token = string.gsub(id, "token:", "")
            DebugPrint("Token found in identifier: " .. token)
            break
        end
    end
    
    -- If not in identifiers, check connection endpoint/params
    if not token then
        local endpoint = GetPlayerEndpoint(source)
        if endpoint then
            -- Try to extract token from endpoint if passed as parameter
            token = string.match(endpoint, "token=([^&]+)")
            if token then
                DebugPrint("Token found in endpoint: " .. token)
            end
        end
    end
    
    -- Validate token with website API
    if Config.EnableTokenAuth then
        ValidateTokenWithWebsite(token, function(isValid, tokenData)
            if not isValid then
                local errorCard = CreateAuthCard(Config.Messages['invalid_token'], true)
                deferrals.presentCard(errorCard)
                Wait(3000)
                deferrals.done(Config.Messages['invalid_token'])
                SendWebhook(
                    "Connection Denied",
                    "**Player:** " .. playerName .. "\n**Reason:** Invalid/No Token",
                    15158332
                )
                return
            end
            
            -- Token is valid, continue with connection
            local checkingCard = CreateAuthCard("Checking server capacity...", false)
            deferrals.presentCard(checkingCard)
            
            Wait(500)
            
            local playerCount = GetPlayerCount()
            local availableSlots = GetAvailableSlots()
            
            -- Check if player can bypass queue
            if CanBypassQueue(identifier) and availableSlots > 0 then
                local connectCard = CreateConnectingCard(playerName)
                deferrals.presentCard(connectCard)
                Wait(1000)
                deferrals.done()
                DebugPrint("Admin bypass: " .. playerName)
                SendWebhook(
                    "Admin Bypass",
                    "**Player:** " .. playerName .. "\n**Status:** Bypassed queue",
                    15844367
                )
                return
            end
            
            -- Check if server has available slots
            if availableSlots > Config.ReservedSlots then
                local connectCard = CreateConnectingCard(playerName)
                deferrals.presentCard(connectCard)
                Wait(1000)
                deferrals.done()
                DebugPrint("Direct connect: " .. playerName)
                return
            end
            
            -- Add to queue (no size limit)
            local queueCard = CreateAuthCard("Adding to queue...", false)
            deferrals.presentCard(queueCard)
            local position = AddToQueue(identifier, deferrals, playerName, token)
            
            DebugPrint("Queue size: " .. #Queue)
        end)
    else
        -- Token auth disabled, proceed normally
        local checkingCard = CreateAuthCard("Checking server capacity...", false)
        deferrals.presentCard(checkingCard)
        
        Wait(500)
        
        local playerCount = GetPlayerCount()
        local availableSlots = GetAvailableSlots()
        
        if CanBypassQueue(identifier) and availableSlots > 0 then
            local connectCard = CreateConnectingCard(playerName)
            deferrals.presentCard(connectCard)
            Wait(1000)
            deferrals.done()
            DebugPrint("Admin bypass: " .. playerName)
            return
        end
        
        if availableSlots > Config.ReservedSlots then
            local connectCard = CreateConnectingCard(playerName)
            deferrals.presentCard(connectCard)
            Wait(1000)
            deferrals.done()
            DebugPrint("Direct connect: " .. playerName)
            return
        end
        
        local queueCard = CreateAuthCard("Adding to queue...", false)
        deferrals.presentCard(queueCard)
        local position = AddToQueue(identifier, deferrals, playerName, nil)
        
        DebugPrint("Queue size: " .. #Queue)
    end
end)

-- Player Disconnect Handler (for crash queue)
AddEventHandler('playerDropped', function(reason)
    local source = source
    local identifier = GetPlayerIdentifiers(source)[1]
    local playerName = GetPlayerName(source)
    
    ConnectingPlayers[identifier] = nil
    RemoveFromQueue(identifier)
    
    -- Check if player crashed
    if reason and (string.find(reason:lower(), "crash") or string.find(reason:lower(), "timeout")) then
        AddToCrashQueue(identifier, playerName)
        SendWebhook(
            "Player Crashed",
            "**Player:** " .. playerName .. "\n**Reason:** " .. reason .. "\n**Status:** Added to crash queue",
            16776960
        )
    end
    
    DebugPrint("Player disconnected: " .. playerName .. " | Reason: " .. reason)
end)

-- Commands
RegisterCommand('queue', function(source, args)
    if source == 0 then
        print("=== Queue Status ===")
        print("Players in queue: " .. #Queue)
        print("Server players: " .. GetPlayerCount() .. "/" .. Config.MaxPlayers)
        print("Available slots: " .. GetAvailableSlots())
        print("\nQueue List:")
        for i, player in ipairs(Queue) do
            print(i .. ". " .. player.name .. " (Priority: " .. player.priority .. ")")
        end
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"Queue", "You are not in queue. Position info will show when connecting."}
        })
    end
end, false)

RegisterCommand('clearqueue', function(source, args)
    if source == 0 then
        for _, player in ipairs(Queue) do
            player.deferrals.done("Queue cleared by administrator.")
        end
        Queue = {}
        print("Queue cleared!")
    end
end, true)

-- API Endpoint for your JS application
-- Export functions that your external application can call
exports('GetQueueStatus', function()
    return {
        queueLength = #Queue,
        playerCount = GetPlayerCount(),
        maxPlayers = Config.MaxPlayers,
        availableSlots = GetAvailableSlots()
    }
end)

exports('GetQueueList', function()
    local queueList = {}
    for i, player in ipairs(Queue) do
        table.insert(queueList, {
            position = i,
            name = player.name,
            priority = player.priority,
            waitTime = os.time() - player.joinTime
        })
    end
    return queueList
end)

-- HTTP Callback for token validation (if using external API)
function ValidateTokenWithAPI(token, callback)
    PerformHttpRequest(Config.APIEndpoint, function(statusCode, response, headers)
        if statusCode == 200 then
            local data = json.decode(response)
            callback(data.valid or false, data)
        else
            callback(false, nil)
        end
    end, 'POST', json.encode({
        token = token,
        apiKey = Config.APIKey
    }), {
        ['Content-Type'] = 'application/json'
    })
end

print("^2[QUEUE]^7 Advanced Queue System loaded successfully!")
print("^2[QUEUE]^7 Max Players: " .. Config.MaxPlayers)
print("^2[QUEUE]^7 Queue Size: Unlimited")
print("^2[QUEUE]^7 Token Auth: " .. (Config.EnableTokenAuth and "Enabled" or "Disabled"))
print("^2[QUEUE]^7 Crash Queue: Exact position restoration enabled")
