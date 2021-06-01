
DetailText = {}

DetailText.arena = {
{{content="挑战他人可获得积分和装备升级材料"}},
{{content="积分可以在竞技场商店兑换奖励"}},
{{content="排名前500的玩家每天可领取排名奖励"}},
{{content="战斗规则："}},
{{content="1.战斗不损兵"}},
{{content="2.先手值高的先手；先手值一致，进攻方先手；"}},
{{content="3.出战阵型为设置界面的阵型；"}},
{{content="4.连胜次数越高，胜利可获得更多积分；"}},
{{content="5.次数为0可购买挑战次数，VIP等级越高.可购买次数越多。"}},
}

DetailText.limitCombat = {
{{content = "指挥官达到20级开启限时关卡"}},
{{content = "攻打关卡.可获得宝物碎片"}},
{{content = "碎片可以在神秘商店进行奖励兑换"}},
{{content = "每个关卡有不同等级据点"}},
{{content = "攻打高级据点可获得更多的宝物碎片"}},
{{content = "攻打胜利固定扣除1次次数"}},
{{content = "失败不扣除"}},
}

DetailText.fightValue = {
{{{content = "此统率等级等于角色等级"}}, {{content = "此项可达100%%"}}},
{{{content = "此技能等级等于角色等级"}}, {{content = "此项可达100%%"}}},
{{{content = "当所有部队穿戴装备全部为最高品质"}}, {{content = "此项可达100%%"}}},
{{{content = "当所有部队装备等级等于角色等级"}}, {{content = "此项可达100%%"}}},
{{{content = "当所有兵种装配的配件全部为最高品质"}}, {{content = "此项可达100%%"}}},
{{{content = "当所有兵种配件等级等于角色等级"}}, {{content = "此项可达100%%"}}},
{{{content = "当所有兵种配件改造等级等于%d级"}}, {{content = "此项可达100%%"}}},
{{{content = "当8项战斗科技（攻击和生命）等级等于角色等级"}}, {{content = "此项可达100%%"}}},
{{{content = "当4项军团科技（命中、闪避、暴击、抗暴）等级等于军团等级"}}, {{content = "此项可达100%%"}}},
{{{content = "当一支部队每个部队位为最强兵种最大带兵数"}}, {{content = "此项可达100%%"}}},
{{{content = "可出战多支部队满编"}}, {{content = "此项可达100%%"}}},
{{{content = "当前繁荣度达到10级"}}, {{content = "此项可达100%%"}}},
}

DetailText.part = {
{{content = "1.配件可通过探险配件关卡获得"}},
{{content = "2.配件能够增加兵种属性：攻击、生命、穿刺和防护"}},
{{content = "    穿刺：增加己方部队伤害结果"}},
{{content = "    防护：减少敌方部队伤害结果"}},
{{content = "3.配件可进行强化.提升配件属性数值"}},
{{content = "4.配件可进行改造，极大提升配件属性数值"}},
{{content = "    改造材料可通过探险配件关卡获得"}},
{{content = "5.蓝紫色配件需要通关碎片合成获得"}},
{{content = "6.橙色配件需通过紫色配件进阶获得"}},
{{content = "7.无用的配件和碎片可进行分解，分解获得改造材料"}},
}

DetailText.extremeCombat = {
{{content = "玩法说明："}},
{{content = "1.每个关卡可挑战3次"}},
{{content = "    挑战次数为0后，需要重置方可挑战"}},
{{content = "    重置副本会消耗少量能量点"}},
{{content = "    每天有1次重置机会，重置后可进行扫荡或挑战副本"}},
{{content = "    关卡挑战回合数限制为100回合，超过回合数判定为失败"}},
{{content = "2.每一关有特定的通关条件"}},
{{content = "    挑战达到通关条件后，方可获得奖励"}},
{{content = "3.可扫荡已通过关卡"}},
{{content = "    每一关有固定的扫荡时间"}},
{{content = "    手动停止扫荡可立即获得扫荡奖励"}},
{{content = "    扫荡自动完成后，通过邮件发放奖励"}},
}


DetailText.energyspar = {
{{content = "能晶镶嵌"}},
{{content = "（1）每个出战部位可镶嵌1套能晶"}},
{{content = "（2）每套能晶包含6个能晶格"}},
{{content = "（3）每个格子可镶嵌不同类型的能晶"}},
{{content = "     红色格：可镶嵌攻击或暴击"}},
{{content = "     蓝色格：可镶嵌生命或抗暴"}},
{{content = "     黄色格：可镶嵌命中或闪避"}},
{{content = "（4）镶嵌满5个高级能晶激活隐藏属性"}},
{{content = "（5）6个能晶格不能镶嵌同类能晶"}},
{{content= " "}},
{{content = "能晶成长"}},
{{content = "（1）能晶有6类"}},
{{content = "（2）对应增加攻击，生命，暴击，抗暴，命中，闪避"}},
{{content = "（3）使用1到3个低级能晶可合成获得"}},
{{content = "（4）合成失败，必定损失1个低级能晶"}},
{{content = "（5）建议各位指挥官凑满能晶进行合成，不然损失能晶可别骂可怜的客服MM哦"}},
{{content= " "}},
{{content = "能晶获得"}},
{{content = "（1）攻打能晶关卡"}},
{{content = "（2）攻打军团祭坛BOSS"}},
}

local labelColor = cc.c3b(0, 0, 0)
DetailText.vip = {
-- VIP1
{{{content = "1.享受", color = labelColor}, {content = "1个", color = COLOR[2]}, {content = "坦克生产/改装、物质生产和科研", color = labelColor}, {content = "等待队列", color = COLOR[5]}},
	{{content = "2.每天可以购买", color = labelColor}, {content = "2次", color = COLOR[2]}, {content = "能量", color = labelColor}},
	{{content = "3.开放购买第", color = labelColor}, {content = "3个", color = COLOR[2]}, {content = "建筑建造位", color = COLOR[5]}},
	{{content = "4.可重置日常任务", color = labelColor}, {content = "2次", color = COLOR[2]}},
	{{content = "5.", color = labelColor}, {content = "建筑升级提速", color = COLOR[5]}, {content = "20%", color = COLOR[2]}},
	{{content = "6.每日可购买", color = labelColor}, {content = "2次", color = COLOR[2]}, {content = "竞技场额外挑战次数", color = COLOR[5]}},
	{{content = "7.每日可重置", color = labelColor}, {content = "1次", color = COLOR[2]}, {content = "装备、配件关卡", color = COLOR[5]}},
	{{content = "8.每日可重置", color = labelColor}, {content = "1次", color = COLOR[2]}, {content = "军工科技副本", color = COLOR[5]}},
	{{content = "9.每日可重置", color = labelColor}, {content = "1次", color = COLOR[2]}, {content = "限时副本", color = COLOR[5]}},
	{{content = "10.每日可重置", color = labelColor}, {content = "1次", color = COLOR[2]}, {content = "能晶、勋章、战术副本", color = COLOR[5]}},
	{{content = "11.战胜敌军多扣除敌军", color = labelColor}, {content = "20点繁荣度", color = COLOR[2]}},
	{{content = "12.累计充值", color = labelColor}, {content = "50金币", color = COLOR[2]}, {content = "可达到", color = COLOR[5]}}},
-- VIP2
{{{content = "1.每天可以购买", color = labelColor}, {content = "3次", color = COLOR[2]}, {content = "能量", color = labelColor}},
	{{content = "2.可重置日常任务", color = labelColor}, {content = "3次", color = COLOR[2]}},
	{{content = "3.可", color = labelColor}, {content = "同时出战", color = COLOR[5]}, {content = "4支", color = COLOR[2]}, {content = "部队", color = labelColor}},
	{{content = "4.世界地图中", color = labelColor}, {content = "行军加速", color = COLOR[5]}, {content = "20%", color = COLOR[2]}},
	{{content = "5.每日可购买", color = labelColor}, {content = "3次", color = COLOR[2]}, {content = "竞技场额外挑战次数", color = labelColor}},
	{{content = "6.战胜敌军多扣除敌军", color = labelColor}, {content = "40点繁荣度", color = COLOR[2]}},
	{{content = "7.同时享受VIP1所有特权", color = labelColor}},
	{{content = "8.累计充值", color = labelColor}, {content = "500金币", color = COLOR[2]}, {content = "可达到", color = labelColor}}},
-- VIP3
{{{content = "1.享受", color = labelColor}, {content = "2个", color = COLOR[2]}, {content = "坦克生产/改装、物质生产和科研", color = labelColor}, {content = "等待队列", color = COLOR[5]}},
	{{content = "2.每天可以购买", color = labelColor}, {content = "4次", color = COLOR[2]}, {content = "能量", color = labelColor}},
	{{content = "3.开放购买第", color = labelColor}, {content = "4个", color = COLOR[2]}, {content = "建筑建造位", color = COLOR[5]}},
	{{content = "4.可重置日常任务", color = labelColor}, {content = "4次", color = COLOR[2]}},
	{{content = "5.", color = labelColor}, {content = "建筑升级提速", color = COLOR[5]}, {content = "40%", color = COLOR[2]}},
	{{content = "6.增加", color = labelColor},{content = "10%", color = COLOR[2]},{content = "战斗经验", color = labelColor}},
	{{content = "7.开放", color = labelColor}, {content = "关卡扫荡", color = COLOR[5]}, {content = "特权", color = labelColor}},
	{{content = "8.每日可重置", color = labelColor}, {content = "2次", color = COLOR[2]}, {content = "装备、配件关卡", color = labelColor}},
	{{content = "9.强化配件", color = labelColor}, {content = "基础成功率", color = COLOR[5]}, {content = "增加", color = labelColor}, {content = "10%", color = COLOR[2]}},
	{{content = "10.每日可购买", color = labelColor}, {content = "5次", color = COLOR[2]}, {content = "竞技场额外挑战次数", color = labelColor}},
	{{content = "11.战胜敌军多扣除敌军", color = labelColor}, {content = "60点繁荣度", color = COLOR[2]}},
	{{content = "12.同时享受VIP2所有特权", color = labelColor}},
	{{content = "13.累计充值", color = labelColor}, {content = "1000金币", color = COLOR[2]}, {content = "可达到", color = labelColor}}},
-- VIP4
{{{content = "1.每天可以购买", color = labelColor}, {content = "5次", color = COLOR[2]}, {content = "能量", color = labelColor}},
	{{content = "2.可重置日常任务", color = labelColor}, {content = "5次", color = COLOR[2]}},
	{{content = "3.可", color = labelColor}, {content = "同时出战", color = COLOR[5]}, {content = "5支", color = COLOR[5]}, {content = "部队", color = labelColor}},
	{{content = "4.减少", color = labelColor}, {content = "坦克生产耗时", color = COLOR[5]}, {content = "20%", color = COLOR[2]}},
	{{content = "5.减少", color = labelColor}, {content = "坦克改装耗时", color = COLOR[5]}, {content = "20%", color = COLOR[2]}},
	{{content = "6.每日可购买", color = labelColor}, {content = "7次", color = COLOR[2]}, {content = "竞技场额外挑战次数", color = labelColor}},
	{{content = "7.战胜敌军多扣除敌军", color = labelColor}, {content = "80点繁荣度", color = COLOR[2]}},
	{{content = "8.同时享受VIP3所有特权", color = labelColor}},
	{{content = "9.累计充值", color = labelColor}, {content = "2000金币", color = COLOR[2]}, {content = "可达到", color = labelColor}}},
-- VIP5
{{{content = "1.享受", color = labelColor}, {content = "3个", color = COLOR[2]}, {content = "坦克生产/改装、物质生产和科研", color = labelColor}, {content = "等待队列", color = COLOR[5]}},
	{{content = "2.每天可以购买", color = labelColor}, {content = "6次", color = COLOR[2]}, {content = "能量", color = labelColor}},
	{{content = "3.开放购买第", color = labelColor}, {content = "5个", color = COLOR[2]}, {content = "建筑建造位", color = COLOR[5]}},
	{{content = "4.可重置日常任务", color = labelColor}, {content = "6次", color = COLOR[2]}},
	{{content = "5.", color = labelColor}, {content = "科技加速", color = COLOR[5]}, {content = "20%", color = COLOR[2]}},
	{{content = "6.增加", color = labelColor},{content = "15%", color = COLOR[2]},{content = "战斗经验", color = labelColor}},
	{{content = "7.每日可购买", color = labelColor}, {content = "10次", color = COLOR[2]}, {content = "竞技场额外挑战次数", color = labelColor}},
	{{content = "8.每日可重置", color = labelColor}, {content = "3次", color = COLOR[2]}, {content = "装备、配件关卡", color = labelColor}},
	{{content = "9.每日可重置", color = labelColor}, {content = "2次", color = COLOR[2]}, {content = "军工科技副本", color = labelColor}},
	{{content = "10.每日可重置", color = labelColor}, {content = "2次", color = COLOR[2]}, {content = "限时副本", color = labelColor}},
	{{content = "11.每日可重置", color = labelColor}, {content = "2次", color = COLOR[2]}, {content = "能晶、勋章、战术副本", color = labelColor}},
	{{content = "12.战胜敌军多扣除敌军", color = labelColor}, {content = "100点繁荣度", color = COLOR[2]}},
	{{content = "13.同时享受VIP4所有特权", color = labelColor}},
	{{content = "14.累计充值", color = labelColor}, {content = "5000金币", color = COLOR[2]}, {content = "可达到", color = labelColor}}},
-- VIP6
{{{content = "1.每天可以购买", color = labelColor}, {content = "7次", color = COLOR[2]}, {content = "能量", color = labelColor}},
	{{content = "2.可重置日常任务", color = labelColor}, {content = "7次", color = COLOR[2]}},
	{{content = "3.可", color = labelColor}, {content = "同时出战", color = COLOR[5]}, {content = "6支", color = COLOR[2]}, {content = "部队", color = labelColor}},
	{{content = "4.强化配件", color = labelColor}, {content = "基础成功率", color = COLOR[5]}, {content = "增加", color = COLOR[2]}, {content = "20%", color = labelColor}},
	{{content = "5.世界资源据点", color = labelColor}, {content = "采集加速", color = COLOR[5]}, {content = "20%", color = COLOR[2]}},
	{{content = "6.每日可购买", color = labelColor}, {content = "15次", color = COLOR[2]}, {content = "竞技场额外挑战次数", color = labelColor}},
	{{content = "7.战胜敌军多扣除敌军", color = labelColor}, {content = "150点繁荣度", color = COLOR[2]}},
	{{content = "8.同时享受VIP5所有特权", color = labelColor}},
	{{content = "9.累计充值", color = labelColor}, {content = "10000金币", color = COLOR[2]}, {content = "可达到", color = labelColor}},
	{{content = "10.开启世界BOSS自动战斗", color = labelColor}}},
-- VIP7
{{{content = "1.享受", color = labelColor}, {content = "4个", color = COLOR[2]}, {content = "坦克生产/改装、物质生产和科研", color = labelColor}, {content = "等待队列", color = COLOR[5]}},
	{{content = "2.每天可以购买", color = labelColor}, {content = "8次", color = COLOR[2]}, {content = "能量", color = labelColor}},
	{{content = "3.开放购买第", color = labelColor}, {content = "6个", color = COLOR[2]}, {content = "建筑建造位", color = COLOR[5]}},
	{{content = "4.可重置日常任务", color = labelColor}, {content = "8次", color = COLOR[2]}},
	{{content = "5.", color = labelColor}, {content = "科技加速", color = COLOR[5]}, {content = "40%", color = COLOR[2]}},
	{{content = "6.增加", color = labelColor},{content = "20%", color = COLOR[2]},{content = "战斗经验", color = labelColor}},
	{{content = "7.同时享受VIP6所有特权", color = labelColor}},
	{{content = "8.每日可重置", color = labelColor}, {content = "4次", color = COLOR[2]}, {content = "装备、配件关卡", color = labelColor}},
	{{content = "9.每日可购买", color = labelColor}, {content = "20次", color = COLOR[2]}, {content = "竞技场额外挑战次数", color = labelColor}},
	{{content = "10.战胜敌军多扣除敌军", color = labelColor}, {content = "200点繁荣度", color = COLOR[2]}},
	{{content = "11.累计充值", color = labelColor}, {content = "20000金币", color = COLOR[2]}, {content = "可达到", color = labelColor}}},
-- VIP8
{{{content = "1.每天可以购买", color = labelColor}, {content = "9次", color = COLOR[2]}, {content = "能量", color = labelColor}},
	{{content = "2.可重置日常任务", color = labelColor}, {content = "9次", color = COLOR[2]}},
	{{content = "3.可", color = labelColor}, {content = "同时出战", color = COLOR[5]}, {content = "7支", color = COLOR[2]}, {content = "部队", color = labelColor}},
	{{content = "4.世界地图中", color = labelColor}, {content = "行军加速", color = COLOR[5]}, {content = "40%", color = COLOR[2]}},
	{{content = "5.每日可购买", color = labelColor}, {content = "25次", color = COLOR[2]}, {content = "竞技场额外挑战次数", color = labelColor}},
	{{content = "6.战胜敌军多扣除敌军", color = labelColor}, {content = "250点繁荣度", color = COLOR[2]}},
	{{content = "7.同时享受VIP7所有特权", color = labelColor}},
	{{content = "8.累计充值", color = labelColor}, {content = "50000金币", color = COLOR[2]}, {content = "可达到", color = labelColor}}},
-- VIP9
{{{content = "1.享受", color = labelColor}, {content = "5个", color = COLOR[2]}, {content = "坦克生产/改装、物质生产和科研", color = labelColor}, {content = "等待队列", color = COLOR[5]}},
	{{content = "2.每天可以购买", color = labelColor}, {content = "10次", color = COLOR[2]}, {content = "能量", color = labelColor}},
	{{content = "3.开放购买第", color = labelColor}, {content = "7个", color = COLOR[2]}, {content = "建筑建造位", color = COLOR[5]}},
	{{content = "4.可重置日常任务", color = labelColor}, {content = "10次", color = COLOR[2]}},
	{{content = "5.", color = labelColor}, {content = "建筑升级提", color = COLOR[5]}, {content = "60%", color = COLOR[2]}},
	{{content = "6.强化配件", color = labelColor}, {content = "基础成功率", color = COLOR[2]}, {content = "增加", color = labelColor}, {content = "30%", color = COLOR[2]}},
	{{content = "7.增加", color = labelColor},{content = "25%", color = COLOR[2]},{content = "战斗经验", color = labelColor}},
	{{content = "8.每日可购买", color = labelColor}, {content = "50次", color = COLOR[2]}, {content = "竞技场额外挑战次数", color = labelColor}},
	{{content = "9.每日可重置", color = labelColor}, {content = "5次", color = COLOR[2]}, {content = "装备、配件关卡", color = labelColor}},
	{{content = "10.每日可重置", color = labelColor}, {content = "3次", color = COLOR[2]}, {content = "军工科技副本", color = labelColor}},
	{{content = "11.每日可重置", color = labelColor}, {content = "3次", color = COLOR[2]}, {content = "限时副本", color = labelColor}},
	{{content = "12.每日可重置", color = labelColor}, {content = "3次", color = COLOR[2]}, {content = "能晶、勋章、战术副本", color = labelColor}},
	{{content = "13.战胜敌军多扣除敌军", color = labelColor}, {content = "350点繁荣度", color = COLOR[2]}},
	{{content = "14.同时享受VIP8所有特权", color = labelColor}},
	{{content = "15.累计充值", color = labelColor}, {content = "100000金币", color = COLOR[2]}, {content = "可达到", color = labelColor}}},
-- VIP10
{{{content = "1.每天可以购买", color = labelColor}, {content = "11次", color = COLOR[2]}, {content = "能量", color = labelColor}},
	{{content = "2.可重置日常任务", color = labelColor}, {content = "11次", color = COLOR[2]}},
	{{content = "3.可", color = labelColor}, {content = "同时出战", color = COLOR[5]}, {content = "8支", color = COLOR[2]}, {content = "部队", color = labelColor}},
	{{content = "4.世界资源据点", color = labelColor}, {content = "采集加速", color = COLOR[5]}, {content = "40%", color = COLOR[2]}},
	{{content = "5.每日可购买", color = labelColor}, {content = "80次", color = COLOR[2]}, {content = "竞技场额外挑战次数", color = labelColor}},
	{{content = "6.战胜敌军多扣除敌军", color = labelColor}, {content = "450点繁荣度", color = COLOR[2]}},
	{{content = "7.同时享受VIP9所有特权", color = labelColor}},
	{{content = "8.累计充值", color = labelColor}, {content = "200000金币", color = COLOR[2]}, {content = "可达到", color = labelColor}}},
-- VIP11
{{{content = "1.享受", color = labelColor}, {content = "6个", color = COLOR[2]}, {content = "坦克生产/改装、物质生产和科研", color = labelColor}, {content = "等待队列", color = COLOR[5]}},
	{{content = "2.每天可以购买", color = labelColor}, {content = "12次", color = COLOR[2]}, {content = "能量", color = labelColor}},
	{{content = "3.可重置日常任务", color = labelColor}, {content = "12次", color = COLOR[2]}},
	{{content = "4.减少", color = labelColor}, {content = "坦克生产耗时", color = COLOR[5]}, {content = "40%", color = COLOR[2]}},
	{{content = "5.减少", color = labelColor}, {content = "坦克改装耗时", color = COLOR[5]}, {content = "40%", color = COLOR[2]}},
	{{content = "6.科技加速", color = COLOR[5]}, {content = "50%", color = COLOR[2]}},
	{{content = "7.增加", color = labelColor},{content = "30%", color = COLOR[2]},{content = "战斗经验", color = labelColor}},
	{{content = "8.每日可购买", color = labelColor}, {content = "100次", color = COLOR[2]}, {content = "竞技场额外挑战次数", color = labelColor}},
	{{content = "9.每日可重置", color = labelColor}, {content = "6次", color = COLOR[2]}, {content = "装备、配件关卡", color = labelColor}},
	{{content = "10.战胜敌军多扣除敌军", color = labelColor}, {content = "550点繁荣度", color = COLOR[2]}},
	{{content = "11.同时享受VIP10所有特权", color = labelColor}},
	{{content = "12.累计充值", color = labelColor}, {content = "500000金币", color = COLOR[2]}, {content = "可达到", color = labelColor}}},

-- VIP12
{{{content = "1.每天可以购买", color = labelColor}, {content = "13次", color = COLOR[2]}, {content = "能量", color = labelColor}},
	{{content = "2.可重置日常任务", color = labelColor}, {content = "13次", color = COLOR[2]}},
	{{content = "3.减少", color = labelColor}, {content = "坦克生产耗时", color = COLOR[5]}, {content = "50%", color = COLOR[2]}},
	{{content = "4.减少", color = labelColor}, {content = "坦克改装耗时", color = COLOR[5]}, {content = "50%", color = COLOR[2]}},
	{{content = "5.增加", color = labelColor},{content = "35%", color = COLOR[2]},{content = "战斗经验", color = labelColor}},
	{{content = "6.战胜敌军多扣除敌军", color = labelColor}, {content = "650点繁荣度", color = COLOR[2]}},
	{{content = "7.同时享受VIP11所有特权", color = labelColor}},
	{{content = "8.累计充值", color = labelColor}, {content = "1000000金币", color = COLOR[2]}, {content = "可达到", color = labelColor}}},
	
-- VIP13
{{{content = "1.每天可以购买", color = labelColor}, {content = "13次", color = COLOR[2]}, {content = "能量", color = labelColor}},
	{{content = "2.每日可重置", color = labelColor}, {content = "5次", color = COLOR[2]}, {content = "军工科技副本", color = labelColor}},
	{{content = "3.每日可重置", color = labelColor}, {content = "5次", color = COLOR[2]}, {content = "限时副本", color = labelColor}},
	{{content = "4.每日可重置", color = labelColor}, {content = "5次", color = COLOR[2]}, {content = "能晶、勋章、战术副本", color = labelColor}},
	{{content = "5.增加", color = labelColor},{content = "40%", color = COLOR[2]},{content = "战斗经验", color = labelColor}},
	{{content = "6.战胜敌军多扣除敌军", color = labelColor}, {content = "750点繁荣度", color = COLOR[2]}},
	{{content = "7.同时享受VIP12所有特权", color = labelColor}},
	{{content = "8.累计充值", color = labelColor}, {content = "1500000金币", color = COLOR[2]}, {content = "可达到", color = labelColor}}},
	
-- VIP14
{{{content = "1.每天可以购买", color = labelColor}, {content = "15次", color = COLOR[2]}, {content = "能量", color = labelColor}},
	{{content = "2.每日可重置", color = labelColor}, {content = "10次", color = COLOR[2]}, {content = "军工科技副本", color = labelColor}},
	{{content = "3.每日可重置", color = labelColor}, {content = "10次", color = COLOR[2]}, {content = "限时副本", color = labelColor}},
	{{content = "4.每日可重置", color = labelColor}, {content = "10次", color = COLOR[2]}, {content = "能晶、勋章、战术副本", color = labelColor}},
	{{content = "5.增加", color = labelColor},{content = "45%", color = COLOR[2]},{content = "战斗经验", color = labelColor}},
	{{content = "6.战胜敌军多扣除敌军", color = labelColor}, {content = "850点繁荣度", color = COLOR[2]}},
	{{content = "7.同时享受VIP13所有特权", color = labelColor}},
	{{content = "8.累计充值", color = labelColor}, {content = "2000000金币", color = COLOR[2]}, {content = "可达到", color = labelColor}}},
	
-- VIP15
{{{content = "1.每天可以购买", color = labelColor}, {content = "20次", color = COLOR[2]}, {content = "能量", color = labelColor}},
	{{content = "2.每日可重置", color = labelColor}, {content = "15次", color = COLOR[2]}, {content = "军工科技副本", color = labelColor}},
	{{content = "3.每日可重置", color = labelColor}, {content = "15次", color = COLOR[2]}, {content = "限时副本", color = labelColor}},
	{{content = "4.每日可重置", color = labelColor}, {content = "15次", color = COLOR[2]}, {content = "能晶、勋章、战术副本", color = labelColor}},
	{{content = "5.增加", color = labelColor},{content = "50%", color = COLOR[2]},{content = "战斗经验", color = labelColor}},
	{{content = "6.战胜敌军多扣除敌军", color = labelColor}, {content = "950点繁荣度", color = COLOR[2]}},
	{{content = "7.同时享受VIP14所有特权", color = labelColor}},
	{{content = "8.累计充值", color = labelColor}, {content = "3000000金币", color = COLOR[2]}, {content = "可达到", color = labelColor}}},
}

DetailText.activity = {
	{{{content = "装备探险可以获得装备升级材料"}}, {{content = "每天攻打装备关卡的次数额外增加"}, {content = "5次", color = COLOR[4]}}, {{content = "助你更高效率获取装备材料卡、升级装备、提升战力!"}}},
	{{{content = "配件探险可以获得配件和配件改装材料"}}, {{content = "每天攻打配件关卡的次数额外增加"}, {content = "5次", color = COLOR[4]}}, {{content = "助你更高效率获取配件材料。提升战力!"}}},
	{{{content = "军团捐献金币可获得贡献度"}}, {{content = "活动期间进行大厅或者科技捐献，可减少60%金币消耗"}}, {{content = "优惠多多，赶紧来参加吧！"}}},
	{{{content = "活动期间，福利大放送!"}}, {{content = "统率升级成功率增加"}, {content = "10%基础值", color = COLOR[4]}}, {{content = "若成功率为50%"}}, {{content = "活动期间成功率=50%*(1+10%)=55%"}}, {{content = "攻打关卡和世界资源点增加"}, {content = "20%基础经验", color = COLOR[4]}}, {{content = "攻打世界资源点"}, {content = "道具掉率增加30%", color = COLOR[4]}}},
	{{{content = "活动期间，金币水晶送不停!"}}, {{content = "每一笔充值返利"}, {content = "%s%%金币", color = COLOR[4]}}, {{content = "充值赠送的金币不包含在返利范围内"}}, {{content = "每一笔充值赠送"}, {content = "充值金币*%s的水晶", color = COLOR[4]}}},
	{{{content = "活动期间使用水晶或金币招募.从第11次起均可享受折扣优惠"}}, {{content = "金币招募"}}, {{content = "单次招募将领："}, {content = "享8折优惠", color=COLOR[4]}}, {{content = "五次招募将领："}, {content = "享7折优惠", color=COLOR[4]}}, {{content = "水晶招募"}}, {{content="单次招募将领："}, {content="享6折优惠", color=COLOR[4]}}, {{content="五次招募将领："}, {content="享5折优惠", color=COLOR[4]}}},
	{{{content = "活动期间抽装备大优惠"}}, {{content = "顶级单次抽装备: "}, {content = "8折优惠，仅需240金币", color = COLOR[4]}}, {{content = "顶级九次抽装备: "}, {content = "7折优惠，仅需1890金币", color = COLOR[4]}}},

	{{{content = "战胜征战关卡后，有几率获取军需箱"}}, {{content = "开启军需箱可以获得丰厚奖励"}}, {{content = "生产军需箱:使用后获得生产类道具，有几率获得全面开采[12H]", size=18, color=COLOR[3]}},
	{{content="资源军需箱:使用后获得资源类道具", size=18, color=COLOR[3]}}, {{content="升级军需箱:使用后获得技能书或统率书", size=18, color=COLOR[3]}}, {{content="战斗军需箱:使用后获得战斗增益类道具", size=18, color=COLOR[3]}},
	{{content="装备军需箱:使用后获得装备类道具。有几率获得紫色装备",size=18,color=COLOR[4]}}, {{content="配件军需箱:使用后获得配件类道具。有几率获得紫色碎片"}}},

	{{{content = "活动期间，装备探险更轻松"}}, {{content = "购买装备关卡次数:"}, {content = "价格减半", color = COLOR[4]}}, {{content = "攻打装备关卡伤害加成:"}, {content = "30%", color = COLOR[4]}}},
	{{{content = "活动期间"}}, {{content = "1.资源类科技研发速度提升"}, {content = "100%", color = COLOR[4]}, {content = "（相当于20级科技馆效果）"}}, {{content = "2.资源类科技研发只需"}, {content = "50%资源", color = COLOR[4]}},{{content = " "}},{{content = "受益的科技有："}},{{content = "1.铁矿精炼"}},{{content = "2.石油精炼"}},{{content = "3.铜矿精炼"}},{{content = "4.钛矿精炼"}},{{content = "5.水晶抛光"}}},
	{{{content = "活动期间，配件探险更轻松"}}, {{content = "购买配件关卡次数:"}, {content = "价格减半", color = COLOR[4]}}, {{content = "攻打配件关卡伤害加成:"}, {content = "30%", color = COLOR[4]}}},

	{{{content = "战胜征战关卡后，有几率获取军需箱"}}, {{content = "开启军需箱可以获得丰厚奖励"}}, {{content = "常规军需箱:打开必定获得增益道具,技能书,统率书或矿点侦查", size=18, color=COLOR[3]}},
	{{content="配件军需箱:打开必定获得配件改造道具", size=18, color=COLOR[3]}}, {{content="将领军需箱:打开必定获得将领进阶和升级道具", size=18, color=COLOR[3]}}},

	{{{content = "活动期间，勋章探险更轻松"}}, {{content = "购买勋章关卡次数:"}, {content = "价格减半", color = COLOR[4]}}, {{content = "攻打勋章关卡伤害加成:"}, {content = "30%", color = COLOR[4]}}},
	{{{content = "勋章探险可以获得勋章和勋章碎片"}}, {{content = "每天攻打勋章关卡的次数额外增加"}, {content = "5次", color = COLOR[4]}}, {{content = "助你更高效率获取高级勋章，提升战力！"}}},
	{{{content = "活动期间任意额度首笔充值返利"}, {content = "120%", color = COLOR[2]}}, {{content = "后续每笔充值返利"}, {content = "80%", color = COLOR[2]}}},
	{{{content = "活动期间任意额度首笔充值返利"}, {content = "%d%%", color = COLOR[2], format="i"}}, {{content = "后续每笔充值返利"}, {content = "%d%%-%d%%", color = COLOR[2], format="ii"}}},
	{{{content = "活动期间，点击基地界面的飞艇领取丰厚奖励，累积登录六日更有登录大奖等你拿！"}}},
	{{{content = "极限探险可以获得配件改造和勋章打磨材料"}}, {{content = "每天极限探险重置次数额外增加"}, {content = "1次", color = COLOR[4]}}, {{content = "助你更高效率获取材料、提升战力!"}}},
	--19
	{{{content = "活动期间，战术探险更轻松"}}, {{content = "购买战术关卡次数:"}, {content = "价格减半", color = COLOR[4]}}, {{content = "攻打战术关卡伤害加成:"}, {content = "30%", color = COLOR[4]}}},
	{{{content = "战术探险可以获得战术和战术碎片"}}, {{content = "每天攻打战术关卡的次数额外增加"}, {content = "5次", color = COLOR[4]}}, {{content = "助你更高效率获取高级战术，提升战力！"}}},
	{{{content = "征服广阔领土，获取赫赫军功。"}}, {{content = "活动期间，每日获得军功上限"}, {content = "翻倍", color = COLOR[2]}, {content = "。"}}},
}

DetailText.heroImprove = {
	{{content="将领进阶说明"}},
	{{content="1.6个将领可进阶为1个高一阶的将领"}},
	{{content="2.将领进阶需消耗进阶石，将领阶级越高，需要的进阶石越多"}},
	{{content="3.进阶石获取途径：军团商店兑换，商城购买"}}
}

DetailText.activityBee = {
	{{content="活动介绍"}},
	{{content=" "}},
	{{content="采集每种资源达到要求可领取坦克"}},
	{{content="(1)采集5M资源：重型坦克=20"}},
	{{content="(2)采集20M资源：重型火箭=20"}},
	{{content="(3)采集60M资源：巨象-改=20"}},
	{{content="(4)采集120M资源：风琴火箭=20"}},
	{{content=" "}},
	{{content="活动结束时排行前30者可领取超值奖励"}},
	{{content="(1)第1名：沙漠虎=20"}},
	{{content="(2)第2名：帕拉丁III=20"}},
	{{content="(3)第3名：黑豹坦克=20"}},
	{{content="(4)第4-5名：风琴火箭=20"}},
	{{content="(5)第6-10名：灰熊火炮=20"}},
	{{content="(6)第11-30名：巨象-改=20"}},
}

DetailText.activityBeeNew = {
	{{content="活动介绍"}},
	{{content=" "}},
	{{content="采集每种资源达到要求可领取坦克"}},
	{{content="(1)采集25M资源：巨象-改=20"}},
	{{content="(2)采集80M资源：黑豹坦克=20"}},
	{{content="(3)采集160M资源：密集阵=20"}},
	{{content="(4)采集320M资源：天启坦克=20"}},
	{{content=" "}},
	{{content="活动结束时排行前30者可领取超值奖励"}},
	{{content="(1)第1名：卡尔600火炮=20"}},
	{{content="(2)第2名：M133装甲车=20"}},
	{{content="(3)第3名：掠夺者坦克=20"}},
	{{content="(4)第4-5名：钢雨战神=20"}},
	{{content="(5)第6-10名：密集阵=20"}},
	{{content="(6)第11-30名：黑豹坦克=20"}},
}

DetailText.activityFortune = {
	{{content="幸运转盘玩法说明"}},
	{{content=" "}},
	{{content="通过玩法可探索获取以下奖励"}},
	{{content="1.蓝色配件碎片"}},
	{{content="2.紫色配件碎片"}},
	{{content="3.万能碎片和改造配件材料"}},
	{{content="每个玩家每天有1次免费探索机会"}},
	{{content=" "}},
	{{content="每次探索可获得10点积分"}},
	{{content="十次探索可获得120点，特享9折优惠"}},
	{{content="活动结算时积分排行前10名玩家可获得丰厚的配件材料奖励"}},
	{{content="积分超过500（且指挥官等级达到10级）才能进榜"}}
}

DetailText.activityFortunePart = {
	{{content="配件转盘活动介绍"}},
	{{content=" "}},
	{{content="消耗金币转动转盘获取配件改造的道具"}},
	{{content="非VIP玩家每天有1次免费机会，VIP玩家有2次机会"}},
	{{content="转到不同奖励时，可获得不同的积分"}},
	{{content="积分达到250点后可进入积分排行"}},
	{{content=" "}},
	{{content="活动结束时，排行前10名玩家可获得丰厚排行奖励"}}
}

DetailText.activityEnergyspar = {
	{{content="能晶转盘活动介绍"}},
	{{content=" "}},
	{{content="1.活动期间可消费金币进行转盘，转盘获取能晶箱子奖励"}},
	{{content="2.转盘获得能晶箱子时可同时获得活动积分"}},
	{{content="3.获得的物品越好，获得的积分越高"}},
	{{content="4.积分达到600点可上榜，活动结束时结算排行，前10名玩家可领取排行奖励"}},
	{{content=" "}},
	{{content="每天免费1次，单次转盘75金币，十次转盘688金币"}},
}

DetailText.activityTactic = {
	{{content="战术转盘活动介绍"}},
	{{content=" "}},
	{{content="1.活动期间可消费金币进行转盘，转盘获取战术箱子和材料奖励"}},
	{{content="2.转盘获得战术箱子和材料时可同时获得活动积分"}},
	{{content="3.获得的物品越好，获得的积分越高"}},
	{{content="4.积分达到600点可上榜，活动结束时结算排行，前10名玩家可领取排行奖励"}},
	{{content=" "}},
	{{content="每天免费1次，单次转盘65金币，十次转盘588金币"}},
}

DetailText.activityEquipdial = {
	{{content="装备升星转盘活动介绍"}},
	{{content=" "}},
	{{content="1.活动期间可消费金币进行转盘，可获取装备升星材料"}},
	{{content="2.转盘同时获得活动积分，单次转盘10积分，十次转盘100积分"}},
	{{content="3.积分达到600点可上榜，活动结束时结算排行，前10名玩家可领取排行奖励"}},
	{{content=" "}},
	{{content="每天免费1次，单次转盘88金币，十次转盘798金币"}},
}

DetailText.activityProfoto = {
	{{content="哈洛克宝藏活动介绍"}},
	{{content=" "}},
	{{content="1.活动期间，战胜资源点有概率获得[宝图碎片]和[哈洛克信物]"}},
	{{content="2.集齐[宝图碎片]可拼合获得[哈洛克宝图]"}},
	{{content="3.开启[哈洛克宝图]需消耗[哈洛克信物]"}},
	{{content="4.开启后随机获得资源、道具、配件等奖励"}},
	{{content="5.战胜等级越高的资源据点，获得碎片的概率越大!"}}
}

DetailText.partyBattleSign = {
	{{content="报名时间：19:30--19:55"}},
	{{content="混战开始：20:00"}},
	{{content="报名资格：入团24小时以上"}},
	{{content="混战条件：报名军团满10个"}},
	{{content=" "}},
	{{content="其他规则："}},
	{{content="在报名截止前可取消报名"}},
	{{content="取消报名后可重新设置阵型报名"}},
	{{content="战斗死亡坦克无需修理"}},
	{{content="死亡坦克会永久损失1%"}},
	{{content="为确保顺利参战，以及取得好的成绩，建议用最大战力参战"}}
}

DetailText.partyBattle = {
	{{content="对战规则："}},
	{{content="攻击方和防守方随机配对战斗"}},
	{{content="先手值高的先手，先手值一致，攻击方先手"}},
	{{content="战斗后胜利则剩余部队进入下次战斗"}},
	{{content="战斗后失败则淘汰"}},
	{{content="军团所有参战玩家失败后，军团淘汰"}},
	{{content="军团淘汰时，结算出淘汰军团排名"}},
	{{content=" "}},
	{{content="排名规则："}},
	{{content="根据连胜场次，结算玩家连胜排行榜"}},
	{{content="根据军团淘汰时间先后，结算军团混战军团排行"}},
	{{content="百团混战排名前10的军团会获得百团战混战积分，每周清空。"}},
	{{content=" "}},
	{{content="奖励规则："}},
	{{content="连胜越高，个人奖励越丰厚"}},
	{{content="战斗消耗坦克越多，个人奖励越丰厚"}},
	{{content="个人奖励在淘汰或军团战结束后自动发放"}},
	{{content="个人奖励发放后会收到邮件通知"}},
	{{content="军团奖励，军团排行越高奖励越丰厚"}},
	{{content="军团奖励自动发放到福利院-战事福利中"}},
	{{content="军团长可自由分配军团奖励"}}
}

DetailText.activityDestroy = {
	{{content="活动说明："}},
	{{content=" "}},
	{{content="(1)每日歼灭指定数量的坦克，可领取坦克奖励"}},
	{{content="(2)累计歼灭指定数量的任意坦克，可领取高阶坦克奖励"}},
	{{content="仅计算世界歼灭玩家和资源点的坦克数量"}},
	{{content=" "}},
	{{content="歼灭玩家坦克可获得积分，积分达到5万可参与排名奖励"}},
	{{content="(1)歼灭1阶兵种可获得1分（轻型坦克0分）"}},
	{{content="(2)歼灭2阶兵种可获得2~5分"}},
	{{content="(3)歼灭3阶兵种可获得10~18分"}},
	{{content="(4)歼灭4阶兵种可获得40~50分"}},
	{{content="(5)歼灭5阶兵种可获得80~90分"}},
	{{content="(6)歼灭6阶兵种可获得92~100分"}},
	{{content="(7)歼灭7阶兵种可获得215~239分"}},
	{{content="(8)歼灭活动抽取兵种可获得120~283分"}}
}

DetailText.activityTech = {
	{{content="活动说明"}},
	{{content=" "}},
	{{content="(1)活动期间，使用指定数量的道具可兑换获得高级增益道具"}},
	{{content="(2)活动期间，使用指定数量道具可随机兑换获得高时效或高功效道具"}}
}

DetailText.boss = {
	{{content="玩法开启："}},
	{{content="指挥官等级达到30级"}},
	{{content="每周星期五晚20:50-21:30"}},
	{{content="玩法说明："}},
	{{content="1.参与战斗不损耗部队"}},
	{{content="2.VIP6可自动参加战斗（请预先设置阵型）"}},
	{{content="3.设置保存阵型时，请保持基地坦克足够"}},
	{{content="4.使用增益道具或购买祝福后，需重新保存阵型生效"}},
	{{content="5.请在规定的时间内击杀BOSS，以获取丰富奖励"}},
	{{content="玩法奖励："}},
	{{content="1.参与奖励：每次战斗后随机获得资源奖励，伤害越高奖励越多"}},
	{{content="击杀奖励：击毁BOSS1-5格血条，击杀者可获得将神魂碎片*1，二星将领箱子*5"}},
	{{content="斩杀BOSS，击杀者可获得将神魂碎片*25，三星将领箱*2"}},
	{{content="奖励战斗后自动发放"}},
	{{content="排名奖励：BOSS被击杀后，可领取伤害排名奖励"}}
}

DetailText.advance = {
	{{content="1.改造等级≥4级的紫色配件可以进阶为橙色配件"}},
	{{content="2.进阶需要消耗一定数量的万能碎片和对应兵种的驱动"}},
	{{content="3.进阶之后的紫色配件将被消耗，强化等级以及改造等级均不保留，但会返还部分水晶和全部改造材料"}},
}

DetailText.cuilian = {
	{{content="1.蓝色及以上配件可进行淬炼"}},
	{{content=" "}},
	{{content="2.配件的淬炼规则"}},
	{{content="  (1)初始时配件的淬炼属性均为封锁状态，无法进行淬炼"}},
	{{content="  (2)当配件强化等级和改造等级提升后，逐步解锁淬炼属性"}},
	{{content="  (3)属性解锁后为永久解锁"}},
	{{content="  (4)淬炼消耗"}},
	{{content="    (4.1)每次淬炼消耗固定数值的资源"}},
	{{content="    (4.2)淬炼有普通（消耗钛），专家和大师（消耗金币）3种消耗方式"}},
	{{content="  (5)淬炼等级"}},
	{{content="    (5.1)淬炼会增加配件淬炼经验，经验提升淬炼等级"}},
	{{content="  (6)淬炼数值大小与配件的淬炼等级,品质,部位和淬炼方式相关"}},
	{{content=" "}},
	{{content="3.淬炼属性达到指定数值，可以激活淬炼激活属性"}},
	{{content=" "}},
	{{content="4.自动淬炼"}},
	{{content="  (1)在资源充足的情况下，自动淬炼方便快速提高淬炼等级"}},
	{{content="  (2)自动淬炼根据勾选条件自动舍弃或者保存淬炼结果"}},
	{{content=" "}},
	{{content="5.其他细节"}},
	{{content="  1)分解配件，不返还淬炼消耗的资源。"}},
	{{content="  2)进阶配件，保留进阶前的淬炼属性和经验。"}},
	{{content="  3)若需要持续多次手动淬炼，可在游戏设置里关闭二次消费提示，之后记得开启哦。"}},

}

DetailText.altarbuild = {
	{{content="祭坛说明"}},
	{{content="祭坛可召唤军团BOSS，前往击杀后可获得丰厚奖励"}},
	{{content=" "}},
	{{content="召唤需求"}},
	{{content="（1）军团长和副军团长才能召唤BOSS"}},
	{{content="（2）召唤需要消耗一定军团建设度"}},
	{{content="（3）召唤有冷却时间"}},
	{{content=" "}},
	{{content="祭坛升级"}},
	{{content="（1）军团长可以升级祭坛"}},
	{{content="（2）升级需消耗一定建设度"}},
	{{content="（3）祭坛等级不能超过（军团等级/5)，上限为6级"}},
	{{content=" "}},
	{{content="升级效果"}},
	{{content="（1）延长BOSS的击杀限时"}},
	{{content="（2）缩短BOSS的召唤冷却时间"}},
	{{content=" "}},
	{{content="星级奖励"}},
	{{content="（1）祭坛等级达到5级时解锁星级玩法，玩家可以捐献资源提升BOSS星级"}},
	{{content="（2）击败高星级的BOSS后，所有参与者可以随机获得两个额外掉落的星级奖励，BOSS逃跑则无星级奖励。"}},
	{{content="（3）BOSS星级和等级越高，星级奖励价值越高。奖励库可通过星级奖励查看"}},
	{{content="（4）星级奖励将同参与奖励一起经由邮件发放"}}
}

DetailText.king = {
	{{content="1.活动分为四个阶段，前三个阶段每个阶段拥有不同的目标，击杀叛军阶段目标为击杀叛军，采集资源阶段目标为采集资源，获取军功阶段目标为获取军功。完成阶段对应的目标可以领取奖励并获得积分。每个阶段结束后，根据目标完成情况对阶段进行排名，并领取排名奖励。"}},
	{{content=" "}},
	{{content="2.最后一个阶段为总榜排名阶段，根据积分进行累加排名，并领取排名奖励。排名分个人榜和军团榜，个人榜为个人积分排名，军团榜为军团成员积分累加排名。"}},
	{{content=" "}},
	{{content="3.积分兑换规则：每击杀1个叛军头目可获得400积分；每击杀1个叛军卫队可获得200积分；每击杀1个叛军分队可获得100积分；每采集2.5万资源可获得1积分；每获取125军功可获得1积分。"}},
	{{content=" "}},
	{{content="4. 军功获取阶段，每日获得军功上限翻倍"}},
}

DetailText.altarboss = {
	{{content= "BOSS说明"}},
	{{content= "BOSS被召唤后.入团满7天的军团成员均可前往攻打"}},
	{{content= " "}},
	{{content= "BOSS状态"}},
	{{content= "（1）未召唤：无法攻打BOSS"}},
	{{content= "（2）准备期：BOSS被召唤后有5分钟准备期.可设置阵型"}},
	{{content= "（3）击杀期：可攻打BOSS和更改阵型"}},
	{{content= "（4）已击杀：在规定时间成功击杀BOSS"}},
	{{content= "（5）已逃跑：在规定时间未能击杀BOSS"}},
	{{content= " "}},
	{{content= "BOSS等级"}},
	{{content= "BOSS被击杀后等级会加1.若逃跑则等级减1"}},
	{{content= " "}},
	{{content= "奖励说明"}},
	{{content= "（1）参与奖励：所有参与击杀BOSS的军团成员均可获得，若BOSS逃跑则奖励减半，奖励通过邮件发放"}},
	{{content= "（2）击杀奖励：对B0SS完成最后一击的玩家可额外获得击杀奖励"}},
	{{content= "（3）排名奖励：BOSS伤害前三的玩家将收到排行奖励，奖励通过邮件发放"}}
}

DetailText.activityGeneral = {
	{{content="名将招募活动有几率获得神秘将领“安兴”"}},
	{{content=" "}},
	{{content="(1)仅提供金币招募功能"}},
	{{content="(2)招募会积累幸运值,幸运值越高几率越大"}},
	{{content="(3)当幸运值满,下次招募必定获得安兴"}},
	{{content="(4)招募可获得积分:1次招募获得3分,5次招募获得20分"}},
	{{content="(5)积分达到800分时可角逐排行榜"}},
	{{content="(6)活动结束时,排行前10的指挥官可获得丰厚排行奖励"}},
	{{content="(7)招募到安兴时，幸运值会被清零"}},
	{{content=" "}},
	{{content="重要说明:"}},
	{{content="仅通过活动界面招募才有几率获得“安兴”，且才有积分"}}
}

DetailText.activityGeneral1 = {
	{{content="邪将降临活动有几率获得神秘将领“奥古斯特”"}},
	{{content=" "}},
	{{content="(1)仅提供金币招募功能"}},
	{{content="(2)招募会积累幸运值,幸运值越高几率越大"}},
	{{content="(3)当幸运值满,下次招募必定获得奥古斯特"}},
	{{content="(4)招募可获得积分:1次招募获得3分,5次招募获得20分"}},
	{{content="(5)积分达到800分时可角逐排行榜"}},
	{{content="(6)活动结束时,排行前10的指挥官可获得丰厚排行奖励"}},
	{{content="(7)招募到奥古斯特时，幸运值会被清零"}},
	{{content=" "}},
	{{content="重要说明:"}},
	{{content="仅通过活动界面招募才有几率获得“奥古斯特”，且才有积分"}}
}

DetailText.activityConsumeDial = {
	{{content="消费转盘活动介绍"}},
	{{content=" "}},
	{{content="活动期间每消费199金币获得1次转盘"}},
	{{content="转动转盘可以获得对应转盘奖励"}},
	{{content="非VIP玩家每天有1次免费机会，VIP玩家有2次"}},
	{{content=" "}},
	{{content="转到不同奖励时可获得不同的积分"}},
	{{content="积分达到30后可进入积分排行"}},
	{{content="活动结算时积分排行前10名玩家可获得丰厚的排行奖励"}}
}

DetailText.staff = {
{{content="世界编制说明"}},
{{content=" "}},
{{content="1.经验获得说明"}},
{{content="（1）占领世界或军事矿区的资源点，每30分钟可获得一次编制经验.矿点等级越高,获得经验越多"}},
{{content="（2）在世界或军事矿区主动攻击其他玩家并且击毁对方坦克,可获得编制经验.同时扣除对方同等量经验"}},
{{content="（3）繁荣等级＞8级时,会获得编制经验加成,助您更快提升编制等级"}},
{{content=" "}},
{{content="2.编制称号说明"}},
{{content="（1）编制等级提升到指定等级.可获得编制称号"}},
{{content="（2）编制称号能够为坦克增加属性,提升战力"}},
{{content="（3）部分高级称号有人数限制.编制经验高者可获得"}},
{{content=" "}},
{{content="3.编制满级说明"}},
{{content="（1）达到999级时为满级编制"}},
{{content="（2）满级后,每天0点扣除10%当前经验值"}},
{{content=" "}},
{{content="4.世界等级说明"}},
{{content="（1）每天0点结算全服前100编制等级"}},
{{content="（2）折算出当天的世界等级"}},
{{content="（3）世界等级越高，世界地图损兵比例越低"}},
{{content="（4）世界等级达到5级后，世界等级越高，战车/改装工厂单次生产上限越高"}},
}

DetailText.exercise = {
{{content="演习说明:"}},
{{content="1.世界等级达到1级后开放军事演习"}},
{{content="2.指挥官编制称号达到排长后可报名参加"}},
{{content="3.参与可获得大量阵营功勋。可在功勋商店兑换丰厚奖励"}}
}

DetailText.militaryArea = {
{{content="玩法开放："}},
{{content="每周六、周日全天开放"}},
{{content="指挥官等级达到60级"}},
{{content=" "}},
{{content="玩法说明："}},
{{content="玩家可占领资源点，并自动获得限时的保护罩"}},
{{content="保护罩期间内，其他玩家无法掠夺和侦查"}},
{{content="占领采集可获得大量资源"}},
{{content="玩家可掠夺据点，掠夺后自动返回部队"}},
{{content="军事矿区中战斗自动修理被击毁坦克"}},
{{content="被击毁坦克永久损失10%"}},
{{content="占领和掠夺会消耗能量"}},
{{content="每日掠夺有次数上限，玩家可购买次数"}},
{{content="跨服军矿和军事矿区的掠夺次数通用"}},
{{content=" "}},
{{content="积分说明："}},
{{content="在地图中采集资源可获得积分"}},
{{content="掠夺玩家资源也会获得积分"}},
{{content="军团所得积分为军团成员个人积分总和"}},
{{content="积分可用于排行领取奖励"}},
{{content=" "}},
{{content="排行奖励："}},
{{content="活动结束后，结算个人排行和军团排行"}},
{{content="排行榜有最低积分要求"}},
{{content="可领奖玩家需手动领取奖励"}},
{{content=" "}},
{{content="注意：防守部队难度较高，请侦查评估后再进攻"}}
}

DetailText.crossmilitaryArea = {
{{content="玩法开放："}},
{{content="每周六、周日全天开放"}},
{{content="指挥官等级达到70级"}},
{{content=" "}},
{{content="玩法说明："}},
{{content="玩家可占领资源点，并自动获得限时的保护罩"}},
{{content="保护罩期间内，其他玩家无法掠夺和侦查"}},
{{content="占领采集可获得大量资源"}},
{{content="玩家可掠夺据点，掠夺后自动返回部队"}},
{{content="军事矿区中战斗自动修理被击毁坦克"}},
{{content="被击毁坦克永久损失10%"}},
{{content="占领和掠夺会消耗能量"}},
{{content="每日掠夺有次数上限，玩家可购买次数"}},
{{content="跨服军矿和军事矿区的掠夺次数通用"}},
{{content=" "}},
{{content="积分说明："}},
{{content="在地图中采集资源可获得积分"}},
{{content="掠夺玩家资源也会获得积分"}},
{{content="全服所得积分为全服的个人积分总和"}},
{{content="积分可用于排行领取奖励"}},
{{content=" "}},
{{content="排行奖励："}},
{{content="活动结束后，结算个人排行和全服排行"}},
{{content="排行榜和领取全服排行奖励有最低积分要求"}},
{{content="可领奖玩家需手动领取奖励"}},
{{content=" "}},
{{content="注意：防守部队难度较高，请侦查评估后再进攻"}},
{{content="军团科技，荣耀生存和作战实验室不会影响跨服军矿的载重"}}
}

DetailText.activityVacation = {
	{{content="活动说明"}},
	{{content=" "}},
	{{content="资格时间内累计充值指定金币可进行度假"}},
	{{content="度假需花费一定数额的金币"}},
	{{content="度假后当天起登录可获得度假奖励"}},
	{{content=" "}},
	{{content="度假奖励："}},
	{{content="(1)度假花费的金币100%返还"}},
	{{content="(2)额外获得金币和超值道具奖励"}},
	{{content=" "}},
	{{content="特殊说明："}},
	{{content="(1)购买后请保持每天登录游戏哦，活动结束后将无法领取奖励。"}},
	{{content="(2)购买后，基地皮肤会发生改变，并替换之前的皮肤外观及效果。"}},
	{{content="每次活动，仅限体验一种度假（3选1）",color = cc.c3b(184, 50, 50)}},
}

DetailText.activityPartResolve = {
	{{content="活动期间分解配件、碎片可获得配件芯片"}},
	{{content=" "}},
	{{content="(1)分解配件品质越高，获得芯片越多"}},
	{{content="(2)不同部位分解获得的芯片数量不同"}},
	{{content=" "}},
	{{content="在活动商店可使用芯片兑换改造道具"}},
}

DetailText.activityMedalResolve = {
	{{content="活动期间分解勋章、碎片可获得勋章芯片"}},
	{{content=" "}},
	{{content="(1)分解勋章、碎片品质越高，获得芯片越多"}},
	{{content="(2)紫色勋章的不同部位分解获得的芯片数量不同"}},
	{{content="(3)橙色勋章分解不获得勋章芯片"}},
	{{content="(4)勋章芯片活动结束后清零"}},
	{{content=" "}},
	{{content="在活动商店可使用芯片兑换勋章打磨材料"}},
}

DetailText.activityEquipCash = {
	{{content="(1)攻打关卡有几率掉落装备秘物"}},
	{{content="(2)收集配方材料，可兑换获取奖励"}},
	{{content="(3)对配方不满意，可刷新配方"}},
	{{content="(4)只有1级装备才能作为配方材料"}},
}

DetailText.activityPartCash = {
	{{content="(1)攻打关卡有几率掉落碎片秘物"}},
	{{content="(2)收集配方材料，可兑换获取奖励"}},
	{{content="(3)对配方不满意，可刷新配方"}},
}

DetailText.activityGamble = {
	{{content="活动介绍："}},
	{{content="(1)累充100金币获得1次下注机会"}},
	{{content="(2)累充300金币获得1次下注机会"}},
	{{content="(3)累充500金币获得1次下注机会"}},
	{{content="(4)累充1000金币获得1次下注机会"}},
	{{content="(5)累充2000金币获得1次下注机会"}},
	{{content="(6)累充5000金币获得1次下注机会"}},
	{{content="(7)累充10000金币获得1次下注机会(最多下注7次！)"}},
	{{content="充值越多，可下注次数越多，赢取金币也越多！"}},
}

DetailText.activityPayTurntable = {
	{{content="活动介绍："}},
	{{content="充值每满%d金币可获得1次抽奖次数"}},
	{{content="充值越多，抽奖次数越多！"}},
}

DetailText.activityRecharge = {
	{{content="活动介绍："}},
	{{content="（1）点击开始，转动转盘两次，分别决定返利系数和充值目标"}},
	{{content="（2）返利金币=充值目标*返利系数"}},
	{{content="（3）完成充值目标可额外获得返利金币，邮件中可以领取"}},
	{{content=""}},
	{{content="其他说明："}},
	{{content="（1）每次转动转盘需要消耗1次转盘次数"}},
	{{content="（2）两次转盘结束前，无法进行其他操作"}},
	{{content="（3）如果对返利结果不满意，可以点击开始按钮放弃本次返利重新转盘"}},
	{{content="（4）返利系数、充值目标和剩余次数会每天重置，充值不达标可不要骂可怜的客服MM哦"}},
}


-- DetailText.activityPayTurntable = {
-- 	{{content="活动介绍："}},
-- 	{{content="充值每满500金币可获得1次抽奖次数"}},
-- 	{{content="充值越多，抽奖次数越多！"}},
-- }

DetailText.activityCelebrate = {
	{{content="狂欢说明"}},
	{{content=" "}},
	{{content="(1)活动期间累计充值任意4天可领取专属挂件"}},
	{{content=" "}},
	{{content="(2)每日首充任意金额可领取丰厚奖励，"},{content = "每日0点重置奖励",color = COLOR[6]}},
	{{content=" "}},
	{{content="(3)每日充值满2000金币，可领取1次奖励，若累计充值4000金币就有2次领取机会，"},{content = "活动期间不重置",color = COLOR[6]}},
}

DetailText.activityCelebrate1 = {
	{{content="劳动说明"}},
	{{content=" "}},
	{{content="(1)活动期间攻打征战关卡，世界资源点或玩家基地胜利后，有概率获得劳动卡"}},
	{{content=" "}},
	{{content="(2)在活动界面可选择劳动卡进行劳动，劳动结束可获得丰厚奖励"}},
	{{content="a.劳动卡[绿]：可获得统率书、资源、增益、加速等道具"}},
	{{content="b.劳动卡[蓝]：可获得装备卡、将领升级材料、配件改造材料、勋章升级材料等道具"}},
	{{content="c.劳动卡[紫]：可获得装备进阶、将领升级觉醒、配件高级改造、勋章改造等材料,万能碎片"}},
	{{content="d.劳动卡[橙]：可获得军功章、装备核心、万能碎片、驱动箱、秘药、钛合金等道具"}},
	{{content=" "}},
	{{content="(3)劳动过程中可使用金币消除时间，立即获得相应奖励"}},
}

DetailText.activityCelebrate2 = {
	{{content="活动说明"}},
	{{content=" "}},
	{{content="(1)活动期间累计充值任意4天可领取专属挂件"}},
	{{content=" "}},
	{{content="(2)每日首充任意金额可领取丰厚奖励，"},{content = "每日0点重置奖励",color = COLOR[6]}},
	{{content=" "}},
	{{content="(3)每日充值满2000金币，可领取1次奖励，若累计充值4000金币就有2次领取机会，"},{content = "活动期间不重置",color = COLOR[6]}},
}

DetailText.activityCelebrate3 = {
	{{content="活动说明"}},
	{{content=" "}},
	{{content="(1)活动期间攻打征战关卡，世界资源点或玩家基地胜利后，有概率获得祝福宝石"}},
	{{content=" "}},
	{{content="(2)在活动界面可选择祝福宝石进行祝福，祝福结束可获得丰厚奖励"}},
	{{content="a.祝福宝石[绿]：祝福后,有概率获得统率书及白色军备图纸等道具"}},
	{{content="b.祝福宝石[蓝]：祝福后,有概率获得装备卡、将领升级材料、绿色军备图纸及材料等道具"}},
	{{content="c.祝福宝石[紫]：祝福后,有概率获得装备进阶、将领觉醒、万能碎片、蓝色或紫色军备图纸"}},
	{{content="d.祝福宝石[橙]：祝福后,有概率获得装备核心、万能碎片、驱动箱、秘药、紫色军备图纸等道具"}},
	{{content=" "}},
	{{content="(3)祝福过程中可使用金币消除时间，立即获得相应奖励"}},
}


DetailText.activityNewRaffle = {
	{{content="活动介绍"}},
	{{content=" "}},
	{{content="1.消费金币可抽取高阶金币车"}},
	{{content=" "}},
	{{content="2.抽取规则"}},
	{{content="a.随机确定坦克类型"}},
	{{content="b.依据下方图片组合获得指定数量的对应坦克"}},
	{{content="c.组合规则：3图一致=5辆,2图一致=3辆,3图各异=1辆"}},
	{{content="d.锁定坦克后每次抽取均可获得锁定的坦克,但需付出更多的金币"}},
	{{content=" "}},
	{{content="3.消费规则"}},
	{{content="a.每个玩家每天有1次免费抽取机会"}},
	{{content="b.锁定抽取将花费更多的金币"}},
	{{content="c.10次抽取获得10倍坦克,且仅需9折金币"}},
}

DetailText.ordnanceProp = {
	{{content="1.军工科技研发"}},
	{{content="（1）有8条科技线：对应生产型和活动型坦克.战车.火炮和火箭"}},
	{{content="（2）每条科技线均需从低阶兵研发起"}},
	{{content="（3）研发需消耗军工材料和军工药剂"}},
	{{content=" "}},
	{{content="2.军工科技效果"}},
	{{content="（1）属性科技：装配到坦克身上增加坦克属性"}},
	{{content="     a.爆裂：增加暴击伤害的倍数"}},
	{{content="     b.坚韧：减少暴击伤害的倍数"}},
	{{content="（2）效率科技：研发后减少对应坦克生产改造时间"}},
	{{content="（3）改造科技：研发后开放对应坦克新改造功能"}},
	{{content=" "}},
	{{content="3.军工材料获得"}},
	{{content="（1）领取祝福：随机获得催化剂.融化剂或润滑剂"}},
	{{content="（2）军工关卡：可获得军工矿粒.矿石或矿晶"}},
}

DetailText.activityM1A2 = {
	{{content="探索可获得"}},
	{{content="(1)坦克：279核战坦克和启示录II(有几率获得1或5辆)"}},
	{{content=" "}},
	{{content="(2)道具：核战坦克核心(用于改装279核战坦克的必须道具)"}},
	{{content=" "}},
	{{content="(3)高级探索有更高几率获得279核战坦克(获得坦克时保底数量为2辆)"}},
	{{content=" "}},
	{{content="活动改装工厂"}},
	{{content="(1)仅活动期间出现"}},
	{{content="(2)提供将启示录II改装为279核战坦克功能"}},
}

DetailText.fortress = {
	{{content="参赛资格："}},
	{{content="百团混战中，排名前10所有军团成员"}},
	{{content="一周3次军团战积分总分排名第1的军团为防守方，第2-10名为进攻方"}},
	{{content=" "}},
	{{content="对战规则："}},
	{{content="预热时，防守方可先进行选择据点进行设防"}},
	{{content="开战时，攻击方可选择对象进行攻击"}},
	{{content="无玩家防守时，攻击玩家可攻击据点"}},
	{{content="据点守军死亡后，据点耐久度降低"}},
	{{content="当耐久度为0时，据点沦陷不可再进行攻防"}},
	{{content="需要先进攻防守玩家才能攻占据点"}},
	{{content=" "}},
	{{content="胜负规则："}},
	{{content="要塞战永久损兵0.1%"}},
	{{content="攻击胜利，根据攻方积分排名决出胜利军团"}},
	{{content="胜利军团可获得军团独有buff增益"}},
	{{content=" "}},
	{{content="排名规则："}},
	{{content="军团所有玩家积分总和结算军团积分，军团排行根据个人积分和结算。"}},
	{{content="个人积分排名分为军团内排名和全服排名两种"}},
	{{content=" "}},
	{{content="军团奖励："}},
	{{content="军团总积分大于一定值后可获得军团积分排名奖励"}},
	{{content="军团奖励直接发放到福利院"}},
	{{content=" "}},
	{{content="个人奖励："}},
	{{content="发生战斗可获得积分"}},
	{{content="攻占据点可获得大量积分"}},
	{{content="积分会折算为军团贡献度"}},
	{{content="贡献度奖励，争霸结束后自动发放给玩家"}},
}

DetailText.fortressJob = {
	{{content="1、属性加成"}},
	{{content="要塞战第一奖励buff,全军团成员生效"}},
	{{content="5种资源基础产量+50%（持续12小时），可与其他BUFF叠加"}},
	{{content=" "}},
	{{content="2、任命官职"}},
	{{content="要塞战胜利军团的军团长拥有任命权，可以任命军团内的人获得增益类的职位，也可以任命军团外的人获得减益类的职位"}},
	{{content="官职任命权在周日要塞战结束后分配，军团长可以在下次要塞战开战前1天的任何时间任命官职"}},
	{{content="职位不可以对拥有职位的玩家使用"}},
	{{content="任命次数代表在这周时间可以任命的次数，要塞战开战前一天清空,即周六的晚上7点30将任职任命界面清空"}},
}

DetailText.fortressJobAdd = {
	{{content=" "}},
	{{content="3、飞艇指挥官任免"}},
	{{content="军团长和副团长可以任免飞艇指挥官,拥有飞艇指挥权的指挥官可以将指挥权转让给其他可以拥有指挥权的同军团指挥官."}},
}

DetailText.exerciseInfo = {
	{{content="玩法时间："}},
	{{content="每周二00:00开始报名"}},
	{{content="20:30开始备战，分配阵营，可在据点设置阵型"}},
	{{content="20:55开始预热，不可修改部队"}},
	{{content="21:00:00  战车工厂战役开始战斗"}},
	{{content="21:10:00  军事学院战役开始战斗"}},
	{{content="21:20:00  装备工厂战役开始战斗"}},
	{{content="21:30:00  演习结束，发放奖励，遣返将领"}},
	{{content=""}},
	{{content="演习部队："}},
	{{content="可用基地坦克兑换演习坦克"}},
	{{content="兑换比例1:500"}},
	{{content="演习坦克在演习过程中100%损耗"}},
	{{content="剩余的演习坦克将会持续保留"}},
	{{content="演习坦克不能兑换回基地坦克。",color = cc.c3b(184, 50, 50)}},
	{{content=""}},
	{{content="阵营增益："}},
	{{content="分配阵营后，可以购买阵营增益"}},
	{{content="阵营增益对本次演习的所有阵营玩家生效"}},
	{{content="双方阵营进修增益等级对比由红蓝显示条可见"}},
	{{content=""}},
	{{content="玩法胜负"}},
	{{content="每路战斗匹配不同阵营战斗，战斗胜利则进入下一轮匹配"}},
	{{content="该路只剩最后一个阵营后，该阵营占领此路部队"}},
	{{content="3路中占领2路或者以上则演习胜利（必定会将三路战斗打完）"}},
	{{content="若占领路数相等，则阵营功勋高的取得胜利。"}},
	{{content=""}},
	{{content="玩法奖励"}},
	{{content="战斗胜利获得阵营功勋"}},
	{{content="战斗失败获得少量阵营功勋"}},
	{{content="胜利阵营获得BUFF奖励"}},
	{{content="个人胜场排行获得排名奖励"}},
}

DetailText.exerciseShop = {
	{{content="普通兑换:"}},
	{{content="每个商品有兑换次数限制"}},
	{{content="每天22点重置次数"}},
	{{content=" "}},
	{{content="珍品兑换:"}},
	{{content="每天22点刷新商品兑换种类和兑换次数"}},
	{{content="珍品有全服兑换次数限制,先到先得"}},
}

DetailText.rebelDetail = {
	{{content="玩法开启",color = COLOR[2]}},
	{{content="开服第8天开启"}},
	{{content="每天的12:00和18:00开启；持续时间为60分钟"}},
	{{content="叛军说明",color = COLOR[2]}},
	{{content="叛军种类："},{content="分队、卫队、头目",color = COLOR[6]},{content="3类叛军"}},
	{{content="叛军数量：每次刷新一定数量3类叛军"}},
	{{content="叛军等级：由战力前100名玩家的等级来确定"}},
	{{content="叛军坐标：随机出现在世界地图"}},
	{{content="叛军抵达时间：叛军分三批抵达。活动开始时分队抵达,五分钟后卫队抵达,再五分钟后头目抵达。"}},
	{{content="存在时间：最多存在60分钟,否则未被击杀的叛军将逃跑"}},
	{{content="击杀说明", color = COLOR[2]}},
	{{content="行军：需派兵和行军,派兵需要消耗1点能量。若行军抵达时叛军已被击杀则会自动遣返部队,同时补偿能量1点(若能量超过上限100,则邮件补偿)"}},
	{{content="先后手：相同先手值玩家先手。"}},
	{{content="损兵：若死亡坦克,则"},{content="损兵比例为20%",color = COLOR[6]}},
	{{content="奖励说明",color = COLOR[2]}},
	{{content="击杀奖励：击杀敌军,可获得丰厚奖励。"}},
	{{content="（1）叛军等级越高,击杀奖励越丰厚。",color = COLOR[6]}},
	{{content="（2）击杀叛军还可能额外获得叛军对应的将领。击杀卫队可能获得二星、三星将领。"},{content="击杀头目",color=COLOR[6]},{content="可能获得银鹰、金鹰将领"}},
	{{content="（3）击杀头目概率掉落礼盒,领取可获得奖励,概率触发金币红包,可在世界频道拼手气抢。"}},
	{{content="全服奖励",color = COLOR[2]}},
	{{content="击杀奖励：若在击杀期(60分钟内)成功击杀完全部叛军,则全服玩家可获得一个随机buff奖励"}},
	{{content="排行说明",color = COLOR[2]}},
	{{content="排行积分：每击杀一个分队、卫队、头目,个人和军团分别可获得"},{content="5、8、12",color = COLOR[6]},{content="积分"}},
	{{content="结算周期：每周一零点会结算上周的积分排名,并可领取上周个人/军团排名奖励"}},
	{{content="总排行：玩家击杀叛军的历史积分均会在此累计"}},
    {{content="叛军boss",color = COLOR[2]}},
	{{content="头目被击杀完后,世界地图会随机出现1名叛军boss"}},
	{{content="头目越快被击杀完,叛军boss的属性越高"}},
	{{content="击杀叛军boss可获得丰富奖励"}},
	{{content="（1）正常击杀奖励",color = COLOR[6]}},
	{{content="（2）必定触发1个拼手气红包",color=COLOR[6]}},
	{{content="（3）击杀者可获得额外增益：5小时内军功获取上限提高50%",color=COLOR[6]}},
}


DetailText.militaryAct = {
{{content = "军工探险可以获得军工升级材料"}}, 
{{content = "每天攻打军工关卡的次数额外增加"}, {content = "5次", color = COLOR[4]}},
{{content = "助你更高效率获取军工材料、提升战力!"}}
}

DetailText.militaryActSupply= {
{{content = "活动期间，军工探险更轻松"}}, 
{{content = "购买军工关卡次数:"}, {content = "价格减半", color = COLOR[4]}}, 
{{content = "攻打军工关卡伤害加成:"}, {content = "30%", color = COLOR[4]}}
}

DetailText.energyAct = {
{{content = "能晶探险可以获得能晶"}}, 
{{content = "每天攻打能晶关卡的次数额外增加"}, {content = "5次", color = COLOR[4]}}, 
{{content = "助你更高效率获取能晶、提升战力!"}}
}

DetailText.energyActSupply= {
{{content = "活动期间，能晶探险更轻松"}}, 
{{content = "购买能晶关卡次数:"}, {content = "价格减半", color = COLOR[4]}}, 
{{content = "攻打能晶关卡伤害加成:"}, {content = "30%", color = COLOR[4]}}
}

DetailText.crossInfo = {
	{{content = "赛制说明"}}, 
	{{content = "1.争霸分为巅峰组和精英组（赛制相同）"}}, 
	{{content = "2.采用【积分赛】+【淘汰赛】+【总决赛】决出最终冠军"}}, 
	{{content = "3.积分赛分为随机配对，每个选手需打满18场，最终排名前64的玩家进入淘汰赛"}}, 
	{{content = "4.淘汰赛分为4个赛区进行，每个赛区以淘汰方式决出赛区冠军进入总决赛"}}, 
	{{content = "5.总决赛决胜出本次争霸最后冠亚季军"}}, 
	{{content = ""}}, 
	{{content = "淘汰赛与总决赛战斗说明"}}, 
	{{content = "1.每场战斗以3局2胜的方式决胜负"}}, 
	{{content = "2.需设置3支不同部队参赛（配合战术选择做出完美的战前策略）"}}, 
	{{content = "3.战斗过程不损兵"}}, 
	{{content = "4.先后手关系"}}, 
	{{content = "	4.1先手值高的一方先手"}}, 	
	{{content = "	4.2先手值相同.按下面逻辑进行"}}, 	
	{{content = "		a.第1场随机一方先手"}}, 
	{{content = "		b.第2场由第1场后手玩家先手"}}, 
	{{content = "		c.第3场由前2场死亡坦克数量少的玩家先手.若数量相同则随机"}}, 
	{{content = "		"}},
	{{content = "5.若出现平局，则取战力高的一方获胜"}}, 
}

DetailText.crossParty = {
	{{content = "赛制说明"}},
	{{content = "1.军团争霸分为资格赛，小组赛与决赛，三轮均为混战。"}},
	{{content = "2.资格赛是军团争霸开启当天的百团大战，每个参赛服的百团大战前三名将获得参赛资格"}},
	{{content = "3.小组赛分为A、B、C、D四组，每组12军团，取各组前六名进入决赛"}},
	{{content = "4.决赛决出本届军团争霸的最终排名"}},
	{{content = "报名与战斗说明"}},
	{{content = "1.资格赛结束之后即可报名，布阵期可进行布阵"}},
	{{content = "2.每场战斗以混战形式决胜负"}},
	{{content = "3.战斗过程不损兵，部队的设置均以镜像的形式保存"}},
	{{content = "奖励说明"}},
	{{content = "1.小组赛中，战斗胜一场得30分，负一场得10分。决赛中，战斗胜一场得60分，负一场得20分。由战斗获得的积分不超过5000分"}},
	{{content = "2.小组赛与决赛达到相应的连胜场次均会有额外积分获得。7连胜+50分，9连胜+70分，11连胜+90分，13连胜+110分"}},
	{{content = "3.小组赛与决赛终结连胜也会有额外积分获得。终结7连胜+70分，9连胜+90分，11连胜+110分，13连胜+130分"}},
	{{content = "4.排行榜说明："}},
	{{content = "4.1 连胜榜记录决赛的连胜场次，需手动领取。"}},
	{{content = "4.2 个人排行以玩家积分为准，需手动领取。"}},
	{{content = "4.3 军团排行以决赛成绩与军团积分为准，奖励自动送往军团福利院，由军团长进行分配"}},
	{{content = "4.4 全服奖励在军团争霸结束后以邮件发送"}},
}

DetailText.crossShop = {
	{{content = "规则说明"}},
	{{content = "1.在世界争霸商店可以兑换各种道具，珍品只有参赛选手可以兑换"}},
	{{content = "2.商店兑换在世界争霸总决赛结束后开放兑换"}},
	{{content = "3.积分将在活动结束后清零，请指挥官们尽快兑换"}},
	{{content = "4.普通、与珍品商品均为个人限购商品"}},
}

DetailText.crossScore = {
	{{content = "积分详情"}},	
	{{content = "1.记录世界争霸期间，个人的积分变化详情"}},	
	{{content = "2.只保留最近30条积分详情"}},	
}

DetailText.crossPartyShop = {
	{{content = "规则说明"}},
	{{content = "1.在军团争霸商店可兑换各种珍稀道具"}},
	{{content = "2.商店兑换在军团争霸总决赛结束后开放兑换"}},
	{{content = "3.积分将在活动结束后清零，请指挥官们尽快兑换"}},
	{{content = "4.积分商店商品均为个人限购"}},
}

DetailText.crossPartyScore = {
	{{content = "积分详情"}},	
	{{content = "1.记录军团争霸期间，个人积分变化详情"}},	
	{{content = "2.只保留最近30条积分详情"}},	
}

DetailText.crossBet = {
	{{content = "下注说明："}},		
	{{content = "1.淘汰赛环节.全体玩家可向喜欢的选手下注"}},		
	{{content = "2.每轮比赛可同时选择一名精英组选手巅峰组选手下注"}},		
	{{content = "3.下注可获得积分奖励，积分可在世界争霸商店兑换珍惜道具"}},		
	{{content = "4.未领取下注积分将在决赛开启前自动加到积分池中"}},		
}

DetailText.collection = {
	{{content = "活动说明:"}},
	{{content = "(1)活动期间攻打经验关卡，世界资源点，玩家基地，有一定几率获得鲜花道具"}},
	{{content = "(2)集齐相应道具可拼合“春暖花开”"}},
	{{content = "(3)单个道具也可兑换丰厚奖励"}},
}

DetailText.flower = {
	{{content = "活动说明"}},
	{{content = "(1)攻打玩家基地获胜后有几率获得鲜花"}},
	{{content = "(2)攻打的玩家等级比你的等级越高几率越大"}},
	{{content = "(3)鲜花祝福可获得各种珍贵物资"}},
	{{content = "(4)活动结束后鲜花清零"}},
}

DetailText.medal = {
{{content = "勋章属性"}},
{{content = "1、勋章的属性作用于全体部队"}},
{{content = "2、勋章将带来两种全新的属性"}},
{{content = "   震慑：进一步强化部队伤害"}},
{{content = "   刚毅：减弱对手震慑的作用效果"}},
{{content = "勋章升级"}},
{{content = "1、消耗升级材料，可获得升级值，当升级进度满时，勋章升级等级提升，属性提升"}},
{{content = "2、升级过程中，有一定几率触发幸运暴击和幸运升级"}},	
{{content = "   2.1 触发幸运暴击，获得的升级值为平常的2倍"}},
{{content = "   2.2 触发幸运升级，升级等级将会直接提升"}},
{{content = "3、每次升级会增加冷却时间，当冷却时间到达上限后需要等待冷却时间结束，或者清除冷却时间，才能继续升级"}},
{{content = "4、勋章分解时，根据该勋章的升级材料消耗，返还部分材料"}},
{{content = "5、一键升级时，系统自动消耗资源提升勋章等级，当勋章等级提升、冷却时间达最大或者玩家材料不足时自动停止"}},
{{content = "勋章打磨"}},	
{{content = "1、打磨可以大量提升勋章属性，并激活勋章打磨光效，打磨10级后激活特效：升级属性提升15%。"}},
{{content = "2、蓝色品质以上的勋章才可以打磨"}},
{{content = "3、勋章分解时，打磨材料将全额返还"}},
}

DetailText.storehouse = {
{{content = "活动说明"}},
{{content = "1）单次开启后可以选择“全部开启”，直接获得全部奖励"}},
{{content = "2）如果第二次选择“单次开启”，则无法选择“全部开启”"}},
{{content = "3）“单次开启”最多只能打开6个箱子"}},
{{content = "4）至少开启一个箱子后才可以选择重置，进行新1轮开启"}},
{{content = "5）黑市兑换的物品会每日0点重置"}},
{{content = " "}},
{{content = "开启箱子概率获得稀世珍宝，可用于黑市兑换"}},
{{content = "备注：活动结束时会清空稀世珍宝，请及时兑换",color = COLOR[6]}},
{{content = " "}},
{{content = "开启箱子可获得积分，用于活动排行"}},
{{content = "1）单次开启获得5积分"}},
{{content = "2）全部开启获得65积分"}},
{{content = "3）积分大于500分可进入排行，活动结束时结算排行，排行前10名玩家可获得丰厚奖励"}},
}

DetailText.medalInfo = {
	{{content = "勋章属性"}},
	{{content = "1、勋章的属性作用于全体部队（坦克，战车，火炮，火箭均受到属性加成效果）"}},
	{{content = "2、勋章将带来两种全新的属性"}},
	{{content = "   震慑：进一步强化部队伤害"}},
	{{content = "   刚毅：减弱对手震慑的作用效果"}},
	{{content = " "}},
	{{content = "勋章获取"}},
	{{content = "1、攻打勋章关卡掉落"}},
	{{content = "2、参加活动获得"}},
	{{content = " "}},
	{{content = "勋章展示"}},
	{{content = "1、勋章展厅将会展示玩家获得的各类勋章"}},
	{{content = "2、获得勋章后，能对勋章进行展示（展示会消耗此勋章），永久获得该勋章的展示属性"}},
	{{content = "3、当展示的勋章达到一定数量时，也会永久获得额外的收集属性"}},
}

DetailText.newYearBoss = {
	{{content = "金鸡报喜，机甲贺岁！"}},
	{{content = "各种“鸡”甲已经准备就绪，等待各位指挥官召唤。"}},
	{{content = "福袋不停，精彩不断，尽在活动中！"}},
	{{content = "玩法开启："}},
	{{content = "1、活动期间每日11:00-14:00和19:00-22:00可进行贺岁机甲的召唤"}},
	{{content = "2、15级以上玩家可参与活动"}},
	{{content = "玩法说明："}},
	{{content = "1、消耗一定金币可进行贺岁机甲的召唤，开启福袋的抢夺（无需进行战斗）。"}},
	{{content = "2、拥有活动道具的玩家可进行福袋的抢夺，两种活动道具均可攻打征战关卡获得，也可直接用金币进行购买。"}},
	{{content = "   春雷：对贺岁机甲进行惊吓，趁机捞走一个福袋"}},
	{{content = "   灯笼：用火红的灯笼吸引贺岁机甲的注意，顺走一个大福袋"}},
	{{content = "3、福袋抢夺有规定时间，若未能抢完所有福袋，贺岁机甲将逃跑"}},
	{{content = "奖励说明："}},
	{{content = "1、进行召唤的指挥官可获得贺岁礼盒，打开可获得大量奖励（有机会获得万能碎片，军功章，装备核心，大量勋章材料）"}},
	{{content = "2、规定时间内抢夺完所有福袋，参与指挥官均可获得额外奖励"}},
	{{content = "3、抢走贺岁机甲最后一个福袋可获得额外奖励"}},
	{{content = "4、福气排行，活动期间指挥官获取过的福袋数量排名，惊喜不断"}},
	{{content = "5、召唤排行，活动期间指挥官召唤贺岁机甲的次数排名，可获得超级大奖"}},
}

--疯狂搬砖
DetailText.mayDayBoss = {
	{{content = "劳动光荣，疯狂搬砖！"}},
	{{content = "各种IT农民已准备就绪，等待各位指挥官召唤。"}},
	{{content = "利是不停，精彩不断，尽在活动中！"}},
	{{content = "玩法开启："}},
	{{content = "1、活动期间每日11:00-14:00和19:00-22:00可进行疯狂搬砖"}},
	{{content = "2、15级以上玩家可参与活动"}},
	{{content = "玩法说明："}},
	{{content = "1、消耗一定金币可进行召唤，抢夺BOSS发来的利是（无需进行战斗）。"}},
	{{content = "2、拥有活动道具的玩家可进行利是的抢夺，两种活动道具均可攻打征战关卡获得，也可直接用金币进行购买。"}},
	{{content = "   营养液：这种粘稠的白色液体富含丰富的蛋白质，搬砖时必备，可捞取一份小利是"}},
	{{content = "   能量块：横扫饥饿，能让搬砖者停不下来！光是想想就觉得兴奋呢！可拿走一份大利是"}},
	{{content = "3、打赏有规定时间，若在规定时间内未能拿走全部利是，BOSS将收回剩余的所有利是"}},
	{{content = "奖励说明："}},
	{{content = "1、进行召唤的指挥官可获得搬砖盒饭，打开可获得大量奖励（有机会获得万能碎片，军功章，装备核心，大量勋章材料）"}},
	{{content = "2、规定时间内抢夺完所有利是，参与指挥官均可获得额外奖励"}},
	{{content = "3、拿到最后一个利是的指挥官可获得额外奖励"}},
	{{content = "4、勤劳排行，活动期间指挥官获取过的利是数量排名，惊喜不断"}},
	{{content = "5、召唤排行，活动期间指挥官召唤的次数排名，可获得超级大奖"}},
}

DetailText.bountyBoss = {
	{{content = "召集小伙伴，集结你的队伍。挑战庞然大物，获取丰厚奖励！"}},
	{{content = "玩法说明："}},
	{{content = "1、70级以上玩家可参加活动。每天会开启若干可供挑战的BOSS，每日0点刷新哦。"}},
	{{content = "2、每个关卡需要三人组队才可出击，玩家可以选择自行建立队伍或加入已存在的队伍，点击加号可向世界发出加入邀请。"}},
	{{content = "3、出击后，按照预设的出击顺序进行车轮战。每个关卡拥有数波敌人，击败所有敌人后计算挑战成功。"}},
	{{content = "4、每次挑战成功后会获得珈蓝矿石，可用于在神秘商店处兑换珍贵奖励。"}},
	{{content = "5、每个关卡挑战成功后会扣除1次奖励次数，挑战失败则不扣除。不同关卡之间的奖励次数独立计算。"}},
	{{content = "6、奖励次数变为0时仍然可以继续挑战关卡，但矿石收益会降低为50%。挑战副本获得的矿石数量达到或超过500时，不可继续获得。通缉令和其他途径获得的珈蓝矿石可正常获取，不受到最大收益影响。"}},
	{{content = "7、所有关卡的战损为0。"}},
	{{content = "8、觉醒鲷哥的烟雾打击、奥古斯特的不死不灭和觉醒奥古斯特的刚毅不屈技能在此类副本中无效。"}},
}

DetailText.bountyDetail = {
	{{content = "1、通缉令会在指定的时间开启，每次开启有时限，到达时限后通缉令关闭。请指挥官多多关注通缉令上方倒计时哟!"}},
	{{content = "2、完成通缉令上的目标，赢取对应奖励。目标分为个人目标和全服目标，全服目标完成后，所有等级≥70的玩家均可领取奖励。"}},
}

DetailText.payClear = {
	{{content = "1、每充值满%s金币可获得1次转盘机会，最多可获得10次机会"}},
	{{content = "2、转动转盘，即可获得指针停止时指向的奖励"}},
	{{content = "3、每当获得奖励后，下次转盘将不会再次转到该奖励"}},
}

DetailText.worshipGod = {
	{{content = "拜女神说明"}},
	{{content = "1.VIP5或以上的玩家才能获得拜女神的金币返还"}},
	{{content = "2.活动开启时直接获得X次拜女神机会"}},
	{{content = "3.第2-3天，每天首次登陆游戏可获得额外1次机会"}},
}

DetailText.worshipTask = {
	{{content = "许愿说明"}},
	{{content = "1.每天会发布3个任务，任务每天0点将会重置"}},
	{{content = "2.每完成1个任务可获得1次许愿机会"}},
	{{content = "3.许愿有概率获得珍稀物品"}},
	{{content = "4.许愿次数活动期间不重置"}},
}

DetailText.actRebel = {
	{{content = "活动说明"}},
	{{content = "战争时代，流寇横行，常有匪徒恃强凌弱，趁火打劫，欺负平民百姓。现展开剿匪行动，以激励指挥官们消灭流寇匪徒，救民于水火之中！"}},
	{{content = " "}},
	{{content = "活动规则"}},	
	{{content = "活动期间，匪徒主要聚集在玩家基地附近，每10分钟会在活跃玩家基地附近刷新。剿灭匪徒会有各类奖励掉落，并会获得相应的积分。"}},	
	{{content = "剿灭匪徒需要消耗能量，前往剿匪的部队将获得民众支援，获得100%的行军加速，并且被击毁的部队均不会永久损失，指挥官只需消耗资源修理即可！"}},	
	{{content = "消灭不同等级匪徒将获得不同积分，挑战比自身等级高的匪徒能获得更多积分，具体对应关系如下"}},	
	{{content = " "}},	
	{{content = "匪徒等级减去玩家等级称为挑战等级"}},	
	{{content = "挑战等级小于-5（包含），获得2点积分"}},	
	{{content = "挑战等级在-4和-2之间，获得3点积分"}},	
	{{content = "挑战等级在-1和1之间，获得4点积分"}},	
	{{content = "挑战等级在2和4之间，获得5点积分"}},	
	{{content = "挑战等级大于5（包含），获得6点积分"}},	
}

DetailText.mineInfo = {
	{{content = "所有资源点均有5种规模，分别是："},{content = "白色小型规模产量100%，",color = COLOR[1]},{content = "绿色中型规模产量112%，",color = COLOR[2]},{content = "蓝色大型规模产量124%，",color = COLOR[3]},
		{content = "紫色巨型规模产量136%，",color = COLOR[4]},{content = "橙色庞大规模产量148%，",color = COLOR[5]},{content = "不同规模会显示对应规模标识，请注意搜索"}},
	{{content = " "}},	
	{{content = "当开采度达到一定程度，在采集部队离开时将会自动结算提升资源点的规模，小型、中型、大型、巨型规模资源点均可提升规模，到达庞大规模则不可继续提升"}},
	{{content = " "}},	
	{{content = "资源点的规模越大，你的部队就更快能够采满资源"}},
	{{content = " "}},	
	{{content = "只要有部队处于该资源点，开采度就会不断的增加；如果资源点没有部队，则很快就会荒废为小型规模的资源点"}},
}

DetailText.heroAwake = {
	{{content = "觉醒说明",color = COLOR[5],size = 30}},
	{{content = " "}},	
	{{content = "1.指挥官70级开启觉醒。",color = COLOR[3]}},
	{{content = "2.使用秘药或者金币进行觉醒时，有几率点亮一个觉醒技能图标碎片或是一个被动技能。",color = COLOR[3]}},	
	{{content = "3.觉醒失败时，会提升下次觉醒的成功几率。",color = COLOR[3]}},
	{{content = "4.觉醒技能完全解锁，将领即觉醒。",color = COLOR[3]}},
	{{content = "5.觉醒后，若被动技能未满级，仍可继续通过秘药觉醒或金币觉醒升级。",color = COLOR[3]}},
	{{content = "6.先觉醒再升级，与先升级再觉醒的最终效果是一样的。",color = COLOR[3]}},
	{{content = "7.将领加成面板括号内的灰值，会在将领觉醒后被激活。该值会随着将领等级提升而提升。",color = COLOR[3]}},
}

DetailText.school = {
	{{content = "1. 每次进修都能获得导师赠予的秘药。"}},
	{{content = "2. 激活“百变星君”buff后，每次进修还有几率获得额外奖励：军功章、技能书、将魂、将神魂碎片。"}},
	{{content = "3. 进修教材在活动结束后会被清除，请务必在活动结束前全部使用掉。"}},
	{{content = "4. 进修教材每小时自动回复1本，当前数量≥10本时，将停止自动回复。"}},
	{{content = "5. 使用金币购买进修教材可以超出10本的上限。购买单价随购买数量提升而提升。"}},
	{{content = "6. 每结业一个学科，都将获得一份丰厚的结业奖励，并更换一位新的导师。"}},
}

DetailText.signInfo = {
	{{content = "1. 每月累计签到天数，领取相应的签到奖励。"}},
	{{content = "2. 累计达到一定的天数，还可以领取额外奖励。"}},
	{{content = "3. 在特定日子里，达到对应VIP等级及以上的玩家可领取双倍奖励！第二份奖励可在当日内升级VIP等级后补领。"}},
	{{content = "4. 每日签到奖励在每日24点计算隔天，当天未领取的奖励隔天不可再补领。"}},
}

DetailText.WeaponryInfo = {
	{{content = "军备属性"}},
	{{content = "   军备属性作用于所有部队（坦克、战车、火炮、火箭均受到属性加成效果）"}},
	{{content = " "}},
	{{content = "军备获取"}},
	{{content = "   前往军备工厂打造获得"}},
	{{content = "   军备材料、图纸可通过叛军以及活动获得"}},
	{{content = " "}},
	{{content = "军备打造"}},
	{{content = "1、军备打造需要消耗图纸，材料，资源"}},
	{{content = "2、一次只能打造一件军备"}},
	{{content = "3、雇佣技工可点击“技工加速”加快军备打造。雇佣时间到后，技工将失去效果。"}},
}


DetailText.MaterialInfo = {
	{{content = "材料工坊"}},
	{{content = ""}},
	{{content = "1、材料工坊消耗低级军备图纸和资源，生产军备材料。"}},
	{{content = "2、玩家当前繁荣度以及繁荣度上限决定工坊的生产速度。"}},
	{{content = "3、材料的预计生产时间会随着繁荣度的变化而变化。"}},
}


DetailText.militaryRankInfo = {
	{{content = "军衔详情"}},
	{{content = "在指挥官等级达到一定程度后，可消耗军功与材料，进行军衔的提升。每一级军衔有军功储存的上限，该限制随军衔等级的提升而提升"}},
	{{content = " "}},
	{{content = "军功获取"}},
	{{content = "军功由战斗中击毁敌方玩家坦克以及自身损失坦克积累，不同品质坦克获取的军功不同。战斗包含：世界地图中的战斗，百团大战，要塞战,军事矿区等等。每日获取的军功有上限，超过上限部分将不再计入"}},
	{{content = " "}},
	{{content = "军衔属性"}},
	{{content = "军衔属性在获得之后，永久生效，作用于所有部队（坦克，战车，火炮，火箭均享受属性加成效果）"}},
}

DetailText.RefineMaster = {
	{{content = "活动规则"}},
	{{content = " "}},
	{{content = " "}},
	{{content = "(1) 活动开启时，可以通过淬炼的方式有几率获得氪金锭。"}},
	{{content = "(2) 通过寻宝有几率获得紫色配件碎片和各种改造材料"}},
	{{content = "(3) 每次寻宝可获得1积分，十次寻宝可获得12积分，百次寻宝可获得120积分"}},
	{{content = "(4) 活动结算时，积分排行前50名玩家可以获得丰厚的奖励"}},
	{{content = "(5) 积分超过100才能上榜"}},
	{{content = "(6) 活动结束后，未消耗掉的氪金锭将会被清零。请在活动期间尽快使用。"}},
}

DetailText.AirshipInfo = {
	{tip = "飞艇开启", {content = "   当服务器开启时间达到5天后解锁飞艇功能.参与飞艇战事必须要先参加一个军团."},
						{content = "(军团等级限制为3级,依次解锁飞艇攻击权限).", color = cc.c3b(239,66,5)},
	},
	{tip = "飞艇战斗", {content = "   飞艇可以由军团长或者副团长免费发起集结"},
					   {content	= "(每日免费一次,当玩家发动过一次免费集结后将失去今日的免费次数)",color=cc.c3b(239,66,5)},
					   {content	= "同一个集结战事中,指挥官只能派遣一支部队参与战斗.同一军团同时只能发起一支针对同一飞艇的集结战事.当飞艇处于中立时,每场战斗结束后会自动修复已损失的耐久"},
					   {content	= "发起战斗序列来进行进攻,进攻发起者可以根据需要调整参与者的参战顺序,所有参战指挥官可以选择撤回部队."},
					   {content	= "(行军状态下撤回需要消耗道具,当飞艇发起行军时无法重新派遣部队加入序列)当消灭一支防守部队时,下次面对对手时将由新出现的部队攻击",color=cc.c3b(239,66,5)}
	},
	{tip = "飞艇修复", {content = "   飞艇每次修复消耗根据世界等级变化所需的资源,并每次固定"},
					   {content	= "回复5%的耐久度,",color=cc.c3b(239,66,5)},
					   {content	= "当飞艇遭受攻击时飞艇耐久度将会损失,耐久度的数量决定了飞艇在战斗中的参战强度.尽量做好防守防止飞艇遭受攻击."},
	},	
	{tip = "飞艇防守", {content = "   防守飞艇时所有同军团指挥官可以派遣部队进行设防,用来防守对手的进攻."},
						{content = "同一个飞艇,指挥官只能派遣一支部队参与防守"},
						{content = "当飞艇的耐久度损失为0时飞艇的所有权会发生改变(飞艇在修复后无法重新修复,需要确保飞艇无法被攻击到).",color=cc.c3b(239,66,5)},
						{content = "飞艇防守者可以在有部队驻防时调整驻防部队的防守战斗序列.,驻防飞艇的部队从设置防守到行军结束会有一小段时间的行军时间.损失的坦克会自动返回指挥官基地."},
						{content = "飞艇在战斗序列内会作为最后一个出战的部队.",color=cc.c3b(239,66,5)},
	},
	{tip = "飞艇物资生产", {content = "   每个飞艇在占领后会有一个"},
						{content = "(持续8小时的)",color=cc.c3b(239,66,5)},
						{content = "保护时间,在这个时间内其他军团无法发起针对此飞艇的集结进攻,同时飞艇的耐久度不会主动恢复,需要指挥官主动修理飞艇,"},
						{content = "当飞艇的耐久度第一次达到100%时,飞艇会开始生产物资.",color=cc.c3b(239,66,5)},
						{content = "当有物资可以领取时同军团的所有玩家可以消耗军功领取已经生产的相应的物资.保护时间结束时,飞艇的耐久度不为100%则飞艇会自动重归于中立状态.,飞艇的物资容量有限,需要在容量满前领取,否则生产将会停止."},
	},
	{tip = "飞艇指挥官", {content = "   飞艇被攻占后会自动设定发起者为指挥官,若指挥官已经拥有飞艇指挥权,则会在其他符合指挥官职位的指挥官中选择1名指挥官成为飞艇指挥官"},
						{content = "[根据军衔,战力,官职条件筛选].",color=cc.c3b(239,66,5)}, 
						{content = "同时飞艇所有者和军团长有在军团福利院转让和重新委任指挥官的权限.当没有指挥官能够管理足够的飞艇时,新获得的飞艇管辖权将会自动丢失."}
	},
	{tip = "集结行军", {content = "   发起集结后有默认15分钟的准备时间.当准备时间达到或者发起者主动出征部队时,集结部队会开始行军,前往飞艇目标的时间为固定时间"},
						{content = "(随着同一飞艇被多支集结部队进攻时,行军时间会有相应延长)",color=cc.c3b(239,66,5)},
						{content = ",集结部队在测试版本中与行军部队为相同序列.会出现在部队列表中并占用一个部队序列."},
	},
	{tip = "部队战损率", {content = "战损率为5%."}},
}

DetailText.WeaponryTips = {
	{{content = "军备洗练"}},
	{{content = " "}},
	{{content = " "}},
	{{content = "洗练技能：洗练能使军备获得随机额外技能，作用于所有部队。品质越高的军备拥有的洗练技能个数越多，洗练技能的等级上限越高。"}},
	{{content = " "}},
	{{content = " "}},
	{{content = "洗练类型：军备洗练分为三种，免费洗练，至尊洗练，和神秘洗练。免费洗练可随时间恢复次数，次数到达上限后将无法储存。神秘洗练仅有紫色以上品质才有，在前三个洗练技能等级达到满后，神秘洗练将可用。神秘洗练能将四个洗练技能随机转化相同的满级技能。"}},
}

DetailText.NewActiveInfo = {
{{
	{{content = "                         任务集星玩法介绍",color = cc.c3b(239, 66, 5)}},
	{{content = " "}},
	{{content = "星星获得方法：通过完成"},{content= "日常任务",color = cc.c3b(3, 212, 231)},{content= "，根据任务的星级来获得星星，日常任务每一个星星对应获得一颗星星。"}},
	{{content = " "}},
	{{content = "获取更多星星：尽量完成高星级的任务，可以通过刷新任务来寻找高星级任务。"}},
	{{content = " "}},
	{{content = "获取更多任务：每完成5个任务，即可通过重置任务来获得新的5个任务。"}},
	{{content = " "}},
	{{content = "档位列表："}},
	{{content = "第一档：20颗星星  获得5点活跃度"}},
	{{content = "第二档：50颗星星  获得10点活跃度"}},
	{{content = "第三档：80颗星星  获得15点活跃度"}},
	{{content = "第四档：120颗星星  获得20点活跃度"}},
	{{content = "第五档：180颗星星  获得30点活跃度"}},
	{{content = "第六档：250颗星星  获得40点活跃度"}},
	{{content = " "}},
	{{content = "任务集星一周可获得的活跃上限为：120点"}},
	},
{
	{{content = "                         配件探险玩法介绍",color = cc.c3b(239, 66, 5)}},
	{{content = " "}},
	{{content = "计算方式：通过参与"},{content= "配件探险关卡",color = cc.c3b(3, 212, 231)},{content= "，每获得一次胜利，即计算一次次数。"}},
	{{content = " "}},
	{{content = "获取更多次数：可以通过购买配件探险次数，来更快的获得配件探险类积分。"}},
	{{content = " "}},
	{{content = "限制条件：司令部等级达到18级，才可开启配件探险玩法。"}},
	{{content = " "}},
	{{content = "攻打配件探险关卡，只有获得胜利，才能获得次数计算。"}},
	{{content = "档位列表："}},
	{{content = "第一档：15次探险  获得5点活跃度"}},
	{{content = "第二档：35次探险  获得10点活跃度"}},
	{{content = "第三档：55次探险  获得15点活跃度"}},
	{{content = "第四档：75次探险  获得20点活跃度"}},
	{{content = "第五档：95次探险  获得30点活跃度"}},
	{{content = "第六档：120次探险  获得40点活跃度"}},
	{{content = " "}},
	{{content = "配件探险一周可获得的活跃上限为：120点"}},		
	},
{
	{{content = "                         生产坦克玩法介绍",color = cc.c3b(239, 66, 5)}},
	{{content = " "}},
	{{content = "计算方式：通过"},{content= "生产任意坦克",color = cc.c3b(3, 212, 231)},{content= "，达到指定的数量，即可领取奖励。"}},
	{{content = " "}},
	{{content = "快速获取积分：通过军工科技，可以更快的达到条件，领取活跃值。"}},
	{{content = " "}},
	{{content = "档位列表："}},
	{{content = "第一档：生产任意500辆坦克  获得5点活跃度"}},
	{{content = "第二档：生产任意1000辆坦克  获得10点活跃度"}},
	{{content = "第三档：生产任意2000辆坦克  获得15点活跃度"}},
	{{content = "第四档：生产任意5000辆坦克  获得20点活跃度"}},	
	{{content = " "}},
	{{content = "生产坦克一周可获得的活跃上限为：50点"}},
	},
{
	{{content = "                         强化配件玩法介绍",color = cc.c3b(239, 66, 5)}},
	{{content = " "}},
	{{content = "计算方式：通过"},{content= "强化任意配件",color = cc.c3b(3, 212, 231)},{content= "，每消耗1M水晶，即可增加1点活跃度。"}},
	{{content = " "}},
	{{content = "配件探险一周可获得的活跃上限为：50点。"}},
	{{content = " "}},
	{{content = "快速获取积分：通过强化高等级的配件，能够更快的获得积分。"}},
	{{content = " "}},
	{{content = "限制条件：司令部等级达到18级，才可开启配件探险玩法。"}},		
	},},
{{
	{{content = "                         竞技场玩法介绍",color = cc.c3b(239, 66, 5)}},
	{{content = " "}},
	{{content = "参与方法：通过在"},{content= "竞技场挑战",color = cc.c3b(3, 212, 231)},{content= "其他玩家，来获得挑战次数，达到指定次数，即可获得奖励。"}},
	{{content = " "}},
	{{content = "获取挑战次数：每天都会自动获得5次免费挑战次数。"}},
	{{content = " "}},
	{{content = "获取更多竞技场次数：可以通过购买竞技场次数，来更快获得竞技场胜利数。"}},
	{{content = " "}},
	{{content = "限制条件：玩家等级达到15级开启竞技场。不管挑战是否胜利，都计算次数。"}},
	{{content = " "}},
	{{content = "档位列表："}},
	{{content = "第一档：竞技场胜利5次  获得5点活跃度"}},
	{{content = "第二档：竞技场胜利20次  获得10点活跃度"}},
	{{content = "第三档：竞技场胜利40次  获得15点活跃度"}},
	{{content = "第四档：竞技场胜利60次  获得20点活跃度"}},
	{{content = "第五档：竞技场胜利80次  获得30点活跃度"}},
	{{content = "第六档：竞技场胜利100次  获得40点活跃度"}},
	{{content = " "}},
	{{content = "竞技场一周可获得的活跃上限为：120点"}},
	},
{
	{{content = "                         战役关卡玩法介绍",color = cc.c3b(239, 66, 5)}},
	{{content = " "}},
	{{content = "计算方式：通过参与"},{content= "攻击战役关卡",color = cc.c3b(3, 212, 231)},{content= "，每获得一次胜利，即计算一次次数。"}},
	{{content = " "}},
	{{content = "获取更多次数：可以通过购买体力，来更快的获得战役关卡类积分。"}},
	{{content = " "}},
	{{content = "限制条件：攻打战役关卡，只有获得胜利，才能获得次数计算。"}},
	{{content = " "}},
	{{content = "档位列表："}},
	{{content = "第一档：通关20次任意战役关卡  获得5点活跃度"}},
	{{content = "第二档：通关50次任意战役关卡  获得10点活跃度"}},
	{{content = "第三档：通关100次任意战役关卡  获得15点活跃度"}},
	{{content = "第四档：通关200次任意战役关卡  获得20点活跃度"}},
	{{content = "第五档：通关400次任意战役关卡  获得30点活跃度"}},
	{{content = "第六档：通关600次任意战役关卡  获得40点活跃度"}},
	{{content = " "}},
	{{content = "战役关卡一周可获得的活跃上限为：120点"}},
	},
{
	{{content = "                         资源采集玩法介绍",color = cc.c3b(239, 66, 5)}},
	{{content = " "}},
	{{content = "计算方式：通过"},{content= "采集",color = cc.c3b(3, 212, 231)},{content= "世界地图资源点，每成功占领一次野外资源点，即计算一次次数。"}},
	{{content = " "}},
	{{content = "获取更多次数：可以通过购买体力，提升VIP等级来更快的获得资源采集类积分。"}},
	{{content = " "}},
	{{content = "限制条件：攻打世界地图资源点，只有获得胜利，才能获得次数计算。"}},
	{{content = " "}},
	{{content = "档位列表："}},
	{{content = "第一档：采集10次任意等级世界资源  获得5点活跃度"}},
	{{content = "第二档：采集20次任意等级世界资源  获得10点活跃度"}},
	{{content = "第三档：采集40次任意等级世界资源  获得15点活跃度"}},
	{{content = "第四档：采集60次任意等级世界资源  获得20点活跃度"}},
	{{content = "第五档：采集80次任意等级世界资源  获得30点活跃度"}},
	{{content = "第六档：采集100次任意等级世界资源  获得40点活跃度"}},
	{{content = " "}},
	{{content = "资源采集一周可获得的活跃上限为：120点"}},
	},
{
	{{content = "                         攻打玩家玩法介绍",color = cc.c3b(239, 66, 5)}},
	{{content = " "}},
	{{content = "计算方式：通过"},{content= "攻打其他玩家",color = cc.c3b(3, 212, 231)},{content= "，每成功战胜其他玩家一次，即计算一次次数"}},
	{{content = " "}},
	{{content = "限制条件：攻打其他玩家，只有获得胜利，才能获得次数计算。"}},
	{{content = " "}},
	{{content = "档位列表："}},
	{{content = "第一档：攻打任意玩家3次  获得5点活跃度"}},
	{{content = "第二档：攻打任意玩家10次  获得10点活跃度"}},
	{{content = "第三档：攻打任意玩家20次  获得15点活跃度"}},
	{{content = "第四档：攻打任意玩家30次  获得20点活跃度"}},
	{{content = " "}},
	{{content = "攻打玩家一周可获得的活跃上限为：50点"}},
	},},
{{
	{{content = "                         百团大战玩法介绍",color = cc.c3b(239, 66, 5)}},
	{{content = " "}},
	{{content = "每周一，周三，周六开启百团混战，参与报名即可获得10点活跃度，每周最高可获得30点活跃度"}},
	},
{
	{{content = "                         军事演习玩法介绍",color = cc.c3b(239, 66, 5)}},
	{{content = " "}},
	{{content = "每周二开启军事演习，只要参与报名，即可获得10点活跃度，每周最高获得10点活跃度"}},
	},
{
	{{content = "                         世界BOSS玩法介绍",color = cc.c3b(239, 66, 5)}},
	{{content = " "}},
	{{content = "每周五开启世界BOSS，只要攻击一次BOSS，即可获得10点活跃度，每周最高获得10点活跃度"}},
	},
{
	{{content = "                         要塞战玩法介绍",color = cc.c3b(239, 66, 5)}},
	{{content = " "}},
	{{content = "每周日开启要塞战，拥有参与资格的军团成员，只要参与过1次战斗，即可获得10点活跃度，每周最高获得10点活跃度"}},
	},},
{{
	{{content = "                         充值活跃玩法介绍",color = cc.c3b(239, 66, 5)}},
	{{content = " "}},
	{{content = "在一个活跃度进行期间，每充值10元，即获得1点活跃度，通过充值获得的活跃度无上限。"}},
	},
{
	{{content = "                         招募将领玩法介绍",color = cc.c3b(239, 66, 5)}},
	{{content = " "}},
	{{content = "在一个活跃度进行期间，每招募10次将领，获得1点活跃度，通过招募将领获得的活跃度无上限。"}},
	},
{
	{{content = "                         消费活跃玩法介绍",color = cc.c3b(239, 66, 5)}},
	{{content = " "}},
	{{content = "在一个活跃度进行期间，每消耗200金币，即获得1点活跃度，通过消费获得的活跃度无上限。"}},
	},},
}

DetailText.staffHeros = {
	{{content="参谋配置"}},
	{{content=" "}},
	{{content="运筹帷幄之中，决胜千里之外，这里是军事学院中不能上阵的将领进驻的地方。"}},
	{{content=" "}},
	{{content="1、在参谋部配置上对应的将领，即能获得将领技能效果（若获得了将领没有在参谋部配置，是不会生效的哦）"}},
	{{content="2、技能类型相同但是效果强度不同的将领，同时上阵会激活更强的技能"}},
}

DetailText.EnegryTips = {
	{{content = "1. 每充值1元=注入10点能量。每天累计充值达到指定的金额，即可点击摇晃的宝箱图标，领取当天的充值奖励。"}},
	{{content = " "}},
	{{content = "2. 点击对应天数上的“注入能量”按钮，可对前面未达标的某天进行补充。"}},
	{{content = " "}},
	{{content = "3. 补充达标后，仍可领取对应当天的奖励。"}},
	{{content = " "}},
	{{content = "4. 累计3天都达标，还能免费领取一份超级大奖。"}},
}

DetailText.OwnGiftTips = {
	{{content = "1. 活动期间，累计充值达到活动额度时，即可任选一份礼物。"}},
	{{content = " "}},
	{{content = "2. 每天参加次数有上限值。"}},
	{{content = " "}},
	{{content = "3. 每天0点将重置可参与次数和领取资格。请各位指挥官在重置前领取礼物。"}},
}

DetailText.BrotherTips = {
	{{content = "1. 活动期间，增益效果对全军团的成员生效。"}},
	{{content = " "}},
	{{content = "2. 增益效果，在攻击和防守飞艇时生效。"}},
	{{content = " "}},
	{{content = "3. 集结和行军时，依然可以继续激活或升级的增益效果。只有在战斗过程中激活或升级的增益效果，才会在下次战斗时生效。"}},
	{{content = " "}},
	{{content = "4. 增益效果，未完成的任务及未领取的奖励，不会被保留到下次活动中。"}},
	{{content = " "}},
	{{content = "5. 在完成攻打飞艇的任务时，只有部队进入战斗后，才会使次数+1。中途召回部队或是遇到飞艇进入保护期，未进入战斗而遣返，都不会增加次数。"}},
}

DetailText.medalRefine = {
	{{content = "勋章精炼"}},
	{{content = " "}},
	{{content = "1. 勋章精炼能将紫色品质勋章转换为橙色品质勋章。"}},
	{{content = " "}},
	{{content = "2. 原勋章升级等级，打磨等级，以及现有的经验值都将完全保留。"}},
}

DetailText.hyperSpace = {
	{{content = "活动规则"}},
	{{content = " "}},
	{{content = "1.原力不会在活动结束后被清空，而是可以被累计到下次活动中继续兑换你想要的道具。"}},
	{{content = "2.VIP等级达到V6及以上时，能够在活动中享受“贸易大王”的效果：每次贸易列表中显示4个道具。"}},
	{{content = "3.每日可在贸易界面免费获得5次刷新机会，但无法叠加到次日使用。"}},
	{{content = "4.在兑换界面中点击左右箭头或是直接左右滑动，都可以刷新兑换货物。但刷新只能通过消耗刷新券或金币实现，优先消耗刷新券。"}},
}

DetailText.MedalHelper = {
	{{content = "1. 活动期间，勋章升级无冷却时间。每天0点会重置免费索敌的次数。该次数隔日无法叠加。"}},
	{{content = " "}},
	{{content = "2. 领奖期间，依然可以进行兑换。"}},
	{{content = " "}},
	{{content = "3. 活动结束后，荣誉勋章会被清空，且无法被累积到下次活动中。请及时兑换各种材料。"}},
	{{content = " "}},
	{{content = "4. 单轮摧毁3橙必定吃鸡。"}},
	{{content = " "}},
	{{content = "5. 吃金拱门全家桶1份，等于吃鸡10次。"}},
	{{content = " "}},
	{{content = "6. 吃鸡数量≥10只，可进入吃鸡排行榜。吃鸡数量相同时，依照达成的时间先后顺序排名。排名前10的玩家可领取大奖。"}},
	{{content = " "}},
	{{content = "7. 消耗金币进行索敌的费用，会随着次数增加而增加。"}},
}

DetailText.WarWeaponHelper = {
	{{content = "秘密武器"}},
	{{content = " "}},
	{{content = "短兵相接的战争慢慢淡去，但在另一个地方，一场没有硝烟的战争已悄然开启。各个武器研究所接连开始了秘密武器的研究，意图有朝一日，能在战场上给予敌方致命一击。"}},
	{{content = " "}},
	{{content = " "}},
	{{content = "功能介绍"}},
	{{content = " "}},
	{{content = "1.秘密武器一共有三种，前一种武器所有技能槽全部解锁完毕后，自动激活下一种武器。"}},
	{{content = " "}},
	{{content = "2.秘密武器的技能槽需要逐条解锁，每种武器有各自的属性偏向。"}},
	{{content = " "}},
	{{content = "3.武器携带的技能可通过研究来进行刷新，每次研究将刷新所有未锁定的技能。如果有指挥官满意的技能，一定要记得加锁哦。"}},
	{{content = " "}},
	{{content = "4.研究券可抵消研究的费用，但是技能锁定的费用还是需要支付的哦。"}},
}

DetailText.ActMonopolyHelper = {
	{{content = "1.	活动开启后的每天12点和24点会准时空投1个补给箱，内含100点精力。"}},
	{{content = " "}},
	{{content = "2.	未领取的补给箱会一直存在，但无法叠加，请指挥官及时领取哟！"}},
	{{content = " "}},
	{{content = "3.	每天24点会重置当前单圈的跑圈进度，并让你回到起点从新开始。请不要在0点前压秒操作，避免奖励被刷新哟。"}},
	{{content = " "}},
	{{content = "4.	每次抵达终点时，多余的步数不会被累计到下一圈中。"}},
	{{content = " "}},
	{{content = "5.	只有存放在背包内的意念骰子和精力药剂，才不会因活动结束而被清空。"}},
	{{content = " "}},
	{{content = "6.	指挥官大人一定要在活动结束前，领取掉跑圈奖励哟。"}},
} 

DetailText.LaboratoryHelper = {
	{{content = "研究院"}},
	{{content = " "}},
	{{content = "1、研究院是生产各种高科技材料的地方，部分材料需要解锁对应的建设，才能进行生产。"}},
	{{content = " "}},
	{{content = "2、研究院会随着时间生产各种材料，各种材料的产量可在人员分配里调整。最顶级的材料需要3人一组才能生产哦。"}},
	{{content = " "}},
	{{content = "3、各材料的合成效率可通过科技突破研究提升，提升人数对材料的生产速度提升很大哦！"}},
	{{content = " "}},
	{{content = "4、研究院的材料装满后将不再生产材料了，请指挥官按时收取哦！初始的容量，可支持4小时的材料生产。"}},
} 

DetailText.LaboratoryDeploymentHelper = {
	{{content = "兵种调配室"}},
	{{content = " "}},
	{{content = "1、兵种调配室是各兵种尖端科技调配的场所，指挥官可使用研究院生产的材料进行兵种深度研究。"}},
	{{content = " "}},
	{{content = "2、兵种深度研究有前置关系，需要将其前置科技提升到相应等级，才能研究下一个。"}},
	{{content = " "}},
	{{content = "3、任一兵种深度研究技能达到Max等级时，研究进度增加一点，进度达到一定程度，能领取奖励，点击进度条可查看。"}},
} 

DetailText.RedPacketHelper = {
	{{content = "各位指挥官新年快乐！"}},
	{{content = " "}},
	{{content = "活动开启期间，每笔满500金币的充值，将获得活动红包。"}},
	{{content = " "}},
	{{content = "1、红包的总金额等于充值金额与活动返利比例的乘积，由不同面值的红包拼组。"}},
	{{content = " "}},
	{{content = "2、活动返利比例会随着全服累计充值进度而提升。每进入一个阶段，全服玩家皆可领取一份奖励，并且享受更高的活动返还比例。"}},
	{{content = " "}},
	{{content = "3、红包可选择在世界频道或者军团频道发送，人数可由发送者设置。"}},
	{{content = " "}},
	{{content = "4、四种活动红包在活动结束之后会消失，请指挥官务必于活动期间内使用！"}},
}

DetailText.SpyLuckHelper = {
	{{content = "1. 谍报机构是获得各种高科技材料的重要场所。派遣间谍执行任务可获取稀缺的作战实验室所需材料。"}},
	{{content = " "}},
	{{content = "2. 间谍被派遣后会自动执行任务，指挥官只需要定期回来领取奖励即可。"}},
	{{content = " "}},
	{{content = "3. 不同的区域刷新的任务不同，高级的区域有可能刷出高品质的任务呢。"}},
	{{content = " "}},
	{{content = "4. 间谍的能力越强，不仅可以获得更多的材料，甚至还能发现隐藏的宝藏哦！"}},
	{{content = " "}},
	{{content = "5、每日0点刷新所有闲置的任务。"}},
}

DetailText.redplanHelper = {
	{{content = "1. 执行红色方案推翻腐朽的资本主义政府！点击地图选择进攻区域，消耗燃料可进行出击，掠夺物资。"}},
	{{content = " "}},
	{{content = "2. 燃料会随时间恢复，一小时一点。可花费金币购买，燃料价格会随着购买次数提高。"}},
	{{content = " "}},
	{{content = "3. 物资可用于和军火商交换珍贵的道具，他正在货轮上等着你，别让他宰的太多！"}},
	{{content = " "}},
	{{content = "4. 选择出击，从当前位置点前往下一位置点，如有多个地点，会随机选择一个进军（无战斗）。进军到达地区终点，可解锁下一地区剧情。"}},
	{{content = " "}},
	{{content = "5. 地区可重复挑战来探索之前未到达的地点。探索完该地区所有的地点，即可领取关卡宝箱并开启关卡扫荡功能。"}},
	{{content = " "}},
	{{content = "6. 未使用完的物资和物资箱会保留到下次活动。"}},
}

DetailText.luckyRoundHelper = {
	{{content = "活动说明"}},
	{{content = " "}},
	{{content = "1.活动开启时，系统会在奖池投放%d金币。"}},
	{{content = " "}},
	{{content = "2.活动期间玩家每次充值，获得正常的金币，奖池也会增加同样的金币。"}},
	{{content = " "}},
	{{content = "3.活动期间累计充值，每满%d金币即可获赠1次抽奖次数。"}},
	{{content = " "}},
	{{content = "4.抽奖会获得奖品，概率直接获得奖池中的部分金币。"}},
}

DetailText.tankExchange = {
	{{content = "转换同阶兵种，组建强大部队！"}},
	{{content = " "}},
	{{content = "1. 活动开启期间，玩家可以转换同阶部队的兵种。"}},
	{{content = " "}},
	{{content = "2. 转换需要花费记忆芯片，记忆芯片会在活动结束后清除。"}},
	{{content = " "}},
	{{content = "3. 兵种转换只能转换同阶部队的兵种类型，无法从低阶兵种转换成高阶兵种。"}},
	{{content = " "}},
	{{content = "4. 兵种转换比例为1：1"}},
}

DetailText.activityMedalCash = {
	{{content="军备兑换"}},
	{{content="(1)收集配方材料，可兑换获取奖励"}},
	{{content="(2)对配方不满意，可刷新配方"}},
}

DetailText.friendGive = {
	{{content="1. 互为好友之间可通过祝福和赠送红包提升友好度"}},
	{{content="  "}},
	{{content="2. 指挥官达到70级，友好度达到一定值，可开启部分道具赠送功能"}},
	{{content="   (1)友好度200:紫色配件碎片1~2号位; 友好度300:紫色配件碎片3~4号位; 友好度400:紫色配件碎片5~6号位; 友好度500:紫色军备图纸; 友好度600:勋章之心; 友好度700:万能碎片; 友好度800:紫色配件碎片7~8号位"}},
	{{content="  "}},
	{{content="3. 友好度达到一定值，掠夺对方基地资源还可额外增加载重量"}},
	{{content="   (1)友好度150:20%; 友好度350:30%; 友好度550:50%; 友好度750:65%; 友好度900:80%; 友好度1000:100%"}},
	{{content="  "}},
	{{content="4. 每月有赠送和获赠的次数限制,次月次数重置"}},

}

DetailText.royaleSurviveDetail = {
	{{content = "1、开服30天后,每月5号和20号的00:00开启荣耀生存玩法,每次玩法持续2天"}},
	{{content = "2、玩法分多个阶段"}},
	{{content = "  2.1、第1天00:00~01:00,第1圈安全区确认"}},
	{{content = "  2.2、第1天01:00~07:00,完成第1圈缩毒"}},
	{{content = "  2.3、第1天07:00~08:00,第2圈安全区确认"}},
	{{content = "  2.4、第1天08:00~12:00,完成第2圈缩毒"}},
	{{content = "  2.5、第1天12:00~13:00,第3圈安全区确认"}},
	{{content = "  2.6、第1天13:00~17:00,完成第3圈缩毒"}},
	{{content = "  2.7、第1天17:00~18:00,第4圈安全区确认"}},
	{{content = "  2.8、第1天18:00~21:00,完成第4圈缩毒,最后的安全区即为荣耀区,荣耀区持续到玩法结束"}},
	{{content = "  2.9、第1天21:00~第2天24:00,荣耀区采集可获得金币和其它加成"}},
	{{content = "3、处于毒区/安全区中的基地,会提供不同的增益/减益buff"}},
	{{content = "  3.1、毒区中的基地,坦克的生命、闪避、抗暴、行军速度会降低,且在世界地图攻打矿点和基地产生的永久损兵增加,毒区阶段越高,影响越大"}},
	{{content = "  3.2、安全区中的基地,坦克的攻击、震慑、爆裂、坚韧和减伤会增加,安全区阶段越高,增加越多"}},
	{{content = "4、玩法期间采集、攻打基地还可获得额外收益"}},
	{{content = "  4.1、采集可获得荣耀积分,矿点等级越高,积分获取速度越快,收矿时会根据矿点所处安全区/毒区的阶段,额外增加/扣除10%/20%/30%/50%比例的积分；采集积分可被掠夺"}},
	{{content = "  4.2、荣耀区采集可获得采集加速效果,并可获得金币,金币可被掠夺,且有掠夺上限"}},
	{{content = "  4.3、攻打基地和矿点时,若击毁玩家高阶坦克可获得荣耀积分,坦克阶级越高、数量越多,获得积分也越多"}},
	{{content = "5、玩法期间对荣耀积分进行排名,玩法结束后可领取军团、个人排行和荣耀金币奖励,所在军团、排名以活动结束时为准"}},
	{{content = "6、请及时收回采集部队,玩法结束后再次收回部队不再获得积分,已采集金币会保留(但是不会侦察显示,收回部队可获得)"}},
}

DetailText.newHeroClearCD = {
	{
		{content = "破罩技能处于冷却状态,剩余时间"}, 
		{content = "%s", color = COLOR[6], format="s"},
		{content = "是否花费金币"}, 
		{content = "%d", color = COLOR[99], format="i"},
		{content = "清除冷却(剩余"},
		{content = "%d", color = COLOR[2], format="i"},
		{content = "次)?"},
	},
}

DetailText.worldMineStr = {
	{
		{content = "世界资源和军事矿区的矿点等级提升"},
		{content = "%d", color = COLOR[2], format="i"},
		{content = "级"},
	},
	{
		{content = "采矿速度提升"},
		{content = "%.2f%%", color = COLOR[2], format="f"},
	},
	{
		{content = "矿点经验每日衰减"},
		{content = "%.1f%%", color = COLOR[6], format="f"},
	},
}

DetailText.worldMineDetail = {
	{{content = "1、全服所有编制等级999级的玩家，每日扣除的编制经验注入到矿点升级经验中"}},
	{{content = "2、矿点升级经验值达到要求时，自动升级。矿点升级每提升1级，世界资源矿和军事矿区的等级提升2级"}},
	{{content = "3、每日贡献编制经验的玩家，可获得当天采矿速度提升的buff。贡献经验越多，速度提升越高"}},
	{{content = "4、每日0点，矿点升级经验会损失一定比例的当前经验。矿点等级越高，损失比例越大。矿点升级经验不足时，可能会导致矿点等级下降"}},
}

DetailText.SecondWeaponrys = {
	{{content = "1、橙色军备洗练4个满级技能后开放第2套洗练方案"}},
	{{content = "2、解锁第2套洗练方案需消耗同部位满级洗练技能的紫装，和500金币"}},
	{{content = "3、解锁完成后，第二套方案直接继承橙色军备现有的洗练技能和等级"}},
	{{content = "4、两套方案可独立洗练和保存，属性不叠加"}},
	{{content = "5、拥有可切换洗练方案的橙色军备时，军备主界面增加切换属性按钮，可一键切换方案1和方案2"}},
}

DetailText.buildflourishDetail = {
	{
		{content = "90级以前每级提供", size=16},
		{content = "%d", color = COLOR[3], format="i", size=16},
		{content = "点繁荣度,", size=16},
		{content = "90级以后每级提供", size=16},
		{content = "%d", color = COLOR[3], format="i", size=16},
		{content = "点繁荣度", size=16},
	},
}

DetailText.partyPay = {
{{content = "活动持续4天"}},
{{content = "活动前3天，指挥官充值的进度也会累计到军团"}},
{{content = "活动第4天，军团充值达成条件的，全体军团成员均可领取奖励"}},
{{content = "第4天才进入军团的成员，不可领取军团好礼"}},
}

DetailText.chanceHero = {
{{content = "指挥官达到20级开启限时关卡"}},
{{content = "攻打关卡.可获得宝物碎片"}},
{{content = "碎片可以在神秘商店进行奖励兑换"}},
{{content = "每个关卡有不同等级据点"}},
{{content = "攻打高级据点可获得更多的宝物碎片"}},
{{content = "攻打胜利固定扣除1次次数"}},
{{content = "失败不扣除"}},
}

DetailText.chanceEquip = {
{{content = "指挥官达到20级开启限时关卡"}},
{{content = "攻打关卡.可获得宝物碎片"}},
{{content = "碎片可以在神秘商店进行奖励兑换"}},
{{content = "每个关卡有不同等级据点"}},
{{content = "攻打高级据点可获得更多的宝物碎片"}},
{{content = "攻打胜利固定扣除1次次数"}},
{{content = "失败不扣除"}},
}

--战术
DetailText.TacticRestrain = {
	{{{content = "当激活战术套效果时，若6个战术均为坦克兵种，可获得额外属性："}}, 
	 {{content = "该部队坦克出战额外增加1%/3%/5%抗暴"}}, 
	 {{content = "对火箭克制额外增加5%/10%/15%"}}, 
	 {{content = "  "}}, 
	 {{content = "品质越高，额外属性越高"}}, 
	 {{content = "6个战术取最低品质生效，如4个绿色、1个蓝色、1个紫色战术，兵种套为最低效果"}}
	},

	{{{content = "当激活战术套效果时，若6个战术均为战车兵种，可获得额外属性："}}, 
	 {{content = "该部队战车出战额外增加1%/3%/5%闪避"}}, 
	 {{content = "对坦克克制额外增加5%/10%/15%"}}, 
	 {{content = "  "}}, 
	 {{content = "品质越高，额外属性越高"}}, 
	 {{content = "6个战术取最低品质生效，如4个绿色、1个蓝色、1个紫色战术，兵种套为最低效果"}}
	},

	{{{content = "当激活战术套效果时，若6个战术均为火炮兵种，可获得额外属性："}}, 
	 {{content = "该部队火炮出战额外增加1%/3%/5%命中"}}, 
	 {{content = "对战车克制额外增加5%/10%/15%"}}, 
	 {{content = "  "}}, 
	 {{content = "品质越高，额外属性越高"}}, 
	 {{content = "6个战术取最低品质生效，如4个绿色、1个蓝色、1个紫色战术，兵种套为最低效果"}}
	},

	{{{content = "当激活战术套效果时，若6个战术均为火箭兵种，可获得额外属性："}}, 
	 {{content = "该部队火箭出战额外增加1%/3%/5%暴击"}}, 
	 {{content = "对火炮克制额外增加5%/10%/15%"}}, 
	 {{content = "  "}}, 
	 {{content = "品质越高，额外属性越高"}}, 
	 {{content = "6个战术取最低品质生效，如4个绿色、1个蓝色、1个紫色战术，兵种套为最低效果"}}
	},

	{{{content = "当激活战术套效果时，若6个战术均为全兵种，可获得额外属性："}}, 
	 {{content = "该部队全兵种出战额外增加1%/3%/5%命中、闪避、暴击、抗暴"}}, 
	 {{content = "  "}}, 
	 {{content = "品质越高，额外属性越高"}}, 
	 {{content = "6个战术取最低品质生效，如4个绿色、1个蓝色、1个紫色战术，兵种套为最低效果"}}
	},
}

DetailText.tactic = {
	{{content = "战术说明"}},
	{{content = "   "}},
	{{content = "战术功能"}},
	{{content = "(1)指挥官45级开启"}},
	{{content = "(2)每个部队出战时可装配6个战术，每种属性的战术最多装配3个"}},
	{{content = "(3)战术在出战时生效"}},
	{{content = "   "}},
	{{content = "战术升级"}},
	{{content = "(1)战术可升级，提升属性；绿/蓝/紫色战术等级上限分别为80/90/100级"}},
	{{content = "(2)从20级开始，每隔10级需要突破才可继续升级，突破需消耗材料和相同的战术碎片"}},
	{{content = "(3)已升级和突破的战术，被用于升级时继承100%经验和80%突破材料和碎片"}},
	{{content = "   "}},
	{{content = "战术克制"}},
	{{content = "(1)战术分4种：强攻、韧性、暴伤、防御"}},
	{{content = "(2)6个战术均为同一种战术时，可激活战术套效果，获得额外属性"}},
	{{content = "(3)战斗开始时，若战术套克制对方，则装配的战术属性额外增加50%"}},
	{{content = "   "}},
	{{content = "兵种套装"}},
	{{content = "(1)战术分5个兵种：坦克、战车、火炮、火箭、全兵种"}},
	{{content = "(2)当激活战术套时，若6个战术为同一兵种，可额外激活兵种套属性"}},
	{{content = "   "}},
	{{content = "属性说明"}},
	{{content = "(1)战术的属性、战术套属性、克制的属性加成对当前部队的所有兵种均生效"}},
	{{content = "(2)兵种套属性只对对应兵种生效"}},
}

DetailText.energyCore = {
	{{content = "1. 熔炼材料与装备，点亮能量原核，激活能源核心，获得属性奖励!"}},
	{{content = "   "}},
	{{content = "2. 点亮能量原核需要注入装备经验。注入经验满足条件后，点亮对应的能量原核并获得对应的属性奖励。点亮每个原核均会获得奖励。"}},
	{{content = "   "}},
	{{content = "3. 多余的装备经验将会被储存，达到下个等级后自动注入。可通过右上方按钮查看存储经验的数量"}},
	{{content = "   "}},
	{{content = "4. 每个等级有四个能量原核，点亮四个能量原核解锁熔炼"}},
	{{content = "   "}},
	{{content = "5. 熔炼需要花费指定的材料。熔炼完成后能源核心等级提升并获得完成奖励。"}},
	{{content = "   "}},
	{{content = "6. 每级能源核心都需要达到前置条件解锁，前置条件与属性奖励可通过详情界面查看。"}},
}

DetailText.formatDetailText = function (formatData, ...)
	-- body
	local result = {}
	local argIndex = 0
	for index = 1, #formatData do
		local strings_format = {}
		local strings = formatData[index]
		for j = 1, #strings do
			local str = strings[j]
			if str.format ~= nil then
				local newStr = {}
				local content = str.content
				local argCount = #str.format

				local params = {}
				for k = 1, argCount do
					table.insert(params, arg[argIndex + k])
				end

				argIndex = argIndex + argCount

				newStr.content = string.format(str.content, unpack(params))

				if str.color then
					newStr.color = str.color
				end

				if str.size then
					newStr.size = str.size
				end
				table.insert(strings_format, newStr)
			else
				table.insert(strings_format, str)
			end
		end
		table.insert(result, strings_format)
	end
	return result
end