# Advanced FiveM Queue System

A comprehensive queue system for FiveM with Discord role-based priorities, admin bypass, crash queue, and web-based authentication.

## Features

✅ **Priority Queue System** - Discord role-based priority levels  
✅ **Admin Bypass** - Admins can skip the queue entirely  
✅ **Crash Queue** - Players who crash get reconnection priority  
✅ **Token Authentication** - Website integration for secure connections  
✅ **Reserved Slots** - Reserve slots for priority players  
✅ **Discord Integration** - Automatic role detection and priority assignment  
✅ **Webhook Logging** - Log all queue events to Discord  
✅ **API Exports** - Full API for external applications  

---

## Installation

### 1. Basic Setup

1. Copy the `fivem queue with web` folder to your server's `resources` directory
2. Add to your `server.cfg`:
   ```
   ensure fivem-queue-web
   ```

### 2. Configuration

Edit `config.lua` and configure the following:

#### Discord Settings
```lua
Config.DiscordBotToken = "YOUR_DISCORD_BOT_TOKEN"
Config.DiscordGuildId = "YOUR_DISCORD_GUILD_ID"
Config.WebhookURL = "YOUR_DISCORD_WEBHOOK_URL"
```

**How to get Discord Bot Token:**
1. Go to https://discord.com/developers/applications
2. Create a new application
3. Go to "Bot" section
4. Click "Add Bot"
5. Copy the token
6. Enable "Server Members Intent" under Privileged Gateway Intents

**How to get Guild ID:**
1. Enable Developer Mode in Discord (Settings → Advanced → Developer Mode)
2. Right-click your server and click "Copy ID"

#### Discord Role IDs
Replace the role IDs in `Config.DiscordRoles` with your actual Discord role IDs:
```lua
Config.DiscordRoles = {
    ['owner'] = '123456789012345678',
    ['admin'] = '123456789012345680',
    -- etc...
}
```

**How to get Role IDs:**
1. In Discord, type `\@RoleName` in any channel
2. Send the message
3. The message will show `<@&ROLE_ID_HERE>`
4. Copy the number

#### API Settings
```lua
Config.APIEndpoint = "http://your-website.com/api/validate-token"
Config.APIKey = "YOUR_SECRET_API_KEY"
```

---

## Website Integration

### Token-Based Authentication

The queue system requires players to connect through your website. Here's how to implement it:

### 1. Server-Side Token Generation (Node.js/Express Example)

```javascript
const express = require('express');
const axios = require('axios');
const app = express();

// Your FiveM server details
const FIVEM_SERVER = 'http://your-fivem-server:30120';

// Generate token endpoint
app.post('/api/generate-token', async (req, res) => {
    const { userId, discordId } = req.body;
    
    // Your authentication logic here
    // Verify user is logged in, check permissions, etc.
    
    try {
        // Call FiveM server to generate token
        const response = await axios.post(`${FIVEM_SERVER}/queuetoken`, {
            identifier: `discord:${discordId}`,
            userId: userId
        });
        
        const token = response.data.token;
        
        res.json({
            success: true,
            token: token,
            connectUrl: `fivem://connect/your-server-ip?token=${token}`
        });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

app.listen(3000);
```

### 2. Frontend Connect Button (HTML/JavaScript)

```html
<!DOCTYPE html>
<html>
<head>
    <title>Connect to Server</title>
</head>
<body>
    <button id="connectBtn">Connect to Server</button>
    
    <script>
        document.getElementById('connectBtn').addEventListener('click', async () => {
            try {
                // Call your backend to generate token
                const response = await fetch('/api/generate-token', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({
                        userId: 'USER_ID_HERE',
                        discordId: 'DISCORD_ID_HERE'
                    })
                });
                
                const data = await response.json();
                
                if (data.success) {
                    // Redirect to FiveM with token
                    window.location.href = data.connectUrl;
                } else {
                    alert('Failed to generate connection token');
                }
            } catch (error) {
                console.error('Error:', error);
                alert('Connection failed');
            }
        });
    </script>
</body>
</html>
```

### 3. Alternative: Direct Token Passing

You can also pass tokens through the connection string:

```javascript
// In your website's connect function
function connectToServer(token) {
    const serverIp = 'your.server.ip:30120';
    const connectUrl = `fivem://connect/${serverIp}?token=${token}`;
    window.location.href = connectUrl;
}
```

Then modify your FiveM `server.cfg` to accept the token:
```
sv_endpointprivacy true
```

---

## API Exports

The resource exports several functions for external use:

### Generate Token
```lua
local token = exports['fivem-queue-web']:GenerateToken(identifier, customData)
```

### Get Queue Status
```lua
local status = exports['fivem-queue-web']:GetQueueStatus()
-- Returns: { queueLength, playerCount, maxPlayers, availableSlots }
```

### Get Queue List
```lua
local queue = exports['fivem-queue-web']:GetQueueList()
-- Returns: Array of { position, name, priority, waitTime }
```

---

## Commands

### Server Console Commands

**View Queue:**
```
queue
```
Shows current queue status and list of players

**Clear Queue:**
```
clearqueue
```
Removes all players from queue

**Generate Token (Manual):**
```
queuetoken <identifier>
```
Example: `queuetoken discord:123456789`

---

## Priority System

Priority levels (higher = higher priority):

| Role | Priority | Description |
|------|----------|-------------|
| Owner | 1000 | Server owner |
| Management | 900 | Management team |
| Admin | 800 | Administrators (bypass enabled) |
| Moderator | 700 | Moderators |
| VIP Platinum | 600 | Highest VIP tier |
| VIP Gold | 500 | High VIP tier |
| VIP Silver | 400 | Medium VIP tier |
| VIP Bronze | 300 | Basic VIP tier |
| Member | 200 | Regular members |
| Default | 100 | No special role |

**Crash Queue Priority:** 950 (higher than most VIPs)

---

## Crash Queue

The crash queue system automatically detects when players disconnect due to crashes or timeouts and gives them priority reconnection.

**Settings:**
- `Config.EnableCrashQueue` - Enable/disable crash queue
- `Config.CrashQueuePriority` - Priority level for crashed players (default: 950)
- `Config.CrashQueueTimeout` - How long the crash queue slot is reserved (default: 180 seconds)

---

## Troubleshooting

### Players can't connect without website
- This is intentional! Set `Config.EnableTokenAuth = false` to allow connections without tokens (for testing)

### Discord roles not working
1. Verify your Discord Bot Token is correct
2. Ensure "Server Members Intent" is enabled in Discord Developer Portal
3. Check that the bot is in your Discord server
4. Verify Discord Role IDs match exactly
5. Check server console for error messages

### Queue not processing
1. Ensure `sv_maxclients` in server.cfg matches `Config.MaxPlayers`
2. Check if reserved slots are configured correctly
3. Verify OneSteady is enabled in your server

### Tokens expiring too fast
- Increase `Config.TokenExpireTime` (in seconds)
- Default is 300 seconds (5 minutes)

---

## Advanced Configuration

### Custom Priority Calculation

You can modify the priority system in `server.lua`:

```lua
local function GetPlayerPriority(identifier)
    -- Add custom logic here
    -- Example: Add priority based on playtime
    local playtime = GetPlayerPlaytime(identifier)
    local basePriority = Config.Priorities['default']
    
    if playtime > 100 then
        basePriority = basePriority + 50
    end
    
    return basePriority
end
```

### Reserved Slots

Reserved slots ensure space for priority players:
```lua
Config.ReservedSlots = 2 -- Reserve 2 slots
```

This means if your server has 32 max players, regular players can only fill 30 slots, keeping 2 for admins/VIPs.

---

## Security Recommendations

1. **Keep your API key secret** - Never expose it in client-side code
2. **Use HTTPS** for your website API
3. **Implement rate limiting** on token generation
4. **Validate Discord IDs** before generating tokens
5. **Log all token generations** for audit purposes
6. **Rotate tokens regularly** using the expiration system

---

## Example Integration Flow

```
1. Player visits your website
2. Player logs in with Discord OAuth
3. Website verifies player's identity
4. Player clicks "Connect to Server"
5. Website calls backend API to generate token
6. Backend validates request and calls FiveM server
7. FiveM server generates token and returns it
8. Website receives token and creates FiveM connect URL
9. Player's browser opens FiveM with connect URL + token
10. FiveM validates token and adds player to queue
11. Queue system checks Discord roles for priority
12. Player is sorted by priority and join time
13. When slot available, player connects to server
```

---

## Support

For issues or questions:
1. Check the console for error messages (F8 in-game or server console)
2. Verify all configuration settings
3. Ensure all required dependencies are installed
4. Check Discord bot permissions

---

## Credits

Created for FiveM servers requiring advanced queue management with web integration.

## License

Free to use and modify for your server.
