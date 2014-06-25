-- demo time script

s = os.date("*t")

--print ("hour:" .. s.hour .. ":" .. s.min);

commandArray = {}

if (s.hour == "23") and (s.min =="1") then
	os.execute('/home/pi/cam_linkage.pl 14')
	print("it is 23:01")
end 
if (s.hour == "7") and (s.minutes == "1") then
	os.execute('/home/pi/cam_linkage.pl 0')
	print("it is 07:01")
end 
if (s.hour == "8") and (s.minutes == "1") then
	os.execute('/home/pi/cam_linkage.pl 14')
	print("it is 08:01")
end 
if (s.hour == "17") and (s.minutes == "1") then
	os.execute('/home/pi/cam_linkage.pl 0')
	print("it is 17:01")
end 

return commandArray
