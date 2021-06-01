--
-- Author: gf
-- Date: 2016-02-29 13:47:40
--

LOGIN_PLATFORM_PARAM = "downjoy"


GameConfig.accountURL = "http://downjoy.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://downjoy.tank.hundredcent.com/serverlist_tank.json"

-- GameConfig.accountURL = "http://192.168.2.31:8080/tank_account/account/account.do"
-- GameConfig.areaURL = "http://192.168.2.31:8080/web/serverlist.json"


GameConfig.downRootURL = "http://downjoy.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://downjoy.tank.hundredcent.com/version/tank_apk_ly.json"


function getPayCallBackUrl()
    return "http://downjoy.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=downjoy"
end