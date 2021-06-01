--
-- Author: gf
-- Date: 2016-02-29 14:12:57
-- 草花IOS 装甲起源


LOGIN_PLATFORM_PARAM = "chzjqy_appstore"


GameConfig.accountURL = "http://chzjqy_appstore.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "https://chzjqy_appstore.tank.hundredcent.com/serverlist_tank.json"
GameConfig.verifyURL = "https://chzjqy_appstore.tank.hundredcent.com/version/tank_ios_test.json"
GameConfig.downRootURL = "https://cdn.tank.hundredcent.com/tank_2.0.1/"


--IPV6审核地址
-- GameConfig.accountURL_ipv6 = "http://ipv4.hundredcent.com:9200/tank_account/account/account.do"
-- GameConfig.areaURL_ipv6 = "http://ipv4.hundredcent.com/serverlist_tank.json"
-- GameConfig.verifyURL_ipv6 = "http://ipv4.hundredcent.com/version/tank_ios_test.json"

function getPayCallBackUrl()
    return "http://chzjqy_appstore.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=chzjqy_appstore"
end