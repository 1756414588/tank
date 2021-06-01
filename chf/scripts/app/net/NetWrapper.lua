

cc.utils = require("framework.cc.utils.init")

local NetWrapper = class("NetWrapper", Request)

-- local REQUEST_HEADER = "Content-Type:application/json;charset=UTF-8"
local REQUEST_HEADER = "Content-Type:application/octet-stream"
local REQUEST_HEADER_ANDROID = "Content-Type=application/octet-stream"

REQUEST_TYPE_GET = "GET"
REQUEST_TYPE_POST = "POST"

local REQUEST_TYPE_DEFAULT = REQUEST_TYPE_POST

local id_ = 1

-- local function checkResponse(data, proxy)
--  local code = data.code
--  if code == 200 then
--  else
--      if code == 291 then
--          --自动重发获取session请求(间隔500毫秒)
--          Helper.Sleep(0.1)
--          NetWrapper.reBeginGame(proxy)
--          elseif code == 292 then
--              NetWrapper.rebegin = nil
--              NetErrorDlg.new({msg=ErrorText.text292, code=292}, function()
--                  ManagerScenes.switchScene("login")
--                  end)
--          else
--              if proxy.m_errorListener then
--                  proxy.m_errorListener()
--              else
--                  local text = ErrorText["text"..tostring(data.code)]
--                  if text == nil then
--                      text = ErrorText.textnil
--                  end
--                  Toast.new(text):show()
--              end
--          end
--          return false
--      end
--      return true
    -- end
    
local function findRequestByResponseCmd(wrapper, cmdId)
    if not wrapper.requests then return nil end

    for index = 1, #wrapper.requests do
        local request = wrapper.requests[index]
        if PbList[request:getName()] and PbList[request:getName()][2] == cmdId then
            return request
        end
        -- if request:getName() == requestName then
        --     return request
        -- end
    end
    return nil
end

--包装回调
local function callBackWrap(wrapper)
    return function(event)
        if wrapper.mask then
            Loading.getInstance():unshow()
        end

        local request = event.request

        local ok = (event.name == "completed")

        if not ok then
            gprint("[NetWrapper] 网络异常，无法连接 not ok")
            -- 网络异常，请重试
            if request:getErrorCode() == 0 then
                NetErrorDialog.getInstance():show({msg = wrapper.errText or ErrorText.text7, code = nil}, function() wrapper:sendRequest() end)
            else
                NetErrorDialog.getInstance():show({msg= wrapper.errText or request:getErrorMessage(), code=request:getErrorCode()}, function() wrapper:sendRequest() end)
            end
            return
        end

        -- print("code:", request:getResponseStatusCode())
        if request:getResponseStatusCode() ~= 200 then
            gprint("[NetWrapper] 网络错误 not 200")
            -- 弹出框，确认重新发送
            NetErrorDialog.getInstance():show({msg = wrapper.errText or request:getErrorMessage(), code = request:getResponseStatusCode()}, function() wrapper:sendRequest() end)
            return
        end

        -- 请求成功，显示服务端返回的内容

        local ok = true
        local errorCode = 0

        -- local result = nil

        if wrapper.encode then
            local ary = cc.utils.ByteArray.new()
            ary:setEndian(cc.utils.ByteArray.ENDIAN_BIG)
            ary:writeBuf(request:getResponseData())
            ary:setPos(1)

            -- gprint("返回总长:", ary:getLen())
            while ary:getPos() <= ary:getLen() do
                local msgLen = ary:readShort()
                -- gprint("长度:", msgLen)
                local msgData = ary:readString(msgLen)

                local name, cmd, code, param, data = PbProtocol.decode(msgData)

                gdump(data, "[NetWrapper] 获得的数据")

                if code ~= 200 then
                    errorCode = code
                    ok = false
                else
                    local request = findRequestByResponseCmd(wrapper, cmd)
                    if request then
                        request:setData(data)
                    else
                        gdump("[NetWrapper] callBackWrap Error! not find request !!!")
                    end
                end

                -- local data = PbProtocol.decode("Base", msgData)
                -- -- dump(data, "all data")
                -- -- dump( protobuf.unpack("Base", msgData), "all data")

                -- if data.code ~= 200 then
                --     errorCode = data.code
                --     ok = false
                -- else
                --     local request = findRequestByResponseCmd(wrapper, data.cmd)
                --     if request then
                --         local retData = PbProtocol.decode(data[request:getName() .. "Rs.ext"][1], data[request:getName() .. "Rs.ext"][2])
                --         request:setData(retData)
                --         -- gdump(retData, "return data")
                --     else
                --         gdump("[NetWrapper] callBackWrap Error! not find request !!!")
                --     end
                -- end
            end
        else
            result = request:getResponseData()
            wrapper:setData(result)
        end

        if ok then
            -- 数据都ok，则通知出去
            Notify.notify(wrapper:getName(), wrapper)
            -- 通知完了就解绑
            Notify.unregisterAll(wrapper:getName())
        else
            if errorCode == 291 then  -- 自动重发获取session请求
                gprint("session已经失效，需要重新连接，这块位置还没有处理")
            else
            end

            if errorCode == 1404 then -- 系统正在维护中
                if UiDirector.hasUiByName("HomeView") then  -- 在游戏中进行登录(重新登录)
                    NetErrorDialog.getInstance():show({msg = ErrorText.text1404, code = nil}, function() os.exit() end)
                    return
                end
            end

            local listener = wrapper:getErrorListener()
            -- 如果没有监听，则直接Toast；否则，监听后如果返回true，则显示Toast
            if not listener or (listener and listener(wrapper, errorCode)) then
                gprint("[NetWrapper] ERROR!!! code:", errorCode)

                local text = ErrorText["text" .. tostring(errorCode)]
                text = text or ErrorText.textnil
                text = text .. "(" .. errorCode .. ")"
                Toast.show(text)
            end
        end
    end
end

local function urlencode(str)
    local function urlencodeChar(char)
        return "%" .. string.format("%02X", string.byte(char))
    end

    -- convert line endings
    str = string.gsub(tostring(str), "\n", "\r\n")
    -- escape all characters but alphanumeric, '.' and '-'
    str = string.gsub(str, "([^%w%.%-_ ])", urlencodeChar)
    -- convert spaces to "+" symbols
    return string.gsub(str, " ", "+")
end

function encodeCookieString(cookie)
    local arr = {}
    for name, value in pairs(cookie) do
        if type(value) == "table" then
            value = tostring(value.value)
        else
            value = tostring(value)
        end

        arr[#arr + 1] = tostring(name) .. "=" .. urlencode(value)
    end
    return table.concat(arr, "; ")
end

function NetWrapper:ctor(listener, wrapperName, mask, reqType, reqUrl, encode, errText, header)
    if mask == nil then mask = true end
    if encode == nil then encode = true end
    -- if isJson == nil then isJson = true end

    wrapperName = wrapperName or "default_" .. id_
    reqType = reqType or REQUEST_TYPE_DEFAULT
    reqUrl = reqUrl or GameConfig.gameURL

    NetWrapper.super.ctor(self, wrapperName)

    Notify.register(self:getName(), listener)

    self.reqType = reqType
    self.reqUrl = reqUrl
    self.mask = mask
    self.encode = encode
    self.errText = errText
    self.header = header

    self.m_errorListener = nil

    id_ = id_ + 1
end

-- errorListener如果返回true，则还会显示Toast信息
function NetWrapper:registerErrorListener(errorListener)
    self.m_errorListener = errorListener
end

function NetWrapper:getErrorListener()
    return self.m_errorListener
end

function NetWrapper:addRequest(reqObj, index)
    if not self.requests then
        self.requests = {}
    end

    local requests = self.requests

    if index then
        table.insert(requests, index, reqObj)
    else
        table.insert(requests, reqObj)
    end
end

-- function NetWrapper:addRequestAtBegin(reqObj)
--  local requests = self.requests
--  if not requests then
--      requests = {}
--      self.requests = requests
--  end

--  table.insert(requests, 1, reqObj)
-- end

function NetWrapper:sendRequest()
    if self.mask then
        Loading.getInstance():show(nil, GAME_INVALID_VALUE)
    end

    gprint("[NetWrapper] url:", self.reqUrl)
    gprint("[NetWrapper] type:", self.reqType)

    local content = nil

    if self.requests then
        if GLOBAL_NETWORK_ENCODE and self.encode then
            local ary = cc.utils.ByteArray.new()
            ary:setEndian(cc.utils.ByteArray.ENDIAN_BIG)

            local list = self.requests
            for index = 1, #list do
                local unit = list[index]
                gprint("[NetWrapper] pro:", unit.name_)

                local data = PbProtocol.encode(unit.name_ .. "Rq", PbList[unit.name_][1], unit.param_)
                -- gprint("发送长度:", #data)
                ary:writeShort(#data)
                ary:writeBuf(data)
            end
            content = ary:getBytes()
        else
            local list = self.requests
            local msg = {}
            for index = 1, #list do
                table.insert(msg, list[index]:pack())
            end
            content = json.encode(msg)
        end
    end

    local request = network.createHTTPRequest(callBackWrap(self), self.reqUrl, self.reqType)
    if self.header then
        request:addRequestHeader(self.header)
        request:setAcceptEncoding(kCCHTTPRequestAcceptEncodingGzip)
    else
        if device.platform == "android" then
            request:addRequestHeader(REQUEST_HEADER_ANDROID)
        else
            request:addRequestHeader(REQUEST_HEADER)
        end
    end

    -- request:setCookieString(encodeCookieString({JSESSIONID = GameConfig.session}))
    if content then request:setPOSTDataWithLenth(content, #content) end
    request:setTimeout(20)
    request.wrapper = self

    -- 发送
    NetQueue.triggerRequest(request)
end

function NetWrapper:getRequestByName(requestName)
    if not self.requests then return end

    for index = 1, #self.requests do
        local request = self.requests[index]
        if request:getName() == requestName then
            return request
        end
    end
    return nil
end

function NetWrapper:setUrl(reqUrl)
    self.reqUrl = reqUrl
end

function NetWrapper:setMask(mask)
    self.mask = mask
end

function NetWrapper:setReqType(reqType)
    self.reqType = reqType
end

--session失效后处理
-- function NetWrapper.reBeginGame(proxy)
--  if NetWrapper.rebegin == true then return end
--  local beginGameCallBack = function()
--      NetWrapper.rebegin = nil
--      local data = ManagerData.getCacheData(BeginGame).data
--      GameConfig.session = data.sd
--      if data.state == 1 then
--          ManagerScenes.switchScene("role")
--      elseif data.state == 2 then
--          Helper.Sleep(0.1)
--          if proxy then
--              local roleLogin= ManagerData.getCacheData(RoleLogin, false)
--              proxy:addRequestAtBegin(roleLogin)
--              proxy:sendRequest()
--          end
--      elseif data.state == 3 then
--          Toast.new(LoginText[32]):show()
--      elseif data.state == 4 then
--          Toast.new(LoginText[33]):show()
--      end
--  end

--  local param = {
--      serverId = GameConfig.areaId,
--      keyId = GameConfig.keyId,
--      token = GameConfig.token,
--      deviceNo = GameConfig.uuid
--  }
            
--  NetWrapper.rebegin = true
--  GameConfig.session = nil
--  ManagerRequestLogin.requestReBeginGame(param,beginGameCallBack)
-- end

function NetWrapper.wrapSend(listener, requests)
    local wrapper = NetWrapper.new(listener)
    if requests and #requests > 0 then
        for index = 1, #requests do
            wrapper:addRequest(requests[index])
        end
    end
    wrapper:sendRequest()
    return wrapper
end

return NetWrapper
