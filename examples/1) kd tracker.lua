
sql.Query("CREATE TABLE IF NOT EXISTS kd_tracker( SteamID TEXT, Kills INT, Deaths INT )")

local shitToUpdate = {} -- Saving the data every so often so the querys aren't spammed
    
local function addStat( SteamID, Type )
    shitToUpdate[SteamID][Type] = shitToUpdate[SteamID][Type] + 1 -- incrementing the value by 1
end

local function updateTracker()
    for k,v in pairs( shitToUpdate ) do
        if not sql.Query(("SELECT * FROM kd_tracker WHERE SteamID='%s'"):format( k )) then
            sql.Query(("INSERT INTO kd_tracker( SteamID, Kills, Deaths ) VALUES( '%s', 0, 0 )"):format( k ))
        end
        sql.Query(("UPDATE kd_tracker SET Kills=%d, Deaths=%d WHERE SteamID='%s'"):format(
            v.kills,
            v.deaths,
            k
        ))
        print("[Tracker] Updated KD Stats for ", k )
        shitToUpdate[k] = {kills = 0, deaths = 0}
    end
end
timer.Create("KD_Tracker_Update", 60, 0, updateTracker)
concommand.Add("kdtracker_force_update", function( ply )
    if not ply:IsSuperAdmin() then return end
    updateTracker()
end)

hook.Add("PlayerDeath","KDTracker",function( pVictim, _, pKiller )
    shitToUpdate[pVictim:SteamID64()] = shitToUpdate[pVictim:SteamID64()] or {
        kills = 0,
        deaths = 0,
    }
    shitToUpdate[pKiller:SteamID64()] = shitToUpdate[pKiller:SteamID64()] or {
        kills = 0,
        deaths = 0,
    }
    addStat(pKiller:SteamID64(),"kills")
    addStat(pVictim:SteamID64(),"deaths")
end)

