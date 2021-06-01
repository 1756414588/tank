--
-- Author: gf
-- Date: 2016-04-14 14:34:41
-- 拇指聚合

LOGIN_PLATFORM_PARAM = "muzhi49"

--拇指聚合
GameConfig.accountURL = "http://muzhi49.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://muzhi49.tank.hundredcent.com/serverlist_tank.json"
GameConfig.downRootURL = "http://cdn.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://cdn.tank.hundredcent.com/version/tank_apk_hf.json"

function getPayCallBackUrl()
    return "http://muzhi49.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=muzhi49"
end
