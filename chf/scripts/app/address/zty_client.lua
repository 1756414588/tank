--
-- Author: gf
-- Date: 2015-11-06 16:26:11
--

LOGIN_PLATFORM_PARAM = "muzhi"

--拇指玩客户端
GameConfig.accountURL = "http://muzhi.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://muzhi.tank.hundredcent.com/serverlist_tank.json"
GameConfig.downRootURL = "http://cdn.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://cdn.tank.hundredcent.com/version/tank_apk_hf.json"

function getPayCallBackUrl()
    return "http://muzhi.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=muzhi"
end