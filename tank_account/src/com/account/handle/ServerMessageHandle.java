package com.account.handle;

import com.account.msg.impl.server.*;
import com.game.pb.InnerPb;
import com.game.pb.InnerPb.BackBuildingRq;
import com.game.pb.InnerPb.BackBuildingRs;
import com.game.pb.InnerPb.BackEquipRq;
import com.game.pb.InnerPb.BackEquipRs;
import com.game.pb.InnerPb.BackFormRq;
import com.game.pb.InnerPb.BackFormRs;
import com.game.pb.InnerPb.BackLordBaseRq;
import com.game.pb.InnerPb.BackLordBaseRs;
import com.game.pb.InnerPb.BackPartRq;
import com.game.pb.InnerPb.BackPartRs;
import com.game.pb.InnerPb.BackPartyMembersRq;
import com.game.pb.InnerPb.BackPartyMembersRs;
import com.game.pb.InnerPb.BackRankBaseRq;
import com.game.pb.InnerPb.BackRankBaseRs;
import com.game.pb.InnerPb.PayConfirmRq;
import com.game.pb.InnerPb.PayConfirmRs;
import com.game.pb.InnerPb.RegisterRq;
import com.game.pb.InnerPb.RegisterRs;
import com.game.pb.InnerPb.ServerErrorLogRq;
import com.game.pb.InnerPb.ServerErrorLogRs;
import com.game.pb.InnerPb.UseGiftCodeRq;
import com.game.pb.InnerPb.UseGiftCodeRs;
import com.game.pb.InnerPb.VerifyRq;
import com.game.pb.InnerPb.VerifyRs;

public class ServerMessageHandle extends MessageHandle {

    @Override
    public void addMessage() {
        // TODO Auto-generated method stub
        // registerMessage("doVerify", DoVerify.class);
        // registerMessage("registerServer", RegisterServer.class);
        registerMessage("getGmMails", GetGmMails.class);
        registerMessage("writeGmMail", WriteGmMail.class);
        registerMessage("modifyGmMail", ModifyGmMail.class);

        registerPbMessage(VerifyRq.EXT_FIELD_NUMBER, DoVerify.class, VerifyRq.ext, VerifyRs.ext);
        registerPbMessage(RegisterRq.EXT_FIELD_NUMBER, RegisterServer.class, RegisterRq.ext, RegisterRs.ext);
        registerPbMessage(UseGiftCodeRq.EXT_FIELD_NUMBER, UseGiftCode.class, UseGiftCodeRq.ext, UseGiftCodeRs.ext);
        registerPbMessage(PayConfirmRq.EXT_FIELD_NUMBER, PayConfirm.class, PayConfirmRq.ext, PayConfirmRs.ext);
        registerPbMessage(BackLordBaseRq.EXT_FIELD_NUMBER, BackLordBase.class, BackLordBaseRq.ext, BackLordBaseRs.ext);
        registerPbMessage(BackBuildingRq.EXT_FIELD_NUMBER, BackBuilding.class, BackBuildingRq.ext, BackBuildingRs.ext);
        registerPbMessage(BackPartRq.EXT_FIELD_NUMBER, BackPart.class, BackPartRq.ext, BackPartRs.ext);
        registerPbMessage(BackEquipRq.EXT_FIELD_NUMBER, BackEquip.class, BackEquipRq.ext, BackEquipRs.ext);
        registerPbMessage(BackRankBaseRq.EXT_FIELD_NUMBER, BackRankBase.class, BackRankBaseRq.ext, BackRankBaseRs.ext);
        registerPbMessage(BackPartyMembersRq.EXT_FIELD_NUMBER, BackPartyMembers.class, BackPartyMembersRq.ext, BackPartyMembersRs.ext);
        registerPbMessage(BackFormRq.EXT_FIELD_NUMBER, BackForm.class, BackFormRq.ext, BackFormRs.ext);
        registerPbMessage(ServerErrorLogRq.EXT_FIELD_NUMBER, ServerErrorLog.class, ServerErrorLogRq.ext, ServerErrorLogRs.ext);
        registerPbMessage(InnerPb.BackEnergyRq.EXT_FIELD_NUMBER, BackEnergy.class, InnerPb.BackEnergyRq.ext, InnerPb.BackEnergyRs.ext);



    }
}
