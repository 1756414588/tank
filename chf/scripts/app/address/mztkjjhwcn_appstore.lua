-- Author: gf
-- Date: 2016-04-11 14:32:54
-- 拇指IOS 坦克警戒 海外中文版



LOGIN_PLATFORM_PARAM = "mztkjjhwcn_appstore"


GameConfig.accountURL = "http://mztkjjhwcn1_appstore.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "https://mztkjjhwcn1_appstore.tank.hundredcent.com/serverlist_tank.json"
GameConfig.verifyURL = "https://mztkjjhwcn1_appstore.tank.hundredcent.com/version/tank_ios_test.json"
GameConfig.downRootURL = "https://mztkjjhwcn_appstore.tank.hundredcent.com/tank_2.0.1/"


function getPayCallBackUrl()
    return "http://mztkjjhwcn1_appstore.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=mztkjjhwcn_appstore"
end