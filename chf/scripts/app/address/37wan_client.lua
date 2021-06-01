--
-- Author: gf
-- Date: 2016-02-29 10:39:25
--

LOGIN_PLATFORM_PARAM = "37wan"


GameConfig.accountURL = "http://37wan.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://37wan.tank.hundredcent.com/serverlist_tank.json"



GameConfig.downRootURL = "http://37wan.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://37wan.tank.hundredcent.com/version/tank_apk_ly.json"


function getPayCallBackUrl()
    return "http://37wan.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=37wan"
end