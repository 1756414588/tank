-- Author: gf
-- Date: 2016-04-11 14:32:54
-- 拇指IOS 坦克警戒2



LOGIN_PLATFORM_PARAM = "mz_appstore"


GameConfig.accountURL = "http://mztkjjylfc_appstore.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://mztkjjylfc_appstore.tank.hundredcent.com/serverlist_tank.json"
GameConfig.verifyURL = "http://mztkjjylfc_appstore.tank.hundredcent.com/version/tank_ios_test.json"
GameConfig.downRootURL = "http://cdn.tank.hundredcent.com/tank_2.0.1/"


--IPV6审核地址
GameConfig.areaURL_ipv6 = "http://ipv4.hundredcent.com/serverlist_tank.json"
GameConfig.verifyURL_ipv6 = "http://ipv4.hundredcent.com/version/tank_ios_test.json"

function getPayCallBackUrl()
    return "http://mztkjjylfc_appstore.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=mz_appstore"
end