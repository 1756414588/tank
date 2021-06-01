--
-- Author: gf
-- Date: 2016-02-23 14:55:14
-- 魅族

LOGIN_PLATFORM_PARAM = "meizhu"

--拇指玩客户端
GameConfig.accountURL = "http://meizhu.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://meizhu.tank.hundredcent.com/serverlist_tank.json"

-- GameConfig.accountURL = "http://192.168.2.31:8080/tank_account/account/account.do"
-- GameConfig.areaURL = "http://192.168.2.31:8080/web/serverlist.json"


GameConfig.downRootURL = "http://meizhu.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://meizhu.tank.hundredcent.com/version/tank_apk_ly.json"


function getPayCallBackUrl()
    return "http://meizhu.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=meizhu"
end