-- Script to alert if a device has not been seen for more than 10mn
--Replace Ping_Cam by your virtual lightswitch device

t1 = os.time()
s = otherdevices_lastupdate['Ping_Cam']
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
if (otherdevices['Ping_Cam'] == 'On') then
  print("ping cam : " .. difference )
  if (difference > 600 and difference < 630) then
	commandArray['SendNotification']='Ping Cam alert#The Ping Cam has been away for more than 10 minutes!'
  end

end 

return commandArray
