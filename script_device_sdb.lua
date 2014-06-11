--Example script to trigger action based on Humidity value
--Replace THGR122 by your device with Humidity value
--Replace SDB-Heat by your heater device

commandArray = {}

if (devicechanged['THGR122_Humidity']) then
  local tmp=devicechanged['THGR122_Temperature']
  local hum=devicechanged['THGR122_Humidity']
  --print ("T=" .. tmp .. " H=" .. hum)
  if (tmp<19 and hum > 70) then 
	commandArray['SDB-Heat']='On FOR 10'
  end
end

return commandArray

