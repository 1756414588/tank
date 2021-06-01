package com.game.service;

import com.game.constant.AwardFrom;
import com.game.dataMgr.StaticLordDataMgr;
import com.game.domain.Player;
import com.game.domain.s.StaticFormula;
import com.game.manager.PlayerDataManager;
import com.game.pb.CommonPb;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * @author zhangdh
 * @ClassName: FormulaService
 * @Description: 道具合成类处理
 * @date 2017/4/20 15:07
 */
@Service
public class FormulaService {

    @Autowired
    private PlayerDataManager playerDataManager;

    @Autowired
    private StaticLordDataMgr staticLordDataMgr;

    /**
     * 根据合成公式合成物品
     *
     * @param player
     * @param fla       合成公式
     * @param awardFrom
     * @return
     */
    public boolean product(Player player, StaticFormula fla, List<CommonPb.Atom2> pbCost, AwardFrom awardFrom) {
        //玩家等级不满足条件
        if (player.lord.getLevel() < fla.getLevel()) return false;

        //世界繁荣度等级不满足条件
        int prosLv = staticLordDataMgr.getStaticProsLv(player.lord.getPros()).getProsLv();
        if (prosLv < fla.getProsLv()) return false;

        //消耗的材料检测
        List<List<Integer>> materials = fla.getMaterials();
        if (materials == null || materials.isEmpty()) return false;//合成公式错误
        for (List<Integer> material : materials) {
            if (!playerDataManager.checkPropIsEnougth(player, material.get(0), material.get(1), material.get(2))) {
                return false;
            }
        }
        //扣除材料资源
        for (List<Integer> material : materials) {
            pbCost.add(playerDataManager.subProp(player, material.get(0), material.get(1), material.get(2), awardFrom));
        }

        return true;
    }

}
