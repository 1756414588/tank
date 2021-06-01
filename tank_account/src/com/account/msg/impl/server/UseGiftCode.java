package com.account.msg.impl.server;

import net.sf.json.JSONObject;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.account.constant.GameError;
import com.account.msg.MessageBase;
import com.account.service.GiftService;
import com.game.pb.BasePb.Base;
import com.game.pb.InnerPb.UseGiftCodeRq;
import com.game.pb.InnerPb.UseGiftCodeRs;

@Component
public class UseGiftCode implements MessageBase {

    @Autowired
    private GiftService giftService;

    @Override
    public JSONObject execute(JSONObject request) {
        // TODO Auto-generated method stub
        //LOG.error("can do in this");
        // JSONObject back =
        // MessageHelper.createPacket(MessageHelper.getRequestCmd(request));
        // JSONObject param = MessageHelper.getRequestParam(request);
        // JSONObject response = new JSONObject();
        // GameError gameError;
        // if (param == null) {
        // gameError = GameError.PARAM_ERROR;
        // return MessageHelper.packError(back, gameError);
        // }
        // gameError = authorityService.verify(param, response);
        // return MessageHelper.packResponse(back, gameError, response);
        return null;
    }

    @Override
    public GameError execute(Object req, Base.Builder builder) {
        // TODO Auto-generated method stub
        UseGiftCodeRq msg = (UseGiftCodeRq) req;
        UseGiftCodeRs.Builder rsBuilder = UseGiftCodeRs.newBuilder();

        GameError gameError = giftService.useGiftCode(msg, rsBuilder);

        UseGiftCodeRs rs = rsBuilder.build();
        builder.setExtension(UseGiftCodeRs.ext, rs);
        return gameError;
    }

}
