package com.game.service;

import com.game.constant.AwardFrom;
import com.game.constant.GameError;
import com.game.constant.ShopConst;
import com.game.dataMgr.StaticShopDataMgr;
import com.game.dataMgr.StaticVipDataMgr;
import com.game.domain.Player;
import com.game.domain.p.Shop;
import com.game.domain.p.ShopBuy;
import com.game.domain.p.TreasureShopBuy;
import com.game.domain.s.StaticTreasureShop;
import com.game.domain.s.StaticVip;
import com.game.domain.s.StaticVipShop;
import com.game.domain.s.StaticWorldShop;
import com.game.manager.PlayerDataManager;
import com.game.manager.StaffingDataManager;
import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb4.BuyTreasureShopRq;
import com.game.pb.GamePb4.BuyTreasureShopRs;
import com.game.pb.GamePb4.GetTreasureShopBuyRs;
import com.game.pb.GamePb5;
import com.game.util.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * @author TanDonghai
 * @ClassName ShopService.java
 * @Description 商店相关服务类
 * @date 创建时间：2016年8月3日 下午3:12:42
 */
@Service
public class ShopService {
    @Autowired
    private PlayerDataManager playerDataManager;

    @Autowired
    private StaticShopDataMgr staticShopDataMgr;

    @Autowired
    private StaticVipDataMgr staticVipDataMgr;

    @Autowired
    private StaffingDataManager staffingDataManager;

    /**
     * 获取宝物商店的商品购买信息
     *
     * @param handler
     */
    public void getTreasureShopBuy(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());

        // 计算今天是开发第几周
        int openServerweek = DateHelper.getServerOpenWeek();
        // 因为荒宝兑换商店的商品是4星期一轮反复，所以对4求余
        int week = openServerweek % 4;
        if (week == 0) {
            week = 4;
        }

        GetTreasureShopBuyRs.Builder builder = GetTreasureShopBuyRs.newBuilder();
        builder.setOpenWeek(week);

        // 获取并计算本周开卖的商品
        List<StaticTreasureShop> shopList = staticShopDataMgr.getTreasureShopByWeek(week);
        if (CheckNull.isEmpty(shopList)) {
            LogUtil.error("荒宝商店的商品未配置, openWeek:" + week);
        } else {
            // 获取已购买本周商品的数量信息
            Iterator<TreasureShopBuy> its = player.treasureShopBuy.values().iterator();
            while (its.hasNext()) {
                TreasureShopBuy buy = its.next();
                if (buy.getBuyWeek() != openServerweek) {
                    its.remove();// 不是本周的商品记录，移除
                    continue;
                }
                builder.addShopBuy(PbHelper.createTreasureShopBuyPb(buy));
            }
        }

        // 返回购买信息
        handler.sendMsgToPlayer(GetTreasureShopBuyRs.ext, builder.build());
    }

    /**
     * 购买宝物商店的商品
     *
     * @param req
     * @param handler
     */
    public void buyTreasureShop(BuyTreasureShopRq req, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());

        // 计算今天是开发第几周
        int openServerweek = DateHelper.getServerOpenWeek();
        // 因为荒宝兑换商店的商品是4星期一轮反复，所以对4求余
        int week = openServerweek % 4;
        if (week == 0) {
            week = 4;
        }

        int treasureId = req.getTreasureId();
        int count = req.getCount();

        if (treasureId <= 0 || count <= 0) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        // 获取商品
        StaticTreasureShop shop = staticShopDataMgr.getTreasureShopById(treasureId);
        if (null == shop) {
            handler.sendErrorMsgToPlayer(GameError.TREASURE_NOT_EXISTS);
            return;
        }

        if (shop.getOpenWeek() != week) {
            handler.sendErrorMsgToPlayer(GameError.TREASURE_WEEK_NOT_MATCH);
            return;
        }

        // 获取已购买本周商品的数量信息
        TreasureShopBuy buy = player.treasureShopBuy.get(treasureId);
        if (null == buy) {
            buy = new TreasureShopBuy();
            buy.setTreasureId(treasureId);
            buy.setBuyWeek(openServerweek);
            player.treasureShopBuy.put(treasureId, buy);
        }

        // 计算玩家是否还有足够的购买次数
        if (shop.getMaxNumber() >= 0 && buy.getBuyNum() + count > shop.getMaxNumber()) {
            handler.sendErrorMsgToPlayer(GameError.TREASURE_SHOP_NUM_LIMIT);
            return;
        }

        // 计算玩家是有足够的货币
        int cost = shop.getCost() * count;
        if (cost > player.lord.getHuangbao()) {
            handler.sendErrorMsgToPlayer(GameError.HUANGBAO_NOT_ENOUGH);
            return;
        }

        // 扣除消耗
        playerDataManager.subHuangbao(player, cost, AwardFrom.TREASURE_SHOP_BUY);

        // 记录购买次数
        buy.setBuyNum(buy.getBuyNum() + count);

        // 增加商品对应的奖励
        int type = shop.getReward().get(0);
        int id = shop.getReward().get(1);
        int num = shop.getReward().get(2);
        playerDataManager.addAward(player, type, id, num, AwardFrom.TREASURE_SHOP_BUY);

        // 返回购买完成信息
        BuyTreasureShopRs.Builder builder = BuyTreasureShopRs.newBuilder();
        builder.setHuangbao(player.lord.getHuangbao());
        handler.sendMsgToPlayer(BuyTreasureShopRs.ext, builder.build());
    }


    /**
     * 获取商城购买记录信息
     *
     * @param req
     * @param handler
     */
    public void getShopInfo(GamePb5.GetShopInfoRq req, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        GamePb5.GetShopInfoRs.Builder builder = GamePb5.GetShopInfoRs.newBuilder();
        for (Map.Entry<Integer, Shop> entry : player.shopMap.entrySet()) {
            Shop shop = entry.getValue();
            checkAndRefreashShop(shop);
            builder.addShop(PbHelper.createShopPb(shop));
        }
        handler.sendMsgToPlayer(GamePb5.GetShopInfoRs.ext, builder.build());
    }


    /**
     * 购买商品
     *
     * @param req
     * @param handler
     */
    public void buyShopGoods(GamePb5.BuyShopGoodsRq req, ClientHandler handler) {
        int sty = req.getSty();//商店类型
        int gid = req.getGid();//商品ID
        int buyCount = req.getCount();//购买次数

        //商城类型不正确
        if (sty != ShopConst.Ty.VIP && sty != ShopConst.Ty.WORLD) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        //购买数量不正确
        if (buyCount < 1 || buyCount > 1000 || gid <= 0) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Shop shop = player.shopMap.get(sty);
        if (shop != null) {
            checkAndRefreashShop(shop);
        }

        boolean buySucc = false;
        if (sty == ShopConst.Ty.VIP) {
            buySucc = buyVipShopGoods(player, shop, sty, gid, buyCount);
        } else {
            buySucc = buyWorldShopGoods(player, shop, sty, gid, buyCount);
        }

        //购买成功
        if (buySucc) {
            GamePb5.BuyShopGoodsRs.Builder builder = GamePb5.BuyShopGoodsRs.newBuilder();
            builder.setGold(player.lord.getGold());
            handler.sendMsgToPlayer(GamePb5.BuyShopGoodsRs.ext, builder.build());
        }
    }

    /**
     * 检测并更新玩家商店购买记录
     *
     * @param shop
     */
    private void checkAndRefreashShop(Shop shop) {
        int day = TimeHelper.getCurrentDay();
        if (shop != null && day != shop.getRefreashTime()) {
            shop.getBuyMap().clear();
            shop.setRefreashTime(day);
        }
    }


    /**
     * 检测VIP商店是否可以购买指定商品
     *
     * @param player
     * @param shopBuy
     * @param buyCount 本次购买次数
     * @return
     */
    private boolean buyVipShopGoods(Player player, Shop shop, int sty, int gid, int buyCount) {
        //购买次数检测
        if (player.lord.getVip() >= 0) {
            StaticVip staticVip = staticVipDataMgr.getStaticVip(player.lord.getVip());
            StaticVipShop staticShop = staticShopDataMgr.getVipShopMap().get(gid);
            if (staticVip == null || staticVip.getBuyShop() <= 0 || staticShop == null) {
                return false;
            }

            // 购买所需VIP等级是否足够
            if (player.lord.getVip() < staticShop.getVipLevel()) {
                return false;
            }

            ShopBuy shopBuy = shop != null ? shop.getBuyMap().get(gid) : null;
            //购买次数是否足够
            int count = buyCount + (shopBuy != null ? shopBuy.getBuyCount() : 0);//购买次数是否足够
            if (staticVip.getBuyShop() < count) {
                return false;
            }

            // 玩家是有足够的货币
            int cost = staticShop.getCost() * buyCount;
            if (cost > player.lord.getGold()) {
                return false;
            }
            buyShopGoods(player, shop, shopBuy, sty, gid, buyCount, cost, staticShop.getReward(), AwardFrom.VIP_SHOP_BUY_GOODS);
            return true;
        }
        return false;
    }

    /**
     * 
    * 购买商店物资逻辑
    * @param player
    * @param shop
    * @param shopBuy
    * @param sty
    * @param gid
    * @param buyCount
    * @param cost
    * @param reward
    * @param awardFrom  
    * void
     */
    private void buyShopGoods(Player player, Shop shop, ShopBuy shopBuy,
                              int sty, int gid, int buyCount, int cost, List<Integer> reward, AwardFrom awardFrom) {
        playerDataManager.subGold(player, cost, awardFrom);
        if (shop == null) {
            player.shopMap.put(sty, shop = new Shop(sty, TimeHelper.getCurrentDay()));
        }
        if (shopBuy == null) {
            shop.getBuyMap().put(gid, shopBuy = new ShopBuy(gid, buyCount));
        } else {
            shopBuy.setBuyCount(shopBuy.getBuyCount() + buyCount);
        }
        playerDataManager.addAward(player, reward.get(0), reward.get(1), reward.get(2) * buyCount, awardFrom);
    }

    /**
     * 检测世界商店是否可以购买指定商品
     *
     * @param player
     * @param shopBuy
     * @param gid      商品ID
     * @param buyCount 本次购买次数
     * @return
     */
    private boolean buyWorldShopGoods(Player player, Shop shop, int sty, int gid, int buyCount) {
        //编制未开放
        if (!TimeHelper.isStaffingOpen()) {
            return false;
        }

        StaticWorldShop staticShop = staticShopDataMgr.getWorldShopMap().get(gid);
        if (staticShop == null) {
            return false;
        }

        //玩家等级是否足够
        if (staticShop.getLevelLimit() > 0 && staticShop.getLevelLimit() > player.lord.getLevel()) {
            return false;
        }

        Map<Integer, List<Integer>> discountAndNmuber = staticShop.getDiscountAndNmuber();
        int lv = staffingDataManager.getWorldLv();
        List<Integer> danList = discountAndNmuber.get(lv);
        if (danList == null || danList.size() < 3) {//[世界等级,折扣万比率,购买次数]
            LogUtil.error(String.format("not found config world lv :%d, world shop discountAndNmuber", lv));
            return false;
        }

        ShopBuy shopBuy = shop != null ? shop.getBuyMap().get(gid) : null;

        //购买次数是否足够
        int count = buyCount + (shopBuy != null ? shopBuy.getBuyCount() : 0);
        if (count > danList.get(2)) return false;


        // 玩家是有足够的货币
        int cost = (int)Math.ceil(staticShop.getPrice() * danList.get(1) / 10000.0F) * buyCount;
        if (cost > player.lord.getGold()) {
            return false;
        }
        buyShopGoods(player, shop, shopBuy, sty, gid, buyCount, cost, staticShop.getReward(), AwardFrom.WORLD_SHOP_BUY_GOODS);
        return true;
    }

}
