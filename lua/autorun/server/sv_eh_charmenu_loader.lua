EHChar = EHChar or {}
EHChar.Version = "0.1.5"

if EHChar.ServerLoaderStarted then return end
EHChar.ServerLoaderStarted = true

local PREFIX = "[EH_Charmenu] "

local function ehPrint(text)
    print(PREFIX .. tostring(text))
end

local function safeInclude(path, sendToClient)
    if sendToClient then
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

ehPrint("Server-Fallback-Loader gestartet | Version " .. EHChar.Version)

safeInclude("eh_charmenu/sh_config.lua", true)
AddCSLuaFile("eh_charmenu/cl_menu.lua")

safeInclude("eh_charmenu/sv_config.lua", false)
safeInclude("eh_charmenu/sv_resources.lua", false)
safeInclude("eh_charmenu/sv_database.lua", false)
safeInclude("eh_charmenu/sv_version.lua", false)
safeInclude("eh_charmenu/sv_core.lua", false)

ehPrint("Server-Dateien geladen")
