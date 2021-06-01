--
-- Author: Gongfan
-- Date: 2014-11-11 16:19:40
-- 激活码

require("app.text.LoginText")

-- import("app.dm.ServerDM")
-- import("app.utils.AreaHelper")

-- local AccountService = require("app.service.AccountService")

-- local uiPath = IMAGE_COMMON .. "login/"
-- local winSize = CCDirector:sharedDirector():getWinSize()

local ActivateScene = class("ActivateScene", function()
    return display.newScene("ActivateScene")
end)

function ActivateScene:ctor()
    gprint("ActivateScene:ctor ... ")
    local bg = LoginBO.getLoadingBg()
    self:addChild(bg)
    self.bg = bg
    
end

function ActivateScene:onEnter()
	self:show()

    -- self:performWithDelay(function()
    --     ManagerUI.addKeypadBack()
    -- end, 0.5)
end

function ActivateScene:show()
    --加载资源
    -- armature_add("image/animation/effect/ui_logo.pvr.ccz", "image/animation/effect/ui_logo.plist", "image/animation/effect/ui_logo_light.xml")

 --    local lightEffect = CCArmature:create("guoming_logo_guang_mc")
 --    lightEffect:retain()
 --    lightEffect:setPosition(GAME_ORIGIANL_X + GAME_SIZE_WIDTH - lightEffect:getContentSize().width / 2 - 60, GAME_ORIGIANL_Y + GAME_SIZE_HEIGHT - lightEffect:getContentSize().height / 2 - 10)
 --    lightEffect:getAnimation():playWithIndex(0)
 --    lightEffect:connectMovementEventSignal(function(movementType, movementID) end)
 --    self:addChild(lightEffect)

    local bg = display.newScale9Sprite("image/common/bg_dlg_1.png", display.cx, display.cy - 20):addTo(self)
    bg:setPreferredSize(CCSizeMake(bg:getContentSize().width, 500))

	local infoLab = ui.newTTFLabel({text = LoginText[44], font = G_FONT, size = FONT_SIZE_MEDIUM, dimensions = CCSizeMake(440,60), align = kCCTextAlignmentLeft}):addTo(bg)
	infoLab:setAnchorPoint(ccp(0, 0.5))
	infoLab:setColor(ccc3(255,255,255))
	infoLab:setPosition(bg:getContentSize().width / 2 - 220, bg:getContentSize().height - 120)

	local function onEdit(event, editbox)
	--    if eventType == "return" then
	--    end
    end

    local width = 400
    local height = UiUtil.getEditBoxHeight(FONT_SIZE_SMALL)

    local inputBg = display.newScale9Sprite(IMAGE_COMMON .. "btn_7_unchecked.png"):addTo(bg, 2)
    inputBg:setPreferredSize(cc.size(width + 20, height + 10))
    inputBg:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height / 2)

    local inputDesc = ui.newEditBox({listener = onEdit, size = cc.size(width, height)}):addTo(bg)
	inputDesc:setFontColor(cc.c3b(0, 0, 0))
	inputDesc:setFontSize(FONT_SIZE_MEDIUM)
	inputDesc:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height / 2)
	self.inputDesc = inputDesc

    -- (请输入激活码)
	local cueLab = ui.newTTFLabel({text = LoginText[45], font = G_FONT, size = FONT_SIZE_MEDIUM}):addTo(bg)
	cueLab:setColor(ccc3(255,0,0))
	cueLab:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height / 2 - 50)
	self.cueLab = cueLab

    -- 取消
    local normal = display.newSprite(IMAGE_COMMON .. "btn_5_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_5_selected.png")
	local cancelBtn = MenuButton.new(normal, selected, nil, handler(self, self.onCancelCallback)):addTo(bg)
    cancelBtn:setLabel(LoginText[57])
	cancelBtn:setPosition(148, 80)

    -- 确定
    local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
    local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
    local confirmBtn = MenuButton.new(normal, selected, nil, handler(self,self.onConfirmCallback)):addTo(bg)
    confirmBtn:setLabel(LoginText[56])
    confirmBtn:setPosition(bg:getContentSize().width - 148, 80)

	local versionLab = ui.newTTFLabel({text = "Version:" .. GameConfig.version, font = G_FONT, size = FONT_SIZE_SMALL, x = display.width - 180, y = 50, color = cc.c3b(0, 0, 0)}):addTo(self)
end

function ActivateScene:onExit()
    self:removeAllChildrenWithCleanup(true)
    -- armature_remove("image/animation/effect/ui_logo.pvr.ccz", "image/animation/effect/ui_logo.plist", "image/animation/effect/ui_logo_light.xml")
    -- ManagerUI.clearImageCache()
end

function ActivateScene:onConfirmCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	
	local code = string.gsub(self.inputDesc:getText()," ","")
	if code == "" then
        self.cueLab:setString(LoginText[45])
        return
    end

    local length = string.len(code)

    if string.find(code,"%d") == nil or length ~= 15 then
    	self.cueLab:setString(LoginText[47])
    	return
    end

    local function doneActive()
        Enter.startArea()
    end

    LoginBO.asynAccountActivate(doneActive, code)
end

function ActivateScene:onCancelCallback()
    ManagerSound.playNormalButtonSound()

	Enter.startLogin()
end

return ActivateScene