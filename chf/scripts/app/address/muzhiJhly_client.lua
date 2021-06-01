--
-- Author: gf
-- Date: 2016-06-28 12:19:49
-- 拇指聚合（新聚合，带切换支付）

LOGIN_PLATFORM_PARAM = "muzhiJhly"

--拇指聚合
GameConfig.accountURL = "http://muzhiJh.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://muzhiJh.tank.hundredcent.com/serverlist_tank.json"

GameConfig.downRootURL = "http://cdn.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://cdn.tank.hundredcent.com/version/tank_apk_hf.json"

function getPayCallBackUrl()
    return "http://muzhiJh.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=muzhiJhly"
end