--
-- Author: gf
-- Date: 2015-10-16 13:49:22
--

GMBO = {}

local storge_file = "gmAwards"


function GMBO.getAwards()
    --读取本地文件
    local path = CCFileUtils:sharedFileUtils():getCachePath() .. storge_file
    local awards = {}
    if io.exists(path) then
        awards = json.decode(io.readfile(path))
    end
    return awards
end

function GMBO.saveAwards(doneCallback,awards)
    local path = CCFileUtils:sharedFileUtils():getCachePath() .. storge_file
    io.writefile(path, json.encode(awards), "w+b")

    Notify.notify(LOCAL_GM_UPDATE_EVENT)
    
    if doneCallback then doneCallback() end
end

function GMBO.asynSendMail(doneCallback,str,mail)
	
	local function parseUpgrade(name, data)
		Toast.show(CommonText[649])
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseUpgrade, NetRequest.new("DoSome", {str = str,mail = mail}))
end

function GMBO.asynGag(doneCallback,str)
	local function parseUpgrade(name, data)
		Toast.show(CommonText[649])
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseUpgrade, NetRequest.new("DoSome", {str = str}))
end

function GMBO.asynSetVip(doneCallback,str)
	local function parseUpgrade(name, data)
		Toast.show(CommonText[649])
		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseUpgrade, NetRequest.new("DoSome", {str = str}))
end