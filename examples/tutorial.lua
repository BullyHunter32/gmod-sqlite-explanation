sql.Query("CREATE TABLE IF NOT EXISTS steamid_saver( SteamID TEXT , Name TEXT )")

hook.Add("PlayerSpawn","SteamID_Saver",function( pPlayer )  
    if sql.Query(("SELECT * FROM steamid_saver WHERE SteamID='%s'"):format( pPlayer:SteamID64() )) then 
        print( pPlayer:Name(), " is already stored!")
        return 
    end
    print("Storing player ".. pPlayer:Name() )
    sql.Query(("INSERT INTO steamid_saver( SteamID , Name ) VALUES( %s , %s )"):format( -- Its more convenient to format the string so it doesn't get messy.
        sql.SQLStr(pPlayer:SteamID64()),
        sql.SQLStr(pPlayer:Name())
    ))
end)

function getNameBySteamID( SteamID64 )
    if !SteamID64 then return end
    local query = sql.Query(("SELECT Name from steamid_saver WHERE SteamID='%s'"):format( SteamID64 )) or {}
    if #query > 0 then
        return query[1].Name -- When selecting data from a database you are returned a table of tables which meet the condition
    end
    return "Player not found!"
end

print( getNameBySteamID( Entity(1):SteamID64() ) )
