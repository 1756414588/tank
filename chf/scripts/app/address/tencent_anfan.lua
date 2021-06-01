--
-- Author: gf
-- Date: 2015-12-02 13:55:22
--

LOGIN_PLATFORM_PARAM = nil
LOGIN_PLATFORM_PARAM_QQ = "afSq"
LOGIN_PLATFORM_PARAM_WX = "afWx"

--安峰玩客户端
GameConfig.accountURL = "http://tencent-anfan.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://tencent-anfan.hundredcent.com/serverlist_tank.json"
GameConfig.downRootURL = "http://cdn.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://cdn.tank.hundredcent.com/version/tank_apk_hf.json"

-- GameConfig.accountURL = "http://self.tank.hundredcent.com:9200/tank_account/account/account.do"
-- GameConfig.areaURL = "http://self.tank.hundredcent.com/serverlist_tank.json"
-- GameConfig.downRootURL = "http://self.tank.hundredcent.com/tank_1.0.1/"

-- GameConfig.accountURL = "http://192.168.2.98:8080/tank_account/account/account.do"
-- GameConfig.areaURL = "http://192.168.2.98:8080/web/serverlist.json"






function getPayCallBackUrl()
    return "http://tencent-anfan.hundredcent.com:9200/tank_account/account/payCallback.do?plat=" .. LOGIN_PLATFORM_PARAM
end