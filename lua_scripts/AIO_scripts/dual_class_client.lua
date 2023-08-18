local AIO = AIO or require("AIO")
if AIO.AddAddon() then
    return;
end

TALENT_MAP = TALENT_MAP or {}
TALENT_MAP_BY_ID = TALENT_MAP_BY_ID or {}

SHOW_TALENT_LEVEL = 0;

AIO.AddSavedVar("TALENT_MAP")
AIO.AddSavedVar("TALENT_MAP_BY_ID")

