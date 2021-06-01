--
-- Author: gf
-- Date: 2016-04-11 14:32:54
-- 拇指IOS 喜马拉雅



LOGIN_PLATFORM_PARAM = "mzXmly_appstore"


GameConfig.accountURL = "http://mz_appstore.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "https://mz_appstore.tank.hundredcent.com/serverlist_tank.json"
GameConfig.verifyURL = "https://mz_appstore.tank.hundredcent.com/version/tank_ios_test.json"
GameConfig.downRootURL = "https://cdn.tank.hundredcent.com/tank_2.0.1/"


function getPayCallBackUrl()
    return "http://mz_appstore.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=mzXmly_appstore"
end