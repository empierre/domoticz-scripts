--Change Porte Marron V below by your virtual device



t1 = os.time()
s = otherdevices_lastupdate['Porte Marron V']
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
if (otherdevices['Porte Marron V'] == 'On') then
  print("porte marron : " .. difference )
  if (difference > 300 and difference < 400) then
	commandArray['SendNotification']='Garage door alert#The garage door has been open for more than 5 minutes!'
  end

end 

return commandArray
