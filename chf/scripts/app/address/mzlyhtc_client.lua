--
-- Author: Your Name
-- Date: 2017-05-16 14:45:51
--

LOGIN_PLATFORM_PARAM = "mzlyhtc"

--htc客户端(拇指)
GameConfig.accountURL = "http://mzlyhtc.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://mzlyhtc.tank.hundredcent.com/serverlist_tank.json"
GameConfig.downRootURL = "http://360.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://360.tank.hundredcent.com/version/tank_apk_ly.json"

function getPayCallBackUrl()
    return "http://mzlyhtc.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=mzlyhtc"
end