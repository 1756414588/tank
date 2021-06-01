--
-- Author: Your Name
-- Date: 2017-04-07 17:28:41
--
--  草花红警复仇 -- oppo
LOGIN_PLATFORM_PARAM = "chYhOppo"

GameConfig.accountURL = "http://chYhOppo.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://chYhOppo.tank.hundredcent.com/serverlist_tank.json"
GameConfig.downRootURL = "http://hj4yxfc.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://hj4yxfc.tank.hundredcent.com/version/tank_apk_ch.json"

function getPayCallBackUrl()
    return "http://chYhOppo.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=chYhOppo"
end