LOGIN_PLATFORM_PARAM = nil
LOGIN_PLATFORM_PARAM_QQ = "chSq2"
LOGIN_PLATFORM_PARAM_WX = "chWx2"

--拇指玩客户端
GameConfig.accountURL = "http://tencent-caohua.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://tencent-caohua.hundredcent.com/serverlist_tank.json"
GameConfig.downRootURL = "http://cdn.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://cdn.tank.hundredcent.com/version/tank_apk_hf.json"


function getPayCallBackUrl()
    return "http://tencent-caohua.hundredcent.com:9200/tank_account/account/payCallback.do?plat=" .. LOGIN_PLATFORM_PARAM
end