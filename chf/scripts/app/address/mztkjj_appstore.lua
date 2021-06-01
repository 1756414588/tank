-- Author: gf
-- Date: 2016-04-11 14:32:54
-- 拇指IOS 坦克警戒：重返战场



LOGIN_PLATFORM_PARAM = "mztkjj_appstore"


GameConfig.accountURL = "http://mztkjj_appstore.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "https://mztkjj_appstore.tank.hundredcent.com/serverlist_tank.json"
GameConfig.verifyURL = "https://mztkjj_appstore.tank.hundredcent.com/version/tank_ios_test.json"

GameConfig.downRootURL = "https://cdn.tank.hundredcent.com/tank_2.0.1/"


function getPayCallBackUrl()
    return "http://mztkjj_appstore.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=mztkjj_appstore"
end