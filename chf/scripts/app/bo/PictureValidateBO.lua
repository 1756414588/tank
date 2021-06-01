PictureValidateBO = {}
PictureValidateBO.validate = nil
PictureValidateBO.validateKeyWord1 = nil
PictureValidateBO.validateKeyWord2 = nil
PictureValidateBO.validatePic = nil
PictureValidateBO.isSuccess = nil
function PictureValidateBO.getScoutInfo(rhand)
	local function getResult(name,data)
		-- body
		Loading.getInstance():unshow()
		gdump(data, "GetScoutFreeTime recieve data==")
		UserMO.prohibitedTime = data.time
		UserMO.scoutCount = data.scoutCount
		UserMO.VerificationFailure = data.scoutFailCount
		PictureValidateBO.validate = data.isVerification
	end
	rhand()

	Loading.getInstance():show()
	SocketWrapper.wrapSend(getResult, NetRequest.new("GetScoutFreeTime"))
end
--
function PictureValidateBO.getisSuccess(imgId,rhand)
	-- body
	local function getResult(name,data)
		-- body
		Loading.getInstance():unshow()
		gdump(data,"VCodeScout recieve data==")
		UserMO.prohibitedTime = data.time
		UserMO.VerificationFailure = data.scoutFailCount
		PictureValidateBO.isSuccess = data.status
		if rhand then
			rhand(data)
		end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(getResult,NetRequest.new("VCodeScout",{imgId = imgId}))
end

function PictureValidateBO.getValidatePic(isFirst,rhand)
	local function getResult(name,data)
		Loading.getInstance():unshow()
		gdump(data,"getPics=====")
		PictureValidateBO.validateKeyWord1 = data.kindOne
		PictureValidateBO.validateKeyWord2 = data.kindTwo
		PictureValidateBO.validatePic = data.imgId
		rhand()
	end

	Loading.getInstance():show()
	SocketWrapper.wrapSend(getResult, NetRequest.new("RefreshScoutImg",{isFirst = isFirst}))
end


