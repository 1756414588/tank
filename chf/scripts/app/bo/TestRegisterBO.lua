
TestRegisterBO = {}

local g_name = "a"
local m_createIndex = 4

function TestRegisterBO.create(index, doneCallback)
    local function doneGuide(name, data)
        -- gdump(data)
        doneCallback()
    end

    local function doneSetLv()
        SocketWrapper.wrapSend(doneGuide, NetRequest.new("DoneGuide"))
    end

    local function doneCreteRole()
        -- SocketWrapper.wrapSend(doneSetLv, NetRequest.new("DoSome", {str = "set lv 3"}))
        doneGuide()
    end

	local function doneBeginGame()
		SocketWrapper.wrapSend(doneCreteRole, NetRequest.new("CreateRole", {nick = g_name .. index, portrait = 1, sex = 1}))
	end

    local function connectCallback()
        local param = {
            serverId = GameConfig.areaId,
            keyId = GameConfig.keyId,
            token = GameConfig.token,
            deviceNo = GameConfig.uuid,
            curVersion = GameConfig.version
        }

        -- gdump(param, "BeginGame")

        SocketWrapper.wrapSend(doneBeginGame, NetRequest.new("BeginGame", param))
    end

    local function doneTest(event)
        local wrapper = event.obj
        local doRegister = wrapper:getRequestByName("DoRegister")

        local data = doRegister:getData()
        gdump(data, "DoRegister data")

        GameConfig.areaId = 1
        GameConfig.token = data.token
        GameConfig.keyId = data.keyId

        -- 获得GameURL
        LoginBO.initGameURL()

        PbProtocol.loadPb("Common.pb")
        PbProtocol.loadPb("Game.pb")

        SocketReceiver.init()
        -- if SocketWrapper.getInstance() then
        --     if SocketWrapper.getInstance():isConnected() then -- 已经连接了
        --         -- print("已经连接了")
        --         SocketWrapper.getInstance():disconnect()
        --     else
        --         -- print("有实例，但是没有连接上")
        --     end

        --     SocketWrapper.deleteInstance()
        -- end
        SocketWrapper.init(GameConfig.gameSocketURL, GameConfig.gamePort, connectCallback)

    end

    local registerData = {
        plat = GameConfig.loginPlatform,
        version = GameConfig.version,
        baseVersion = GameConfig.baseVersion,
        deviceNo = GameConfig.uuid,
        accountId = g_name .. index,
        passwd = "1"
    }

    local doRegister = NetRequest.new("DoRegister", registerData)

    local wrapper = NetWrapper.new(doneTest, nil, nil, nil, GameConfig.accountURL)
    wrapper:addRequest(doRegister)
    wrapper:sendRequest()
end

function TestRegisterBO.start()
    display.getRunningScene():removeAllChildren()

	local function next()
		m_createIndex = m_createIndex + 1
		if m_createIndex <= 10000 then
			TestRegisterBO.create(m_createIndex, next)
		end
	end

    local function create()
	   TestRegisterBO.create(m_createIndex, next)
    end

    LoginBO.asynGetServerList(create)
end
