--Change Porte Marron V below by your virtual device

commandArray = {}


-- List all otherdevices states for debugging:
--   for i, v in pairs(otherdevices) do print(i, v) end
-- List all otherdevices svalues for debugging:
--   for i, v in pairs(otherdevices_svalues) do print(i, v) end
--

Counter1='CM180i-1 etage/frigo-four/general' -- your co180i multi device
usageid=384 --your virtual device id
Counter2='ERGY Elec' --your virtual device name
voltage=240 --your voltage
if (devicechanged[Counter1]) then

	--456 Watt, 120 Watt, 552 Watt, Total: 5082364.830 Wh
	--T=1.9;0.8;2.6;5082606.047
	l1, l2, l3, tot = otherdevices_svalues[Counter1]:match("([^;]+);([^;]+);([^;]+);([^;]+)")
	c1, c2 = otherdevices_svalues[Counter2]:match("([^;]+);([^;]+)")
	print ("T="..l1.." "..l2.." "..l3.." "..tot.." "..c1.." "..c2)
	wattage=l3*voltage
	t_wattage=c2+wattage
	commandArray['UpdateDevice'] = usageid .. "|0|" .. wattage .. ";" .. t_wattage

end

return commandArray
