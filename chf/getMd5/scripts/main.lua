
function __G__TRACKBACK__(errorMessage)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
    print(debug.traceback("", 2))
    print("----------------------------------------")
end

--luajit编译脚本

luajit_compile = "F:/tank/develop/quick-cocos2d-x-2.2.6-release/bin/compile_scripts.bat"
--项目所在目录
-- proj_dir = "D:/dep/pro_2dx/ljws/"
--项目发布总目录(坦克)
proj_publish = "F:/tank/export/uc/"  --混服
-- proj_publish = "F:/tank/export/ly/" --联运
-- proj_publish = "F:/tank/export/ch_yh/" --草花硬核
-- proj_publish = "F:/tank/export/verify/" --版号
-- proj_publish = "F:/tank/export/verify_ch/" --草花版号
-- proj_publish = "F:/tank/export/tw/"  --台湾繁体
-- proj_publish = "F:/tank/export/en/"  --英文

-- proj_publish = "F:/tank/export/test/"  --测试

--发布版本号(发布的文件会在主目录+版本号的目录下)
ver = "3.6.4"

-- ver = "1.3.5"
--发布文件目录
export_dir = proj_publish .. "ver_" .. ver .. "/"

require("app.MyApp").new():run()