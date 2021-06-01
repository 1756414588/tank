--
-- Author: gf
-- Date: 2016-06-28 09:14:53
-- 拇指IOS 坦克突击




LOGIN_PLATFORM_PARAM = "mztktj_appstore"


GameConfig.accountURL = "http://mztktj_appstore.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "https://mztktj_appstore.tank.hundredcent.com/serverlist_tank.json"
GameConfig.verifyURL = "https://mztktj_appstore.tank.hundredcent.com/version/tank_ios_test.json"

GameConfig.downRootURL = "https://cdn.tank.hundredcent.com/tank_2.0.1/"


function getPayCallBackUrl()
    return "http://mztktj_appstore.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=mztktj_appstore"
end