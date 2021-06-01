package com.game.service;

import com.game.constant.ActivityConst;
import com.game.constant.AwardFrom;
import com.game.constant.AwardType;
import com.game.constant.GameError;
import com.game.dataMgr.StaticActivityDataMgr;
import com.game.domain.ActivityBase;
import com.game.domain.Player;
import com.game.domain.p.Activity;
import com.game.domain.p.Lord;
import com.game.domain.p.Prop;
import com.game.domain.p.QuinnPanel;
import com.game.domain.s.StaticActQuinn;
import com.game.domain.s.StaticActQuinnEasteregg;
import com.game.domain.s.StaticActQuinnRefresh;
import com.game.manager.ActivityDataManager;
import com.game.manager.PlayerDataManager;
import com.game.message.handler.ClientHandler;
import com.game.pb.CommonPb.Award;
import com.game.pb.CommonPb.Quinn;
import com.game.pb.GamePb6.BuyQuinnRs;
import com.game.pb.GamePb6.GetQuinnAwardRs;
import com.game.pb.GamePb6.ShowQuinnRs;
import com.game.util.GameErrorException;
import com.game.util.RandomHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * @ClassName
 * @Description 超时空财团活动play
 * @author 丁文渊
 *
 */
@Service
public class QuinnService {
    @Autowired
    private PlayerDataManager playerDataManager;
    @Autowired
    private StaticActivityDataMgr staticActivityDataMgr;
    @Autowired
    private ActivityDataManager activityDataManager;

    /**
     * 获得商品面板
     * 
     * @param i
     * @param showQuinnHandler
     */
    public void showQuinn(int type, int isRefresh, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || null == player.lord) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_QUINN);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        
        /*取得活动对象并判断活动否存在*/
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_QUINN);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        /*判断活动是否处于开启状态*/
        if (activityBase.getStep() == ActivityConst.OPEN_AWARD) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        
        /*判断type参数是否正常*/
        if (type > 2 || type < 1) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        /*取得面板 如果动作为刷新 则刷新已有面板 动作为进入面板 判断面板是否存在 不存在就初始化*/
        QuinnPanel panel = player.quinnPanels.get(type);
        if(isRefresh == 1 && panel == null){
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }
        boolean newPanel = false;//是否是新的面板
        boolean newQuinn = false;//是否需要更新商品
       
        if (panel == null || activity.getPropMap().get(1040) == null ) { //如果面板不存在 或者 是新的活动
            activity.getPropMap().put(1040, 1) ;
            panel = initQuinnPanel(type, player);
            newPanel = true;
            newQuinn = true;
            player.quinnPanels.put(type, panel);
        } else   if (  isRefresh == 1) { //面板存在  但是点的刷新按钮
            try {
                refreshQuinnPanel(panel, player);
            } catch (GameErrorException e) {
                handler.sendErrorMsgToPlayer(e.getGameError());
                return;
            }
            newQuinn = true;
        } 
       
        if( isNewDay(panel, player) && !newPanel) {  //已是新的一天并且 并且不是新初始化的面板
            initQuinnPanelProp(panel, player);
            if( activityBase.getStaticActivity().getClean() == 1){//根据配置  第二天要不要刷新货物
           // if( true){
                newQuinn = true;
            }
        }
        
        if (newQuinn) {
            panel.setQuinns(makeQuinns(type, player, activityBase.getPlan().getAwardId()));
        }else if( type == 1 && player.lord.getVip() > 5 && panel.getQuinns().size() < 4){
            panel.getQuinns().add(addQuinn(4, activityBase.getPlan().getAwardId()));
        }

        //加入商品
       
        
        //除了刷新类型为免费刷新并且免费次数大于0以外       判断刷新币来决定是不是金币刷新
        if(panel.getGetType() != 1 || panel.getGetNumber() < 1 ){
	      
            if (playerDataManager.checkPropIsEnougth(player, AwardType.PROP, 493, 1)) {
            	panel.setGetType(2);
            } else {
            	panel.setGetType(3);
            }
	       
        }

        ShowQuinnRs.Builder buider = ShowQuinnRs.newBuilder();
        buider.addAllQuinn(panel.getQuinns());
        buider.setGetType(panel.getGetType());
        buider.setGetNumber(panel.getGetNumber());
        
        

        // 刷新类型为金币刷新时
        if (panel.getGetType() == 3) {
            // 根据金币刷新次数得到当前刷新费用
            StaticActQuinnRefresh staticActQuinnRefresh = staticActivityDataMgr.getStaticActQuinnRefreshMap().get(type);
            buider.setGetPrice(staticActQuinnRefresh.givePrice(panel.getGetNumber()));
        }
        if (panel.getType() == 2) {
            Prop prop = player.props.get(492);
            buider.setHasStars(prop == null ? 0 : prop.getCount());
        }
        // 当前刷新奖励 可能为空
        if (panel.getAwards() != null) {
            buider.addAllAward(fixAwards(panel.getAwards()));
        }
        // 当前剩余金币
        buider.setHasMoney(player.lord.getGold());
        // 当前剩余刷新币
        Prop prop = player.props.get(493);
        buider.setHasRefreshes(prop == null ? 0 : prop.getCount());
        handler.sendMsgToPlayer(ShowQuinnRs.ext, buider.build());

    }
    
    private List<Award> fixAwards(List<Award> awards) {
        return awards;
    }


    /**
     * 消耗刷新币刷新
     * 
     * @param quinnPanel
     * @param player
     * @throws GameErrorException
     */
    public void refreshByProp(QuinnPanel quinnPanel, Player player) throws GameErrorException {
        if (!playerDataManager.checkPropIsEnougth(player, AwardType.PROP, 493, 1)) {
            throw new GameErrorException(GameError.PROP_NOT_ENOUGH);
        }
        playerDataManager.subProp(player, AwardType.PROP, 493, 1, AwardFrom.REFRESH_QUINNPANEL);
       
    }

    /**
     * 消耗金币刷新
     * 
     * 下午2:15:07
     * 
     * @throws GameErrorException
     */
    private void refreshByGold(QuinnPanel quinnPanel, Player player) throws GameErrorException {
        StaticActQuinnRefresh staticActQuinnRefresh = staticActivityDataMgr.getStaticActQuinnRefreshMap()
                .get(quinnPanel.getType());
        int sub = staticActQuinnRefresh.givePrice(quinnPanel.getGetNumber());
        Lord lord = player.lord;
        if (lord.getGold() < sub) {
            throw new GameErrorException(GameError.PROP_NOT_ENOUGH);
        }
        playerDataManager.subGold(player, sub, AwardFrom.REFRESH_QUINNPANEL);
     

    }

    /**
     * 刷新商品面板
     * 
     * @param quinnPanel
     * @param player
     * @throws GameErrorException
     */
    public void refreshQuinnPanel(QuinnPanel quinnPanel, Player player) throws GameErrorException {

        switch (quinnPanel.getGetType()) {
            case 1:
                quinnPanel.setGetNumber(quinnPanel.getGetNumber() - 1);

                break;
            case 2:
                refreshByProp(quinnPanel, player);
                quinnPanel.setGetNumber(quinnPanel.getGetNumber() + 1);
                if (quinnPanel.getType() == 2) {
                    makeEgg(quinnPanel);
                }
                break;
            case 3:
                refreshByGold(quinnPanel, player);
                quinnPanel.setGetNumber(quinnPanel.getGetNumber() + 1);
                if (quinnPanel.getType() == 2) {
                    makeEgg(quinnPanel);
                }
                break;
            default:
                break;
        }

    }

    /**
     * 初始化面板属性
     * 
     * @param type
     * @param player
     * @return
     */
    private QuinnPanel initQuinnPanelProp(QuinnPanel quinnPanel, Player player) {
  
        // 贸易面板从免费刷新1开始 兑换没有免费刷新
        int getType = 1;
        int getNumber = 5;
        if (quinnPanel.getType() == 2) {
            if (playerDataManager.checkPropIsEnougth(player, AwardType.PROP, 493, 1)) {
                getType = 2;
            } else {
                getType = 3;
            }
            getNumber = 0;
        }
        quinnPanel.setGetType(getType);
        quinnPanel.setGetSum(0);
        quinnPanel.setGetNumber(getNumber);
        quinnPanel.setEggId(0);
        return quinnPanel;
    }
    
    /**
     * 初始化面板
     * 
     * @param type
     * @param player
     * @return
     */
    private QuinnPanel initQuinnPanel(int type, Player player) {
        QuinnPanel quinnPanel = new QuinnPanel();
        quinnPanel.setType(type);
        initQuinnPanelProp(quinnPanel, player);
        
        return quinnPanel;
    }

    /**
     * 实例化商品
     */
    private Quinn addQuinn(int type, int awardId) {
        StaticActQuinn staticActQuinn = staticActivityDataMgr.randomQuinn(awardId, type);
        Quinn.Builder quinn = Quinn.newBuilder();
        quinn.setType(staticActQuinn.getItem()[0]);
        quinn.setId(staticActQuinn.getItem()[1]);
        quinn.setCount(staticActQuinn.getItem()[2]);
        quinn.setDesc(staticActQuinn.getDesc());
        quinn.setSold(0);
        quinn.setDis(randomDis(staticActQuinn.getDiscount()));
        quinn.setPrice(disPrice(staticActQuinn.getPrice(), quinn.getDis()));
        quinn.setEspecial(staticActQuinn.getEspecial());
        return quinn.build();
    }

    /**
     * 装载商品
     */
    private List<Quinn> makeQuinns(int type, Player player,int awardId) {
        int num = 3;
        List<Quinn> list = new ArrayList<>();
        if (type == 1) {
            if (player.lord.getVip() > 5) {
                num = 4;
            }
            for (int j = 1; j < num + 1; j++) {

                list.add(addQuinn(j, awardId));
            }
        } else {
            list.add(addQuinn(100, awardId));
        }
        return list;
    }

    /**
     * 是否产生彩蛋
     * 
     * @return
     */

    /**
     * 是否产生彩蛋
     * 
     * @return
     */
    public void makeEgg(QuinnPanel panel) {
        List<StaticActQuinnEasteregg> staticActQuinnEastereggList = staticActivityDataMgr
                .getStaticActQuinnEastereggMap().get(panel.getType());

        List<Award> list = new ArrayList<>();
        int num = (panel.getType() == 1) ? panel.getGetSum() : panel.getGetNumber();
        for (StaticActQuinnEasteregg staticActQuinnEasteregg : staticActQuinnEastereggList) {
            if (staticActQuinnEasteregg.getNumber() <= panel.getEggId()) {
                continue;
            }
            if (staticActQuinnEasteregg.getNumber() <= num) {
                Integer[][] eggs = staticActQuinnEasteregg.getAwards();
                for (Integer[] integers : eggs) {
                    Award.Builder award = Award.newBuilder();
                    award.setType(integers[0]);
                    award.setId(integers[1]);
                    award.setCount(integers[2]);
                    list.add(award.build());
                }

                panel.setEggId(staticActQuinnEasteregg.getNumber());
            } else {
                break;
            }
        }
		if (list.size() > 0) {
            panel.setAwards(list);
        }
    }

    /**
     * 计算折扣价格
     * 
     * @return
     */
    public static int disPrice(double price, int dis) {
        return (int) Math.ceil(price / 10 * dis);
    }

    /**
     * 随机产生折扣
     * 
     * @return
     */
    public int randomDis(Integer[][] array) {
        int random = 0;
        for (Integer[] dis : array) {
            random += dis[1].intValue();
        }
        random = RandomHelper.randomInSize(random);
        int total = 0;
        for (Integer[] dis : array) {
            total += dis[1].intValue();
            if (random <= total) {
                return dis[0].intValue();
            }
        }
        return 1;
    }

    /**
     * 购买商品
     * 
     * @param type
     * @param buyQuinn
     */
    public void buyQuinn(int type, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || null == player.lord) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_QUINN);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_QUINN);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        if (activityBase.getStep() == ActivityConst.OPEN_AWARD) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        QuinnPanel quinnPanel;
        Quinn quinn;
        BuyQuinnRs.Builder buider = BuyQuinnRs.newBuilder();
        if (type > 0 && type < 5) {// 购买贸易面板物品
            quinnPanel = player.quinnPanels.get(1);
            quinn = quinnPanel.getQuinns().get(type - 1);
            Lord lord = player.lord;
            if (lord.getGold() < quinn.getPrice()) {
                handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
                return;
            }
            if (quinn.getSold() == 1) {
                handler.sendErrorMsgToPlayer(GameError.HAS_SOLD);
                return;
            }
            playerDataManager.subGold(player, quinn.getPrice(), AwardFrom.QUINNPANEL_BUY);
            buider.setHasMoney(lord.getGold());
            // 增加物品
            playerDataManager.addAward(player, quinn.getType(), quinn.getId(), quinn.getCount(), AwardFrom.QUINNPANEL_BUY);
            Award.Builder award = Award.newBuilder();
            award.setType(quinn.getType());
            award.setId(quinn.getId());
            award.setCount(quinn.getCount());
            buider.addAward(award.build());
            List<Quinn> newquinn = new ArrayList<>();
            List<Quinn> oldquinn = quinnPanel.getQuinns();
            for (int i = 0; i < oldquinn.size(); i++) {
                if (i == type - 1) {
                    newquinn.add(quinn.toBuilder().setSold(1).build());
                } else {
                    newquinn.add(oldquinn.get(i));
                }
            }
            quinnPanel.setQuinns(newquinn);

        } else if (type == 100) {// 购买兑换面板物品
            quinnPanel = player.quinnPanels.get(2);
            quinn = quinnPanel.getQuinns().get(0);
            if (!playerDataManager.checkPropIsEnougth(player, AwardType.PROP, 492, quinn.getPrice())) {
                handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
                return;
            }
            if (quinn.getSold() == 1) {
                handler.sendErrorMsgToPlayer(GameError.HAS_SOLD);
                return;
            }
            buider.setHasMoney((int) playerDataManager
                    .subProp(player, AwardType.PROP, 492, quinn.getPrice(), AwardFrom.QUINNPANEL_BUY).getCount());
            // 增加物品
            playerDataManager.addAward(player, quinn.getType(), quinn.getId(), quinn.getCount(),
                    AwardFrom.QUINNPANEL_BUY);
            Award.Builder award = Award.newBuilder();
            award.setType(quinn.getType());
            award.setId(quinn.getId());
            award.setCount(quinn.getCount());
            buider.addAward(award.build());
            List<Quinn> newquinn = new ArrayList<>();
            newquinn.add(quinn.toBuilder().setSold(1).build());
            quinnPanel.setQuinns(newquinn);
        } else {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }
        quinnPanel.setGetSum(quinnPanel.getGetSum() + quinn.getPrice());
        makeEgg(quinnPanel);
        if (quinnPanel.getAwards() != null) {
            buider.addAllEggs(fixAwards(quinnPanel.getAwards()));
        }

        handler.sendMsgToPlayer(BuyQuinnRs.ext, buider.build());
    }

    /**
     * 领取金币刷新奖励
     * 
     */
    public void getQuinnAward(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || null == player.lord) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_QUINN);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_QUINN);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        if (activityBase.getStep() == ActivityConst.OPEN_AWARD) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        GetQuinnAwardRs.Builder buider = GetQuinnAwardRs.newBuilder();

        for (int i = 1; i < 3; i++) {
            QuinnPanel panel = player.quinnPanels.get(i);
            if (panel != null && panel.getAwards() != null) {
                for (Award award : panel.getAwards()) {
                    // 增加物品
                    playerDataManager.addAward(player, award.getType(), award.getId(), (int) award.getCount(),
                            AwardFrom.GET_QUINN_AWARD);
                    buider.addAward(award);
                }
                panel.setAwards(null);
            }
        }
        handler.sendMsgToPlayer(GetQuinnAwardRs.ext, buider.build());
    }

    /**
     * 得到时间yyyyMMdd
     * 
     */
    private int getFormatDay(Long time) {
        SimpleDateFormat format = new SimpleDateFormat("yyyyMMdd");
        if (time == null || time.longValue() == 0) {
            time = System.currentTimeMillis();
        }
        return Integer.parseInt(format.format(new Date(time)));
    }

    /**
     * 根据刷新时间判断是否是到了的一天
     * 
     */
    private boolean isNewDay(QuinnPanel panel, Player player) {
        boolean newDay = false;
        if(panel.getFreshedDate() == 0){
            newDay = true;
        }
        int refreshDate = getFormatDay(panel.getFreshedDate());
        int today = getFormatDay(null);
        newDay = refreshDate < today;
        panel.setFreshedDate(System.currentTimeMillis());
        return newDay;
    }

}
