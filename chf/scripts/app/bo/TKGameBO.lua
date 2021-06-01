--
-- Author: gf
-- Date: 2015-10-17 16:38:17
--


TKGameBO = {}

TKGameBO.callQueue = {}

function tkCall(method, p)
    gdump(p,"TKGAME:" .. method)
	if device.platform == "android" then
        luaj.callStaticMethod("com/baili/tank/TKGame", method, {json.encode(p)}, "(Ljava/lang/String;)V")
    elseif device.platform == "ios" or device.platform == "mac" then
        luaoc.callStaticMethod("TKGame", method, p)
    else
        -- callback()
    end
end

function TKGameBO.update()
    if #TKGameBO.callQueue > 0 then
        local item = TKGameBO.callQueue[1]
        table.remove(TKGameBO.callQueue, 1)
        if item then
            tkCall(item[1], item[2])
        end
    end
end

--事件
function TKGameBO.onEvnt(evt, data)
    local p = {}
    p.event = evt
    p.map = data
    -- tkCall("onEvent", p)
    table.insert(TKGameBO.callQueue, {"onEvent", p})
end

--设定账号
function TKGameBO.setAccount(account, area)
    local p = {}
    if area == 1 or area == 2 then
        p.account = tostring(account)
    else
        p.account = tostring(account) .. "_" .. tostring(area)
    end
    p.area = tostring(area)
    tkCall("setAccount", p)
end

--设定账号名
function TKGameBO.setAccountName(accountName)
    local p = {}
    p.accountName = accountName
    tkCall("setAccountName", p)
end

--设定帐号类型
function TKGameBO.setAccountType(accountType)
    local p = {}
    p.accountType = accountType
    tkCall("setAccountType", p)
end

--设定等级
function TKGameBO.setLevel(level)
    local p = {}
    p.level = level
    tkCall("setLevel", p)
end

--获得金币
function TKGameBO.onReward(amount, origin)
    local p = {}
    p.amount = amount
    p.origin = origin
    tkCall("onReward", p)
end

--金币消耗
function TKGameBO.onPurchase(item, count, price)
    local p = {}
    p.item = item
    p.count = count
    p.price = price
    tkCall("onPurchase", p)
end

--物品消耗
function TKGameBO.onUse(item, count)
    local p = {}
    p.item = item
    p.count = count
    tkCall("onUse", p)
end

--进入关卡
function TKGameBO.onBegin(name)
    local p = {}
    p.stage = name
    tkCall("onBegin", p)
end

--完成关卡
function TKGameBO.onCompleted(name)
    local p = {}
    p.stage = name
    tkCall("onCompleted", p)
end

--关卡失败
function TKGameBO.onFailed(name,failInfo)
    local p = {}
    p.stage = name
    p.failInfo = failInfo
    tkCall("onFailed", p)
end

-- --支付成功
-- function TKGameBO.onChargeSuccess(orderId)
--     local p = {}
--     p.orderId = orderId
--     tkCall("onChargeSuccess", p)
-- end




TKGAME_USERES_TYPE_UPDATE = 1  --更新
TKGAME_USERES_TYPE_CONSUME = 2 --减少或者增加
--金币消耗统计
function TKGameBO.onUseCoinTk(coin,item,type,c)
    if not coin or coin <= 0 then return end
    local coinUse
    local count = 1
    if type == TKGAME_USERES_TYPE_UPDATE then
        coinUse = UserMO.coin_ - coin 
    else
        coinUse = coin
    end
    if c then count = c end
    -- dump(coinUse,"coinUse")
    if coinUse > 0 then
        TKGameBO.onPurchase(item, count, coinUse / count)
    end
end

--资源消耗统计
function TKGameBO.onUseResTk(id,count,kind,type)
    if not count or count <=0 then return end
    local resUse
    if type == TKGAME_USERES_TYPE_UPDATE then
        resUse = UserMO.getResource(ITEM_KIND_RESOURCE, id) - count
    else
        resUse = count
    end
    if resUse > 0 then
        TKGameBO.onEvnt(TKText.eventName[4], {type = id, count = UiUtil.strNumSimplify(resUse), kind = kind})
    end
end

--资源获得统计
function TKGameBO.onGetResTk(id,count,kind,type)
    if not count or count <=0 then return end
    local resUse
    if type == TKGAME_USERES_TYPE_UPDATE then
        resUse = count - UserMO.getResource(ITEM_KIND_RESOURCE, id)
    else
        resUse = count
    end
    if resUse > 0 then
        TKGameBO.onEvnt(TKText.eventName[3], {type = id, count = UiUtil.strNumSimplify(resUse), kind = kind})
    end
end


function TKGameBO.arrangeAwards(awards)
    local ret = {}

    local function add(award)
        if award.id and award.id == 0 then award.id = nil end

        for index = 1, #ret do
            local r = ret[index]
            if r.kind == award.kind then
                if r.id and award.id then
                    if r.id == award.id then  -- 找到了
                        r.count = r.count + award.count
                        return
                    end
                elseif not r.id and not award.id then  -- 找到了
                    r.count = award.count
                    return
                end
            end
        end
        ret[#ret + 1] = award
    end

    for index = 1, #awards do
        local award = awards[index]
        if not table.isexist(award, "kind") then award.kind = award.type end

        add(award)
    end
    return ret
end





--注册成功
function TKGameBO.onRegister(keyId)
    if GameConfig.environment == "ch_appstore" or GameConfig.environment == "af_appstore" or GameConfig.environment == "mz_appstore" 
        or GameConfig.environment == "chlhtk_appstore" or GameConfig.environment == "mztkwz_appstore" or GameConfig.environment == "mztkdg_appstore" 
        or GameConfig.environment == "mzeztk_appstore" or GameConfig.environment == "mztkwc_appstore" or GameConfig.environment == "mztkjj_appstore"
        or GameConfig.environment == "afTkxjy_appstore" or GameConfig.environment == "mztktj_appstore" or GameConfig.environment == "mztkjjylfc_appstore" 
        or GameConfig.environment == "chdgzhg_appstore" or GameConfig.environment == "mztkjjhwcn_appstore" or GameConfig.environment == "chgtfc_appstore"
        or GameConfig.environment == "chzdjj_appstore" or GameConfig.environment == "chzjqy_appstore" or GameConfig.environment == "mzAqHszz_appstore" 
        or GameConfig.environment == "mzAqTkjt_appstore" or GameConfig.environment == "mztkjjylfcba_appstore" or GameConfig.environment == "mzAqGtdg_appstore"
        or GameConfig.environment == "mzAqHxzz_appstore" or GameConfig.environment == "mzAqZbshj_appstore" or GameConfig.environment == "mzAqZzfy_appstore" 
        or GameConfig.environment == "mzTkjjQysk_appstore" or GameConfig.environment == "chzzzhg_appstore" or GameConfig.environment == "afGhgxs_appstore" 
        or GameConfig.environment == "afMjdzh_appstore" or GameConfig.environment == "afWpzj_appstore" or GameConfig.environment == "afXzlm_appstore" 
        or GameConfig.environment == "afTqdkn_appstore" or GameConfig.environment == "chzzzhg1_appstore" or GameConfig.environment == "chzzzhg2_appstore" 
        or GameConfig.environment == "afGhgzh_appstore" or GameConfig.environment == "mzGhgzh_appstore" or GameConfig.environment == "mzYiwanCyzc_appstore" 
        or GameConfig.environment == "afTqdknHD_appstore" or GameConfig.environment == "afNew_appstore" or GameConfig.environment == "chCjzjtkzz_appstore" 
        or GameConfig.environment == "chZjqytkdz_appstore" or GameConfig.environment == "mzLzwz_appstore" or GameConfig.environment == "afNewMjdzh_appstore" 
        or GameConfig.environment == "afNewWpzj_appstore" or GameConfig.environment == "afLzyp_appstore" or GameConfig.environment == "chhjfc_appstore" then
        local p = {}
        p.keyId = tostring(keyId)
        tkCall("onRegister", p)
    elseif GameConfig.environment == "anfan_client" or GameConfig.environment == "anfanKoudai_client" or GameConfig.environment == "anfan_client_small" 
        or GameConfig.environment == "anfanJh_client" or GameConfig.environment == "anfanaz_client" then
        callJava("com/baili/tank/TKAdGame", "onRegister", "(Ljava/lang/String;)V", tostring(keyId))
    end
   
end

--登录成功
function TKGameBO.onLogin(keyId)
    if GameConfig.environment == "ch_appstore" or GameConfig.environment == "af_appstore" or GameConfig.environment == "mz_appstore" 
        or GameConfig.environment == "chlhtk_appstore" or GameConfig.environment == "mztkwz_appstore" or GameConfig.environment == "mztkdg_appstore" 
        or GameConfig.environment == "mzeztk_appstore" or GameConfig.environment == "mztkwc_appstore" or GameConfig.environment == "mztkjj_appstore" 
        or GameConfig.environment == "afTkxjy_appstore" or GameConfig.environment == "mztktj_appstore" or GameConfig.environment == "mztkjjylfc_appstore" 
        or GameConfig.environment == "chdgzhg_appstore" or GameConfig.environment == "mztkjjhwcn_appstore" or GameConfig.environment == "chgtfc_appstore"
        or GameConfig.environment == "chzdjj_appstore" or GameConfig.environment == "chzjqy_appstore" or GameConfig.environment == "mzAqHszz_appstore" 
        or GameConfig.environment == "mzAqTkjt_appstore" or GameConfig.environment == "mztkjjylfcba_appstore" or GameConfig.environment == "mzAqGtdg_appstore"
        or GameConfig.environment == "mzAqHxzz_appstore" or GameConfig.environment == "mzAqZbshj_appstore" or GameConfig.environment == "mzAqZzfy_appstore" 
        or GameConfig.environment == "mzTkjjQysk_appstore" or GameConfig.environment == "chzzzhg_appstore" or GameConfig.environment == "afGhgxs_appstore" 
        or GameConfig.environment == "afMjdzh_appstore" or GameConfig.environment == "afWpzj_appstore" or GameConfig.environment == "afXzlm_appstore" 
        or GameConfig.environment == "afTqdkn_appstore" or GameConfig.environment == "chzzzhg1_appstore" or GameConfig.environment == "chzzzhg2_appstore" 
        or GameConfig.environment == "afGhgzh_appstore" or GameConfig.environment == "mzGhgzh_appstore" or GameConfig.environment == "mzYiwanCyzc_appstore" 
        or GameConfig.environment == "afTqdknHD_appstore" or GameConfig.environment == "afNew_appstore" or GameConfig.environment == "chCjzjtkzz_appstore" 
        or GameConfig.environment == "chZjqytkdz_appstore" or GameConfig.environment == "mzLzwz_appstore" or GameConfig.environment == "afNewMjdzh_appstore" 
        or GameConfig.environment == "afNewWpzj_appstore" or GameConfig.environment == "afLzyp_appstore" or GameConfig.environment == "chhjfc_appstore" then
        local p = {}
        p.keyId = tostring(keyId)
        tkCall("onLogin", p)
    elseif GameConfig.environment == "anfan_client" or GameConfig.environment == "anfanKoudai_client" or GameConfig.environment == "anfan_client_small" 
        or GameConfig.environment == "anfanJh_client" or GameConfig.environment == "anfanaz_client" then
        callJava("com/baili/tank/TKAdGame", "onLogin", "(Ljava/lang/String;)V", tostring(keyId))
    end
    
end

--创建角色成功
function TKGameBO.onCreateRole(name)
    if GameConfig.environment == "ch_appstore" or GameConfig.environment == "af_appstore" or GameConfig.environment == "mz_appstore" 
        or GameConfig.environment == "chlhtk_appstore" or GameConfig.environment == "mztkwz_appstore" or GameConfig.environment == "mztkdg_appstore" 
        or GameConfig.environment == "mzeztk_appstore" or GameConfig.environment == "mztkwc_appstore" or GameConfig.environment == "mztkjj_appstore" 
        or GameConfig.environment == "afTkxjy_appstore" or GameConfig.environment == "mztktj_appstore" or GameConfig.environment == "mztkjjylfc_appstore" 
        or GameConfig.environment == "chdgzhg_appstore" or GameConfig.environment == "mztkjjhwcn_appstore" or GameConfig.environment == "chgtfc_appstore"
        or GameConfig.environment == "chzdjj_appstore" or GameConfig.environment == "chzjqy_appstore" or GameConfig.environment == "mzAqHszz_appstore" 
        or GameConfig.environment == "mzAqTkjt_appstore" or GameConfig.environment == "mztkjjylfcba_appstore" or GameConfig.environment == "mzAqGtdg_appstore"
        or GameConfig.environment == "mzAqHxzz_appstore" or GameConfig.environment == "mzAqZbshj_appstore" or GameConfig.environment == "mzAqZzfy_appstore" 
        or GameConfig.environment == "mzTkjjQysk_appstore" or GameConfig.environment == "chzzzhg_appstore" or GameConfig.environment == "afGhgxs_appstore" 
        or GameConfig.environment == "afMjdzh_appstore" or GameConfig.environment == "afWpzj_appstore" or GameConfig.environment == "afXzlm_appstore" 
        or GameConfig.environment == "afTqdkn_appstore" or GameConfig.environment == "chzzzhg1_appstore" or GameConfig.environment == "chzzzhg2_appstore" 
        or GameConfig.environment == "afGhgzh_appstore" or GameConfig.environment == "mzGhgzh_appstore" or GameConfig.environment == "mzYiwanCyzc_appstore" 
        or GameConfig.environment == "afTqdknHD_appstore" or GameConfig.environment == "afNew_appstore" or GameConfig.environment == "chCjzjtkzz_appstore" 
        or GameConfig.environment == "chZjqytkdz_appstore" or GameConfig.environment == "mzLzwz_appstore" or GameConfig.environment == "afNewMjdzh_appstore" 
        or GameConfig.environment == "afNewWpzj_appstore" or GameConfig.environment == "afLzyp_appstore" or GameConfig.environment == "chhjfc_appstore" then
        local p = {}
        p.name = name
        tkCall("onCreateRole", p)
    elseif GameConfig.environment == "anfan_client" or GameConfig.environment == "anfanKoudai_client" or GameConfig.environment == "anfan_client_small" 
        or GameConfig.environment == "anfanJh_client" or GameConfig.environment == "anfanaz_client" then
        callJava("com/baili/tank/TKAdGame", "onCreatRole", "(Ljava/lang/String;)V", tostring(GameConfig.keyId))
    end
    
end

--支付成功
function TKGameBO.onPay(account,orderId,amount,currencyType,payType,addGold)
    if GameConfig.environment == "af_appstore" or GameConfig.environment == "mz_appstore" or GameConfig.environment == "ch_appstore"
        or GameConfig.environment == "chlhtk_appstore" or GameConfig.environment == "mztkwz_appstore" or GameConfig.environment == "mztkdg_appstore" 
        or GameConfig.environment == "mzeztk_appstore" or GameConfig.environment == "mztkwc_appstore" or GameConfig.environment == "mztkjj_appstore" 
        or GameConfig.environment == "afTkxjy_appstore" or GameConfig.environment == "mztktj_appstore" or GameConfig.environment == "mztkjjylfc_appstore"
        or GameConfig.environment == "chdgzhg_appstore" or GameConfig.environment == "mztkjjhwcn_appstore" or GameConfig.environment == "chgtfc_appstore"
        or GameConfig.environment == "chzdjj_appstore" or GameConfig.environment == "chzjqy_appstore" or GameConfig.environment == "mzAqHszz_appstore" 
        or GameConfig.environment == "mzAqTkjt_appstore" or GameConfig.environment == "mztkjjylfcba_appstore" or GameConfig.environment == "mzAqGtdg_appstore"
        or GameConfig.environment == "mzAqHxzz_appstore" or GameConfig.environment == "mzAqZbshj_appstore" or GameConfig.environment == "mzAqZzfy_appstore" 
        or GameConfig.environment == "mzTkjjQysk_appstore" or GameConfig.environment == "chzzzhg_appstore" or GameConfig.environment == "afGhgxs_appstore" 
        or GameConfig.environment == "afMjdzh_appstore" or GameConfig.environment == "afWpzj_appstore" or GameConfig.environment == "afXzlm_appstore" 
        or GameConfig.environment == "afTqdkn_appstore" or GameConfig.environment == "chzzzhg1_appstore" or GameConfig.environment == "chzzzhg2_appstore" 
        or GameConfig.environment == "afGhgzh_appstore" or GameConfig.environment == "mzGhgzh_appstore" or GameConfig.environment == "mzYiwanCyzc_appstore"
        or GameConfig.environment == "afTqdknHD_appstore" or GameConfig.environment == "afNew_appstore" or GameConfig.environment == "chCjzjtkzz_appstore" 
        or GameConfig.environment == "chZjqytkdz_appstore" or GameConfig.environment == "mzLzwz_appstore" or GameConfig.environment == "afNewMjdzh_appstore" 
        or GameConfig.environment == "afNewWpzj_appstore" or GameConfig.environment == "afLzyp_appstore" or GameConfig.environment == "chhjfc_appstore" then
        local p = {}
        p.account = tostring(account)
        p.orderId = orderId
        p.amount = amount
        p.currencyType = currencyType
        p.payType = payType
        p.level = UserMO.level_
        p.addGold = addGold
        tkCall("onPay", p)
    end
    local p = {}
    p.orderId = orderId
    tkCall("onChargeSuccess", p)
end