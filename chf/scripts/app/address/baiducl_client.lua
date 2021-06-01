--
-- Author: gf
-- Date: 2016-02-25 11:06:43
-- 百度采量

LOGIN_PLATFORM_PARAM = "baiducl"


GameConfig.accountURL = "http://baiducl.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://baiducl.tank.hundredcent.com/serverlist_tank.json"

-- GameConfig.accountURL = "http://192.168.2.31:8080/tank_account/account/account.do"
-- GameConfig.areaURL = "http://192.168.2.31:8080/web/serverlist.json"


GameConfig.downRootURL = "http://cdn.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://cdn.tank.hundredcent.com/version/tank_apk_hf.json"


function getPayCallBackUrl()
    return "http://baiducl.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=baiducl"
end