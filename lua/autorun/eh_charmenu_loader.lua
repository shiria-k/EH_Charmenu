EHChar = EHChar or {}
EHChar.Version = "0.1.1"

local function ehPrint(text)
    print("[EHChar Loader] " .. tostring(text))
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

    ehPrint("FEHLER in " .. path .. ": " .. tostring(err))
    return false
end

if SERVER then
    ehPrint("Starte Server Loader Version " .. EHChar.Version)
else
    ehPrint("Starte Client Loader Version " .. EHChar.Version)
end

safeInclude("eh_charmenu/sh_config.lua", true)

if SERVER then
    safeInclude("eh_charmenu/sv_resources.lua", false)
    safeInclude("eh_charmenu/sv_database.lua", false)
    safeInclude("eh_charmenu/sv_core.lua", false)
    AddCSLuaFile("eh_charmenu/cl_menu.lua")
else
    safeInclude("eh_charmenu/cl_menu.lua", false)
end
