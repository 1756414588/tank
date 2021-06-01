--
-- Author: Your Name
-- Date: 2017-03-21 16:21:30
--

--新将领界面View
SCHOOL_VIEW_FOR_UI = 1
SCHOOL_VIEW_FOR_FORMAT = 2 -- 从设置阵型进入

local NewSchoolView = class("NewSchoolView", UiNode)

function NewSchoolView:ctor(buildingId, viewFor, kind)
	viewFor = viewFor or SCHOOL_VIEW_FOR_UI
	self.m_viewFor = viewFor
	self.kind = kind

	if self.m_viewFor == SCHOOL_VIEW_FOR_UI then
		NewSchoolView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	else
		NewSchoolView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_NONE)
	end

	self.m_build = BuildMO.queryBuildById(buildingId)
end

function NewSchoolView:onEnter()
	NewSchoolView.super.onEnter(self)
		
	self:setTitle(self.m_build.name)
	self:updatePage()--刷新page
	self.m_updateHerosHandler = Notify.register(LOCAL_HERO_AWAKE_EVENT, handler(self, self.onUpdatePage))

	--四个按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	heroPicBtn = MenuButton.new(normal, selected, nil, handler(self,self.openHeroPicView)):addTo(self:getBg())
	heroPicBtn:setPosition(self:getBg():getContentSize().width / 2 - 230,70)
	heroPicBtn:setLabel(CommonText[505][1])

	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	heroLotteryBtn = MenuButton.new(normal, selected, nil, handler(self,self.openLotteryHeroView)):addTo(self:getBg())
	heroLotteryBtn:setPosition(self:getBg():getContentSize().width / 2 - 75,70)
	heroLotteryBtn:setLabel(CommonText[505][2])

	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	heroDecomposeBtn = MenuButton.new(normal, selected, nil, handler(self,self.openBatchDecompose)):addTo(self:getBg())
	heroDecomposeBtn:setPosition(self:getBg():getContentSize().width / 2 + 75,70)
	heroDecomposeBtn:setLabel(CommonText[505][3])

	local normal = display.newSprite(IMAGE_COMMON .. "btn_9_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_9_selected.png")
	heroImproveBtn = MenuButton.new(normal, selected, nil, handler(self,self.openImproveView)):addTo(self:getBg())
	heroImproveBtn:setPosition(self:getBg():getContentSize().width / 2 + 230,70)
	heroImproveBtn:setLabel(CommonText[505][4])
end

function NewSchoolView:updatePage()
	local size = cc.size(GAME_SIZE_WIDTH - 12, GAME_SIZE_HEIGHT - 180)
	local pages = {CommonText[981][1],CommonText[981][2]}

	local function createDelegate(container, index)
		if index == 1 then  -- 普通
			HeroBO.getHeroEndTime(function ()
				self:showOrdinaryHero(container,index)
			end)
		elseif index == 2 then -- 觉醒
			self:showAwakeHero(container,index)
		end
	end

	local function clickDelegate(container, index)
	end

	local function clickBaginDelegate(index)
		return true
	end

	local pageView = MultiPageView.new(MULTIPAGE_STYLE_NORMAL, size, pages, {x = GAME_SIZE_WIDTH / 2, y = 34 + size.height / 2, createDelegate = createDelegate, clickDelegate = clickDelegate, clickBaginDelegate = clickBaginDelegate, hideDelete = true}):addTo(self:getBg(), 2)
	pageView:setPageIndex(1)
	self.m_pageView = pageView

	if HeroMO.awakeTip_  and HeroMO.awakeTip_ > 0 then
		UiUtil.showTip(self.m_pageView.m_noButtons[2],HeroMO.awakeTip_)
	end
	
end

function NewSchoolView:onUpdatePage()
	if not HeroMO.awakeTip_ then
		HeroMO.awakeTip_ = 0
	end
	HeroMO.awakeTip_ = HeroMO.awakeTip_ + 1
	self.m_pageView:reloadContainer(self.m_pageView:getPageIndex())
	UiUtil.showTip(self.m_pageView.m_noButtons[2],HeroMO.awakeTip_)
end

function NewSchoolView:showOrdinaryHero(container,index)
	local HeroTableView = require("app.scroll.HeroTableView")
	local view = HeroTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 130), index, self.m_viewFor, self.kind):addTo(container)
	self.view = view
	if view then
		view:setPosition(0, 70)
		view:reloadData()
	end

	local btnBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_27.png"):addTo(container)
	btnBg:setPreferredSize(cc.size(container:getContentSize().width, btnBg:getContentSize().height))
	btnBg:setPosition(container:getContentSize().width / 2,container:getContentSize().height - 25)
	--tableBtn
	self.btn1 = UiUtil.button("btn_59_normal.png", "btn_59_selected.png", nil, handler(self, self.showIndex))
   		:addTo(btnBg,0,1):pos(105,btnBg:getContentSize().height / 2 + 3)
  	self.btn1:selected()
  	self.btn1:selectDisabled()
  	local star1 = display.newSprite(IMAGE_COMMON .. "hero_star_1.png",self.btn1:getContentSize().width / 2,self.btn1:getContentSize().height / 2):addTo(self.btn1)

  	self.btn2 = UiUtil.button("btn_60_normal.png", "btn_60_selected.png", nil,handler(self, self.showIndex))
  	 	:addTo(btnBg,0,2):alignTo(self.btn1, 90)
  	self.btn2:unselected()
  	self.btn2:selectDisabled()
  	local star2 = display.newSprite(IMAGE_COMMON .. "hero_star_2.png",self.btn2:getContentSize().width / 2,self.btn2:getContentSize().height / 2):addTo(self.btn2)

  	self.btn3 = UiUtil.button("btn_61_normal.png", "btn_61_selected.png", nil,handler(self, self.showIndex))
  	 	:addTo(btnBg,0,3):alignTo(self.btn2, 120)
  	self.btn3:unselected()
  	self.btn3:selectDisabled()
  	local star3 = display.newSprite(IMAGE_COMMON .. "hero_star_3.png",self.btn3:getContentSize().width / 2,self.btn3:getContentSize().height / 2):addTo(self.btn3)

  	self.btn4 = UiUtil.button("btn_60_normal.png", "btn_60_selected.png", nil,handler(self, self.showIndex))
  	 	:addTo(btnBg,0,4):alignTo(self.btn3, 120)
  	self.btn4:setScaleX(-1)
  	self.btn4:unselected()
  	self.btn4:selectDisabled()
  	local star4 = display.newSprite(IMAGE_COMMON .. "hero_star_4.png",self.btn4:getContentSize().width / 2,self.btn4:getContentSize().height / 2):addTo(self.btn4)

  	self.btn5 = UiUtil.button("btn_59_normal.png", "btn_59_selected.png", nil,handler(self, self.showIndex))
  	 	:addTo(btnBg,0,5):alignTo(self.btn4, 90)
  	self.btn5:setScaleX(-1)
  	self.btn5:unselected()
  	self.btn5:selectDisabled()
  	local star5 = display.newSprite(IMAGE_COMMON .. "hero_star_5.png",self.btn5:getContentSize().width / 2,self.btn5:getContentSize().height / 2):addTo(self.btn5)
  	--四个按钮

  	local pageIdx = HeroMO.getLowestStar()
  	self:showIndex(self.subIdx or pageIdx)
end

function NewSchoolView:showAwakeHero(container)
	UiUtil.unshowTip(self.m_pageView.m_noButtons[2])
	UiUtil.unshowTip(self.m_pageView.m_yesButtons[2])
	HeroMO.awakeTip_ = 0
	local awakeHeroTableView = require("app.scroll.AwakeHeroTableView")
	local view = awakeHeroTableView.new(cc.size(container:getContentSize().width, container:getContentSize().height - 90), self.m_viewFor, self.kind):addTo(container)
	self.view = view
	if view then
		view:setPosition(0, 70)
		view:reloadData()
	end
end

function NewSchoolView:showIndex(tag,sender)
	for i=1,5 do
		if i == tag then
			self["btn"..i]:selected()
		else
			self["btn"..i]:unselected()
		end
	end
	self.subIdx = tag
	self.view:updateUI(tag + 1)

end

function NewSchoolView:openHeroPicView()
	ManagerSound.playNormalButtonSound()
	require("app.view.SchoolPicView").new():push()
end

function NewSchoolView:openLotteryHeroView()
	ManagerSound.playNormalButtonSound()
	require("app.view.LotteryHeroView").new():push()
end

function NewSchoolView:openBatchDecompose()
	ManagerSound.playNormalButtonSound()
	require("app.dialog.BatchDecomposeDialog").new(BATCH_DIALOG_FOR_HERO):push()
end

function NewSchoolView:openImproveView()
	ManagerSound.playNormalButtonSound()
	require("app.view.HeroImproveView").new():push()
end

function NewSchoolView:onExit()
	NewSchoolView.super.onExit(self)
	if self.m_updateHerosHandler then
		Notify.unregister(self.m_updateHerosHandler)
		self.m_updateHerosHandler = nil
	end
end

return NewSchoolView
