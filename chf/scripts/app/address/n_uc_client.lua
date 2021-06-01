--
-- Author: gf
-- Date: 2015-10-10 09:51:14
--

LOGIN_PLATFORM_PARAM = "n_uc"

--UC客户端
GameConfig.accountURL = "http://uc.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://uc.tank.hundredcent.com/serverlist_tank.json"

-- GameConfig.accountURL = "http://192.168.2.98:8080/tank_account/account/account.do"
-- GameConfig.areaURL = "http://192.168.2.98:8080/web/serverlist.json"

GameConfig.downRootURL = "http://uc.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://uc.tank.hundredcent.com/version/tank_apk_ly.json"


function getPayCallBackUrl()
    return "http://uc.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=n_uc"
end