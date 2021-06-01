--
-- Author: gf
-- Date: 2016-02-16 10:31:35
-- 拇指应用宝世界大战

LOGIN_PLATFORM_PARAM = nil
LOGIN_PLATFORM_PARAM_QQ = "mzSq1"
LOGIN_PLATFORM_PARAM_WX = "mzWx1"

--拇指玩客户端
GameConfig.accountURL = "http://txsjdz.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://txsjdz.tank.hundredcent.com/serverlist_tank.json"
GameConfig.downRootURL = "http://cdn.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://cdn.tank.hundredcent.com/version/tank_apk_hf.json"


function getPayCallBackUrl()
    return "http://txsjdz.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=" .. LOGIN_PLATFORM_PARAM
end