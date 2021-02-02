
SQL is a standard language for storing, manipulating and retrieving data in databases. It can be extremely useful when storing sensitive 
information about a player such as ban records, darkrp money, logs and others of this nature.


1) How to use sqlite within garrysmod.

Garrysmod already has an implemented database (one for each realm/state) and has an sql lib ready to be used so there is nothing you need to install.
The function that is used to execute sql queries is

```lua
sql.Query( string query )
```

2) Usage      

Before you can use sqlite you need to have a table that you can use.
In this example we will create one for storing people's steamid.

We can create a table by using the key words 'CREATE TABLE' but it would better to use 'CREATE TABLE IF NOT EXISTS' so it does not overwrite any tables.
In a query it would look like this,
```lua
sql.Query("CREATE TABLE IF NOT EXISTS steamid_saver( SteamID TEXT , Name TEXT )")
```

The two parameters given are SteamID with the data type TEXT (string) and also their Name which is also stored as a string.


You can insert values into this table using the `INSERT` keyword. In this example I will store their name and steamid when they spawn in.
I'll use the PlayerInitSpawn hook for this.

Garrysmod has a function within the sql lib to filter out the dangerous inputs (sql.SQLStr). The first argument is the string, and the second argument is wether or not you want to remove the quotes which isn't ideal unless you're adding them manually.

NOTE: THIS HOOK CAN ONLY BE USED IN THE SERVER REALM, ON THE CLIENT THIS WILL NOT DO ANYTHING
```lua
hook.Add("PlayerInitSpawn","SteamID_Saver",function( pPlayer )  
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
```


If we wanted to lookup a steamid within the database we would use the 'SELECT' and 'WHERE' keywords.
The syntax for finding specific data is 'SELECT <values> FROM <tablename> WHERE <condition>'
We can create a function for this to make it easier to fetch data instead of using sql.Query every time.

```lua
function getNameBySteamID( SteamID64 )
    if !SteamID64 then return end
    local query = sql.Query(("SELECT Name from steamid_saver WHERE SteamID='%s'"):format( SteamID64 )) or {} -- It may return false if your syntax is incorrect so I added 'or {}' as a fallback
    
    if #query > 0 then
        return query[1].Name -- When selecting data from a database you are returned a table of tables which meet the condition
    end
    return "Player not found!"
end

print( getNameBySteamID( Entity(1):SteamID64() ) ) -- This would print your name at the time of when it was stored
```
