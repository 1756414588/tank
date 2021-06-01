--
-- Author: gf
-- Date: 2015-10-24 17:15:11
--
LOGIN_PLATFORM_PARAM = "oppo"

--360客户端
GameConfig.accountURL = "http://oppo.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://oppo.tank.hundredcent.com/serverlist_tank.json"

-- GameConfig.accountURL = "http://192.168.2.98:8080/tank_account/account/account.do"
-- GameConfig.areaURL = "http://192.168.2.98:8080/web/serverlist.json"


GameConfig.downRootURL = "http://oppo.tank.hundredcent.com/tank_2.0.1/"



function getPayCallBackUrl()
    return "http://oppo.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=oppo"
end