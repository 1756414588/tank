--
-- Author: Xiaohang
-- Date: 2016-05-25 10:10:45
--草花 应用宝 红警4 
LOGIN_PLATFORM_PARAM = nil
LOGIN_PLATFORM_PARAM_QQ = "chSq1"
LOGIN_PLATFORM_PARAM_WX = "chWx1"

--应用宝英雄复仇户端
GameConfig.accountURL = "http://yxfc.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://yxfc.tank.hundredcent.com/serverlist_tank.json"
GameConfig.downRootURL = "http://hj4yxfc.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://hj4yxfc.tank.hundredcent.com/version/tank_apk_ch.json"

function getPayCallBackUrl()
    return "http://yxfc.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=" .. LOGIN_PLATFORM_PARAM
end