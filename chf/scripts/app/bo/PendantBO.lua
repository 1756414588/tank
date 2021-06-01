-----------

-----------
PendantBO = {}
PendantBO.pendants_ = {}
PendantBO.portraits_ = {}

function PendantBO.asynGetPendant(doneCallback)
	local function parseGetPendant(name, data)
		PendantBO.update(data)
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseGetPendant, NetRequest.new("GetPendant")) 
end

function PendantBO.update(data)
	if data then
		local pendants = PbProtocol.decodeArray(data["pendant"])
		for k,v in ipairs(pendants) do
			PendantBO.pendants_[v.pendantId] = v
		end
		pendants = PbProtocol.decodeArray(data["portrait"])
		for k,v in ipairs(pendants) do
			PendantBO.portraits_[v.id] = v
		end
	end
end

