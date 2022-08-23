local t1 = os.date("%H") -- get hour time digit

commandArray = {}

-- if t1%23 == 0 then -- only poll at 11pm every day

json = (loadfile "/home/pi/domoticz/scripts/lua/JSON.lua")()  -- For Linux

       --  API call
       local config=assert(io.popen('curl "http://192.168.86.46/json"'))
       local Stringjson = config:read('*all')
       config:close()
       local jsonData = json:decode(Stringjson)

       pm1_0  = jsonData.pm1_0_atm
       pm2_5  = jsonData.pm2_5_atm
       pm10_0 = jsonData.pm10_0_atm

-- print (Stringjson)  -- debug json
 print (pm1_0) -- parsed json value


        commandArray[1]={['UpdateDevice']= 935 .. "|" .. pm1_0 .. "|0" }
        commandArray[2]={['UpdateDevice']= 244 .. "|" .. pm2_5 .. "|0" }
        commandArray[3]={['UpdateDevice']= 245 .. "|" .. pm10_0 .. "|0" }


-- end

return commandArray

