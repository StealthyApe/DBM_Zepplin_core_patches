local mod	= DBM:NewMod("Ragnaros", "DBM-MC", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 143 $"):sub(12, -3))
mod:SetCreatureID(11502)
mod:RegisterCombat("combat")

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_REMOVED",
	"CHAT_MSG_MONSTER_YELL",
	"UNIT_SPELLCAST_SUCCEEDED",
	"UNIT_SPELLCAST_FAILED",
	"COMBAT_LOG_EVENT_UNFILTERED"
)
local son_count = 0;
local warnWrathRag		= mod:NewSpellAnnounce(20566)
local warnHandRag		= mod:NewSpellAnnounce(19780)--does not show in combat log. need transciptor to get more data on this later
local warnSubmergeSoon	= mod:NewAnnounce("WarnSubmergeSoon", "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendBurrow.blp")
local warnSubmerge		= mod:NewAnnounce("WarnSubmerge", "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendBurrow.blp")
local warnEmergeSoon	= mod:NewAnnounce("WarnEmergeSoon", "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendUnBurrow.blp")
local warnEmerge		= mod:NewAnnounce("WarnEmerge", "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendUnBurrow.blp")


local timerWrathRag		= mod:NewNextTimer(25, 20566)
local timerWrathEstimate = mod:NewNextTimer(25, 20566)
local timerHandRag		= mod:NewNextTimer(20, 19780)
local timerSubmerge		= mod:NewTimer(180, "TimerSubmerge", "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendBurrow.blp")
local timerEmerge		= mod:NewTimer(90, "TimerEmerge", "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendUnBurrow.blp")
local timerCombatStart	= mod:NewTimer(78, "TimerCombatStart", 2457)
local state_timer = false;
local submerged
function mod:OnCombatStart(delay)
	submerged = false
	timerSubmerge:Start(-delay)
	warnSubmergeSoon:Schedule(170-delay)
	timerWrathRag:Start(27-delay)
end

function mod:emerged()
	timerEmerge:Cancel()
	warnEmerge:Show()
	timerSubmerge:Start()
	warnSubmergeSoon:Schedule(170)
	timerWrathRag:Start(27)
	submerge = false
end

function mod:UNIT_SPELLCAST_FAILED(unit_target, spell_d)
	if spell_d == "Wrath of Ragnaros" then
		warnWrathRag:Show()
		timerWrathRag:Start()
	elseif spell_d == "Hand of Ragnaros" then
		warnHandRag:Show()
		timerHandRag:Show()
	end
end

function mod:UNIT_SPELLCAST_SUCCEEDED(unit_target, spell_d)
	if spell_d == "Wrath of Ragnaros" then
		warnWrathRag:Show()
		timerWrathRag:Start()
		timerWrathEstimate:Cancel()
	elseif spell_d == "Hand of Ragnaros" then
		warnHandRag:Show()
		timerHandRag:Show()
	end
end


function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.Submerge then
		self:SendSync("Submerge")
	elseif msg ~= L.Submerge and submerged then
		self:SendSync("Emerge")
	elseif msg == L.Pull then
		self:SendSync("RagPulled")
	end
end

function mod:COMBAT_LOG_EVENT_UNFILTERED(arg1, death, arg3, arg4, arg5, arg6,name,arg8)

	if(timerWrathRag.startedTimers[1] == nil and timerWrathEstimate.startedTimers[1] == nil) then
		timerWrathEstimate:Start()
	end
if name == "Son of Flame" and death == "UNIT_DIED" then son_count = son_count + 1 end
if son_count == 8 then
	son_count = 0
	mod:emerged()
end
end

function mod:OnSync(msg, arg)
	if msg == "Submerge" and not submerge then
		submerge = true
		warnSubmerge:Show()
		timerEmerge:Start()
		warnEmergeSoon:Schedule(80)
		self:ScheduleMethod(90, "emerged")
	elseif msg == "Emerge" and submerge == false then
		mod:emerged()
	elseif msg == "RagPulled" then
		timerCombatStart:Start()
	end
end
