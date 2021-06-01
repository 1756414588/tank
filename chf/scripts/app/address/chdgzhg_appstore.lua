--
-- Author: gf
-- Date: 2016-05-16 15:41:53
-- 草花IOS 帝国指挥官




LOGIN_PLATFORM_PARAM = "chdgzhg_appstore"


GameConfig.accountURL = "http://chdgzhg_appstore.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "https://chdgzhg_appstore.tank.hundredcent.com/serverlist_tank.json"
GameConfig.verifyURL = "https://chdgzhg_appstore.tank.hundredcent.com/version/tank_ios_test.json"
GameConfig.payTypeURL = "https://chdgzhg_appstore.tank.hundredcent.com/version/ch_ios_payType.json"




GameConfig.downRootURL = "https://cdn.tank.hundredcent.com/tank_2.0.1/"


function getPayCallBackUrl()
    return "http://chdgzhg_appstore.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=chdgzhg_appstore"
end