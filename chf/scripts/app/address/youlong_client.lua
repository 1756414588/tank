--
-- Author: Your Name
-- Date: 2017-02-18 14:58:17
--
--拇指游龙（聚合）
LOGIN_PLATFORM_PARAM = "youlong"


GameConfig.accountURL = "http://37wan.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://37wan.tank.hundredcent.com/serverlist_tank.json"
GameConfig.downRootURL = "http://37wan.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://37wan.tank.hundredcent.com/version/tank_apk_ly.json"


function getPayCallBackUrl()
    return "http://37wan.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=youlong"
end