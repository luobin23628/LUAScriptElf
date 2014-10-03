function click(x, y)
	local r = touchDown(0, x, y);
	touchUp(r, x, y);
end

function checkColor(x2,y2,r,g,b,wc)
	wc = wc or 5;        
	local r1, g1, b1 = getColorRGB(x2,y2);
	logDebug("x2, y2, r, g, b = "..x2..","..y2..","..r..","..g..","..b);
	logDebug("r1, g1, b1 = "..r1..","..g1..","..b1);
	
	if (r<=r1+wc and r>=r1-wc) and (g<=g1+wc and g>=g1-wc) and (b<=b1+wc and b>=b1-wc) then
        return true
	else
		return false
	end
end

function main()
--[[
    logDebug("hello word");
    click(50, 50);
    click(200, 200);
    logDebug("hello word2");
    
    mSleep(10000);
    notifyMessage("testtesttest", 3000);
    
    notifyVibrate(5000);

    local c = getColor(100, 10);
    logDebug(string.format("%d", c));

    
    local r, g, b = getColorRGB(100, 10);
    logDebug(string.format("%d, %d, %d", r, g, b));

    local x, y = findColorFuzzy(0xFFFFFF)
    logDebug(string.format("%d, %d", x, y));

    
    local x, y = findColorInRegion(0xFFFFFF, 100, 100, 200, 200);
    logDebug(string.format("%d, %d", x, y));



    appKill("com.luobin.TestLUA.TestLUA");

    local w, h = getScreenResolution();
    logDebug(string.format("%d, %d", w, h));


appRun("com.ea.fifa15.bv");
]]--
    notifyMessage("testtesttest", 3000);



end