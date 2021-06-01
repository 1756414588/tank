--
-- Author: Your Name
-- Date: 2017-01-06 18:25:36
--
LOGIN_PLATFORM_PARAM = "mzwM1"

--拇指玩客户端
GameConfig.accountURL = "http://mzwM1.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://mzwM1.tank.hundredcent.com/serverlist_tank.json"
GameConfig.downRootURL = "http://cdn.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://cdn.tank.hundredcent.com/version/tank_apk_hf.json"

function getPayCallBackUrl()
    return "http://mzwM1.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=mzwM1"
end