--
-- Author: Xiaohang
-- Date: 2016-09-06 14:45:12
--
-----------------------------------内容条界面---------
local ContentTableView = class("ContentTableView", TableView)

function ContentTableView:ctor(size)
	ContentTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(size.width, 140)
	self.list = {}
end

function ContentTableView:createCellAtIndex(cell, index)
	ContentTableView.super.createCellAtIndex(self, cell, index)
	local infoBg = UiUtil.sprite9("info_bg_82.png", 60,50,14,13,590,140):addTo(cell):pos(self.m_cellSize.width/2,self.m_cellSize.height/2)
	local data = self.list[index]
	local rd = RebelMO.queryHeroById(data.heroPick)
	local hd = HeroMO.queryHero(rd.associate)
	RebelMO.getImage(data.heroPick):addTo(cell):pos(100,self.m_cellSize.height / 2):scale(0.7)
	local t = UiUtil.label(hd.heroName .." Lv."..data.rebelLv,nil,COLOR[data.type+1]):addTo(cell):align(display.LEFT_CENTER,170,self.m_cellSize.height / 2+20)
	local pos = WorldMO.decodePosition(data.pos)
	UiUtil.label(" ("..  pos.x .."," .. pos.y ..")",nil,COLOR[2]):rightTo(t)
	local c = nil
	if data.state == 0 then c = COLOR[2]
	elseif data.state == 2 then c = COLOR[6] end
	UiUtil.label(CommonText[20121][data.state+1],nil,c):addTo(cell):align(display.LEFT_CENTER,170,self.m_cellSize.height / 2 - 20)

	local normal = display.newSprite(IMAGE_COMMON .. "btn_11_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_11_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_9_disabled.png")
	local useBtn = CellMenuButton.new(normal, selected, disabled, handler(self, self.goto))
	useBtn:setLabel(CommonText[20122])
	useBtn:setEnabled(data.state == 1)
	useBtn.pos = pos
	cell:addButton(useBtn, self.m_cellSize.width - 100, self.m_cellSize.height / 2)

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(cell)
	line:setPreferredSize(cc.size(560, line:getContentSize().height))
	line:setPosition(self.m_cellSize.width / 2, 0)
	return cell
end

function ContentTableView:goto(tag, sender)
	UiDirector.popMakeUiTop("HomeView")
	UiDirector.getUiByName("HomeView"):showChosenIndex(MAIN_SHOW_WORLD)
	UiDirector.getTopUi():getCurContainer():onLocate(sender.pos.x,sender.pos.y)
end

function ContentTableView:numberOfCells()
	return #self.list
end

function ContentTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function ContentTableView:updateUI(list)
	self.list = list
	for idx=1,#self.list do
		local pos = WorldMO.decodePosition(self.list[idx].pos)
		local time = WorldBO.getMarchTime(pos, cc.p(WorldMO.pos_.x, WorldMO.pos_.y))
		self.list[idx].time = time
	end

	function sortFun(a,b)
		if a.state == b.state then
			return a.time < b.time
		else
			return a.state > b.state
		end
	end
	table.sort(self.list,sortFun)

	self:reloadData()
end

function ContentTableView:onBack(tag,sender)
	ExerciseBO.fightReport(sender.key)
end

-----------------------------------总览界面-----------
local RebelInfo = class("RebelInfo",function ()
	return display.newNode()
end)

function RebelInfo:ctor(width,height,index)
	self.m_UpgradeHandler = Notify.register(LOCAL_REBEL_BOSS_UPDATA, handler(self, self.onUpgradeUpdate))

	self:size(width,height)
	self.list = {RebelBO.data.unitRebels,RebelBO.data.guardRebels,RebelBO.data.leaderRebels}
	local t = UiUtil.label(CommonText[10067][1],nil,cc.c3b(125,125,125)):addTo(self):align(display.LEFT_CENTER,40,height-25)
	self.state = UiUtil.label(CommonText[RebelBO.data.state == 0 and 871 or 20116],nil,COLOR[RebelBO.data.state == 0 and 6 or 2]):rightTo(t)

	UiUtil.label(CommonText[20117] .. RebelBO.data.killNum .."/5",26,cc.c3b(227,236,23)):alignTo(t,280)
	UiUtil.button("btn_detail_normal.png", "btn_detail_selected.png", nil, function()
			ManagerSound.playNormalButtonSound()
			require("app.dialog.DetailTextDialog").new(DetailText.rebelDetail):push() 
		end):addTo(self):pos(580,height-45):setScale(0.8)

	local function onOpenServerFixed()
		if self.m_bossData then
			local pos = WorldMO.decodePosition(self.m_bossData.pos)
			UiDirector.popMakeUiTop("HomeView")
			UiDirector.getUiByName("HomeView"):showChosenIndex(MAIN_SHOW_WORLD)
			UiDirector.getTopUi():getCurContainer():onLocate(pos.x,pos.y)
		end
	end
	-- 叛军BOSS
	local bossData = RebelBO.data.bossRebels[1]
	self.m_bossData = bossData
	local normal = display.newSprite(IMAGE_COMMON .. "btn_rebel_boss.png")
	local bossBtn = ScaleButton.new(normal, onOpenServerFixed):addTo(self)
	bossBtn:setPosition(500,height-65)
	bossBtn:setScale(0.8)
	bossBtn:run{
		"rep",
		{
			"seq",
			{"delay",math.random(1,3)},
			{"rotateTo",0,-10},
			{"rotateTo",0.1,10},
			{"rotateTo",0.1,-10},
			{"rotateTo",0.5,0,"ElasticOut"}
		}
	}
	self.m_bossBtn = bossBtn
	self.m_bossBtn:setVisible(false)
	if bossData then
		self.m_bossBtn:setVisible(bossData.state == 1)
	end


	t = UiUtil.label(CommonText[20118],nil,cc.c3b(125,125,125)):alignTo(t,-26,1)
	self.time = UiUtil.label("00m:00s",nil,COLOR[2]):rightTo(t)
	self.left = UiUtil.label(CommonText[20119],nil,cc.c3b(125,125,125)):alignTo(t,-26,1)
	self:showLeft()
	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_24.png"):addTo(self)
	line:setPreferredSize(cc.size(width, line:getContentSize().height))
	line:setPosition(width / 2, height - 118)
	display.newSprite(IMAGE_COMMON.."info_bg_27.png"):addTo(self):pos(display.cx-7,height-122)
	--tab按钮
    self.btn1 = UiUtil.button("btn_53_normal.png", "btn_53_selected.png", nil, handler(self,self.showIndex),CommonText[20120][1])
   		:addTo(self,0,1):pos(132,height-120)
  	self.btn1:selected()
  	self.btn1:selectDisabled()

  	self.btn2 = UiUtil.button("btn_54_normal.png", "btn_54_selected.png", nil, handler(self,self.showIndex),CommonText[20120][2])
  	 	:addTo(self,0,2):alignTo(self.btn1, 184)
  	self.btn2:unselected()
  	self.btn2:selectDisabled()

  	self.btn3 = UiUtil.button("btn_53_normal.png", "btn_53_selected.png", nil, handler(self,self.showIndex),CommonText[20120][3])
  	 	:addTo(self,0,3):alignTo(self.btn2, 184)
  	self.btn3:setScaleX(-1)
  	self.btn3.m_label:setScaleX(-1)
  	self.btn3:unselected()
  	self.btn3:selectDisabled()
	--内容
	local view = ContentTableView.new(cc.size(600, height-145),kind)
		:addTo(self):pos((width-600)/2,-5)
	self.view = view

	--刷新时间
	local function tick()
		local left = RebelBO.data.changeTime - ManagerTimer.getTime()
		if left <= 0 or RebelBO.data.state == 0 then 
			left = 0
			self.time:stopAllActions()
			RebelBO.data.state = 0
			self.state:setString(CommonText[RebelBO.data.state == 0 and 871 or 20116])
			self.state:setColor(COLOR[RebelBO.data.state == 0 and 6 or 2])
			for k,v in ipairs(self.list) do
				for m,n in ipairs(v) do
					if n.state == 1 then
						n.state = 2
					end
				end
			end
			self:showIndex(self.tag)
		end
		self.time:setString(string.format("%02dm:%02ds",math.floor(left/60),left%60))
	end
	self:showIndex(index or 1)
	self.time:performWithDelay(tick, 1, 1)
	tick()

end

function RebelInfo:showLeft()
	self.left:removeAllChildren()
	local t = UiUtil.label(CommonText[20120][1],nil,COLOR[2]):addTo(self.left):align(display.LEFT_CENTER,self.left:width()+5,self.left:height()/2)
	t = UiUtil.label("("):rightTo(t)
	t = UiUtil.label(RebelBO.data.restUnit .."/",nil,COLOR[2]):rightTo(t)
	t = UiUtil.label(#RebelBO.data.unitRebels ..")"):rightTo(t)
	t = UiUtil.label(CommonText[20120][2],nil,COLOR[3]):rightTo(t,10)
	t = UiUtil.label("("):rightTo(t)
	t = UiUtil.label(RebelBO.data.restGuard .."/",nil,COLOR[3]):rightTo(t)
	t = UiUtil.label(#RebelBO.data.guardRebels ..")"):rightTo(t)
	t = UiUtil.label(CommonText[20120][3],nil,COLOR[4]):rightTo(t,10)
	t = UiUtil.label("("):rightTo(t)
	t = UiUtil.label(RebelBO.data.restLeader .."/",nil,COLOR[4]):rightTo(t)
	t = UiUtil.label(#RebelBO.data.leaderRebels ..")"):rightTo(t)
end

function RebelInfo:showIndex(tag,sender)
	if tag == self.tag then return end
	for i=1,3 do
		if i == tag then
			self["btn"..i]:selected()
		else
			self["btn"..i]:unselected()
		end
	end
	self.tag = tag
	UiUtil.checkScrollNone(self.view,self.list[tag])
	self.view:updateUI(self.list[tag])
end

function RebelInfo:onUpgradeUpdate(event)
	if self.m_bossBtn then
		self.m_bossData = PbProtocol.decodeRecord(event.obj.param)
		self.m_bossBtn:setVisible(self.m_bossData.state == 1) --状态为1.表述未击杀
	end
end

function RebelInfo:onExit()
	RebelInfo.super.onExit(self)
	
	if self.m_UpgradeHandler then
		Notify.unregister(self.m_UpgradeHandler)
		self.m_UpgradeHandler = nil
	end
end


return RebelInfo