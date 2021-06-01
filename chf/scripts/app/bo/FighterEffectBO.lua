--
-- 战斗特效
--

FighterEffectBO = {}

function FighterEffectBO.GetAttackEffect(rhand)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		-- repeated AttackEffectPb effect = 1;		//攻击特效信息
		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetAttackEffect"))
end

function FighterEffectBO.UseAttackEffect(rhand, id)
	-- required int32 id = 1;					//攻击特效唯一ID
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("UseAttackEffect",{id = id}))
end