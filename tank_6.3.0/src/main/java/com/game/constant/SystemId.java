package com.game.constant;

/**
 * @ClassName SystemId.java
 * @Description 全局常量配置表id配置信息
 * @author TanDonghai
 * @date 创建时间：2016年9月3日 上午11:40:22
 *
 */
public class SystemId {
    private SystemId() {
    }

    /** 叛军入侵活动首次开启条件，开服第几天 */
    public static final int REBEL_FIRST_OPEN_DAY = 1;

    /** 叛军入侵活动开启日期（星期几），多个日期用半角逗号分割 ps:2,4 */
    public static final int REBEL_OPEN_WEEK_DAY = 2;

    /** 叛军入侵活动开启时间，格式:mm:ss，多个时间用半角逗号分割 ps:12:00,18:00 */
    public static final int REBEL_OPEN_TIME = 3;

    /** 叛军入侵活动持续时长，单位：秒 */
    public static final int REBEL_DURATION = 4;

    /** 叛军入侵活动，将领按类型掉落上限：分队 */
    public static final int UNIT_DROP_LIMIT = 5;

    /** 叛军入侵活动，将领按类型掉落上限：卫队 */
    public static final int GUARD_DROP_LIMIT = 6;

    /** 叛军入侵活动，将领按类型掉落上限：领袖 */
    public static final int LEADER_DROP_LIMIT = 7;

    /** 服务器当前玩家等级上限 */
    public static final int MAX_ROLE_LEVEL = 8;

    /** 单次叛军活动，可击杀叛军数上限 */
    public static final int KILL_REBEL_LIMIT = 9;

    /** 叛军两种类型之间出现的间隔时间，单位：秒 */
    public static final int REBEL_DELAY = 10;

    /** 勋章温养总冷却时间,单位：s */
    public static final int MEDAL_UP_TIME_MAX = 11;

    /** 勋章温养单次花费时间，单位：s */
    public static final int MEDAL_UP_TIME = 12;

    /** 勋章温养每次的基础经验 */
    public static final int MEDAL_UP_ADD_EXP = 13;

    /** 奥古斯特复活部队数量权重 */
    public static final int HERO_REBORN_WEIGHT = 14;

    /** 玩家离线超过配置时间，自产为0 */
    public static final int RESOURCE_STOP_ADD_OFFTIME = 15;

    /** 配件最高改造等级 */
    public static final int MAX_PART_REFIT_LV = 16;

    /** 配件最高强化等级 */
    public static final int MAX_PART_UP_LV = 17;

    /** 勋章位置开放等级 */
    public static final int MEDAL_POS_OPEN_LV = 18;

    /** 角色最高等级 */
    public static final int PLAYER_OPEN_LV = 19;

    /** 装备等级上限 */
    public static final int EQUIP_OPEN_LV = 20;

    /** 科技等级上限 */
    public static final int SCIENCE_OPEN_LV = 21;

    /** 勋章升级等级上限 */
    public static final int MEDAL_UP_OPEN_LV = 22;

    /** 勋章打磨等级上限 */
    public static final int MEDAL_REFIT_OPEN_LV = 23;

    /** 废墟影响载重减少率 万分率 */
    public static final int RUINS_LOAD_REDUCE = 24;

    /** 废墟状态金币恢复所需值 */
    public static final int RUINS_RECOVER = 25;

    /** 合服后赠送防护罩的持续时间 */
    public static final int MERGE_GAME_BUFF_FREE_TIME = 26;

    /** 世界地图矿点功能开放服务器列表 */
    public static final int WORLD_MINE_OPEN_SERVERS = 27;

    /** 侦查水晶消耗等级差系数 */
    public static final int SCOUT_lV_DIFF_RATIO = 28;

    /** 侦查水晶消耗次数梯度系数 */
    public static final int SCOUT_COUNT_RATIO = 29;

    /** 飞艇战事准备时间 */
    public static final int AIRSHIP_BEGAIN_SECOND = 30;

    /** 飞艇进攻默认行军时间 */
    public static final int AIRSHIP_ATTACK_MARCH_SECOND = 31;

    /** 飞艇部队进攻增加时间 */
    public static final int AIRSHIP_ATTACK_MARCH_ADD_SECOND = 32;

    /** 飞艇进攻部队撤回时间 */
    public static final int AIRSHIP_ATTACK_RETREAT_SECOND = 33;

    /** 飞艇驻军撤回时间 */
    public static final int AIRSHIP_GUARD_RETREAT_SECOND = 34;

    /** 飞艇部队永久损失比例 */
    public static final int AIRSHIP_HAUST_TANK_RATIO = 35;

    /** 飞艇部队进攻失效返回 */
    public static final int AIRSHIP_ATTACK_FAIL_RETREAT_SECOND = 36;

    /** 飞艇部队驻军行军时间 */
    public static final int AIRSHIP_GUARD_MARCH_SECOND = 37;

    /** 军备材料生产速度计算因子 */
    public static final int LORD_EQUIP_MAT_FACTOR = 38;

    /** 飞艇成功占领后的安全时间 */
    public static final int AIRSHIP_SAFE_TIME = 39;

    /** 军备功能开启等级 */
    public static final int LORD_EQUIP_OPEN_LV = 40;

    /** 军功每天获取上限 */
    public static final int MPLT_LIMIT_EVERY_DAY = 41;

    /** 最强实力系数 */
    public static final int STRONGEST_FORM_FIGHT_CALC_F = 43;


    /** 设备侦查、攻击矿点记录日志打印阈值 */
    public static final int LOG_SCOUT_MINE_COUNT = 46;

    /** Sentry服务器URL */
    public static final int SENTRY_DSN = 47;

    /** 秘密武器*/
    public static final int SECRET_WEAPON = 48;

    /** 跨服战等级限制 */
    public static final int CROSS_REG_LEVEL = 50;

    /**扫矿外挂识别配置*/
    public static final int SCOUT_MINE_PLUG_IN = 51;

    /** IP白名单*/
    public static final int WHITE_IPS = 52;

    /** 保存优化功能开关 */
    public static final int SAVE_OPTIMIZE_SWITCH = 53;

    /** 保存优化功能配置数据 */
    public static final int SAVE_OPTIMIZE_CONFIG = 54;

    /** 服务器状态日志打印周期 */
    public static final int SERVER_STATUS_LOG_PERIOD = 55;
    
    /** 叛军来袭礼盒触发概率 */
    public static final int REBEL_BOX_PROB = 56;
    
    /** 叛军来袭礼盒领取等级 */
    public static final int GET_BOX_LEVEL = 57;
    
    /** 叛军来袭礼盒初始个数 */
    public static final int BOX_INIT_COUNT = 58;
    
    /** 叛军来袭礼盒每人每天领取个数 */
    public static final int BOX_DAILY_LIMIT = 59;
    
    /** 叛军来袭世界金币红包个数 */
    public static final int WORLD_REDBAG_COUNT = 60;
    
    /** 作战实验室，军工科技重置重置科技需要vip等级 */
    public static final int LAB_VIP = 61;
    
    /** 低等级经验加成BUFF 格式：[[目标等级，加成系数]，[],...]*/
    public static final int LEVEL_EXP_BUFF = 62;
    
    /** 上个版本的最大等级限制 */
    public static final int LAST_MAX_LEVEL = 63;

    /**
     *勋章打磨十级激活特效：增加该勋章升级属性系数
     */
    public static final int MEDAL_RATE = 64;

    /**
     *每日掠夺金币数量上限
     */
    public static final int HERO_GOLD = 65;

    /**
     *破罩将领技能冷却时间
     */
    public static final int NEW_HERO_CD = 66;

    /**
     *破罩将领每日次数
     */
    public static final int NEW_HERO_COUNT = 67;

    /**
     *破罩将领清cd价格
     */
    public static final int NEW_HERO_CD_PRICE = 68;
    /**
     * 触发验证的侦查次数
     */
    public static final int VCODE_SCOUT_COUNT = 69;

    /**
     * 友好度上限
     */
    public static final int FRIENDLINESS_MAX = 70;

    /**
     * 可以赠送道具的友好度
     */
    public static final int CAN_GIVE_PROP_FRIENDLINESS_MAX = 71;

    /**
     * 支持赠送的道具范围
     */
    public static final Integer GIVE_PROPS = 72;

    /**
     * 好友之间每月赠送次数
     */
    public static final Integer FRIEND_MONTH_GIVE_COUNT = 73;

    /**
     * 每月最大赠送次数
     */
    public static final Integer FRIEND_MONTH_GIVE_MAX_COUNT= 74;

    /**
     * 9-10号配件合成所需的最少本体碎片数
     */
    public static final int NINE_TEN_PART_COMBINE_CHIP_COUNT = 75;

    /**
     * 赠送功能所需的等级限制
     */
    public static final int FRIEND_GIVE_PROP_LV_LIMIT = 76;

    /**
     * 友好度提升掠夺资源量
     */
    public static final int FRIENDLIESS_RESOURCE_RATE = 77;

    public static final int REBEL_HP = 78;

    public static final int REBEL_TYPE_BOOS_REDBAG = 79;

    public static final int ENERGY_CORE_UNLOCK=80;

    /**
     * 跨服军矿解锁要求
     */
    public static final int CROSSMINE_UNLOCK=81;

    /**
     * 领取服务器排行奖励最低积分要求
     */
    public static final int CROSSMINE_AWARD_UNLOCK=82;
}
