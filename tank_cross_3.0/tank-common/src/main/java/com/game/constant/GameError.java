package com.game.constant;

public enum GameError {
    OK(200, "OK") {},
    PARAM_ERROR(201, "PARAM FORMAT ERROR") {},
    INVALID_PARAM(202, "INVALID PARAM VALUE") {},
    MSG_LEN(203, "MSG LENTH ERROR") {},
    DDOS_ERROR(204, "SEND MSG TOO FAST") {},
    PROTOCAL_ERROR(205, "WRONG ENCODE") {},
    SERVER_EXCEPTION(206, "OCCUR EXCEPTION") {},
    CUR_VERSION(207, "CURRENT VERSION OLD") { // 版本有更新，请退出重进
    },
    SESSION_LOST(208, "SESSION LOST") { // SESSION失效，请重新登录
    },
    TOKEN_LOST(209, "TOKEN LOST") { // token丢失，请重新登录
    },
    NO_LORD(210, "NOT FOUND LORD") {},
    SENSITIVE_WORD(211, "CONTAIN SENSITIVE WORD") {},
    INVALID_CHAR(212, "INVALID CHAR") {},

    SAME_NICK(501, "SAME NICK NAME") {},
    ALREADY_CREATE(502, "ALREADY CREATE ROLE") {},
    NO_REPAIR(503, "NO NEED REPAIR") {},
    NO_CONFIG(504, "NO CONFIG") {},
    DATA_EXCEPTION(505, "PLAYER DATA EXCEPTION") {},
    STONE_NOT_ENOUGH(506, "STONE NOT ENOUGH") {},
    GOLD_NOT_ENOUGH(507, "GOLD NOT ENOUGH") {},
    LV_NOT_ENOUGH(508, "LORD LEVEL NOT ENOUGH") {},
    COMMAND_LV_NOT_ENOUGH(509, "COMMAND LEVEL NOT ENOUGH") {},
    RESOURCE_NOT_ENOUGH(510, "RESOURCE NOT ENOUGH") {},
    MAX_BUILD_QUE(511, "MAX BUILD QUE") {},
    ALREADY_BUILD(512, "ALREADY IN BUILD QUE") {},
    CANT_BUILD(513, "THIS CAN'T BE BUILD") {},
    BUILD_LEVEL(514, "BUILD LEVEL NOT ENOUGH") {},
    MAX_TANK_QUE(515, "MAX TANK QUE") {},
    NO_EXIST_QUE(516, "NOT FOUND THIS QUE") {},
    NO_PROP(517, "DON'T HAVA PROP") {},
    BOOK_NOT_ENOUGH(518, "SKILL BOOK NOT ENOUGH") {},
    MAX_PROP_QUE(519, "MAX PROP QUE") {},
    SPEED_WAIT_QUE(520, "CAN'T SPEED WAIT QUE") {},
    CANT_REFIT(521, "THIS CAN'T BE REFIT") {},
    DRAWING_NOT_ENOUGH(522, "DRWAING NOT ENOUGH") {},
    HERO_CHIP_NOT_ENOUGH(523, "HERO CHIP NOT ENOUGH") {},
    PROP_NOT_ENOUGH(524, "PROP NOT ENOUGH") {},
    MAX_REFIT_QUE(525, "MAX REFIT QUE") {},
    TANK_COUNT(526, "TANK COUNT NOT ENOUGHT") {},
    NO_EQUIP(527, "DON'T HAVA THIS EQUIP") {},
    MAX_EQUIP_LV(528, "MAX EQUIP LEVEL") {},
    ALRADY_EQUIP(529, "ALREADY EQUIP") {},
    MAX_EQUIP_STORE(530, "MAX EQUIP STORE") {},
    FULL_EQUIP_ON(531, "FULL EQUIP ON") {},
    EQUIP_STORE_LIMIT(532, "STORE LIMIT") {},
    CHIP_NOT_ENOUGH(533, "PART CHIP NOT ENOUGH") {},
    NO_PART(534, "DON'T HAVA THIS PART") {},
    MAX_PART_UP_LV(535, "MAX PART UP LV") {},
    METAL_NOT_ENOUGH(536, "METAL NOT ENOUGH") {},
    MAX_PART_REFIT_LV(537, "MAX PART REFIT LV") {},
    INGREDIENT_NOT_ENOUGH(538, "INGREDIENT NOT ENOUGH") {},
    DRAW_NOT_ENOUGH(539, "DRAW NOT ENOUGH") {},
    FULL_PART_ON(540, "FULL PART ON") {},
    MAX_PART_STORE(541, "MAX PART STORE") {},
    FAME_LEVEL_ERROR(542, "FAME LEVEL NOT ENOUGH") {},
    COMBAT_PASS_BEFORE(543, "DON'T PASS BEFORE") {},
    NO_POWER(544, "POWER NOT ENOUGH") {},
    NO_RANKS(545, "LORD RANKS NOT ENOUGH") {},
    HAD_PASS(546, "HAD PASS THIS EXTREME EXPLORE") {},
    NEED_3STAR(547, "NEED 3 STAR") {},
    VIP_NOT_ENOUGH(548, "VIP NOT ENOUGH") {},
    COMBAT_NOT_OPEN(549, "COMBAT NOT OPEN") {},
    MAX_BUY_COUNT(550, "MAX BUY COUNT") {},
    HERO_CANT_UP(551, "HERO CANT UP") {},
    NO_PASS(552, "WIPE UNPASS COMBAT") {},
    NO_STAR(553, "COMBAT STAR NOT ENOUGH") {},
    HUANGBAO_NOT_ENOUGH(554, "HUANGBAO NOT ENOUGH") {},
    MAX_RANKS(555, "MAX RANKS") {},

    MAX_COMMAND(556, "MAX COMMAND") {},

    FULL_PROSP(557, "FULL PROSP") {},

    ALREADY_FAME(558, "ALREADY FAME") {},

    ALREADY_GET_BOX(559, "ALREADY GET BOX") {},

    ALREADY_RANK_FAME(560, "ALREADY GET RANK FAME") {},

    FRIEND_HAD(561, "FRIEND HAD") {},
    FRIEND_NOT_EXIST(562, "FRIEND NOT EXIST") {},
    BLESS_HAD(563, "BLESS HAD") {},
    NO_BUILDING(564, "NO BUILDING") {},
    ALREADY_MILL(565, "ALREADY HAD MILL AT POS") {},
    MAX_MILL(566, "EXCESS MILL COUNT LIMIT") {},
    PLAYER_NOT_EXIST(567, "PLAYER NOT EXIST") {},
    NO_HERO(568, "NO HERO") {},
    ARENA_COUNT(569, "EXCESS ARENA COUNT") {},
    ARENA_FORM(570, "NO ARENA FORM") {},
    ARENA_CD(571, "ARENA CD") {},
    NOT_HERO(572, "IT'S NOT HERO") {},
    MAX_BUY_ARENA(573, "MAX BUY ARENA") {},
    ARENA_SCORE(574, "ARENA SCORE NOT ENOUGH") {},
    NO_EXPLORE_COUNT(578, "NO EXPLORE COUNT") {},
    RANK_NOT_ENOUGH(579, "RANK NOT ENOUGH") {},
    ALREADY_ARENA_AWARD(580, "ALREADY GET AWARD") {},
    NO_PARTY(581, "NO PARTY") {},
    PARTY_NOT_EXIST(582, "PARTY NOT EXIST") {},
    DONATE_COUNT(583, "DONATE COUNT") {},
    AUTHORITY_ERR(584, "AUTHORITY_ERR") {},
    DONATE_NOT_ENOUGH(585, "DONATE NOT ENOUGH") {},
    WEAL_NOT_EXIST(586, "WEAL NOT EXIST") {},
    WEAL_GOT(587, "WEAL GOT") {},
    PARTY_HAD(588, "PARTY HAD") {},
    SAME_PARTY_NAME(589, "SAME PARTY NAME") {},
    PARTY_APPLY_FULL(590, "PARTY APPLY FULL") {},
    FIGHT_NOT_ENOUGH(591, "FIGHT NOT ENOUGH") {},
    PARTY_MEMBER_FULL(592, "PARTY MEMBER FULL") {},
    EMPTY_POS(593, "EMPTY POS") {},
    MAX_ARMY_COUNT(594, "MAX ARMY COUNT") {},
    UP_JOB_FAIL(595, "UP JOB FAIL") {},
    PARTY_COMBAT_EXIST(596, "PARTY_COMBAT_EXIST") {},
    AWARD_HAD_GOT(597, "AWARD HAD GOT") {},
    COMBAT_PASS(598, "COMBAT PASS") {},
    POS_NOT_EMPTY(599, "POS NOT EMPTY") {},
    NO_ARMY(600, "NO ARMY") {},
    IN_MARCH(601, "IN MARCHING") {},
    MAIL_NOT_EXIST(602, "MAIL NOT EXIST") {},
    NOT_IN_MARCH(603, "NOT IN MARCHING") {},
    UN_LOGIN(604, "UN LOGIN") {},
    NO_TASK(605, "NO TASK") {},
    TASK_NO_FINISH(606, "TASK NO FINISH") {},
    HAD_ACCEPT(607, "HAD ACCEPT") {},
    TASK_DAYIY_FULL(608, "TASK DAYIY FULL") {},
    MAX_CHAT_LENTH(609, "MAX CHAT LENTH") {},
    MAX_SCIENCE_QUE(610, "MAX SCIENCE QUE") {},
    TARGET_NOT_ONLINE(611, "TARGET NOT ONLINE") {},
    NO_REPORT(612, "NO THIS REPORT") {},
    LIVE_NO_ENOUGH(613, "LIVE NO ENOUGH") {},
    NOT_SAME_PARTY(614, "NOT SAME PARTY") {},
    IN_WIPE(615, "IN WIPE") {},
    NOT_IN_WIPE(616, "NOT IN WIPE") {},
    LEFT_ONE_MEMBER(617, "LEFT ONE MEMBER") {},
    GIFT_HAD_GOT(618, "GIFT HAD GOT") {},
    COUNT_NOT_ENOUGH(619, "COUNT NOT ENOUGH") {},
    ATTACK_FREE(620, "CAN'T ATTACK OR SCOUT") {},
    HAD_APPLY(621, "HAD APPLY") {},
    PARTY_RECRUIT_CD(622, "CAN'T RECRUIT IN 30 MINUTE") {},
    GIFT_CODE_LENTH(623, "GIFT CODE LENTH ERROR") {},
    GIFT_CODE_FORMAT(624, "GIFT CODE FORMAT ERROR") {},
    ACTIVITY_NOT_FINISH(625, "ACTIVITY_NOT_FINISH") {},
    ACTIVITY_NOT_OPEN(626, "ACTIVITY_NOT_OPEN") {},
    GIFT_CODE_INVALID(627, "GIFT CODE INVALID") {},
    INVALID_POS(628, "INVALID POS") {},
    CHAT_CD(629, "IN CHAT CD TIME") {},
    PART_NOT_ENOUGH(630, "PART NOT ENOUGH") {},
    OL_NOT_ENOUGH(631, "ONLINE TIME NOT ENOUGH") {},
    ACTIVITY_GOT(632, "ACTIVITY GOT") {},
    CHAT_SILENCE(633, "YOU ARE SILENCE") {},
    NO_AUTHORITY(634, "NOT HAVE AUTHORITY") {},
    IN_SAME_PARTY(635, "IN SAME PARTY") {},
    IN_COLLECT(636, "IN COLLECT") {},
    TIME_NOT_ENOUGH(637, "TIME NOT ENOUGH") {},
    PARTY_LV_ERROR(638, "PARTY LV ERROR") { // 不能超过军团大厅等级
    },
    SCIENCE_LV_ERROR(639, "PARTY LV ERROR") { // 不能超过军团大厅等级
    },
    ALREADY_REG(640, "ALREADY REG PARTY WAR") {},
    OUT_REG_TIME(641, "OUT REG TIME") {},
    NOT_ON_RANK(642, "NOT ON RANK") {},
    IN_WAR(643, "IN WAR") {},
    IN_PARTY_TIME(644, "NEED 24 HOURS") {},
    MAX_BLESS_LV(645, "MAX BLESS LV") {},
    BOSS_STATE(646, "NOT IN BOSS STATE") {},
    BOSS_END(647, "BOSS END") {},
    BOSS_CD(648, "BOSS CD") {},
    BOSS_FORM(649, "NO BOSS FORM") {},
    WAR_PROCESS(650, "WAR IN PROCESS") {},
    BOSS_NOT_END(651, "BOSS NOT END") {},
    BUY_ONLY_ONCE(652, "BUY ONLY ONCE") {},
    ARENA_ERROR(653, "ARENA ERROR") {},
    NEED_LV_15(654, "NEED_LV_15") {},
    STAFFING_NOT_OPEN(655, "STAFFING NOT OPEN") {},
    SENIOR_MINE_DAY(656, "SENIOR NOT OPEN TODAY") {},
    SENIOR_ATTACK_1(657, "CAN'T OCCUPA") {},
    SENIOR_ATTACK_2(658, "CAN'T ROB") {},
    NO_SENIOR_COUNT(659, "SENIOR COUNT NOT ENOUGH") {},
    SENIOR_MINE_NOT_END(660, "SENIOR MINE NOT END") {},
    NOT_ON_SCORE_RANK(661, "NOT ON SCORE RANK") {},
    ALREADY_GET_AWARD(662, "ALREADY GET AWARD") {},
    FUNCTION_NO_OPEN(663, "FUNCTION_NO_OPEN") {},
    SCORE_NOT_ENOUGH(664, "SCORE_NOT_ENOUGH") {},
    TOPUP_NOT_ENOUGH(665, "TOPUP_NOT_ENOUGH") {},
    REFRESH_FAIL(666, "REFRESH_FAIL") {},
    PARTY_NAME_IS_EXIST(667, "PARTY_NAME_IS_EXIST") { // 军团名已存在
    },
    HERO_STAR_NOT_SAME(668, "HERO_STAR_NOT_SAME") { // 武将等级不一致
    },
    HERO_STAR_ERROR(669, "HERO_STAR_ERROR") { // 将星不可超过银
    },
    COUNT_ERROR(670, "COUNT_ERROR") { // 数量不对
    },
    PART_LOCKED(671, "PART_LOCKED") { // 配件已锁定
    },
    PRAY_EXIST(672, "PRAY_EXIST") { // 已祝福
    },
    NO_PRAY(673, "NO_PRAY") { // 未祝福
    },
    SCIENCE_FIT_SCOPE_IS_NOT_RIGHT(674, "SCIENCE_FIT_SCOPE_IS_NOT_RIGHT") { // 军工科技装载范围不对
    },
    SCIENCE_FIT_POS_IS_NOT_RIGHT(675, "SCIENCE_FIT_POS_IS_NOT_RIGHT") { // 装载的位置不存在
    },
    SCIENCE_POS_CAN_NOT_FIT(676, "SCIENCE_POS_CAN_NOT_FIT") { // 该位置不能装载军工科技
    },
    SCIENCE_Military_NOT_ENOUGH(677, "SCIENCE_Military_NOT_ENOUGH") { // 军工材料不够
    },
    SCIENCE_RefitTank_UN_ACTIVE(678, "SCIENCE_RefitTank_UN_ACTIVE") { // 军工改造未激活
    },
    SCIENCE_RefitTank_NO_CONFIG(679, "SCIENCE_RefitTank_NO_CONFIG") { // 未配置该坦克改造信息
    },
    SCIENCE_MILITARY_NO_CONFIG(680, "SCIENCE_MILITARY_NO_CONFIG") { // 未配置该军工科技信息
    },
    SCIENCE_THE_POS_UN_LOCK_NO_CONFIG(681, "SCIENCE_THE_POS_UN_LOCK_NO_CONFIG") { // 该位置没有配置解锁信息
    },
    SCIENCE_UN_LOCK_Material_NOT_ENOUGTH(682, "SCIENCE_UN_LOCK_Material_NOT_ENOUGTH") { // 解锁军工格子材料不够
    },
    SCIENCE_NO_GRID_NEED_UN_LOCK(683, "SCIENCE_NO_GRID_NEED_UN_LOCK") { // 没有需要解锁格子
    },
    SCIENCE_UN_BEGIN_CAUSE_LEVEL(684, "SCIENCE_UN_BEGIN_CAUSE_LEVEL") { // 等级未达到开启军工副本等级条件
    },
    SCIENCE_LOCKED(685, "SCIENCE_LOCKED") { // 军工科技未解锁
    },
    SCIENCE_LEVEL_MAX_LIMIT(686, "SCIENCE_LEVEL_MAX_LIMIT") { // 军工科技等级上限
    },
    SCIENCE_NO_INIT(687, "SCIENCE_NO_INIT") { // 军工科技未初始化
    },
    SCIENCE_LEVE_CAN_NOT_FIT(688, "SCIENCE_LEVE_CAN_NOT_FIT") { // 军工科技等级为0不可装配
    },
    POWER_LIMIT(689, "POWER_LIMIT") { // 体力已达上限
    },
    Fortress_No_Qualification_Join(690, "Fortress_No_Qualification_Join") { // 没有资格参加要塞战
    },
    Fortress_State_Is_Not_Right(691, "Fortress_State_Is_Not_Right") { // 要塞战状态不对
    },
    Fortress_DefencePalyer_IS_NOT_EXIST_OR_BE_OUT(
            692, "Fortress_DefencePalyer_IS_NOT_EXIST_OR_BE_OUT") { // 要塞防守玩家不存在或者被其他玩家击败
    },
    Fortress_Attack_CD(693, "Fortress_CD") { // 进攻或者防守CD中
    },
    Fortress_CD_TIME_BEGIN_NO_NEED_BUY(694, "Fortress_CD_TIME_BEGIN_NO_NEED_BUY") { // CD已到不需要购买
    },
    Fortress_Error_ReportKey(695, "Firtress_Error_ReportKey") { // 错误的要塞战报id
    },
    Fortress_Attr_Level_Limit(696, "Fortress_Attr_Level_Limit") { // 进修等级上限
    },
    Fortress_Have_Appoint_Job(697, "Fortress_Have_Appoint_Job") { // 已任命过职务
    },
    Fortress_Job_No_Exist_Or_Config(698, "Fortress_Job_No_Exist_Or_Config") { // 职位不存在或未配置
    },
    Fortress_Job_Is_Full(699, "Fortress_Job_Is_Full") { // 职位已满
    },
    Fortress_Add_Buff_Job_Just_App_Our_Party(
            700, "Fortress_Add_Buff_Job_Just_App_Our_Party") { // 增益类buff只能应用本军团成员
    },
    Fortress_Add_DeBuff_Job_Cant_APP_Our_Party(
            701, "Fortress_Add_DeBuff_Job_Cant_APP_Our_Party") { // 减益类buff只能应用非本军团成员
    },
    Fortress_No_Form(702, "Fortress_No_Form") { // 非要塞战阵型类型
    },
    Fortress_Error_Apponint_Time(703, "Fortress_Error_Apponint_Time") { // 错误的任命时间
    },
    Fortress_Already_Setting_Denfence(704, "Fortress_Already_Setting_Denfence") { // 要塞战已经设置了防守
    },
    Fortress_Not_Win_Party(705, "Fortress_Not_Win_Party") { // 要塞战胜利军团长才能任命
    },
    Fortress_No_End_Can_Not_Appoint_Job(706, "Fortress_No_End_Can_Not_Appoint_Job") { // 要塞未结束不能任命职位
    },
    Is_In_Fortress(707, "Is_In_Fortress") { // 要塞战中
    },
    ENERGY_STONE_NOT_ENOUGH(708, "ENERGY_STONE_NOT_ENOUGH") { // 能晶不足
    },
    ENERGY_STONE_MAX_LEVEL(709, "ENERGY_STONE_MAX_LEVEL") { // 能晶已到最高等级
    },
    ENERGY_STONE_INLAYED(710, "ENERGY_STONE_INLAYED") { // 镶嵌孔已经镶嵌有能晶
    },
    ENERGY_STONE_HOLE_ERROR(711, "ENERGY_STONE_HOLE_ERROR") { // 镶嵌孔类型不匹配
    },
    ENERGY_STONE_NOT_INLAY(712, "ENERGY_STONE_NOT_INLAY") { // 镶嵌孔还未镶嵌，不能执行卸下操作
    },
    ALTAR_PARTY_LV_LIMIT(713, "ALTAR_PARTY_LV_LIMIT") { // 祭坛建筑开启需要军团达到20级
    },
    ALTAR_LV_EXCEED(714, "ALTAR_LV_EXCEED") { // 祭坛等级不能超过军团大厅等级/5
    },
    ALTAR_NO_FORM(715, "ALTAR_NO_FORM") { // 祭坛BOSS还没有设置阵型
    },
    ALTAR_BOSS_CD(716, "ALTAR_BOSS_CD") { // 祭坛BOSS未到召唤时间
    },
    ALTAR_BOSS_BUILD_NOT_ENOUGH(717, "ALTAR_BOSS_BUILD_NOT_ENOUGH") { // 召唤祭坛BOSS，建设度不足
    },
    ALTAR_BOSS_STARTED(718, "ALTAR_BOSS_STARTED") { // 祭坛BOSS已开始
    },
    ALTAR_BOSS_IN_PARTY_TIME(719, "NEED 7 DAYS") { // 参加祭坛BOSS需要加入军团7天以上
    },
    CANNT_CROSSREG_CASE_FIGHTORRANKREASON(
            801, "CANNT_CROSSREG_CASE_FIGHTORRANKREASON") { // 战力或者排名没有达到报名条件
    },
    HAVE_REG_CROSS(802, "Have_Reg_CROSS") { // 已经报名跨服战
    },
    CROSS_REG_TIME_IS_WRONG(803, "CROSS_REG_TIME_IS_WRONG") { // 跨服战报名时间不对
    },
    CROSS_NO_REG(804, "CROSS_NO_REG") { // 跨服战未报名
    },
    CROSS_NO_SET_FORM_TIME(805, "CROSS_NO_SET_FORM_TIME") { // 未到设置阵型时间
    },
    CROSS_JUST_SET_FORM_1(806, "CROSS_JUST_SET_FORM_1") { // 只能设置第一个阵型
    },
    CROSS_REPORT_IS_NOT_EXISTED(807, "CROSS_REPORT_IS_NOT_EXISTED") { // 跨服战战报不存在
    },
    CROSS_BET_NUM_LIMIT(808, "CROSS_BET_NUM_LIMIT") { // 下注次数限制
    },
    CROSS_BET_NOT_TIME(809, "CROSS_BET_NOT_TIME") { // 不在下注时间内
    },
    CROSS_NO_OPPONENT(810, "CROSS_NO_OPPONENT") { // 没有对手
    },
    CROSS_NO_RANK_REG(811, "CROSS_NO_RANK_REG") { // 竞技场排名不够
    },
    CROSS_NO_BET_AIM(812, "CROSS_NO_BET_AIM") { // 下注目标不存在
    },
    CROSS_CAN_BET_TWO_BOY(813, "CROSS_CAN_BET_TWO_BOY") { // 不能同时对两边下注
    },
    CROSS_BET_HAVE_RECEIVE(814, "CROSS_BET_HAVE_RECEIVE") { // 已经领过奖励
    },
    CROSS_CANT_RECEVIE_BET_CAUSE_NO_FIGHT(
            815, "CROSS_CANT_RECEVIE_BET_CAUSE_NO_FIGHT") { // 没有战斗不能领取奖励
    },
    CROSS_SHOP_NOT_TIME(816, "CROSS_SHOP_NOT_TIME") { // 跨服商店，不在商店开启时间内
    },
    CROSS_SHOP_NOT_FOUND(817, "CROSS_SHOP_NOT_FOUND") { // 跨服商店，商品不存在
    },
    CROSS_SHOP_NOT_ENOUGH(818, "CROSS_SHOP_NOT_ENOUGH") { // 跨服商店，商品不足
    },
    CROSS_JIFEN_NOT_ENOUGH(819, "CROSS_JIFEN_NOT_ENOUGH") { // 跨服商店，积分不足
    },
    CROSS_FINAL_NO_BET(820, "CROSS_FINAL_NO_BET") { // 总决赛不下注
    },
    CROSS_NO_RANK(821, "CROSS_NO_RANK") { // 跨服战没有排名
    },
    CROSS_HAVE_RECEIVE_CROSS_RANK(822, "CROSS_HAVE_RECEIVE_CROSS_RANK") { // 已经领取跨服战奖励
    },
    CROSS_NO_BET(823, "CROSS_NO_BET") { // 没有下注
    },
    CROSS_ATHLETE_CAN_ECHAGE_Treasure(824, "CROSS_ATHLETE_CAN_ECHAGE_Treasure") { // 参赛玩家才能兑换珍品
    },
    CROSS_CAN_NOT_BET_CASE_HAVE_FIGHT(825, "CROSS_CAN_NOT_BET_CASE_HAVE_FIGHT") { // 已经战斗完了不能下注
    },
    CROSS_CAN_BET_CASE_SAME_CG(826, "CROSS_CAN_BET_CASE_SAME_CG") { // 同一场次只能下注一个玩家
    },
    CROSS_NO_RECEIVE_RANK_TIME(827, "CROSS_NO_RECEIVE_RANK_TIME") { // 没有到领取排名奖励时间
    },
    CROSS_CAN_RECEIVE_BET_CASE_TIME(828, "CROSS_CAN_RECEIVE_BET_CASE_TIME") { // 时间过期不能领取下注奖励
    },
    CROSS_CAN_NOT_EXCHANGE_CASE_TIME(829, "CROSS_CAN_NOT_EXCHANGE_CASE_TIME") { // 时间过期不能兑换
    },

    CROSS_PARTY_HAVE_REG(850, "CROSS_PARTY_HAVE_REG") { // 跨服军团已经报名
    },
    CROSS_PARTY_REG_RANK(851, "CROSS_PARTY_REG_RANK") { // 跨服军团报名资格不够
    },
    CROSS_PARTY_NO_IN_REG_TIME(852, "CROSS_PARTY_NO_IN_REG_TIME") { // 跨服战报名时间不对
    },
    CROSS_PARTY_NO_REG(853, "CROSS_PARTY_NO_REG") { // 没有报名跨服军团
    },
    CROSS_PARTY_NO_IN_FORM_TIME(854, "CROSS_PARTY_NO_IN_FORM_TIME") { // 不正确的跨服军团布阵时间
    },
    CROSS_PARTY_HAVE_RECEIVE(855, "CROSS_PARTY_HAVE_RECEIVE") { // 已经领取排名奖励
    },
    CROSS_PARTY_NO_RANK(856, "CROSS_PARTY_NO_RANK") { // 没有排名
    },
    CROSS_PARTY_CANT_SET_FORM_CASE_NO_REG(
            857, "CROSS_PARTY_CANT_SET_FORM_CASE_NO_REG") { // 没有报名不能设置阵型
    },
    CROSS_PARTY_NO_RECEIVE_TIME(858, "CROSS_PARTY_NO_RECEIVE_TIME") { // 未到领取跨服军团奖励时间
    },
    CROSS_PARTY_RECEIVE_EXCEED(859, "CROSS_PARTY_RECEIVE_EXCEED") { // 领取跨服军团奖励时间过期
    },
    CAN_NOT_QUIT_PARTY_CASE_CP(860, "CAN_NOT_QUIT_PARTY_CASE_CP") {// 跨服战已报名不能离开军团
    },
    NOT_IN_PARTY(861, "NOT_IN_PARTY") {// 不在军团中
    },

    HAVE_RECEIVE(901, "HAVE_RECEIVE") {// 已经领取
    },
    TIME_IS_NOT_UP(902, "TIME_IS_NOT_UP") {// 时间未到
    },
    NO_FIGHT_ADD(903, "NO_FIGHT_ADD") {// 战力暴增未领取
    },

    CD_REG_STAFFING(910, "CD_REG_STAFFING") {// 玩家报名资格不够
    },
    CD_NOT_REG_STATE(911, "CD_NOT_REG_STATE") {// 当前不是跨服军演报名时间
    },
    CD_ROLE_HAS_REG(912, "CD_ROLE_HAS_REG") {// 玩家已经报过名
    },
    CD_ROLE_NOT_REG(913, "CD_ROLE_NOT_REG") {// 玩家未报名
    },
    CD_BUFF_NOT_FOUND(914, "CD_BUFF_NOT_FOUND") {// 跨服军演，buff不存在
    },
    CD_BUFF_MAX_LV(915, "CD_BUFF_MAX_LV") {// 跨服军演，buff已达最高等级
    },
    CD_BUFF_RESOURCE_NOT_ENOUGH(916, "CD_BUFF_RESOURCE_NOT_ENOUGH") {// 跨服军演，buff升级资源不足
    },
    CD_NOT_REWARD_TIME(917, "CD_NOT_REWARD_TIME") {// 跨服军演，当前不是领奖时间
    },
    CD_ROLE_NOT_IN_RANK(918, "CD_ROLE_NOT_IN_RANK") {// 玩家未上榜
    },
    CD_ROLE_RECEIVED_RANK(919, "CD_ROLE_RECEIVED_RANK") {// 玩家已领取过排行奖励
    },
    CD_FIELD_NOT_EXIST(920, "CD_FIELD_NOT_EXIST") {// 跨服军演，战场不存在
    },
    CD_STRONGHOLD_NOT_EXIST(921, "CD_STRONGHOLD_NOT_EXIST") {// 跨服军演，据点不存在
    },
    CD_FIELD_NOT_PREPARE(922, "CD_FIELD_NOT_PREPARE") {// 跨服军演，战场当前不是备战状态，不能设置阵型
    },
    CD_ARMY_LIMIT(923, "CD_ARMY_LIMIT") {// 跨服军演，据点设置的部队达到上限
    },
    CD_NOT_KONCKOUT(924, "CD_NOT_KONCKOUT") {// 状态不正确
    },
    CD_KONCKOUT_NOT_EXIST(925, "CD_KONCKOUT_NOT_EXIST") {// 淘汰赛对战信息不存在
    },
    CD_BET_TARGET(926, "CD_BET_TARGET") {// 跨服军演两次投注目标不一致
    },
    CD_BET_LIMIT(927, "CD_BET_LIMIT") {// 跨服军演已达下注上限
    },
    CD_ROLE_NOT_BET(928, "CD_ROLE_NOT_BET") {// 跨服军演玩家没有下注
    },
    CD_BET_CAN_NOT_RECEIVE(929, "CD_BET_CAN_NOT_RECEIVE") {// 跨服军演玩家不能领取下注奖励
    },
    CD_SHOP_EXCHANGE(930, "CD_SHOP_EXCHANGE") {// 仅报名且参赛选手可兑换
    },

    // 1001-1050 军备错误信息
    LORD_EQUIP_ALEADY_PUTON(1001, "LORD_EQUIP_ALEADY_PUTON") {// 军备已经穿戴
    },
    NO_LORD_EQUIP(1002, "NO_LORD_EQUIP") {    //军备不存在
    },
    LORD_EQUIP_SCHEME_SAME_POS(1003, "LORD_EQUIP_SCHEME_SAME_POS") {    //军备方案出现重复部位
    },
    LORD_EQUIP_SCHEME_POS_MISSMATCH(1004, "LORD_EQUIP_SCHEME_POS_MISSMATCH") {    //军备方案出现重复部位
    },
    NO_SUCH_LORD_EQUIP_SCHEME(1005, "NO_SUCH_LORD_EQUIP_SCHEME") {    //不存在该方案
    },
    LORD_EQUIP_FUNCTION_CLOSE(1006, "LORD_EQUIP_FUNCTION_CLOSE") {    //军备功能未开放
    },

    LORD_EQUIP_SKILL_NO_NUM(1011, "LORD_EQUIP_SKILL_NO_NUM") {// 军备免费洗练没有免费次数了
    },
    LORD_EQUIP_SKILL_NO_GLOD(1012, "LORD_EQUIP_SKILL_NO_GLOD") {// 军备至尊洗练和神秘洗练没有免费足够金币
    },
    LORD_EQUIP_SKILL_NO_FULL_LEVEL(1013, "LORD_EQUIP_SKILL_NO_FULL_LEVEL") {// 军备神秘洗练没有满级
    },
    LORD_EQUIP_SKILL_CANNOT_CHANGE(1014, "LORD_EQUIP_SKILL_CANNOT_CHANGE") {// 没有神秘洗练功能
    },

    // 1101-1150 广告错误信息
    AD_LOGIN_COUNT(1101, "AD_LOGIN_COUNT") {// 登陆广告次数超过
    },
    AD_BUFF1_COUNT(1102, "AD_BUFF1_COUNT") {// 编制经验广告次数超过
    },
    AD_BUFF2_COUNT(1103, "AD_BUFF2_COUNT") {// 指挥官经验广告次数超过
    },
    AD_POWER_COUNT(1104, "AD_POWER_COUNT") {// 体力广告次数超过
    },
    AD_COMMOND_COUNT(1105, "AD_COMMOND_COUNT") {// 统率书广告次数超过
    },
    AD_FIRSTPAY_COUNT(1106, "AD_FIRSTPAY_COUNT") {// 首冲广告次数超过
    },
    AD_GETAWARD(1107, "AD_GETAWARD") {// 奖励已经领取过了
    },
    AD_FIRSTPAY_VIP(1108, "AD_FIRSTPAY_VIP") {// 该用户已经领取过首冲奖励了
    },
    AD_FIRSTPAY_NO(1109, "AD_FIRSTPAY_NO") {// 未达成领取条件
    },
    AD_NOEXIST(1110, "AD_NOEXIST") {// 该渠道没有此活动
    },

    // 1151-1250 运营活动相关错误信息
    // 1151-1180 运营活动通用错误信息
    ACTIVITY_FINISYH(1151, "ACTIVITY_FINISYH") {// 活动已经结束
    },
    ACT_GETAWARD(1152, "ACT_GETAWARD") {// 活动奖励已经领取过了
    },
    ACT_NOT_ENOUGH(1153, "ACT_NOT_ENOUGH") {// 领取次数不够
    },
    ACT_NOT_INIT_DATA(1158, "ACT_NOT_INIT_DATA") {// 活动数据未初始化
    },
    ACT_NOT_REFRESH_DATA(1159, "ACT_NOT_REFRESH_DATA") {// 活动数据未刷新
    },
    ACT_AWARD_COND_LIMIT(1160, "ACT_AWARD_COND_LIMIT") {// 未达到奖励领取条件
    },
    ACT_NOT_AWARD_TIME(1161, "ACT_NOT_AWARD_TIME") {// 非领奖时间段
    },

    // 1181-1190 运营活动--->大富翁(圣诞宝藏)错误码
    ACT_MONOPOLY_GRID_FINISH(1181, "ACT_MONOPOLY_GRID_FINISH") {// 已完成本轮游戏，请刷新地图
    },
    ACT_MONOPOLY_ENERGY_NOT_ENOUGH(1182, "ACT_MONOPOLY_ENERGY_NOT_ENOUGH") {// 大富翁精力不足
    },
    ACT_MONOPOLY_FREE_ENERGY_DRAW(1184, "ACT_MONOPOLY_FREE_ENERGY_DRAW") {// 大富翁已经领取过本次免费精力
    },
    // 1191-1200 运营活动--->抢红包 错误码
    ACT_RED_BAG_NOT_FOUND(1191, "ACT_RED_BAG_NOT_FOUND") {// 红包未找到错误
    },
    ACT_RED_BAG_GRAB_FINISH(1192, "ACT_RED_BAG_GRAB_FINISH") {// 红包被抢光了
    },
    ACT_RED_BAG_AREADY_GRAB(1192, "ACT_RED_BAG_AREADY_GRAB") {// 已经抢过此红包了
    },

    // 1051-1060 静态数据错误信息
    STATIC_DATA_NOT_FOUND(1051, "STATIC_DATA_NOT_FOUND") {// 静态数据缺失
    },
    STATIC_DATA_ERROR(1052, "STATIC_DATA_ERROR") {// 静态错误
    },

    // 1061-1070 军衔错误
    MILITARY_RANK_MAX_ERROR(1061, "MILITARY_RANK_MAX_ERROR") {// 军衔已经最大
    },

    // 1071-1100 坦克相关错误信息
    TANK_NOT_FOUND_IN_TANKS(1071, "TANK_NOT_FOUND_IN_TANKS") {// 没找到坦克
    },

    // 1251-1280 将领相关错误信息
    HERO_CANNOT_PUT(1251, "HERO_CANNOT_PUT") {// 将领不在可入驻配置表里，不能入驻参谋部
    },
    HERO_OVER_NUM(1252, "HERO_OVER_NUM") {// 超过设置的最大可设置数量
    },
    HERO_ALREADY_PUT(1253, "HERO_ALREADY_PUT") {// 已经入驻
    },
    HERO_NOT_ENOUGH(1254, "HERO_NOT_ENOUGH") {// 将领数目不够入驻
    },

    // 1281-1300 排行榜相关错误
    STRONGEST_FORM_SET_ERR(1281, "STRONGEST_FORM_SET_ERROR") {// 最强实力阵形设置错误
    },

    // 1301-1320 秘密武器错误
    SECRET_WEAPON_STUDY_LOCK_MAX(1301, "SECRET_WEAPON_STUDY_LOCK_MAX") {// 锁定栏目满了
    },

    // 1321-1340 作战实验室错误
    FIGHT_LAB_SKILL_NOT_FOUND(1321, "FIGHT_LAB_SKILL_NOT_FOUND") {// 技能未解锁
    },

    // 1340-1350 点击宝箱获得奖励
    GIFT_REWARD_NO_COUNT(1340, "GIFT_REWARD_NO_COUNT") {// 今天无法再领取更多礼物了
    },

    // 1350-1370 红色方案
    RED_PLAN_LAST_AREA(1351, "RED_PLAN_LAST_AREA") {// 上一个地图未完成
    },
    RED_PLAN_NOT_OPEN(1352, "RED_PLAN_NOT_OPEN") {// 该区域未开启
    },
    RED_PLAN_FUEL(1353, "RED_PLAN_FUEL") {// 燃料不足
    },
    RED_PLAN_COUNT(1354, "RED_PLAN_COUNT") {// 购买次数不足
    },
    RED_PLAN_REWARD(1355, "RED_PLAN_REWARD") {// 已经领取过该奖励
    },
    RED_PLAN_AREA(1356, "RED_PLAN_AREA") {// 没有全部通关该地图
    },
    RED_PLAN_MAX_FUEL(1357, "RED_PLAN_MAX_FUEL") {// 燃料满足不需要购买
    },

    // 1380-1400 赏金活动
    TEAM_NOT_HAVE(1380, "TEAM_NOT_HAVE") {// 角色无队伍
    },
    TEAM_HAVE(1381, "TEAM_HAVE") {// 角色已有队伍
    },
    TEAM_FULL(1382, "TEAM_FULL") {// 队伍已满
    },
    NO_TEAMS_TO_JOIN(1383, "NO_TEAMS_TO_JOIN") {// 无可加入的队伍
    },
    TEAM_RIGHT_LIMIT(1384, "TEAM_RIGHT_LIMIT") {// 权限不足
    },
    TEAM_NO_FORM(1385, "TEAM_NO_FORM") {// 阵型不能为空
    },
    CAN_NOT_INVITE(1386, "CAN_NOT_INVITE") {// 权限不足，无法邀请
    },
    BOUNTY_SHOP_COUNT(1387, "BOUNTY_SHOP_COUNT") {// 购买次数不足
    },
    BOUNTY_SHOP_NOGOOD(1388, "BOUNTY_SHOP_COUNT") {// 商品不存在或已下架
    },
    BOUNTY_NOT_ENOUGH(1389, "BOUNTY_NOT_ENOUGH") {// 代币数量不足
    },
    STAGE_NOT_OPEN(1390, "STAGE_NOT_OPEN") {// 关卡未开放
    },
    TEAM_UNREADY(1391, "TEAM_UNREADY") {// 队伍未准备
    },
    TEAM_NOT(1392, "TEAM_NOT") {// 队伍已经解散
    },
    TEAM_MEMBER_NOT_ENOUGH(1393, "TEAM_MEMBER_NOT_ENOUGH") { // 队伍人数不足
    },
    TEAM_INVALID_PARAM(1394, "TEAM_INVALID_PARAM") { // 交换顺序时，参数错误
    },


    // 1401-1410 叛军优化
    REBEL_BOX_NULL(1401, "REBEL_BOX_NULL") {// 礼盒不存在
    },
    REBEL_NO_PARTY(1402, "REBEL_NO_PARTY") {// 玩家未加入军团
    },
    SERVER_STOP(1404, "SERVER_STOP") {// 服务器正在维护中
    },

    // 1411-1420 配件转换
    PART_LEVEL_NOT_ENOUGH(1411, "PART_LEVEL_NOT_ENOUGH") {// 未达到配件转换功能开启等级
    },
    PART_VIP_NOT_ENOUGH(1412, "PART_VIP_NOT_ENOUGH") {// vip等级不足
    },
    PART_QUALITY_NOT_ENOUGH(1413, "PART_QUALITY_NOT_ENOUGH") {// 配件品质不足
    },
    PART_NOT_SAME_POS(1414, "PART_NOT_SAME_POS") {// 配件不是同一个部位
    },

    // 1421-1430 金币车转换
    TANK_NOT_ENOUGH(1421, "TANK_NOT_ENOUGH") {// 坦克数量不足
    },
    DONT_SUP_CONVERT(1422, "CAN_NOT_CONVERT") {// 不支持该转换
    },
    MATERIRALS_NOT_ENOUGH(1423, "MATERIRALS_NOT_ENOUGH") { // 材料不足
    },
    HERO_FREEWAR_TIME(1424, "HERO_FREEWAR_TIME") { // 在保护时间内
    },

    // 1431-1440
    HONOURLIVE_NOT_OPEN(1431, "HONOURLIVE_NOT_OPEN") { // 荣耀生存玩法未开启
    },
    LOGIN_AWARD_SATTUS_ERROR(1432, "LOGIN_AWARD_SATTUS_ERROR") { // 奖励状态错误，不可领或已领
    },
    PARTY_COMBAT_NO_AWARD(1433, "PARTY_COMBAT_NO_AWARD") { // 不存在可领的军团副本奖励
    },
    QUESTIONNAIRE_TWICE_ERROR(1434, "QUESTIONNAIRE_TWICE_ERROR") { // 问卷调查活动不可重复提交
    },
    ARTICLES_ARE_INVALID(1435, "ARTICLES_ARE_INVALID") { // 每日奖励限制为当日领取
    },
    RANK_KING_REWARD(1436, "RANK_KING_REWARD") { // 新加入军团不能领取奖励
    },
    USE_TACTICS_ERROR(1437, "USE_TACTICS_ERROR") {//战术不存在,或出战
    },
    NO_MUTUAL_FRIEND(1438, "NO_MUTUAL_FRIEND") {//双方非互为好友
    },
    MAX_FRIENDLINESS(1439, "MAX_FRIENDLINESS") {//好友度已达上限
    },
    FRIEND_CUR_MONTH_GIVE_MAX(1440, "FRIEND_CUR_MONTH_GIVE_MAX") {//好友当月赠送次数已达上限
    },
    PLAYER_CUR_MONTH_GIVE_TOTAL_MAX(1441, "PLAYER_CUR_MONTH_GIVE_TOTAL_MAX") {//玩家当月赠送累计次数已达上限
    },
    FRIENDLINESS_NOT_ENOUGH(1442, "FRIENDLINESS_NOT_ENOUGH") {//好友度不足
    },
    //扫荡条件不足
    WIPE_COMBAT(1443, "WIPE_COMBAT") {
    },
    GET_FRIEND_GIVE_PROP_NUM_MAX(1444, "GET_FRIEND_GIVE_PROP_NUM_MAX") {//获取好友赠送道具数量已达上限

    };

    public int getCode() {
        return code;
    }

    public void setCode(int code) {
        this.code = code;
    }

    public String getMsg() {
        return msg;
    }

    public void setMsg(String msg) {
        this.msg = msg;
    }

    private GameError(int code, String msg) {
        this.code = code;
        this.msg = msg;
    }

    private int code;
    private String msg;
}
