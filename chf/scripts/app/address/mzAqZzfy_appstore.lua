--
-- Author: gf
-- Date: 2016-04-11 14:32:54
-- 拇指IOS 安趣 战争风云



LOGIN_PLATFORM_PARAM = "mzAqZzfy_appstore"


GameConfig.accountURL = "http://mz_appstore.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "https://mz_appstore.tank.hundredcent.com/serverlist_tank.json"
GameConfig.verifyURL = "https://mz_appstore.tank.hundredcent.com/version/tank_ios_test.json"
GameConfig.downRootURL = "https://cdn.tank.hundredcent.com/tank_2.0.1/"


--IPV6审核地址
-- GameConfig.accountURL_ipv6 = "http://ipv4.hundredcent.com:9200/tank_account/account/account.do"
-- GameConfig.areaURL_ipv6 = "http://ipv4.hundredcent.com/serverlist_tank.json"
-- GameConfig.verifyURL_ipv6 = "http://ipv4.hundredcent.com/version/tank_ios_test.json"

function getPayCallBackUrl()
    return "http://mz_appstore.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=mzAqZzfy_appstore"
end