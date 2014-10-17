function click(x, y)
	local r = touchDown(0, x, y);
	touchUp(r, x, y);
end

function main()
    rotateScreen(90);
    local code = localOcrText("/tessdata",  -- 语言包tessdata目录在设备中的路径
                                    "eng",  -- 语言类型为中文
                                     500,  -- 图片左上角X坐标为100
                                     193,  -- 图片左上角Y坐标为100
                                     654,  -- 图片右下角X坐标为200
                                     235,  -- 图片右下角Y坐标为200
                           "0123456789=+-?"); -- 设置白名单字符串, 只识别数字
    notifyMessage("code == "..code , 3000);
end