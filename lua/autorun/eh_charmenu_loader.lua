EHChar = EHChar or {}
EHChar.Version = "0.1.0"

local function includeShared(path)
    if SERVER then AddCSLuaFile(path) end
    include(path)
end

includeShared("eh_charmenu/sh_config.lua")

if SERVER then
    include("eh_charmenu/sv_database.lua")
    include("eh_charmenu/sv_core.lua")
    AddCSLuaFile("eh_charmenu/cl_menu.lua")
else
    include("eh_charmenu/cl_menu.lua")
end
