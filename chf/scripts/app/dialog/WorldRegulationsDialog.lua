-- 世界玩法

local Dialog = require("app.dialog.Dialog")
local WorldRegulationsDialog = class("WorldRegulationsDialog", Dialog)

function WorldRegulationsDialog:ctor(viewFor)
	WorldRegulationsDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 720)})
	self.m_viewFor = viewFor or 1

	cc.SpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("image/world/world.plist", "image/world/world.png")

	armature_add(IMAGE_ANIMATION .. "movie/tanke_caikuang.pvr.ccz", IMAGE_ANIMATION .. "movie/tanke_caikuang.plist", IMAGE_ANIMATION .. "movie/tanke_caikuang.xml")
end

function WorldRegulationsDialog:onEnter()
	WorldRegulationsDialog.super.onEnter(self)

	self:setTitle(CommonText[959][1])

	-- local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(542, 690))

	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local function createDelegate(container, index)
		if index == 1 then   --- 攻打敌人
			self:showAttackRegulations(container, index)
		elseif index == 2 then  ---资源采集
			self:showCollectionRegulations(container, index)
		elseif index == 3 then  --- 团队协防
			self:showTeamRegulations(container, index)
		end
		self:updateTips(container, index)
	end

	local function clickDelegate(container, index)

	end

	local pages = CommonText[960]

	local size = self:getBg():getContentSize()
	size.width = size.width - 60
	size.height = size.height - 135
	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = size.width / 2 + 30, y = size.height / 2 + 30, createDelegate = createDelegate, clickDelegate = clickDelegate, hideDelete = true}):addTo(self:getBg(), 2)
	pageView:setPageIndex(self.m_viewFor)
	self.m_pageView = pageView	
end

function WorldRegulationsDialog:showAttackRegulations(container, index)
	local armature = armature_create("tanke_caikuang"):addTo(container, 2)
	armature:setPosition(container:getContentSize().width/2, container:getContentSize().height - 200)
	armature:getAnimation():play("2",0, -1, 1)
end

function WorldRegulationsDialog:showCollectionRegulations(container, index)
	local armature = armature_create("tanke_caikuang"):addTo(container, 2)
	armature:setPosition(container:getContentSize().width/2, container:getContentSize().height - 200)
	armature:getAnimation():play("1",0, -1, 1)
end

function WorldRegulationsDialog:showTeamRegulations(container, index)
	local armature = armature_create("tanke_caikuang"):addTo(container, 2)
	armature:setPosition(container:getContentSize().width/2, container:getContentSize().height - 200)
	armature:getAnimation():play("3",0, -1, 1)
end

function WorldRegulationsDialog:updateTips( container, index )
	local label = ui.newTTFLabel({text=CommonText[961],color=COLOR[12], font = G_FONT, size = FONT_SIZE_SMALL+1, 
		align = ui.TEXT_ALIGN_CENTER}):addTo(container,3)
	label:setPosition(container:getContentSize().width/2, container:getContentSize().height - 30)
	local map = display.newSprite(IMAGE_COMMON .. "dituxxx.png"):addTo(container,1)
	map:setPosition(container:getContentSize().width/2, container:getContentSize().height - map:getContentSize().height/2 - 50)

	local regulations = CommonText.regulations[index]

	for i,v in ipairs(regulations) do
		local label = ui.newTTFLabel({text=v, font = G_FONT, size = FONT_SIZE_SMALL, 
			align = ui.TEXT_ALIGN_LEFT,dimensions = cc.size(430, 80)}):addTo(container,4)
		label:setAnchorPoint(cc.p(0,0.5))
		label:setPosition(50, (4-i) * 60)

		local icon = display.newSprite(IMAGE_COMMON .. "scroll_head_3.png"):addTo(label)
		icon:setPosition(-15, label:getContentSize().height/2)
	end
end

return WorldRegulationsDialog
