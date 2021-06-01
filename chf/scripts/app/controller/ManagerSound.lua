--

local ManagerSound = {}

local MUSIC_DIR = "music/"
local SOUND_DIR = "sound/"

ManagerSound.musicEnable = true  -- 是否有背景音乐
ManagerSound.soundEnable = true  -- 是否有音效

function ManagerSound.playMusic(name, loop)
	if not ManagerSound.musicEnable then return end

	local fn = MUSIC_DIR .. name .. ".mp3"
	if ManagerSound.music then
		audio.stopMusic(fn)
	end
	ManagerSound.music = fn
	audio.playMusic(fn, loop)
end

function ManagerSound.stopMusic()
	audio.stopMusic()
end

function ManagerSound.setMusicVolume(volume)
	audio.setMusicVolume(volume)
end

function ManagerSound.playSound(name, loop)
	if not ManagerSound.soundEnable then return end

	if name then
		audio.playSound(SOUND_DIR .. name .. ".mp3", loop)
	end
end

function ManagerSound.stopSound()
	audio.stopAllSounds()
end

-- function ManagerSound.playResult(b)
-- 	local fn
-- 	if b then
-- 		fn = "win"
-- 	else
-- 		fn = "lose"
-- 	end
	
-- 	ManagerSound.playMusic(fn, false)
-- end

-- ManagerSound.UI_MUSIC_VOLUME = 0.6  -- UI的音量

-- 播放一般按钮的点击音效(不包含特殊按钮)
function ManagerSound.playNormalButtonSound()
	if not ManagerSound.soundEnable then return end

	ManagerSound.playSound("button_click")
end

-- -- 播放左右翻页按钮的点击音效
-- function ManagerSound.playPageButtonSound()
-- 	ManagerSound.playSound("ui_page_change")
-- end

-- local SITE_ARR = {3, 4, 5}
-- function ManagerSound.playBattle(id)
-- 	local m
-- 	local index = table.keyOfItem(SITE_ARR, id)
-- 	if index and index >= 1 then
-- 		m = "m1"
-- 	else
-- 		m = "m2"
-- 	end

-- 	ManagerSound.playMusic(m, true)
-- end

-- function ManagerSound.playCall(lordId)
-- 	local m
-- 	if lordId == 3 then
-- 		m = "call_b"
-- 		else
-- 		m = "call_a"
-- 	end

-- 	ManagerSound.playSound(m, false)
-- end

-- function ManagerSound.playBufSound(bufId)
-- 	local m
-- 	if (bufId>=4 and bufId<=9) or (bufId>=22 and bufId<=27) then
--     --上升
--         m = "buf3"
--     elseif (bufId>=10 and bufId<=15) or (bufId>=28 and bufId<=33) then
-- 	--下降
--         m = "buf4"
--     elseif (bufId == 18) then
-- 	--中毒
-- 		m = "buf1"
-- 	elseif (bufId == 19 or bufId == 44) then
-- 		--流血
-- 		m = "buf2"
-- 	end

-- 	if m then
-- 		ManagerSound.playSound(m, false)
-- 	end
-- end

-- function ManagerSound.readFile()
-- 	if ManagerSound.soundEnable == nil then
-- 		local file = io.open(device.writablePath.."sound", "rb")
-- 	    if file then
-- 	        local content = file:read("*all")
-- 	        io.close(file)
-- 	        if content == "1" then
-- 	        	ManagerSound.soundEnable = true
-- 	        else
-- 	        	ManagerSound.soundEnable = false
-- 	        end  
-- 	        return     
-- 	    end
-- 	    ManagerSound.soundEnable = true
-- 	end
-- end

-- function ManagerSound.writeFile(type)
-- 	io.writefile(device.writablePath .. "sound", type)
-- end
-- ManagerSound.readFile()
return ManagerSound