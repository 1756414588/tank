--
-- Author: gf
-- Date: 2016-02-29 14:12:57
-- 草花IOS 超级装甲-坦克战争


LOGIN_PLATFORM_PARAM = "chCjzjtkzz_appstore"

GameConfig.accountURL = "http://ch_appstore.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://ch_appstore.tank.hundredcent.com/serverlist_tank.json"
GameConfig.verifyURL = "http://ch_appstore.tank.hundredcent.com/version/tank_ios_test.json"
GameConfig.downRootURL = "http://cdn.tank.hundredcent.com/tank_2.0.1/"


--IPV6审核地址
GameConfig.areaURL_ipv6 = "http://ipv4.hundredcent.com/serverlist_tank.json"
GameConfig.verifyURL_ipv6 = "http://ipv4.hundredcent.com/version/tank_ios_test.json"

function getPayCallBackUrl()
    return "http://ch_appstore.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=chCjzjtkzz_appstore"
end