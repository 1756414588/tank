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

local function getFileSize(path)
    local file = io.open(path, "rb")
    if file then
        local size = file:seek("end")
        io.close(file)
        return size
    end
    print("error path size", path)
    return nil
end

local function checkDirOK( path )
    require "lfs"
    local oldpath = lfs.currentdir()
    CCLuaLog("old path------> "..oldpath)

     if lfs.chdir(path) then
        lfs.chdir(oldpath)
        CCLuaLog("path check OK------> "..path)
        return true
     end

     if lfs.mkdir(path) then
        CCLuaLog("path create OK------> "..path)
        return true
     end
end

local function checkCacheDirOK(root_dir, path)
    path = string.gsub(string.trim(path), "\\", "/")
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

require "lfs"

function findindir (path, wefind, r_table, intofolder)
    for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." then
            local f = path..'\\'..file
            --print ("/t "..f)
            local attr = lfs.attributes (f)
            --assert (type(attr) == "table")
            if attr.mode == "directory" and intofolder then
                findindir (f, wefind, r_table, intofolder)
            else
                if string.find(f, wefind) ~= nil then
                    --print("/t "..f)
                    table.insert(r_table, f)
                end
            end
        end
    end
end

MakeFileList = {}

--脚本目录
local scriptDir = export_dir .. "scripts"
--资源目录
local resDir = export_dir .. "res"
--输出目录
--local outputDir = "ver" .. ver .. "_" .. os.date("%Y%m%d%H%M%S") .. "/"

function MakeFileList:run()

    -- if not checkCacheDirOK(proj_publish, outputDir) then
    --     print("输出目录不存在", outputDir)
    --     return
    -- end

    print("======= 过程时间较长，请耐心等候进度完成的提示 ===========")
    
    print("1.------- 统计文件 ----------")
    local input_table = {}
    findindir(scriptDir, ".", input_table, true)
    findindir(resDir, ".", input_table, true)

    --压缩json
    composeJson(input_table)

    print("2.------- 生成文件Md5码 ----------")
    --所有文件列表
    local allFiles = {}
    local pthlen = string.len(export_dir)+1
    for i, v in ipairs(input_table) do
        local data = readFile(v)
        local ms = crypto.md5(hex(data or "")) or ""
        local size = getFileSize(v)
        --table.insert(allFiles, {file=string.gsub(v, proj_dir, ''), code = ms})
        local nfn = string.trim(string.sub(v, pthlen))
        nfn = string.gsub(nfn, "\\", "/")
        table.insert(allFiles, {name=nfn, code = ms, size = size})
    end

    --导出版本号
    io.writefile(export_dir .. "ver.manifest", ver)

    --将版本号文件加到更新列表
    local d = readFile(export_dir .. "ver.manifest")
    local c = crypto.md5(hex(d or "")) or ""
    local s = getFileSize(export_dir .. "ver.manifest")
    table.insert(allFiles, {name="ver.manifest", code = c, size = s})


     --将cache.manifest文件加到更新列表
    -- local d = readFile(export_dir .. "cache.manifest1")
    -- local c = crypto.md5(hex(d or "")) or ""
    -- table.insert(allFiles, {name="cache.manifest1", code = c})
    
    -----------------------------------------------------------------------------------
    --导出所有源文件列表
    output(allFiles, "cache.manifest.src")
    
    --复制文件(返回复制的文件)
    --local files = campare("E:\\cocos2d_work\\ljws-lua\\ljws\\cache.manifest", allFiles)

    print("3.------- 编译脚本文件 ----------")
    --编译更新文件
    compileFile()


    print("4.------- 生成配置文件 ----------")

    local compFiles = getFilesCode(allFiles)

    --重命名编译文件夹
    os.rename(export_dir .. "scripts", export_dir .. "scripts_compile")

    --导出编译的文件列表
    output(compFiles, "cache.manifest.compile")
    
    print("======= 全部工作完成，您可以关闭程序了 ===========")
end

function copyFiles()
    --xcopy e:\*.* d: /s /h /d /y
    local cmd = "xcopy " .. scriptDir .. "/*.* " .. export_dir .. " /s /e"
    os.execute(cmd)
    cmd = "xcopy " .. resDir .. " " .. export_dir .. " /s /h /d /y"
    os.execute(cmd)
end

function composeJson(files)
    for i = 1, #files do
        if string.sub(files[i], -5, -1) == ".json" then
            local content = readFile(files[i])
            if content then
                local str = json.encode(json.decode(content))
                io.writefile(files[i], str)
            end
        end
    end
    print("compile json completed!")
end

function output(allFiles, filename)
    --local manifest = {}
    --manifest.ver = ver
    --manifest.filelist = allFiles
    -- dump(allFiles,"allFiles")

    local manifest = "local m={\n"
    --版本号
    manifest = manifest .. "\tver=\"" .. ver .. "\",\n"
    --文件列表
    manifest = manifest .. "\tstage={"
    for i = 1, #allFiles do
        manifest = manifest .. "\n\t\t{name=\"" .. allFiles[i].name .. "\","
        manifest = manifest .. "code=\"" .. allFiles[i].code .. "\","
        manifest = manifest .. "size=" .. allFiles[i].size .. "}"


        if i < #allFiles then
            manifest = manifest .. ","
        end
    end
    manifest = manifest .. "\n\t}\n}"
    manifest = manifest .. "\nreturn m"
    io.writefile(export_dir .. filename, manifest)
end

function campare(old_file, allFiles)
    local files = {}
    local oldFiles = dofile(old_file).stage
    for i = 1, #allFiles do
        if not campareFile(oldFiles, allFiles[i]) then
            table.insert(files, allFiles[i])
        end
    end
    dump(files, "files------------>")
    for i = 1, #files do
        copyFile(files[i])
    end
    return files
end

function campareFile(stage, file)
    local b = false;
    for i = 1, #stage do
        if stage[i].name == file.name then
            if stage[i].code == file.code then
                b = true
            end
            break
        end
    end
    return b
end

function copyFile(file)
    local filename = file.name
    local f = io.open(proj_dir .. filename, "rb") 
    local content = f:read "*a"
    f:close()
    checkCacheDirOK(export_dir, filename)
    f = io.open(export_dir .. filename, "wb")
    f:write(content) 
    f:close()
end

function compileFile()
    -- luajit_compile
    
    --重命名源文件
    os.rename(export_dir .. "scripts", export_dir .. "scripts_src")
    
    local cmd = luajit_compile .. " -m files"
    cmd = cmd .. " -i " .. export_dir .. "scripts_src"
    cmd = cmd .. " -o " .. export_dir .. "scripts"
    print(cmd)
    os.execute(cmd)
    
    --os.remove(string.gsub(curDir .. "scripts_src", '/', '\\'))
end

function getFilesCode(files)
    for i = 1, #files do
        local data = readFile(export_dir .. files[i].name)
        local ms = crypto.md5(hex(data or "")) or ""
        local size = getFileSize(export_dir .. files[i].name)
        files[i].code = ms
        files[i].size = size
    end
    return files
end

return MakeFileList