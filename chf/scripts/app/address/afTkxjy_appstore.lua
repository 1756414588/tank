--
-- Author: gf
-- Date: 2016-05-25 09:48:34
-- 安峰IOS 坦克新纪元


LOGIN_PLATFORM_PARAM = "afTkxjy_appstore"


GameConfig.accountURL = "http://afTkxjy_appstore.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "https://afTkxjy_appstore.tank.hundredcent.com/serverlist_tank.json"
GameConfig.verifyURL = "https://afTkxjy_appstore.tank.hundredcent.com/version/tank_ios_test.json"
GameConfig.downRootURL = "https://cdn.tank.hundredcent.com/tank_2.0.1/"


function getPayCallBackUrl()
    return "http://afTkxjy_appstore.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=afTkxjy_appstore"
end