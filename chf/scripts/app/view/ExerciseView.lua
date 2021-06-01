--
-- Author: Xiaohang
-- Date: 2016-08-08 14:27:05
--
local ExerciseView = class("ExerciseView", UiNode)

function ExerciseView:ctor()
	ExerciseView.super.ctor(self, "image/common/bg_ui.jpg", UI_ENTER_NONE)
end

function ExerciseView:onEnter()
	ExerciseView.super.onEnter(self)
	armature_add("animation/effect/hongqipiao.pvr.ccz", "animation/effect/hongqipiao.plist", "animation/effect/hongqipiao.xml")
	armature_add("animation/effect/lanqipiao.pvr.ccz", "animation/effect/lanqipiao.plist", "animation/effect/lanqipiao.xml")
	armature_add("animation/effect/junshi_baozha.pvr.ccz", "animation/effect/junshi_baozha.plist", "animation/effect/junshi_baozha.xml")
	armature_add("animation/effect/junshi_tanke.pvr.ccz", "animation/effect/junshi_tanke.plist", "animation/effect/junshi_tanke.xml")
	armature_add("animation/effect/light_touch.pvr.ccz", "animation/effect/light_touch.plist", "animation/effect/light_touch.xml")
	-- 增益信息
	self:setTitle(CommonText[10059][2])
	ExerciseBO.getInfo(handler(self, self.showUI))
	self:performWithDelay(function()
    		if ExerciseMO.refreshTime() then
    			self:refreshUI()
    		end
		end, 1, 1)
	-- ExerciseBO.data = {}
	-- ExerciseBO.data.status = 5
	-- ExerciseBO.data.enrollNum = 5
	-- ExerciseBO.data.camp = 0
	-- ExerciseBO.data.myArmy = 0
	-- ExerciseBO.data.exploit = 100
	-- ExerciseBO.data.redWin = {0,0,0}
	-- self:showUI()
end

function ExerciseView:showUI()
	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(self:getBg())
	bg:setPreferredSize(cc.size(display.width - 40, 710))
	bg:setPosition(display.cx, display.height - 100 - bg:height() / 2)
	self.bg = bg
	display.newSprite(IMAGE_COMMON .. "yanxibeijing.jpg"):addTo(bg):align(display.CENTER_TOP,bg:width()/2,bg:height()-5)
	local t = display.newSprite(IMAGE_COMMON .. "info_bg_28.png"):addTo(bg):pos(bg:width()/2,bg:height()-10)
	UiUtil.label(CommonText[20065]):addTo(t):center()

	--红军
	local t = display.newSprite("image/build/main_command_1.png")
			:addTo(bg,10):pos(510,bg:height()-130)
	t = display.newSprite(IMAGE_COMMON.."bg_red.png")
		:addTo(t):pos(t:width()/2,t:height()+20)
	UiUtil.label(CommonText[20066][2],nil,COLOR[6]):addTo(t):center()

	local t = display.newSprite("image/build/main_command_1.png")
			:addTo(bg,10):pos(bg:width()-510,380)
	t = display.newSprite(IMAGE_COMMON.."bg_blue.png")
		:addTo(t):pos(t:width()/2,t:height()+20)
	UiUtil.label(CommonText[20066][1],nil,COLOR[3]):addTo(t):center()

	self.builds = {}
	local x,y,ex,ey = 180,bg:height()-176,120,90
	local IMG = {"main_chariot.png","main_school.png","main_equip.png"}
	for i=0,2 do
		local t = display.newSprite("image/build/"..IMG[i+1])
		local tx,ty = x+i*ex,y-i*ey
		t = TouchButton.new(t, nil, nil, nil, handler(self, self.chooseLine))
			:addTo(bg,5,i+1):pos(tx,ty)
		self:checkArmy(i+1,tx,ty,t)
		table.insert(self.builds,t)
		display.newSprite(IMAGE_COMMON.."arrows_blue"..(i+1)..".png")
			:addTo(bg):align(display.RIGHT_TOP):pos(tx-55,ty-40)
		display.newSprite(IMAGE_COMMON.."arrows_red"..(i+1)..".png")
			:addTo(bg):align(display.LEFT_BOTTOM):pos(tx + 40,ty + 20)
		t = display.newSprite(IMAGE_COMMON.."btn_16_normal.png")
			:addTo(t):pos(t:width()/2,t:height()+20)
		UiUtil.label(CommonText[20067][i+1]):addTo(t):center()
	end
	-- --线路
	-- display.newSprite(IMAGE_COMMON.."icon_arrow_1.png", 310,248):addTo(bg)
	-- t = display.newSprite(IMAGE_COMMON.."icon_arrow_1.png", 42,420):addTo(bg)
	-- t:scaleY(-1)
	-- t:rotation(-90)
	-- --线路
	-- t = display.newSprite(IMAGE_COMMON.."icon_arrow_2.png", 320,600):addTo(bg):scale(-1)
	-- t = display.newSprite(IMAGE_COMMON.."icon_arrow_2.png", 520,440):addTo(bg)
	-- t:scaleX(-1)
	-- t:rotation(-90)

	--信息
	t = UiUtil.label(CommonText[20068]):addTo(bg):align(display.LEFT_CENTER,32,198)
	local state,c = ExerciseMO.getState(ExerciseBO.data.status)
	UiUtil.label(state,nil,c):addTo(bg):rightTo(t)
	t = UiUtil.label(CommonText[20069]):addTo(bg):alignTo(t, -32, 1)
	UiUtil.label(ExerciseBO.data.enrollNum,nil,COLOR[2]):addTo(bg):rightTo(t)
	--我的阵营
	local camp,c = CommonText[20052],COLOR[1]
	if ExerciseBO.data.camp == 1 then camp = CommonText[20066][2] c = COLOR[6]
	elseif ExerciseBO.data.camp == 2 then camp = CommonText[20066][1] c = COLOR[3] end
	t = UiUtil.label(CommonText[20070]):addTo(bg):alignTo(t, -32, 1)
	UiUtil.label(camp,nil,c):addTo(bg):rightTo(t)
	--我的部队
	t = UiUtil.label(CommonText[20071]):addTo(bg):alignTo(t, -32, 1)
	UiUtil.label(ExerciseBO.data.myArmy.."/2"):addTo(bg):rightTo(t)
	--阵营功勋
	t = UiUtil.label(CommonText[20072]):addTo(bg):alignTo(t, -32, 1)
	local temp = UiUtil.label((ExerciseBO.data.redExploit or "-") .."/",nil,COLOR[6]):addTo(bg):rightTo(t)
	UiUtil.label((ExerciseBO.data.blueExploit or "-"),nil,COLOR[3]):addTo(bg):rightTo(temp)
	--我的功勋
	t = UiUtil.label(CommonText[20093]):addTo(bg):alignTo(t, -32, 1)
	UiUtil.label(ExerciseBO.data.exploit,nil,COLOR[2]):addTo(bg):rightTo(t)
	
	local label = CommonText[20073][ExerciseBO.data.isEnrolled and 2 or 1]
	local btn = UiUtil.button("btn_1_normal.png", "btn_1_selected.png", "btn_1_disabled.png",
				handler(self, self.apply),label):addTo(self.bg):pos(480,167)
	if ExerciseBO.data.isEnrolled then
		btn:setEnabled(false)
	end
	UiUtil.button("btn_5_normal.png", "btn_5_selected.png",nil,
		handler(self, self.exercise),CommonText[20074]):addTo(self.bg):alignTo(btn, -100, 1)

	t = UiUtil.button("btn_11_normal.png", "btn_11_selected.png",nil,
		handler(self, self.rank),CommonText[765][2]):addTo(self):pos(display.cx+30,70):scale(0.9)
	UiUtil.button("btn_11_normal.png", "btn_11_selected.png",nil,
		handler(self, self.buff),CommonText[135]):addTo(self):alignTo(t,-130):scale(0.9)
	UiUtil.button("btn_11_normal.png", "btn_11_selected.png",nil,
		handler(self, self.record),CommonText[806][3]):addTo(self):alignTo(t,-260):scale(0.9)
	UiUtil.button("btn_11_normal.png", "btn_11_selected.png",nil,
		handler(self, self.shop),CommonText[20075]):addTo(self):alignTo(t,130):scale(0.9)
	UiUtil.button("btn_detail_normal.png", "btn_detail_selected.png", nil, function()
			ManagerSound.playNormalButtonSound()
			require("app.dialog.DetailTextDialog").new(DetailText.exerciseInfo):push() 
		end):addTo(self):alignTo(t, 242)
	self:showEffect()
end

function ExerciseView:checkArmy(index,x,y,v)
	if v.touchEffect then v.touchEffect:removeSelf() v.touchEffect = nil end
	if v.tankSprite then v.tankSprite:removeSelf() v.tankSprite = nil end
	local num = 0
	for i = FORMATION_FOR_EXERCISE1,FORMATION_FOR_EXERCISE3 do
		if not TankMO.isEmptyFormation(TankMO.getFormationByType(i)) then
			num = num + 1
		end
	end
	local formation = TankMO.getFormationByType(FORMATION_FOR_EXERCISE1 - 1 + index)
	if not TankMO.isEmptyFormation(formation) then
		for index = 1, FIGHT_FORMATION_POS_NUM do
			local data = formation[index]
			if data.count > 0 then
				v.tankSprite = UiUtil.createItemSprite(ITEM_KIND_TANK, data.tankId):scale(0.5):addTo(self.bg,10):pos(x+40,y-40)
				return
			end
		end	
	elseif num < 2 and ExerciseMO.inPrepareTime() and ExerciseBO.data.isEnrolled then
		v.touchEffect = armature_create("light_touch",x,y):addTo(self.bg,4)
		v.touchEffect:getAnimation():playWithIndex(0)
	end
end

function ExerciseView:tankEffect(v)
	local ex,ey = 140,90
	local tx,ty = 70,70*ey/ex
	v.tank1 = armature_create("junshi_tanke",v:x() - ex,v:y() - ey):addTo(self.bg,10)
	v.tank1:getAnimation():play("movefan")
	v.tank1:runAction(transition.sequence({cc.MoveTo:create(2, cc.p(v:x() - tx,v:y()-ty)), cc.CallFuncN:create(function(sender)
			v.tank1:getAnimation():play("firefan", 0, -1, 0)
		end)}))

	v.tank2 = armature_create("junshi_tanke",v:x() + ex,v:y() + ey):addTo(self.bg,10)
	v.tank2:getAnimation():play("movezheng")
	armature_callback(v.tank2, function (movementType, movementID, armature)
			if movementType == MovementEventType.COMPLETE and movementID == "firezheng" then
				local fire = armature_create("junshi_baozha",v:width()/2,v:height()/2,
					function (movementType, movementID, armature)
						if movementType == MovementEventType.COMPLETE then
							armature:removeSelf()
							self:showEffect()
						end
					end):addTo(v)
				fire:getAnimation():playWithIndex(0)
			end
		end)
	v.tank2:runAction(transition.sequence({cc.MoveTo:create(2, cc.p(v:x() + tx,v:y() + ty)), cc.CallFuncN:create(function(sender)
			v.tank2:getAnimation():play("firezheng", 0, -1, 0)
		end)}))
end

--界面特效
function ExerciseView:showEffect()
	local state = ExerciseBO.data.status
	for k,v in ipairs(self.builds) do
		if v.flag then v.flag:removeSelf() v.flag = nil end
		if v.tank1 then v.tank1:removeSelf() v.tank1 = nil end
		if v.tank2 then v.tank2:removeSelf() v.tank2 = nil end
		--旗帜
		local hasEnd = false
		if state - 3 >= k then
			if ExerciseBO.data.redWin[k] ~= 0 then
				local flag = ExerciseBO.data.redWin[k] == 1 and "hongqipiao" or "lanqipiao"
				v.flag = armature_create(flag, v:width()/2,v:height()+40):addTo(v)
				v.flag:getAnimation():playWithIndex(0)
				hasEnd = true
			end
		end
		--哪一路在打架
		if not hasEnd and state - 3 == k then
			self:tankEffect(v)
		end
	end

end

function ExerciseView:chooseLine(tag, sender)
	require("app.view.StrongholdView").new(nil,tag):push()
end

function ExerciseView:apply(tag,sender)
	ManagerSound.playNormalButtonSound()
	if not ExerciseMO.inApplyTime() then 
		Toast.show(CommonText[20102])
		return
	end
	ExerciseBO.apply(handler(self, self.refreshUI))
end

function ExerciseView:exercise(tag,sender)
	ManagerSound.playNormalButtonSound()
	require("app.view.ExerciseMilitary").new():push()
end

function ExerciseView:rank()
	ManagerSound.playNormalButtonSound()
	require("app.view.ExerciseRank").new():push()
end

function ExerciseView:record()
	ManagerSound.playNormalButtonSound()
	require("app.view.ExerciseRecord").new():push()
end

function ExerciseView:buff()
	ManagerSound.playNormalButtonSound()
	if not ExerciseBO.data.isEnrolled or ExerciseBO.data.status == 0 then
		Toast.show(CommonText[20103])
		return
	end
	require("app.view.ExerciseBuff").new():push()
end

function ExerciseView:shop()
	ManagerSound.playNormalButtonSound()
	require("app.view.ExerciseShop").new():push()
end

function ExerciseView:onExit()
	armature_remove("animation/effect/hongqipiao.pvr.ccz", "animation/effect/hongqipiao.plist", "animation/effect/hongqipiao.xml")
	armature_remove("animation/effect/lanqipiao.pvr.ccz", "animation/effect/lanqipiao.plist", "animation/effect/lanqipiao.xml")
	armature_remove("animation/effect/junshi_baozha.pvr.ccz", "animation/effect/junshi_baozha.plist", "animation/effect/junshi_baozha.xml")
	armature_remove("animation/effect/junshi_tanke.pvr.ccz", "animation/effect/junshi_tanke.plist", "animation/effect/junshi_tanke.xml")
	armature_remove("animation/effect/light_touch.pvr.ccz", "animation/effect/light_touch.plist", "animation/effect/light_touch.xml")
end

function ExerciseView:refreshUI()
	self.bg:removeSelf()
	ExerciseBO.getInfo(handler(self, self.showUI))
end

return ExerciseView