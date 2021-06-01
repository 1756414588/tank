--
-- Author: Your Name
-- Date: 2017-02-27 18:27:30
--

LOGIN_PLATFORM_PARAM = "anfanTest"

--安峰客户端
GameConfig.accountURL = "http://119.29.180.212:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://119.29.180.212/serverlist_tank.json"
GameConfig.downRootURL = "http://cdn.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://cdn.tank.hundredcent.com/version/tank_apk_hf.json"


function getPayCallBackUrl()
    return "http://119.29.180.212:9200/tank_account/account/payCallback.do?plat=anfanTest"
end