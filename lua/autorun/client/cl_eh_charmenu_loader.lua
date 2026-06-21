EHChar = EHChar or {}
EHChar.Version = EHChar.Version or "0.1.5"

if EHChar.ClientLoaderStarted then return end
EHChar.ClientLoaderStarted = true

local PREFIX = "[EH_Charmenu] "

local function ehPrint(text)
    print(PREFIX .. tostring(text))
end

local function safeInclude(path)
    local ok, err = pcall(include, path)
    if ok then
        ehPrint("Client geladen: " .. path)
        return true
    end

    ehPrint("CLIENT FEHLER beim Laden von " .. path .. ": " .. tostring(err))
    return false
end

ehPrint("Client-Fallback-Loader gestartet | Version " .. tostring(EHChar.Version))

safeInclude("eh_charmenu/sh_config.lua")
safeInclude("eh_charmenu/cl_menu.lua")
