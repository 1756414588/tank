--
-- 账号管理

-- local ErrorBox = require("app.component.box.ErrorBox")
-- import("app.dm.ServerDM")
-- import("app.text.ErrorText")

-- local NetErrorDlg = require("app.dialog.NetErrorDlg")
-- local APIUtils = require("app.service.APIUtils")

-- require("app.text.LoginText")

require("app.mo.LoginMO")

AREA_PAGE_SERVER_NUM = 100  -- 服务器列表UI每页显示的服务器个数



-- 此变量不能放在LoginMO中，LoginMO在进入后，不会重新加载，这样首次更新后，则没有此变量
HOME_SNOW_VERSION = 140  -- 场景中的雪景版本号的最大值
HOME_SNOW_DEFAULT = 0 		-- 默认可更改 对应system表中49 用于在未加载表时使用

LoginBO = {}

-- 注册时名称的最大长度
REGISTER_NAME_MAX_LEN = 12
-- 创建角色时的最长名称
ROLE_NAME_MAX_LEN = 18


--IPV6审核地址
-- GameConfig.accountURL_ipv6 = "http://ipv4.hundredcent.com:9200/tank_account/account/account.do"
-- GameConfig.areaURL_ipv6 = "http://ipv4.hundredcent.com/serverlist_tank.json"
-- GameConfig.verifyURL_ipv6 = "http://ipv4.hundredcent.com/version/tank_ios_test.json"

-- local storge_file = "accountList"

--游戏服务器验证服务-check.do
-- local checkService = "/check.do"
--游戏服务器逻辑服务-logic.do
-- local logicService = "/logic.do"

--获得分区列表成功
-- local onAreaSuccess


-- 初始本地的所有账号
function LoginBO.initLocalAcounts()
	local content = readfile(LoginMO.accountsFileName)
	if content then
		local accounts = json.decode(content)
		LoginMO.setLocalAccounts(accounts)
	end
end

-- 在客户端本地中获得当前版本号
function LoginBO.initVersion()
    local version = nil
    local verFile = CACHE_DIR .. GameConfig.versionManifest  -- 先从cache中查询

    if io.exists(verFile) then
        version = CCFileUtils:sharedFileUtils():getStringFromFile(verFile)
    else
        --从初始目录读文件列表
        local cpath = CCFileUtils:sharedFileUtils():fullPathForFilename(GameConfig.versionManifest)
        
        gprint("LoginBO.initVersion 需要从初始目录读版本号", cpath)
        
        if cpath ~= GameConfig.versionManifest then
            version = CCFileUtils:sharedFileUtils():getStringFromFile(cpath)
        end
        -- gprint("LoginBO.initVersion 从初始目录读版本号文件complete")
    end

    if not version then
    	version = GameConfig.version
    end

    GameConfig.version = version
    
    gprint("[LoginBO] version:", GameConfig.version)
end

function LoginBO.initRunParam(callback)
	local function setParam(runParam)
		local p = string.split(runParam, "|")
	
		GameConfig.environment = p[1]

		if p[2] ~= nil then GameConfig.cpid = p[2] end

		gprint("[LoginBO] environment:", GameConfig.environment)
		gprint("[LoginBO] cpid:", GameConfig.cpid)

        require_ex("app.address." .. GameConfig.environment)

        gprint("[LoginBO] account url:", GameConfig.accountURL)

        if callback then callback() end
	end

	ServiceBO.getRunParam(function(p)
			setParam(p)
		end)
end

function LoginBO.initUUID(callback)
    ServiceBO.getUUID(function(uuid)
	        GameConfig.uuid = uuid
	        Statistics.setInfo(uuid,LOGIN_PLATFORM_PARAM)
	        gprint("[LoginBO] uuid:", GameConfig.uuid)

	        if callback then callback() end
	    end)
end

function LoginBO.initGameURL()
	gprint("[LoginBO] initGameURL area:", GameConfig.areaId)
    local currentArea = LoginMO.getServerById(GameConfig.areaId)
    gdump(currentArea, "LoginUpdate.updateGameURL")

    GameConfig.gameURL = currentArea.url
    if string.sub(GameConfig.gameURL, 1, 7) ~= "http://" then
        GameConfig.gameURL = "http://" .. GameConfig.gameURL
    end

    GameConfig.gameSocketURL = currentArea.socketURL

    GameConfig.gamePort = currentArea.port

    gprint("[LoginBO] game url:", GameConfig.gameURL)
    gprint("[LoginBO] game socket url:", GameConfig.gameSocketURL)
    gprint("[LoginBO] game port:", GameConfig.gamePort)
end

-- function LoginBO.initSession(session)
--     GameConfig.session = session
--     gprint("[LoginBO] session:", GameConfig.session)
-- end

-- 判断当前是否是自家登录。如果是则显示登录框，如果不是则使用SDK登录
function LoginBO.isSelfLogin()
	if GameConfig.environment == "self_client" or GameConfig.environment == "ipay_client" or GameConfig.environment == "ios_client" or GameConfig.environment == "zty_nake_client" then
		return true
	else
		return false
	end
end

-- 拉取服务器配置json
function LoginBO.asynGetServerList(callBack)
	ServiceBO.getIPAddress(function(ipAddress)
    		local function getListCallback(event)
				local wrapper = event.obj
				local content = wrapper:getData()
				local data = json.decode(content)
				gdump(data, "LoginBO.asynGetServerList")

				LoginMO.baseVersion_ = data.baseVersion
				-- LoginMO.serverList_ = data.list
				LoginMO.serverList_ = LoginBO.filterServerList(data)

				if callBack then callBack() end
			end

		    local url
    		local myDeviceIP = ipAddress
			local localVersion = LoginBO.getLocalApkVersion()
			if not myDeviceIP then myDeviceIP = "" end
			if (device.platform == "ios" or device.platform == "mac") and localVersion >= 200 and myDeviceIP:find(":") and GameConfig.areaURL_ipv6 then
				url = GameConfig.areaURL_ipv6
			else
				url = GameConfig.areaURL
			end
			local wrapper = NetWrapper.new(getListCallback, nil, true, REQUEST_TYPE_GET, url, false, nil, "Accept-Encoding:gzip,deflate")
    		wrapper:sendRequest()
    	end
	)
end

--处理登录结果
local function parseLoginResult(event)
	ServiceBO.sdkLogining_ = false

	local data = nil
	if not GLOBAL_NETWORK_ON then
		data = {}
		data.recent = {1}
		data.active = 1
	else
		local wrapper = event.obj
		local doLogin = wrapper:getRequestByName("DoLogin")
		-- gdump(doLogin, "doLogin")

		data = doLogin:getData()
		gdump(data, "DoLogin data")
	end

	-- 登录返回数据出错
	if not data then
		LoginBO.clearAccount()
		return
	end

	--成功
	--身份令牌
	GameConfig.token = data.token
	GameConfig.keyId = data.keyId
	ServiceBO.userInfo = data.userInfo
	
	LoginMO.recentLogin_ = data.recent

	gprint("[LoginBO] token:", GameConfig.token)
	gprint("[LoginBO] keyId:", GameConfig.keyId)
	-- gprint("[LoginBO] recent:", GameConfig.recent)

	LoginBO.saveAccount(LoginMO.getEmail(), LoginMO.getPassword())

	--草花用户绑定
	if GameConfig.environment == "chpub_client" or GameConfig.environment == "chYh_client" 
		or GameConfig.environment == "chpub_hj4_client" then
		ServiceBO.userInfoBind(data.userInfo)
	end

	if data.userInfo and data.userInfo == "1" then
		TKGameBO.onRegister(data.keyId)
	end
	TKGameBO.onLogin(data.keyId)


	-- 根据返回状态判断是否有激活流程0未激活 1已激活
	if data.active == 0 then
		Enter.startActivate()
	else
		Enter.startArea()
	end

end

-- 处理注册结果
local function parseRegistResult(event)
	-- gprint("parseRegistResult ... ")
	local wrapper = event.obj
	local doRegister = wrapper:getRequestByName("DoRegister")

	local data = doRegister:getData()
	gdump(data, "DoRegister data")

	if not data then
		LoginBO.clearAccount()
		return
	end

	GameConfig.token = data.token
	GameConfig.keyId = data.keyId

	gprint("[LoginBO] token:", GameConfig.token)
	gprint("[LoginBO] keyId:", GameConfig.keyId)

	LoginBO.saveAccount(LoginMO.getEmail(), LoginMO.getPassword())

	if device.platform == "ios" or device.platform == "mac" then
		local data = {reuid = data.keyId}
		local dataStr = "json=" .. json.encode(data)
		gprint("[LoginBO] parseRegistResult device is IOS or MAC")
	else
		-- 根据返回状态判断是否有激活流程0未激活 1已激活
		if data.active == 0 then
			Enter.startActivate()
		else
			Enter.startArea()
		end
	end
end

local function parseRoleLoginResult(notifyName, data)

	gprint("[LoginBO] parseRoleLoginResult ...")

	Loading:getInstance():unshow()
	if table.isexist(data, "war") and data.war == 1 then
		PartyBattleMO.isOpen = true
	else
		PartyBattleMO.isOpen = false
	end

	if table.isexist(data, "boss") and data.boss == 1 then  -- 世界BOSS是否开启
		ActivityCenterMO.isBossOpen_ = true
	else
		ActivityCenterMO.isBossOpen_ = false
	end

	if table.isexist(data, "staffing") and data.staffing == 1 then -- 编制功能是否开启
		StaffMO.isStaffOpen_ = true
	else
		StaffMO.isStaffOpen_ = false
	end

	if table.isexist(data, "fortress") and data.fortress == 1 then -- 要塞战是否开启
		FortressMO.isOpen_ = true
	else
		FortressMO.isOpen_ = false
	end

	if table.isexist(data, "drill") then -- 红蓝大战是是否报名
		if not ExerciseBO.data then ExerciseBO.data = {} end
		ExerciseBO.data.isEnrolled = data.drill
	end

	if table.isexist(data, "crossFight") then -- 跨服战是否开启
		CrossMO.isOpen_ = data.crossFight == 1
	end
	if table.isexist(data, "crossParty") then -- 跨服军团战是否开启
		CrossPartyMO.isOpen_ = data.crossParty == 1
	end
	-- 进入游戏
	Enter.startLoading()
	return false
end

--选区回调
local function parseBeginGameResult(name, data)
	-- local data = {}
	-- if not GLOBAL_NETWORK_ON then
	-- 	data.sd = "1234kjdlfsjdk34"
	-- 	data.time = os.time()
	-- 	data.state = 2
	-- 	data.name = {}
	-- else
	-- 	local beginGame = event.obj:getRequestByName("BeginGame")
	-- 	data = beginGame:getData()
	-- 	gdump(data, "LoginBO parseBeginGameResult")
	-- end

	gdump(data, "LoginBO parseBeginGameResult")

	data.name = data.name or {}

	-- LoginBO.initSession(data.sd)
	LoginMO.roleNames_ = data.name

	if data.state == 1 or data.state == 2 then
		ManagerTimer.start(data.time)

		if data.state == 1 then -- 需要创建角色
			Loading.getInstance():unshow()
			-- Enter.startRole()
			LoginBO.createLocalRole(data.name[1])
		elseif data.state == 2 then
			SocketWrapper.wrapSend(parseRoleLoginResult, NetRequest.new("RoleLogin"))
		end
	elseif data.state == 3 then  -- 账号被禁
		Loading.getInstance():unshow()
		Toast.show(LoginText[32])
	elseif data.state == 4 then  -- 不在白名单
		Loading.unshow()
		Toast.show(LoginText[17])
	end

	return false
end

-- 
function LoginBO.createLocalRole(name)
	local function parseCallback(data)
		SocketWrapper.wrapSend(parseRoleLoginResult, NetRequest.new("RoleLogin"))
	end
	SocketWrapper.wrapSend(parseCallback, NetRequest.new("CreateRole", {nick = name, portrait = 1, sex = 1}))
end

-- 账号登录
function LoginBO.asynAccountLogin(email_s, pas_s, doneCallback)
	local baseVer_
	if not GAME_APK_VERSION or GAME_APK_VERSION == "" then 
		baseVer_ = "1.0.0"
	else
		baseVer_ = GAME_APK_VERSION
	end
	local loginData = {
		sid = email_s .. "_" .. pas_s,
		plat = GameConfig.loginPlatform,
		version = GameConfig.version,
		baseVersion = baseVer_,
		deviceNo = GameConfig.uuid,
	}

	gdump(loginData,"loginData===")
	LoginMO.setEmail(email_s)
	LoginMO.setPassword(pas_s)

   local doLogin = NetRequest.new("DoLogin", loginData)

   local callback = doneCallback
   if not callback then callback = parseLoginResult end -- 使用默认的
    
    local wrapper = NetWrapper.new(parseLoginResult, nil, nil, nil, GameConfig.accountURL)
    wrapper:addRequest(doLogin)
    wrapper:sendRequest()
    -- wrapper:sendGetRequest()
end

-- sdk登录
function LoginBO.asynSdkLogin(sdkToken)
	ServiceBO.getIPAddress(function(ipAddress)
		    local url
    		local myDeviceIP = ipAddress
			local localVersion = LoginBO.getLocalApkVersion()
			if not myDeviceIP then myDeviceIP = "" end
			if (device.platform == "ios" or device.platform == "mac") and localVersion >= 200 and myDeviceIP:find(":") and GameConfig.accountURL_ipv6 then
				url = GameConfig.accountURL_ipv6
			else
				url = GameConfig.accountURL
			end
			ServiceBO.sdkLogining_ = true
			gprint("LoginBO.asynSdkLogin", sdkToken)
			GameConfig.sdkLoginToken = sdkToken

			local baseVer_
			if not GAME_APK_VERSION or GAME_APK_VERSION == "" then 
				baseVer_ = "1.0.0"
			else
				baseVer_ = GAME_APK_VERSION
			end
			local loginData = {
					sid = sdkToken,
					plat = LOGIN_PLATFORM_PARAM,
					version = GameConfig.version,
					baseVersion = baseVer_,
					deviceNo = GameConfig.uuid
				}
			gdump(loginData, "LoginBO.asynSdkLogin data")

			local doLogin = NetRequest.new("DoLogin", loginData)

		    local wrapper = NetWrapper.new(parseLoginResult, nil, nil, nil, url)
		    wrapper:addRequest(doLogin)
		    wrapper:sendRequest()
    	end
	)	

    -- wrapper:sendGetRequest()
end

-- 游戏中的重新登录, 注意:必须是在游戏中，如果没有成功登录过游戏，不要调用
function LoginBO.asynReLogin(doneCallback)
	local function doneDoLogin(event)
		local wrapper = event.obj
		local doLogin = wrapper:getRequestByName("DoLogin")
		-- gdump(doLogin, "doLogin")

		data = doLogin:getData()
		gdump(data, "DoLogin data")

		--身份令牌
		GameConfig.token = data.token
		GameConfig.keyId = data.keyId

		if doneCallback then doneCallback() end
	end

	local sid = ""
	if LoginBO.isSelfLogin() then sid = LoginMO.getEmail() .. "_" .. LoginMO.getPassword()
	else sid = GameConfig.sdkLoginToken end

	local baseVer_
	if not GAME_APK_VERSION or GAME_APK_VERSION == "" then 
		baseVer_ = "1.0.0"
	else
		baseVer_ = GAME_APK_VERSION
	end

	local doLogin = NetRequest.new("DoLogin", {sid = sid, plat = LOGIN_PLATFORM_PARAM, version = GameConfig.version, baseVersion = baseVer_, deviceNo = GameConfig.uuid})
    local wrapper = NetWrapper.new(doneDoLogin, nil, nil, nil, GameConfig.accountURL)
    wrapper:addRequest(doLogin)
    wrapper:sendRequest()
    -- wrapper:sendGetRequest()
end

--账号注册
function LoginBO.asynRegistAccount(email_s, pas_s)
	local baseVer_
	if not GAME_APK_VERSION or GAME_APK_VERSION == "" then 
		baseVer_ = "1.0.0"
	else
		baseVer_ = GAME_APK_VERSION
	end
	registerData = {
		plat = GameConfig.loginPlatform,
		version = GameConfig.version,
		baseVersion = baseVer_,
		deviceNo = GameConfig.uuid,
		accountId = email_s,
		passwd = pas_s
	}

	LoginMO.setEmail(email_s)
	LoginMO.setPassword(pas_s)

    local doRegister = NetRequest.new("DoRegister", registerData)

    local wrapper = NetWrapper.new(parseRegistResult, nil, nil, nil, GameConfig.accountURL)
    wrapper:addRequest(doRegister)
    wrapper:sendRequest()
    -- wrapper:sendGetRequest()
end

-- 账号激活
function LoginBO.asynAccountActivate(doneCallback, activateCode)
	local function parseActivate()
		if doneCallback then doneCallback() end
	end

	-- if true then
	-- 	parseActivate()
	-- 	return
	-- end

	local doActive = NetRequest.new("DoActive", {keyId = GameConfig.keyId, activeCode = activeCode})
    local wrapper = NetWrapper.new(parseRegistResult, nil, nil, nil, GameConfig.accountURL)
    wrapper:addRequest(doActive)
    wrapper:sendRequest()
end

--清除账号
function LoginBO.clearAccount()
	writefile(LoginMO.accountsFileName, "")
end

-- 保存账号
function LoginBO.saveAccount(email, password)
	if email and password then
		local accounts = LoginMO.getLocalAccounts()

		local index = LoginBO.getLocalAccountIndex(email)
		if index > 0 then  -- 如果已经存在，则先移除
			table.remove(accounts, index)
		end

		local account = {accountId = email, passwd = password}

		table.insert(accounts, 1, account)

		writefile(LoginMO.accountsFileName, json.encode(accounts))
	end
end

-- 获得账号account在本地保存的位置索引
function LoginBO.getLocalAccountIndex(accountId)
	local accounts = LoginMO.getLocalAccounts()

	for index = 1, #accounts do
		if accounts[index].accountId == accountId then
			return index
		end
	end
	return -1
end


--获得存储的账号
-- function LoginBO.getAccount()
-- 	local path = CCFileUtils:sharedFileUtils():getCachePath() .. storge_file
-- 	if io.exists(path) then
-- 		local contents = io.readfile(path)
-- 		LoginBO.loginHis = json.decode(contents)
-- 		-- dump(LoginBO.loginHis)
-- 		return LoginBO.loginHis
-- 	end
-- end

-- function LoginBO.writefile()
-- 	local path = CCFileUtils:sharedFileUtils():getCachePath() .. storge_file
-- 	local contents = json.encode(LoginBO.loginHis)
-- 	return io.writefile(path, contents, "w+b")
-- end

-- 选区
function LoginBO.asynBeginGame(doneCallback)
	local function parseDoBegin()
		local param = {
			serverId = GameConfig.areaId,
			keyId = GameConfig.keyId,
			token = GameConfig.token,
			deviceNo = GameConfig.uuid,
			curVersion = GameConfig.version
		}

		-- gdump(param, "BeginGame")
		local callback = doneCallback
		if not callback then callback = parseBeginGameResult end -- 使用默认的回调

		SocketWrapper.wrapSend(callback, NetRequest.new("BeginGame", param))
	end
	--判断是否是IOS审核阶段
	if GameConfig.enableCode == true and not GameConfig.skipUpdate then
		LoginBO.checkVersion(function(data)
			LoginBO.initVersion()
			--比较线上ver.manifest和本地ver.manifest，是否版本号一致
			if string.sub(data,1,string.len(GameConfig.version)) == GameConfig.version then
            	parseDoBegin()
            else  --如果不一致，重新跳转到开始进行更新
            	BusErrorDialog.getInstance():show({msg=ErrorText.text207}, function()
            						-- SocketWrapper.getInstance():disconnect(true)
            						Enter.startLogo()
            					end)
            	BusErrorDialog.getInstance().m_cancelBtn:hide()
            	BusErrorDialog.getInstance().m_okBtn:x(BusErrorDialog.getInstance().m_okBtn:getParent():width()/2)
            end
		end)
	else
		parseDoBegin()
	end
end

-- 创建角色时，获得角色名称
function LoginBO.asynGetRoleNames(doneCallback)
	local function parseGetNames(name, data)
		gdump(data, "LoginBO asynGetRoleNames")

		LoginMO.roleNames_ = data.name
		if doneCallback then doneCallback() end

		return false
	end

	SocketWrapper.wrapSend(parseGetNames, NetRequest.new("GetNames", param))
end

-- 创建角色
function LoginBO.asynCreateRole(doneCallback, nick, portrait, sex)
	local function parseCreateRole(event)
		SocketWrapper.wrapSend(parseRoleLoginResult, NetRequest.new("RoleLogin"))

		--TK统计
    	TKGameBO.onCreateRole(nick)

		--创建角色提交数据
		if GameConfig.environment == "weiuu_client" or GameConfig.environment == "37wan_client" 
			or GameConfig.environment == "muzhiJh_client" or GameConfig.environment == "anfanJh_client" 
			or GameConfig.environment == "muzhi_49" or GameConfig.environment == "muzhiJhly_client" 
			or GameConfig.environment == "pptv_client" or GameConfig.environment == "muzhiU8ly_client" 
			or GameConfig.environment == "muzhiJhYyb_client" or GameConfig.environment == "chhjfc_360_client" 
			or GameConfig.environment == "muzhiJhYyb1_client" then
			ServiceBO.creatRole()
		end
		
		
		-- if doneCallback then doneCallback() end
		return false
	end

	-- gprint("LoginBO asynCreateRole")

	SocketWrapper.wrapSend(parseCreateRole, NetRequest.new("CreateRole", {nick = nick, portrait = portrait, sex = sex}))
end


function LoginBO.isInPlat(plats)
	for index=1,#plats do
		local plat = plats[index]
		if plat == LOGIN_PLATFORM_PARAM then
			return true
		end
	end
	return false
end


function LoginBO.filterServerList(data)
	-- function isInList(plats)
	-- 	for index=1,#plats do
	-- 		local plat = plats[index]
	-- 		if plat == LOGIN_PLATFORM_PARAM then
	-- 			return true
	-- 		end
	-- 	end
	-- 	return false
	-- end

	--新版规则(根据control字段，判断当前渠道是否显示专服列表)
	function getControlList(data)
		local controlList = nil
		if data.control then
			controlList = {}
			for index=1,#data.control do
				local controlData = data.control[index]
				if controlData.plat then
					if LoginBO.isInPlat(controlData.plat) then
						if controlData.allowMin and controlData.allowMax then
							for j=controlData.allowMin, controlData.allowMax do
								controlList[#controlList + 1] = j
							end
						else
							if controlData.allowMin then
								for j=controlData.allowMin, #data.list do
									controlList[#controlList + 1] = j
								end
							elseif controlData.allowMax then
								for j=1, controlData.allowMax do
									controlList[#controlList + 1] = j
								end
							end
						end
						if controlData.allow then
							for j=1,#controlData.allow do
								controlList[#controlList + 1] = controlData.allow[j]
							end
						end
					end
				else
					-- Toast.show("JSONError:not have plat")
				end
			end
		end
		return controlList
	end

	local list = data.list
	local servers = {}
	local controlList = getControlList(data)

	if GameConfig.enableCode == true then
		if controlList and #controlList > 0 then
			for index=1,#list do
				server = list[index]
				for j=1,#controlList do
					local serverId = controlList[j]
					if serverId == server.id then
						servers[#servers + 1] = server
					end
				end
			end
		else
			for index=1,#list do
				server = list[index]
				if not server.plat or (server.plat and LoginBO.isInPlat(server.plat)) then
					servers[#servers + 1] = server
				end
			end
		end
	else --IOS审核阶段只能看到ID为 9999 的审核服
		for index=1,#list do
			server = list[index]
			if server.id == 9999 then
				servers[#servers + 1] = server
			end
		end
	end


	--拇指安趣渠道 服务器列表 名称特殊处理
	if GameConfig.environment == "mzAqGtdg_appstore" or GameConfig.environment == "mzAqHszz_appstore" 
		or GameConfig.environment == "mzAqHxzz_appstore" or GameConfig.environment == "mzAqTkjt_appstore"
		or GameConfig.environment == "mzAqZbshj_appstore" or GameConfig.environment == "mzAqZzfy_appstore" then
		for index=1, #servers do
			local server = servers[index]
			if server.aqName then
				server.name = server.aqName
			end 
		end
	end

	return servers
end

function LoginBO.getNewOpenServerIdx()
	-- local idx = 1
	-- for index=1,#LoginMO.serverList_ do
	-- 	local server = LoginMO.serverList_[index]
	-- 	if server.id > LoginMO.serverList_[idx].id and (not server.stop or server.stop == 0) then
	-- 		idx = index
	-- 	end
	-- end
	-- return idx


	local serverList = clone(LoginMO.serverList_)

	--过滤掉维护状态的服务器
	local serverList_ = {}
	for index=1,#serverList do
		local server = serverList[index]
		if not server.stop or server.stop == 0 then
			serverList_[#serverList_ + 1] = server
		end
	end

	--排序规则，new > hot > id
	local function sortFun(a,b)
		if a.new == b.new then
			if a.hot == b.hot then
				return a.id > b.id
			else
				return a.hot > b.hot
			end
		else
			return a.new > b.new
		end
	end
	gdump(serverList_,"serverList_====")
	gdump(LoginMO.serverList_,"LoginMO.serverList_====")
	table.sort(serverList_,sortFun)
	if #serverList_ >  0 then
		return serverList_[1].id
	else
		return LoginMO.serverList_[1].id
	end
end

-- serverId的服务器上是否有玩家的角色
function LoginBO.hasRoleInServer(serverId)
	for index = 1, #LoginMO.recentLogin_ do
		if LoginMO.recentLogin_[index] == serverId then
			return true
		end
	end
	return false
end



-- 拉取服务器APK的version信息
function LoginBO.asynGetServerApkVersion(callBack)
	local function getVersionCallback(event)
		local wrapper = event.obj
		local content = wrapper:getData()
		gprint("content",content)
		local data = json.decode(content)
		gdump(data, "LoginBO.asynGetServerApkVersion")
		if callBack then callBack(data) end
	end

    local wrapper = NetWrapper.new(getVersionCallback, nil, true, REQUEST_TYPE_GET, GameConfig.versionURL, false)
    wrapper:sendRequest()
end

function LoginBO.getLocalApkVersion()
	if not GAME_APK_VERSION or GAME_APK_VERSION == "" then return 100 end

	local localVer = string.split(GAME_APK_VERSION, ".")
	local localVer1 = ""
    for i = 1, #localVer do
        localVer1 = localVer1 .. localVer[i]
    end
    localVer1 = tonumber(localVer1)

    -- gprint("LoginBO.getLocalApkVersion =====:",localVer1)
    return localVer1
end

--判断是否需要整包更新
function LoginBO.needUpdateApk()
	-- if GameConfig.environment == "self_client" then return nil end
	if device.platform == "ios" then return nil end

	if not GameConfig.versionURL or GameConfig.versionURL == "" then return nil end
	if not GAME_APK_VERSION or GAME_APK_VERSION == "" then return nil end

	local localVer = string.split(GAME_APK_VERSION, ".")
	local localVer1 = ""
    for i = 1, #localVer do
        localVer1 = localVer1 .. localVer[i]
    end
    localVer1 = tonumber(localVer1)

    gprint("localVer1=====:",localVer1)
    if localVer1 < 200 then return nil end
    return true
end

--获取整包更新信息
function LoginBO.getApkUpdateData(callBack)
	--获取服务器APK的version信息
	LoginBO.asynGetServerApkVersion(function(data)
		local versionList = data.list
		gdump(versionList, "versionList")
		if not versionList then 
			--版本配置文件无法获取
			NetErrorDialog.getInstance():show({msg = InitText[17], code = nil}, function() LoginBO.getApkUpdateData(callBack) end)
			return 
		end

		--获得当前APK的versionCode和包名
	    ServiceBO.getPackageInfo(function(packageInfo)
	    	   --获得包体的包名和versionCode
	    	   local info = string.split(packageInfo, "|")
	    	   local apk_packageName = info[1]
		       local apk_versionCode = tonumber(info[2])

		       --根据包名取得版本信息
		       local versionData = LoginBO.getVersionDataByPackageName(versionList,apk_packageName)
		       if not versionData then Enter.startUpdate() gprint("========not need update") return end

		       --版本号无法获取
	       		if not versionData.versionCode then
	       			NetErrorDialog.getInstance():show({msg = InitText[23], code = nil}, function() LoginBO.getApkUpdateData(callBack) end)
					return  
	       		end
		       gprint("==============apk version compare===================")
		       gprint(apk_packageName,apk_versionCode)
		       gprint("local_versionCode:" .. apk_versionCode,"server_versionCode:"..versionData.versionCode)
		       gprint("==============apk version compare===================")
		       if apk_versionCode < versionData.versionCode then
		       		--版本下载地址无法获取
		       		if not versionData.url then
		       			NetErrorDialog.getInstance():show({msg = InitText[18], code = nil}, function() LoginBO.getApkUpdateData(callBack) end)
						return  
		       		end
		       		--需要更新
		       		NetErrorDialog.getInstance():show({msg = InitText[21], code = nil}, function() callBack(versionData.url) end)
		       	else
		       		Enter.startUpdate()
		       end
		    end)
		end)

end

function LoginBO.getVersionDataByPackageName(versionList,packageName)
	for index=1,#versionList do
		local versionData = versionList[index]
		if versionData.packageName == packageName then
			return versionData
		end
	end
	return nil
end

function LoginBO.getLoadingBg()
	local bg
    if GameConfig.environment == "anfan_client" then
        bg = display.newSprite("zLoginBg/bg_login_1.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "zty_client" or GameConfig.environment == "muzhiJhly_client" 
    	or GameConfig.environment == "tencent_muzhi" or GameConfig.environment == "muzhiJh_client" 
    	or GameConfig.environment == "mzwM1_client" or GameConfig.environment == "tt_client" then
        bg = display.newSprite("zLoginBg/bg_login_2.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "tencent_chpub" or GameConfig.environment == "chpub_client" 
    		or GameConfig.environment == "chYh_client" or GameConfig.environment == "tencent_chpub_zzzhg" 
    		or GameConfig.environment == "chpubNew_client" or GameConfig.environment == "hongshouzhi_client"
    		or GameConfig.environment == "tencent_chpub_redtank" or GameConfig.environment == "chCjzjtkzz_appstore" 
    		or GameConfig.environment == "chZjqytkdz_appstore" then
        bg = display.newSprite("zLoginBg/bg_login_tencent_chpub.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "tencent_anfan" or GameConfig.environment == "anfanKoudai_client" then
        bg = display.newSprite("zLoginBg/bg_login_tencent_anfan.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "tencent_anfan_hj3" then
        bg = display.newSprite("zLoginBg/bg_login_tencent_anfanhj3.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "tencent_anfan_fktk" then
        bg = display.newSprite("zLoginBg/bg_login_tencent_anfanfktk.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "tencent_muzhi_sjdz" or GameConfig.environment == "muzhi_49" then
        bg = display.newSprite("zLoginBg/bg_login_tencent_sjdz.jpg", display.cx, display.cy)
    elseif  GameConfig.environment == "ztyLy_client" or GameConfig.environment == "baiducl_client" then
    	bg = display.newSprite("zLoginBg/bg_login_ly.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "baidu_client" or GameConfig.environment == "wdj_client" 
    		or GameConfig.environment == "mzw_client" or GameConfig.environment == "jrtt_client"
    		or GameConfig.environment == "anzhi_client" or GameConfig.environment == "pptv_client"
    		or GameConfig.environment == "yyh_client" or GameConfig.environment == "meizu_client" 
    		or GameConfig.environment == "n_uc_client" or GameConfig.environment == "qihoo360_client" 
    		or GameConfig.environment == "nhdz_client" or GameConfig.environment == "sogou_client" 
    		or GameConfig.environment == "downjoy_client" or GameConfig.environment == "37wan_client" 
    		or GameConfig.environment == "ttyy_client" or GameConfig.environment == "pyw_client"
    		or GameConfig.environment == "kaopu_client" or GameConfig.environment == "haima_client" 
    		or GameConfig.environment == "tencent_muzhi_ly" or GameConfig.environment == "huashuo_client" 
    		or GameConfig.environment == "zhuoyou_client" or GameConfig.environment == "gameFan_client"
    		or GameConfig.environment == "mzwM2_client" or GameConfig.environment == "muzhiU8ly_client" 
			or GameConfig.environment == "muzhiJhYyb_client" or GameConfig.environment == "aile_client" 
			or GameConfig.environment == "muzhiTkjj_client" or GameConfig.environment == "youlong_client" 
			or GameConfig.environment == "muzhiJhYyb1_client" or GameConfig.environment == "mzlyhtc_client" then

    	bg = display.newSprite("zLoginBg/bg_login_tkjjcl.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "weiuu_client" then
    	bg = display.newSprite("zLoginBg/bg_login_ly_weiuu.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "tencent_muzhi_hd" or GameConfig.environment == "afTqdknHD_appstore" then
    	bg = display.newSprite("zLoginBg/bg_login_hd.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "ch_appstore" or GameConfig.environment == "chzzzhg_appstore" 
    	or GameConfig.environment == "chzzzhg1_appstore" or GameConfig.environment == "chzzzhg2_appstore" then
    	bg = display.newSprite("zLoginBg/bg_login_ios.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "tencent_anfan_tq" or GameConfig.environment == "af_appstore" 
    	or GameConfig.environment == "anfan_client_small" or GameConfig.environment == "anfanJh_client" 
    	or GameConfig.environment == "anfanaz_client" then
    	bg = display.newSprite("zLoginBg/bg_login_tq.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "mz_appstore" then
    	bg = display.newSprite("zLoginBg/bg_login_tkzz.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "chpub_hj4_client" or GameConfig.environment == "tencent_yxfc" then
    	bg = display.newSprite("zLoginBg/bg_login_hj4.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "chlhtk_appstore" then
    	bg = display.newSprite("zLoginBg/bg_login_lhtk.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "mztkwz_appstore" or GameConfig.environment == "mztkwz_client" then
    	bg = display.newSprite("zLoginBg/bg_login_tkwz.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "mztkdg_appstore" then
    	bg = display.newSprite("zLoginBg/bg_login_tkdg.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "mzeztk_appstore" then
    	bg = display.newSprite("zLoginBg/bg_login_eztk.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "mztkwc_appstore" then
    	bg = display.newSprite("zLoginBg/bg_login_tkwc.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "mztkjj_appstore" or GameConfig.environment == "muzhi_vertify" then
    	bg = display.newSprite("zLoginBg/bg_login_tkjj.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "afTkxjy_appstore" then
    	bg = display.newSprite("zLoginBg/bg_login_tkxjy.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "muzhi_93" then
    	bg = display.newSprite("zLoginBg/bg_login_dgjq.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "mztktj_appstore" then
    	bg = display.newSprite("zLoginBg/bg_login_tktj.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "chdgzhg_appstore" then
    	bg = display.newSprite("zLoginBg/bg_login_dgzhg.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "mztkjjhwcn_appstore" or GameConfig.environment == "ifeng_client" then
    	bg = display.newSprite("zLoginBg/bg_login_mztkjjhwcn.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "baiducltkjj_client" or GameConfig.environment == "mztkjjylfc_appstore" then
    	bg = display.newSprite("zLoginBg/bg_login_tkjjcl.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "chjxtk_appstore" then
    	bg = display.newSprite("zLoginBg/bg_login_jxtk.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "chcjzj_appstore" then
    	bg = display.newSprite("zLoginBg/bg_login_cjzj.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "chxsjt_appstore" then
    	bg = display.newSprite("zLoginBg/bg_login_xsjt.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "chgtfc_appstore" then
    	bg = display.newSprite("zLoginBg/bg_login_gtfc.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "chzdjj_appstore" then
    	bg = display.newSprite("zLoginBg/bg_login_zdjj.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "chdgfb_appstore" then
    	bg = display.newSprite("zLoginBg/bg_login_dgfb.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "chzjqy_appstore" then
    	bg = display.newSprite("zLoginBg/bg_login_zjqy.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "mzAqHszz_appstore" then
    	bg = display.newSprite("zLoginBg/bg_login_hszz.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "mzAqTkjt_appstore" then
    	bg = display.newSprite("zLoginBg/bg_login_tkjt.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "mztkjjylfcba_appstore" then
    	bg = display.newSprite("zLoginBg/bg_login_tkjj2.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "mzXmly_appstore" then
    	bg = display.newSprite("zLoginBg/bg_xmly.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "mzAqGtdg_appstore" then
    	bg = display.newSprite("zLoginBg/bg_AqGtdg.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "mzAqHxzz_appstore" then
    	bg = display.newSprite("zLoginBg/bg_AqHxzz.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "mzAqZbshj_appstore" then
    	bg = display.newSprite("zLoginBg/bg_AqZbshj.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "mzAqZzfy_appstore" then
    	bg = display.newSprite("zLoginBg/bg_AqZzfy.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "mzTkjjQysk_appstore" then
    	bg = display.newSprite("zLoginBg/bg_qysk.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "afGhgxs_appstore" then
    	bg = display.newSprite("zLoginBg/bg_ghgxs.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "afMjdzh_appstore" then
    	bg = display.newSprite("zLoginBg/bg_mjdzh.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "afWpzj_appstore" then
    	bg = display.newSprite("zLoginBg/bg_wpzj.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "afXzlm_appstore" then
    	bg = display.newSprite("zLoginBg/bg_xzlm.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "afTqdkn_appstore" or GameConfig.environment == "afNew_appstore" then
    	bg = display.newSprite("zLoginBg/bg_login_tq.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "afghgzh_client" or GameConfig.environment == "afGhgzh_appstore" then
    	bg = display.newSprite("zLoginBg/bg_login_afghgzh.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "mzGhgzh_appstore" then
    	bg = display.newSprite("zLoginBg/bg_login_mzGhgzh.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "chhjfc_hawei_client" or GameConfig.environment == "chhjfc_oppo_client"
    	or GameConfig.environment == "chhjfc_mi_client" or GameConfig.environment == "chhjfc_gp_client"
    	or GameConfig.environment == "chhjfc_uc_client" or GameConfig.environment == "chhjfc_sw_client"
    	or GameConfig.environment == "chhjfc_meizu_client" or GameConfig.environment == "chhjfc_coolpad_client"
    	or GameConfig.environment == "chhjfc_gionee_client" or GameConfig.environment == "chhjfc_downjoy_client"
    	or GameConfig.environment == "chhjfc_xiaoqi_client" or GameConfig.environment == "chhjfc_360_client"
    	or GameConfig.environment == "chhjfc_lenovo_client" or GameConfig.environment == "chhjfc_sanxing_client"
    	or GameConfig.environment == "chhjfc_baidu_client" or GameConfig.environment == "chhjfc_yyb_client" then
    	bg = display.newSprite("zLoginBg/bg_login_chhjfc.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "mzYiwanCyzc_appstore" then
    	bg = display.newSprite("zLoginBg/bg_login_cyzc.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "mzLzwz_appstore" then
    	bg = display.newSprite("zLoginBg/bg_login_lzwz.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "afNewMjdzh_appstore" then
    	bg = display.newSprite("zLoginBg/bg_afNewMjdzh.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "afNewWpzj_appstore" then
    	bg = display.newSprite("zLoginBg/bg_afNewWpzj.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "afLzyp_appstore" then
    	bg = display.newSprite("zLoginBg/bg_afLzyp.jpg", display.cx, display.cy)
    elseif GameConfig.environment == "chhjfc_appstore" then
    	bg = display.newSprite("zLoginBg/bg_chhjfc.jpg", display.cx, display.cy)
    else
        bg = display.newSprite("zLoginBg/bg_login.jpg", display.cx, display.cy)
    end


    return bg
end

--是否能够充值和创建角色
function LoginBO.enableRecharge()
	local enable = true
	if LoginMO.blackList and #LoginMO.blackList > 0 then
		for index=1,#LoginMO.blackList do
			local plat = LoginMO.blackList[index]
			gprint(plat,LOGIN_PLATFORM_PARAM)
			if plat == LOGIN_PLATFORM_PARAM then
				enable = false
				break
			end
		end
	end
	gprint(enable,"enable===")
	return enable
end

--拉取充值和创建角色的黑名单
function LoginBO.getRechargeBlack(callBack)
	local function getListCallback(event)
		local wrapper = event.obj
		local content = wrapper:getData()
		local data = json.decode(content)
		gdump(data, "LoginBO.asynGetBlackList")
		if data and data.blackList then
			LoginMO.blackList = data.blackList
		end
		if callBack then callBack() end
	end

	local url = "http://cdn.tank.hundredcent.com/version/recharge_black.json"
	
    local wrapper = NetWrapper.new(getListCallback, nil, true, REQUEST_TYPE_GET, url, false)
    wrapper:sendRequest()
end

function LoginBO.checkNickName(nick)
    local function isOk(string)
        local ch = string.byte(string, 1)

        if ch < 0 then ch = ch + 256 end

        if ch <= 127 then
        	if ch == 33 then
        		return true
            elseif ch >= 40 and ch <= 126 then
                return true
            end
        elseif ch >= 228 and ch <= 233 then  -- 中文
            return true
        elseif ch == 226 or ch == 227 or ch == 239 then
            local ch2 = string.byte(string, 2)
            local ch3 = string.byte(string, 3)

            if ch == 226 and ch2 == 128 and ch3 == 148 then  -- "—"
            	return true
            elseif ch == 226 and ch2 == 128 and ch3 == 156 then  -- "“"
            	return true
            elseif ch == 226 and ch2 == 128 and ch3 == 157 then  -- "”"
            	return true
            elseif ch == 227 and ch2 == 128 and ch3 == 130 then  -- "。" (0x3002)
                return true
            elseif ch == 227 and ch2 == 128 and ch3 == 138 then  -- "《"
                return true
            elseif ch == 227 and ch2 == 128 and ch3 == 139 then  -- "》"
                return true
            elseif ch == 239 and ch2 == 188 and ch3 == 136 then  -- "（"
            	return true
            elseif ch == 239 and ch2 == 188 and ch3 == 137 then  -- "）"
            	return true
            elseif ch == 239 and ch2 == 188 and ch3 == 140 then  -- "，"
            	return true
            elseif ch == 239 and ch2 == 188 and ch3 == 154 then  -- "："
            	return true
            elseif ch == 239 and ch2 == 188 and ch3 == 159 then  -- "？"
            	return true
            elseif ch == 239 and ch2 == 191 and ch3 == 165 then  -- "￥"
            	return true
            else
                return false
            end
        else
            return false
        end
    end

    local strTab = stringToChar_(nick)
    if not strTab then return false end

    -- local len = string.len(strTab[1])
    -- for index = 1, len do
    -- 	print("value:", string.byte(strTab[1], index))
    -- end

    for index = 1, #strTab do
        local content = strTab[index]
        if not isOk(content) then
            return false
        end
    end
    return true
end

--是否屏蔽兑换码
function LoginBO.enableCode(callBack)
	GameConfig.enableCode = true
	if not GameConfig.verifyURL then callBack(true)  return end
	if device.platform == "android" then
		callBack(true)
	elseif device.platform == "ios" or device.platform == "mac" or device.platform == "windows" then
		LoginBO.asynGetIosTest(function(data)
				gdump(data,"LoginBO.asynGetIosTest")
				local enable_ = true
				local localVersion = LoginBO.getLocalApkVersion() 
				if data.list then
					for index=1,#data.list do
						local dd = data.list[index]
						--渠道相同，版本号相同
						if dd.plat == GameConfig.environment and localVersion == dd.version then
							enable_ = false
							GameConfig.enableCode = false
							break
						end
					end
				end
				callBack(enable_)
			end
		)
	end
end

--拉取IOS是否审核状态标识
function LoginBO.asynGetIosTest(callBack)
    --判断网络环境是否IPV6
    ServiceBO.getIPAddress(function(ipAddress)
    		local function getIosTestCallback(event)
		        local wrapper = event.obj
		        local content = wrapper:getData()
		        gprint("content",content)
		        local data = json.decode(content)
		        if callBack then callBack(data) end
		    end
		    local url
    		local myDeviceIP = ipAddress
			local localVersion = LoginBO.getLocalApkVersion()
			if not myDeviceIP then myDeviceIP = "" end
			if (device.platform == "ios" or device.platform == "mac") and localVersion >= 200 and myDeviceIP:find(":") and GameConfig.verifyURL_ipv6 then
				url = GameConfig.verifyURL_ipv6
			else
				url = GameConfig.verifyURL
			end
			local wrapper = NetWrapper.new(getIosTestCallback, nil, true, REQUEST_TYPE_GET, url, false)
    		wrapper:sendRequest()
    	end
	)
end



--草花IOS 帝国指挥官 支付方式 1 苹果官方 2 第三方
function LoginBO.chPaytype(callBack)
	if not GameConfig.payTypeURL then callBack(1)  return end
	if device.platform == "android" then
		callBack(1)
	elseif device.platform == "ios" or device.platform == "mac" or device.platform == "windows" then
		LoginBO.asynGetChPaytype(function(data)
				gdump(data,"LoginBO.chPaytype")
				callBack(data.paytype)
			end
		)
	end
end

--拉取草花IOS 帝国指挥官 支付方式
function LoginBO.asynGetChPaytype(callBack)
    local function getChPaytypeCallback(event)
        local wrapper = event.obj
        local content = wrapper:getData()
        gprint("content",content)
        local data = json.decode(content)
        if callBack then callBack(data) end
    end
    local wrapper = NetWrapper.new(getChPaytypeCallback, nil, true, REQUEST_TYPE_GET, GameConfig.payTypeURL, false)
    wrapper:sendRequest()
end




function LoginBO.asynDoIosIdfa()
    local function callback(idfa)
    	local function doIdfaCallback(event)
        
    	end
    	local url = GameConfig.idfaURL .. "&idfa=" .. idfa
    	print("idfa:"..url)
    	local wrapper = NetWrapper.new(doIdfaCallback, nil, true, REQUEST_TYPE_GET, url, false)
    	wrapper:sendRequest()
    end
    ServiceBO.getIdfa(callback)
end

--草花智汇推
function LoginBO.asynZhihuitui()
	ServiceBO.getUUID(function(uuid)
	        local function doIdfaCallback(event)
    
			end
			local url = GameConfig.idfaURL .. "&muid=" .. uuid
			print("idfa:"..url)
			local wrapper = NetWrapper.new(doIdfaCallback, nil, true, REQUEST_TYPE_GET, url, false)
			wrapper:sendRequest()

			local function doIdfaWXCallback(event)
    
			end
			local url = GameConfig.idfaWXURL .. "?muid=" .. uuid
			print("idfaWX:"..url)
			local wrapper = NetWrapper.new(doIdfaWXCallback, nil, true, REQUEST_TYPE_GET, url, false)
			wrapper:sendRequest()
	    end)
end

--拉取线上 ver.manifest
function LoginBO.checkVersion(callBack)
	local function getVersionCallback(event)
        local wrapper = event.obj
        local content = wrapper:getData()
        if callBack then callBack(content) end
	end

	local wrapper = NetWrapper.new(getVersionCallback, nil, true, REQUEST_TYPE_GET, GameConfig.VER_URL, false)
	wrapper:sendRequest()

end