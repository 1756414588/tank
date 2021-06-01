
require("config")
require("framework.init")
cc.utils = require("framework.cc.utils.init")

CCTexture2D:PVRImagesHavePremultipliedAlpha(true)

-- 不管模块modname是否加载过，都重新加载
function require_ex(modname)
	print(string.format("[MyApp] require_ex = %s", modname))
	package.loaded[modname] = nil
	package.preload[modname] = nil
	return require(modname)
end

-- 如果模块modname加载过，则重新加载
function reload_ex(modname)
	print(string.format("[MyApp] reload_ex = %s", modname))
	if package.loaded[modname] then
		package.loaded[modname] = nil
		return require(modname)
	end
end

-- 去除加载模块modname
function un_register(modname)
	print(string.format("[MyApp] un_register = %s", modname))
	package.loaded[modname] = nil
end

-- call Java method
function callJava(cls, method, sign, ...)
    print("class---------->", cls)
    print("method------->", method)
    local javaParams = clone({...})
    -- dump(javaParams, "javaParams-------------->")
    luaj.callStaticMethod(cls, method, javaParams, sign)
end

function callObjectC(cls, method, param, callback)
    -- print("call Object-C:", cls, method, param)
    local ok, ret = luaoc.callStaticMethod(cls, method, param)
    -- print("call result------->", ok, ret)
    if ok and callback ~= nil then callback(ret) end
end

local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
end

function MyApp:run()
	require_ex("app.Enter")
    Enter.startLogo()
end

return MyApp
