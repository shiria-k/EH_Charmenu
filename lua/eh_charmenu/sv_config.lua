EHChar = EHChar or {}
EHChar.Config = EHChar.Config or {}

-- =========================================================
-- EH_Charmenu Server Config
-- Diese Datei wird NUR serverseitig geladen.
-- Hier kommen SQL-Daten rein.
-- Diese Datei NICHT an Clients senden.
-- =========================================================

EHChar.Config.Database = {
    -- true = MySQL/MariaDB ueber mysqloo
    -- false = lokale SQLite-Testdatenbank
    UseMySQL = true,

    -- Bei externer Datenbank niemals 127.0.0.1/localhost nutzen.
    -- Trage die echte Datenbank-IP oder den Datenbank-Host ein.
    Host = "DEINE_SQL_IP_ODER_HOST",
    Port = 3306,
    Database = "DEINE_DATENBANK",
    Username = "DEIN_SQL_USER",
    Password = "DEIN_SQL_PASSWORT",

    AutoReconnect = true,
    ReconnectDelay = 10,
    StrictMySQL = true
}
