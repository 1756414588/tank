--
-- Author: gf
-- Date: 2016-06-23 14:54:50
--
LOGIN_PLATFORM_PARAM = "mztkwz"

--拇指玩  坦克武装 客户端
GameConfig.accountURL = "http://mztkwz.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://mztkwz.tank.hundredcent.com/serverlist_tank.json"
GameConfig.downRootURL = "http://cdn.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://cdn.tank.hundredcent.com/version/tank_apk_hf.json"

function getPayCallBackUrl()
    return "http://mztkwz.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=mztkwz"
end