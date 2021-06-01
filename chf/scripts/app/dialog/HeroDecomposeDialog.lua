--
-- Author: gf
-- Date: 2015-09-02 14:14:37
--


local Dialog = require("app.dialog.Dialog")
local HeroDecomposeDialog = class("HeroDecomposeDialog", Dialog)



function HeroDecomposeDialog:ctor(type,param)
	HeroDecomposeDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 460)})

	self.type = type
	if type == DECOMPOSE_TYPE_HERO then
		self.param = param.keyId
	else
		self.param = param
	end
end

function HeroDecomposeDialog:onEnter()
	HeroDecomposeDialog.super.onEnter(self)

	self:setTitle(CommonText[514][2])


	-- local type = self.type
	-- local param = self.param
	self.m_DecomposeHandler = Notify.register(LOCAL_HERO_DECOMPOSE_EVENT, handler(self, self.decomposeDoneHandler))

	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(550, 380))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_16.png"):addTo(self:getBg(), -1)
	infoBg:setPreferredSize(cc.size(510, 300))
	infoBg:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2)
	
	local titLab = ui.newTTFLabel({text = CommonText[516], font = G_FONT, size = FONT_SIZE_SMALL, 
		x = infoBg:getContentSize().width / 2, y = infoBg:getContentSize().height - 20, align = ui.TEXT_ALIGN_CENTER, color = COLOR[12]}):addTo(infoBg)
	titLab:setAnchorPoint(cc.p(0.5, 0.5))

	--分解可得到的物品
	local awards = HeroBO.getDecomposeAwards(self.type,self.param)
	self.awards = awards
	-- gdump(awards,"[HeroDecomposeDialog]..awards")

	for index = 1,#awards do
		local award = awards[index]
		local itemView = UiUtil.createItemView(award[1], award[2],{count = award[3]}):addTo(infoBg)
		itemView:setPosition(86 + (index - 1) % 2 * 220 ,200 - 120 * math.floor((index - 1) / 2))
		UiUtil.createItemDetailButton(itemView)
		local prop = PropMO.queryPropById(award[2])

		local name = ui.newTTFLabel({text = PropMO.getPropName(award[2]), font = G_FONT, size = FONT_SIZE_SMALL, 
			x = itemView:getPositionX() + itemView:getContentSize().width / 2 + 10, 
			y = itemView:getPositionY() + 20, 
			align = ui.TEXT_ALIGN_CENTER, 
			color = COLOR[prop.color]}):addTo(infoBg)
		name:setAnchorPoint(cc.p(0, 0.5))
		local count = ui.newTTFLabel({text = "+" .. award[3], font = G_FONT, size = FONT_SIZE_SMALL, 
			x = name:getPositionX(), 
			y = name:getPositionY() - 50, 
			align = ui.TEXT_ALIGN_CENTER, 
			color = COLOR[1]}):addTo(infoBg)
		count:setAnchorPoint(cc.p(0, 0.5))
	end

	--按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	cancelBtn = MenuButton.new(normal, selected, nil, handler(self,self.cancelHandler)):addTo(self:getBg())
	cancelBtn:setPosition(self:getBg():getContentSize().width / 2 - 150,30)
	cancelBtn:setLabel(CommonText[515][1])

	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	decomposeBtn = MenuButton.new(normal, selected, nil, handler(self,self.decomposeHandler)):addTo(self:getBg())
	decomposeBtn:setPosition(self:getBg():getContentSize().width / 2 + 150,30)
	decomposeBtn:setLabel(CommonText[515][2])
end



function HeroDecomposeDialog:cancelHandler()
	ManagerSound.playNormalButtonSound()
	self:pop()
end

function HeroDecomposeDialog:decomposeDoneHandler()
	self:pop()
end

function HeroDecomposeDialog:decomposeHandler(tag, sender)
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	HeroBO.asynDecompose(function()
		Loading.getInstance():unshow()
		end, self.type, self.param)
end



function HeroDecomposeDialog:onExit()
	HeroDecomposeDialog.super.onExit(self)

	if self.m_DecomposeHandler then
		Notify.unregister(self.m_DecomposeHandler)
		self.m_DecomposeHandler = nil
	end
end


return HeroDecomposeDialog