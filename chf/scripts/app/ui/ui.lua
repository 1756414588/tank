

-- -- start --

-- --------------------------------
-- -- 使用 TTF 字体创建文字显示对象，并返回 Label 对象。
-- -- @function [parent=#display] newTTFLabel
-- -- @param table params 参数表格对象
-- -- @return Label#Label ret (return value: cc.Label)  Label对象

-- --[[--

-- 使用 TTF 字体创建文字显示对象，并返回 Label 对象。

-- 可用参数：

-- -    text: 要显示的文本
-- -    font: 字体名，如果是非系统自带的 TTF 字体，那么指定为字体文件名
-- -    size: 文字尺寸，因为是 TTF 字体，所以可以任意指定尺寸
-- -    color: 文字颜色（可选），用 cc.c3b() 指定，默认为白色
-- -    align: 文字的水平对齐方式（可选）
-- -    valign: 文字的垂直对齐方式（可选），仅在指定了 dimensions 参数时有效
-- -    dimensions: 文字显示对象的尺寸（可选），使用 cc.size() 指定
-- -    x, y: 坐标（可选）

-- align 和 valign 参数可用的值：

-- -    cc.TEXT_ALIGNMENT_LEFT 左对齐
-- -    cc.TEXT_ALIGNMENT_CENTER 水平居中对齐
-- -    cc.TEXT_ALIGNMENT_RIGHT 右对齐
-- -    cc.VERTICAL_TEXT_ALIGNMENT_TOP 垂直顶部对齐
-- -    cc.VERTICAL_TEXT_ALIGNMENT_CENTER 垂直居中对齐
-- -    cc.VERTICAL_TEXT_ALIGNMENT_BOTTOM 垂直底部对齐

-- ~~~ lua

-- -- 创建一个居中对齐的文字显示对象
-- local label = display.newTTFLabel({
--     text = "Hello, World",
--     font = "Marker Felt",
--     size = 64,
--     align = cc.TEXT_ALIGNMENT_CENTER -- 文字内部居中对齐
-- })

-- -- 左对齐，并且多行文字顶部对齐
-- local label = display.newTTFLabel({
--     text = "Hello, World\n您好，世界",
--     font = "Arial",
--     size = 64,
--     color = cc.c3b(255, 0, 0), -- 使用纯红色
--     align = cc.TEXT_ALIGNMENT_LEFT,
--     valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
--     dimensions = cc.size(400, 200)
-- })

-- ~~~

-- ]]
-- -- end --

-- function display.newTTFLabel(params)
--     assert(type(params) == "table",
--            "[app.ui.ui.display] newTTFLabel() invalid params")

--     local text       = tostring(params.text)
--     local font       = params.font or display.DEFAULT_TTF_FONT
--     local size       = params.size or display.DEFAULT_TTF_FONT_SIZE
--     local color      = params.color or display.COLOR_WHITE
--     local textAlign  = params.align or cc.TEXT_ALIGNMENT_LEFT
--     local textValign = params.valign or cc.VERTICAL_TEXT_ALIGNMENT_TOP
--     local x, y       = params.x, params.y
--     local dimensions = params.dimensions or cc.size(0, 0)

--     assert(type(size) == "number",
--            "[framework.display] newTTFLabel() invalid params.size")

--     local label
--     if cc.FileUtils:getInstance():isFileExist(font) then
--         label = cc.Label:createWithTTF(text, font, size, dimensions, textAlign, textValign)
--     else
--         label = cc.Label:createWithSystemFont(text, font, size, dimensions, textAlign, textValign)
--     end

--     if label then
--         label:setColor(color)
--         if x and y then label:setPosition(x, y) end
--     end

--     return label
-- end

-- function display.createLabel(params)
--    if not params then params ={} 
--                       params.text = "" 
--                  end
--    if not params.dimensions  then params.dimensions = CCSizeMake(500,100) end
--    if not params.font then params.font = FONTS end 
--    if not params.size then params.size = FONTS_SIZE end 
--    return  ui.newTTFLabel(params)
-- end

