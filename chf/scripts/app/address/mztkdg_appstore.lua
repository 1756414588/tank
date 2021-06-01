-- Author: gf
-- Date: 2016-04-11 14:32:54
-- 拇指IOS 坦克帝国：重器



LOGIN_PLATFORM_PARAM = "mztkdg_appstore"


GameConfig.accountURL = "http://mztkdg_appstore.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "https://mztkdg_appstore.tank.hundredcent.com/serverlist_tank.json"
GameConfig.verifyURL = "https://mztkdg_appstore.tank.hundredcent.com/version/tank_ios_test.json"


GameConfig.downRootURL = "https://cdn.tank.hundredcent.com/tank_2.0.1/"


function getPayCallBackUrl()
    return "http://mztkdg_appstore.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=mztkdg_appstore"
end