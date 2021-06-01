--
-- Author: Xiaohang
-- Date: 2016-04-26 18:52:31
--

--额外扩展，简化api
-- Node
local Node = cc.Node

function Node:pos(x, y)
    if not x then
        return {x = self:x(), y = self:y()}
    end
    if y then
        self:setPosition(x, y)
    else
        self:setPosition(x)
    end
    return self
end

function Node:alignTo(n, len, isVertical)
    self:setAnchorPoint(n:getAnchorPoint())
    local x = n:x()
    local y = n:y()
    if isVertical then
        self:pos(n:x(), n:y() + len)
    else
        self:pos(n:x() + len, n:y())
    end
    if not self:getParent() then
        self:addTo(n:getParent())
    end
    return self
end

function Node:center()
    local parent = self:getParent()
    if not parent or parent:width()==0 then
        self:setPosition(display.cx, display.cy)
    else
        self:setPosition(parent:width()/2,parent:height()/2)
    end
    return self
end

--额外扩展

--紧接着对齐
function Node:rightTo(t,ex)
    local align = t:getAnchorPoint()
    self:align(display.LEFT_CENTER, t:x() + (1-align.x)*t:width() + (ex or 0), t:y())
    if not self:getParent() then
        self:addTo(t:getParent())
    end
    return self
end

--紧接着对齐
function Node:leftTo(t,ex)
    local align = t:getAnchorPoint()
    self:align(display.RIGHT_CENTER, t:x() - align.x*t:width() - (ex or 0), t:y())
    if not self:getParent() then
        self:addTo(t:getParent())
    end
    return self
end

function Node:x(v)
    if v ~= nil then
        self:setPositionX(v)
        return self
    end
    return self:getPositionX()
end

function Node:y(v)
    if v ~= nil then
        self:setPositionY(v)
        return self
    end
    return self:getPositionY()
end

function Node:width(v)
    if v ~= nil then
        return self:size(v,self:height())
    end
    return self:getContentSize().width
end

function Node:height(v)
    if v ~= nil then
        return self:size(self:width(),v)
    end

    return self:getContentSize().height
end

function Node:scaleY(v)
    if v then
        self:setScaleY(v)
    else
        return self:getScaleY()
    end
    return self
end

function Node:scaleX(v)
    if v then
        self:setScaleX(v)
    else
        return self:getScaleX()
    end
    return self
end

function Node:scaleTX(width)
    return self:scaleX(width/self:width())
end

function Node:scaleTY(height)
    return self:scaleY(height/self:height())
end

--冒泡排序算法
function table.bubble(arr,comp)
    for i=1,table.getn(arr) do
        for j=i+1,table.getn(arr) do
            if comp(arr[j],arr[i]) then
                arr[i],arr[j]=arr[j],arr[i]
            end
        end
    end
end

function Node:performWithDelay(callback, delay, forever)
    local action = transition.sequence({
        cc.DelayTime:create(delay),
        cc.CallFunc:create(callback),
    })
    if forever then
        action = self:runAction(cc.RepeatForever:create(action))
    else
        action = self:runAction(action)
    end
    return action
end

function Node:drawBoundingBox(color,bordersize)
    local _color = color or ccc4f(1, 0, 0, 1)
    local _bordersize = bordersize or 0.5
    local box = self:boundingBox()
    local ___scale = self:getScale()
    local size = _bordersize / ___scale
    local ___width = box.size.width / ___scale
    local ___height = box.size.height / ___scale
    local draw = cc.DrawNode:create()
    draw:drawSegment(cc.p(0,0), cc.p(___width,0), size , _color)
    draw:drawSegment(cc.p(0,0), cc.p(0,___height), size , _color)
    draw:drawSegment(cc.p(0,___height), cc.p(___width,___height), size , _color)
    draw:drawSegment(cc.p(___width,0), cc.p(___width,___height), size , _color)
    self:addChild(draw)
end

local action_map = {
    MOVETO           =  CCMoveTo,
    MOVEBY           =  CCMoveBy,
    ROTATETO         =  CCRotateTo,
    ROTATEBY         =  CCRotateBy,
    SCALETO          =  CCScaleTo,
    SCALEBY          =  CCScaleBy,
    FADEIN           =  CCFadeIn,
    FADEOUT          =  CCFadeOut,
    FADETO           =  CCFadeTo,
    SHOW             =  CCShow,
    HIDE             =  CCHide,
    REMOVE           =  CCRemoveSelf,
    CALL             =  CCCallFunc,
    DELAY            =  CCDelayTime,
    FLIPX            =  CCFlipX,
    FLIPY            =  CCFlipY,
    CAMERA           =  CCOrbitCamera,
    PLACE            =  CCPlace,
    REUSEGRID        =  CCReuseGrid,
    TOGGLEVISIBILITY =  CCToggleVisibility,
    JUMPBY           =  CCJumpBy,
    PROGRESSTO       =  CCProgressTo,
    PROGRESSFROMTO   =  CCProgressFromTo,
    REVERSETIME      =  CCReverseTime,
    SKEWTO           =  CCSkewTo,
    TINTTO           =  CCTintTo,
    TINTBY           =  CCTintBy,
    SHAKY3D          =  CCShaky3D,--{"Shaky3D",1,CCSize(10,10),1,false}
    SHAKYTILES3D     =  CCShakyTiles3D,--{"SHAKYTILES3D",10,CCSize(10,10),1,false}
    WAVES            =  CCWaves,--{"WAVES",10,CCSize(10,10),10,10,true,true}
    WAVES3D          =  CCWaves3D,--{"WAVES3d",10,CCSize(10,10),10,10}
    FLIPX3D          =  CCFlipX3D,
    FLIPY3D          =  CCFlipY3D,
    PAGETURN3D       =  CCPageTurn3D,
    LENS3D           =  CCLens3D,
}

local action_ease = {
    BACKIN           =  CCEaseBackIn,
    BACKINOUT        =  CCEaseBackInOut,
    BACKOUT          =  CCEaseBackOut,
    BOUNCE           =  CCEaseBounce,
    BOUNCEIN         =  CCEaseBounceIn,
    BOUNCEINOUT      =  CCEaseBounceInOut,
    BOUNCEOUT        =  CCEaseBounceOut,
    ELASTIC          =  CCEaseElastic,
    ELASTICIN        =  CCEaseElasticIn,
    ELASTICINOUT     =  CCEaseElasticInOut,
    ELASTICOUT       =  CCEaseElasticOut,
    EXPONENTIALIN    =  CCEaseExponentialIn,
    EXPONENTIALINOUT =  CCEaseExponentialInOut,
    EXPONENTIALOUT   =  CCEaseExponentialOut,
    IN               =  CCEaseIn,
    INOUT            =  CCEaseInOut,
    OUT              =  CCEaseOut,
    RATEACTION       =  CCEaseRateAction,
    SINEIN           =  CCEaseSineIn,
    SINEINOUT        =  CCEaseSineInOut,
    SINEOUT          =  CCEaseSineOut
}
local action_mutil = {
    SEQ  = CCSequence,
    SPA  = CCSpawn,
}
local function createAction(map)
    local key = string.upper(map[1])

    -- 循环
    if "REP" == key then
        return CCRepeatForever:create(createAction(map[2]))
    elseif "REPC" == key then -- 循环次数
        return CCRepeat:create(createAction(map[3]),map[2])
    end

    -- 多个效果
    if action_mutil[key] then
        local arr = CCArray:create()
        for i = 2,#map do
            arr:addObject(createAction(map[i]))
        end
        return action_mutil[key]:create(arr)
    end

    -- 正常缓类
    local cls1,cls2,j,param1,param2 = nil
    cls1 = key
    cls2 = nil
    -- 查找是否有缓类
    param1 = false
    param2 = nil
    for i = 2,#map do
        if type(map[i]) == "string" then
            param1 = true
            j = i
            cls2 = string.upper(map[i])
            break
        end
    end
    -- 拷贝参数
    if param1 then
        param1 = {}
        param2 = {}
        for i = 2,#map do
            if i < j then
                table.insert(param1,map[i])
            elseif i > j then
                table.insert(param2,map[i])
            end
        end
    else
        param1 = {}
        for i = 2,#map do
            table.insert(param1,map[i])
        end
    end

    -- 创建action
    assert(action_map[cls1] ~= nil,cls1 .. "类不存在")
    cls1 = action_map[cls1]
    j = cls1:create(unpack(param1))
    -- EASE 类
    if cls2 then
        assert(action_ease[cls2] ~= nil,cls2 .. "类不存在")
        cls2 = action_ease[cls2]
        j = cls2:create(j,unpack(param2))
    end
    return j
end

--[[
单个
{"moveby",5.3,ccp(500,0)}
有EASE的类,ease参数和普通action一样，可以后面跟参数
{"moveby",5.3,ccp(500,0),"elasticout"}
队列 
run({"seq",{"delay",1},{"moveby",5.3,ccp(500,0)},{"scaleto",5.3,100,0}})
并列
run({"spa",{"delay",1},{"moveby",5.3,ccp(500,0)},{"scaleto",5.3,100,0}})
循环
run({"rep",{"delay",1},{"moveby",5.3,ccp(500,0)},{"scaleto",5.3,100,0}})
三合一,停1秒后同时移动和缩放（移动是带EASE）,然后一直循环
run({
        "rep",
        {
            "seq",
            {"delay",1},
            {
                "spa",
                {"moveby",5.3,ccp(500,0),"elasticout"},
                {"scaleto",5.3,100,0}
            }
        }
    })
--]]

function Node:run(v)
    if not v or type(v) ~= "table" then
        return self
    end
    local action = createAction(v)
    self:runAction(action)
    return self,action
end
