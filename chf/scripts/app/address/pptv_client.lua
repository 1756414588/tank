--
-- Author: gf
-- Date: 2016-03-02 14:22:16
-- PPTV

LOGIN_PLATFORM_PARAM = "pptv"


GameConfig.accountURL = "http://pptv.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://pptv.tank.hundredcent.com/serverlist_tank.json"

-- GameConfig.accountURL = "http://192.168.2.31:8080/tank_account/account/account.do"
-- GameConfig.areaURL = "http://192.168.2.31:8080/web/serverlist.json"


GameConfig.downRootURL = "http://pptv.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://pptv.tank.hundredcent.com/version/tank_apk_ly.json"


function getPayCallBackUrl()
    return "http:/pptv.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=pptv"
end