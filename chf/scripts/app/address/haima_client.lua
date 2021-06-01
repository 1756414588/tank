--
-- Author: gf
-- Date: 2016-03-04 11:54:42
-- 海马

LOGIN_PLATFORM_PARAM = "haima"


GameConfig.accountURL = "http://haima.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://haima.tank.hundredcent.com/serverlist_tank.json"

-- GameConfig.accountURL = "http://192.168.2.31:8080/tank_account/account/account.do"
-- GameConfig.areaURL = "http://192.168.2.31:8080/web/serverlist.json"


GameConfig.downRootURL = "http://haima.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://haima.tank.hundredcent.com/version/tank_apk_ly.json"


function getPayCallBackUrl()
    return "http://haima.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=haima"
end