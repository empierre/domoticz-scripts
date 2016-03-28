s = otherdevices_lastupdate['Exterieur']
-- returns a date time like 2013-07-11 17:23:12

year = string.sub(s, 1, 4)
month = string.sub(s, 6, 7)
day = string.sub(s, 9, 10)
hour = string.sub(s, 12, 13)
minutes = string.sub(s, 15, 16)
seconds = string.sub(s, 18, 19)

dte=year*10000+month*100+day
 
commandArray = {}
--commandArray['Variable:aeration_chambres']= "20150701"

if (devicechanged['Exterieur']) then

	if ((devicechanged['Exterieur_Temperature']<otherdevices_temperature['Chambre filles'])
	and(otherdevices_temperature['Chambre filles']>=20)) then
	    if (uservariables["aeration_chambres"] ~= dte) then
		commandArray['SendNotification']='Maison à aerer#Il est temps d aerer la maison'
		commandArray['Variable:aeration_chambres']= tostring(dte)
	    end
	end
	if ((devicechanged['Exterieur_Temperature']>otherdevices_temperature['Chambre filles'])
	and(otherdevices_temperature['Chambre filles']>=20)) then
	    if (uservariables["aeration_chambres2"] ~= dte) then
		commandArray['SendNotification']='Maison à aerer#Il est temps de fermer les fenetres de la maison'
		commandArray['Variable:aeration_chambres2']= tostring(dte)
	    end
	end
end
return commandArray
