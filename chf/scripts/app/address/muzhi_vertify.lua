--
-- Author: Your Name
-- Date: 2017-06-12 17:52:31
--
LOGIN_PLATFORM_PARAM = "mzvertify"

--拇指玩客户端
-- GameConfig.accountURL = "http://muzhi.tank.hundredcent.com:9200/tank_account/account/account.do"
-- GameConfig.areaURL = "http://muzhi.tank.hundredcent.com/serverlist_tank.json"
GameConfig.downRootURL = "http://cdn.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://cdn.tank.hundredcent.com/version/tank_apk_hf.json"
--预发布
GameConfig.accountURL = "http://119.29.180.212:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://119.29.180.212/serverlist_tank.json"

function getPayCallBackUrl()
    return "http://119.29.180.212:9200/tank_account/account/payCallback.do?plat=mzvertify"
end