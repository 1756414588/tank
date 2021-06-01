--
-- Author: gf
-- Date: 2015-10-26 11:24:19
--

LOGIN_PLATFORM_PARAM = "anfan"

--安峰客户端
GameConfig.accountURL = "http://anfan.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://anfan.tank.hundredcent.com/serverlist_tank.json"
GameConfig.downRootURL = "http://cdn.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://cdn.tank.hundredcent.com/version/tank_apk_hf.json"


function getPayCallBackUrl()
    return "http://anfan.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=anfan"
end