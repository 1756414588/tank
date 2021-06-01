--
-- Author: gf
-- Date: 2016-05-16 15:41:53
-- 草花IOS 烈火坦克




LOGIN_PLATFORM_PARAM = "chlhtk_appstore"


GameConfig.accountURL = "http://chlhtk_appstore.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "https://chlhtk_appstore.tank.hundredcent.com/serverlist_tank.json"
GameConfig.verifyURL = "https://chlhtk_appstore.tank.hundredcent.com/version/tank_ios_test.json"
GameConfig.downRootURL = "https://cdn.tank.hundredcent.com/tank_2.0.1/"



-- GameConfig.accountURL = "http://119.29.180.212:9200/tank_account/account/account.do"
-- GameConfig.areaURL = "http://119.29.180.212/serverlist_tank.json"



--IPV6审核地址
-- GameConfig.accountURL_ipv6 = "http://ipv4.hundredcent.com:9200/tank_account/account/account.do"
-- GameConfig.areaURL_ipv6 = "http://ipv4.hundredcent.com/serverlist_tank.json"
-- GameConfig.verifyURL_ipv6 = "http://ipv4.hundredcent.com/version/tank_ios_test.json"

function getPayCallBackUrl()
    return "http://chlhtk_appstore.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=chlhtk_appstore"
end