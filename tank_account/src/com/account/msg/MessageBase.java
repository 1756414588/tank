package com.account.msg;

import net.sf.json.JSONObject;

import com.account.constant.GameError;
import com.game.pb.BasePb.Base;

public interface MessageBase {
    JSONObject execute(JSONObject request);

    GameError execute(Object req, Base.Builder builder);
}
