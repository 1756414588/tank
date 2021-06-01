--
-- Author: gf
-- Date: 2017-01-20 15:04:12
--  草花 IOS 战争指挥官-跨服团战

LOGIN_PLATFORM_PARAM = "chzzzhg_appstore"


GameConfig.accountURL = "http://ch_appstore.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "https://ch_appstore.tank.hundredcent.com/serverlist_tank.json"
GameConfig.verifyURL = "https://ch_appstore.tank.hundredcent.com/version/tank_ios_test.json"
GameConfig.downRootURL = "https://cdn.tank.hundredcent.com/tank_2.0.1/"

--智汇推广告接口
-- GameConfig.idfaURL = "http://chxsjt_appstore1.tank.hundredcent.com:9108/tank_advertise/account/zhtCheck.do?plat=ch_appstore"
-- GameConfig.idfaWXURL = "http://chxsjt_appstore1.tank.hundredcent.com:9108/tank_advertise/account/wxadCheck.do"


--IPV6审核地址
GameConfig.accountURL_ipv6 = "http://ipv4.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL_ipv6 = "http://ipv4.hundredcent.com/serverlist_tank.json"
GameConfig.verifyURL_ipv6 = "http://ipv4.hundredcent.com/version/tank_ios_test.json"

function getPayCallBackUrl()
    return "http://ch_appstore.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=chzzzhg_appstore"
end