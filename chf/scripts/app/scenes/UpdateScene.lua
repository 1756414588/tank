--
-- 更新

require_ex("app.text.InitText")
-- require_ex("app.utils.Helper")

local server = GameConfig.downRootURL
local param = "?dev="..device.platform
local list_filename = "cache.manifest"
local ver_filename = "ver.manifest"
local downList = {}

local function hex(s)
    s=string.gsub(s,"(.)",function (x) return string.format("%02X",string.byte(x)) end)
    return s
end

local function readFile(path)
    local file = io.open(path, "rb")
    if file then
        local content = file:read("*all")
        io.close(file)
        return content
    end
    return nil
end

local function removeFile(path)
    --CCLuaLog("removeFile: "..path)
    io.writefile(path, "")
    if device.platform == "windows" then
        -- os.execute("del " .. string.gsub(path, '/', '\\'))
        os.remove(string.gsub(path, '/', '\\'))
    else
        -- os.execute("rm " .. path)
        os.remove(path)
    end
end

local function renameFile(path, newPath)
    removeFile(newPath)
    os.rename(path, newPath)
    -- print("renameFile---------------> " .. path .. "  ==> " .. newPath)
end

local function checkFile(fileName, cryptoCode)
    if not io.exists(fileName) then
        return false
    end

    local data = readFile(fileName)
    if data == nil then
        gprint("文件不存在:", filename)
        return false
    end

    if cryptoCode == nil then
        return true
    end

    local ms = crypto.md5(hex(data))
    if ms == cryptoCode then
        return true
    end

    -- gprint("md5差异:", fileName, cryptoCode, ms)

    return false
end

--生成更新列表{{name="scripts/app/address/debug.lua",code="aadebdda85b00096b0801a34a908d4d6"}}
local function compManifest(oList, newList)
    local oldList = {}
    
    for i = 1, #oList do
        oldList[oList[i].name] = oList[i].code
    end

    -- gprint("@^^^^map complete:" .. table.nums(oldList))

    local list = {}
    for i = 1, #newList do
        local name = newList[i].name
        if newList[i].code ~= oldList[name] then
            table.insert(list, newList[i])
        end
    end
    gprint("@^^^^newList count:" .. #list)
    return list
end

function loadJsonData(name)
    local path = CCFileUtils:sharedFileUtils():fullPathForFilename(name)
    if path then
        local fileData = CCFileUtils:sharedFileUtils():getFileData(path)
        return json.decode(fileData)
    end
end

-- function playAnimationRepeat(sprite, path, name, delay)
--     local fileName = path .. name
--     local data = loadJsonData(fileName .. ".json")
--     -- dump(data, "data------------>")
--     local posData = data.frames
--     local texture = CCTextureCache:sharedTextureCache():addImage(fileName .. ".png")
--     local frames = {}
--     for i=1,#posData do
--         local pos = posData[i]
--         -- local frameName = string.format("%s%03d.png", name, i - 1)
--         local frame = CCSpriteFrame:createWithTexture(texture, CCRect(pos[1], pos[2], pos[3], pos[4]))
--         frame:setOffset(ccp(pos[3] / 2 - pos[6] , pos[7] - pos[4] / 2))
--         frames[#frames + 1] = frame
--     end
--     sprite:playAnimationForever(display.newAnimation(frames, delay))
--     -- transition.playAnimationForever(sprite, display.newAnimation(frame), delay)
-- end

local function checkDirOK( path )
    require "lfs"
    local oldpath = lfs.currentdir()
    -- CCLuaLog("old path------> "..oldpath)

    if lfs.chdir(path) then
        lfs.chdir(oldpath)
        -- CCLuaLog("path check OK------> "..path)
        return true
    end

    if lfs.mkdir(path) then
        -- CCLuaLog("path create OK------> "..path)
        return true
    end
end

local function checkCacheDirOK(root_dir, path)
    path = string.gsub(string.trim(path), "\\", "/")
    -- gprint("checkCacheDirOK---------->", root_dir, path)
    local info = io.pathinfo(path)
    local dirs = string.split(info.dirname, "/")
    local sdir = root_dir
    if not checkDirOK(sdir) then return false end
    for i = 1, #dirs do
        if string.sub(sdir, -1, -2) ~= "/" then sdir = sdir .. "/" end
        sdir = sdir .. dirs[i]
        if not checkDirOK(sdir) then
            return false
        end
    end
    return true
end

------------------------------------------------------------------------------
--define UpdateScene
------------------------------------------------------------------------------
local UpdateScene = class("UpdateScene", function()
    return display.newScene("UpdateScene")
    end)

function UpdateScene:ctor()
    local bg = LoginBO.getLoadingBg()
    bg:setScale(GAME_X_SCALE_FACTOR)
    self:addChild(bg)
    self.bg = bg
    downList = {}
    -- self.beginGame = nil
    --缓存目录
    self.path = CACHE_DIR

    --缓存目录下的版本文件名 self.path .. ver_filename
    self.curVerFile = nil

    --服务器上的版本文件内容
    self.curVer = nil

    --缓存目录下的列表文件名 self.path .. list_filename
    self.curListFile =  nil

    --列表文件内容 dofile(self.curListFile)         
    -- self.fileList = {ver = "1.0.0", stage = {}}
    self.fileList = nil

    --upd列表文件名 self.curListFile..".upd"
    self.newListFile = nil

    --需要更新的列表内容 {{name="scripts/app/address/debug.lua",code="aadebdda85b00096b0801a34a908d4d6"}}
    self.needUpdateList = nil

    --当前更新的文件序号 1,2,3, 序号对应needUpdateList中的位置
    self.numFileCheck = nil

    --当前处理的条目,是self.needUpdateList中的一条
    self.curStageFile = nil

    self.updateSuccess = false

    self.errorOccur = false

    self.rmvRes = false

    self.nowFile = nil --当前正在更新的文件
end

function UpdateScene:onEnter()
    if GameConfig.skipUpdate then
        self:enterLogin()
        return
    end
    -- 显示版本号
    local versionLab = ui.newTTFLabel({text = "", font = G_FONT, size = FONT_SIZE_SMALL, x = display.width, y = 30, color = ccc3(255, 255, 255)}):addTo(self, 1000)
    versionLab:setAnchorPoint(cc.p(1,0.5))
    if GAME_APK_VERSION then
        versionLab:setString("App v" .. GAME_APK_VERSION .. "  Res v" .. GameConfig.version)
    else
        versionLab:setString("Res v" .. GameConfig.version)
    end
    self:initUI()

    self:getUpdatePath(function(path)
            server = server .. path
            gprint("更新地址目录:" .. server)
            self:runAction(transition.sequence({cc.DelayTime:create(1), CCCallFunc:create(function()
                gprint("@^^^^start update")
                gprint("@^^^^check self.path ", self.path)
                if not checkDirOK(self.path) then
                    gprint("@^^^^check self.path ok")
                    self:runApp(true)
                    return
                end

                gprint("@^^^^请求版本号")
                --请求版本号
                self:getVer()
                self:requestVer()

                self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.onEnterFrame))
                self:scheduleUpdate()

                
            end)}))
        end)

    
end

function UpdateScene:initUI()
    --加载资源
    -- armature_add("image/animation/effect/ui_logo.pvr.ccz", "image/animation/effect/ui_logo.plist", "image/animation/effect/ui_logo_light.xml")

    -- local lightEffect = CCArmature:create("guoming_logo_guang_mc")
    -- lightEffect:retain()
    -- lightEffect:setPosition(GAME_ORIGIANL_X + GAME_SIZE_WIDTH - lightEffect:getContentSize().width / 2 - 60, GAME_ORIGIANL_Y + GAME_SIZE_HEIGHT - lightEffect:getContentSize().height / 2 - 10)
    -- lightEffect:getAnimation():playWithIndex(0)
    -- lightEffect:connectMovementEventSignal(function(movementType, movementID) end)
    -- self:addChild(lightEffect)

    self.updateView = display.newNode():addTo(self)

    local barBgName = ""

    if LoginBO.getLocalApkVersion() <= HOME_SNOW_VERSION then
        barBgName = "image/screen/a_bg_7.png"
    else
        barBgName = "image/screen/b_bg_7.png"
        if HOME_SNOW_DEFAULT == 1 then
            barBgName = "image/screen/a_bg_7.png"
        end
    end

    local bar = ProgressBar.new(IMAGE_COMMON .. "login/bar_1.png", BAR_DIRECTION_HORIZONTAL, cc.size(296, 20), {bgName = barBgName}):addTo(self.updateView)
    bar:setPosition(display.cx, display.cy - 380)
    bar:setPercent(0)
    self.m_progressBar = bar
    --提示语
    ui.newTTFLabelWithOutline({text=InitText[22][1],font=G_FONT,size=20,align=ui.TEXT_ALIGN_CENTER})
        :addTo(self):pos(display.cx,display.cy - 310)
    ui.newTTFLabelWithOutline({text=InitText[22][2],font=G_FONT,size=20,align=ui.TEXT_ALIGN_CENTER})
        :addTo(self):pos(display.cx,display.cy - 335)
    local dot = display.newSprite("image/common/login/downEffect.png"):addTo(bar,100)
    dot:setPosition(0, 10)
    self.dot = dot

    self.m_msgLabel = ui.newTTFLabel({text = InitText[1], font = G_FONT, size = FONT_SIZE_SMALL, x = display.cx, y = display.cy - 420, align = ui.TEXT_ALIGN_CENTER}):addTo(self.updateView)
    self.m_msgLabel:setColor(ccc3(255,255,255))
end

function UpdateScene:updateUI(msg, percent, barVisible)
    if not barVisible then barVisible = true end

    self.m_msgLabel:setString(msg)
    self.m_progressBar:setPercent(percent)
    self.m_progressBar:setVisible(barVisible)

    local w = self.m_progressBar:getContentSize().width * percent
    self.dot:setPositionX(w)
end

function UpdateScene:updateFiles()
    self.fileList = dofile(self.newListFile)
    if self.fileList == nil then
        self.errorOccur = true
        self:endProcess(InitText[10])
        return
    end

    for i,v in ipairs(downList) do
        --去掉.upd
        local fn = string.sub(v, 1, -5)
        renameFile(v, fn)
    end

    io.writefile(self.curVerFile, self.curVer)
    renameFile(self.newListFile, self.curListFile)

    GameConfig.version = self.fileList.ver
    self.updateSuccess = true
    self:endProcess(InitText[11])
end

function UpdateScene:cleanUpdFiles()
    for i,v in ipairs(downList) do
        local fn = string.sub(v, 1, -5)
        renameFile(v, fn)
    end
end

--从服务器下载需要更新的文件
function UpdateScene:reqNextFile()
    self.numFileCheck = self.numFileCheck + 1
    self.curStageFile = self.needUpdateList[self.numFileCheck]

    if self.curStageFile and self.curStageFile.name then
        local filename = io.pathinfo(self.curStageFile.name).filename
        local fn = self.path .. self.curStageFile.name
        local updFn = fn .. ".upd"

        local percent = self.numFileCheck / #self.needUpdateList
        self:updateUI(InitText[2]..tostring(math.floor(percent*100)) .. "%", percent)

        if io.exists(updFn) then
            if checkFile(updFn, self.curStageFile.code) then
                table.insert(downList, updFn)
                local action = CCCallFunc:create(function() self:reqNextFile() end)
                self:runAction(action)
                return
            end
        else
            if checkFile(fn, self.curStageFile.code) then
                local action = CCCallFunc:create(function() self:reqNextFile() end)
                self:runAction(action)
                return
            end
        end

        self:requestFromServer(self.curStageFile.name)
        return
    end

    --下载完成
    self:updateUI(InitText[13], 1)  -- 正在缓存

    self:runAction(
        transition.sequence({CCDelayTime:create(1.5), CCCallFunc:create(function() self:updateFiles() end)}))
end

function UpdateScene:onEnterFrame(dt)

    if self.dataRecv then
        if self.requesting == ver_filename then
            self.errorOccur = false
            if self.dataRecv ~= self.version then
                self.curVer = self.dataRecv
                gprint("@^^^请求cacheManifest文件", self.dataRecv, self.version)
                self:getFileList()
                self:requestManifest()
            else
                self.dataRecv = nil
                self:endProcess(InitText[6])
            end
            return
        end

        if self.requesting == list_filename then
           gprint("@^^^写到本地cacheManifest文件", self.newListFile)
           io.writefile(self.newListFile, self.dataRecv)
           self.dataRecv = nil

           local newList = dofile(self.newListFile)
           if newList == nil then
                self.errorOccur = true
                self:endProcess(string.format(InitText[5], self.newListFile))
                return
           end

        CCLuaLog(newList.ver)
        gprint("@^^^比较newList.ver与self.fileList.ver", newList.ver, self.fileList.ver, self.version)

        if (newList.ver == self.fileList.ver) and (newList.ver == self.version) then
            removeFile(self.newListFile)
            self:endProcess("")
            return
        end

        --检查WIFI
        -- local updateConfirm = function()
        --     confirmDialog:startCloseDialog()
        --     self.wifiStatus = true
        -- end
        -- local updateCancel = function()
        --     os.exit()
        -- end
        -- if not network.isLocalWiFiAvailable() then
        --     local confirmDialog = ConfirmDialog.new(InitText[16],updateConfirm,updateCancel)
        --     self:addChild(confirmDialog)
        --     self.wifiStatus = false
        -- else
        --     self.wifiStatus = true
        -- end

        -- if self.wifiStatus == true then
        --     self.needUpdateList = compManifest(self.fileList.stage, newList.stage)
        --     gprint("@^^^needUpdateList", #self.needUpdateList)
        --     self.customBar:setValue(0, #self.needUpdateList)
        --     self.numFileCheck = 0
        --     self.requesting = "files"
        --     self:reqNextFile()
        -- end


        --比较获得需要更新的列表        
        self.needUpdateList = compManifest(self.fileList.stage, newList.stage)
        gdump(self.needUpdateList,"self.needUpdateList")
        gprint("@^^^needUpdateList", #self.needUpdateList)
        -- self.customBar:setValue(0, #self.needUpdateList)

        --计算列表中文件的大小
        local allSize = self:getDownLoadSize()
        --如果有文件大小，则弹出提示
        if device.platform == "android" and allSize > 0 then
            local dialog = NetErrorDialog.getInstance()
            dialog:show({msg = string.format(InitText[30],self:convertingBit(allSize)), code = nil}, function()
                self.numFileCheck = 0
                self.requesting = "files"
                self:reqNextFile()
            end,function() os.exit() end)
        else
            self.numFileCheck = 0
            self.requesting = "files"
            self:reqNextFile()
        end
        return
    end

    if self.requesting == "files" then
        local fn = self.path..self.curStageFile.name..".upd"
            --检查并创建多级目录
            if not checkCacheDirOK(self.path, self.curStageFile.name) then 
                self.errorOccur = true
                self:endProcess(InitText[7])
                return
            end
            io.writefile(fn, self.dataRecv)
            self.dataRecv = nil
            if checkFile(fn, self.curStageFile.code) then
                --下载正确
                table.insert(downList, fn)
                self:reqNextFile()
            else
                --错误
                self.errorOccur = true
                self:endProcess(InitText[8])
            end
            return
        end
        return
    end
end

function UpdateScene:runApp(restart)
    cc.FileUtils:sharedFileUtils():purgeCachedEntries()

    if restart then
        collectgarbage("collect")
        local oneSec = transition.sequence({CCDelayTime:create(1), CCCallFunc:create(handler(self,self.enterLogo))})
        self:runAction(oneSec)
    else
        local oneSec = transition.sequence({CCDelayTime:create(1), CCCallFunc:create(handler(self,self.enterLogin))})
        self:runAction(oneSec)
    end
end

function UpdateScene:enterLogin()
    require_ex("app.Enter")
    Enter.startLogin()
end

function UpdateScene:enterLogo()
    require_ex("app.Enter")
    Enter.startLogo()
end

--获取本地版本文件的版本号
function UpdateScene:getVer()
    --本地cache.manifest
    self.curVerFile =  self.path .. ver_filename

    gprint("@^^^^require self.curVerFile", self.curVerFile)
    --从缓存目录读文件列表
    if io.exists(self.curVerFile) then
        self.version = CCFileUtils:sharedFileUtils():getFileData(self.curVerFile)
    else
        --从初始目录读文件列表
        local cpath = CCFileUtils:sharedFileUtils():fullPathForFilename(ver_filename);
        
        gprint("@^^^^从初始目录读版本文件", cpath)
        
        if cpath ~= ver_filename then
            self.version = CCFileUtils:sharedFileUtils():getFileData(cpath)
        end
        gprint("@^^^^从初始目录读版本文件complete")
    end

    --两个目录下都未找到
    if self.version == nil then
        gprint("@^^^^两个目录下都未找到")
        self.version = "1.0.0"
    end

    GameConfig.version = self.version
end

--读取本地的列表文件
function UpdateScene:getFileList()
    --本地cache.manifest
    -- dump(self.path .. list_filename)
    self.curListFile =  self.path .. list_filename
    self.fileList = nil
    
    gprint("@^^^^require self.curListFile", self.curListFile)
    --从缓存目录读文件列表
    if io.exists(self.curListFile) then
        self.fileList = dofile(self.curListFile)
    else
        --从初始目录读文件列表
        local cpath = CCFileUtils:sharedFileUtils():fullPathForFilename(list_filename);

        gprint("@^^^^从初始目录读文件列表", cpath)

        if cpath ~= list_filename then
            local fileData = CCFileUtils:sharedFileUtils():getFileData(cpath)
            if fileData then self.fileList = assert(loadstring(fileData))() end
        end

        gprint("@^^^^从初始目录读文件列表complete")
    end

    --两个目录下都未找到
    if self.fileList == nil then
        gprint("@^^^^两个目录下都未找到")
        self.fileList = {
        ver = "1.0.0",
        stage = {}}
    end

end

--获取服务器上的版本文件
function UpdateScene:requestVer()
    self.requestCount = 0
    self.requesting = ver_filename
    self.dataRecv = nil
    self:requestFromServer(self.requesting)
end

--获取服务器上的列表文件
function UpdateScene:requestManifest()
    self.requesting = list_filename
    --新的cache.manifest
    self.newListFile = self.curListFile..".upd"
    self.dataRecv = nil
    self:requestFromServer(self.requesting)
end

function UpdateScene:onExit()
    self:removeAllChildrenWithCleanup(true)
    if self.rmvRes then
        -- armature_remove("image/animation/effect/ui_logo.pvr.ccz", "image/animation/effect/ui_logo.plist", "image/animation/effect/ui_logo_light.xml")
    end
end

function UpdateScene:endProcess(msg)
    if not msg then msg = "" end
    if msg == InitText[6] then
        self:updateUI(msg, 1)
    else
        self.m_msgLabel:setString(msg)
    end

    --更新失败处理
    if self.errorOccur == true then
        local dialog = NetErrorDialog.getInstance()
        dialog:show({msg = InitText[14], code = nil}, function()
            --断线重连
            self.errorOccur = false
            self:requestFromServer(self.nowFile)
        end)
        dialog.m_okBtn:setLabel(InitText[25])
        return
    end
    

    if self.updateSuccess == true then
        self.updateSuccess = false
        self:runApp(true)
    else
        self:runApp(false)
    end
end

function UpdateScene:reloadPack(modename)
    gprint("reloadPack:" .. modename)
    if string.sub(modename, -4, -1) == ".lua" then
        local name = string.sub(modename, 9, -5)
        name = string.gsub(name, "/", ".")
        reload_ex(name)
        self.needRestart = true
    end
end

function UpdateScene:requestFromServer(filename, waittime)
    local url = server..filename..param
    self.requestCount = self.requestCount + 1
    local index = self.requestCount
    gprint("@^^^^^requestFromServer", url)
    if filename == ver_filename then
        GameConfig.VER_URL = url
    end
    self.nowFile = filename
    local request = network.createHTTPRequest(function(event)
        self:onResponse(event, index)
        end, url, "GET")
    
    if request then
        request:setTimeout(30)
        request:start()
    else
        self.errorOccur = true
        self:endProcess("HttpRequest is null")
    end
end

function UpdateScene:onResponse(event, index, dumpResponse)
    local request = event.request
    gprint("@^^^^^onResponse", event.name, index)
    if event.name == "completed" then
        --gprintf("REQUEST %d - getResponseHeadersString() =\n%s", index, request:getResponseHeadersString())

        if request:getResponseStatusCode() ~= 200 then
            self.errorOccur = true
            self:endProcess("response code error " .. request:getResponseStatusCode())
        else
            if dumpResponse then
                --gprintf("REQUEST %d - getResponseString() =\n%s", index, request:getResponseString())
            end
            self.dataRecv = request:getResponseData()
        end
    else
        self.errorOccur = true
        self:endProcess("request error " .. request:getErrorCode())
    end
end

function UpdateScene:getUpdatePath(callCack)
    
    local function getIosTestCallback(event)
        local wrapper = event.obj
        local content = wrapper:getData()
        gprint("content",content)
        local data = json.decode(content)
        local path = data.path
        if callCack then callCack(path) end
    end

    local url
    if GameConfig.downRootURLPATH then
        url = GameConfig.downRootURLPATH
    else
        url = GameConfig.downRootURL .. "updatePath.json"
    end
    local wrapper = NetWrapper.new(getIosTestCallback, nil, true, REQUEST_TYPE_GET, url, false)
    wrapper:sendRequest()
end

function UpdateScene:getDownLoadSize()
    local allSize = 0
    if self.needUpdateList and #self.needUpdateList then
        for index=1,#self.needUpdateList do
            local fileData = self.needUpdateList[index]
            if fileData and fileData.size then
                allSize = allSize + fileData.size
            end
        end
    end
    return allSize
end

function UpdateScene:convertingBit(size)
    print(size,"size")
    local newSize
    local kb = math.floor(size / 1024)
    if kb >= 1000 then
        newSize = string.format("%.1f", kb / 1024) .. "M"
    else
        if kb == 0 then
            kb = 1
        end
        newSize = kb .. "K"
    end
    return newSize
end


return UpdateScene
