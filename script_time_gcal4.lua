    --[[ script_time_calendar.lua based on an original idea by epierre

    Scans the results of a calendar listing for today and issues commandArray
    settings. Calendar entries must be of the form: devicename=setting

    The event is only actioned if the device setting needs to be changed,
    that is, if Light3 is already On then the Calendar entry "Light3=On" will not
    be actioned. You can change this behaviour by commenting out the test marked xxx so
    that each command is issued every minute whether it needs to be or not.

    The not-so-small print:

    The calendar events can be up to a year in duration and no more.

    No checks are made that the calendar entries you specify are valid. Though errors
    won't break Domoticz they may prevent other calendar entries that are due from
    being actioned.

    Don't use it for safety-critical applications.
    Don't use it to turn on heaters or machinery if no one is present to deal with
     the consequences.
    If you don't keep your calendar private others can control your Domoticz and
     mess with your stuff.

    No claim is made that this code fit for your purpose, I know only that it works for
    me. If the software breaks, your only entitlement is to keep all the pieces.

    Now the fun bit... --]]

    months={Jan=1,Feb=2,Mar=3,Apr=4,May=5,Jun=6,Jul=7,Aug=8,Sep=9,Oct=10,Nov=11,Dec=12}

    function GetFiles(mask)
      local files = {}
      local f = io.open(mask)

      if f then
        local k = 1
        for line in f:lines() do
          files[k] = line
          k = k + 1
        end
        f:close()
      end
      return files
    end

    function recode(str) -- a calendar date string to mmddhhmm
      m=months[str:sub(1,3)]
      v=tonumber(m..str:sub(5,6)..str:sub(8,9)..str:sub(11,12))
      --print("recode: "..str.." -> "..v)
      return v
    end

    commandArray = {}
    now=os.date("*t")
    t=now.month*1000000+now.day*10000+now.hour*100+now.min -- now time as mmddhhmm
    result=GetFiles("/var/tmp/gcalt.txt")
    for key,value in pairs(result) do
    --print(value)
      i, j = string.find(value, "=", 1) -- look for "=" in device=setting,date-range
      if i then
        device = value:sub(1,j-1)
        k, l = string.find(value, ",", j+1) setting = value:sub(j+1,k-1)
        range=value:sub(l+1)       -- get date range
        s=recode(range:sub(1,12))  -- start time
        e=recode(range:sub(16))    -- end time
    --    print(key,value,s,e,t)
        if   (t>=s and (t<=e or s>e))
        and  (otherdevices[device] ~= setting) -- xxx
        then commandArray[device]=setting
             print("(CAL) Setting " .. value)
        end
      end
    end

    return commandArray
