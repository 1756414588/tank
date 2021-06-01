package com.account.plat;

import net.sf.json.JSONObject;

import com.account.constant.GameError;
import com.game.pb.AccountPb.DoRegisterRq;
import com.game.pb.AccountPb.DoRegisterRs;

public interface Register {
    public GameError register(JSONObject param, JSONObject response);

    public GameError register(DoRegisterRq req, DoRegisterRs.Builder builder);
}
