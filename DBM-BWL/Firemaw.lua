local mod	= DBM:NewMod("Firemaw", "DBM-BWL", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 168 $"):sub(12, -3))
mod:SetCreatureID(11983)
mod:RegisterCombat("combat")

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_CAST_SUCCESS",
	"UNIT_SPELLCAST_SUCCEEDED"
)

local warnWingBuffet	= mod:NewCastAnnounce(23339)
local warnShadowFlame	= mod:NewCastAnnounce(22539)
local warnFlameBuffet	= mod:NewSpellAnnounce(23341)

local timerWingBuffet	= mod:NewNextTimer(30, 23339)
local timerShadowFlame	= mod:NewCastTimer(2, 22539)
--local timerFlameBuffetCD = mod:NewCDTimer(10, 23341)

function mod:OnCombatStart(delay)
	timerWingBuffet:Start(-delay)
end

function mod:UNIT_SPELLCAST_SUCCEEDED(target,spellid)
	if spellid == "Wing Buffet" then
		timerWingBuffet:Start()
		warnWingBuffet:Show()
	end
end

--[[
function mod:SPELL_CAST_START(args)
	if args:IsSpellID(23339) and self:IsInCombat() then
		warnWingBuffet:Show()
		timerWingBuffet:Start()
	elseif args:IsSpellID(22539) and self:IsInCombat() then
		timerShadowFlame:Start()
		warnShadowFlame:Show()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(23341) then
		warnFlameBuffet:Show()
	end
end
--]]