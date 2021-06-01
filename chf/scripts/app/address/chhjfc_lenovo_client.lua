--
-- Author: Your Name
-- Date: 2017-04-12 11:49:08
--
--  草花红警复仇 -- 联想
LOGIN_PLATFORM_PARAM = "chYhLx"

GameConfig.accountURL = "http://chYhLx.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://chYhLx.tank.hundredcent.com/serverlist_tank.json"
GameConfig.downRootURL = "http://hj4yxfc.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://hj4yxfc.tank.hundredcent.com/version/tank_apk_ch.json"

-- 李超
-- GameConfig.accountURL = "http://192.168.2.80:8080/tank_account/account/account.do"
-- GameConfig.areaURL = "http://192.168.2.80:8080/web/serverlist.json"

function getPayCallBackUrl()
    return "http://chYhLx.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=chYhLx"
end