--
-- Author: gf
-- Date: 2016-04-14 14:34:41
-- 拇指 坦克警戒 聚合 联运

LOGIN_PLATFORM_PARAM = "muzhiU8ly"

--拇指聚合
GameConfig.accountURL = "http://37wan.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://37wan.tank.hundredcent.com/serverlist_tank.json"

GameConfig.downRootURL = "http://37wan.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://37wan.tank.hundredcent.com/version/tank_apk_ly.json"

function getPayCallBackUrl()
    return "http://37wan.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=muzhiU8ly"
end
