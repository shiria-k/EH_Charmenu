EHChar = EHChar or {}
EHChar.Version = "0.1.4"

local PREFIX = "[EH_Charmenu] "

local function ehPrint(text)
    print(PREFIX .. tostring(text))
end

local function safeInclude(path, sendToClient)
    if SERVER and sendToClient then
        AddCSLuaFile(path)
    end

    local ok, err = pcall(include, path)
    if ok then
        ehPrint("Geladen: " .. path)
        return true
    end

    ehPrint("FEHLER beim Laden von " .. path .. ": " .. tostring(err))
    return false
end

ehPrint("Loader gestartet | Version " .. EHChar.Version)

-- Shared config wird auch an Clients gesendet.
-- In sh_config.lua duerfen keine SQL-Passwoerter stehen.
safeInclude("eh_charmenu/sh_config.lua", true)

if SERVER then
    AddCSLuaFile("eh_charmenu/cl_menu.lua")

    -- Server-only config enthaelt SQL-Daten und wird NICHT an Clients gesendet.
    safeInclude("eh_charmenu/sv_config.lua", false)
    safeInclude("eh_charmenu/sv_resources.lua", false)
    safeInclude("eh_charmenu/sv_database.lua", false)
    safeInclude("eh_charmenu/sv_version.lua", false)
    safeInclude("eh_charmenu/sv_core.lua", false)

    ehPrint("Server-Dateien geladen")
else
    safeInclude("eh_charmenu/cl_menu.lua", false)
end
