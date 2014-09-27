

-- 点击函数封装
function click(x, y)
	local r = touchDown(0, x, y)
	mSleep(100)
	touchUp(r)
end

function move(x1, y1, x2, y2)
	local r = touchDown(0, x1, y1)
	mSleep(100);
	touchMove(r, x2, y2)
	touchUp(r)
end

function width(w0)
	return w - 1136 + w0;
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

function waitUtilMeetCondition (condition1, callback1, repeatFunctiion) 
	return waitUtilMeetCondition2(condition1, callback1, nil, nil, repeatFunctiion);
end

function waitUtilMeetCondition2 (condition1, callback1, condition2, callback2, repeatFunctiion) 
	return waitUtilMeetCondition3(condition1, callback1, condition2, callback2, nil, nil, repeatFunctiion);
end

function waitUtilMeetCondition3 (condition1, callback1, condition2, callback2, condition3, callback3, repeatFunctiion) 
	local retryCount = 0;
	local  runLoopCount = 0;
	repeat
		if condition1 and condition1() then
			local ret = true;
			if callback1 then
				ret = callback1();
			end

			if ret then
				return true;
			end

		elseif condition2 and condition2() then
			local ret = true;
			if callback2 then
				ret = callback2();
			end
			if ret then
				return true;
			end
		elseif condition3 and condition3() then
			local ret = true;
			if callback3 then
				ret = callback3();
			end
			if ret then
				return true;
			end
		elseif isErrorAlert() or not appIsRunnning() then
			mSleep(1000);	
			do
				return false;
			end
			break;	
		elseif isRetryAlert() then
			retryCount = retryCount + 1;
			if retryCount < 3 then 
				click(w/2, 531);
				mSleep(1000);
			else 
				return false;
			end
		else
			--长时间无响应  0.5 * 2 * 60 * 2 (2分钟)
			runLoopCount = runLoopCount + 1;
			if runLoopCount > 2 * 60 * 1 then
				return false;
			end
			if repeatFunctiion then 
				repeatFunctiion();
			end
			mSleep(500);	
		end
	until false
end


function __moveTo(srcX, srcY, dstX, dstY)
	a = (srcY - dstY)*1.0/(srcX-dstX);
	b = (srcX*dstY - dstX*srcY) * 1.0/(srcX - dstX);
	
	x0 = srcX;			
	repeat
		if srcX < dstX then
			x0 = x0 + 10;			
			if x0 > dstX then				
				break;
			else
				y0 = a * x0 + b;
				touchMove(1, x0, y0);
				mSleep(20);	
			end
		else
			x0 = x0 - 10;			
			if x0 < dstX then				
				break;
			else
				y0 = a * x0 + b;
				touchMove(1, x0, y0);
				mSleep(20);	
			end
		end

	until false	
	touchMove(1, dstX, dstY);		
end

function moveTo(srcX, srcY, dstX, dstY)
	touchDown(1, srcX, srcY);
	mSleep(10);			
	
	__moveTo(srcX, srcY, dstX, dstY);

	touchMove(1, dstX, dstY);

	mSleep(20);	
	touchUp(1);
		
	mSleep(1000);	
end

function isErrorAlert()
	if w == 960 then
		return checkColor(437, 105, 230, 230, 230)	
		and checkColor(510, 106, 230, 230, 230)
		and checkColor(486, 532, 164, 171, 184)
		and checkColor(175, 524, 28, 31, 35)
		and checkColor(482, 102, 230, 230, 230)
		and checkColor(436, 104, 230, 230, 230);
	else 
		return checkColor(525, 105, 230, 230, 230)	
		and checkColor(560, 105, 230, 230, 230)
		and checkColor(571, 534, 165, 172, 185)
		and checkColor(385, 205, 49, 52, 56)
		and checkColor(579, 526, 165, 172, 185);	
	end	
end	

function isNoPacksAlert()
	if w == 960 then
		return checkColor(287, 453, 28, 31, 35)	
		and checkColor(477, 454, 165, 172, 185)
		and checkColor(257, 291, 230, 230, 230)
		and checkColor(522, 292, 230, 230, 230);	
	else 
		return checkColor(392, 455, 28, 31, 35)	
		and checkColor(565, 454, 165, 172, 185)
		and checkColor(465, 292, 230, 230, 230)
		and checkColor(610, 292, 230, 230, 230);	
	end
end	

function isRetryAlert()
	if w == 960 then
		return checkColor(436, 104, 230, 230, 230)	
		and checkColor(489, 107, 230, 230, 230)
		and checkColor(439, 533, 165, 172, 185)
		and checkColor(385, 205, 49, 52, 56)
		and checkColor(510, 106, 230, 230, 230);	
	else 
		return checkColor(525, 105, 230, 230, 230)	
		and checkColor(560, 105, 230, 230, 230)
		and checkColor(544, 531, 165, 172, 185)
		and checkColor(385, 205, 49, 52, 56)
		and checkColor(541, 99, 230, 230, 230);	
	end
end	

function isLincseAgreeAlert()
	if w == 960 then
		return checkColor(231, 160, 49, 52, 57)	
		and checkColor(230, 463, 28, 31, 35)
		and checkColor(533, 464, 251, 209, 62);	
	else 
		return checkColor(344, 284, 53, 56, 60)	
		and checkColor(520, 473, 28, 31, 35)
		and checkColor(630, 472, 250, 202, 55)
		and checkColor(839, 397, 50, 53, 57);		
	end	
end	

--启动界面
function isStartPage()
	if w == 960 then
		return	checkColor(43, 42, 1, 88, 149)	
		and checkColor(780, 144, 199, 33, 47)
		and checkColor(665, 327, 223, 225, 224)
		and checkColor(877, 305, 204, 31, 37);
	else 
		return	checkColor(140, 172, 82, 164, 212)	
		and checkColor(785, 322, 226, 226, 228)
		and checkColor(963, 307, 200, 31, 38)
		and checkColor(896, 151, 252, 252, 252);
	end
end

--选择包类型
function isChoosePackageTypePage()
	if w == 960 then
		return	checkColor(119, 257, 227, 71, 71)	
		and checkColor(362, 218, 1, 1, 2)
		and checkColor(601, 213, 206, 14, 25)
		and checkColor(487, 49, 232, 180, 32)
		and checkColor(486, 116, 255, 255, 255);
	else 
		return	checkColor(113, 22, 41, 46, 57)	
		and checkColor(158, 250, 222, 55, 62)
		and checkColor(693, 221, 210, 15, 29)
		and checkColor(1041, 220, 213, 48, 64)
		and checkColor(524, 51, 232, 180, 32);
	end
end


--球队预览
function isTeamPreviewPage()
	if w == 960 then
		return	checkColor(909, 43, 248, 204, 49)	
		and checkColor(189, 34, 36, 45, 57)
		and checkColor(521, 39, 37, 45, 63);
	else 
		return	checkColor(1089, 40, 248, 204, 49)	
		and checkColor(49, 38, 46, 54, 63)
		and checkColor(550, 34, 42, 49, 63);
	end
end

--球队预览
function isBaseControlPage()
	if w == 960 then
		return	checkColor(69, 37, 35, 46, 57)	
		and checkColor(494, 35, 248, 204, 50)
		and checkColor(913, 42, 248, 204, 50);
	else 
		return	checkColor(89, 40, 35, 42, 53)	
		and checkColor(1082, 47, 250, 206, 49)
		and checkColor(454, 38, 248, 204, 50);
	end
end


--第一场比赛开始
function isFirstMatchStartPage()
	if w == 960 then
		return	checkColor(915, 31, 230, 230, 230)	
		and checkColor(502, 29, 91, 188, 236)
		and checkColor(130, 28, 230, 230, 230);
	else 
		return	checkColor(1103, 31, 230, 230, 230)	
		and checkColor(502, 29, 91, 188, 236)
		and checkColor(130, 29, 230, 230, 230);
	end
end

--暂停页
function isPausePage()
	if w == 960 then
		return	checkColor(72, 192, 230, 230, 230)	
		and checkColor(89, 472, 230, 230, 230)
		and checkColor(499, 473, 230, 230, 230)
		and checkColor(565, 193, 230, 230, 230);
	else 
		return	checkColor(72, 192, 230, 230, 230)	
		and checkColor(89, 472, 230, 230, 230)
		and checkColor(635, 470, 230, 230, 230)
		and checkColor(588, 190, 230, 230, 230);
	end
end

--主界面
function isMainPage()
	if w == 960 then
		return	checkColor(212, 128, 59, 64, 74)	
		and checkColor(866, 124, 230, 230, 230)
		and checkColor(769, 42, 36, 38, 50)
		and (checkColor(851, 128, 230, 230, 230) or checkColor(865, 124, 230, 230, 230));
	else 
		return	checkColor(212, 128, 59, 64, 74)	
		and (checkColor(1000, 126, 230, 230, 230) or checkColor(1016, 126, 230, 230, 230))
		and checkColor(947, 127, 62, 63, 67)
		and checkColor(761, 612, 32, 59, 22)
		and checkColor(115, 613, 28, 44, 15);
	end
end

--my packs
function isMyPacksPage()
	if w == 960 then
		return	checkColor(177, 44, 201, 0, 0)	
		and checkColor(209, 127, 234, 180, 33)
		and checkColor(42, 126, 248, 204, 49);
	else 
		return	checkColor(277, 52, 41, 48, 58)	
		and checkColor(203, 129, 230, 180, 33)
		and checkColor(42, 126, 248, 204, 49);
	end
end

function myPacksIsNotEmpty()
	if w == 960 then
		return	checkColor(68, 216, 243, 218, 103)	
		and checkColor(186, 131,  234, 180, 33)
		and checkColor(891, 534,  246, 203, 72)
		and checkColor(850, 523, 9, 9, 17);
	else 
		return	checkColor(46, 179, 243, 198, 78)	
		and checkColor(924, 529,  249, 211, 86)
		and checkColor(1003, 535, 9, 9, 17)
		and checkColor(957, 530, 9, 9, 17);
	end
end

function isSellAllAlert()
	if w == 960 then
		return checkColor(191, 433,  18, 101, 118)
		and checkColor(183, 500, 28, 31, 35)
		and checkColor(282, 503, 165, 172, 185)
		and checkColor(663, 506, 165, 172, 185);
	else 
		return	checkColor(283, 433,  18, 101, 119)
		and checkColor(276, 499, 28, 31, 35)
		and checkColor(363, 509, 165, 172, 185)
		and checkColor(752, 505, 165, 172, 185);
	end
end

function isRegularPacksPage()
	if w == 960 then
		return	checkColor(41, 124, 248, 204, 49)	
		and checkColor(443, 128,  234, 180, 33)
		and checkColor(869, 411, 248, 205, 75)
		and checkColor(798, 515, 9, 9, 17)
		and checkColor(754, 417, 32, 122, 60);
	else 
		return	checkColor(41, 124, 248, 204, 49)	
		and checkColor(457, 129,  234, 180, 33)
		and checkColor(1058, 411, 247, 204, 74)
		and checkColor(804, 128, 229, 229, 229);
	end
end



function isPackContentPage()
	if w == 960 then
		return	checkColor(810, 220, 248, 210, 83)	
		and checkColor(40, 124,  248, 204, 49)
		and checkColor(370, 124, 248, 204, 50)
		and (checkColor(144, 560, 244, 195, 47) or checkColor(144, 560, 248, 204, 50));
	else 
		return	checkColor(995, 221, 248, 210, 83)	
		and checkColor(39, 124,  248, 204, 49)
		and checkColor(125, 470, 242, 197, 48)
		and checkColor(578, 119, 248, 204, 50)
		and checkColor(1020, 243,  9, 10, 17)
		and checkColor(1087, 224, 247, 201, 71);
	end
end

function isStoreIntroducePage()
	if w == 960 then
		return	checkColor(666, 123, 70, 189, 243)	
		and checkColor(739, 127,  234, 180, 33)
		and checkColor(519, 294, 255, 255, 255);
	else 
		return	checkColor(344, 387, 255, 242, 144)	
		and checkColor(866, 129,  234, 180, 33)
		and checkColor(632, 295, 255, 255, 255);
	end
end

function isTransfersPage()
	if w == 960 then
		return	checkColor(40, 125, 248, 204, 49)	
		and checkColor(906, 135,  248, 204, 49)
		and (checkColor(320, 120, 230, 230, 230) or checkColor(471, 123, 230, 230, 230)) 	
	else 
		return	checkColor(40, 125, 248, 204, 49)	
		and checkColor(1083, 135,  248, 204, 49)
		and checkColor(177, 43, 204, 0, 0)
		and (checkColor(625, 125, 230, 230, 230) or checkColor(882, 128, 230, 230, 230)) ;
	end
end

function isGitterGoldCard()
	if w == 960 then
		return	checkColor(224, 412, 208, 171, 57, 10)	
		and checkColor(259, 205,  220, 172, 36, 10)
		and checkColor(223, 179, 208, 152, 17, 10);
	else 
		return	checkColor(313, 412, 208, 171, 57, 10)	
		and checkColor(352, 214,  231, 192, 52, 10)
		and checkColor(312, 179, 208, 153, 8, 10);
	end
end

function isBlackCard()
	if w == 960 then
		return	false;	
	else 
		return	checkColor(313, 178, 10, 9, 4, 10)	
		and checkColor(352, 210,  29, 24, 18, 10)
		and checkColor(314, 43, 8, 7, 2, 10);
	end
end

function isEnterValuePage()
	if w == 960 then
		return	checkColor(31, 40, 248, 204, 49)	
		and checkColor(524, 38,  248, 204, 50)
		and checkColor(930, 41, 248, 204, 49)
		and checkColor(361, 239, 21, 22, 28) ;
	else 
		return	checkColor(30, 40, 248, 204, 49)	
		and checkColor(519, 38,  248, 204, 50)
		and checkColor(1103, 42, 248, 204, 49)
		and checkColor(333, 252, 21, 22, 28) ;
	end
end

function  isSystemMaintenanceAlert()
	if w == 960 then
		return	false;
	else 
		return	false;
	end
end

function clearAppData() 

	local somefile = "/a"
	local F,err = io.open(somefile,"r+");
	if err or not F then 
		os.execute(string.format("find /var/mobile/Applications -maxdepth 3 -mindepth 3  -name FIFA15_NA.entitlements -size 454c >> %s", somefile));
	end

	local file,err = io.open(somefile,"r+");

	local ourline = file:read()
	io.close(file);

	local appFolder = string.gsub(ourline, "/FIFA14.app/FIFA15_NA.entitlements", "");

	local documentFolder = string.format("%s%s", appFolder, "/Documents");
	local libraryFolder = string.format("%s%s", appFolder, "/Library");

	local  command = string.format("rm -rf %s", documentFolder);
	os.execute (command);

	--command = string.format("rm -rf %s", libraryFolder);
	--os.execute (command);
end

function backupDocumentFolder(findGoodPlayer) 

	local somefile = "/a"
	local F,err = io.open(somefile,"r+");
	if err or not F then 
		os.execute(string.format("find /var/mobile/Applications -maxdepth 3 -mindepth 3  -name FIFA15_NA.entitlements -size 454c >> %s", somefile));
	end

	local file,err = io.open(somefile,"r+");

	local ourline = file:read()
	io.close(file);

	local appFolder = string.gsub(ourline, "/FIFA14.app/FIFA15_NA.entitlements", "");

	local documentFolder = string.format("%s%s", appFolder, "/Documents");

	local  command;
	if findGoodPlayer then
		if w == 960 then
			snapshotRegion(string.format("%s%s", documentFolder, "/1.bmp"), 143, 178, 309, 418, 50);
		else 
			snapshotRegion(string.format("%s%s", documentFolder, "/1.bmp"), 235, 178, 400, 418, 50);
		end
		mSleep(1000);
	 	command = string.format("mv %s \"%s_`date`_\"", documentFolder, documentFolder);

	else
	 	command = string.format("mv %s \"%s_`date`\"", documentFolder, documentFolder);
	end
	os.execute (command);
end

function parseIntFromEngTextInRegion(x1, y1, x2, y2) 
	local code = localOcrText("/tessdata",  -- 语言包tessdata目录在设备中的路径
                                    "eng",  -- 语言类型为中文
                                      x1,  -- 图片左上角X坐标为100
                                      y1,  -- 图片左上角Y坐标为100
                                      x2,  -- 图片右下角X坐标为200
                                      y2,  -- 图片右下角Y坐标为200
                         ""); -- 设置白名单字符串, 只识别数字
    logDebug("识别验证码为："..code);

	s = string.gsub(code, "[^%d]", "");
	
	if s and s ~= "" then
		local  a = tonumber(s);
		if a  then 
			logDebug(string.format("解析为%d", a));
			return a;
		end
	end
	return nil;
end


function parseIntFromRegion(x1, y1, x2, y2, veryfyCode) 
	if not veryfyCode then
		veryfyCode = "0123456789";
	end
	local code = localOcrText("/tessdata",  -- 语言包tessdata目录在设备中的路径
                                    "eng",  -- 语言类型为中文
                                      x1,  -- 图片左上角X坐标为100
                                      y1,  -- 图片左上角Y坐标为100
                                      x2,  -- 图片右下角X坐标为200
                                      y2,  -- 图片右下角Y坐标为200
                         veryfyCode); -- 设置白名单字符串, 只识别数字
    logDebug("识别验证码为："..code);


	local s = string.gsub(code, " ", "");
	s = string.gsub(s, ",", "");
	s = string.gsub(s, "^3", "8");
	s = string.gsub(s, "^5", "6");
	
	if s and s ~= "" then
		local  a = tonumber(s);
		if a  then 
			logDebug(string.format("解析为%d", a));
			return a;
		end
	end
	return nil;
end

function appIsRunnning()
	return appRunning("com.ea.fifa15.bv");
end	

function inputNumber(a)
	local keyLocation = {{x = 190,y=356},
						{x = 565,y=356},
						{x = 953,y=356},								
						{x = 190,y=436},
						{x = 565,y=436},
						{x = 953,y=436},
						{x = 190,y=514},
						{x = 565,y=514},
						{x = 953,y=514},
						{x = 475,y=600}};
	local  s = string.format("%d", a);
	local strLen = string.len(s);				
	for i = 1, strLen do  
		local key = tonumber(string.sub(s, i, i));  
		if key then
			if key == 0 then 
				key = 10;
			end							
			local location = keyLocation[key];
			if location then						
				click(location.x, location.y);
				mSleep(500);	
			end						
		end						
	end 
end


UI = {
        { 'TextView{-球员筛选条件-}'                   },
        { 'InputBox{80}',             'minRattingStr',    '球员评价大于:' },
        { 'InputBox{4000}',    	'minMoneyStr',     '球员价值大于:' },
        { 'DropList{否|是}',    'backupStr', '保留存档循环执行:' },
        { 'DropList{俱乐部物品|球员|球队职员|消耗品}',    'transfer', '转移球员使用:' },
};


-- 主入口函数
function main()
    rotateScreen(-90);

    local  minRatting = tonumber(minRattingStr);
    local  minMoney = tonumber(minMoneyStr);
    local  backup = (backupStr == "是")

    local findGoodPlayer = false;

	-- 将屏幕宽度和高度分别保存在变量w、h中				
	w, h = getScreenResolution();  
		
	mSleep(1000);	

	::restart::		

	local noError = false;
			
	appKill("com.ea.fifa15.bv");
	mSleep(1000);	

	if not findGoodPlayer then
		--clearAppData();
	end
	mSleep(1000);
	appRun("com.ea.fifa15.bv");
	mSleep(1000);
	
	--notifyVibrate(1000)	

	noError = waitUtilMeetCondition2(isLincseAgreeAlert, function ()
			if w == 960 then
				click(632, 478);
			else
				click(716, 475);
			end
			return true;
		end, isStartPage, function ()
			return true;
		end);

	local shouldGotoMainPage = false;

	noError = waitUtilMeetCondition3(isStartPage, function ()
			click(50, 50);
			return false;
		end,
		isChoosePackageTypePage, function ()
			mSleep(500);
			noError = waitUtilMeetCondition(function ()
				if w == 960 then
					return checkColor(598, 367, 248, 204, 50) or isTeamPreviewPage();
				else
					return checkColor(686, 367, 237, 195, 49) or isTeamPreviewPage();
				end
			end, function ()
				if w == 960 then
					click(592, 363);
				else
					click(698, 368);
				end
				return true;
			end, function ()
				if w == 960 then
					click(592, 363);
				else
					click(698, 368);
				end
			end);

			mSleep(1000);
			return true;
		end,
		isMainPage, function ()
			shouldGotoMainPage = true;
			return true;
		end,
		function ()
			click(50, 50);
		end);

	if shouldGotoMainPage then
		goto mainPage;
	end

	noError = waitUtilMeetCondition(isTeamPreviewPage, function ()
			click(width(1089), 40);
			mSleep(500);
			return true;
		end);


	noError = waitUtilMeetCondition(isBaseControlPage, function ()
			--点击两次，一次有时候不成功
			mSleep(500);
			click(width(1089), 40);
			mSleep(500);
			click(width(1089), 40);
			mSleep(500);
			return true;
		end);


	noError = waitUtilMeetCondition(isFirstMatchStartPage, function ()
			click(width(1097), 28);
			mSleep(500);
			return true;
		end, 
		function ()
			click(50, 50);
		end);

	if not noError then
		goto restart;
	end

	noError = waitUtilMeetCondition(isPausePage, function ()
			--退出
			click(828, 517);
			mSleep(1000);
			--确认退出
			click(734, 498);
			mSleep(1000);
			return true;
		end);

	if not noError then
		goto restart;
	end

	::mainPage::

	noError = waitUtilMeetCondition(isMainPage, function ()
			mSleep(800);
			--点击store
			if w == 960 then
				click(715, 130);
				mSleep(1000);
			else
				click(840, 130);
			end
			mSleep(2000);
			--点击my packs
			click(288, 517);
			mSleep(1000);
			return true;
		end);

	local  noPacks = false;
	noError = waitUtilMeetCondition2(isMyPacksPage, function ()
		return true;
	end, isNoPacksAlert, function ()
		noPacks = true;
		return true;
	end);

	if not noError or noPacks then
		goto restart;
	end

	local money = 0;

	noError = waitUtilMeetCondition3(myPacksIsNotEmpty, function ()
			logDebug("myPacksIsNotEmpty");
			mSleep(500);
			--点击开包
			click(width(998), 532);
			mSleep(1000);

			noError = waitUtilMeetCondition (isPackContentPage);
			if not noError then
				return true;
			end

			logDebug("isPackContentPage");

			mSleep(500);

			--点击全部出售
			click(width(995), 335);
			mSleep(1000);

			noError = waitUtilMeetCondition (isSellAllAlert);
			if not noError then
				return true;
			end

			local rating;
			
			if w == 960 then
				rating = parseIntFromRegion(155, 202, 191, 227);
			else
				rating = parseIntFromRegion(240, 201, 280, 229);
			end

			local moneyPerPack;
			if w == 960 then
				moneyPerPack = parseIntFromEngTextInRegion(372, 349, 871, 392);
				mSleep(500);
			else
				moneyPerPack = parseIntFromEngTextInRegion(461, 351, 958, 392);
			end

			if not moneyPerPack then
				moneyPerPack = 0;
			end

			money = money + moneyPerPack;
			
			if rating and rating > minRatting and (isGitterGoldCard() or isBlackCard()) 
			or moneyPerPack > minMoney then
				notifyVibrate(3000);
				findGoodPlayer = true;
				if backup then
					backupDocumentFolder(true);
					mSleep(1000);
					return true;
				end
			else 
				--确定
				click(767, 500);
				mSleep(1000);
			end

			return false;
		end,
		isRegularPacksPage, function ()
			--点击返回
			click(41, 124);
			mSleep(500);
			return true;
		end, isStoreIntroducePage, function ()
			click(50, 50);
			mSleep(1000);
			return false;
		end);
	
	if not noError then
		goto restart;
	end

	if backup then
		if findGoodPlayer then
			findGoodPlayer = false;
			notifyVibrate(2000);
		else
			backupDocumentFolder(false);
			mSleep(1000);
		end
		goto restart;
	else
		notifyVibrate(2000);
	end

	local hasEnterTransferList = false;

	if w == 960 then
		mSleep(2000);
	end

	noError = waitUtilMeetCondition2(isMainPage, function ()
			mSleep(500);
			--点击transfers
			if w == 960 then
				click(499, 130);
			else
				click(424, 130);
			end
			mSleep(500);


			noError = waitUtilMeetCondition(function ()
				local ok =  isMainPage();
				if ok then
					if w == 960 then
						ok = checkColor(397, 127, 234 ,180 , 33);
					else
						ok = checkColor(587, 186, 230 ,230 , 230)
						and checkColor(44, 181, 230 ,230 , 230);
					end
				end 
				return ok;
			end);

			if findGoodPlayer and not hasEnterTransferList then
				hasEnterTransferList = true;
				--transfer list
				click(305, 513);
				mSleep(500);
				return false;
			else
				mSleep(500);
				--market
				click(305, 301);
				mSleep(500);
				return true;
			end
		end, 
		isStoreIntroducePage, function ()
			click(50, 50);
			mSleep(1000);
			return false;
		end);


	if not noError then
		goto restart;
	end

	noError = waitUtilMeetCondition(isTransfersPage, function ()
			mSleep(1000);

			if w == 960 then
				--俱乐部物品|球员|球队职员|消耗品
				if transfer == "球员" then
					click(134, 127);
				elseif transfer == "球队职员" then
					click(319, 129);
				elseif transfer == "消耗品" then
					click(465, 129);
				else    --俱乐部物品
					click(750, 127);
				end
			else
				--俱乐部物品|球员|球队职员|消耗品
				if transfer == "球员" then
					click(169, 128);
				elseif transfer == "球队职员" then
					click(389, 128);
				elseif transfer == "消耗品" then
					click(581, 128);
				else    --俱乐部物品
					click(882, 128);
				end
			end


			mSleep(1000);
			return true;
		end);

	noError = waitUtilMeetCondition(function ()
		local ok = isTransfersPage();
		if ok then
			if w == 960 then
				--俱乐部物品|球员|球队职员|消耗品
				if transfer == "球员" then
					return (checkColor(134, 127, 234, 180, 33) and checkColor(191, 131, 234, 180, 33))
				elseif transfer == "球队职员" then
					return (checkColor(319, 129, 234, 180, 33) and checkColor(349, 129, 234, 180, 33))
				elseif transfer == "消耗品" then
					return (checkColor(465, 129, 234, 180, 33) and checkColor(560, 127, 234, 180, 33))
				else    --俱乐部物品
					return (checkColor(688, 126, 234, 180, 33) and checkColor(750, 129, 234, 180, 33))
				end

			else
				--俱乐部物品|球员|球队职员|消耗品
				if transfer == "球员" then
					return (checkColor(169, 129, 234, 180, 33) and checkColor(255, 127, 234, 180, 33))
				elseif transfer == "球队职员" then
					return (checkColor(389, 123, 234, 180, 33) and checkColor(437, 130, 234, 180, 33))
				elseif transfer == "消耗品" then
					return (checkColor(581, 127, 234, 180, 33) and checkColor(665, 128, 234, 180, 33))
				else    --俱乐部物品
					return (checkColor(828, 129, 234, 180, 33) and checkColor(903, 126, 234, 180, 33))
				end
			end

		end

		return false;

	end, function ()
			--最大价格
			click(width(1079), 261);
			mSleep(500);

			if findGoodPlayer or money == 0 then
				if w == 960 then
					money = parseIntFromRegion(564, 61, 655, 85, "0123456789,");
				else
					money = parseIntFromRegion(745, 65, 830, 85, "0123456789,");
				end
			end

			if money == nil then
				money = 6000;
			end

			mSleep(500);

			--最小一口
			click(width(983), 328);
			mSleep(500);

			noError = waitUtilMeetCondition(isEnterValuePage, function ()
					mSleep(1000);
					--if w == 960 then
					--	inputText(money);
					--else
						inputNumber(money);
					--end
					--点击确定
					mSleep(500);
					click(width(1104), 43);
					mSleep(1000);
					return true;
				end);

			click(width(1079), 392);
			mSleep(500);

			return true;
		end);

	if noError then
		notifyVibrate(2000);
	else
		goto restart;
	end
	

	::over::		
end





















