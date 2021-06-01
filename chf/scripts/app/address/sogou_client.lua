--
-- Author: gf
-- Date: 2016-02-26 14:32:06
--

LOGIN_PLATFORM_PARAM = "sogou"


GameConfig.accountURL = "http://sogou.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://sogou.tank.hundredcent.com/serverlist_tank.json"

-- GameConfig.accountURL = "http://192.168.2.31:8080/tank_account/account/account.do"
-- GameConfig.areaURL = "http://192.168.2.31:8080/web/serverlist.json"


GameConfig.downRootURL = "http://sogou.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://sogou.tank.hundredcent.com/version/tank_apk_ly.json"


function getPayCallBackUrl()
    return "http://sogou.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=sogou"
end