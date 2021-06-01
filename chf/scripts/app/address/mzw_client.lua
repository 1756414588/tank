--
-- Author: gf
-- Date: 2016-02-29 17:50:15
-- 拇指玩

LOGIN_PLATFORM_PARAM = "mzw"


GameConfig.accountURL = "http://mzw.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://mzw.tank.hundredcent.com/serverlist_tank.json"

-- GameConfig.accountURL = "http://192.168.2.31:8080/tank_account/account/account.do"
-- GameConfig.areaURL = "http://192.168.2.31:8080/web/serverlist.json"


GameConfig.downRootURL = "http://mzw.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://mzw.tank.hundredcent.com/version/tank_apk_ly.json"


function getPayCallBackUrl()
    return "http://mzw.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=mzw"
end