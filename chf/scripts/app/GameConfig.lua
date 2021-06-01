--
-- 游戏运行配置
-- GameConfig在进入游戏后只能require一次。除非整个游戏应该退出，不能unregister，否则会导致GameConfig中的参数丢失。
--

-- 游戏中是否可以打印
GAME_PRINT_ENABLE = true

GAME_INVALID_VALUE = 0xffffffff

G_FONT = "Arial Rounded MT Bold"
-- G_FONT = "hyzz.ttf"

FONT_SIZE_HUGE   = 34  -- 字体为超大
FONT_SIZE_BIG    = 30  -- 字体为大号
FONT_SIZE_MEDIUM = 26  -- 字体为中号
FONT_SIZE_SMALL  = 20  -- 字体为小号
FONT_SIZE_TINY   = 18  -- 字体为最小号
FONT_SIZE_LIMIT  = 16  

-- 是否使用联网测试
GLOBAL_NETWORK_ON = true
-- 网络消息是否编码，使用pb协议
GLOBAL_NETWORK_ENCODE = true

-- 网络请求是否是顺序的
-- 如果是顺序的则在一个请求发送后至少需要等待一定时间才能再次发送
GLOBAL_NETWORK_SEQUENCE = true

GameConfig = {}

--游戏版本(打包版本)
GameConfig.baseVersion = "2.0.1"
--游戏版本(当前更新版本)
GameConfig.version = "1.0.0"

GameConfig.versionManifest = "ver.manifest"
GameConfig.fileManifest = "cache.manifest"

--以下三项由播放器传入
GameConfig.environment = "debug"
--设备号
GameConfig.uuid = "00000000-2625-0b64-7b72-55e30033c587"

GameConfig.cpid = 10314

GameConfig.defaultRunParam = "self_client" .. "|" .. GameConfig.cpid

-- 登录平台的默认参数参数
GameConfig.loginPlatform = "self"

-- 登录账号URL
GameConfig.accountURL = ""
-- 获得分服ServerList的信息URL
GameConfig.areaURL = ""
-- game服务器URL
GameConfig.gameURL = ""

GameConfig.gameSocketURL = ""
-- game服务器端口
GameConfig.gamePort = 8080

-- --自有平台登录，创建用户等 auth.do
-- GameConfig.sdkURL = nil
-- GameConfig.downRootURL = nil
-- GameConfig.payBackURL = nil

-- 第三方登录的token
GameConfig.sdkLoginToken = ""

--身份令牌(自有平台登录后返回;如果是通过第三方平台登入，由该平台返回)
GameConfig.token = nil
GameConfig.keyId = nil
GameConfig.areaId = nil  -- 分服的id

-- --以下三项选区后由服务器给定
-- --游戏运行的服务器地址（不包括服务需拼合参数）
-- GameConfig.URL = nil
-- --websocket地址
-- GameConfig.socketURL = nil
-- --websocket端口
-- GameConfig.socketPort = nil

-- GameConfig.session = nil

--是否跳过维护状态
GameConfig.skipStop = false

--整包版本更新配置
GameConfig.versionURL = ""

--开启调试模式,更改代码直接打开界面即可，不需要重进游戏
GameConfig.debug = true

GameConfig.GM = true

--跳过检查更新
GameConfig.skipUpdate = true 
