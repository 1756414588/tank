--
-- Author: gf
-- Date: 2015-10-24 15:29:51
--
LOGIN_PLATFORM_PARAM = "360"

--360客户端
GameConfig.accountURL = "http://360.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://360.tank.hundredcent.com/serverlist_tank.json"

-- GameConfig.accountURL = "http://192.168.2.98:8080/tank_account/account/account.do"
-- GameConfig.areaURL = "http://192.168.2.98:8080/web/serverlist.json"


GameConfig.downRootURL = "http://360.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://360.tank.hundredcent.com/version/tank_apk_ly.json"


function getPayCallBackUrl()
    return "http://360.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=360"
end