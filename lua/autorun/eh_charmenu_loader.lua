EHChar = EHChar or {}
EHChar.Version = "0.1.2"

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

-- Diese Datei liegt in lua/autorun/ und nutzt deshalb Pfade ab lua/.
-- Wichtig: sh_config.lua wird an Clients gesendet, damit cl_menu.lua EHChar.Config kennt.
safeInclude("eh_charmenu/sh_config.lua", true)

if SERVER then
    AddCSLuaFile("eh_charmenu/cl_menu.lua")

    safeInclude("eh_charmenu/sv_resources.lua", false)
    safeInclude("eh_charmenu/sv_database.lua", false)
    safeInclude("eh_charmenu/sv_core.lua", false)

    ehPrint("Server-Dateien geladen")
else
    safeInclude("eh_charmenu/cl_menu.lua", false)
end
