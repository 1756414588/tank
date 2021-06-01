--
-- Author: gf
-- Date: 2016-03-03 10:13:41
-- 内涵段子


LOGIN_PLATFORM_PARAM = "nhdz"


GameConfig.accountURL = "http://nhdz.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://nhdz.tank.hundredcent.com/serverlist_tank.json"

-- GameConfig.accountURL = "http://192.168.2.31:8080/tank_account/account/account.do"
-- GameConfig.areaURL = "http://192.168.2.31:8080/web/serverlist.json"


GameConfig.downRootURL = "http://nhdz.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://nhdz.tank.hundredcent.com/version/tank_apk_ly.json"


function getPayCallBackUrl()
    return "http:/nhdz.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=nhdz"
end