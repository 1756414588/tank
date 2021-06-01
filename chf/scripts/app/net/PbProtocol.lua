
--
-- 与游戏服务器的通信协议处理
-- 
require("app.util.protobuf")

PbProtocol = {}

-- function PbProtocol.preLoadAll()
--     PbProtocol.loadPb("Base.pb")
--     for name, value in pairs(PbList) do
--         PbProtocol.loadPb(name .. ".pb")
--     end
--     -- PbProtocol.loadPb("Base.pb")
--     -- PbProtocol.loadPb("Base.pb")
-- end

function PbProtocol.loadPb(pbName, profile)
    local path = CCFileUtils:sharedFileUtils():fullPathForFilename("pb/" .. pbName)
    
    local buffer = CCFileUtils:sharedFileUtils():getFileData(path)
    protobuf.register(buffer)

    if profile then
        local t = protobuf.decode("google.protobuf.FileDescriptorSet", buffer)
        -- dump(t, "file set:")
        local proto = t.file[1]

        print("proto.name:" .. proto.name)
        print("proto.package:" .. proto.package)
        local message = proto.message_type

        for _,v in ipairs(message) do
            print(v.name)
            for _,v in ipairs(v.field) do
                print("\t".. v.name .. " ["..v.number.."] " .. v.label)
            end
        end
    end
end

function PbProtocol.profile(pbName)
    local path = CCFileUtils:sharedFileUtils():fullPathForFilename("app/pb/" .. pbName)
    print("path", path)
    
    local buffer = CCFileUtils:sharedFileUtils():getFileData(path)
    local t = protobuf.decode("google.protobuf.FileDescriptorSet", buffer)
    -- dump(t, "file set:")
    local proto = t.file[1]

    print("proto.name:" .. proto.name)
    print("proto.package:" .. proto.package)
    local message = proto.message_type

    for _,v in ipairs(message) do
        print(v.name)
        for _,v in ipairs(v.field) do
            print("\t".. v.name .. " ["..v.number.."] " .. v.label)
        end
    end
end

function PbProtocol.encode(pbPkg, cmd, data)
    local extend = protobuf.encode(pbPkg, data)
    local s = "Base cmd " .. pbPkg .. ".ext"
    local buffer = protobuf.pack(s, cmd, extend)
    return buffer
end

function PbProtocol.decode(data)
    local s = "Base cmd code param"
    local cmd, code, param = protobuf.unpack(s, data, #data)

    local PbName = ""
    local suffix = ""
    if cmd > 1000 and cmd < 3000 then -- 服务器推送
        -- print("服务器推送了")
        PbName = PbRequest[cmd]
        suffix = "Rq"
        gprint("[PbProtocol] decode request cmd", cmd, "code:", code, "param:", param, "name:", PbName)
        -- gprint("[PbProtocol] decode request protocal name:", PbName)
    else
        PbName = PbResponse[cmd]
        suffix = "Rs"
        gprint("[PbProtocol] decode response cmd", cmd, "code:", code, "param:", param, "name:", PbName)
        -- gprint("[PbProtocol] decode response protocal name:", PbName)
    end

    ----暂时暴力处理 返回
    if code ~= 200 and code ~= 0 then
        return PbName, cmd, code, param
    end

    local s = "Base cmd code param " .. PbName .. suffix .. ".ext"
    local cmd, code, param, info = protobuf.unpack(s, data, #data)

    if info and info[1] and info[2] > 0 then
        local ret = protobuf.decode(PbName .. suffix, info[1], info[2])
        return PbName, cmd, code, param, ret
    else
        return PbName, cmd, code, param
    end
end

-- function PbProtocol.encodeRecord(pbPkg, data)
--     return {pbPkg, protobuf.encode(pbPkg, data)}
-- end

-- function PbProtocol.decode(pbPkg, code)
--     local data = protobuf.decode(pbPkg, code)
--     return data
-- end

-- 解码PB数据，数据table索引1为协议名，索引2为解码数据
function PbProtocol.decodeRecord(pbData)
    local typename = rawget(pbData , 1)
    local buffer = rawget(pbData , 2)

    if typename and buffer then
        return protobuf.decode(pbData[1], pbData[2])
    else
        return nil
    end
end

-- 解码获得的PB数组数据
function PbProtocol.decodeArray(pbAry)
    if not pbAry or #pbAry < 1 then return {} end

    local ret = {}
    for index = 1, #pbAry do
        local r = PbProtocol.decodeRecord(pbAry[index])
        if r then
            ret[#ret + 1] = r
        end
    end
    return ret
end


-- 客户端模拟组装 TwoInt列表 数据
-- example:
-- in   | list = {{key=880,value=5},{key=882,value=6},{key=884,value=1}}
-- out  | {1 = {"v1" = 880, "v2" = 5}, 2 = {"v1" = 882, "v2" = 6}, 3 = {"v1" = 884, "v2" = 1}} (out 用 PbProtocol.decodeArray 解析后结果)
function PbProtocol.analogyTwoIntList(list)
    if not list then return {} end
    local out = {}
    local analogyName = "TwoInt"
    for index = 1, #list do   
        local data = {}
        data["v1"] = list[index].key
        data["v2"] = list[index].value
        local prodata = protobuf.encode(analogyName, data)
        local outdata = {}
        outdata[#outdata + 1] = analogyName
        outdata[#outdata + 1] = prodata
        out[#out + 1] = outdata
    end
    return out
end
