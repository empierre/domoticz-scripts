local t1 = os.date("%H") -- get hour time digit

commandArray = {}

-- if t1%23 == 0 then -- only poll at 11pm every day

json = (loadfile "/home/pi/domoticz/scripts/lua/JSON.lua")()  -- For Linux

       --  API call
       local config=assert(io.popen('curl "http://192.168.86.249/api/getRadiation"'))
       local Stringjson = config:read('*all')
       config:close()
       local jsonData = json:decode(Stringjson)

       cpm  = math.floor(jsonData.cpm)
       val  = math.floor(jsonData.value)

-- print (Stringjson)  -- debug json
-- print (cpm) -- parsed json value
-- print (val) -- parsed json value


        commandArray[1]={['UpdateDevice']= 968 .. "|" .. 0 .. "|".. val }
        commandArray[2]={['UpdateDevice']= 969 .. "|" .. 0 .. "|" .. cpm }


-- end

return commandArray

