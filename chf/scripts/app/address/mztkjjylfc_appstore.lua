-- Author: gf
-- Date: 2016-04-11 14:32:54
-- 拇指IOS 坦克警戒 尤里复仇 (更名为坦克警戒：战火世界)



LOGIN_PLATFORM_PARAM = "mz_appstore"


GameConfig.accountURL = "http://mztkjjylfc_appstore.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://mztkjjylfc_appstore.tank.hundredcent.com/serverlist_tank.json"
GameConfig.verifyURL = "http://mztkjjylfc_appstore.tank.hundredcent.com/version/tank_ios_test.json"
GameConfig.downRootURL = "http://cdn.tank.hundredcent.com/tank_2.0.1/"

--预发布测试
-- GameConfig.accountURL = "http://119.29.180.212:9200/tank_account/account/account.do"
-- GameConfig.areaURL = "http://119.29.180.212/serverlist_tank.json"
-- GameConfig.downRootURL = "http://119.29.180.212/tank_2.0.1/"



--IPV6审核地址
GameConfig.areaURL_ipv6 = "http://ipv4.hundredcent.com/serverlist_tank.json"
GameConfig.verifyURL_ipv6 = "http://ipv4.hundredcent.com/version/tank_ios_test.json"


function getPayCallBackUrl()
    return "http://mztkjjylfc_appstore.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=mz_appstore"
end