--
-- Author: gf
-- Date: 2016-01-22 10:27:05
--


LOGIN_PLATFORM_PARAM = "anfan1"

--安峰客户端
GameConfig.accountURL = "http://anfan1.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://anfan1.tank.hundredcent.com/serverlist_tank.json"
GameConfig.downRootURL = "http://cdn.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://cdn.tank.hundredcent.com/version/tank_apk_hf.json"


function getPayCallBackUrl()
    return "http://anfan1.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=anfan1"
end