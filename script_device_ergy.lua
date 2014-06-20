

function timedifference(s)
   year = string.sub(s, 1, 4)
   month = string.sub(s, 6, 7)
   day = string.sub(s, 9, 10)
   hour = string.sub(s, 12, 13)
   minutes = string.sub(s, 15, 16)
   seconds = string.sub(s, 18, 19)
   t1 = os.time()
   t2 = os.time{year=year, month=month, day=day, hour=hour, min=minutes, sec=seconds}
   difference = os.difftime (t1, t2)
   return difference
end


commandArray = {}
-- initialize libraries
local sqlite3 = require("luasql.sqlite3")
env = assert(sqlite3.sqlite3())
-- initialize vars
local s=0
local hamt
local switchid=91
local usageid=128
local wattage=700

if (devicechanged['FGS211'] == 'Off') then
	con = assert (env:connect("/home/pi/domoticz/domoticz.db") )

	cur = assert (con:execute('select Date from LightingLog where DeviceRowID='..switchid..' and nValue=1 order by Date desc limit 1'))
	row = cur:fetch ({}, "a")
	s=row.Date
	cur:close()
	con:close()

	difference = timedifference(s)

	con = assert (env:connect("/home/pi/domoticz/domoticz.db") )
	cur = assert (con:execute('select Value from Meter where DeviceRowID='..usageid..' order by Date desc limit 1'))
	row = cur:fetch ({}, "a")
	hamt=row.Value/100
	cur:close()

	con:close()
	env:close()


	local amt=math.floor(difference*(wattage/3600)+0.5)/1000
	local famt=hamt+amt
	print ("T="..t1.." T0="..t2.." "..s.." %"..difference.." - "..hamt.." + "..amt.."="..famt)
	commandArray['UpdateDevice'] = usageid .. "|0|" .. 0 .. ";" .. famt
end 

if (devicechanged['FGS211'] == 'On') then
	con = assert (env:connect("/home/pi/domoticz/domoticz.db") )

	cur = assert (con:execute('select Date from LightingLog where DeviceRowID='..switchid..' and nValue=1 order by Date desc limit 1'))
	row = cur:fetch ({}, "a")
	s=row.Date
	cur:close()
	con:close()

	difference = timedifference(s)

	con = assert (env:connect("/home/pi/domoticz/domoticz.db") )
	cur = assert (con:execute('select Value from Meter where DeviceRowID='..usageid..' order by Date desc limit 1'))
	row = cur:fetch ({}, "a")
	hamt=row.Value/100
	cur:close()

	con:close()
	env:close()


	local amt=math.floor(difference*(wattage/3600)+0.5)/1000
	local famt=hamt+amt
	print ("T="..t1.." T0="..t2.." "..s.." %"..difference.." - "..hamt.." + "..amt.."="..famt)
	commandArray['UpdateDevice'] = usageid .. "|0|" .. wattage .. ";" .. famt
end 

return commandArray


