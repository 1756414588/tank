
-- 创建角色

-- import("app.text.LoginText")
-- import("app.dm.ServerDM")
-- import("app.dm.WordsDM")

-- local AccountService = require("app.service.AccountService")
-- local RoleListView = import("app.listview.RoleListView")

local RoleScene = class("RoleScene", function()
    return display.newScene("RoleScene")
end)

function RoleScene:ctor()
    local bg = LoginBO.getLoadingBg()
    bg:setScale(GAME_X_SCALE_FACTOR)
    self:addChild(bg)
    self.bg = bg

	self:show()
end

function RoleScene:show()
    local abg = display.newScale9Sprite(IMAGE_COMMON .. "bg_dlg_1.png", display.cx, display.cy - 50)
    abg:setPreferredSize(cc.size(582, 587))
    self:addChild(abg)
    self.m_bg = abg

    local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(abg, -1)
    btm:setPosition(abg:getContentSize().width / 2, abg:getContentSize().height / 2 - 6)
    btm:setScaleY((abg:getContentSize().height - 70) / btm:getContentSize().height)

    local labelColor = cc.c3b(98,165,210)

    local tilte = ui.newTTFLabel({text = LoginText[53], font = G_FONT, size = FONT_SIZE_MEDIUM, x = self.m_bg:getContentSize().width / 2, y = self.m_bg:getContentSize().height - 26, align = ui.TEXT_ALIGN_CENTER}):addTo(self.m_bg)

    self.m_sexIndex = 1 -- 默认是男

    local function showChose()
    	if self.m_sexIndex == 1 then -- 男
    		self.m_choseSprite:setPosition(self.m_bg:getContentSize().width / 2 - 115, self.m_bg:getContentSize().height - 210)
    	else
    		self.m_choseSprite:setPosition(self.m_bg:getContentSize().width / 2 + 115, self.m_bg:getContentSize().height - 210)
    	end
    end

    local function onMaleCallback(tag, sender)
    	ManagerSound.playNormalButtonSound()
    	self.m_sexIndex = 1
    	showChose()
	end

    -- 男
    local bg = display.newSprite(IMAGE_COMMON .. "btn_head_normal.png")
    local btn = TouchButton.new(bg, nil, nil, nil, onMaleCallback):addTo(self.m_bg)
    btn:setPosition(self.m_bg:getContentSize().width / 2 - 115, self.m_bg:getContentSize().height - 210)

    local head = display.newSprite("image/item/h_1.jpg"):addTo(btn)
    head:setPosition(btn:getContentSize().width / 2, btn:getContentSize().height / 2)

    local tag = display.newSprite(IMAGE_COMMON .. "icon_sex_1.png"):addTo(self.m_bg)
    tag:setPosition(btn:getPositionX(), self.m_bg:getContentSize().height - 320)

    local function onFemaleCallback(tag, sender)
    	ManagerSound.playNormalButtonSound()
    	self.m_sexIndex = 2
    	showChose()
	end

    -- 女
    local bg = display.newSprite(IMAGE_COMMON .. "btn_head_normal.png")
    local btn = TouchButton.new(bg, nil, nil, nil, onFemaleCallback):addTo(self.m_bg)
    btn:setPosition(self.m_bg:getContentSize().width / 2 + 115, self.m_bg:getContentSize().height - 210)

    local head = display.newSprite("image/item/h_2.jpg"):addTo(btn)
    head:setPosition(btn:getContentSize().width / 2, btn:getContentSize().height / 2)

    local tag = display.newSprite(IMAGE_COMMON .. "icon_sex_2.png"):addTo(self.m_bg)
    tag:setPosition(btn:getPositionX(), self.m_bg:getContentSize().height - 320)

    -- 选中效果
    local chose = display.newSprite(IMAGE_COMMON .. "chose_5.png"):addTo(self.m_bg)
    self.m_choseSprite = chose

    showChose()

	local function onEdit(event, editbox)
    end

    local width = 300
    local height = UiUtil.getEditBoxHeight(FONT_SIZE_SMALL)

    local inputBg = display.newScale9Sprite(IMAGE_COMMON .. "btn_7_unchecked.png"):addTo(self.m_bg, 2)
    inputBg:setPreferredSize(cc.size(width + 20, height + 10))
    inputBg:setPosition(self.m_bg:getContentSize().width / 2 - 30, self.m_bg:getContentSize().height - 380)

    local input1 = ui.newEditBox({listener = onEdit, size = cc.size(width, height)}):addTo(self.m_bg, 2)
    input1:setFontColor(labelColor)
    input1:setMaxLength(10)
    input1:setPosition(self.m_bg:getContentSize().width / 2 - 30, self.m_bg:getContentSize().height - 380)
    self.input1 = input1

    self.curNameIndex_ = 1
	self.input1:setText(LoginMO.roleNames_[self.curNameIndex_])

	local normal = display.newSprite(IMAGE_COMMON .. "login/btn_random_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "login/btn_random_normal.png")
	local nxtBtn = MenuButton.new(normal, selected, nil, handler(self, self.onRandomName)):addTo(self.m_bg)
	nxtBtn:setPosition(self.m_bg:getContentSize().width / 2 + 175, self.m_bg:getContentSize().height - 380)

	-- 限制长度
	ui.newTTFLabel({text = LoginText[39], align = ui.TEXT_ALIGN_CENTER, size = FONTS_SIZE_SMALL, color = labelColor, x = self.m_bg:getContentSize().width / 2, y = self.m_bg:getContentSize().height - 430}):addTo(self.m_bg)

	--开始按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local okBtn = MenuButton.new(normal, selected, nil, handler(self, self.onOkCallback)):addTo(self.m_bg)
	okBtn:setLabel(LoginText[29])
	okBtn:setPosition(self.m_bg:getContentSize().width / 2, 25)

	-- local tablebg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_48.png")
	-- tablebg:setPreferredSize(CCSizeMake(633, 378))
	-- tablebg:setPosition(display.cx, display.cy)
	-- self:addChild(tablebg)

	-- local data = {}
	-- for i=1,24 do
	-- 	data[i] = i
	-- end

	-- local rect = CCRectMake(0, 0, 600, 300)
	-- local tableView = RoleListView.new(rect, data, 5)
	-- tableView:addEventListener("onItemClicked", handler(self, self.onItemClicked)) -- 点击商品详情
	-- tableView:setPosition(display.cx - 300, display.cy - 160)
	-- self:addChild(tableView,1)
	-- self.tableView = tableView


	-- local slider = tableView:createSlider(300, ccp(display.cx - 305, display.cy - 10))
	-- self:addChild(slider)	
end

-- function RoleScene:onExit()
-- end

-- function RoleScene:onItemClicked(event)
-- 	-- dump(event)
-- 	self.selectedId = event.data
-- end

function RoleScene:onRandomName(tag, sender)
	ManagerSound.playNormalButtonSound()

	self.curNameIndex_ = self.curNameIndex_ + 1
	if self.curNameIndex_ > #LoginMO.roleNames_ then
		self.curNameIndex_ = 0

		Loading.getInstance():show()

		LoginBO.asynGetRoleNames(function()
				Loading.getInstance():unshow()

				self.curNameIndex_ = 1

				self.input1:setText(LoginMO.roleNames_[self.curNameIndex_])
			end)
		return
	else
		self.input1:setText(LoginMO.roleNames_[self.curNameIndex_])
	end
end

function RoleScene:onOkCallback(tag, sender)
	ManagerSound.playNormalButtonSound()

    LoginBO.getRechargeBlack(function()
        if LoginBO.enableRecharge() == false then Toast.show(CommonText[887]) return end 

        self.selectedId = self.m_sexIndex  -- 创建时，头像默认和性别一直

        local nick = string.gsub(self.input1:getText()," ","")

        if nick == "" or nick == LoginText[30] then
            Toast.show(LoginText[30])
            return
        end

        if WordMO.isSensitiveWords(nick) then
            Toast.show(LoginText[38])
            return
        end

        local length = string.utf8len(nick)
        -- local length = string.utf8len(nick)
        -- gprint("length:", length)
        if length > NAME_MAX_LEN or length < NAME_MIN_LEN then
            Toast.show(string.format(LoginText[37], NAME_MAX_LEN, NAME_MIN_LEN))
            return
        end

        local ok = LoginBO.checkNickName(nick)
        if not ok then
            Toast.show(LoginText[40])  -- 角色昵称只能包含中文、英文和数字
            return
        end

        Loading.getInstance():show()

        LoginBO.asynCreateRole(nil, nick, self.selectedId, self.m_sexIndex)
     end)
end

return RoleScene