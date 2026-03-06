local Root = "an_adminsys/"

local function IncludeSharedFile(FileName)
    local Path = Root .. "shared/" .. FileName

    if SERVER then
        AddCSLuaFile(Path)
    end

    include(Path)
end

local function LoadFolder(Folder, ShouldSendToClient, ShouldInclude)
    local Files = file.Find(Root .. Folder .. "*.lua", "LUA")
    table.sort(Files)

    for _, FileName in ipairs(Files) do
        local Path = Root .. Folder .. FileName

        if SERVER and ShouldSendToClient then
            AddCSLuaFile(Path)
        end

        if ShouldInclude then
            include(Path)
        end
    end
end

if SERVER then
    IncludeSharedFile("sh_admin_popups_config.lua")

    local SharedFiles = file.Find(Root .. "shared/*.lua", "LUA")
    table.sort(SharedFiles)

    for _, FileName in ipairs(SharedFiles) do
        if FileName ~= "sh_admin_popups_config.lua" then
            IncludeSharedFile(FileName)
        end
    end

    -- Server files
    LoadFolder("server/", false, true)

    -- Client files
    LoadFolder("client/", true, false)
else
    IncludeSharedFile("sh_admin_popups_config.lua")

    local SharedFiles = file.Find(Root .. "shared/*.lua", "LUA")
    table.sort(SharedFiles)

    for _, FileName in ipairs(SharedFiles) do
        if FileName ~= "sh_admin_popups_config.lua" then
            IncludeSharedFile(FileName)
        end
    end

    -- Client files
    LoadFolder("client/", false, true)
end