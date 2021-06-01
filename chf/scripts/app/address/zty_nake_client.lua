--
-- Author: gf
-- Date: 2015-11-06 16:26:11
--

LOGIN_PLATFORM_PARAM = "muzhi"

--拇指玩客户端
GameConfig.accountURL = "http://muzhi.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://muzhi.tank.hundredcent.com/serverlist_tank.json"

-- GameConfig.accountURL = "http://192.168.2.98:8080/tank_account/account/account.do"
-- GameConfig.areaURL = "http://192.168.2.98:8080/web/serverlist.json"


GameConfig.downRootURL = "http://muzhi.tank.hundredcent.com/tank_1.0.1/"
GameConfig.versionURL = "http://muzhi.tank.hundredcent.com/version/muzhi_v.json"


function getPayCallBackUrl()
    return "http://muzhi.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=muzhi"
end