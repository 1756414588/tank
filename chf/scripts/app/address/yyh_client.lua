--
-- Author: gf
-- Date: 2016-03-09 15:54:38
-- 应用汇


LOGIN_PLATFORM_PARAM = "yyh"


GameConfig.accountURL = "http://yyh.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://yyh.tank.hundredcent.com/serverlist_tank.json"
GameConfig.downRootURL = "http://yyh.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://yyh.tank.hundredcent.com/version/tank_apk_ly.json"


function getPayCallBackUrl()
    return "http://yyh.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=yyh"
end