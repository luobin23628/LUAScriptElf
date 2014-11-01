

-- 点击函数封装
function click(x, y)
	local r = touchDown(0, x, y)
	mSleep(100)
	touchUp(r, x, y)
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
		return waitUtilMeetCondition4(condition1, callback1, condition2, callback2, condition3, callback3, nil, nil, repeatFunctiion);
end

function setWaitLoopCount(count)
	loopCount = count;
end

function waitUtilMeetCondition4 (condition1, callback1, condition2, callback2, condition3, callback3, condition4, callback4, repeatFunctiion) 
	local retryCount = 0;
	local  runLoopCount = 0;
	if not loopCount then
		loopCount = 2 * 60 * 1;
	end
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
		elseif condition4 and condition4() then
			local ret = true;
			if callback4 then
				ret = callback4();
			end
			if ret then
				return true;
			end
		elseif isErrorAlert() or not appIsRunnning() then
			if isErrorAlert() then
				--mSleep(500);
				--click(w/2, 529);
			end
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
			if runLoopCount > loopCount then
				logDebug(string.format("runLoopCount > loopCount %d > %d", runLoopCount, loopCount));
				return false;
			end
			if repeatFunctiion then 
				repeatFunctiion();
			end
			mSleep(500);	
		end
	until false
end


function __moveTo(id, srcX, srcY, dstX, dstY, step)
	if not step or step == 0 then
		step = 20;
	end

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
				touchMove(id, x0, y0);
				mSleep(step);	
			end
		else
			x0 = x0 - 10;			
			if x0 < dstX then				
				break;
			else
				y0 = a * x0 + b;
				touchMove(id, x0, y0);
				mSleep(step);	
			end
		end

	until false	
	touchMove(id, dstX, dstY);
end

function moveTo(srcX, srcY, dstX, dstY)
	local id = touchDown(0, srcX, srcY);
	mSleep(10);			
	
	__moveTo(id, srcX, srcY, dstX, dstY);

	touchMove(id, dstX, dstY);

	mSleep(20);	
	touchUp(id, dstX, dstY);
		
	mSleep(1000);	
end

function isErrorAlert()
	if w == 960 then
		return checkColor(437, 105, 230, 230, 230)	
		and checkColor(339, 307, 230, 230, 230)
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

function isSecurityVerificationPage()
	if w == 960 then
		return	checkColor(334, 40, 248, 204, 50)	
		and checkColor(508, 38, 248, 204, 50)
		and checkColor(928, 41, 248, 204, 50)
		and checkColor(390, 101, 21, 22, 28);
	else 
		return	checkColor(496, 140, 248, 204, 50)	
		and checkColor(689, 41, 248, 204, 50)
		and checkColor(1102, 47, 248, 204, 50)
		and checkColor(390, 101, 21, 22, 28);
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
function isFirstPausePage()
	if w == 960 then
		return	checkColor(72, 192, 230, 230, 230)	
		and checkColor(89, 472, 230, 230, 230)
		and checkColor(499, 473, 230, 230, 230)
		and checkColor(565, 193, 230, 230, 230);
	else 
		return checkColor(72, 192, 230, 230, 230)	
		and checkColor(89, 472, 230, 230, 230)
		and checkColor(635, 470, 230, 230, 230)
		and checkColor(588, 190, 230, 230, 230);
	end
end

--暂停页
function isPausePage()
	if w == 960 then
		return	checkColor(273, 191, 210, 210, 211)	
		and checkColor(587, 193, 230, 230, 230)
		and checkColor(500, 347, 230, 230, 230)
		and checkColor(535, 503, 230, 230, 230);
	else 
		return checkColor(317, 191, 210, 210, 211)
		and checkColor(587, 345, 230, 230, 230)
		and checkColor(587, 195, 230, 230, 230)
		and checkColor(623, 501, 230, 230, 230);
	end
end

--主界面
function isMainPage()
	if w == 960 then
		return	checkColor(866, 124, 230, 230, 230)
		and checkColor(769, 42, 36, 38, 50)
		and (checkColor(851, 128, 230, 230, 230) or checkColor(865, 124, 230, 230, 230));
	else 
		return (checkColor(1000, 126, 230, 230, 230) or checkColor(1016, 126, 230, 230, 230))
		and checkColor(947, 127, 62, 63, 67)
		and checkColor(761, 612, 32, 59, 22)
		and checkColor(115, 613, 28, 44, 15);
	end
end

function isMainPageSelectClub()
	if w == 960 then
		return	isMainPage()	
		and checkColor(566, 127, 234, 180, 33) 
		and checkColor(135, 184, 229, 229, 229);
	else 
		return	isMainPage()	
		and (checkColor(678, 128, 234, 180, 33) or checkColor(666, 128, 234, 180, 33)) 
		and checkColor(604, 328, 229, 229, 229);
	end
end

function isMainPageSelectHome()
	if w == 960 then
		return	isMainPage()	
		and checkColor(78, 129, 234, 180, 33);
	else 
		return	isMainPage()	
		and checkColor(105, 128, 234, 180, 33) or checkColor(105, 126, 234, 180, 33);
	end
end

--赛季选择页
function isSeasonSelectionPage()
	if w == 960 then
		return	checkColor(40, 125, 248, 204, 49)	
		and checkColor(388, 124, 248, 204, 49)
		and checkColor(576, 125, 248, 204, 49)
		and checkColor(901, 131, 248, 204, 49);
	else 
		return	checkColor(40, 125, 248, 204, 49)	
		and checkColor(476, 124, 248, 204, 49)
		and checkColor(457, 126, 248, 204, 49)
		and checkColor(1072, 134, 248, 204, 49);
	end
end

--赛季页
function isSeasonPage()
	if w == 960 then
		return	checkColor(30, 115, 248, 204, 49)	
		and checkColor(286, 121, 234, 180, 33)
		and checkColor(368, 121, 234, 180, 33)
		and checkColor(913, 118, 248, 204, 49);
	else 
		return	checkColor(30, 115, 248, 204, 49)	
		and checkColor(345, 118, 234, 180, 33)
		and checkColor(426, 121, 234, 180, 33)
		and checkColor(1087, 119, 248, 204, 49);
	end
end

function isEndSeasonEarlyAlert()
	if w == 960 then
		return checkColor(348, 176, 230, 230, 230)	
		and checkColor(530, 175, 230, 230, 230)
		and checkColor(415, 463, 28, 31, 35);	
	else 
		return checkColor(437, 177, 230, 230, 230)	
		and checkColor(618, 177, 230, 230, 230)
		and checkColor(538, 312, 229, 229, 229)
		and checkColor(571, 464, 165, 172, 185);	
	end
end	

function isEndSeasonEndAlert()
	if w == 960 then
		return checkColor(394, 173, 230, 230, 230)	
		and checkColor(476, 462, 165, 172, 185)
		and checkColor(353, 320, 230, 230, 230);
	else 
		return checkColor(483, 175, 230, 230, 230)	
		and checkColor(421, 462, 165, 172, 185)
		and checkColor(633, 459, 255, 255, 255);	
	end
end	

--我的球队页
function isMySquadPage()
	if w == 960 then
		return	checkColor(33, 39, 248, 204, 49)	
		and checkColor(227, 41, 234, 180, 33)
		and checkColor(352, 45, 234, 180, 33)
		--and checkColor(913, 42, 248, 204, 49);
	else 
		return	checkColor(33, 39, 248, 204, 49)	
		and checkColor(287, 41, 234, 180, 33)
		and checkColor(411, 42, 234, 180, 33)
		and checkColor(729, 42, 230, 230, 230);
	end
end

--快速模拟页
function isQuickSimulationPage()
	if w == 960 then
		return	checkColor(33, 39, 248, 204, 49)	
		and checkColor(243, 564, 247, 204, 50)
		and checkColor(806, 568, 247, 204, 50);
	else 
		return	checkColor(33, 39, 248, 204, 49)	
		and checkColor(286, 562, 247, 204, 50)
		and checkColor(819, 566, 247, 204, 50);
	end
end

--skill detail页
function isSkillDetailPage()
	if w == 960 then
		return checkColor(218, 44, 234, 180, 33)
		and checkColor(395, 44, 230, 230, 230)
		and checkColor(917, 38, 248, 204, 49);
	else 
		return checkColor(214, 45, 234, 180, 33)
		and (checkColor(523, 42, 230, 230, 230) or checkColor(522, 42, 230, 230, 230))
		and checkColor(1088, 43, 248, 204, 49);
	end
end

function isFinalScorePage()
	if w == 960 then
		return checkColor(395, 39, 248, 204, 49)
		and checkColor(536, 38, 248, 204, 49)
		and checkColor(914, 42, 248, 204, 49);
	else 
		return checkColor(482, 38, 248, 204, 49)
		and checkColor(624, 41, 248, 204, 49)
		and checkColor(1088, 43, 248, 204, 49);
	end
end

function moveSubstifutionPlayerTo(srcX, srcY, dstX, dstY)
	local id = touchDown(1, srcX, srcY);
	mSleep(10);			

	__moveTo(id, srcX, srcY, dstX - 30, dstY - 30);

	touchMove(id, dstX - 30, dstY + 50);

	mSleep(20);	
	touchUp(id, dstX - 30, dstY + 50);

	mSleep(1000);	
end

function exchangeSubstifutionPlayerIfNeed(x, y) 
		local offset;
		
		if w == 1136 then
			offset = 176;
		else
			offset = 0;
		end	

		--预备队员最后一个开始		
		if not checkColor(731 + offset, 525, 155, 3, 0, 10) 
			and  not checkColor(731 + offset, 525, 79, 79, 79, 10) 
			and  not checkColor(731 + offset, 525, 201, 191, 191, 20) then 
			moveSubstifutionPlayerTo(731 + offset, 525, x, y);			
		elseif not checkColor(635 + offset, 525, 155, 3, 0, 10) 
			and  not checkColor(635 + offset, 525, 79, 79, 79, 10) 
			and  not checkColor(635 + offset, 525, 201, 191, 191, 20) then
			moveSubstifutionPlayerTo(635 + offset, 525, x, y);			
		elseif not checkColor(539 + offset, 525, 155, 3, 0, 10) 
			and  not checkColor(539 + offset, 525, 79, 79, 79, 10)
			and  not checkColor(539 + offset, 525, 201, 191, 191, 20) then		
			moveSubstifutionPlayerTo(539 + offset, 525, x, y);	
		elseif not checkColor(443 + offset, 525, 155, 3, 0, 10) 
			and  not checkColor(443 + offset, 525, 79, 79, 79, 10)
			and  not checkColor(443 + offset, 525, 201, 191, 191, 20) then
			moveSubstifutionPlayerTo(443 + offset, 525, x, y);	
		elseif not checkColor(347 + offset, 525, 155, 3, 0, 10) 
			and  not checkColor(347 + offset, 525, 79, 79, 79, 10)
			and  not checkColor(347 + offset, 525, 201, 191, 191, 20) then
			moveSubstifutionPlayerTo(347 + offset, 525, x, y);
		end	
end


function adjustSubstifutionPlayer()

		mSleep(1000);
		click(width(830 + 176), 602);		
		mSleep(1500);

		local offset;
		
		if w == 1136 then
			offset = 176;
		else
			offset = 0;
		end		

		if checkColor(923 + offset, 387, 155, 3, 0, 10) 
			or checkColor(923 + offset, 387, 79, 79, 79, 10) 
			or checkColor(923 + offset, 387, 201, 191, 191, 20) then
			exchangeSubstifutionPlayerIfNeed(923 + offset, 387);	
		end

		if checkColor(827 + offset, 387, 155, 3, 0, 10) 
			or checkColor(827 + offset, 387, 79, 79, 79, 10) 
			or checkColor(827 + offset, 387, 201, 191, 191, 20) then
			exchangeSubstifutionPlayerIfNeed(827 + offset, 387);	
		end

		if checkColor(731 + offset, 387, 155, 3, 0, 10) 
			or checkColor(731 + offset, 387, 79, 79, 79, 10)
			or checkColor(731 + offset, 387, 201, 191, 191, 20)  then 
			exchangeSubstifutionPlayerIfNeed(731 + offset, 387);			
		end

		if checkColor(635 + offset, 387, 155, 3, 0, 10) 
			or checkColor(635 + offset, 387, 79, 79, 79, 10)
			or checkColor(635 + offset, 387, 201, 191, 191, 20) then
			exchangeSubstifutionPlayerIfNeed(635 + offset, 387);			
		end

		if checkColor(539 + offset, 387, 155, 3, 0, 10) 
			or checkColor(539 + offset, 387, 79, 79, 79, 10) 
			or checkColor(539 + offset, 387, 201, 191, 191, 20) then		
			exchangeSubstifutionPlayerIfNeed(539 + offset, 387);	
		end

		if checkColor(443 + offset, 387, 155, 3, 0, 10) 
			or checkColor(443 + offset, 387, 79, 79, 79, 10) 
			or checkColor(443 + offset, 387, 201, 191, 191, 20) then
			exchangeSubstifutionPlayerIfNeed(443 + offset, 387);	
		end

		if checkColor(347 + offset, 387, 155, 3, 0, 10) 
			or checkColor(347 + offset, 387, 79, 79, 79, 10) 
			or checkColor(347 + offset, 387, 201, 191, 191, 20) then
			exchangeSubstifutionPlayerIfNeed(347 + offset, 387);	
		end	

		mSleep(500);
		click(width(808 + 176), 192);
		mSleep(1000);
end


function adjustPlayer()
	mSleep(500);
	--4312

	local playerOffset = (106 and ((w==1136) and 106 or 0));--a?b:c
	
	exchangeSpecifyPlayerIfNeed(484 + playerOffset, 130);
	exchangeSpecifyPlayerIfNeed(606 + playerOffset, 179);
	exchangeSpecifyPlayerIfNeed(730 + playerOffset, 130);

	exchangeSpecifyPlayerIfNeed(450 + playerOffset, 290);
	exchangeSpecifyPlayerIfNeed(606 + playerOffset, 327);
	exchangeSpecifyPlayerIfNeed(764 + playerOffset, 290);

	exchangeSpecifyPlayerIfNeed(342 + playerOffset, 415);
	exchangeSpecifyPlayerIfNeed(494 + playerOffset, 423);
	exchangeSpecifyPlayerIfNeed(720 + playerOffset, 423);
	exchangeSpecifyPlayerIfNeed(870 + playerOffset, 415);

	exchangeSpecifyPlayerIfNeed(606 + playerOffset, 495);	

end	

function movePlayerTo(srcX, srcY, dstX, dstY)
	local id = touchDown(1, srcX, srcY);
	mSleep(10);			

	__moveTo(id, srcX, srcY, 568, 120);
	__moveTo(id, 568, 120, dstX, dstY);

	touchMove(id, dstX - 30, dstY + 50);

	mSleep(20);	
	touchUp(id, dstX - 30, dstY + 50);
	
	mSleep(2000);	
end

function exchangeSpecifyPlayerIfNeed(x, y) 
	if checkColor(x, y, 155, 3, 0) or checkColor(x, y, 174, 57, 55) 
	or checkColor(x, y, 155,49,48, 10) or checkColor(x - 2, y, 203, 194, 194, 10)--合同过期
		or checkColor(x, y, 79, 79, 79)		--无球员
		or checkColor(x, y, 213, 213, 212) or checkColor(x + 5, y, 180, 20, 18, 20) or checkColor(x + 5, y, 207, 4, 0, 10) 		--红牌
		or checkColor(x, y + 3, 149, 10, 10, 10) or checkColor(x, y + 3, 145, 14, 15, 10)		--受伤
		 then
		click(width(830 + 176), 602);		
		mSleep(1000);

		local offset;
		
		if w == 1136 then
			offset = 176;
		else
			offset = 0;
		end			
		
		--从替补和预备队员最后一个开始		
		if not checkColor(731 + offset, 525, 155, 3, 0, 10) 
			and  not checkColor(731 + offset, 525, 79, 79, 79, 10) 
			and  not checkColor(731 + offset, 525, 201, 191, 191, 20) then 
			movePlayerTo(731 + offset, 525, x, y);			
		elseif not checkColor(635 + offset, 525, 155, 3, 0, 10) and  not checkColor(635 + offset, 525, 79, 79, 79) then
			movePlayerTo(635 + offset, 525, x, y);			
		elseif not checkColor(539 + offset, 525, 155, 3, 0, 10) and  not checkColor(539 + offset, 525, 79, 79, 79) then		
			movePlayerTo(539 + offset, 525, x, y);	
		elseif not checkColor(443 + offset, 525, 155, 3, 0, 10) and  not checkColor(443 + offset, 525, 79, 79, 79) then
			movePlayerTo(443 + offset, 525, x, y);	
		elseif not checkColor(347 + offset, 525, 155, 3, 0, 10) and  not checkColor(347 + offset, 525, 79, 79, 79) then
			movePlayerTo(347 + offset, 525, x, y);	
		--替补
		elseif not checkColor(923 + offset, 387, 155, 3, 0, 10) and  not checkColor(923 + offset, 387, 79, 79, 79) then
			movePlayerTo(923 + offset, 387, x, y);	
		elseif not checkColor(827 + offset, 387, 155, 3, 0, 10) and  not checkColor(827 + offset, 387, 79, 79, 79) then
			movePlayerTo(827 + offset, 387, x, y);	
		elseif not checkColor(731 + offset, 387, 155, 3, 0, 10) and  not checkColor(731 + offset, 387, 79, 79, 79)  then 
			movePlayerTo(731 + offset, 387, x, y);			
		elseif not checkColor(635 + offset, 387, 155, 3, 0, 10) and  not checkColor(635 + offset, 387, 79, 79, 79) then
			movePlayerTo(635 + offset, 387, x, y);			
		elseif not checkColor(539 + offset, 387, 155, 3, 0, 10) and  not checkColor(539 + offset, 387, 79, 79, 79) then		
			movePlayerTo(539 + offset, 387, x, y);	
		elseif not checkColor(443 + offset, 387, 155, 3, 0, 10) and  not checkColor(443 + offset, 387, 79, 79, 79) then
			movePlayerTo(443 + offset, 387, x, y);	
		elseif not checkColor(347 + offset, 387, 155, 3, 0, 10) and  not checkColor(347 + offset, 387, 79, 79, 79) then
			movePlayerTo(347 + offset, 387, x, y);	
		end				
	end			
end	


function isLineupErrorAlert()
	return  isLineupNoEnoughPlayerAlert() or isOutOfContractsAlert() or isLineupInjuredOrBannedAlert();
end

function isLineupInjuredOrBannedAlert()
	if w == 960 then
		return false;
	else 
		return checkColor(525, 181, 230, 230, 230)
		and checkColor(398, 459, 165, 172, 185)
		and checkColor(726, 458, 165, 172, 185);
	end
end

function isLineupNoEnoughPlayerAlert()
	if w == 960 then
		return checkColor(437, 179, 230, 230, 230)
		and checkColor(309, 458, 164, 171, 184)
		and checkColor(637, 460, 164, 171, 184);
	else 
		return checkColor(525, 181, 230, 230, 230)
		and checkColor(334, 270, 230, 230, 230)
		and checkColor(397, 458, 164, 171, 184);
	end
end

function isOutOfContractsAlert()
	if w == 960 then
		return checkColor(385, 103, 246, 203, 50)
		and checkColor(506, 102, 246, 203, 50)
		and checkColor(253, 505, 255, 255, 255);
	else 
		return checkColor(511, 102, 246, 203, 50)
		and checkColor(662, 95, 246, 203, 50)
		and checkColor(340, 505, 255, 255, 255);
	end
end

function isPlayerSwapAlert()
	if w == 960 then
		return checkColor(220, 467, 247, 203, 50)
		and checkColor(449, 304, 230, 230, 230)
		and checkColor(711, 271, 230, 230, 230);
	else 
		return checkColor(308, 466, 247, 203, 50)
		and checkColor(548, 172, 230, 230, 230)
		and checkColor(800, 320, 230, 230, 230);
	end
end


function isClubSearchPage()
	if w == 960 then
		return checkColor(41, 125, 248, 204, 49)	
		and checkColor(466, 129, 234, 180, 33)
		and checkColor(853, 544, 248, 204, 49)
		and checkColor(829, 481, 70, 64, 42);
	else 
		return checkColor(41, 125, 248, 204, 49)	
		and checkColor(588, 130, 234, 180, 33)
		and checkColor(975, 542, 248, 204, 49)
		and checkColor(1005, 482, 70, 64, 42);
	end

end	

function isClubExchagePlayerPage()
	if w == 960 then
		return checkColor(41, 125, 248, 204, 49)	
		and checkColor(466, 129, 234, 180, 33)
		and checkColor(853, 544, 248, 204, 49)
		and checkColor(829, 481, 248, 204, 50);
	else 
		return checkColor(41, 125, 248, 204, 49)	
		and checkColor(589, 129, 234, 180, 33)
		and checkColor(1004, 481, 248, 204, 49)
		and checkColor(1029, 545, 248, 204, 50);
	end
end	

function enumateClubPlayerForExchange(pageCallback)
	local  srcX;
	if w == 960 then
		srcX = 653;
	else
		srcX = 875;
	end
	local  srcY = 300;
	local  dstX = 23;
	local  dstY = 300; 
	
	local hasMorePlayer = true;
	if pageCallback then
		local stop = pageCallback(hasMorePlayer);
		if stop then
			return;
		end
	end

	while hasMorePlayer do
		local id = touchDown(0, srcX, srcY);
		mSleep(10);			
		__moveTo(id, srcX, srcY, dstX, dstY, 20);
		touchMove(id, dstX, dstY);

		mSleep(500);	

		if w == 960 then
			hasMorePlayer = (not (checkColor(697, 325, 68, 67, 64) and  checkColor(665, 330, 62, 61, 59)));
		else
			hasMorePlayer = (not (checkColor(871, 325, 57, 56, 53) and  checkColor(820, 325, 66, 65, 63)));
		end
		if hasMorePlayer then
			logDebug("enumateClubPlayerForExchange hasMorePlayer:1");
		else
			logDebug("enumateClubPlayerForExchange hasMorePlayer:0");
		end

		mSleep(100);	
		touchUp(id, dstX, dstY);
		mSleep(500);	

		if pageCallback then
			local stop = pageCallback(hasMorePlayer);
			if stop then
				break;
			end
		end
	end
end

-- 0 成功， 1 球员不足， 2 错误
function exchangePlayerFromClub()
	local offset;
	if w == 1136 then
		offset = 176;
	else
		offset = 0;
	end		

	click(width(830 + 176), 602);		
	mSleep(1000);

	click(731 + offset, 525);
	mSleep(500);
	
	local noError = waitUtilMeetCondition2(isPlayerSwapAlert, function ()
			click(485, 184);
			return false;
		end,
		isClubSearchPage, function ()
			mSleep(500);
			click(139, 259);
			mSleep(1000);
			click(292, 289);
			mSleep(500);
			return true;
		end);

	if not noError then
		return 2;
	end

	noError = waitUtilMeetCondition(isClubSearchPage, function ()
			click(width(824 + 176), 542);
			mSleep(500);
			return true;
		end);

	noError = waitUtilMeetCondition(isClubExchagePlayerPage);

	if not noError then
		return 2;
	end

	--如果俱乐部没有球员			
	if checkColor(605, 264, 0x31, 0x43, 0x4D) 
	and checkColor(600, 307, 0xFF, 0xFF, 0xFF) then	
		click(46, 121);
		mSleep(2000);	
		return 1;
	end

	mSleep(1000);

	local hasMoreLineupPlayer = true;
	local hasEnoughPlayer = true;
	local hasMorePlayer = true;

	local noError = waitUtilMeetCondition(function ()
			return hasMoreLineupPlayer;
		end, function ()
			if checkColor(width(885 + 176), 235, 155, 3, 0) or checkColor(width(885 + 176), 235, 79, 79, 79) then
				if not hasMorePlayer then
					hasEnoughPlayer = false;
					logDebug("not hasEnoughPlayer");
					return true;
				end
				enumateClubPlayerForExchange(function (morePlayer)
					hasMorePlayer = morePlayer;

					local  x , y;
					local offsetX = 23;
					local hasReplace = false;

					noError = waitUtilMeetCondition(isClubExchagePlayerPage, function ()
						x, y = findColorInRegionFuzzy(0xc38461, 100, offsetX, 241, width(702 + 176 - 145), 241)
						if x ~= -1 and y ~= -1 then
							logDebug(string.format("findColorInRegionFuzzy 0xc38461 %d %d", x, y));
							offsetX = x + 100;
							if not checkColor(x + 98, 239, 155, 3, 0) and not checkColor(x + 98, 239, 176, 64, 63) then	
								click(x + 98, 239);	
								mSleep(500);	

								click(x + 35, 556);	
								mSleep(500);
								hasReplace = true;
								return true;
							else
								return false;
							end
						else
							return true;
						end
					end);

					if not noError then
						return true;
					end

					if hasReplace then
						return true;	
					end

					offsetX = 23;
					noError = waitUtilMeetCondition(isClubExchagePlayerPage, function ()
						x, y = findColorInRegionFuzzy(0xbc9985, 95, offsetX, 241, width(702 + 176 - 145), 241)
						if x ~= -1 and y ~= -1 then
							logDebug(string.format("findColorInRegionFuzzy 0xbc9985 %d %d", x, y));
							offsetX = x + 100;
							if not checkColor(x + 97, 239, 155, 3, 0) and not checkColor(x + 96, 239, 155, 3, 0) then	

								click(x + 97, 239);	
								mSleep(500);

								logDebug("exchange  player from club");

								click(x + 33, 556);	
								mSleep(500);
								hasReplace = true;
								return true;
							else
								return false;
							end
						else
							return true;
						end
					end);

					if not noError then
						return true;
					end

					if hasReplace then
						return true;	
					else
						if not hasMorePlayer then
							hasEnoughPlayer = false;
							logDebug("not hasEnoughPlayer");
							return true;
						else
							return false;	
						end
					end

					--[[
					if not checkColor(191, 239, 155, 3, 0) then	
						click(191, 239);	
						mSleep(500);	

						click(127, 556);	
						mSleep(500);
						return true;							
					elseif not checkColor(401, 239, 155, 3, 0) then	
						click(401, 239);	
						mSleep(500);	

						click(343, 556);	
						mSleep(500);
						return true;							
					elseif not checkColor(611, 239, 155, 3, 0) then	
						click(611, 239);	
						mSleep(500);

						click(554, 556);	
						mSleep(500);
						return true;							
					else
						return false;
					end
					]]--

				end);
			else
				hasEnoughPlayer = true;
			end

			if not hasEnoughPlayer then
				return true;
			end

			hasMoreLineupPlayer = checkColor(width(730 + 176), 315, 249, 199, 52);
			if hasMoreLineupPlayer then
				click(width(730 + 176), 315);
				mSleep(1500);
			end
			return not hasMoreLineupPlayer;
		end);

	if not noError then
		return 2;
	end

	local ret = 0;
	if not hasEnoughPlayer then
		ret =  1;
	end

	mSleep(500);
	click(40, 126);
	mSleep(500);

	return ret;
end

function isClubDetailPage()
	if w == 960 then
		return checkColor(41, 125, 248, 204, 49)	
		and checkColor(133, 128, 234, 180, 33)
		and checkColor(813, 218, 248, 204, 50);
	else 
		return checkColor(41, 125, 248, 204, 49)	
		and checkColor(239, 129, 234, 180, 33)
		and checkColor(1028, 530, 248, 204, 50);
	end
end

function isSellCurrentAlert()
	if w == 960 then
		return checkColor(303, 502,  165, 172, 185)	
		and checkColor(370, 502, 28, 31, 35)
		and checkColor(663, 505, 165, 172, 185);
	else 
		return checkColor(406, 504,  165, 172, 185)	
		and checkColor(511, 504, 28, 31, 35)
		and checkColor(764, 503, 165, 172, 185)
		and checkColor(470, 371, 229, 229, 229);
	end
end

function isSellAlert()
	if w == 960 then
		return checkColor(303, 502,  165, 172, 185)	
		and checkColor(370, 502, 28, 31, 35)
		and checkColor(682, 504, 165, 172, 185);
	else 
		return checkColor(355, 503,  165, 172, 185)	
		and checkColor(486, 499, 28, 31, 35)
		and checkColor(784, 506, 165, 172, 185)
		and checkColor(699, 289, 229, 229, 229);
	end
end


function enumateClubPlayer(pageCallback)
	local  srcX;
	if w == 960 then
		srcX = 623;
	else
		srcX = 850;
	end
	local  srcY = 300;
	local  dstX = 24;
	local  dstY = 300; 
	
	local hasMorePlayer = true;
	if pageCallback then
		local stop = pageCallback(hasMorePlayer);
		if stop then
			return;
		end
	end

	while hasMorePlayer do
		local id = touchDown(0, srcX, srcY);
		mSleep(10);			
		__moveTo(id, srcX, srcY, dstX, dstY, 20);
		touchMove(id, dstX, dstY);

		mSleep(500);	

		if w == 960 then
			hasMorePlayer = (not (checkColor(657, 323, 60, 59, 57) and  checkColor(698, 323, 69, 69, 69)));
		else
			hasMorePlayer = (not (checkColor(871, 325, 57, 56, 53) and  checkColor(820, 325, 66, 65, 63)));
		end

		mSleep(100);	
		touchUp(id, dstX, dstY);
		mSleep(500);	

		if pageCallback then
			local stop = pageCallback(hasMorePlayer);
			if stop then
				break;
			end
		end
	end
end


function quickSellAllBronzePlayer ()
	
	local noError = waitUtilMeetCondition(isMySquadPage, function ()
		click(32, 40);
		mSleep(500);
		return true;
	end);

	noError = waitUtilMeetCondition(isSeasonPage, function ()
		click(33, 115);
		mSleep(500);
		return true;
	end);

	noError = waitUtilMeetCondition(isMainPage, function ()
		--点击俱乐部	
		if w == 960 then
			click(580, 125);
		else
			click(681, 125);
		end	
		mSleep(500);
		return true;
	end);

	noError = waitUtilMeetCondition(isMainPageSelectClub, function ()
		mSleep(500);
		--点击my club	
		click(246, 296);
		mSleep(500);
		return true;
	end);
	
	noError = waitUtilMeetCondition(isClubDetailPage);

	if not noError then
		return false;
	end
	
	--点击搜索	
	click(width(822 + 176), 530);
	mSleep(1000);		
	--点击级别	
	click(139, 259);
	mSleep(1000);
	--选择青铜	
	click(292, 289);
	mSleep(1000);	
	--点击搜索按钮	
	click(width(822 + 176), 530);
	mSleep(1000);	
	
	noError = waitUtilMeetCondition(isClubDetailPage);

	if not noError then
		return false;
	end

	enumateClubPlayer(function (morePlayer)
		::redo::
					mSleep(500);
					if not noError then
						return true;
					end

					noError = waitUtilMeetCondition(function ()
						-- body
						local x;
						if w == 960 then
							x = 702;
						else
							x = 875;
						end
						local x, y = findColorInRegion(0x9b0300, 23, 220, x, 231); 
						if x ~= -1 and y ~= -1 then                             -- 如果找到了
	    					click(x, y);
							mSleep(500);

							--quick sell
							click(width(818 + 176), 283);	
							mSleep(500);	

							noError = waitUtilMeetCondition2(isSellAlert, function ()
								mSleep(300);
								click(672, 500);
								mSleep(300);
								return true;
							end, 
							isSellCurrentAlert, function ()
								mSleep(300);
								click(672, 500);
								mSleep(300);
								return false;
							end);

							noError = waitUtilMeetCondition(isClubDetailPage);
							mSleep(500);
							if noError then
								return false;
							else
								return true;
							end
	    				else
	    					return true;
						end
					end);

					if morePlayer then
						return false;
					else
						return true;
					end
				end);

		if not noError then
			return false;
		end

		noError = waitUtilMeetCondition(isClubDetailPage);
		mSleep(500);

		click(43, 123);
		mSleep(500);

		noError = waitUtilMeetCondition(isMainPageSelectClub, function ()
			mSleep(500);
			
			click(width(707 + 176), 370);
			mSleep(500);
			return true;
		end);


		return true;
end

function isBuyBronzePackageConfirmAlert() 
	if w == 960 then
		return checkColor(380, 141,  229, 229, 229)	
		and checkColor(411, 494, 28, 31, 35);
	else 
		return checkColor(468, 139,  229, 229, 229)	
		and checkColor(502, 490, 28, 31, 35);
	end
end

function isDuplicateAlert()
	if w == 960 then
		return checkColor(437, 105,  230, 230, 230)	
		and checkColor(407, 305, 229, 229, 229)
		and checkColor(584, 334,  230, 230, 230);
	else 
		return checkColor(560, 105,  230, 230, 230)	
		and checkColor(507, 338, 229, 229, 229)
		and checkColor(690, 334,  230, 230, 230);
	end
end

function isSellAllAlert()
	if w == 960 then
		return checkColor(264, 504,  165, 172, 185)	
		and checkColor(676, 504, 165, 172, 185)
		and checkColor(457, 369,  230, 230, 230)
		and checkColor(400, 495,  28, 31, 35);
	else 
		return checkColor(364, 500,  165, 172, 185)	
		and checkColor(764, 502, 165, 172, 185)
		and checkColor(545, 369,  230, 230, 230)
		and checkColor(502, 508,  28, 31, 35);
	end
end

function isRegularPacksSelectBronzePack()
	if w == 960 then
		return checkColor(807, 524, 9, 9, 17)
		and checkColor(758, 195, 230, 230, 230)
		and checkColor(837, 195, 230, 230, 230);
	else 
		return checkColor(982, 524, 9, 9, 17)
		and checkColor(949, 195, 230, 230, 230)
		and checkColor(1014, 196, 230, 230, 230);
	end
end

function buyBronzePackage()

	local maxCount = 10
	local buyCount = 0;

	-- body
	local noError = waitUtilMeetCondition(isRegularPacksPage, function ()
			mSleep(500);
				
			moveTo(701, 368, 23, 378);
			mSleep(500);
			moveTo(701, 368, 23, 378);
			mSleep(500);

			click(width(607 + 176), 341);

			return true;
		end);

	if not noError then
		return false;
	end

	::buyBronzePackage::

	noError = waitUtilMeetCondition(isRegularPacksSelectBronzePack, function ()
			mSleep(500);
			click(width(835 + 176), 529);
			mSleep(500);
			return true;
		end, 
		function ()
			-- body
			moveTo(701, 368, 23, 378);
			mSleep(500);
			click(width(607 + 176), 341);
			mSleep(500);
		end);

	if not noError then
		return false;
	end

	noError = waitUtilMeetCondition(isBuyBronzePackageConfirmAlert, function ()
			mSleep(500);
			click(652, 495);
			mSleep(500);
			return true;
		end);

	if not noError then
		return false;
	end

	noError = waitUtilMeetCondition(isPackContentPage, function ()
		mSleep(500);
		--save all in club
		click(width(995), 248);
		mSleep(1000);
		return true;
	end);

	if not noError then
		return false;
	end

	noError = waitUtilMeetCondition2(isDuplicateAlert, function ()
		mSleep(500);
		--save all in club
		click(w/2, 534);
		mSleep(1000);

		noError = waitUtilMeetCondition(isPackContentPage, function ()
			mSleep(500);
			--点击全部出售
			click(width(995), 335);
			mSleep(1000);
			return true;
		end);

		noError = waitUtilMeetCondition (isSellAllAlert);
		if not noError then
			return false;
		end

		--确定
		mSleep(500);
		click(767, 500);
		mSleep(1000);

		return false;
	end, isRegularPacksPage, function ()
		return true;
	end);

	if not noError then
		return false;
	end

	if (buyCount < maxCount) then
		buyCount =  buyCount + 1;
		goto buyBronzePackage;
	else
		click(45, 125);
		mSleep(1000);

		noError = waitUtilMeetCondition(isMainPageSelectClub);

		mSleep(500);
		click(112, 128);
		mSleep(1000);

		noError = waitUtilMeetCondition(isMainPageSelectHome);

		if not noError then
			return false;
		end
	end

	return true;
end

function isInSimulateMatchPage()
	if w == 960 then
		return	checkColor(932, 40, 248, 204, 49)	
		and checkColor(239, 45,  234, 180, 33)
		and checkColor(584, 44, 230, 230, 230);
	else 
		return	checkColor(1098, 41, 248, 204, 49)	
		and checkColor(298, 45,  234, 180, 33)
		and checkColor(662, 42, 230, 230, 230);
	end
end

function isRegularPacksPage()
	if w == 960 then
		return	checkColor(41, 124, 248, 204, 49)	
		and checkColor(443, 128,  234, 180, 33)
		and checkColor(790, 571, 250, 203, 84);
	else 
		return	checkColor(41, 124, 248, 204, 49)	
		and checkColor(476, 129,  234, 180, 33)
		and checkColor(853, 129, 230, 230, 230);
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

function string_split_pattern(s, patternDelim)
    if type(patternDelim) ~= "string" or string.len(patternDelim) <= 0 then
        return
    end

    local start = 1
    local t = {}
    while true do
    local pos = string.find (s, patternDelim, start, false) -- plain find
        if not pos then
          break
        end

        table.insert (t, string.sub (s, start, pos - 1))
        start = pos + 1
    end
    table.insert (t, string.sub (s, start))

    return t
end

function parseVerificationCodeFromRegion(x1, y1, x2, y2) 

	local code = localOcrText("/tessdata",  -- 语言包tessdata目录在设备中的路径
                                    "eng",  -- 语言类型为中文
                                     x1,  -- 图片左上角X坐标为100
                                     y1,  -- 图片左上角Y坐标为100
                                     x2,  -- 图片右下角X坐标为200
                                     y2,  -- 图片右下角Y坐标为200
                           "0123456789=+-?"); -- 设置白名单字符串, 只识别数字

	logDebug("识别验证码为:"..code);

	mSleep(1000);

			code = string.sub(code, 1, -3);
		notifyMessage(string.format("%s", code));

	local isOK = false;
	local ret = nil;
			
	if code == "" then
		--无法识别。重新开始
		ret =  nil;
	else
		local strs = string_split_pattern(code, '[ +%-=?]');

		if strs and #strs > 1 then
			local  a = tonumber(strs[1]);
			local  b = tonumber(strs[2]);
					
			if a and b and string.find(code, "+") then 
				ret = string.format("%d", a + b);
				isOK = true;
			elseif a and b  then
				if a - b >= 0 then
					ret = string.format("%d", a - b);
					isOK = true;
				end						
			end
		end
	end
	return ret;
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

function getMoney()
	local a = 0;
	for i=0x060f8978,0x060f89F8,16 do
		local success, data = memoryRead("com.ea.fifa15.bv", i, "U32");  

		if success then

			if data > 2000 and data < 100000 then
   		 		a = data;
   		 		return a;
			end
		end
	end

	for i=0x060fa978,0x060fa9F8,16 do
		local success, data = memoryRead("com.ea.fifa15.bv", i, "U32");  
		
		if success then

			if data > 2000 and data < 100000 then
   		 		a = data;
   		 		return a;
			end
		end
	end

	return a;
end


function scandir(directory, iterateCallback)
    local i, t, popen = 0, {}, io.popen
    for filename in popen('ls -a "'..directory..'"'):lines() do
        i = i + 1
        t[i] = filename
        if iterateCallback then
        	iterateCallback(filename);
        end
    end
    return t
end

function fileExits(filePath)
	local F,err = io.open(filePath,"r+");
	if err or not F then 
		return false;
	else
		io.close(F);
		return true;
	end
end

function checkAddress(startAddress, endAddress)
    for i=startAddress,endAddress,16 do
        local ok1, ret1 = memoryRead("com.ea.fifa15.bv", i, "U32");
        if ok1 and ret1 == 0 then
            local ok2, ret2 = memoryRead("com.ea.fifa15.bv", i+4, "U32");
            if ok2 and ret2 == 0 then
                
                local ok3, ret3 = memoryRead("com.ea.fifa15.bv", i-12, "U32");
                local ok4, ret4 = memoryRead("com.ea.fifa15.bv", i-8, "U32");
                local ok5, ret5 = memoryRead("com.ea.fifa15.bv", i-4, "U32");
                if ok3 and ret3 > 0 and ret3 <= 90
                    and ok4 and ret4 > 0 and ret4 < 1000
                    and ok5 and ret5 > 0 and ret5 < 1000 then
                    return i;
                end
            end
        end
    end
    return nil;
end

function getGoalAddress()
    local ret = nil;
	--score
    if memoryRead then
        if w == 960 then
            ret = checkAddress(0x061bb788, 0x061bb808);
            if ret == nil then
                ret = checkAddress(0x06139788, 0x06139808);
            end
        else
            ret = checkAddress(0x06082788, 0x06082808);
            if ret == nil then
                ret = checkAddress(0x0611F788, 0x0611F808);
            end
        end
	end
    return ret;
end

function modifyGoal(address)
	if memoryWrite then
   	 	memoryWrite("com.ea.fifa15.bv", address, 15, "U32");
   	 	memoryWrite("com.ea.fifa15.bv", address + 4, 0, "U32");
	end
end

UI = {
        { 'TextView{-登录账号-}'                   },
        { 'InputBox{}',             'email',    '邮箱:' },
        { 'InputBox{}',    	'password',     '密码:' },
        { 'DropList{仅使用铜卡球员|使用铜银卡球员|使用所有金银铜卡球员}',    'cardType', '使用卡片类型:' },
};


-- 主入口函数
function main()
--[[    if not email or not password then
    	 notifyMessage(string.format("请配置登录账号和密码！"));
    	 return;
 	end
]]--
    rotateScreen(90);

    mSleep(2000);
    
	-- 将屏幕宽度和高度分别保存在变量w、h中				
	w, h = getScreenResolution(); 
	local noError = false;
	local shouldGotoMainPage = false;
    local address = 0;
    local isFirst = true;
    local runLoopCount = 0;

	if isPausePage() then
		goto inGame;
	end
    
	::restart::		

	appKill("com.ea.fifa15.bv");
	mSleep(1000);	

	if not appIsRunnning() then
		mSleep(1000);
		appRun("com.ea.fifa15.bv");
		mSleep(1000);
	end

	address = 0;
	isFirst = true;
	runLoopCount = 0;

	setWaitLoopCount(2 * 60 * 3);

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

	setWaitLoopCount(2 * 60 * 1);

	if not noError then
		goto restart;
	end

	noError = waitUtilMeetCondition4(isStartPage, function ()
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
		isSecurityVerificationPage, function ()

			noError = waitUtilMeetCondition2(isSecurityVerificationPage, function ()
					local a;
					if w == 960 then
						a = parseVerificationCodeFromRegion(500, 193, 674, 235);

					else
						a = parseVerificationCodeFromRegion(592, 190, 765, 234);

					end

					if not a then

					end

				end, 
				isMainPage, function ()
					return true;
				end);

			if not noError then
				return true;
			else
				return false;
			end

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

	noError = waitUtilMeetCondition(isFirstPausePage, function ()
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

	noError = waitUtilMeetCondition2(isMainPage, function ()
			mSleep(500);
			--点击play season
			click(width(900), 300);
			mSleep(500);
			return true;
		end, 
		isStoreIntroducePage, function ()
			click(50, 50);
			mSleep(1000);
			return false;
		end);

	if not noError then
		goto restart;
	end

	::seasonPage::

	noError = waitUtilMeetCondition3(isSeasonPage, function ()
			logDebug("isSeasonPage");
			
			mSleep(500);
			click(width(1087), 119)
			mSleep(500);
			return true;
		end, 
		isStoreIntroducePage, function ()
			click(50, 50);
			mSleep(1000);
			return false;
		end, 
		isSeasonSelectionPage, function ()

			logDebug("isSeasonSelectionPage");

			address = 0;
			isFirst = true;
			runLoopCount = 0;
			
			mSleep(500);
			moveTo(width(800 + 176), 319, 50, 319);
			mSleep(500);
			
			--选择Ultimate League
			click(width(886 + 176), 319);
			mSleep(800);
			click(width(1076), 128);
			mSleep(1000);
			click(714, 508);
			
			mSleep(2000);

			return false;
		end);

	if not noError then
		goto restart;
	end

	shouldGotoMainPage = false;
	noError = waitUtilMeetCondition4(isMySquadPage, function ()
			mSleep(1000);
			if w == 960 then
				mSleep(500);
			end

			click(width(808 + 176), 192);
			mSleep(1000);

			adjustPlayer();

			mSleep(1500);
			click(width(1085), 43);
			mSleep(500);

			return false;
		end,
		isQuickSimulationPage, function ()
			click(width(989), 515);
			return true;
		end, 
		isLineupErrorAlert, function ()
			mSleep(500);
			if isLineupNoEnoughPlayerAlert() or isLineupInjuredOrBannedAlert() then
				click(274, 457);
			else
				noError = waitUtilMeetCondition2(
				isMySquadPage, function ()
					return true;
				end, function ()
					if w == 960 then
                        local x, y = findColorInRegion(0xffffff, 432, 140, 518, 170)
						return (x ~= -1 and y~= -1) or checkColor(467, 173, 110, 80, 64);
					else
                        local x, y = findColorInRegion(0xffffff, 519, 140, 600, 170)
						return (x ~= -1 and y~= -1) or checkColor(554, 171, 110, 80, 64);
					end
				end,  function ()
					mSleep(1000);
					click(278, 505);
					mSleep(1000);
					return false;
				end);

			end

			mSleep(500);

			noError = waitUtilMeetCondition(isMySquadPage);

			logDebug("exchangePlayerFromClub");

			if not noError then
				return true;
			end

			local ret = exchangePlayerFromClub();
			click(808, 192);
			mSleep(500);
			
			--球员不足
			if ret == 1 then
				local BOOL ok = quickSellAllBronzePlayer();
				if ok then
					local BOOL ok = buyBronzePackage();
					if ok then
						shouldGotoMainPage = true;
						return true;
					else
						noError = false;
						return true;
					end
				else
					noError = false;
					return true;
				end

			elseif ret == 2 then
				noError = false;
				return true;
			else
				mSleep(500);
				adjustSubstifutionPlayer();
				mSleep(500);
				return false;
			end

		end);
	if shouldGotoMainPage then
		goto mainPage;
	end

	if not noError then
		goto restart;
	end

	::inGame::

	setWaitLoopCount(2 * 60 * 60*24*356);

	noError = waitUtilMeetCondition4(isSkillDetailPage, function()
			mSleep(1000);
			click(width(1088), 44);
			mSleep(500);
			return true;
		end, 
		isPausePage, function ()
			mSleep(1500);
			click(860, 239);
			mSleep(500);
			return false;
		end,
		isMySquadPage, function ()
			mSleep(500);
			click(33, 39);
			mSleep(500);
			return false;
		end,
		isInSimulateMatchPage, function ()
            runLoopCount = runLoopCount + 1;
                                     
            if (address == 0 or address == nil) and runLoopCount >= 2 then
                address = getGoalAddress();
            end
            if address and address > 0 then
                if isFirst or runLoopCount %20 == 0 then
                	isFirst = false;
                	logDebug(string.format("address === %x", address));
              		 modifyGoal(address);
              	end
            end
            return false;
		end);

	setWaitLoopCount(2 * 60 * 1);

	if not noError then
		goto restart;
	end

	noError = waitUtilMeetCondition(isFinalScorePage, function ()
			mSleep(500);
			click(width(1088), 44);
			mSleep(500);

			return true;
		end);

	noError = waitUtilMeetCondition4(isEndSeasonEarlyAlert, function ()
			mSleep(500);
			click(w/2, 463);
			mSleep(500);

			return false;
		end, isEndSeasonEndAlert, function ()
			mSleep(500);
			click(w/2 - 50, 463);
			mSleep(500);

			return false;
		end,
		isSeasonPage, function ()
			-- body
			return true;
		end, isSeasonSelectionPage, function ()
			-- body
			return true;
		end);



	if noError then
		goto  seasonPage;
	else
		goto restart;
	end

end





















