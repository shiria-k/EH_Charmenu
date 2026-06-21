if CLIENT then return end

EHMoneyShop = EHMoneyShop or {}
EHMoneyShop.Config = EHMoneyShop.Config or {}

local CONFIG = {}

-- Auf Server 1 so lassen, auf Server 2 auf "server2" stellen
CONFIG.CURRENT_SERVER = "server1"

-- Deine beiden GMod-Server
CONFIG.SERVER_1_IP = "148.251.79.27:27015"
CONFIG.SERVER_2_IP = "148.251.79.27:27017"

-- Datenbankdaten
-- WICHTIG: Passwort nicht öffentlich in GitHub speichern, wenn das Repository public ist.
CONFIG.DB_HOST = "148.251.103.136"
CONFIG.DB_USER = "u1_JGKRHTsvqk"
CONFIG.DB_PASS = "HIER_DEIN_NEUES_DATENBANK_PASSWORT_EINTRAGEN"
CONFIG.DB_NAME = "s1_Geld_Shop"
CONFIG.DB_PORT = 3306

EHMoneyShop.Config.CurrentServer = CONFIG.CURRENT_SERVER
EHMoneyShop.Config.Server1IP = CONFIG.SERVER_1_IP
EHMoneyShop.Config.Server2IP = CONFIG.SERVER_2_IP

EHMoneyShop.Config.MySQL = {
    host = CONFIG.DB_HOST,
    username = CONFIG.DB_USER,
    password = CONFIG.DB_PASS,
    database = CONFIG.DB_NAME,
    port = CONFIG.DB_PORT
}

EHMoneyShop.ServerConfig = CONFIG

print("[EH Geld Config] sv_config.lua geladen. Server: " .. tostring(CONFIG.CURRENT_SERVER))
