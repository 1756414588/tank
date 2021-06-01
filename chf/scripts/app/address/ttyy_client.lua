--
-- Author: gf
-- Date: 2016-03-07 11:53:09
-- TT语音

LOGIN_PLATFORM_PARAM = "ttyy"


GameConfig.accountURL = "http://ttyy.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://ttyy.tank.hundredcent.com/serverlist_tank.json"

-- GameConfig.accountURL = "http://192.168.2.31:8080/tank_account/account/account.do"
-- GameConfig.areaURL = "http://192.168.2.31:8080/web/serverlist.json"


GameConfig.downRootURL = "http://ttyy.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://ttyy.tank.hundredcent.com/version/tank_apk_ly.json"


function getPayCallBackUrl()
    return "http://ttyy.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=ttyy"
end