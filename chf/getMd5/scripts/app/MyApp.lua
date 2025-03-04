
require("config")
require("framework.init")
require("framework.shortcodes")
require("framework.cc.init")

local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
end

function MyApp:run()
    mk = require("mkflist")
    mk:run("files")
    CCFileUtils:sharedFileUtils():addSearchPath("res/")
    self:enterScene("MainScene")
end

return MyApp
