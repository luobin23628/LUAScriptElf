function click(x, y)
	local r = touchDown(0, x, y);
	touchUp(r, x, y);
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
]]--

appRun("com.ea.fifa15.bv");

end