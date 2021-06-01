--
-- Author: Your Name
-- Date: 2017-04-14 11:22:55
--
--  草花红警复仇 -- 应用宝
LOGIN_PLATFORM_PARAM = nil
LOGIN_PLATFORM_PARAM_QQ = "chYhSq"
LOGIN_PLATFORM_PARAM_WX = "chYhWx"

GameConfig.accountURL = "http://chYhYyb.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://chYhYyb.tank.hundredcent.com/serverlist_tank.json"
GameConfig.downRootURL = "http://hj4yxfc.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://hj4yxfc.tank.hundredcent.com/version/tank_apk_ch.json"

-- 李超
-- GameConfig.accountURL = "http://192.168.2.80:8080/tank_account/account/account.do"
-- GameConfig.areaURL = "http://192.168.2.80:8080/web/serverlist.json"

function getPayCallBackUrl()
    return "http://chYhYyb.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat="..LOGIN_PLATFORM_PARAM
end