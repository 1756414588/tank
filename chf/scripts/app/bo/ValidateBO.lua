ValidateBO={}
ValidateBO.validate = nil
function ValidateBO.getScoutInfo(rhand)
	local function getResult(name,data)
		-- body
		Loading.getInstance():unshow()
		gdump(data, "GetScoutFreeTime recieve data==")
		UserMO.prohibitedTime=data.time
		UserMO.scoutCount=data.scoutCount
		UserMO.VerificationFailure=data.scoutFailCount
		ValidateBO.validate = data.isVerification
	end
		rhand()

	Loading.getInstance():show()
	SocketWrapper.wrapSend(getResult, NetRequest.new("GetScoutFreeTime"))
end

function ValidateBO.getisSuccess(state,rhand)
	-- body
	local function getResult(name,data)
		-- body
		Loading.getInstance():unshow()
		gdump(data,"VCodeScout recieve data==")
		UserMO.prohibitedTime=data.time
		UserMO.VerificationFailure=data.scoutFailCount
		if rhand then
			rhand(data)
		end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(getResult,NetRequest.new("VCodeScout",{state=state}))
end

