-- Author: gf
-- Date: 2016-04-11 14:32:54
-- 拇指IOS 二战坦克



LOGIN_PLATFORM_PARAM = "mzeztk_appstore"


GameConfig.accountURL = "http://mzeztk_appstore.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "https://mzeztk_appstore.tank.hundredcent.com/serverlist_tank.json"
GameConfig.verifyURL = "https://mzeztk_appstore.tank.hundredcent.com/version/tank_ios_test.json"
GameConfig.downRootURL = "https://cdn.tank.hundredcent.com/tank_2.0.1/"


function getPayCallBackUrl()
    return "http://mzeztk_appstore.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=mzeztk_appstore"
end