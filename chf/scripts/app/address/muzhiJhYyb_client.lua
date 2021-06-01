--
-- Author: gf
-- Date: 2016-04-14 14:34:41
-- 拇指聚合 应用宝 混服

LOGIN_PLATFORM_PARAM = "muzhiJhYyb"

--拇指聚合
GameConfig.accountURL = "http://muzhiJh.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://muzhiJh.tank.hundredcent.com/serverlist_tank.json"
GameConfig.downRootURL = "http://cdn.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://cdn.tank.hundredcent.com/version/tank_apk_hf.json"

function getPayCallBackUrl()
    return "http://muzhiJh.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=muzhiJhYyb"
end
