--
-- Author: gf
-- Date: 2016-03-09 13:53:12
-- 卓悠

LOGIN_PLATFORM_PARAM = "zhuoyou"


GameConfig.accountURL = "http://zhuoyou.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://zhuoyou.tank.hundredcent.com/serverlist_tank.json"

-- GameConfig.accountURL = "http://192.168.2.31:8080/tank_account/account/account.do"
-- GameConfig.areaURL = "http://192.168.2.31:8080/web/serverlist.json"


GameConfig.downRootURL = "http://zhuoyou.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://zhuoyou.tank.hundredcent.com/version/tank_apk_ly.json"


function getPayCallBackUrl()
    return "http://zhuoyou.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=zhuoyou"
end