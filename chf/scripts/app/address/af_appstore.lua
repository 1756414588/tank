--
-- Author: gf
-- Date: 2016-03-04 14:54:54
-- 安峰IOS

LOGIN_PLATFORM_PARAM = "af_appstore"


GameConfig.accountURL = "http://af_appstore.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "https://af_appstore.tank.hundredcent.com/serverlist_tank.json"
GameConfig.verifyURL = "https://af_appstore.tank.hundredcent.com/version/tank_ios_test.json"
GameConfig.downRootURL = "https://cdn.tank.hundredcent.com/tank_2.0.1/"


--IPV6审核地址
GameConfig.areaURL_ipv6 = "http://ipv4.hundredcent.com/serverlist_tank.json"
GameConfig.verifyURL_ipv6 = "http://ipv4.hundredcent.com/version/tank_ios_test.json"

function getPayCallBackUrl()
    return "http://af_appstore.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=af_appstore"
end