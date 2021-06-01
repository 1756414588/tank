package com.game.constant;

/**
 * @author ChenKui
 * @version 创建时间：2015-9-19 上午11:57:38
 * @declare
 */
public class MailType {

  public static final int NORMAL_MAIL = 1;
  public static final int SEND_MAIL = 2;
  public static final int REPORT_MAIL = 3;
  public static final int SYSTEM_MAIL = 4;
  public static final int ARENA_MAIL = 5;
  public static final int ARENA_GLOBAL_MAIL = 6;

  public static final int STATE_UNREAD = 1; // 未读
  public static final int STATE_READ = 2; // 已读
  public static final int STATE_UNREAD_ITEM = 3; // 含附件未读
  public static final int STATE_READ_ITEM = 4; // 含附件已读
  public static final int STATE_NO_ITEM = 5; // 附件已读已领取

  public static final int MOLD_GUARD = 1; // 驻军:参数{s}
  public static final int MOLD_RETREAT = 2; // 驻军遣返：参数{s}
  public static final int MOLD_HOLD = 3; // 资源占领：参数{s}
  public static final int MOLD_FRIEND_ADD = 4; // 添加好友：参数{s}
  public static final int MOLD_CONCEDE = 5; // 军团长让位：参数{s,s}
  public static final int MOLD_ENTER_PARTY = 6; // 进入军团：参数{s}
  public static final int MOLD_TARGET_GONE = 7; // 原玩家已搬迁：参数{s} 坐标
  // public static final int MOLD_RUINS = 8;// 军团长让位：参数{s,s}
  public static final int MOLD_RUINS = 8; // 废墟提醒:尊敬的指挥官 您的基地被|%s|打成废墟了

  public static final int MOLD_SCOUT_PLAYER = 9; // 侦查玩家：参数{s,s}
  public static final int MOLD_ATTACK_PLAYER = 10; // 攻击玩家：参数{s,s}
  public static final int MOLD_DEFEND = 11; // 遭受攻击：参数{s,s}

  public static final int MOLD_FREE_ATTACK = 16; // 掠夺返回:%s|使用了护罩，保护期内不可侦查或者攻击，你的部队正在返回

  public static final int MOLD_CLEAN_MEMBER = 17; // 清理帮派成员：参数{s}

  public static final int MOLD_SCOUT_MINE = 18; // 侦查矿：参数{s,s}
  public static final int MOLD_ATTACK_MINE = 19; // 攻击矿：参数{s,s}

  public static final int MOLD_AID_GONE = 20; // 驻军遣返:原|%s|的玩家基地已迁往其他地方，您的驻军被直接遣返

  public static final int MOLD_WIPE = 21; // 扫荡奖励：参数{s,s}
  public static final int MOLD_GOLD = 22; // 财政官收入：参数{s,s}
  public static final int MOLD_RED_PACKET = 23; // 土豪的赠礼：参数{s}
  public static final int MOLD_AMY_PROP = 24; // 团长的分配,由于您骁勇善战，军团长|%s|分配您了如下奖励，请继续为军团战斗吧！

  public static final int MOLD_SCOUT_SUCCESS = 25; // 使用成功，你侦查的指挥官|%s|占领中的矿点为：|%s|级|%s|%s
  public static final int MOLD_SCOUT_FAIL = 26; // 使用成功，你查找的指挥官|%s|没有占领中的矿点
  public static final int MOLD_SCOUT = 27; // 使用成功，你侦查的指挥官|%s|在|%s|

  public static final int MOLD_WELCOME_MUZHI = 28; // 欢迎指挥官

  public static final int MOLD_ARENA_1 = 29; // %s挑战%s失败(全服)
  public static final int MOLD_ARENA_2 = 30; // %s挑战%s成功(全服)

  public static final int MOLD_ARENA_3 = 31; // 你挑战%s成功|
  public static final int MOLD_ARENA_4 = 32; // 你挑战%s失败
  public static final int MOLD_ARENA_5 = 33; // %s挑战你成功
  public static final int MOLD_ARENA_6 = 34; // %s挑战你失败

  public static final int MOLD_SYSTEM_1 = 35; // 尊敬的指挥官，您参与了|%s|，现在为您奉上奖励，快快提取吧！
  public static final int MOLD_SYSTEM_2 = 36; // 尊敬的指挥官，很抱歉耽误您宝贵的时间，现在为您奉上补偿，快快提取吧！
  public static final int MOLD_SYSTEM_3 = 37; // 尊敬的指挥官，现在为您补充了物资，快快提取吧！

  public static final int MOLD_FIRST_PAY = 38; // 尊敬的指挥官，这是属于您的首冲豪礼，快快提取吧！
  public static final int MOLD_PAY_DONE =
      39; // 尊敬的指挥官，您充值的|%s|金币（实充|%s|金币+赠送|%s|金币）已经到账，请您查收，祝您游戏愉快！

  public static final int MOLD_ACT_1 = 40; // 充值丰收
  // (尊敬的指挥官，您获得了|%s|金币的充值返利和|%s|的水晶奖励，请您查收，祝您游戏愉快！)

  public static final int MOLD_SYSTEM_PUB_1 = 41; // 系统公告

  public static final int MOLD_ACT_2 = 42; // 连续充值(尊敬的指挥官，您获得了|%s|金币的充值返利，请您查收，祝您游戏愉快！)

  public static final int MOLD_SYSTEM_PUB_2 = 43; // 系统公告(带附件)

  public static final int MOLD_PARTY_WAR =
      44; // 您个人获得了|%s|连胜的成绩，获得|%s|军团贡献奖励！（军团排名前10奖励，直接发放到军团福利院-战事福利，请关注！）损失坦克：|%s|

  public static final int MOLD_KILL_BOSS = 45; // 您完成了对V3重装坦克的击杀，获得了|%s|奖励

  public static final int MOLD_HURT_BOSS = 46; // 您摧毁了V3重装坦克的炮口，获得了|%s|奖励

  public static final int MOLD_WELCOME_ANFAN = 47; // 欢迎指挥官安峰

  public static final int MOLD_WELCOME_CAOHUA = 48; // 欢迎指挥官草花

  public static final int MOLD_GM_1 = 49; // GM自定义邮件
  public static final int MOLD_GM_2 = 50; // GM自定义系统邮件

  public static final int MOLD_SENIOR_MINE_DEFEND = 51; // 军事矿区遭受攻击
  public static final int MOLD_SENIOR_MINE_SCOUT = 52; // 军事矿区侦察报告
  public static final int MOLD_SENIOR_MINE_ATTACK = 53; // 军事矿区攻击

  public static final int MOLD_WELCOME_CAOHUA_YH = 54; // 欢迎草花yh
  public static final int MOLD_WELCOME_FANGPIAN = 55; // 防骗邮件

  public static final int MOLD_PARTY_NAME_CHAGE = 56; // 军团名变更

  public static final int MOLD_FORTRESS_DEFANCE_Invitation =
      58; // 要塞战邀请(由于您和军团骁勇善战，军团已经获得了参与本周六的要塞战资格，本周您的百团大战军团积分排名为|%s|,将会防守要塞。请继续为军团战斗吧！)
  public static final int MOLD_FORTRESS_ATTACK_Invitation = 59;
  public static final int MOLD_FORTRESS_Rward =
      60; // 要塞战奖励(您个人获得了|%s|积分的成绩，获得|%s|军团贡献奖励！（军团排名奖励，直接发放到军团福利院-战事福利，请关注！）损失坦克：|%s|
  public static final int MOLD_FORTRESS_JOB_APPOINT =
      61; // 尊敬的要塞主：|%s|，将您任命为：|%s|，从即刻开始实行。持续时间：|%s|。在此段时间内将获得：|%s|的效果。
  public static final int MOLD_FORTRESS_KING_REWARD = 62; // 您的军团获得了最终的胜利，获得BUFF：|%s|持续时间:|%s|天。
  public static final int MOLD_FORTRESS_JOB_REWAD = 63; // 尊敬的|%s|，这里是今日的收入，请查收。
  public static final int MOLD_WELCOME =
      64; // 报告指挥官，非常感谢您及时来到前线战场，当前我军遭受到各方攻击，战况紧急，正在等您发号施令，突破重围！\n加Q群即可与万千指挥官一起分析最新军情动态，排兵布阵，攻城掠地。同时还可领取指挥官限定礼包！\n官方交流QQ群：573291506\n问题咨询或疑难杂症解决专家QQ：4009611191\n祝您游戏愉快！
  public static final int MOLD_PART_ALTAR_BOSS_SUCCESS = 65; // 参与军团BOSS活动，并胜利的参与奖励,
  // 由于参与了祭坛BOSS的挑战，您获得了的奖励。
  public static final int MOLD_PART_ALTAR_BOSS_FAIL = 66; // 参与军团BOSS活动，但是失败的参与奖励,
  // 由于您的军团准备不足祭坛BOSS已逃跑，您获得了部分奖励。
  public static final int MOLD_KILL_ALTAR_BOSS = 67; // 击杀军团BOSS,
  // 您完成了对祭坛BOSS的击杀，获得了奖励。
  public static final int MOLD_ALTAR_BOSS_RANK_REWARD = 68; // 军团BOSS排名奖励,
  // 您在本次祭坛BOSS挑战中，伤害排名第|%s|，获得了奖励

  public static final int MOLD_CROSS_PLAN =
      78; // 尊敬的指挥官，您所在的服务器将于|%s|进行跨服战活动。竞技场排名前|%s|名的玩家可以参与巅峰组，排名前|%s|名的玩家可以参与精英组赛事。请留意活动日期。
  public static final int MOLD_CROSS_REG = 79; // 尊敬的指挥官，您所在的服务器已经开始进行跨服战报名。您已获取报名资格，请前往跨服战页面进行报名
  public static final int MOLD_JIFEN_PLAN = 80; // 尊敬的指挥官，积分赛预热已经开始，请前往布阵。
  public static final int MOLD_KNOCK_PLAN = 81; // 尊敬的指挥官，淘汰赛预热已经开始，请前往布阵和下注。
  public static final int MOLD_KNOCK_BET = 82; // 尊敬的指挥官，淘汰赛预热已经开始，请前往进行下注。所有玩家都可以通过下注指定玩家来获取积分。
  public static final int MOLD_BET_RESULT_WIN =
      83; // 尊敬的指挥官，您下注的选手：|%s|在战斗中获得胜利，该次获得积分：|%s|，在奖励领取界面领取。
  public static final int MOLD_BET_RESULT_FAIL =
      84; // 尊敬的指挥官，您下注的选手：|%s|在战斗中获得胜利，该次获得积分：|%s|，在奖励领取界面领取。
  public static final int MOLD_FINAL_PLAN = 85; // / 尊敬的指挥官，您已经获得总决赛资格，总决赛已经开始预热，请前往界面进行布阵和修改。
  public static final int MOLD_GET_SECEND = 86; // 尊敬的指挥官，您在战斗中不敌选手：|%s|，胜败乃兵家常事。您获得此次世界争霸|%s|亚军
  public static final int MOLD_THRID_FIGHT = 87; // 尊敬的指挥官，您在战斗中不敌选手：|%s|，请做好争夺季军的准备。
  public static final int MOLD_GET_THRID = 88; // 尊敬的指挥官，您在战斗中战胜了选手：|%s|。您获得此次世界争霸|%s|季军。
  public static final int MOLD_GET_FIRST = 89; // 尊敬的指挥官，恭喜您在战斗中战胜选手：|%s|，获得冠军。成为本届世界争霸|%s|的冠军。
  public static final int MOLD_TOP_SERVER_REWARD =
      90; // 尊敬的指挥官，恭喜您恭喜您所在服务器的选手：|%s|，获得|%s|组冠军。成为本届跨服巅峰对决|%s|的冠军。所在服务器将会获得大量奖励，可在排行界面中领取。
  public static final int MOLD_KNOCK_OUT = 91; // 尊敬的指挥官，您在淘汰赛赛程中不敌不敌选手：|%s|，胜败乃兵家常事。指挥官期待下次获得更好的成绩。
  public static final int MOLD_FINAL_OUT = 92; // 尊敬的指挥官，您在总决赛赛程中不敌不敌选手：|%s|，胜败乃兵家常事。指挥官期待下次获得更好的成绩。
  public static final int MOLD_JIFEN_GET =
      93; // 尊敬的指挥官，您在本次跨服战活动中累积获得积分：|%s|。（积分已在过程中发放到个人积分池），可在跨服战积分商城中消费珍贵道具。
  public static final int MOLD_TOP2_SERVER_REWARD =
      94; // 尊敬的指挥官，恭喜您恭喜您所在服务器的选手：|%s|，获得|%s|组亚军。成为本届跨服巅峰对决|%s|的亚军。所在服务器将会获得大量奖励，可在排行界面中领取。
  public static final int MOLD_TOP3_SERVER_REWARD =
      95; // 尊敬的指挥官，恭喜您恭喜您所在服务器的选手：|%s|，获得|%s|组季军。成为本届跨服巅峰对决|%s|的亚军。所在服务器将会获得大量奖励，可在排行界面中领取。
  public static final int MOLD_FIRST_FIGHT = 96; // 尊敬的指挥官，您在战斗中战胜选手：|%s|，请做好争夺冠军的准备。

  public static final int MOLD_CP_104 = 104; // 军团争霸赛事已开启，请指挥官在今天的百团大战中争夺军团争霸的参赛资格！
  public static final int MOLD_CP_105 = 105; // 您所在的军团已获得参加军团争霸的资格，请前往军团争霸界面报名参赛！
  public static final int MOLD_CP_106 = 106; // 您所在的军团在小组赛中表现优异，成功晋级决赛，请做好争夺冠军的准备！
  public static final int MOLD_CP_107 = 107; // 尊敬的指挥官，您的军团在小组赛中未能出线，胜败乃兵家常事。指挥官期待下次获得更好的成绩。
  public static final int MOLD_CP_108 = 108; // 尊敬的指挥官，您的军团在战斗中战胜了军团：|%s|。您的军团获得此次军团争霸|%s|季军。
  public static final int MOLD_CP_109 =
      109; // 尊敬的指挥官，您在本次军团争霸活动中累积获得积分：|%s|。（积分已在过程中发放到个人积分池），可在军团争霸积分商城中消费珍贵道具。
  public static final int MOLD_CP_110 = 110; // 尊敬的指挥官，您的军团在战斗中不敌军团：|%s|，胜败乃兵家常事。您的军团获得此次军团争霸|%s|亚军
  public static final int MOLD_CP_111 = 111; // 尊敬的指挥官，恭喜您的军团在战斗中战胜军团：|%s|，成为本届军团争霸|%s|的冠军军团。
  public static final int MOLD_CP_112 = 112; // 尊敬的指挥官，恭喜您所在服务器的军团：|%s|，成为本届军团争霸|%s|的冠军。
  public static final int MOLD_CP_113 = 113; // 尊敬的指挥官，恭喜您所在服务器的军团：|%s|，成为本届军团争霸|%s|的亚军。
  public static final int MOLD_CP_114 = 114; // 尊敬的指挥官，恭喜您所在服务器的军团：|%s|，成为本届军团争霸|%s|的亚军。
  public static final int MOLD_CP_115 = 115; // 115	军团争霸发军团排行奖励占位	发军团排行奖励占位
}
