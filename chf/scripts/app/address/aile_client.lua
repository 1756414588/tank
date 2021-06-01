--
-- Author: Your Name
-- Date: 2017-02-08 18:10:22
--
LOGIN_PLATFORM_PARAM = "aile"

--爱乐
GameConfig.accountURL = "http://360.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://360.tank.hundredcent.com/serverlist_tank.json"
GameConfig.downRootURL = "http://360.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://360.tank.hundredcent.com/version/tank_apk_ly.json"

function getPayCallBackUrl()
    return "http://360.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=aile"
end