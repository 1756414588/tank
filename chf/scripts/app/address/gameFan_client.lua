--
-- Author: Your Name
-- Date: 2016-12-22 14:03:45
--
LOGIN_PLATFORM_PARAM = "gameFan"

--
GameConfig.accountURL = "http://gameFan.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://gameFan.tank.hundredcent.com/serverlist_tank.json"
GameConfig.downRootURL = "http://cdn.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://cdn.tank.hundredcent.com/version/tank_apk_hf.json"
--李超
-- GameConfig.accountURL = "http://192.168.2.80:8080/tank_account/account/account.do"
-- GameConfig.areaURL = "http://192.168.2.80:8080/tank_account/serverlist.json"

function getPayCallBackUrl()
    return "http://gameFan.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=gameFan"
end