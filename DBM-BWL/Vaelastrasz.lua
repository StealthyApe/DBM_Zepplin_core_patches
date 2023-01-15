local mod	= DBM:NewMod("Vaelastrasz", "DBM-BWL", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 168 $"):sub(12, -3))
mod:SetCreatureID(13020)
mod:RegisterCombat("combat")

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_AURA_APPLIED",
	"UNIT_SPELLCAST_SUCCEEDED"
)

local warnBreath		= mod:NewCastAnnounce(23461)
local warnAdrenaline	= mod:NewSpellAnnounce(18173)
local warnSweep         = mod:NewSpellAnnounce(15847)

local timerSweep        = mod:NewNextTimer(15,15847)
local timerBreath		= mod:NewCastTimer(2, 23461)
local timerAdrenaline	= mod:NewNextTimer(30, 18173)

local specWarnAdrenaline	= mod:NewSpecialWarningYou(18173)

function mod:OnCombatStart(delay)
end

function mod:UNIT_SPELLCAST_SUCCEEDED(target,spellid)
	if spellid == "Burning Adrenaline" then
		timerAdrenaline:Start()
		warnAdrenaline:Show()
	elseif spellid == "Tail Sweep" then
		timerSweep:Start()
		warnSweep:Show()
	end

end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(23461) then
		warnBreath:Show()
		timerBreath:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(18173) then
		warnAdrenaline:Show(args.destName)
		timerAdrenaline:Start(args.destName)
		if args:IsPlayer() then
			specWarnAdrenaline:Show()
		end
	end
end