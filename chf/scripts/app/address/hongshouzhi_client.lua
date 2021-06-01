--
-- Author: Your Name
-- Date: 2017-02-09 15:27:59
--
LOGIN_PLATFORM_PARAM = "hongshouzhi"

--草花客户端
--李超
-- GameConfig.accountURL = "http://192.168.2.80:8080/tank_account/account/account.do"
-- GameConfig.areaURL = "http://192.168.2.80:8080/tank_account/serverlist.json"

GameConfig.accountURL = "http://hj4yxfc.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://hj4yxfc.tank.hundredcent.com/serverlist_tank.json"
GameConfig.downRootURL = "http://hj4yxfc.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://hj4yxfc.tank.hundredcent.com/version/tank_apk_ch.json"

function getPayCallBackUrl()
    return "http://hj4yxfc.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=hongshouzhi"
end