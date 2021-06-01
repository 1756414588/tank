--
-- Author: gf
-- Date: 2016-05-31 15:12:59
--


LOGIN_PLATFORM_PARAM = "ylt"

--安峰客户端
-- GameConfig.accountURL = "http://ylt.tank.hundredcent.com:9200/tank_account/account/account.do"
-- GameConfig.areaURL = "http://ylt.tank.hundredcent.com/serverlist_tank.json"
-- GameConfig.downRootURL = "http://cdn.tank.hundredcent.com/tank_2.0.1/"
-- GameConfig.versionURL = "http://ylt.tank.hundredcent.com/version/ylt_v.json"

GameConfig.accountURL = "http://ylt.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://ylt.tank.hundredcent.com/serverlist_tank.json"
GameConfig.downRootURL = "http://ylt.tank.hundredcent.com/tank_2.0.1/"


function getPayCallBackUrl()
    return "http://ylt.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=ylt"
end