N1Config = {}

N1Config.MaxPlayers = GetConvarInt('sv_maxclients', 32) -- Gets max players from config file, default 32
N1Config.IdentifierType = "steam" -- Set the identifier type (can be: steam, license)
N1Config.DefaultSpawn = {x=-1035.71,y=-2731.87,z=12.86,a=0.0}

N1Config.Money = {}
N1Config.Money.MoneyTypes = {['cash'] = 500, ['bank'] = 5000, ['crypto'] = 0 } -- ['type']=startamount - Add or remove money types for your server (for ex. ['blackmoney']=0), remember once added it will not be removed from the database!
N1Config.Money.DontAllowMinus = {'cash', 'crypto'} -- Money that is not allowed going in minus

N1Config.Player = {}
N1Config.Player.MaxWeight = 150000 -- Max weight a player can carry (currently 120kg, written in grams)
N1Config.Player.MaxInvSlots = 30 -- Max inventory slots for a player
N1Config.Player.Bloodtypes = {
    "A+",
    "A-",
    "B+",
    "B-",
    "AB+",
    "AB-",
    "O+",
    "O-",
}

N1Config.Server = {} -- General server config
N1Config.Server.closed = false -- Set server closed (no one can join except people with ace permission 'N1admin.join')
N1Config.Server.closedReason = "We\'re still testing." -- Reason message to display when people can't join the server
N1Config.Server.uptime = 0 -- Time the server has been up.
N1Config.Server.whitelist = false -- Enable or disable whitelist on the server
N1Config.Server.discord = "https://discord.gg/Ttr6fY6" -- Discord invite link
N1Config.Server.PermissionList = {} -- permission list
