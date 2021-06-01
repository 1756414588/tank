--
-- Author: xiaoxing
-- Date: 2016-11-16 11:16:37
--
local item_color = {5,4,3,2,1}
local item_pendent = {{17,18,19},{20,21,22}}
local CrossCelebrity = class("CrossCelebrity",function ()
	return display.newNode()
end)

function CrossCelebrity:ctor(width,height,data,kind)
	self:size(width,height)
	-- local frame = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_11.png"):addTo(self)
	-- frame:setPreferredSize(cc.size(width - 30, height))
	-- frame:setCapInsets(cc.rect(130, 40, 1, 1))
	-- frame:setPosition(width/2,height - frame:height()/2 - 50)
	local frame = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self)
	frame:setPreferredSize(cc.size(width - 30, height - 50))
	frame:setPosition(width/2,height - frame:height()/2 - 60)
	frame = display.newClippingRegionNode(cc.rect(0,0,frame:width(),frame:height()))
		:addTo(frame)
	self.timeLabel = UiUtil.label("",26):addTo(self):pos(self:width()/2,88)
	self.backBtn = UiUtil.button("btn_2_normal.png","btn_2_selected.png",nil,handler(self,self.toDetail),CommonText[30053])
		:addTo(self):pos(self:width()/2,35)
	self.frame = frame
	self.data = data
	self.kind = kind or ACTIVITY_CROSS_WORLD
	local t = display.newSprite(IMAGE_COMMON.."info_bg_27.png"):addTo(self):pos(display.cx-7,height-30)
	self.titles = {1,2,3,4,5}
	if self.kind == ACTIVITY_CROSS_WORLD then
		--tab按钮
	    self.btn1 = UiUtil.button("btn_55_normal.png", "btn_55_selected.png", nil, handler(self,self.showIndex),CommonText[30012][1])
	   		:addTo(self,0,1):pos(172,height-30)
	  	-- self.btn1:selected()

	  	self.btn2 = UiUtil.button("btn_55_normal.png", "btn_55_selected.png", nil, handler(self,self.showIndex),CommonText[30012][2])
	  	 	:addTo(self,0,2):alignTo(self.btn1, 280)
	  	-- self.btn2:unselected()
	  	self.btn2:setScaleX(-1)
	  	self.btn2.m_label:setScaleX(-1)

	  	self:showIndex(1)
	elseif self.kind == ACTIVITY_CROSS_PARTY then
		self.titles = {1,2,3,6,7}
		self.backBtn:hide()
		UiUtil.label(string.format(CommonText[30055],self.data.keyId) .. CommonText[20148][self.kind],28,cc.c3b(199,199,199))
			:addTo(t):center()
		self.tag = 2
		self:showDetail(self.data.crossFame)
		self.timeLabel:y(30)
	end
end

function CrossCelebrity:showIndex(tag,sender)
	if tag == self.tag then return end
	for i=1,2 do
		if i == tag then
			self["btn"..i]:selected()
		else
			self["btn"..i]:unselected()
		end
	end
	self.tag = tag
	self:showDetail(self.data.crossFame[tag])
end

function CrossCelebrity:showDetail(data)
	self.frame:removeAllChildren()
	local t = display.newSprite(IMAGE_COMMON .. (self.tag == 1 and "bg_battle_fail.jpg" or "bg_battle_succ.jpg"))
			:addTo(self.frame):align(display.LEFT_TOP, 0, self.frame:height())
	t:setOpacity(51)
	local data = data
	if self.kind == ACTIVITY_CROSS_WORLD then
		data = PbProtocol.decodeArray(data.famePojo)
	end
	--头像
	self:createHead(1, data[1]):addTo(self.frame):pos(self:width()/2,self.frame:height()-125)
	self:createHead(2, data[2]):addTo(self.frame):pos(self:width()/2-180,self.frame:height()-205)
	self:createHead(3, data[3]):addTo(self.frame):pos(self:width()/2+180,self.frame:height()-285)
	self:createHead(4, data[4]):addTo(self.frame):pos(self:width()/2-100,self.frame:height()-515)
	self:createHead(5, data[5]):addTo(self.frame):pos(self:width()/2+100,self.frame:height()-515)

	local bt = string.gsub(self.data.beginTime,"-","/")
	local et = string.gsub(self.data.endTime,"-","/")
	self.timeLabel:setString(bt .."-"..et)
end

function CrossCelebrity:createHead(index,data)
	local head = nil
	if self.kind == ACTIVITY_CROSS_WORLD then
		if data then
			head = UiUtil.createItemView(ITEM_KIND_PORTRAIT, data.portrait, {pendant = item_pendent[self.tag][index]})
			local t = display.newSprite(IMAGE_COMMON.."info_bg_23.png"):addTo(head):pos(head:width()/2,-22)
			UiUtil.label("Lv."..data.level .." "..data.name,26,COLOR[6]):addTo(t):pos(t:width()/2,t:height()/2+15)
		else
			head = UiUtil.createItemView(ITEM_KIND_PORTRAIT, 0, {pendant = item_pendent[self.tag][index]})
		end
	elseif self.kind == ACTIVITY_CROSS_PARTY then
		if data then
			head = UiUtil.createItemView(ITEM_KIND_PORTRAIT, data.portrait, {pendant = nil})
			local t = display.newSprite(IMAGE_COMMON.."info_bg_23.png"):addTo(head):pos(head:width()/2,-42)
			UiUtil.label(data.serverName,24):addTo(t):pos(t:width()/2,t:height()/2+40)
			UiUtil.label(data.name,26,COLOR[index <= 3 and 5 or 2]):addTo(t):pos(t:width()/2,t:height()/2+14)
		else
			head = UiUtil.createItemView(ITEM_KIND_PORTRAIT, 0, {pendant = nil})
		end
	end
	display.newSprite(IMAGE_COMMON.."title_"..self.titles[index] ..".png"):addTo(head):pos(head:width()/2,head:height()+19)
	head:scale(0.8)
	return head
end

function CrossCelebrity:toDetail()
	ManagerSound.playNormalButtonSound()
	require("app.view.CrossBack").new(self.data,self.tag):push()
end

return CrossCelebrity