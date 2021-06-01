--
-- Author: gf
-- Date: 2016-03-18 14:25:05
--

LOGIN_PLATFORM_PARAM = nil
LOGIN_PLATFORM_PARAM_QQ = "mzSq3"
LOGIN_PLATFORM_PARAM_WX = "mzWx3"

--拇指玩客户端
GameConfig.accountURL = "http://txmzhd.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://txmzhd.tank.hundredcent.com/serverlist_tank.json"
GameConfig.downRootURL = "http://cdn.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://cdn.tank.hundredcent.com/version/tank_apk_hf.json"


function getPayCallBackUrl()
    return "http://txmzhd.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=" .. LOGIN_PLATFORM_PARAM
end