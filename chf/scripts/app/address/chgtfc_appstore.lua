--
-- Author: gf
-- Date: 2016-02-29 14:12:57
-- 草花IOS 钢铁复仇


LOGIN_PLATFORM_PARAM = "chgtfc_appstore"


GameConfig.accountURL = "http://chgtfc_appstore.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "https://chgtfc_appstore.tank.hundredcent.com/serverlist_tank.json"
GameConfig.verifyURL = "https://chgtfc_appstore.tank.hundredcent.com/version/tank_ios_test.json"
GameConfig.downRootURL = "https://cdn.tank.hundredcent.com/tank_2.0.1/"


function getPayCallBackUrl()
    return "http://chgtfc_appstore.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=chgtfc_appstore"
end