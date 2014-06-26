-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- version 2 as published by the Free Software Foundation.
-- Author: epierre

-- MAnages to send only one notificatio on an interval of time through a virtual switch

t1 = os.time()
s = otherdevices_lastupdate['Sensor1']
-- returns a date time like 2013-07-11 17:23:12
year = string.sub(s, 1, 4)
month = string.sub(s, 6, 7)
day = string.sub(s, 9, 10)
hour = string.sub(s, 12, 13)
minutes = string.sub(s, 15, 16)
seconds = string.sub(s, 18, 19)

commandArray = {}
t2 = os.time{year=year, month=month, day=day, hour=hour, min=minutes, sec=seconds}
difference = (os.difftime (t1, t2))

if ((devicechanged['PIR_V'] == 'On')and(otherdevices['Sensor1'] == 'On')) then
	commandArray['Sensor1']='On'
end

if ((devicechanged['PIR_V'] == 'On')and(otherdevices['Sensor1'] == 'Off')) then
	commandArray['Sensor1']='On'
	commandArray['SendNotification']='Whatever !'
end

if ((devicechanged['PIR_V'] == 'Off')and(otherdevices['Sensor1'] == 'On')) then
	if (difference >= 900) then
		commandArray['Sensor1']='Off'
    end
end
if ((otherdevices['PIR_V'] == 'Off')and(otherdevices['Sensor1'] == 'On')and(difference>=900)) then
	commandArray['Sensor1']='Off'
end
return commandArray

