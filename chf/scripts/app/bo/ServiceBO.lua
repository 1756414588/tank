
--
-- 处理对外的接口
-- 

ServiceBO = {}
ServiceBO.userInfo = nil

function ServiceBO.getRunParam(callback)
    gprint("ServiceBO.getRunParam------->", device.platform)
    if device.platform == "android" then
        gprint("callJava", "com/baili/tank/SDKHelper", "getType")
        callJava("com/baili/tank/SDKHelper", "getType", "(I)V", callback)
        gprint("done=====================")
    elseif device.platform == "ios" or device.platform == "mac" then
        callObjectC("CSDKHelper", "getType", nil, callback)
    else
        callback(GameConfig.defaultRunParam)
    end
end

--获取手机的唯一ID
function ServiceBO.getUUID(callback)
    if device.platform == "android" then
        callJava("com/baili/tank/Main", "getUUID", "(I)V", callback)
    elseif device.platform == "ios" or device.platform == "mac" then
        callObjectC("CSDKHelper", "getOpenUDID", nil, callback)
    else
        callback(GameConfig.uuid)
    end
end

function ServiceBO.showNotice(url)
    -- print("ServiceBO.showNotice:" .. url)
    if device.platform == "android" then
        callJava("com/baili/tank/Main", "showNotice", "(Ljava/lang/String;)V", url)
    elseif device.platform == "ios" or device.platform == "mac" then
        callObjectC("CSDKHelper", "showNotice", {url=url})
    else

    end
end

--使用第3方平台sdk登录
function ServiceBO.sdkLogin(callback)
    if device.platform == "android" then
        if GameConfig.environment == "tencent_muzhi" or GameConfig.environment == "tencent_chpub" 
            or GameConfig.environment == "tencent_anfan" or GameConfig.environment == "tencent_anfan_hj3" 
            or GameConfig.environment == "tencent_muzhi_sjdz" or GameConfig.environment == "tencent_anfan_fktk" 
            or GameConfig.environment == "tencent_muzhi_ly" or GameConfig.environment == "tencent_muzhi_hd" 
            or GameConfig.environment == "tencent_anfan_tq" or GameConfig.environment == "tencent_yxfc" 
            or GameConfig.environment == "tencent_chpub_zzzhg" or GameConfig.environment == "tencent_chpub_redtank"
            or GameConfig.environment == "chhjfc_yyb_client"then
            callJava("com/baili/tank/SDKHelper", "autoLogin", "(I)V", callback)
        else
            callJava("com/baili/tank/SDKHelper", "login", "(I)V", callback)
        end

    elseif device.platform == "ios" or device.platform == "mac" then
        local p = {listener=callback}
        if GameConfig.appotaConfig then p.appotaConfig=GameConfig.appotaConfig end
        callObjectC("CSDKHelper", "login", p)
    else
        callback("win32")
    end
end

--腾讯手动登录
function ServiceBO.txSdkLogin(callback,type)
    if device.platform == "android" then
        callJava("com/baili/tank/SDKHelper", "txlogin", "(Ljava/lang/String;I)V", type, callback)
    elseif device.platform == "ios" or device.platform == "mac" then
        local p = {listener=callback}
        if GameConfig.appotaConfig then p.appotaConfig=GameConfig.appotaConfig end
        callObjectC("CSDKHelper", "login", p)
    else
        callback("win32")
    end
end

function ServiceBO.txSdkLogout()
    if device.platform == "android" then
        callJava("com/baili/tank/Main", "letUserLogout", "()V")
    elseif device.platform == "ios" or device.platform == "mac" then
        
    else
        callback("win32")
    end
end

--使用第3方平台sdk切换账号
function ServiceBO.switchAccount(callback)
    if device.platform == "android" then
        if callback then 
            callJava("com/baili/tank/SDKHelper", "switchAccount", "(I)V", callback)
        else
            callJava("com/baili/tank/SDKHelper", "switchAccount", "()V")
        end    
    elseif device.platform == "ios" or device.platform == "mac" then
        local p = {unuse = "unuse"}
        if callback then
            p.listener = callback
        end
        callObjectC("CSDKHelper", "switchAccount", p)
    else

    end
end

function ServiceBO.setUserInfo()
    local data = {}
    data.roleId = UserMO.lordId_
    data.roleName = UserMO.nickName_
    data.roleLevel = UserMO.level_
    data.zoneId = GameConfig.areaId
    data.zoneName = string.gsub(LoginMO.getServerById(GameConfig.areaId).name," ","")
    data.vip = UserMO.vip_
    data.coin = UserMO.coin_
    data.roleCTime = UserMO.createRoleTime_
    data.power = UserMO.fightValue_
    -- gdump(data, "user-----------------")
    if device.platform == "android" then
        callJava("com/baili/tank/SDKHelper", "setUserInfo", "(Ljava/lang/String;)V", json.encode(data))
    elseif device.platform == "ios" or device.platform == "mac" then
        callObjectC("CSDKHelper", "setUserInfo", data)
    else

    end
end

function ServiceBO.userLevelUp()
    local data = {}
    data.roleId = UserMO.lordId_
    data.roleName = UserMO.nickName_
    data.roleLevel = UserMO.level_
    data.zoneId = GameConfig.areaId
    data.zoneName = string.gsub(LoginMO.getServerById(GameConfig.areaId).name," ","")
    data.vip = UserMO.vip_
    data.coin = UserMO.coin_
    data.roleCTime = UserMO.createRoleTime_
    data.power = UserMO.fightValue_
    -- gdump(data, "user-----------------")
    if device.platform == "android" then
        callJava("com/baili/tank/SDKHelper", "userLevelUp", "(Ljava/lang/String;)V", json.encode(data))
    elseif device.platform == "ios" or device.platform == "mac" then
        callObjectC("CSDKHelper", "userLevelUp", data)
    else

    end
end

function ServiceBO.creatRole()
    local data = {}
    data.roleId = UserMO.lordId_
    data.roleName = UserMO.nickName_
    data.roleLevel = UserMO.level_
    data.zoneId = GameConfig.areaId
    data.zoneName = string.gsub(LoginMO.getServerById(GameConfig.areaId).name," ","")
    data.vip = UserMO.vip_
    data.coin = UserMO.coin_
    data.power = UserMO.fightValue_
    -- gdump(data, "user-----------------")
    if device.platform == "android" then
        callJava("com/baili/tank/SDKHelper", "creatRole", "(Ljava/lang/String;)V", json.encode(data))
    elseif device.platform == "ios" or device.platform == "mac" then
        --callObjectC("CSDKHelper", "setUserInfo", {user=jdson.encode(data)})
    else

    end
end

--草花专用 用户绑定
function ServiceBO.userInfoBind(tokenResult)
    if device.platform == "android" then
        callJava("com/baili/tank/SDKHelper", "userInfoBind", "(Ljava/lang/String;)V", tokenResult)
    elseif device.platform == "ios" or device.platform == "mac" then
        --callObjectC("CSDKHelper", "userInfoBind", {user=jdson.encode(data)})
    else

    end
end

function ServiceBO.useGiftCode(code)
    if device.platform == "android" then
        callJava("com/baili/tank/SDKHelper", "useGiftCode", "(Ljava/lang/String;)V", code)
    elseif device.platform == "ios" or device.platform == "mac" then
    else

    end

end



function ServiceBO.pay(callback, rechargeId, notifyUrl, amount, coin, currencyType, paymentType, productName, goodsCount, productId, extraCoin)
    require("app.mo.UserMO")

    gdump(productId,"productId==")

    local p = {}
    p.uid = UserMO.lordId_
    p.ulevel = UserMO.level_
    p.nickName = UserMO.nickName_
    p.serverid = GameConfig.areaId
    p.serverName = string.gsub(LoginMO.getServerById(GameConfig.areaId).name," ","")
    p.rechargeId = rechargeId
    p.notifyUrl = notifyUrl
    p.amount = amount
    p.coin = coin
    p.iapId = amount .. RechargeBO.getCurrencyType() .. coin .. CommonText.item[1][1]
    p.currencyType = currencyType
    p.paymentType = paymentType
    p.productName = productName
    p.goodsCount = goodsCount
    p.productId = productId
    p.oddCoin = UserMO.coin_
    p.extraCoin = extraCoin
    p.userInfo = ServiceBO.userInfo

    gdump(p,"recharge param=====")

    if device.platform == "android" then
        callJava("com/baili/tank/SDKHelper", "pay", "(Ljava/lang/String;I)V", json.encode(p), callback)
    elseif device.platform == "ios" or device.platform == "mac" then
        p.listener = callback
        callObjectC("CSDKHelper", "pay", p)
    else
        -- dump(p, "recharge------------->")
        callback()
    end
end


function ServiceBO.chIosPay(callback, rechargeId, notifyUrl, amount, coin, currencyType, paymentType, productName, goodsCount, productId, extraCoin, chPaytype,thirdPayType)
    require("app.mo.UserMO")

    gdump(productId,"productId==")

    local p = {}
    p.uid = UserMO.lordId_
    p.ulevel = UserMO.level_
    p.nickName = UserMO.nickName_
    p.serverid = GameConfig.areaId
    p.rechargeId = rechargeId
    p.notifyUrl = notifyUrl
    p.amount = amount
    p.coin = coin
    p.iapId = amount .. RechargeBO.getCurrencyType() .. coin .. CommonText.item[1][1]
    p.currencyType = currencyType
    p.paymentType = paymentType
    p.productName = productName
    p.goodsCount = goodsCount
    p.productId = productId
    p.oddCoin = UserMO.coin_
    p.extraCoin = extraCoin
    p.listener = callback
    p.paytype = chPaytype
    p.thirdPayType = thirdPayType
    gdump(p,"recharge param=====")
    callObjectC("CSDKHelper", "pay", p)
end

function ServiceBO.getPackageInfo(callback)
    if device.platform == "android" then
        callJava("com/baili/tank/Main", "getPackageInfo", "(I)V", callback)
    elseif device.platform == "ios" or device.platform == "mac" then
    else
        callback("com.baili.tank.self")
    end
end


--获取更新整包APK的下载大小
function ServiceBO.getProgress(callback)
    if device.platform == "android" then
        callJava("com/baili/tank/Main", "getProgress", "(I)V", callback)
    elseif device.platform == "ios" or device.platform == "mac" then
        callObjectC("CSDKHelper", "getProgress", nil, callback)
    end
end

function ServiceBO.updateApk(url)
    if device.platform == "android" then
        callJava("com/baili/tank/Main", "updateApk", "(Ljava/lang/String;)V", url)
    elseif device.platform == "ios" or device.platform == "mac" then
        callObjectC("CSDKHelper", "updateApk", {url=url})
    else

    end
end

function ServiceBO.getIPAddress(callback)
    local localVersion = LoginBO.getLocalApkVersion()
    if (device.platform == "ios" or device.platform == "mac") and localVersion >= 200 then
        callObjectC("CSDKHelper", "getIPAddress", nil, callback)
    else
        callback()
    end
end

function ServiceBO.gotoURL(url)
    if device.platform == "ios" or device.platform == "mac" then
        callObjectC("CSDKHelper", "gotoURL", {url=url})
    elseif device.platform == "android" then
        local localVersion = LoginBO.getLocalApkVersion()
        if localVersion >= 346 then
            callJava("com/baili/tank/Main", "gotoURL", "(Ljava/lang/String;)V", url)
        end
    end
end



function ServiceBO.gotoAppStorePageRaisal(msg)
    if device.platform == "ios" or device.platform == "mac" then
        callObjectC("CSDKHelper", "gotoAppStorePageRaisal", {msg=msg})
    else
        
    end
end


--获取手机的IDFA
function ServiceBO.getIdfa(callback)
    local localVersion = LoginBO.getLocalApkVersion()
    if localVersion < 269 then return end
    if device.platform == "android" then
        -- callJava("com/baili/tank/Main", "getUUID", "(I)V", callback)
    elseif device.platform == "ios" or device.platform == "mac" then
        callObjectC("CSDKHelper", "getIdfa", nil, callback)
    end
end

--播放拇指广告
function ServiceBO.playMzAD(type,callback)
    local localVersion = LoginBO.getLocalApkVersion()
    
    
    if device.platform == "android" then
        -- callJava("com/baili/tank/Main", "playMzAD", "(I)V", callback)
    elseif device.platform == "ios" or device.platform == "mac" then
        if localVersion < 365 then return end
        local p = {}
        p.type = type
        p.listener = callback
        callObjectC("CSDKHelper", "playMzAD", p)
    else
        callback()
    end
end

--拇指广告 触发平台
function ServiceBO.muzhiAdPlat()
    if device.platform == "ios" or device.platform == "mac" then
        --暂时屏蔽拇指广告
        do return false end

        local localVersion = LoginBO.getLocalApkVersion()
        if localVersion < 381 then return false end
        
        if GameConfig.environment == "mztkjjylfc_appstore" or GameConfig.environment == "mztkjjylfcba_appstore" 
            then
            return true
        end
    elseif device.platform == "android" then

    end
    return false
end


