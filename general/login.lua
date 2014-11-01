disable_for_gms = 1

local function languagefix (event, player)
	player:RemoveSpell(668, player)
	player:LearnSpell(668, player)
end

local function register_stats (event, Player)
	CharDBExecute("INSERT INTO shard_aa_points (playerguid) VALUES ("..Player:GetGUIDLow()..")")
	base_statdb = WorldDBQuery("SELECT str, agi, sta, inte, spi FROM player_levelstats WHERE race="..player:GetRace().."")
	CharDBExecute("INSERT INTO shard_stats (playerguid, str, agi, sta, inte, spi) VALUES ("..base_statdb:GetUInt32(0)..", "..base_statdb:GetUInt32(1)..", "..base_statdb:GetUInt32(2)..", "..base_statdb:GetUInt32(3)..", "..base_statdb:GetUInt32(4)..")")
end

local function multiboxing (event, player)
	for k, v in ipairs(GetPlayersInWorld()) do
		if(v:GetPlayerIP() == player:GetPlayerIP()) then -- check areas so we wont spam to the whole world
			if (v:GetName()~=player:GetName()) then
				if v:IsGM() and (disable_for_gms==1) then
					player:SendBroadcastMessage("GM detected. Multibox prevention disabled.")
					v:SendBroadcastMessage("GM detected. Multibox prevention disabled.")
				else
					SendWorldMessage("[Security]: |cffff0000Automatically kicked characters '"..v:GetName().."' and '"..player:GetName().."' for multiboxing.|r")
					v:KickPlayer()
					player:KickPlayer()
				end
			end
		end
	end
end

function apply_allocation (event, player)
	base_statdb = WorldDBQuery("SELECT str, agi, sta, inte, spi FROM player_levelstats WHERE race="..player:GetRace().."")
	statdb = CharDBQuery("SELECT str, agi, sta, inte, spi FROM shard_stats WHERE playerguid="..player:GetGUIDLow().."")
	if (statdb==nil) then
		CharDBExecute("INSERT INTO shard_stats (playerguid, str, agi, sta, inte, spi) VALUES ("..base_statdb:GetUInt32(0)..", "..base_statdb:GetUInt32(1)..", "..base_statdb:GetUInt32(2)..", "..base_statdb:GetUInt32(3)..", "..base_statdb:GetUInt32(4)..")")
		player:SendBroadcastMessage("[DEBUG]: New player! No stat allocation.")
	else
	allocated_str = ((statdb:GetUInt32(0))-(base_statdb:GetUInt32(0)))
	allocated_agi = ((statdb:GetUInt32(1))-(base_statdb:GetUInt32(1)))
	allocated_sta = ((statdb:GetUInt32(2))-(base_statdb:GetUInt32(2)))
	allocated_inte = ((statdb:GetUInt32(3))-(base_statdb:GetUInt32(3)))
	allocated_spi = ((statdb:GetUInt32(4))-(base_statdb:GetUInt32(4)))

	ticker1 = allocated_str
	ticker2 = allocated_agi
	ticker3 = allocated_sta
	ticker4 = allocated_inte
	ticker5 = allocated_spi

	if (allocated_str>0) then
		player:SendBroadcastMessage(""..allocated_str.."")
	end
end
end

local function manaregen (event, player)
	if (player:GetStat(4)>1) then
		spirit = player:GetStat(4)
		repeat
			player:AddAura(21359, player)
			spirit = (spirit-2)
		until (spirit<=1)
	end
end

RegisterPlayerEvent(30, register_stats)
RegisterPlayerEvent(3, apply_allocation)
RegisterPlayerEvent(29, manaregen)
RegisterPlayerEvent(13, manaregen)
RegisterPlayerEvent(3, manaregen)
RegisterPlayerEvent(3, languagefix)
RegisterPlayerEvent(3, multiboxing)
RegisterPlayerEvent(27, languagefix)