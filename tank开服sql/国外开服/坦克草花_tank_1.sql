/*
Navicat MySQL Data Transfer

Source Server         : 坦克英文测试服
Source Server Version : 50620
Source Host           : localhost:3306
Source Database       : tank_1

Target Server Type    : MYSQL
Target Server Version : 50620
File Encoding         : 65001

Date: 2017-10-30 17:32:13
*/

SET @serverId = 2;
SET @openTime = '2017-03-23 00:00:00';
SET @serverName = 'Tank Alert';
SET @tcpPort = 9201;
SET @httpPort = 9202;
SET @accountServerUrl = 'http://172.23.0.1:9200/tank_account/account/inner.do';
SET @actMold = 2;
SET @gmOrder = 0;

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for p_account
-- ----------------------------
DROP TABLE IF EXISTS `p_account`;
CREATE TABLE `p_account` (
`keyId`  int(11) NOT NULL AUTO_INCREMENT ,
`accountKey`  int(11) NOT NULL ,
`serverId`  int(11) NOT NULL ,
`platNo`  int(11) NOT NULL ,
`platId`  char(40) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL ,
`childNo`  int(11) NOT NULL DEFAULT 0 ,
`forbid`  int(11) NOT NULL DEFAULT 0 COMMENT '是否封号 1开启封号' ,
`whiteName`  int(11) NOT NULL DEFAULT 0 COMMENT '是否白名单玩家 1.属于白名单玩家' ,
`lordId`  bigint(20) NOT NULL ,
`created`  int(11) NOT NULL DEFAULT 0 COMMENT '是否创建了角色' ,
`deviceNo`  char(80) CHARACTER SET ascii COLLATE ascii_general_ci NULL DEFAULT NULL ,
`createDate`  datetime NULL DEFAULT NULL COMMENT '角色创建日期' ,
`loginDays`  int(11) NOT NULL DEFAULT 1 COMMENT '登陆天数（非连续登陆天数，登陆一天累加一次）' ,
`loginDate`  datetime NULL DEFAULT NULL COMMENT '最后登录日期' ,
`isGm`  int(11) NOT NULL DEFAULT 0 COMMENT '是否gm' ,
`isGuider`  int(11) NOT NULL DEFAULT 0 COMMENT '是否新手引导员' ,
`backState`  int(11) NULL DEFAULT NULL COMMENT '回归奖励状态' ,
`backEndTime`  datetime NULL DEFAULT NULL COMMENT '回归时间' ,
PRIMARY KEY (`keyId`),
UNIQUE INDEX `only_index` (`accountKey`, `serverId`) USING BTREE ,
UNIQUE INDEX `lord_index` (`lordId`) USING BTREE 
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_bin
AUTO_INCREMENT=234

;

-- ----------------------------
-- Table structure for p_ad
-- ----------------------------
DROP TABLE IF EXISTS `p_ad`;
CREATE TABLE `p_ad` (
`lordId`  bigint(11) NOT NULL COMMENT '关联用户唯一id' ,
`firstPay`  int(11) NOT NULL DEFAULT 0 COMMENT '当天首冲观看次数' ,
`lastFirstPayADTime`  datetime NULL DEFAULT NULL COMMENT '最后一次观看首冲广告的时间' ,
`firstPayCount`  int(11) NOT NULL DEFAULT 0 COMMENT '连续观看了几天的首冲广告' ,
`firstPayStatus`  int(11) NOT NULL DEFAULT 0 COMMENT '首冲状态1可领取0不可领取' ,
`lvUpStatus`  int(11) NOT NULL DEFAULT 0 COMMENT '秒升一级1可使用0不可使用' ,
`lvUpLastTime`  datetime NULL DEFAULT NULL COMMENT '最后观看秒升一级的时间' ,
`loginStatus`  int(11) NOT NULL DEFAULT 0 COMMENT '登陆广告奖励' ,
`lastLoginTime`  datetime NULL DEFAULT NULL COMMENT '最后一次观看登陆广告的时间' ,
`buffCount`  int(11) NOT NULL DEFAULT 0 COMMENT '编制经验buff添加次数' ,
`lastBuffTime`  datetime NULL DEFAULT NULL COMMENT '最后一次观看编制经验广告的时间' ,
`buffCount2`  int(11) NOT NULL DEFAULT 0 COMMENT '指挥官经验buff添加次数' ,
`lastBuff2Time`  datetime NULL DEFAULT NULL COMMENT '最后一次观看指挥官经验广告的时间' ,
`powerCount`  int(11) NOT NULL DEFAULT 0 COMMENT '体力回复广告观看次数' ,
`powerTime`  datetime NULL DEFAULT NULL COMMENT '最后一次体力回复广告观看时间' ,
`commondCount`  int(11) NOT NULL DEFAULT 0 COMMENT '统率书广告观看次数' ,
`commondTime`  datetime NULL DEFAULT NULL COMMENT '最后一次观看统率书广告的时间' ,
PRIMARY KEY (`lordId`)
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci
COMMENT='游戏内观看广告'

;

-- ----------------------------
-- Table structure for p_arena
-- ----------------------------
DROP TABLE IF EXISTS `p_arena`;
CREATE TABLE `p_arena` (
`lordId`  bigint(20) NOT NULL ,
`rank`  int(11) NOT NULL ,
`score`  int(11) NOT NULL DEFAULT 0 COMMENT '积分' ,
`count`  int(11) NOT NULL COMMENT '剩余挑战次数' ,
`lastRank`  int(11) NOT NULL DEFAULT 0 COMMENT '上次排名' ,
`winCount`  int(11) NOT NULL DEFAULT 0 COMMENT '连胜次数' ,
`coldTime`  int(11) NOT NULL DEFAULT 0 COMMENT '冷却开始时间' ,
`arenaTime`  int(11) NOT NULL COMMENT '刷新时间' ,
`awardTime`  int(11) NOT NULL DEFAULT 0 COMMENT '排名奖励领取时间' ,
`buyCount`  int(11) NOT NULL DEFAULT 0 COMMENT '当天购买的次数' ,
`fight`  int(11) NOT NULL COMMENT '竞技场战力' ,
PRIMARY KEY (`lordId`),
INDEX `rank_index` (`rank`) USING BTREE 
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_bin

;

-- ----------------------------
-- Table structure for p_arena_log
-- ----------------------------
DROP TABLE IF EXISTS `p_arena_log`;
CREATE TABLE `p_arena_log` (
`keyId`  int(11) NOT NULL AUTO_INCREMENT ,
`arenaTime`  int(11) NOT NULL COMMENT '竞技场排名奖励统计日期' ,
`count`  int(11) NOT NULL ,
PRIMARY KEY (`keyId`)
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_bin
AUTO_INCREMENT=231

;

-- ----------------------------
-- Table structure for p_boss
-- ----------------------------
DROP TABLE IF EXISTS `p_boss`;
CREATE TABLE `p_boss` (
`lordId`  bigint(20) NOT NULL ,
`bossType`  int(10) NOT NULL DEFAULT 1 COMMENT 'BOSS类型，1 世界BOSS，2 祭坛BOSS' ,
`hurt`  bigint(20) NOT NULL DEFAULT 0 ,
`bless1`  int(11) NOT NULL DEFAULT 0 ,
`bless2`  int(11) NOT NULL DEFAULT 0 ,
`bless3`  int(11) NOT NULL DEFAULT 0 ,
`autoFight`  int(11) NOT NULL DEFAULT 0 COMMENT 'vip自动挑战' ,
PRIMARY KEY (`lordId`, `bossType`)
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_bin

;

-- ----------------------------
-- Table structure for p_building
-- ----------------------------
DROP TABLE IF EXISTS `p_building`;
CREATE TABLE `p_building` (
`lordId`  bigint(20) NOT NULL ,
`ware1`  int(11) NOT NULL COMMENT '第一仓库等级' ,
`ware2`  int(11) NOT NULL COMMENT '第二仓库等级' ,
`tech`  int(11) NOT NULL COMMENT '科技馆等级' ,
`factory1`  int(11) NOT NULL COMMENT '第一战车工厂等级' ,
`factory2`  int(11) NOT NULL COMMENT '第二战车工厂等级' ,
`refit`  int(11) NOT NULL COMMENT '改装工厂等级' ,
`command`  int(11) NOT NULL COMMENT '司令部等级' ,
`workShop`  int(11) NOT NULL COMMENT '制造车间等级' ,
`leqm`  int(11) NULL DEFAULT 0 COMMENT '军备材料工厂' ,
PRIMARY KEY (`lordId`)
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_bin

;

-- ----------------------------
-- Table structure for p_cpFames
-- ----------------------------
DROP TABLE IF EXISTS `p_cpFames`;
CREATE TABLE `p_cpFames` (
`keyId`  int(11) UNSIGNED ZEROFILL NOT NULL AUTO_INCREMENT ,
`beginTime`  varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL ,
`endTime`  varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL ,
`crossFames`  blob NULL ,
PRIMARY KEY (`keyId`)
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci
AUTO_INCREMENT=1

;

-- ----------------------------
-- Table structure for p_crossFames
-- ----------------------------
DROP TABLE IF EXISTS `p_crossFames`;
CREATE TABLE `p_crossFames` (
`keyId`  int(11) UNSIGNED ZEROFILL NOT NULL AUTO_INCREMENT ,
`beginTime`  varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL ,
`endTime`  varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL ,
`crossFames`  blob NULL ,
PRIMARY KEY (`keyId`)
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci
AUTO_INCREMENT=1

;

-- ----------------------------
-- Table structure for p_data
-- ----------------------------
DROP TABLE IF EXISTS `p_data`;
CREATE TABLE `p_data` (
`lordId`  bigint(20) NOT NULL ,
`roleData`  mediumblob NOT NULL COMMENT '坦克' ,
`mail`  mediumblob NOT NULL COMMENT '邮件' ,
`combatId`  int(11) NOT NULL DEFAULT 0 COMMENT '普通副本进度' ,
`equipEplrId`  int(11) NOT NULL DEFAULT 0 COMMENT '装备副本进度' ,
`partEplrId`  int(11) NOT NULL DEFAULT 0 COMMENT '配件副本进度' ,
`militaryEplrId`  int(11) NOT NULL DEFAULT 0 COMMENT '军工副本次数' ,
`extrEplrId`  int(11) NOT NULL DEFAULT 300 COMMENT '极限副本进度' ,
`extrMark`  int(11) NOT NULL DEFAULT 0 COMMENT '极限副本最高层数' ,
`wipeTime`  int(11) NOT NULL DEFAULT 0 COMMENT '极限副本扫荡开始时间' ,
`timePrlrId`  int(11) NOT NULL DEFAULT 0 COMMENT '限时副本进度' ,
`energyStoneEplrId`  int(11) NOT NULL DEFAULT 0 COMMENT '能晶副本进度' ,
`signLogin`  int(11) NOT NULL DEFAULT 0 COMMENT '签到登录奖励' ,
`maxKey`  int(11) NOT NULL DEFAULT 0 COMMENT '最大key' ,
`seniorDay`  int(11) NOT NULL DEFAULT 0 COMMENT '军事矿区参与时间' ,
`seniorCount`  int(11) NOT NULL DEFAULT 0 COMMENT '军事矿区掠夺剩余次数' ,
`seniorScore`  int(11) NOT NULL DEFAULT 0 COMMENT '军事矿区掠夺积分' ,
`seniorAward`  int(11) NOT NULL DEFAULT 0 COMMENT '是否领取了军事矿区军团排名奖励' ,
`seniorBuy`  int(11) NOT NULL DEFAULT 0 COMMENT '军事矿区掠夺购买次数' ,
`medalEplrId`  int(11) NOT NULL DEFAULT 0 COMMENT '勋章副本进度' ,
PRIMARY KEY (`lordId`),
INDEX `lord_index` (`lordId`) USING BTREE 
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_bin

;

-- ----------------------------
-- Table structure for p_extreme
-- ----------------------------
DROP TABLE IF EXISTS `p_extreme`;
CREATE TABLE `p_extreme` (
`extremeId`  int(11) NOT NULL ,
`first1`  blob NOT NULL ,
`last3`  mediumblob NOT NULL ,
PRIMARY KEY (`extremeId`)
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_bin

;

-- ----------------------------
-- Table structure for p_global
-- ----------------------------
DROP TABLE IF EXISTS `p_global`;
CREATE TABLE `p_global` (
`globalId`  int(11) NOT NULL AUTO_INCREMENT ,
`maxKey`  int(11) NOT NULL DEFAULT 0 COMMENT '全局key' ,
`mails`  blob NOT NULL COMMENT '竞技场全服战报' ,
`warTime`  int(11) NOT NULL DEFAULT 0 COMMENT '百团混战时间' ,
`warRecord`  blob NOT NULL COMMENT '百团混战全服战况' ,
`warState`  int(11) NOT NULL DEFAULT 0 COMMENT '百团混战状态 1.正常 2.取消' ,
`winRank`  blob NOT NULL COMMENT '连胜排名奖励' ,
`getWinRank`  blob NOT NULL COMMENT '领取过连胜排名奖励的玩家Id' ,
`bossTime`  int(11) NOT NULL DEFAULT 0 ,
`bossLv`  int(11) NOT NULL DEFAULT 0 ,
`bossWhich`  int(11) NOT NULL DEFAULT 0 ,
`bossHp`  int(11) NOT NULL DEFAULT 0 ,
`bossState`  int(11) NOT NULL DEFAULT 0 ,
`hurtRank`  blob NOT NULL ,
`getHurtRank`  blob NOT NULL ,
`bossKiller`  char(20) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL ,
`shop`  varchar(64) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL DEFAULT '' COMMENT '军团商品' ,
`shopTime`  int(11) NOT NULL DEFAULT 0 COMMENT '军团商品更新时间' ,
`seniorWeek`  int(11) NOT NULL DEFAULT 0 COMMENT '军事矿区参与时间' ,
`scoreRank`  blob NOT NULL COMMENT '军事矿区个人积分排名' ,
`scorePartyRank`  blob NOT NULL COMMENT '军事矿区军团积分排名' ,
`seniorState`  int(11) NOT NULL DEFAULT 0 COMMENT '军事矿区状态' ,
`warRankRecords`  blob NULL COMMENT '记录本周军团战前10名' ,
`canFightFortressPartyMap`  blob NULL COMMENT '参加要塞战的军团' ,
`fortressTime`  int(11) NOT NULL DEFAULT 0 COMMENT '要塞战时间' ,
`fortressState`  int(255) NULL DEFAULT 0 COMMENT '状态:0未开始,1准备2开始3取消4战斗结束5奖励结束' ,
`fortressPartyId`  int(11) NULL DEFAULT 0 COMMENT '要塞主军团id' ,
`fortressRecords`  mediumblob NULL COMMENT '要塞战所有的记录' ,
`rptRtkFortresss`  mediumblob NULL COMMENT '要塞战所有的战报' ,
`myFortressFightDatas`  mediumblob NULL COMMENT '所有的要塞战数据' ,
`partyStatisticsMap`  blob NULL COMMENT '军团统计数据' ,
`fortressJobAppointList`  blob NULL COMMENT '要塞职位任命信息' ,
`allServerFortressFightDataRankLordMap`  blob NULL COMMENT '要塞个人积分排名top100' ,
`drillStatus`  int(11) NOT NULL DEFAULT 0 COMMENT '红蓝大战活动的状态，0 未开启，1 报名，2 备战，3 预热，4 第一部队战斗，5 第二部队战斗，6 第三部队战斗' ,
`lastOpenDrillDate`  int(11) NOT NULL DEFAULT 0 COMMENT '红蓝大战最近一次开启的日期，格式:20160809' ,
`drillRank`  mediumblob NOT NULL COMMENT '红蓝大战玩家排行榜' ,
`drillRecords`  mediumblob NOT NULL COMMENT '红蓝大战玩家战况记录' ,
`drillFightRpts`  mediumblob NOT NULL COMMENT '红蓝大战玩家的战报记录' ,
`drillResult`  blob NOT NULL COMMENT '红蓝大战战斗结果' ,
`drillImprove`  blob NOT NULL COMMENT '红蓝大战红方的进修情况' ,
`drillShop`  blob NOT NULL COMMENT '红蓝大战红方的进修情况' ,
`rebelStatus`  int(2) NOT NULL DEFAULT 0 COMMENT '叛军入侵活动状态，1 已开始，0 未开始或已结束' ,
`rebelLastOpenTime`  int(11) NOT NULL DEFAULT 0 COMMENT '叛军入侵活动最近一次开启的时间' ,
`rebelTotalData`  mediumblob NOT NULL COMMENT '叛军入侵活动，所有公用数据' ,
`worldMineInfo`  mediumblob NULL COMMENT '世界地图矿点品质' ,
`gameStopTime`  int(11) NULL DEFAULT NULL COMMENT '游戏停服维护时间点' ,
`airship`  blob NULL COMMENT '飞艇数据' ,
PRIMARY KEY (`globalId`)
)
ENGINE=MyISAM
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_bin
AUTO_INCREMENT=2

;

-- ----------------------------
-- Table structure for p_lord
-- ----------------------------
DROP TABLE IF EXISTS `p_lord`;
CREATE TABLE `p_lord` (
`lordId`  bigint(20) NOT NULL AUTO_INCREMENT COMMENT '玩家id' ,
`nick`  char(20) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL COMMENT '主公名字' ,
`portrait`  int(11) NOT NULL DEFAULT 1 COMMENT '头像' ,
`sex`  int(11) NOT NULL DEFAULT 0 ,
`level`  int(11) NOT NULL DEFAULT 1 COMMENT '当前等级' ,
`exp`  bigint(20) NOT NULL DEFAULT 0 COMMENT '当前经验值' ,
`vip`  int(11) NOT NULL DEFAULT 0 COMMENT 'vip等级' ,
`topup`  int(11) NOT NULL DEFAULT 0 COMMENT '总充值金额' ,
`pos`  int(11) NOT NULL DEFAULT '-1' COMMENT '坐标' ,
`gold`  int(11) NOT NULL DEFAULT 0 COMMENT '金币' ,
`goldCost`  int(11) NOT NULL DEFAULT 0 COMMENT '金币总消耗' ,
`goldGive`  int(11) NOT NULL DEFAULT 0 COMMENT '总共赠予的金币' ,
`goldTime`  int(11) NOT NULL DEFAULT 0 COMMENT '财政官金发送取时间' ,
`huangbao`  int(11) NOT NULL COMMENT '荒宝碎片数量' ,
`ranks`  int(11) NOT NULL DEFAULT 1 COMMENT '军衔' ,
`command`  int(11) NOT NULL DEFAULT 0 COMMENT '统帅等级' ,
`fame`  int(11) NOT NULL DEFAULT 0 COMMENT '声望' ,
`fameLv`  int(11) NOT NULL DEFAULT 1 COMMENT '声望等级' ,
`fameTime1`  int(11) NOT NULL DEFAULT 0 COMMENT '军衔领取声望的时间' ,
`fameTime2`  int(11) NOT NULL DEFAULT 0 COMMENT '授勋领取声望的时间' ,
`honour`  int(11) NOT NULL DEFAULT 0 COMMENT '荣誉' ,
`pros`  int(11) NOT NULL DEFAULT 0 COMMENT '繁荣度' ,
`prosMax`  int(11) NOT NULL DEFAULT 0 COMMENT '最大繁荣度' ,
`prosTime`  int(11) NOT NULL COMMENT '繁荣度恢复时间' ,
`power`  int(11) NOT NULL DEFAULT 0 COMMENT '当前行动力' ,
`powerTime`  int(11) NOT NULL COMMENT '上一次回复行动力的时间' ,
`newState`  bigint(20) NOT NULL DEFAULT 0 COMMENT '新手引导步骤' ,
`fight`  bigint(20) NOT NULL DEFAULT 0 COMMENT '战斗力' ,
`equip`  int(11) NOT NULL COMMENT '装备仓库容量' ,
`fitting`  int(11) NOT NULL COMMENT '零件数量' ,
`metal`  int(11) NOT NULL COMMENT '记忆金属数量' ,
`plan`  int(11) NOT NULL COMMENT '设计蓝图数量' ,
`mineral`  int(11) NOT NULL COMMENT '金属矿物数量' ,
`tool`  int(11) NOT NULL COMMENT '改造工具数量' ,
`draw`  int(11) NOT NULL COMMENT '改造图纸数量' ,
`tankDrive`  int(11) NOT NULL DEFAULT 0 COMMENT '坦克驱动' ,
`chariotDrive`  int(11) NOT NULL DEFAULT 0 COMMENT '战车驱动' ,
`artilleryDrive`  int(11) NOT NULL DEFAULT 0 COMMENT '火炮驱动' ,
`rocketDrive`  int(11) NOT NULL DEFAULT 0 COMMENT '火箭驱动' ,
`eplrTime`  int(11) NOT NULL COMMENT '探险副本重置时间' ,
`equipEplr`  int(11) NOT NULL COMMENT '装备副本挑战次数' ,
`partEplr`  int(11) NOT NULL COMMENT '配件副本挑战次数' ,
`militaryEplr`  int(11) NOT NULL DEFAULT 0 COMMENT '军工副本挑战次数' ,
`extrEplr`  int(11) NOT NULL COMMENT '极限副本挑战次数' ,
`timeEplr`  int(11) NOT NULL COMMENT '限时副本挑战次数' ,
`energyStoneEplr`  int(11) NOT NULL DEFAULT 0 COMMENT '能晶副本挑战次数' ,
`equipBuy`  int(11) NOT NULL COMMENT '装备探险购买次数' ,
`partBuy`  int(11) NOT NULL COMMENT '配件副本购买次数' ,
`militaryBuy`  int(11) NOT NULL DEFAULT 0 COMMENT '军工副本购买次数' ,
`extrReset`  int(11) NOT NULL COMMENT '探险副本重置次数' ,
`timeBuy`  int(11) NOT NULL DEFAULT 0 COMMENT '限时副本购买次数' ,
`energyStoneBuy`  int(11) NOT NULL DEFAULT 0 COMMENT '能晶副本购买次数' ,
`goldHeroCount`  int(11) NOT NULL DEFAULT 0 COMMENT '金币抽将次数' ,
`goldHeroTime`  int(11) NOT NULL DEFAULT 0 ,
`stoneHeroCount`  int(11) NOT NULL DEFAULT 0 COMMENT '宝石抽将次数' ,
`stoneHeroTime`  int(11) NOT NULL DEFAULT 0 ,
`blessCount`  int(11) NOT NULL DEFAULT 0 COMMENT '祝福次数' ,
`blessTime`  int(11) NOT NULL DEFAULT 0 COMMENT '祝福时间' ,
`taskDayiy`  int(11) NOT NULL DEFAULT 0 COMMENT '日常任务环数' ,
`dayiyCount`  int(11) NOT NULL DEFAULT 0 COMMENT '日常任务购买次数' ,
`taskLive`  int(11) NOT NULL DEFAULT 0 COMMENT '日常总活跃' ,
`taskLiveAd`  int(11) NOT NULL DEFAULT 0 COMMENT '日常活跃领取奖励值' ,
`taskTime`  int(11) NOT NULL DEFAULT 0 COMMENT '任务刷新时间' ,
`taskLiveTime`  int(11) NULL DEFAULT NULL COMMENT '每周活跃任务刷新时间' ,
`buyPower`  int(11) NOT NULL DEFAULT 0 COMMENT '购买能量次数' ,
`buyPowerTime`  int(11) NOT NULL DEFAULT 0 COMMENT '购买能量日期' ,
`stars`  int(11) NOT NULL DEFAULT 0 COMMENT '关卡总星数' ,
`starRankTime`  int(11) NOT NULL DEFAULT 0 COMMENT '玩家最近一次上关卡总星榜的时间' ,
`lotterExplore`  int(11) NOT NULL DEFAULT 0 COMMENT '单次探宝时间' ,
`buildCount`  int(11) NOT NULL DEFAULT 0 COMMENT '购买的建筑位' ,
`newerGift`  int(11) NOT NULL DEFAULT 0 COMMENT '0未领取新手礼包 1已领取' ,
`onTime`  int(11) NOT NULL DEFAULT 0 COMMENT '最近一次上线时间' ,
`olTime`  int(11) NOT NULL DEFAULT 0 COMMENT '当日在线时长' ,
`offTime`  int(11) NOT NULL DEFAULT 0 COMMENT '最近一次离线时间' ,
`ctTime`  int(11) NOT NULL DEFAULT 0 COMMENT '在线奖励倒计时开始时间' ,
`olAward`  int(11) NOT NULL DEFAULT 0 COMMENT '领取了第几个在线奖励' ,
`silence`  int(11) NOT NULL DEFAULT 0 COMMENT '禁言' ,
`olMonth`  int(11) NOT NULL DEFAULT 0 COMMENT '每月登录天数，值=月份*10000+登录时间*100+天数' ,
`pawn`  int(11) NOT NULL DEFAULT 0 COMMENT '极限单兵领取时间' ,
`partDial`  int(11) NOT NULL DEFAULT 0 COMMENT '配件转盘' ,
`consumeDial`  int(11) NOT NULL DEFAULT 0 COMMENT '消费转盘' ,
`energyStoneDial`  int(11) NOT NULL DEFAULT 0 COMMENT '能晶转盘' ,
`tankRaffle`  int(11) NOT NULL DEFAULT 0 COMMENT '坦克拉霸' ,
`partyLvAward`  int(11) NOT NULL DEFAULT 0 COMMENT '帮派等级奖励' ,
`partyFightAward`  int(11) NOT NULL DEFAULT 0 COMMENT '帮派战力奖励' ,
`partyTipAward`  int(11) NOT NULL DEFAULT 0 COMMENT '军团提示奖励' ,
`freeMecha`  int(11) NOT NULL DEFAULT 0 ,
`upBuildTime`  int(11) NOT NULL DEFAULT 0 COMMENT '剩余自动升级时间' ,
`onBuild`  int(11) NOT NULL DEFAULT 0 COMMENT '打开自动升级' ,
`partExchange`  int(11) NOT NULL DEFAULT 0 COMMENT '限时(配件)兑换' ,
`staffing`  int(11) NOT NULL DEFAULT 0 COMMENT '编制' ,
`staffingLv`  int(11) NOT NULL DEFAULT 0 COMMENT '编制等级' ,
`staffingExp`  int(11) NOT NULL DEFAULT 0 COMMENT '编制经验' ,
`staffingSaveExp`  int(11) NOT NULL DEFAULT 0 COMMENT '编制预存经验' ,
`lockTankId`  int(11) NULL DEFAULT NULL COMMENT '坦克拉霸锁定id' ,
`lockTime`  int(11) NULL DEFAULT NULL COMMENT '坦克拉霸重置日期天' ,
`scountDate`  int(11) NULL DEFAULT NULL COMMENT '侦查日期天' ,
`scount`  int(11) NULL DEFAULT NULL COMMENT '侦查次数' ,
`exploit`  int(11) NOT NULL DEFAULT 0 COMMENT '玩家的功勋值' ,
`resetDrillShopTime`  int(11) NOT NULL DEFAULT 0 COMMENT '玩家上次重置军演商店购买信息的时间' ,
`detergent`  int(11) NOT NULL COMMENT '洗涤剂' ,
`grindstone`  int(11) NOT NULL COMMENT '研磨石' ,
`polishingMtr`  int(11) NOT NULL COMMENT '抛光材料' ,
`maintainOil`  int(11) NOT NULL COMMENT '保养油' ,
`grindTool`  int(11) NOT NULL COMMENT '打磨石' ,
`medalUpCdTime`  int(11) NOT NULL COMMENT '勋章强化冷却结束时间' ,
`medalEplr`  int(11) NOT NULL COMMENT '勋章关卡次数' ,
`medalBuy`  int(11) NOT NULL COMMENT '勋章关卡购买次数' ,
`frighten`  int(11) NOT NULL DEFAULT '-1' COMMENT '勋章 震慑总和' ,
`fortitude`  int(11) NOT NULL DEFAULT '-1' COMMENT '勋章 刚毅总和' ,
`medalPrice`  int(11) NOT NULL DEFAULT '-1' COMMENT '勋章价值总和' ,
`militaryRank`  int(11) NULL DEFAULT NULL COMMENT '军衔' ,
`militaryRankUpTime`  bigint(20) NULL DEFAULT NULL COMMENT '军衔升级时间(毫秒)' ,
`militaryExploit`  bigint(11) NULL DEFAULT NULL COMMENT '军功' ,
`mpltGetToday`  int(11) NULL DEFAULT NULL COMMENT '今日获取军功数' ,
`lastMpltDay`  int(11) NULL DEFAULT NULL COMMENT '最后获取军功时间' ,
`maxFight`  bigint(20) NULL DEFAULT NULL COMMENT '玩家总战力' ,
`guide`  int(11) NULL DEFAULT NULL ,
PRIMARY KEY (`lordId`)
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_bin
AUTO_INCREMENT=234

;

-- ----------------------------
-- Table structure for p_party
-- ----------------------------
DROP TABLE IF EXISTS `p_party`;
CREATE TABLE `p_party` (
`partyId`  int(11) NOT NULL ,
`partyName`  char(32) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL ,
`legatusName`  char(64) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL COMMENT '军团长名称' ,
`partyLv`  int(11) NOT NULL DEFAULT 1 COMMENT '军团大厅等级' ,
`scienceLv`  int(11) NOT NULL DEFAULT 1 COMMENT '科技馆等级' ,
`wealLv`  int(11) NOT NULL DEFAULT 1 COMMENT '福利院等级' ,
`lively`  int(11) NOT NULL DEFAULT 0 COMMENT '军团活跃值' ,
`build`  int(11) NOT NULL DEFAULT 0 COMMENT '建设度' ,
`fight`  bigint(20) NOT NULL DEFAULT 0 COMMENT '战斗力' ,
`apply`  int(11) NOT NULL DEFAULT 1 COMMENT '1申请即可加入 2申请需要审批' ,
`applyLv`  int(11) NOT NULL DEFAULT 0 COMMENT '申请等级' ,
`applyFight`  bigint(20) NOT NULL DEFAULT 0 COMMENT '申请战斗力' ,
`slogan`  varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '公会宣传语' ,
`innerSlogan`  varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '内部宣传语' ,
`jobName1`  char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '职位1的名称' ,
`jobName2`  char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '职位1的名称' ,
`jobName3`  char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '职位1的名称' ,
`jobName4`  char(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '职位1的名称' ,
`mine`  blob NOT NULL COMMENT '全员采集资源数量' ,
`science`  blob NOT NULL COMMENT '帮派科技信息' ,
`applyList`  blob NOT NULL COMMENT '工会申请列表（最大20个）' ,
`trend`  blob NOT NULL COMMENT '军情' ,
`partyCombat`  blob NOT NULL COMMENT '军团副本' ,
`liveTask`  blob NOT NULL COMMENT '军团活跃任务' ,
`activity`  blob NOT NULL ,
`amyProps`  blob NOT NULL COMMENT '战事福利' ,
`donates`  blob NOT NULL COMMENT '捐献者ID' ,
`shopProps`  varchar(128) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT '[0,0,0]' COMMENT '已购买次数' ,
`refreshTime`  int(11) NOT NULL COMMENT '采集时间' ,
`warRecord`  blob NOT NULL COMMENT '百团混战军团战况' ,
`regLv`  int(11) NOT NULL DEFAULT 0 COMMENT '军团报名等级' ,
`regFight`  bigint(20) NOT NULL DEFAULT 0 COMMENT '军团报名战力' ,
`warRank`  int(11) NOT NULL DEFAULT 0 COMMENT '百团混战排名' ,
`score`  int(11) NOT NULL DEFAULT 0 COMMENT '军事矿区积分' ,
`altarLv`  int(11) NOT NULL DEFAULT 1 COMMENT '军团祭坛的等级' ,
`nextCallBossSec`  int(11) NOT NULL DEFAULT 0 COMMENT '下一次可以召唤祭坛BOSS的时间（CD结束时间），毫秒数/1000' ,
`bossLv`  int(11) NOT NULL DEFAULT 0 COMMENT '祭坛BOSS的等级' ,
`bossState`  int(11) NOT NULL DEFAULT 0 COMMENT '祭坛BOSS的状态' ,
`bossWhich`  int(11) NOT NULL DEFAULT 0 COMMENT '祭坛BOSS当前是第几管血' ,
`bossHp`  int(11) NOT NULL DEFAULT 0 COMMENT '祭坛BOSS当前血量万分比' ,
`bossHurtRank`  varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL COMMENT '祭坛BOSS伤害排行' ,
`bossAward`  varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL COMMENT '祭坛BOSS排行奖励，已领取奖励的玩家记录' ,
`shopTime`  int(11) NULL DEFAULT NULL COMMENT '军团商店珍品上次重置时间' ,
`airshipData`  blob NULL COMMENT '飞艇部队信息' ,
PRIMARY KEY (`partyId`)
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_bin

;

-- ----------------------------
-- Table structure for p_party_member
-- ----------------------------
DROP TABLE IF EXISTS `p_party_member`;
CREATE TABLE `p_party_member` (
`lordId`  bigint(20) NOT NULL ,
`partyId`  int(11) NOT NULL ,
`job`  int(11) NOT NULL DEFAULT 0 COMMENT '99军团长 10普通成员 0申请玩家' ,
`donate`  int(11) NOT NULL DEFAULT 0 COMMENT '个人贡献' ,
`prestige`  bigint(20) NOT NULL DEFAULT 0 COMMENT '军团内部威望' ,
`weekAllDonate`  int(11) NOT NULL DEFAULT 0 COMMENT '周总贡献' ,
`weekDonate`  int(11) NOT NULL DEFAULT 0 COMMENT '周贡献' ,
`donateTime`  int(11) NOT NULL DEFAULT 0 COMMENT '贡献时间' ,
`dayWeal`  int(11) NOT NULL DEFAULT 0 COMMENT '日常福利：0.未领 1.已领' ,
`hallMine`  blob NOT NULL COMMENT '大厅宝石贡献次数' ,
`scienceMine`  blob NOT NULL COMMENT '科技宝石贡献次数' ,
`wealMine`  blob NOT NULL COMMENT '科技硅石贡献次数' ,
`partyProp`  blob NOT NULL ,
`combatId`  blob NOT NULL ,
`applyList`  varchar(128) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT '|' COMMENT '申请列表' ,
`combatCount`  int(11) NOT NULL DEFAULT 0 COMMENT '打军团本次数' ,
`refreshTime`  int(11) NOT NULL DEFAULT 0 COMMENT '领取福利日期' ,
`enterTime`  int(11) NOT NULL DEFAULT 0 COMMENT '申请/加入帮派时间' ,
`activity`  int(11) NOT NULL DEFAULT 0 COMMENT '活跃度' ,
`regParty`  int(11) NOT NULL DEFAULT 0 COMMENT '报名时所在军团id' ,
`regTime`  int(11) NOT NULL DEFAULT 0 COMMENT '百团报名时间' ,
`regLv`  int(11) NOT NULL DEFAULT 0 COMMENT '报名等级' ,
`regFight`  int(11) NOT NULL DEFAULT 0 COMMENT '报名战力' ,
`winCount`  int(11) NOT NULL DEFAULT 0 COMMENT '百团混战连胜数' ,
`warRecord`  blob NOT NULL COMMENT '百团混战个人战报' ,
PRIMARY KEY (`lordId`),
UNIQUE INDEX `lordId_index` (`lordId`) USING BTREE 
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_bin

;

-- ----------------------------
-- Table structure for p_pay
-- ----------------------------
DROP TABLE IF EXISTS `p_pay`;
CREATE TABLE `p_pay` (
`keyId`  int(11) NOT NULL AUTO_INCREMENT ,
`serverId`  int(11) NOT NULL ,
`roleId`  bigint(20) NOT NULL ,
`platNo`  int(11) NOT NULL ,
`platId`  char(40) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL ,
`orderId`  char(64) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL ,
`serialId`  char(64) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL ,
`amount`  int(11) NOT NULL ,
`payTime`  datetime NOT NULL ,
PRIMARY KEY (`keyId`),
UNIQUE INDEX `only_index` (`platNo`, `orderId`) USING BTREE 
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_bin
AUTO_INCREMENT=132

;

-- ----------------------------
-- Table structure for p_resource
-- ----------------------------
DROP TABLE IF EXISTS `p_resource`;
CREATE TABLE `p_resource` (
`lordId`  bigint(20) NOT NULL ,
`iron`  bigint(20) NOT NULL DEFAULT 0 COMMENT '铁' ,
`oil`  bigint(20) NOT NULL DEFAULT 0 COMMENT '石油' ,
`copper`  bigint(20) NOT NULL DEFAULT 0 COMMENT '铜' ,
`silicon`  bigint(20) NOT NULL DEFAULT 0 COMMENT '硅' ,
`stone`  bigint(20) NOT NULL DEFAULT 0 COMMENT '宝石' ,
`ironOut`  bigint(20) NOT NULL ,
`oilOut`  bigint(20) NOT NULL ,
`copperOut`  bigint(20) NOT NULL ,
`siliconOut`  bigint(20) NOT NULL ,
`stoneOut`  bigint(20) NOT NULL ,
`ironOutF`  int(11) NOT NULL DEFAULT 0 ,
`oilOutF`  int(11) NOT NULL DEFAULT 0 ,
`copperOutF`  int(11) NOT NULL DEFAULT 0 ,
`siliconOutF`  int(11) NOT NULL DEFAULT 0 ,
`stoneOutF`  int(11) NOT NULL DEFAULT 0 ,
`ironMax`  bigint(20) NOT NULL ,
`oilMax`  bigint(20) NOT NULL ,
`copperMax`  bigint(20) NOT NULL ,
`siliconMax`  bigint(20) NOT NULL ,
`stoneMax`  bigint(20) NOT NULL ,
`storeF`  int(11) NOT NULL DEFAULT 0 COMMENT '容量额外百分比' ,
`tIron`  bigint(20) NOT NULL ,
`tOil`  bigint(20) NOT NULL ,
`tCopper`  bigint(20) NOT NULL ,
`tSilicon`  bigint(20) NOT NULL ,
`tStone`  bigint(20) NOT NULL ,
`storeTime`  int(11) NOT NULL COMMENT '上次刷新资源分钟数' ,
PRIMARY KEY (`lordId`)
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_bin

;

-- ----------------------------
-- Table structure for p_smallId
-- ----------------------------
DROP TABLE IF EXISTS `p_smallId`;
CREATE TABLE `p_smallId` (
`keyId`  bigint(20) NOT NULL DEFAULT 0 ,
`lordId`  bigint(20) NOT NULL ,
PRIMARY KEY (`lordId`)
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci
COMMENT='小号表'

;

-- ----------------------------
-- Table structure for p_tip_guy
-- ----------------------------
DROP TABLE IF EXISTS `p_tip_guy`;
CREATE TABLE `p_tip_guy` (
`lordId`  bigint(20) NOT NULL COMMENT '被举报玩家ID' ,
`vip`  int(11) NOT NULL DEFAULT 0 COMMENT 'vip等级' ,
`level`  int(11) NOT NULL DEFAULT 0 COMMENT '玩家等级' ,
`count`  int(11) NOT NULL DEFAULT 0 COMMENT '被举报次数' ,
`tips`  blob NULL COMMENT '举报次数' ,
`content`  varchar(600) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT '[]' ,
PRIMARY KEY (`lordId`)
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_bin

;

-- ----------------------------
-- Table structure for p_usual_activity
-- ----------------------------
DROP TABLE IF EXISTS `p_usual_activity`;
CREATE TABLE `p_usual_activity` (
`activityId`  int(11) NOT NULL ,
`goal`  bigint(32) NOT NULL DEFAULT 0 COMMENT '全服：得分' ,
`sortord`  int(11) NOT NULL DEFAULT 1 COMMENT '排名排序方式（默认倒序）' ,
`playerRank`  blob NULL COMMENT '玩家排行榜数据' ,
`partyRank`  blob NULL COMMENT '军团排行榜数据' ,
`addtion`  blob NULL COMMENT '附加字段' ,
`activityTime`  int(11) NOT NULL DEFAULT 0 COMMENT '活动开启时间' ,
`recordTime`  int(11) NOT NULL DEFAULT 0 COMMENT '记录时间' ,
`params`  varchar(256) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL COMMENT '不固定参数' ,
`actBoss`  blob NULL COMMENT '活动boss数据' ,
`actRebel`  blob NULL COMMENT '活动叛军' ,
PRIMARY KEY (`activityId`),
UNIQUE INDEX `activityId_index` (`activityId`) USING BTREE 
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_bin

;

-- ----------------------------
-- Table structure for p_war_log
-- ----------------------------
DROP TABLE IF EXISTS `p_war_log`;
CREATE TABLE `p_war_log` (
`keyId`  int(11) NOT NULL AUTO_INCREMENT ,
`warTime`  int(11) NOT NULL COMMENT '百团混战时间' ,
`state`  int(11) NOT NULL ,
`partyCount`  int(11) NOT NULL COMMENT '参战军团数' ,
PRIMARY KEY (`keyId`)
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_bin
AUTO_INCREMENT=130

;

-- ----------------------------
-- Table structure for p_world_log
-- ----------------------------
DROP TABLE IF EXISTS `p_world_log`;
CREATE TABLE `p_world_log` (
`keyId`  int(11) NOT NULL AUTO_INCREMENT ,
`lvTime`  int(11) NOT NULL ,
`worldLv`  int(11) NOT NULL ,
`totalLv`  int(11) NOT NULL ,
PRIMARY KEY (`keyId`)
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_bin
AUTO_INCREMENT=186

;

-- ----------------------------
-- Table structure for s_server_setting
-- ----------------------------
DROP TABLE IF EXISTS `s_server_setting`;
CREATE TABLE `s_server_setting` (
`paramId`  int(11) NOT NULL ,
`title`  char(20) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL ,
`paramName`  char(30) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL ,
`paramValue`  varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL ,
`descs`  varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL ,
PRIMARY KEY (`paramId`)
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_bin

;

-- ----------------------------
-- Table structure for u_client_message
-- ----------------------------
DROP TABLE IF EXISTS `u_client_message`;
CREATE TABLE `u_client_message` (
`keyId`  bigint(20) NOT NULL AUTO_INCREMENT ,
`lordId`  bigint(20) NULL DEFAULT 0 ,
`version`  char(12) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT '0' ,
`plat`  char(20) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL ,
`definition`  char(60) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL COMMENT '分辨力' ,
`msgData`  varchar(1000) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL ,
`createDate`  datetime NULL DEFAULT NULL ,
PRIMARY KEY (`keyId`)
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_bin
AUTO_INCREMENT=1

;

-- ----------------------------
-- Auto increment value for p_account
-- ----------------------------
ALTER TABLE `p_account` AUTO_INCREMENT=234;

-- ----------------------------
-- Auto increment value for p_arena_log
-- ----------------------------
ALTER TABLE `p_arena_log` AUTO_INCREMENT=231;

-- ----------------------------
-- Auto increment value for p_cpFames
-- ----------------------------
ALTER TABLE `p_cpFames` AUTO_INCREMENT=1;

-- ----------------------------
-- Auto increment value for p_crossFames
-- ----------------------------
ALTER TABLE `p_crossFames` AUTO_INCREMENT=1;

-- ----------------------------
-- Auto increment value for p_global
-- ----------------------------
ALTER TABLE `p_global` AUTO_INCREMENT=2;

-- ----------------------------
-- Auto increment value for p_lord
-- ----------------------------
ALTER TABLE `p_lord` AUTO_INCREMENT=234;

-- ----------------------------
-- Auto increment value for p_pay
-- ----------------------------
ALTER TABLE `p_pay` AUTO_INCREMENT=132;

-- ----------------------------
-- Auto increment value for p_war_log
-- ----------------------------
ALTER TABLE `p_war_log` AUTO_INCREMENT=130;

-- ----------------------------
-- Auto increment value for p_world_log
-- ----------------------------
ALTER TABLE `p_world_log` AUTO_INCREMENT=186;

-- ----------------------------
-- Auto increment value for u_client_message
-- ----------------------------
ALTER TABLE `u_client_message` AUTO_INCREMENT=1;



###################################################################初始化服务器数据########################################################
INSERT INTO `s_server_setting` VALUES ('1', '账号服务器地址', 'accountServerUrl', @accountServerUrl, '账号服务器的url，账号服务器用来验证玩家身份信息');
INSERT INTO `s_server_setting` VALUES ('2', '测试模式', 'testMode', 'no', '(yes / no)是否开启测试模式，测试模式下不进行身份验证');
INSERT INTO `s_server_setting` VALUES ('3', '配置方式', 'configMode', 'db', '服务器配置方式(db/file), db方式下s_server_setting生效，file方式下gameServer.properties文件里的配置生效  ');
INSERT INTO `s_server_setting` VALUES ('4', '白名单模式', 'openWhiteName', 'no', '(yes / no)是否开启白名单模式，白名单模式下只有白名单玩家能进入游戏');
INSERT INTO `s_server_setting` VALUES ('5', '开启通信加密', 'cryptMsg', 'no', '(yes / no)是否对客户端的通信协议加密');
INSERT INTO `s_server_setting` VALUES ('6', '通信密码', 'msgCryptCode', 'xxoofuckyou', '通信协议加密时使用的密码');
INSERT INTO `s_server_setting` VALUES ('7', '兑换码', 'convertUrl', 'http://cnmobile.sgzb.login.hundredcent.com:9999/sysmgr/Convert', '统计后台地址');
INSERT INTO `s_server_setting` VALUES ('8', '开充值入口', 'pay', 'yes', '客户端是否开充值');
INSERT INTO `s_server_setting` VALUES ('9', 'tcp端口', 'clientPort', @tcpPort, '对外tcp连接端口');
INSERT INTO `s_server_setting` VALUES ('10', 'http端口', 'httpPort', @httpPort, '对外http连接端口');
INSERT INTO `s_server_setting` VALUES ('11', '区号', 'serverId', @serverId, '区号');
INSERT INTO `s_server_setting` VALUES ('12', '开服时间', 'openTime', @openTime, '本区开服时间');
INSERT INTO `s_server_setting` VALUES ('13', '服务器名', 'serverName', @serverName, '');
INSERT INTO `s_server_setting` VALUES ('14', '活动模板ID', 'actMold', @actMold ,'活动模板ID');
INSERT INTO `s_server_setting` VALUES ('101', '接收GM指令', 'gmOrder', @gmOrder ,'是否接收GM指令');
