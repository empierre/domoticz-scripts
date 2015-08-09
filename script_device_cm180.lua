
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
 
function timeCount(numSec)
   local nSeconds = numSec
   if nSeconds == 0 then
      return  "0seconds"
   else
      local sTime = ""
      local nHours = math.floor(nSeconds/3600)
      local nMins = math.floor(nSeconds/60 - (nHours*60))
      if(nHours > 0) then
         sTime = sTime .. nHours
         if(nHours == 1) then
            sTime = sTime .. "hour "
         else
            sTime = sTime .. "hours "
         end         
      end
      if(nMins > 0) then
         sTime = sTime .. nMins
              if(nMins == 1) then
            sTime = sTime .. "minute "
         else
            sTime = sTime .. "minutes "
         end         
      end
      local nSecs = math.floor(nSeconds - nHours*3600 - nMins *60) 
      if(nSecs > 0) then 
         sTime = sTime .. nSecs
              if(nSecs == 1) then
            sTime = sTime .. "second"
         else
            sTime = sTime .. "seconds"
         end
      end
      return sTime 
   end
end

commandArray = {}


-- List all otherdevices states for debugging:
--   for i, v in pairs(otherdevices) do print(i, v) end
-- List all otherdevices svalues for debugging:
--   for i, v in pairs(otherdevices_svalues) do print(i, v) end
--

Counter1='CM180i-1 etage/frigo-four/general' -- your physical CM180i multi device
Counter2='ERGY Elec' --your virtual device name
usageid2=384 --your virtual curve only device id
Counter3='ERGY Elec total' --your virtual device name
usageid3=385 --your virtual total device id
voltage=240 --your voltage
if (devicechanged[Counter1]) then

	--456 Watt, 120 Watt, 552 Watt, Total: 5082364.830 Wh
	--T=1.9;0.8;2.6;5082606.047
	l1, l2, l3, tot = otherdevices_svalues[Counter1]:match("([^;]+);([^;]+);([^;]+);([^;]+)")
	c1, c2 = otherdevices_svalues[Counter3]:match("([^;]+);([^;]+)")
	--print ("D:"..otherdevices_svalues[Counter3])
	--print ("T="..l1.." "..l2.." "..l3.." "..tot.." "..c1.." "..c2)
	interval = timedifference(otherdevices_lastupdate[Counter1])
	-- convert internal in seconds into hours
	interval = interval / 3600
	wattage=l3*voltage
	t_wattage=c2+wattage*interval
	--print ("E="..wattage.." "..wattage*interval.." "..t_wattage)
	commandArray[1]={['UpdateDevice']= usageid2 .. "|0|" .. wattage }
	commandArray[2]={['UpdateDevice']= usageid3 .. "|0|" .. wattage .. ";" .. t_wattage}

end

return commandArray
