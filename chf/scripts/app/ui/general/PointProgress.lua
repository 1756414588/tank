--
-- Author: Xiaohang
-- Date: 2016-07-17 21:16:58
-- 点进度条
local PointProgress = class("ProgressBar", function ()
   return display.newNode()
end)
local ex = 2

function PointProgress:ctor(totalNum,max)
	self.totalNum = totalNum
	self.max = max
	self:size(totalNum*7+(totalNum-1)*ex,16)
	self.points = {}
	for i=1,totalNum do
		self.points[i] = display.newSprite(IMAGE_COMMON.."lv.png")
			:addTo(self):align(display.LEFT_CENTER,(i-1)*(7+ex),8)
	end
	self:setAnchorPoint(cc.p(0.5,0.5))
end

function PointProgress:setPercent(percent)
	self.percent_ = percent
	local bar = "hong.png"
	if percent > 0.66 then
		bar = "lv.png"
	elseif percent > 0.33 then
		bar = "huang.png"
	end
	for i=1,self.totalNum do
		if (i-1)/self.totalNum >= percent then
			self.points[i]:setTexture(CCTextureCache:sharedTextureCache():addImage(IMAGE_COMMON .."hui.png"))
		else
			self.points[i]:setTexture(CCTextureCache:sharedTextureCache():addImage(IMAGE_COMMON ..bar))
		end
	end
end

function PointProgress:getPercent()
	return self.percent_
end

return PointProgress