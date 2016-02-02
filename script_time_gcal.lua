id ="(CAL) "
 debug = false
 LUAevents = false

 tmpdir = "/var/tmp/"
 months={Jan=1,Feb=2,Mar=3,Apr=4,May=5,Jun=6,Jul=7,Aug=8,Sep=9,Oct=10,Nov=11,Dec=12}
printf = function(s,...) return print(id..s:format(...)) end

 function recode(str1,str2) -- a calendar date string to mddhhmm
   v=tonumber(str1:sub(6,7)..str1:sub(9,10)..str2:sub(1,2)..str2:sub(4,5))
   if debug then printf("recode: %q -> %s",str1.." "..str2,v) end
   return v
 end

function mysplit(inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={} ; i=1
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                t[i] = str
                i = i + 1
        end
        return t
end

 function trim(s) return (s:gsub("^%s*(.-)%s*$", "%1")) end
function loadstring(str,name) -- omit this function if your domoticz supports it natively
   local file = tmpdir.."loadstring.tmp"
   local f,err=io.open(file,"w")
   if not f then
     printf("Can't open %s (%s)",file,err)
   else
     f:write(str)
     f:close()
     f,err=loadfile(file)
     if f then f,err=f()
       if debug then printf('f() returns %s and err %s',f,err) end
     end
   end
   return f,err
 end

 commandArray = {}
 LUAevent = false -- an LUA event has been processed
 now=os.date("*t")
 t=now.month*1000000+now.day*10000+now.hour*100+now.min -- now in mddhhmm format

 listing=tmpdir.."gcalt.txt" fhnd,err=io.open(listing)
 if fhnd then
   fhnd:lines() fhnd:lines()
   for line in fhnd:lines() do if debug then printf("%s",line) end
-- format is device=setting,date-range
       linesplit={}
       linesplit=mysplit(line,"\t")
       s=recode(linesplit[1],linesplit[2]) e=recode(linesplit[3],linesplit[4]) -- start & end time
       if debug then printf("Start: %s  End: %s  Now: %s",s,e,t) end
       if (t>=s and (t<=e or s>e)) then -- if this event is current
           cA=commandArray od=otherdevices odsv=otherdevices_svalues -- abbreviations
               spl=mysplit(linesplit[5],"=")
               commandArray[spl[1]]=spl[2]
               if debug then printf("Run:"..spl[1].." "..spl[2]) end
     end
   end
   fhnd:close()
 else
   printf("Can't open Calendar listing file: %s (%s)",listing,err)
 end

 if debug or LUAevent then for i,v in pairs(commandArray) do printf("commandArray[%q] =  %q",i,v) end end

 return commandArray
