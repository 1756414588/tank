--
-- Author: gf
-- Date: 2016-02-25 11:06:43
-- 百度采量

LOGIN_PLATFORM_PARAM = "baiducltkjj"


GameConfig.accountURL = "http://baiducltkjj.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://baiducltkjj.tank.hundredcent.com/serverlist_tank.json"

-- GameConfig.downRootURL = "http://cdn.tank.hundredcent.com/tank_2.0.1/"
-- GameConfig.versionURL = "http://cdn.tank.hundredcent.com/version/tank_apk_hf.json"


-- GameConfig.accountURL = "http://muzhily.tank.hundredcent.com:9200/tank_account/account/account.do"
-- GameConfig.areaURL = "http://muzhily.tank.hundredcent.com/serverlist_tank.json"
GameConfig.downRootURL = "http://37wan.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://37wan.tank.hundredcent.com/version/tank_apk_ly.json"

function getPayCallBackUrl()
    return "http://baiducltkjj.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=baiducltkjj"
end