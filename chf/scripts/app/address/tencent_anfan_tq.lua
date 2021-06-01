--
-- Author: gf
-- Date: 2016-03-31 18:50:56
-- 天启的狂怒

LOGIN_PLATFORM_PARAM = nil
LOGIN_PLATFORM_PARAM_QQ = "afSq3"
LOGIN_PLATFORM_PARAM_WX = "afWx3"

--安峰玩客户端
GameConfig.accountURL = "http://tqkn.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://tqkn.tank.hundredcent.com/serverlist_tank.json"
GameConfig.downRootURL = "http://cdn.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://cdn.tank.hundredcent.com/version/tank_apk_hf.json"

-- GameConfig.accountURL = "http://self.tank.hundredcent.com:9200/tank_account/account/account.do"
-- GameConfig.areaURL = "http://self.tank.hundredcent.com/serverlist_tank.json"
-- GameConfig.downRootURL = "http://self.tank.hundredcent.com/tank_1.0.1/"

-- GameConfig.accountURL = "http://192.168.2.98:8080/tank_account/account/account.do"
-- GameConfig.areaURL = "http://192.168.2.98:8080/web/serverlist.json"






function getPayCallBackUrl()
    return "http://tqkn.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=" .. LOGIN_PLATFORM_PARAM
end