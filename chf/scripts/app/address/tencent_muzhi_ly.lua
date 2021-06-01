--
-- Author: gf
-- Date: 2016-03-08 11:47:25
--


LOGIN_PLATFORM_PARAM = nil
LOGIN_PLATFORM_PARAM_QQ = "mzSq2"
LOGIN_PLATFORM_PARAM_WX = "mzWx2"

--拇指玩客户端
GameConfig.accountURL = "http://txmzly.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://txmzly.tank.hundredcent.com/serverlist_tank.json"
GameConfig.downRootURL = "http://txmzly.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://txmzly.tank.hundredcent.com/version/tank_apk_ly.json"


function getPayCallBackUrl()
    return "http://txmzly.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=" .. LOGIN_PLATFORM_PARAM
end