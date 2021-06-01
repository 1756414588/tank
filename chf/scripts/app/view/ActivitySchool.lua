--
-- Author: xiaoxing
-- Date: 2017-04-07 16:34:44
--
local ActivitySchool = class("ActivitySchool", UiNode)
local TEMP = 1
local girl_ani = {
	"nvlaoshi",
	"nvjunguan",
	"nvtegong",
	"nvhushi",
	"nvjiaolian",
	"nvjiaolian2"
}
function ActivitySchool:ctor(activity)
	ActivitySchool.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_FADE_IN_GATE)
	self.m_activity = activity
end

function ActivitySchool:onEnter()
	ActivitySchool.super.onEnter(self)
	armature_add(IMAGE_ANIMATION .. "effect/xdjx_baoguang.pvr.ccz", IMAGE_ANIMATION .. "effect/xdjx_baoguang.plist", IMAGE_ANIMATION .. "effect/xdjx_baoguang.xml")
	armature_add(IMAGE_ANIMATION .. "effect/xdjx_diandiguang.pvr.ccz", IMAGE_ANIMATION .. "effect/xdjx_diandiguang.plist", IMAGE_ANIMATION .. "effect/xdjx_diandiguang.xml")
	armature_add(IMAGE_ANIMATION .. "effect/xdjx_shouguang.pvr.ccz", IMAGE_ANIMATION .. "effect/xdjx_shouguang.plist", IMAGE_ANIMATION .. "effect/xdjx_shouguang.xml")

	self:hasCoinButton(true)
	self:setTitle(self.m_activity.name)
	ActivityCenterBO.getActCollege(function(data)
			self.data = data
			self:showUI()
		end)
	-- ActivityCenterBO.prop_ = {}
	-- self.data = {id = 1,point = 1,totalPoint = 80,freeTime = os.time()}
	-- self:showUI()
end

function ActivitySchool:showUI(changeTalk)
	self:getBg():removeAllChildren()
	local bg = self:getBg()
	local st = ActivityCenterMO.getCollegeSubject(self.data.id)
	if not st then
		st = ActivityCenterMO.getCollegeSubject(self.data.id - 1)
	end
	local t = display.newSprite(IMAGE_COMMON..st.background ..".jpg"):addTo(bg):align(display.CENTER_TOP, bg:width()/2, bg:height() - 100)
	local topBg = t
	self.topBg = topBg
	if self.data.point < st.credits then
		local now = display.newSprite(IMAGE_COMMON.."subject"..self.data.id..".png"):addTo(t):align(display.LEFT_CENTER, 300, t:height() - 30)
		UiUtil.label(self.data.point .."/"..st.credits,30):rightTo(now,10)
	end
	--女孩
	local girl = girl_ani[self.data.id]
	if self.data.point >= st.credits then
		girl = girl_ani[self.data.id + 1]
	end
	armature_add(IMAGE_ANIMATION .. "effect/"..girl..".pvr.ccz", IMAGE_ANIMATION .. "effect/"..girl..".plist", IMAGE_ANIMATION .. "effect/"..girl..".xml")
	local temp = armature_create(girl, 0, 0)
    temp:getAnimation():playWithIndex(0)
    temp:addTo(topBg):align(display.LEFT_BOTTOM, 30, 22)
	--说话
	local talk = ActivityCenterMO.getCollegeShowgirlchat(self.data.id)
	if not ActivityCenterMO.talkIndex_ or changeTalk or not talk[ActivityCenterMO.talkIndex_] then
		ActivityCenterMO.talkIndex_ = math.random(1, #talk)
	end
	local lw = topBg:width() - (temp:x() + temp:width()) - 20
	local str = UiUtil.label(talk[ActivityCenterMO.talkIndex_].chat,nil,cc.c3b(5,60,116),cc.size(lw-20,0),ui.TEXT_ALIGN_LEFT)
	local temp = UiUtil.sprite9("talk_panel.png", 20, 14, 6, 1, lw, str:height() + 20):addTo(t):align(display.LEFT_CENTER, temp:x() + temp:width(), temp:y() + temp:height()/2+60)
	str:addTo(temp):align(display.LEFT_TOP, 20, temp:height() - 10)

	local info = ActivityCenterMO.getCollegeEducation()
	local total = info[#info - 1].maxnumber
	-- 属性背景框
	local attrBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(bg)
	attrBg:setPreferredSize(cc.size(586, 150))
	attrBg:setPosition(bg:width()/2, t:y()-t:height()-attrBg:height()/2 - 30)
	local t = display.newSprite(IMAGE_COMMON .. "info_bg_28.png"):addTo(attrBg):pos(attrBg:width()/2,attrBg:height()-6)
	UiUtil.label(CommonText[20224][1] .. self.data.totalPoint .."/"..total):addTo(t):center()
	--总进度
	local bar = ProgressBar.new(IMAGE_COMMON .. "bar_5.png", BAR_DIRECTION_HORIZONTAL, cc.size(500, 37), {bgName = IMAGE_COMMON .. "bar_bg_2.png", bgScale9Size = cc.size(500 + 4, 26)}):addTo(attrBg)
	bar:setPosition(attrBg:width() / 2, 32)
	bar:setPercent(self.data.totalPoint/total)
	self.exTotal = {}
	for i=1, #info - 1 do
		local item = info[i]
		local t = UiUtil.showTip(bar, item.maxnumber, item.maxnumber/total*bar:width(), bar:height() , nil, i)
		local img = IMAGE_COMMON..item.map..".jpg"
		t = display.newSprite(img):addTo(bar):align(display.CENTER_BOTTOM, t:x(), t:y() + 5):scale(0.6)
		self:showTips(item.buffmeaning,t)
		table.insert(self.exTotal, item.maxnumber)
		if self.data.totalPoint >= item.maxnumber then
			display.newSprite(IMAGE_COMMON.."icon_gou.png"):addTo(t):center()
		else
			img = IMAGE_COMMON.. "gray_" ..item.map..".jpg"
		end
		if item.cumulativerewards == "[]" then
			local x,y = 400,30
			if topBg.buff then
				x = topBg.buff:x() + 80
			end
			topBg.buff = display.newSprite(img):addTo(topBg,0,i):align(display.CENTER_BOTTOM, x, y):scale(0.7)
			self:showTips(item.buffmeaning,topBg.buff)
		end
	end

	--下部信息
	local normal = display.newSprite(IMAGE_COMMON .. "btn_go.png")
	local shopBtn = ScaleButton.new(normal, function()
			ManagerSound.playNormalButtonSound()
			local buildingId = BUILD_ID_SCHOOL
			if UserMO.level_ < BuildMO.getOpenLevel(buildingId) then
				local build = BuildMO.queryBuildById(buildingId)
				Toast.show(string.format(CommonText[290], BuildMO.getOpenLevel(buildingId), build.name))
				return
			end
			require("app.view.NewSchoolView").new(buildingId):push()
		end):addTo(bg)
	shopBtn:setPosition(90, attrBg:y() - 110)
	UiUtil.label(CommonText[20224][2]):addTo(shopBtn):center()
	UiUtil.button("btn_39_normal.png", "btn_39_selected.png", nil, function()
			ManagerSound.playNormalButtonSound()
			local DetailTextDialog = require("app.dialog.DetailTextDialog")
			DetailTextDialog.new(DetailText.school):push()
		end):addTo(bg):pos(bg:width() - 50, shopBtn:y())
	--进修教材
	local need = json.decode(st.needbook)
	local pb = UserMO.getResourceData(need[1],need[2])
	local t = UiUtil.createItemView(need[1], need[2]):addTo(bg):pos(260,shopBtn:y() - 42)
	UiUtil.createItemDetailButton(t)
	local view = t
	t = UiUtil.label(pb.name, nil, COLOR[pb.quality]):addTo(bg):align(display.LEFT_CENTER, t:x() + 65, t:y() + 18)
	local count = ActivityCenterBO.prop_[need[2]] and ActivityCenterBO.prop_[need[2]].count or 0
	t = UiUtil.label(count, nil, COLOR[count < need[3] and 6 or 2]):addTo(bg):alignTo(t, -36, 1)
	t = UiUtil.label("/"..need[3]):rightTo(t)
	bg.ownLabel = t
	ScaleButton.new(display.newSprite(IMAGE_COMMON.."small_add.png"), function()
				ManagerSound.playNormalButtonSound()
				local worldPoint = view:getParent():convertToWorldSpace(cc.p(view:getPositionX(), view:getPositionY()))
				local BagBuyDialog = require("app.dialog.BagBuyDialog")
				local function rhand(num,hand)
					ActivityCenterBO.buyActProp(need[2],num,function(buyNum,freeTime)
							self.data.buyPropNum = buyNum
							self.data.freeTime = freeTime or 0
							self:showUI()
							hand()
						end)

				end
				local param = {item = need, nowtime = self.data.buyPropNum, price = PropMO.queryActPropById(need[2]).trapezoidalprice, rhand = rhand}
				local dialog = BagBuyDialog.new(worldPoint, propId, param)
				dialog:push()
			end):rightTo(t, 10)
	--补充时间
	if self.data.freeTime > 0 then
		local label = UiUtil.label("00:00:00", nil, COLOR[6])
			:addTo(bg):align(display.LEFT_CENTER, 190, view:y() - 64)
		local label_1 = UiUtil.label(CommonText[20224][3]):rightTo(label)
		local function tick()
			local left = self.data.freeTime + 3600 - ManagerTimer.getTime()
			local time = ManagerTimer.time(left)
			if left <= 0 then
				if self.doAdvan then
					label:hide()
					label_1:hide()
					return
				end
				CombatBO.addAwards({{type = ITEM_KIND_CHAR, id = need[2], count = 1}})
				if ActivityCenterBO.prop_[need[2]].count >= 10 then
					self.data.freeTime = 0
				else
					self.data.freeTime = ManagerTimer.getTime()
				end
				self:showUI()
			end
			label:setString(string.format("%02d:%02d:%02d", time.hour, time.minute, time.second))
		end
		label:performWithDelay(tick, 1, 1)
		tick()
	end
	t = UiUtil.button("btn_1_normal.png", "btn_1_selected.png", nil, handler(self, self.doAdvance), CommonText[20225][1])
		:addTo(bg,0,1):pos(178,62)
	t = UiUtil.button("btn_2_normal.png", "btn_2_selected.png", nil, handler(self, self.doAdvance), CommonText[20225][2])
		:addTo(bg,0,10):pos(bg:width() - t:x(),t:y())
	self.doAdvan = nil
end

function ActivitySchool:showTips(str,node)
	node:setTouchEnabled(true)
	node:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		if event.name == "began" then
			local des = display.newScale9Sprite(IMAGE_COMMON .. "item_bg_6.png")
			local label = UiUtil.label(str,nil,nil,cc.size(200,0),ui.TEXT_ALIGN_LEFT)
			des:setPreferredSize(cc.size(220,label:height() + 10))
			label:addTo(des):align(display.LEFT_TOP, 10, des:height() - 5)
			des:alignTo(node, node:height()*node:getScaleY() + 5, 1)
			if des:x() + des:width()/2 > des:getParent():width() then
				des:x(des:getParent():width() - des:width()/2 - 5)
			elseif des:x() - des:width()/2 < 0 then
				des:x(des:width()/2)
			end
			node.tipNode_ = des
			return true
		elseif event.name == "ended" then
			node.tipNode_:removeSelf()
		end
	end)
end

function ActivitySchool:doAdvance(tag, sender)
	if self.isDo then
		return
	end
	ManagerSound.playNormalButtonSound()
	self.doAdvan = true
	local st = ActivityCenterMO.getCollegeSubject(self.data.id)
	if not st then
		st = ActivityCenterMO.getCollegeSubject(self.data.id - 1)
	end
	local need = json.decode(st.needbook)
	local pb = UserMO.getResourceData(need[1],need[2])
	local count = ActivityCenterBO.prop_[need[2]] and ActivityCenterBO.prop_[need[2]].count or 0
	local target = sender
	local s_pos = cc.p(sender:x(), sender:y())
	local function rhand(data)
		local id = self.data.id
		local oldTotal = self.data.totalPoint
		local point = self.data.point
		local st = ActivityCenterMO.getCollegeSubject(data.id)
		self.data.id = data.id
		self.data.point = data.point
		self.data.totalPoint = data.totalPoint
		self.data.freeTime = data.freeTime
		self.data.buyPropNum = self.data.buyPropNum + tag
		if data.id > id or (st.credits > point and data.point >= st.credits) then
			self:showSubject(id,function()
					for k,v in ipairs(self.exTotal) do
						if oldTotal < v and data.totalPoint >= v then
							self:showBarEffect(s_pos,k)
							return
						end
					end
					self:showUI(1)
				end)
		else
			for k,v in ipairs(self.exTotal) do
				if oldTotal < v and data.totalPoint >= v then
					self:showBarEffect(s_pos,k)
					return
				end
			end
			self:showUI(1)
		end
	end
	local function doAct()
		ActivityCenterBO.doActCollege(tag,false,function(data)
				rhand(data)
			end)
	end
	if count < tag*need[3] then 
		local ConfirmDialog = require("app.dialog.ConfirmDialog")
		local price = UiUtil.getGradedPrice(json.decode(PropMO.queryActPropById(need[2]).trapezoidalprice),self.data.buyPropNum,tag)
		local temp = self.doAdvan
		ConfirmDialog.new(string.format(CommonText[20226],price,tag), function()
			local counts = UserMO.getResource(ITEM_KIND_COIN)
			if counts < price then  -- 金币不足
				self.doAdvan = nil
				require("app.dialog.CoinTipDialog").new():push()
				return
			end
			ActivityCenterBO.doActCollege(tag,true,function(data)
					UserMO.reduceResource(ITEM_KIND_COIN, price)
					rhand(data)
				end,1)
		end,function() self.doAdvan = nil end):push()
	else
		doAct()
	end
end

function ActivitySchool:showBarEffect(pos,id)
	local layer = display.newColorLayer(ccc4(0, 0, 0, 0)):addTo(display.getRunningScene(),999,988)
	layer:setContentSize(cc.size(display.width, display.height))
	layer:setPosition(0, 0)
	layer:setTouchEnabled(true)
	layer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		return true
	end)

	local info = ActivityCenterMO.getCollegeEducation(id)
	local bg = self:getBg()
	local path = "animation/effect/miyaojuexing_tx1.plist"
    local particleSys = cc.ParticleSystemQuad:create(path)
    local wPos = pos
    particleSys:pos(pos.x,pos.y)
    particleSys:setScale(1.5)
    particleSys:addTo(self:getBg())

    local toPos = cc.p(bg:width() / 2, bg:height() - 350)
    local config = ccBezierConfig()
    config.endPosition = toPos
    config.controlPoint_1 = cc.p(wPos.x - 60, wPos.y + 100)
    config.controlPoint_2 = cc.p(wPos.x-30, wPos.y + 160)

   	particleSys:runAction(transition.sequence({cc.EaseSineIn:create(cc.BezierTo:create(1, config)), cc.CallFunc:create(function(sender) 
   			particleSys:removeSelf()
   			--黑色遮罩
   			local touchLayer = display.newColorLayer(ccc4(0, 0, 0, 180)):addTo(bg,999)
   			touchLayer:setContentSize(cc.size(display.width, display.height))
   			touchLayer:setPosition(0, 0)
   			touchLayer:setTouchEnabled(true)
   			touchLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
   				return true
   			end)	

			local light = armature_create("xdjx_baoguang", toPos.x,toPos.y,
			        function (movementType, movementID, armature)
			            if movementType == MovementEventType.COMPLETE then
			                armature:removeSelf()
			            end
			        end)
		    light:getAnimation():playWithIndex(0)
		    light:addTo(bg,1000)
		    local view = nil
		    local target = nil
		    if info.cumulativerewards ~= "[]" then
		    	local item = json.decode(info.cumulativerewards)
		    	view = UiUtil.createItemView(item[1], item[2], {count = item[3]})
		    	target = bg.ownLabel
		    else
		    	view = display.newSprite(IMAGE_COMMON..info.map..".jpg")
		    	target = self.topBg:getChildByTag(id)
		    end
		    view:addTo(bg,1001):pos(toPos.x,toPos.y)
		    view:setCascadeOpacityEnabled(true)
		    view:setOpacity(0)
		    view:run({
		    		"seq",
		    		{"fadeIn",0.5},
		    		{"call",function()
	    				local temp = armature_create("xdjx_diandiguang", toPos.x,toPos.y)
	    			    temp:getAnimation():playWithIndex(0)
	    			    temp:addTo(bg,1000)
	    			    view.diguang = temp
		    		end},
		    		{"delay",1.5},
		    		{"call",function()
		    			view:fadeOut(0.8)
		    			view.diguang:fadeOut(0.8)
	    				local temp = armature_create("xdjx_shouguang", toPos.x,toPos.y,
					        function (movementType, movementID, armature)
					            if movementType == MovementEventType.COMPLETE then
					                armature:removeSelf()
					                view.diguang:removeSelf()
					                view:removeSelf()
					                touchLayer:removeSelf()
					                particleSys = cc.ParticleSystemQuad:create(path)
					                particleSys:pos(toPos.x,toPos.y)
					                particleSys:setScale(1.5)
					                particleSys:addTo(bg)
					                local tarPos = target:convertToWorldSpace(cc.p(0,0))
					                particleSys:run{
					                	"seq",
					                	{"moveTo",0.4,tarPos},
					                	{"call",function()
					                		particleSys:removeSelf()
					                		target:run{
					                			"seq",
					                			{"scaleto",0.3,1.2},
					                			{"scaleto",0.1,1,elasticout},
					                			{"call",function()
					                				layer:removeSelf()
					                				self:showUI(1)
					                			end}
					                		}
					                	end},
					            	}
					            end
					        end)
	    			    temp:getAnimation():playWithIndex(0)
	    			    temp:addTo(bg,1000)
		    		end},
		    	})
    	end)
   	}))
end

function ActivitySchool:showSubject(id,rhand)
	local layer = display.newColorLayer(ccc4(0, 0, 0, 0)):addTo(display.getRunningScene(),999,988)
	layer:setContentSize(cc.size(display.width, display.height))
	layer:setPosition(0, 0)
	layer:setTouchEnabled(true)
	layer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		return true
	end)
	armature_add(IMAGE_ANIMATION .. "effect/wanmeijieye.pvr.ccz", IMAGE_ANIMATION .. "effect/wanmeijieye.plist", IMAGE_ANIMATION .. "effect/wanmeijieye.xml")
	local bg = self:getBg()
	local st = ActivityCenterMO.getCollegeSubject(id)
	local item = json.decode(st.awards)[1]
	UserMO.addResource(item[1], item[3], item[2])
	local temp = armature_create("wanmeijieye", bg:width()/2,bg:height()/2,
			        function (movementType, movementID, armature)
			            if movementType == MovementEventType.COMPLETE then
			                -- armature:removeSelf()
                   			--黑色遮罩
                   			local touchLayer = display.newColorLayer(ccc4(0, 0, 0, 180)):addTo(bg,999)
                   			touchLayer:setContentSize(cc.size(display.width, display.height))
                   			touchLayer:setPosition(0, 0)
                   			touchLayer:setTouchEnabled(true)
                   			touchLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
                   				return true
                   			end)	
                   			local toPos = cc.p(armature:x(),armature:y() + 20)
                			local light = armature_create("xdjx_baoguang", toPos.x,toPos.y,
                			        function (movementType, movementID, armature)
                			            if movementType == MovementEventType.COMPLETE then
                			                armature:removeSelf()
                			            end
                			        end)
                		    light:getAnimation():playWithIndex(0)
                		    light:addTo(bg,1000)
                		    local view = UiUtil.createItemView(item[1], item[2], {count = item[3]})
                		    view:addTo(bg,1000):pos(toPos.x,toPos.y)
                		    view:setCascadeOpacityEnabled(true)
                		    view:setOpacity(0)
                		    view:run({
                		    		"seq",
                		    		{"fadeIn",0.5},
                		    		{"call",function()
                	    				local temp = armature_create("xdjx_diandiguang", toPos.x,toPos.y)
                	    			    temp:getAnimation():playWithIndex(0)
                	    			    temp:addTo(bg,999)
                	    			    view.diguang = temp
                	    			    local pb = UserMO.getResourceData(item[1],item[2])
                	    			    UiUtil.label(pb.name, nil, COLOR[pb.quality]):addTo(view):pos(view:width()/2, -18)
                		    		end},
                		    		{"delay",1.5},
                		    		{"call",function()
                		    			view:fadeOut(0.4)
                		    			view.diguang:fadeOut(0.4)
                		    			touchLayer:removeSelf()
                		    			armature:run{
                		    				"seq",
                		    				{"fadeOut",0.4},
                		    				{"call",function()
                		    					armature:removeSelf()
                		    					layer:removeSelf()
                		    					rhand()
                		    				end}
                		    			}
                		    		end},
                		    	})
			            end
			        end)
    temp:getAnimation():playWithIndex(0)
    temp:addTo(bg)
end

function ActivitySchool:onExit()
	armature_remove(IMAGE_ANIMATION .. "effect/xdjx_baoguang.pvr.ccz", IMAGE_ANIMATION .. "effect/xdjx_baoguang.plist", IMAGE_ANIMATION .. "effect/xdjx_baoguang.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/xdjx_diandiguang.pvr.ccz", IMAGE_ANIMATION .. "effect/xdjx_diandiguang.plist", IMAGE_ANIMATION .. "effect/xdjx_diandiguang.xml")
	armature_remove(IMAGE_ANIMATION .. "effect/xdjx_shouguang.pvr.ccz", IMAGE_ANIMATION .. "effect/xdjx_shouguang.plist", IMAGE_ANIMATION .. "effect/xdjx_shouguang.xml")

	armature_remove(IMAGE_ANIMATION .. "effect/wanmeijieye.pvr.ccz", IMAGE_ANIMATION .. "effect/wanmeijieye.plist", IMAGE_ANIMATION .. "effect/wanmeijieye.xml")
	for k,v in ipairs(girl_ani) do
		armature_remove(IMAGE_ANIMATION .. "effect/"..v..".ccz", IMAGE_ANIMATION .. "effect/"..v..".plist", IMAGE_ANIMATION .. "effect/"..v..".xml")
	end
end

return ActivitySchool