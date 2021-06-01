
Notify = require_ex("app.remote.Notify")
Request = require_ex("app.remote.Request")
NetRequest = require_ex("app.remote.NetRequest")

require_ex("app.remote.LocalRequest")

require("app.remote.SocketReceiver")  -- 使用scheduler，不能使用require_ex加载