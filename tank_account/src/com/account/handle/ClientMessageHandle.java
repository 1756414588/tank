package com.account.handle;

import com.account.msg.impl.client.DoActive;
import com.account.msg.impl.client.DoLogin;
import com.account.msg.impl.client.DoRegister;
import com.game.pb.AccountPb.DoActiveRq;
import com.game.pb.AccountPb.DoActiveRs;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;
import com.game.pb.AccountPb.DoRegisterRq;
import com.game.pb.AccountPb.DoRegisterRs;

public class ClientMessageHandle extends MessageHandle {
    @Override
    public void addMessage() {
        // registerMessage("doLogin", DoLogin.class);
        // registerMessage("doRegister", DoRegister.class);
        // registerMessage("doActive", DoActive.class);

//		registerPbMessage(DoLoginRq.EXT_FIELD_NUMBER, DoLogin.class);
//		registerPbMessage(102, DoRegister.class);
//		registerPbMessage(103, DoActive.class);

        registerPbMessage(DoLoginRq.EXT_FIELD_NUMBER, DoLogin.class, DoLoginRq.ext, DoLoginRs.ext);
        registerPbMessage(DoRegisterRq.EXT_FIELD_NUMBER, DoRegister.class, DoRegisterRq.ext, DoRegisterRs.ext);
        registerPbMessage(DoActiveRq.EXT_FIELD_NUMBER, DoActive.class, DoActiveRq.ext, DoActiveRs.ext);

    }

}
