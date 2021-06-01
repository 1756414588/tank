--
-- Author: gf
-- Date: 2016-02-29 14:12:57
-- 草花帝国风暴 CPS 清源SDK支付


LOGIN_PLATFORM_PARAM = "chdgfb_appstore"


GameConfig.accountURL = "http://chdgfb_appstore.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "https://chdgfb_appstore.tank.hundredcent.com/serverlist_tank.json"
GameConfig.verifyURL = "https://chdgfb_appstore.tank.hundredcent.com/version/tank_ios_test.json"
GameConfig.downRootURL = "https://cdn.tank.hundredcent.com/tank_2.0.1/"


--IPV6审核地址
-- GameConfig.accountURL_ipv6 = "http://ipv4.hundredcent.com:9200/tank_account/account/account.do"
-- GameConfig.areaURL_ipv6 = "http://ipv4.hundredcent.com/serverlist_tank.json"
-- GameConfig.verifyURL_ipv6 = "http://ipv4.hundredcent.com/version/tank_ios_test.json"

function getPayCallBackUrl()
    return "http://chdgfb_appstore.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=chdgfb_appstore"
end