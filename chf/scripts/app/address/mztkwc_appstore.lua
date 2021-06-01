-- Author: gf
-- Date: 2016-04-11 14:32:54
-- 拇指IOS 坦克围城



LOGIN_PLATFORM_PARAM = "mztkwc_appstore"


GameConfig.accountURL = "http://mztkwc_appstore.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "https://mztkwc_appstore.tank.hundredcent.com/serverlist_tank.json"
GameConfig.verifyURL = "https://mztkwc_appstore.tank.hundredcent.com/version/tank_ios_test.json"
-- 陈奎
--GameConfig.accountURL = "http://192.168.2.37:8080/tank_account/account/account.do"
--GameConfig.areaURL = "http://192.168.2.37:8080/web/serverlist.json"


GameConfig.downRootURL = "https://cdn.tank.hundredcent.com/tank_2.0.1/"


function getPayCallBackUrl()
    return "http://mztkwc_appstore.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=mztkwc_appstore"
end