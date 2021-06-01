--
-- Author: gf
-- Date: 2016-03-01 15:13:54
-- 朋友玩


LOGIN_PLATFORM_PARAM = "pyw"


GameConfig.accountURL = "http://pyw.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://pyw.tank.hundredcent.com/serverlist_tank.json"

-- GameConfig.accountURL = "http://192.168.2.31:8080/tank_account/account/account.do"
-- GameConfig.areaURL = "http://192.168.2.31:8080/web/serverlist.json"


GameConfig.downRootURL = "http://pyw.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://pyw.tank.hundredcent.com/version/tank_apk_ly.json"


function getPayCallBackUrl()
    return "http:/pyw.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=pyw"
end