package com.game.util;

import com.alibaba.fastjson.JSON;
import com.game.domain.p.Award;
import com.game.domain.p.Mail;
import com.game.domain.p.NewMail;
import com.game.pb.CommonPb;

import java.util.Arrays;
import java.util.LinkedList;
import java.util.List;

/**
 * @ClassName:MailHelper
 * @author zc
 * @Description:
 * @date 2017年9月30日
 */
public class MailHelper {
    /**
     * 以Mail创建一个NewMail对象
     * 
     * @param mail
     * @return
     */
    public static NewMail createNewMail(long lordId, Mail mail) {
        NewMail newMail = new NewMail();
        newMail.setLordId(lordId);
        newMail.setKeyId(mail.getKeyId());
        newMail.setType(mail.getType());
        newMail.setMoldId(mail.getMoldId());
        newMail.setTitle(mail.getTitle());
        newMail.setSendName(mail.getSendName());
        newMail.setToName(mail.getToName());
        newMail.setState(mail.getState());
        newMail.setContont(mail.getContont());
        newMail.setTime(mail.getTime());
        newMail.setLv(mail.getLv());
        newMail.setVipLv(mail.getVipLv());
        newMail.setCollections(mail.getCollections());

        if (mail.getParam() != null && mail.getParam().length > 0) {
            newMail.setParam(Arrays.asList(mail.getParam()));
        }

        //附件存为json格式
        if (mail.getAward() != null && !mail.getAward().isEmpty()) {
            List<CommonPb.Award> awards = mail.getAward();
            List<Award> newAwards = new LinkedList<>();
            for (CommonPb.Award awardPb : awards) {
                Award award = new Award(awardPb.getType(), awardPb.getId(), (int) awardPb.getCount(), awardPb.getKeyId());
                if (!awardPb.getParamList().isEmpty()) {
                    award.setParam(awardPb.getParamList());
                }
                newAwards.add(award);
            }

            newMail.setAward(JSON.toJSONString(newAwards));
        }

        if (mail.getReport() != null) {
            newMail.setReport(mail.getReport().toByteArray());
        }
        return newMail;
    }
}
