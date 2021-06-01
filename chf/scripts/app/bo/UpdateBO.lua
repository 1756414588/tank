
-- UpdateBO = {}

-- --读取本地的列表文件
-- function UpdateBO.getFileList()
--     --本地cache.manifest
--     local filePath =  CACHE_DIR .. GameConfig.fileManifest

--     local fileList = nil

--     --从缓存目录读文件列表
--     if io.exists(filePath) then
--         fileList = dofile(filePath)
--     else
--         --从初始目录读文件列表
--         local cpath = CCFileUtils:sharedFileUtils():fullPathForFilename(GameConfig.fileManifest)

--         if cpath ~= GameConfig.fileManifest then
--             local fileData = CCFileUtils:sharedFileUtils():getFileData(cpath)
--             if fileData then self.fileList = assert(loadstring(fileData))() end
--         end
--     end

--     --两个目录下都未找到
--     if fileList == nil then
--         -- gprint("@^^^^两个目录下都未找到")
--         fileList = {ver = GameConfig.version, stage = {}}
--     end

--     return fileList
-- end

-- -- 生成更新列表{{name="scripts/app/address/debug.lua",code="aadebdda85b00096b0801a34a908d4d6"}}
-- function UpdateBO.compManifest(oldFile, newFile)
--     local oldList = {}

--     for i = 1, #oldFile do
--         oldList[oldFile[i].name] = oldFile[i].code
--     end

--     -- gprint("@^^^^map complete:" .. table.nums(oldList))

--     local list = {}
--     for i = 1, #newFile do
--         local name = newFile[i].name
--         if newFile[i].code ~= oldList[name] then
--             table.insert(list, newFile[i])
--         end
--     end
--     gprint("[UpdateBO] need update file count:" .. #list)
--     return list
-- end

-- function UpdateBO.checkFile(fileName, cryptoCode)
--     local function hex(s)
--         s=string.gsub(s,"(.)",function (x) return string.format("%02X",string.byte(x)) end)
--         return s
--     end

--     if not io.exists(fileName) then
--         return false
--     end

--     local data = readFile(fileName)
--     if data == nil then
--         gprint("文件不存在:", filename)
--         return false
--     end

--     if cryptoCode == nil then
--         return true
--     end

--     local ms = crypto.md5(hex(data))
--     if ms == cryptoCode then
--         return true
--     end

--     -- gprint("md5差异:", fileName, cryptoCode, ms)
--     return false
-- end

-- function UpdateBO.asynRequestVersion(doneCallback)
-- 	local function parseVersion(event)
-- 		local wrapper = event.obj
-- 		gprint("[UpdateBO] asynRequestVersion version:", wrapper:getData())
-- 		if doneCallback then doneCallback(wrapper:getData()) end
-- 	end

-- 	local url = GameConfig.downRootURL .. GameConfig.versionManifest .. "?dev="..device.platform
--     local wrapper = NetWrapper.new(parseVersion, nil, true, REQUEST_TYPE_GET, url, false, false)
--     wrapper:sendRequest()
-- end

-- function UpdateBO.asynRequestFileList(doneCallback)
-- 	local function parseFileList(event)
-- 		local wrapper = event.obj

-- 		local cpyFileList = CACHE_DIR .. GameConfig.fileManifest .. ".upd"
-- 		-- gprint("[UpdateBO] asynRequestFileList fileList:", wrapper:getData())
-- 		io.writefile(cpyFileList, wrapper:getData())

--         local status = -1
--         local localFileData = nil

-- 		local newFileData = dofile(cpyFileList)
-- 		if not newFileData then  -- 出错
-- 			gprint("出问题了...")
--             status = 0
--         else
--             -- 获得本地的fileList
--             localFileData = UpdateBO.getFileList()

--             if (newFileData.ver == localFileData.ver) and (newFileData.ver == GameConfig.version) then  -- 不需要更新
--                 removeFile(cpyFileList)
--                 status = 1
--             else
--                 status = 2
--             end
-- 		end

-- 		if doneCallback then doneCallback(status, localFileData, newFileData) end
-- 	end

-- 	local url = GameConfig.downRootURL .. GameConfig.fileManifest .. "?dev="..device.platform
--     local wrapper = NetWrapper.new(parseFileList, nil, true, REQUEST_TYPE_GET, url, false, false)
--     wrapper:sendRequest()
-- end
