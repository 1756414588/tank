--
-- Author: gf
-- Date: 2015-11-06 16:26:11
--

LOGIN_PLATFORM_PARAM = "muzhily"

--拇指玩客户端
GameConfig.accountURL = "http://muzhily.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://muzhily.tank.hundredcent.com/serverlist_tank.json"
GameConfig.downRootURL = "http://37wan.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://37wan.tank.hundredcent.com/version/tank_apk_ly.json"

function getPayCallBackUrl()
    return "http://muzhily.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=muzhily"
end