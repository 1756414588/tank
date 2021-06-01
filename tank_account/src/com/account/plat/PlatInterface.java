package com.account.plat;

import javax.servlet.http.HttpServletResponse;

import org.springframework.web.context.request.WebRequest;

import com.account.constant.GameError;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;

import net.sf.json.JSONObject;

public interface PlatInterface {

    GameError doLogin(JSONObject param, JSONObject response);

    // public GameError verify(JSONObject param, JSONObject response);
    String payBack(WebRequest request, String content, HttpServletResponse response);

    // public String payBack(WebRequest request,String content);
    String order(WebRequest request, String content);

    String balance(WebRequest request, String content);

    GameError doLogin(DoLoginRq req, DoLoginRs.Builder response);
}
