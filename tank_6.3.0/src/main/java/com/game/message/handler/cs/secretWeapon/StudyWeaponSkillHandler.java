package com.game.message.handler.cs.secretWeapon;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.server.GameServer;
import com.game.service.SecretWeaponService;

/**
 * @author zhangdh
 * @ClassName: StudyWeaponSkillHandler
 * @Description:
 * @date 2017-11-14 16:14
 */
public class StudyWeaponSkillHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb6.StudyWeaponSkillRq req = msg.getExtension(GamePb6.StudyWeaponSkillRq.ext);
        GameServer.ac.getBean(SecretWeaponService.class).studyWeaponSkill(req, this);
    }
}
