--
-- Author: gf
-- Date: 2015-10-22 10:09:04
--
LOGIN_PLATFORM_PARAM = "mi"

--小米客户端
GameConfig.accountURL = "http://mi.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://mi.tank.hundredcent.com/serverlist_tank.json"

-- GameConfig.accountURL = "http://192.168.2.98:8080/tank_account/account/account.do"
-- GameConfig.areaURL = "http://192.168.2.98:8080/web/serverlist.json"


GameConfig.downRootURL = "http://mi.tank.hundredcent.com/tank_2.0.1/"



function getPayCallBackUrl()
    return "http://mi.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=mi"
end