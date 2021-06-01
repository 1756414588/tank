--
-- Author: gf
-- Date: 2016-02-26 10:06:56
-- 安智


LOGIN_PLATFORM_PARAM = "anzhi"


GameConfig.accountURL = "http://anzhi.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://anzhi.tank.hundredcent.com/serverlist_tank.json"

-- GameConfig.accountURL = "http://192.168.2.31:8080/tank_account/account/account.do"
-- GameConfig.areaURL = "http://192.168.2.31:8080/web/serverlist.json"


GameConfig.downRootURL = "http://anzhi.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://anzhi.tank.hundredcent.com/version/tank_apk_ly.json"


function getPayCallBackUrl()
    return "http://anzhi.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=anzhi"
end