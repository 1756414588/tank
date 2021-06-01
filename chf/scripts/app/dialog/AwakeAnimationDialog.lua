--
-- Author: Your Name
-- Date: 2017-03-21 10:31:38
--
--觉醒提示Dialog

--根据type判定展示开启，成功或失败的效果

AWAKE_BEGIN_TYPE = 1    --觉醒开启
AWAKE_FALI_TYPE = 2       --觉醒失败
AWAKE_SUCCESS_TYPE = 3    --觉醒成功


local Dialog = require("app.dialog.Dialog")
local AwakeAnimationDialog = class("AwakeAnimationDialog", Dialog)


function AwakeAnimationDialog:ctor(type,hero)
	local kind = type 
	if type == AWAKE_SUCCESS_TYPE then
		AwakeAnimationDialog.super.ctor(self,nil,nil)
	else
		AwakeAnimationDialog.super.ctor(self,nil,UI_ENTER_FADE_IN_GATE)
	end
	self:setOutOfBgClose(true)
	self:setInOfBgClose(true)
	self.hero = hero
	self.type = type
end

function AwakeAnimationDialog:onEnter()
	AwakeAnimationDialog.super.onEnter(self)
	
	if self.type == AWAKE_BEGIN_TYPE then
		armature_add(IMAGE_ANIMATION .. "hero/juexingkaiqi.pvr.ccz", IMAGE_ANIMATION .. "hero/juexingkaiqi.plist", IMAGE_ANIMATION .. "hero/juexingkaiqi.xml")
			local itemAm = armature_create("juexingkaiqi",self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height / 2 ,nil):addTo(self:getBg())
			itemAm:getAnimation():playWithIndex(0)
	elseif self.type == AWAKE_FALI_TYPE then
		local num = HeroMO.queryFailTipsNum()
		local id = random(1, num) 
		local failInfo = HeroMO.queryFailTips(id)

		local faliTip = display.newSprite(IMAGE_COMMON.."info_bg_85.png", display.cx, display.cy):addTo(self:getBg())
		local tipsLab = ui.newTTFLabel({text = failInfo.desc, font = G_FONT, size = FONT_SIZE_SMALL,
		 x = faliTip:getContentSize().width / 2 - 20, y = faliTip:getContentSize().height / 2 + 50, align = ui.TEXT_ALIGN_LEFT,dimensions = cc.size(290, 70)}):addTo(faliTip)

	elseif self.type == AWAKE_SUCCESS_TYPE then
		armature_add(IMAGE_ANIMATION .. "hero/jxcg.pvr.ccz", IMAGE_ANIMATION .. "hero/jxcg.plist", IMAGE_ANIMATION .. "hero/jxcg.xml")
		armature_add(IMAGE_ANIMATION .. "hero/beihou_youying.pvr.ccz", IMAGE_ANIMATION .. "hero/beihou_youying.plist", IMAGE_ANIMATION .. "hero/beihou_youying.xml")
		armature_add(IMAGE_ANIMATION .. "hero/jxcg_baoguang.pvr.ccz", IMAGE_ANIMATION .. "hero/jxcg_baoguang.plist", IMAGE_ANIMATION .. "hero/jxcg_baoguang.xml")
		armature_add(IMAGE_ANIMATION .. "hero/diaoge.pvr.ccz", IMAGE_ANIMATION .. "hero/diaoge.plist", IMAGE_ANIMATION .. "hero/diaoge.xml")
		armature_add(IMAGE_ANIMATION .. "hero/youying.pvr.ccz", IMAGE_ANIMATION .. "hero/youying.plist", IMAGE_ANIMATION .. "hero/youying.xml")
		armature_add(IMAGE_ANIMATION .. "hero/anxing.pvr.ccz", IMAGE_ANIMATION .. "hero/anxing.plist", IMAGE_ANIMATION .. "hero/anxing.xml")
		armature_add(IMAGE_ANIMATION .. "hero/leidi.pvr.ccz", IMAGE_ANIMATION .. "hero/leidi.plist", IMAGE_ANIMATION .. "hero/leidi.xml")

		armature_add(IMAGE_ANIMATION .. "hero/beihou_diaoge.pvr.ccz", IMAGE_ANIMATION .. "hero/beihou_diaoge.plist", IMAGE_ANIMATION .. "hero/beihou_diaoge.xml")
		armature_add(IMAGE_ANIMATION .. "hero/beihou_fengxingzhe.pvr.ccz", IMAGE_ANIMATION .. "hero/beihou_fengxingzhe.plist", IMAGE_ANIMATION .. "hero/beihou_fengxingzhe.xml")
		armature_add(IMAGE_ANIMATION .. "hero/beihou_anxing.pvr.ccz", IMAGE_ANIMATION .. "hero/beihou_anxing.plist", IMAGE_ANIMATION .. "hero/beihou_anxing.xml")
		armature_add(IMAGE_ANIMATION .. "hero/beihou_aogusite.pvr.ccz", IMAGE_ANIMATION .. "hero/beihou_aogusite.plist", IMAGE_ANIMATION .. "hero/beihou_aogusite.xml")

		local itemAm = armature_create("jxcg",self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height / 2 ,nil):addTo(self:getBg(),999)
		itemAm:getAnimation():playWithIndex(0)
		self:performWithDelay(function()
		    local baoguang = armature_create("jxcg_baoguang",self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height / 2 + 50 ,nil):addTo(self:getBg(),998)
		    baoguang:setScale(1.8)
			baoguang:getAnimation():playWithIndex(0)
		end, 0.3)

		self:performWithDelay(function()
		    local heroAm = armature_create(self.hero.map,self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height / 2 + 150 ,nil):addTo(self:getBg(),997)
			heroAm:getAnimation():playWithIndex(0)
		end, 0.6)

		local map = self.hero.map
		if map == "leidi" then
			map = "anxing"
		end

		self:performWithDelay(function()
		   	local lightEffect = CCArmature:create("beihou_"..map)
		    lightEffect:getAnimation():playWithIndex(0)
		    lightEffect:addTo(self:getBg(),0):center()
		    lightEffect:setPosition(self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height / 2 + 150)
		end, 0.5)
	end

end

function AwakeAnimationDialog:onExit()
	AwakeAnimationDialog.super.onExit(self)
	armature_remove(IMAGE_ANIMATION .. "hero/juexingkaiqi.pvr.ccz", IMAGE_ANIMATION .. "hero/juexingkaiqi.plist", IMAGE_ANIMATION .. "hero/juexingkaiqi.xml")
	armature_remove(IMAGE_ANIMATION .. "hero/jxcg.pvr.ccz", IMAGE_ANIMATION .. "hero/jxcg.plist", IMAGE_ANIMATION .. "hero/jxcg.xml")
	armature_remove(IMAGE_ANIMATION .. "hero/beihou_diaoge.pvr.ccz", IMAGE_ANIMATION .. "hero/beihou_diaoge.plist", IMAGE_ANIMATION .. "hero/beihou_diaoge.xml")
	armature_remove(IMAGE_ANIMATION .. "hero/jxcg_baoguang.pvr.ccz", IMAGE_ANIMATION .. "hero/jxcg_baoguang.plist", IMAGE_ANIMATION .. "hero/jxcg_baoguang.xml")
	armature_remove(IMAGE_ANIMATION .. "hero/beihou_youying.pvr.ccz", IMAGE_ANIMATION .. "hero/beihou_youying.plist", IMAGE_ANIMATION .. "hero/beihou_youying.xml")
	armature_remove(IMAGE_ANIMATION .. "hero/beihou_fengxingzhe.pvr.ccz", IMAGE_ANIMATION .. "hero/beihou_fengxingzhe.plist", IMAGE_ANIMATION .. "hero/beihou_fengxingzhe.xml")
	armature_remove(IMAGE_ANIMATION .. "hero/beihou_anxing.pvr.ccz", IMAGE_ANIMATION .. "hero/beihou_anxing.plist", IMAGE_ANIMATION .. "hero/beihou_anxing.xml")
	armature_remove(IMAGE_ANIMATION .. "hero/beihou_aogusite.pvr.ccz", IMAGE_ANIMATION .. "hero/beihou_aogusite.plist", IMAGE_ANIMATION .. "hero/beihou_aogusite.xml")

	-- armature_remove(IMAGE_ANIMATION .. "hero/youying.pvr.ccz", IMAGE_ANIMATION .. "hero/youying.plist", IMAGE_ANIMATION .. "hero/youying.xml")
	-- armature_remove(IMAGE_ANIMATION .. "hero/diaoge.pvr.ccz", IMAGE_ANIMATION .. "hero/diaoge.plist", IMAGE_ANIMATION .. "hero/diaoge.xml")

end

return AwakeAnimationDialog