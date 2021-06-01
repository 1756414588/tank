package com.account.handle;

import com.account.constant.PlatType;
import com.account.exception.AccountException;
import com.account.plat.PlatBase;
import com.account.plat.Register;
import com.account.plat.impl.afAppstore.AfAppstorePlat;
import com.account.plat.impl.afGhgxsAppstore.AfGhgxsAppstorePlat;
import com.account.plat.impl.afGhgzhAppstore.AfGhgzhAppstorePlat;
import com.account.plat.impl.afJjfz_appstore.AfJjfzAppstorePlat;
import com.account.plat.impl.afJsyd_appstore.AfJsyd_appstorePlat;
import com.account.plat.impl.afLzypAppstore.AfLzypAppstorePlat;
import com.account.plat.impl.afMjdzhAppstore.AfMjdzhAppstorePlat;
import com.account.plat.impl.afNew1Appstore.AfNew1AppstorePlat;
import com.account.plat.impl.afNewAppstore.afNewAppstorePlat;
import com.account.plat.impl.afNewMjdzh1Appstore.AfNewMjdzh1AppstorePlat;
import com.account.plat.impl.afNewMjdzhAppstore.AfNewMjdzhAppstorePlat;
import com.account.plat.impl.afNewTqdknHDappstore.AfNewTqdknHDAppstorePlat;
import com.account.plat.impl.afNewWpzj1Appstore.AfNewWpzj1AppstorePlat;
import com.account.plat.impl.afNewWpzjAppstore.AfNewWpzjAppstorePlat;
import com.account.plat.impl.afSq.AfSqPlat;
import com.account.plat.impl.afSq1.AfSq1Plat;
import com.account.plat.impl.afSq2.AfSq2Plat;
import com.account.plat.impl.afSq3.AfSq3Plat;
import com.account.plat.impl.afTkjs_appstore.AfTkjsAppstorePlat;
import com.account.plat.impl.afTkxjyAppstore.AfTkxjyAppstorePlat;
import com.account.plat.impl.afTqdknAppstore.AfTqdknAppstorePlat;
import com.account.plat.impl.afTqdknHDAppstore.AfTqdknHDAppstorePlat;
import com.account.plat.impl.afWpzjAppstore.AfWpzjAppstorePlat;
import com.account.plat.impl.afWx.AfWxPlat;
import com.account.plat.impl.afWx1.AfWx1Plat;
import com.account.plat.impl.afWx2.AfWx2Plat;
import com.account.plat.impl.afWx3.AfWx3Plat;
import com.account.plat.impl.afXzlmAppstore.AfXzlmAppstorePlat;
import com.account.plat.impl.afghgzh.AfghgzhPlat;
import com.account.plat.impl.aile.AilePlat;
import com.account.plat.impl.anfan.AnfanPlat;
import com.account.plat.impl.anfan1.Anfan1Plat;
import com.account.plat.impl.anfanJh.AnfanJhPlat;
import com.account.plat.impl.anfanSmall.AnfanSmallPlat;
import com.account.plat.impl.anfanTest.AnfanTestPlat;
import com.account.plat.impl.anfanaz.AnfanazPlat;
import com.account.plat.impl.anzhi.AnzhiPlat;
import com.account.plat.impl.baidu.BaiduPlat;
import com.account.plat.impl.baiducl.BaiduclPlat;
import com.account.plat.impl.baiducltkjj.BaiducltkjjPlat;
import com.account.plat.impl.caohua.CaohuaPlat;
import com.account.plat.impl.caohuaEn.CaoHuaEnPlat;
import com.account.plat.impl.caohuaEnAppstore.CaoHuaEnAppstorePlat;
import com.account.plat.impl.caohuanew.CaohuanewPlat;
import com.account.plat.impl.chAppstore.ChAppstorePlat;
import com.account.plat.impl.chCjzjtkzzAppstore.ChCjzjtkzzAppstorePlat;
import com.account.plat.impl.chHj4.ChHj4Plat;
import com.account.plat.impl.chHj4Hw.ChHj4HwPlat;
import com.account.plat.impl.chJhNew.ChJhNewPlat;
import com.account.plat.impl.chJhNew1.ChJhNew1Plat;
import com.account.plat.impl.chJh_hjfc.ChjhHjfcPlat;
import com.account.plat.impl.chQzHjdg.ChQzHjdgPlat;
import com.account.plat.impl.chQzHjsjAppstore.ChQzHjsjAppstorePlat;
import com.account.plat.impl.chQzHjtkzbAppstore.ChQzHjtkzbAppstorePlat;
import com.account.plat.impl.chQzHjtkzc_appstore.ChQzHjtkzcAppstorePlat;
import com.account.plat.impl.chQzJdtk_appstore.ChQzJdtkAppstorePlat;
import com.account.plat.impl.chQzQmtkzb_appstore.ChQzQmtkzbAppstorePlat;
import com.account.plat.impl.chQzQmtkzzAppstore.ChQzQmtkzzAppstorePlat;
import com.account.plat.impl.chQzTkryAppstore.ChQzTkryAppstorePlat;
import com.account.plat.impl.chQzTkzhg_appstore.ChQzTkzhgAppstorePlat;
import com.account.plat.impl.chQzTkzjz_appstore.ChQzTkzjzAppstorePlat;
import com.account.plat.impl.chQzTkzzwzxd_appstore.ChQzTkzzwzxdAppstorePlat;
import com.account.plat.impl.chQzZjldzAppstore.ChQzZjldzAppstorePlat;
import com.account.plat.impl.chQzZzzhg360.ChQzZzzhg_360Plat;
import com.account.plat.impl.chQzZzzhgGionee.ChQzZzzhgGioneePlat;
import com.account.plat.impl.chQzZzzhgMeizu.ChQzZzzhgMeizuPlat;
import com.account.plat.impl.chQzZzzhgSogo.ChQzZzzhgSogoPlat;
import com.account.plat.impl.chQzZzzhgYxf.ChQzZzzhgYxfPlat;
import com.account.plat.impl.chQzZzzhg_baidu.ChQzZzzhgBaiduPlat;
import com.account.plat.impl.chQzZzzhg_caohua.ChQzZzzhgCaoHua;
import com.account.plat.impl.chQzZzzhg_xiaoqi.ChQzZzzhgXiaoQiPlat;
import com.account.plat.impl.chQzZzzhg_yijie.ChQzZzzhgYijiePlat;
import com.account.plat.impl.chSq.ChSqPlat;
import com.account.plat.impl.chSq1.ChSq1Plat;
import com.account.plat.impl.chSq2.ChSq2Plat;
import com.account.plat.impl.chSqWx.ChSqWxPlat;
import com.account.plat.impl.chSqWx2.ChSqWx2Plat;
import com.account.plat.impl.chWx.ChWxPlat;
import com.account.plat.impl.chWx1.ChWx1Plat;
import com.account.plat.impl.chWx2.ChWx2Plat;
import com.account.plat.impl.chYh.ChYhPlat;
import com.account.plat.impl.chYh360.ChYh360Plat;
import com.account.plat.impl.chYhBaidu.ChYhBaiduPlat;
import com.account.plat.impl.chYhCoolpad.ChYhCoolpadPlat;
import com.account.plat.impl.chYhDownjoy.ChYhDownjoyPlat;
import com.account.plat.impl.chYhGp.ChYhGpPlat;
import com.account.plat.impl.chYhHw.ChYhHwPlat;
import com.account.plat.impl.chYhJl.ChYhJlPlat;
import com.account.plat.impl.chYhLenovo.ChYhLenovoPlat;
import com.account.plat.impl.chYhMz.ChYhMzPlat;
import com.account.plat.impl.chYhOppo.ChYhOppoPlat;
import com.account.plat.impl.chYhSq.ChYhSqPlat;
import com.account.plat.impl.chYhSw.ChYhSwPlat;
import com.account.plat.impl.chYhSx.ChYhSxPlat;
import com.account.plat.impl.chYhUc.ChYhUcPlat;
import com.account.plat.impl.chYhWx.ChYhWxPlat;
import com.account.plat.impl.chYhX7.ChYhX7Plat;
import com.account.plat.impl.chYhXm.ChYhXmPlat;
import com.account.plat.impl.chYhYijie.ChYhYijiePlat;
import com.account.plat.impl.chYhYijie1.ChYhYijie1Plat;
import com.account.plat.impl.chYhYijie2.ChYhYijie2Plat;
import com.account.plat.impl.chYhYijieYTK.ChYhYijieYTKPlat;
import com.account.plat.impl.chZjqytkdzAppstore.ChZjqytkdzAppstorePlat;
import com.account.plat.impl.chcjzjAppstore.ChcjzjAppstorePlat;
import com.account.plat.impl.chdgfbAppstore.ChdgfbAppstorePlat;
import com.account.plat.impl.chdgzhgAppstore.ChdgzhgAppstorePlat;
import com.account.plat.impl.chgtfcAppstore.ChgtfcAppstorePlat;
import com.account.plat.impl.chhjfcAppstore.ChhjfcAppstorePlat;
import com.account.plat.impl.chhjfcQhwx.ChhjfcQhwx;
import com.account.plat.impl.chhjfcQy_appstore.ChhjfcQyAppStorePlat;
import com.account.plat.impl.chjxtk_appstore.Chjxtk_appstorePlat;
import com.account.plat.impl.chlhtkAppstore.ChlhtkAppstorePlat;
import com.account.plat.impl.chredtankSq.ChredtankSqPlat;
import com.account.plat.impl.chredtankWx.ChredtankWxPlat;
import com.account.plat.impl.chxsjtAppstore.ChxsjtAppstorePlat;
import com.account.plat.impl.chxz_appstore.ChxzAppstorePlat;
import com.account.plat.impl.chyhgamefanhjfc.ChyhGameFanHjfcPlat;
import com.account.plat.impl.chysdk.ChysdkPlat;
import com.account.plat.impl.chzdjjAppstore.ChzdjjAppstorePlat;
import com.account.plat.impl.chzjqyAppstore.ChzjqyAppstorePlat;
import com.account.plat.impl.chzzzhg1Appstore.Chzzzhg1AppstorePlat;
import com.account.plat.impl.chzzzhg2Appstore.Chzzzhg2AppstorePlat;
import com.account.plat.impl.chzzzhg3Appstore.Chzzzhg3AppstorePlat;
import com.account.plat.impl.chzzzhgAppstore.ChzzzhgAppstorePlat;
import com.account.plat.impl.cmgeAppstore.CmgeAppstorePlat;
import com.account.plat.impl.cmgeen.CmgeEnPlat;
import com.account.plat.impl.downjoy.DownjoyPlat;
import com.account.plat.impl.gameFan.GameFanPlat;
import com.account.plat.impl.haima.HaimaPlat;
import com.account.plat.impl.hiGame.HiGamePlat;
import com.account.plat.impl.hongshouzhi.HongShouZhiPlat;
import com.account.plat.impl.huashuo.HuashuoPlat;
import com.account.plat.impl.ifeng.IfengPlat;
import com.account.plat.impl.inTouch.InTouchPlat;
import com.account.plat.impl.ipay.child.IpayPlat;
import com.account.plat.impl.jqios.JqIosPlat;
import com.account.plat.impl.jrtt.JrttPlat;
import com.account.plat.impl.kaopu.KaopuPlat;
import com.account.plat.impl.leqi.LeqiPlat;
import com.account.plat.impl.meizu.MeizuPlat;
import com.account.plat.impl.mi.MiPlat;
import com.account.plat.impl.muzhi.MuzhiPlat;
import com.account.plat.impl.muzhi1.Muzhi1Plat;
import com.account.plat.impl.muzhi1001.Muzhi1001Plat;
import com.account.plat.impl.muzhi1002.Muzhi1002Plat;
import com.account.plat.impl.muzhi1003.Muzhi1003Plat;
import com.account.plat.impl.muzhi1004.Muzhi1004Plat;
import com.account.plat.impl.muzhi1005.Muzhi1005Plat;
import com.account.plat.impl.muzhi1006.Muzhi1006Plat;
import com.account.plat.impl.muzhi1007.Muzhi1007Plat;
import com.account.plat.impl.muzhi1008.Muzhi1008Plat;
import com.account.plat.impl.muzhi1009.Muzhi1009Plat;
import com.account.plat.impl.muzhi1010.Muzhi1010Plat;
import com.account.plat.impl.muzhi49.Muzhi49Plat;
import com.account.plat.impl.muzhi93.Muzhi93Plat;
import com.account.plat.impl.muzhiEn.MuzhiEnPlat;
import com.account.plat.impl.muzhiJh.MuzhiJhPlat;
import com.account.plat.impl.muzhiJhYlfc.MuZhiJhYlfcPlat;
import com.account.plat.impl.muzhiJhYyb.MuzhiJhYybPlat;
import com.account.plat.impl.muzhiJhYyb1.MuzhiJhYyb1Plat;
import com.account.plat.impl.muzhiJhly.MuzhiJhlyPlat;
import com.account.plat.impl.muzhiLy.MuzhiLyPlat;
import com.account.plat.impl.muzhiM1.MuzhiM1Plat;
import com.account.plat.impl.muzhiM2.MuzhiM2Plat;
import com.account.plat.impl.muzhiTkjj.MuzhiTkjjPlat;
import com.account.plat.impl.muzhiU8ly.MuzhiU8lyPlat;
import com.account.plat.impl.mzAppstore.MzAppstorePlat;
import com.account.plat.impl.mzDgjq_appstore.MzDgjqAppstorePlat;
import com.account.plat.impl.mzGhgzhAppstore.MzGhgzhAppstorePlat;
import com.account.plat.impl.mzHjxd_appstore.MzHjxdAppstorePlat;
import com.account.plat.impl.mzHjylgl_appstore.MzHjylglAppstorePlat;
import com.account.plat.impl.mzHsTkzz_appstore.MzHsTkzzAppstorePlat;
import com.account.plat.impl.mzHsbwz_appstore.MzHsbwzAppstorePlat;
import com.account.plat.impl.mzHszzjj_appstore.MzHszzjjAppstorePlat;
import com.account.plat.impl.mzIntouch.MzIntouchPlat;
import com.account.plat.impl.mzLzwzAppstore.MzLzwzAppstorePlat;
import com.account.plat.impl.mzSq1.MzSq1Plat;
import com.account.plat.impl.mzSq2.MzSq2Plat;
import com.account.plat.impl.mzSq3.MzSq3Plat;
import com.account.plat.impl.mzTkbtdz_appstore.MzTkbtdzAppstorePlat;
import com.account.plat.impl.mzTkbwz_appstore.MzTkbwzAppstorePlat;
import com.account.plat.impl.mzTkfb_appstore.MuZhiDgzzsdAppstorePlat;
import com.account.plat.impl.mzTkhslx_appstore.MzTkhslxAppstorePlat;
import com.account.plat.impl.mzTkjjQy_appstore.MzTkjjQyAppstorePlat;
import com.account.plat.impl.mzTksjdz_appstore.MzTksjdzAppstorePlat;
import com.account.plat.impl.mzUnicom.MzUnicomPlat;
import com.account.plat.impl.mzWx1.MzWx1Plat;
import com.account.plat.impl.mzWx2.MzWx2Plat;
import com.account.plat.impl.mzWx3.MzWx3Plat;
import com.account.plat.impl.mzXmlyAppstore.MzXmlyAppstorePlat;
import com.account.plat.impl.mzYiwanCyzcAppstore.MzYiwanCyzcAppstorePlat;
import com.account.plat.impl.mzZjhwd_appstore.MzZjhwdAppstorePlat;
import com.account.plat.impl.mzZztx_appstore.MzZztxAppstorePlat;
import com.account.plat.impl.mzaqgtdgAppstore.MzaqgtdgAppstorePlat;
import com.account.plat.impl.mzaqhszzAppstore.MzaqhszzAppstorePlat;
import com.account.plat.impl.mzaqhxzzAppstore.MzaqhxzzAppstorePlat;
import com.account.plat.impl.mzaqtkjtAppstore.MzaqtkjtAppstorePlat;
import com.account.plat.impl.mzaqzbshjAppstore.MzaqzbshjAppstorePlat;
import com.account.plat.impl.mzaqzzfyAppstore.MzaqzzfyAppstorePlat;
import com.account.plat.impl.mzenAppstore.MzenAppstorePlat;
import com.account.plat.impl.mzeztkAppstore.MzeztkAppstorePlat;
import com.account.plat.impl.mzjttx_appstore.MzzjTtxAppstorePlat;
import com.account.plat.impl.mzlyhtc.MzlyhtcPlat;
import com.account.plat.impl.mztkdgAppstore.MztkdgAppstorePlat;
import com.account.plat.impl.mztkjjAppstore.MztkjjAppstorePlat;
import com.account.plat.impl.mztkjjhwcnAppstore.MztkjjhwcnAppstorePlat;
import com.account.plat.impl.mztkjjylfcAppstore.MztkjjylfcAppstorePlat;
import com.account.plat.impl.mztkwcAppstore.MztkwcAppstorePlat;
import com.account.plat.impl.mztkwz.MztkwzPlat;
import com.account.plat.impl.mztkwzAppstore.MztkwzAppstorePlat;
import com.account.plat.impl.mzusfun.MzusfunPlat;
import com.account.plat.impl.mzvertify.MzvertifyPlat;
import com.account.plat.impl.mzw.MzwPlat;
import com.account.plat.impl.nhdz.NhdzPlat;
import com.account.plat.impl.oppo.OppoPlat;
import com.account.plat.impl.pengy.PengyPlat;
import com.account.plat.impl.play68.Play68Plat;
import com.account.plat.impl.play68Appstore.Play68AppstorePlat;
import com.account.plat.impl.pptv.PptvPlat;
import com.account.plat.impl.qh360.Qh360Plat;
import com.account.plat.impl.qihu.QihuPlat;
import com.account.plat.impl.qmyxzs.QmyxzsPlat;
import com.account.plat.impl.self.SelfPlat;
import com.account.plat.impl.selfIos.SelfIosPlat;
import com.account.plat.impl.sogou.SogouPlat;
import com.account.plat.impl.sq.SqPlat;
import com.account.plat.impl.ssjj.SsjjPlat;
import com.account.plat.impl.tt.TTPlat;
import com.account.plat.impl.ttyy.TtyyPlat;
import com.account.plat.impl.uc.UcPlat;
import com.account.plat.impl.vivo.VivoPlat;
import com.account.plat.impl.wan.WanPlat;
import com.account.plat.impl.wandoujianew.WdjNewPlat;
import com.account.plat.impl.weiuu.WeiuuPlat;
import com.account.plat.impl.wx.WeixinPlat;
import com.account.plat.impl.youlong.YouLongPlat;
import com.account.plat.impl.youlongteng.YoulongtengPlat;
import com.account.plat.impl.yoyou.YoyouPlat;
import com.account.plat.impl.yyh.YyhPlat;
import com.account.plat.impl.zhuoyou.ZhuoyouPlat;
import org.springframework.context.support.ApplicationObjectSupport;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

public class PlatHandle extends ApplicationObjectSupport {
    private Map<String, PlatBase> platBump;

    private Map<Integer, PlatBase> platNoMap;

    private Set<Integer> recordRolePlatNoSet;

    private Set<Integer> actionPointPlatNoSet;

    private Map<String, Register> registerBump;

    private Set<Integer> yBPayCallBackPlatNoSet;

    public void init() {
        platBump = new HashMap<String, PlatBase>();
        platNoMap = new HashMap<Integer, PlatBase>();
        recordRolePlatNoSet = new HashSet<Integer>();
        actionPointPlatNoSet = new HashSet<Integer>();
        registerBump = new HashMap<>();
        yBPayCallBackPlatNoSet = new HashSet<Integer>();
        addRecordRolePlat();
        addActionPointPlat();
        addyBPayCallBackPlat();
        this.addPlat();
    }

    private void addRecordRolePlat() {
        recordRolePlatNoSet.add(1);// self
        recordRolePlatNoSet.add(81);// 拇指
        recordRolePlatNoSet.add(501);// 拇指APPstore
        recordRolePlatNoSet.add(80);// 安峰
        recordRolePlatNoSet.add(87);// 安峰手Q
        recordRolePlatNoSet.add(88);// 安峰微信
        recordRolePlatNoSet.add(89);// 安峰手Q
        recordRolePlatNoSet.add(90);// 安峰微信
        recordRolePlatNoSet.add(91);// 安峰1
        recordRolePlatNoSet.add(95);// 安峰store
        recordRolePlatNoSet.add(96);// 安峰手Q2
        recordRolePlatNoSet.add(97);// 安峰微信2
        recordRolePlatNoSet.add(126);// 安峰微信3
        recordRolePlatNoSet.add(129);// 安峰
        recordRolePlatNoSet.add(132);// 安峰聚合
        recordRolePlatNoSet.add(145);// 安峰安智 天启的狂怒
        recordRolePlatNoSet.add(164);// 安峰测试
        recordRolePlatNoSet.add(165);// 安峰 共和国之辉 账号与80互通
        recordRolePlatNoSet.add(162);//
        recordRolePlatNoSet.add(508);// 安峰APPstore：坦克新纪元
        recordRolePlatNoSet.add(529);// 安峰IOS 共和国雄狮 账号与95互通
        recordRolePlatNoSet.add(530);// 安峰IOS 盟军的召唤
        recordRolePlatNoSet.add(531);// 安峰IOS 王牌战警
        recordRolePlatNoSet.add(532);// 安峰IOS 天启的狂怒（新） 账号与95互通
        recordRolePlatNoSet.add(533);// 安峰IOS 血战黎明 账号与95互通
        recordRolePlatNoSet.add(536);// 安峰IOS 共和国之徽 账号与95互通
        recordRolePlatNoSet.add(540);// 安峰IOS 天启的狂怒HD 账号与95互通
        recordRolePlatNoSet.add(542);// 安峰ios 账号与95互通

    }

    private void addActionPointPlat() {
        actionPointPlatNoSet.add(1);// self
        actionPointPlatNoSet.add(152); // 中手游 az
        actionPointPlatNoSet.add(522); // 中手游 ios

    }

    private void addyBPayCallBackPlat() {
        yBPayCallBackPlatNoSet.add(1);// self
        yBPayCallBackPlatNoSet.add(80);// 安峰
        yBPayCallBackPlatNoSet.add(87);// 安峰手Q
        yBPayCallBackPlatNoSet.add(88);// 安峰微信
        yBPayCallBackPlatNoSet.add(89);// 安峰手Q
        yBPayCallBackPlatNoSet.add(90);// 安峰微信
        yBPayCallBackPlatNoSet.add(91);// 安峰1
        yBPayCallBackPlatNoSet.add(95);// 安峰store
        yBPayCallBackPlatNoSet.add(96);// 安峰手Q2
        yBPayCallBackPlatNoSet.add(97);// 安峰微信2
        yBPayCallBackPlatNoSet.add(126);// 安峰微信3
        yBPayCallBackPlatNoSet.add(129);// 安峰
        yBPayCallBackPlatNoSet.add(132);// 安峰聚合
        yBPayCallBackPlatNoSet.add(145);// 安峰安智 天启的狂怒
        yBPayCallBackPlatNoSet.add(164);// 安峰测试
        yBPayCallBackPlatNoSet.add(165);// 安峰 共和国之辉 账号与80互通
        yBPayCallBackPlatNoSet.add(508);// 安峰APPstore：坦克新纪元
        yBPayCallBackPlatNoSet.add(529);// 安峰IOS 共和国雄狮 账号与95互通
        yBPayCallBackPlatNoSet.add(530);// 安峰IOS 盟军的召唤
        yBPayCallBackPlatNoSet.add(531);// 安峰IOS 王牌战警
        yBPayCallBackPlatNoSet.add(532);// 安峰IOS 天启的狂怒（新） 账号与95互通
        yBPayCallBackPlatNoSet.add(533);// 安峰IOS 血战黎明 账号与95互通
        yBPayCallBackPlatNoSet.add(536);// 安峰IOS 共和国之徽 账号与95互通
        yBPayCallBackPlatNoSet.add(540);// 安峰IOS 天启的狂怒HD 账号与95互通
        yBPayCallBackPlatNoSet.add(542);// 安峰ios 账号与95互通
    }

    private void addPlat() {
        registerPlat("self", 1, SelfPlat.class, "SelfPlat", PlatType.ALL);
        registerSelfPlat("self", SelfPlat.class);
        registerPlat("ipay", 3, IpayPlat.class, "IpayPlat", PlatType.OTHER);
        registerSelfPlat("ipay", IpayPlat.class);
        registerPlat("oppo", 5, OppoPlat.class, "OppoPlat", PlatType.LIANYUN);

        registerPlat("qihu", 6, QihuPlat.class, "QihuPlat", PlatType.OTHER);

        registerPlat("mi", 7, MiPlat.class, "MiPlat", PlatType.LIANYUN);
        // registerPlat("n_uc",13,NewUcPlat.class,"NewUcPlat");
        registerPlat("self_ios", 21, SelfIosPlat.class, "SelfIosPlat", PlatType.ALL);
        registerSelfPlat("self_ios", SelfIosPlat.class);
        registerPlat("anfan", 80, AnfanPlat.class, "安峰", PlatType.HUNFU);
        registerPlat("muzhi", 81, MuzhiPlat.class, "拇指", PlatType.HUNFU);
        registerPlat("caohua", 82, CaohuaPlat.class, "草花", PlatType.HUNFU);
        registerPlat("shouq", 83, SqPlat.class, "拇指手Q", PlatType.HUNFU);
        registerPlat("weixin", 84, WeixinPlat.class, "拇指微信", PlatType.HUNFU);
        registerPlat("chSq", 85, ChSqPlat.class, "草花手Q", PlatType.HUNFU);
        registerPlat("chWx", 86, ChWxPlat.class, "草花微信", PlatType.HUNFU);
        registerPlat("afSq", 87, AfSqPlat.class, "安峰手Q", PlatType.HUNFU);
        registerPlat("afWx", 88, AfWxPlat.class, "安峰微信", PlatType.HUNFU);
        registerPlat("afSq1", 89, AfSq1Plat.class, "安峰手Q", PlatType.HUNFU);
        registerPlat("afWx1", 90, AfWx1Plat.class, "安峰微信", PlatType.HUNFU);
        registerPlat("anfan1", 91, Anfan1Plat.class, "安峰1", PlatType.HUNFU);
        registerPlat("mzSq1", 92, MzSq1Plat.class, "拇指手Q1", PlatType.HUNFU);
        registerPlat("mzWx1", 93, MzWx1Plat.class, "拇指微信1", PlatType.HUNFU);
        registerPlat("ch_appstore", 94, ChAppstorePlat.class, "草花store", PlatType.HUNFU);
        registerPlat("af_appstore", 95, AfAppstorePlat.class, "安峰store", PlatType.HUNFU);
        registerPlat("afSq2", 96, AfSq2Plat.class, "安峰手Q2", PlatType.HUNFU);
        registerPlat("afWx2", 97, AfWx2Plat.class, "安峰微信2", PlatType.HUNFU);
        registerPlat("weiuu", 98, WeiuuPlat.class, "微游汇", PlatType.LIANYUN);
        registerPlat("meizhu", 99, MeizuPlat.class, "魅族", PlatType.LIANYUN);
        registerPlat("baidu", 100, BaiduPlat.class, "百度", PlatType.LIANYUN);
        registerPlat("anzhi", 101, AnzhiPlat.class, "安智", PlatType.LIANYUN);
        registerPlat("sogou", 102, SogouPlat.class, "搜狗", PlatType.LIANYUN);
        registerPlat("n_uc", 103, UcPlat.class, "uc", PlatType.LIANYUN);
        registerPlat("37wan", 104, WanPlat.class, "37玩", PlatType.LIANYUN);
        registerPlat("downjoy", 105, DownjoyPlat.class, "当乐", PlatType.LIANYUN);
        registerPlat("pyw", 106, PengyPlat.class, "朋友", PlatType.LIANYUN);
        registerPlat("mzw", 107, MzwPlat.class, "拇指玩", PlatType.LIANYUN);
        registerPlat("pptv", 108, PptvPlat.class, "pptv", PlatType.LIANYUN);
        registerPlat("jrtt", 109, JrttPlat.class, "今日头条", PlatType.LIANYUN);
        registerPlat("nhdz", 110, NhdzPlat.class, "内涵段子", PlatType.LIANYUN);
        registerPlat("haima", 111, HaimaPlat.class, "海马", PlatType.LIANYUN);
        registerPlat("huashuo", 112, HuashuoPlat.class, "华硕", PlatType.LIANYUN);
        registerPlat("ttyy", 113, TtyyPlat.class, "天天语音", PlatType.LIANYUN);
        registerPlat("kpzs", 114, KaopuPlat.class, "靠谱助手", PlatType.LIANYUN);
        registerPlat("qmyxzs", 115, QmyxzsPlat.class, "全民游戏助手", PlatType.OTHER);
        registerPlat("zhuoyou", 116, ZhuoyouPlat.class, "卓游", PlatType.LIANYUN);
        registerPlat("yyh", 117, YyhPlat.class, "应用汇", PlatType.LIANYUN);
        registerPlat("360", 118, Qh360Plat.class, "360", PlatType.LIANYUN);
        registerPlat("mzSq2", 119, MzSq2Plat.class, "拇指手Q2", PlatType.LIANYUN);
        registerPlat("mzWx2", 120, MzWx2Plat.class, "拇指微信2", PlatType.LIANYUN);
        registerPlat("chYh", 121, ChYhPlat.class, "草花硬核", PlatType.HUNFU);
        registerPlat("mzSq3", 122, MzSq3Plat.class, "拇指手Q3", PlatType.HUNFU);
        registerPlat("mzWx3", 123, MzWx3Plat.class, "拇指微信3", PlatType.HUNFU);
        registerPlat("wdj", 124, WdjNewPlat.class, "豌豆荚", PlatType.LIANYUN);
        registerPlat("afSq3", 125, AfSq3Plat.class, "安峰手Q3", PlatType.HUNFU);
        registerPlat("afWx3", 126, AfWx3Plat.class, "安峰微信3", PlatType.HUNFU);
        registerPlat("muzhiJh", 127, MuzhiJhPlat.class, "拇指聚合", PlatType.HUNFU);
        registerPlat("chHj4", 128, ChHj4Plat.class, "草花HJ4", PlatType.YINGHE);
        registerPlat("anfanSmall", 129, AnfanSmallPlat.class, "安峰", PlatType.HUNFU);
        registerPlat("chSq1", 130, ChSq1Plat.class, "草花手Q", PlatType.YINGHE);
        registerPlat("chWx1", 131, ChWx1Plat.class, "草花微信", PlatType.YINGHE);
        registerPlat("anfanJh", 132, AnfanJhPlat.class, "安峰聚合", PlatType.HUNFU);
        registerPlat("ylt", 133, YoulongtengPlat.class, "海外游龙腾", PlatType.OVERSEAS);
        registerPlat("muzhi49", 134, Muzhi49Plat.class, "拇指49平台", PlatType.HUNFU);
        registerPlat("muzhi93", 135, Muzhi93Plat.class, "93平台", PlatType.HUNFU);
        registerPlat("mztkwz", 136, MztkwzPlat.class, "拇指坦克武装Android", PlatType.HUNFU);
        registerPlat("muzhiJhly", 137, MuzhiJhlyPlat.class, "拇指聚合联运", PlatType.HUNFU);
        registerPlat("chSq2", 138, ChSq2Plat.class, "草花手Q2", PlatType.HUNFU);
        registerPlat("chWx2", 139, ChWx2Plat.class, "草花微信2", PlatType.HUNFU);
        registerPlat("muzhily", 140, MuzhiLyPlat.class, "拇指sdk联运", PlatType.LIANYUN);
        registerPlat("baiducl", 141, BaiduclPlat.class, "百度采量", PlatType.HUNFU);
        registerPlat("tt", 142, TTPlat.class, "TT语音《红警：共和国之辉》", PlatType.HUNFU);
        registerPlat("baiducltkjj", 143, BaiducltkjjPlat.class, "坦克警戒百度采量", PlatType.LIANYUN);
        registerPlat("leqi", 144, LeqiPlat.class, "乐7", PlatType.HUNFU);
        registerPlat("anfanaz", 145, AnfanazPlat.class, "安峰安智天启的狂怒", PlatType.HUNFU);
        registerPlat("mzyw", 146, InTouchPlat.class, "拇指海外inTouch", PlatType.OVERSEAS);
        registerPlat("yoYou", 147, YoyouPlat.class, "快游天启的狂怒", PlatType.HUNFU);
        registerPlat("chSqWx", 148, ChSqWxPlat.class, "草花手Q微信支付渠道", PlatType.OTHER);
        registerPlat("ifeng", 149, IfengPlat.class, "凤凰网", PlatType.LIANYUN);
        registerPlat("caohuanew", 150, CaohuanewPlat.class, "新草花", PlatType.HUNFU);
        registerPlat("68play", 151, Play68Plat.class, "台湾68play", PlatType.OTHER);
        registerPlat("cmgeEn", 152, CmgeEnPlat.class, "中手游英文版", PlatType.OVERSEAS);
        registerPlat("chSqWx2", 153, ChSqWx2Plat.class, "草花手Q微信2支付渠道", PlatType.OTHER);
        registerPlat("gameFan", 154, GameFanPlat.class, "游戏Fan", PlatType.HUNFU);
        registerPlat("muzhiEn", 155, MuzhiEnPlat.class, "拇指安卓英文版", PlatType.OVERSEAS);
        registerPlat("mzwM1", 156, MuzhiM1Plat.class, "拇指红警：共和国之辉", PlatType.HUNFU);
        registerPlat("mzwM2", 157, MuzhiM2Plat.class, "拇指坦克警戒", PlatType.HUNFU);
        registerPlat("muzhiU8ly", 158, MuzhiU8lyPlat.class, "拇指坦克警戒聚合联运", PlatType.LIANYUN);
        registerPlat("muzhiJhYyb", 159, MuzhiJhYybPlat.class, "拇指聚合应用宝混服", PlatType.HUNFU);
        registerPlat("aile", 160, AilePlat.class, "爱乐游戏", PlatType.LIANYUN);
        registerPlat("hongshouzhi", 161, HongShouZhiPlat.class, "红手指", PlatType.YINGHE);
        registerPlat("muzhiTkjj", 162, MuzhiTkjjPlat.class, "拇指SDK安卓坦克警戒", PlatType.HUNFU);
        registerPlat("youlong", 163, YouLongPlat.class, "游龙", PlatType.LIANYUN);
        registerPlat("anfanTest", 164, AnfanTestPlat.class, "安峰测试", PlatType.HUNFU);
        registerPlat("afghgzh", 165, AfghgzhPlat.class, "安峰共和国之辉账号与80互通", PlatType.HUNFU);
        registerPlat("chredtankSq", 166, ChredtankSqPlat.class, "草花红色坦克手Q", PlatType.HUNFU);
        registerPlat("chredtankWx", 167, ChredtankWxPlat.class, "草花红色坦克微信", PlatType.HUNFU);
        registerPlat("chYh360", 168, ChYh360Plat.class, "草花硬核360", PlatType.YINGHE);
        registerPlat("chYhBaidu", 169, ChYhBaiduPlat.class, "草花硬核百度", PlatType.YINGHE);
        registerPlat("chYhXm", 170, ChYhXmPlat.class, "草花硬核小米", PlatType.YINGHE);
        registerPlat("chYhHw", 171, ChYhHwPlat.class, "草花硬核华为", PlatType.YINGHE);
        registerPlat("chYhOppo", 172, ChYhOppoPlat.class, "草花硬核oppo", PlatType.YINGHE);
        registerPlat("chYhMz", 173, ChYhMzPlat.class, "草花硬核魅族", PlatType.YINGHE);
        registerPlat("chYhGp", 174, ChYhGpPlat.class, "草花硬核果盘", PlatType.YINGHE);
        registerPlat("chYhSw", 175, ChYhSwPlat.class, "草花硬核顺网", PlatType.YINGHE);
        registerPlat("chYhUc", 176, ChYhUcPlat.class, "草花硬核UC", PlatType.YINGHE);
        registerPlat("chYhSq", 177, ChYhSqPlat.class, "草花硬核手Q", PlatType.YINGHE);
        registerPlat("chYhWx", 178, ChYhWxPlat.class, "草花硬核微信", PlatType.YINGHE);
        registerPlat("mzIntouch", 179, MzIntouchPlat.class, "拇指Intouch", PlatType.OTHER);
        registerPlat("chYhCoolpad", 180, ChYhCoolpadPlat.class, "草花硬核酷派", PlatType.YINGHE);
        registerPlat("chYhJl", 181, ChYhJlPlat.class, "草花硬核金立", PlatType.YINGHE);
        registerPlat("chYhLx", 182, ChYhLenovoPlat.class, "草花硬核联想", PlatType.YINGHE);
        registerPlat("chYhXq", 183, ChYhX7Plat.class, "草花硬核小7", PlatType.YINGHE);
        registerPlat("chYhDl", 184, ChYhDownjoyPlat.class, "草花硬核当乐", PlatType.YINGHE);
        registerPlat("muzhiJhYyb1", 185, MuzhiJhYyb1Plat.class, "拇指聚合新应用宝", PlatType.HUNFU);
        registerPlat("chYhSx", 186, ChYhSxPlat.class, "草花硬核三星", PlatType.YINGHE);
        registerPlat("hiGame", 187, HiGamePlat.class, "海外英文版HiGame", PlatType.OVERSEAS);
        registerPlat("mzlyhtc", 188, MzlyhtcPlat.class, "HTC", PlatType.LIANYUN);
        registerPlat("mzvertify", 189, MzvertifyPlat.class, "拇指坦克警戒测试", PlatType.HUNFU);
        registerPlat("ssjj", 190, SsjjPlat.class, "小米", PlatType.OTHER);
        registerPlat("chHj4Hw", 191, ChHj4HwPlat.class, "草花硬核-[红警4-英雄复仇]华为渠道", PlatType.YINGHE);
        registerPlat("chysdk", 192, ChysdkPlat.class, "草花手游YSDK测试包", PlatType.HUNFU);
        registerPlat("mzusfun", 193, MzusfunPlat.class, "拇指安卓英文版", PlatType.OVERSEAS);
        registerPlat("chYhYijie", 194, ChYhYijiePlat.class, "草花硬核-红警复仇-易接", PlatType.YINGHE);
        registerPlat("caohuaEn", 195, CaoHuaEnPlat.class, "草花手游海外SDK【CP对接】", PlatType.OVERSEAS);
        registerPlat("chYhYijie1", 196, ChYhYijie1Plat.class, "草花硬核-红警复仇-易接新", PlatType.YINGHE);
        registerPlat("muzhiJhYlfc", 197, MuZhiJhYlfcPlat.class, "拇指聚合尤里的复仇", PlatType.HUNFU);
        registerPlat("muzhi1", 198, Muzhi1Plat.class, "拇指i官网包起义时刻", PlatType.HUNFU);
        registerPlat("muzhi1001", 199, Muzhi1001Plat.class, "拇指起义时刻买量包199", PlatType.HUNFU);
        registerPlat("muzhi1002", 200, Muzhi1002Plat.class, "拇指起义时刻买量包200", PlatType.HUNFU);
        registerPlat("muzhi1003", 201, Muzhi1003Plat.class, "拇指起义时刻买量包201", PlatType.HUNFU);
        registerPlat("muzhi1004", 202, Muzhi1004Plat.class, "拇指起义时刻买量包202", PlatType.HUNFU);
        registerPlat("muzhi1005", 203, Muzhi1005Plat.class, "拇指起义时刻买量包203", PlatType.HUNFU);
        registerPlat("muzhi1006", 204, Muzhi1006Plat.class, "拇指起义时刻买量包204", PlatType.HUNFU);
        registerPlat("muzhi1007", 205, Muzhi1007Plat.class, "拇指起义时刻买量包205", PlatType.HUNFU);
        registerPlat("muzhi1008", 206, Muzhi1008Plat.class, "拇指起义时刻买量包206", PlatType.HUNFU);
        registerPlat("muzhi1009", 207, Muzhi1009Plat.class, "拇指起义时刻买量包207", PlatType.HUNFU);
        registerPlat("muzhi1010", 208, Muzhi1010Plat.class, "拇指起义时刻买量包208", PlatType.HUNFU);
        registerPlat("chYhYijieYTK", 209, ChYhYijieYTKPlat.class, "草花仟指云天空（易接SDK母包）", PlatType.YINGHE);
        registerPlat("chYhVivo", 210, VivoPlat.class, "【草花硬核】仟指-《红警复仇》VIVO", PlatType.YINGHE);
        registerPlat("chJhNew", 211, ChJhNewPlat.class, "草花新版中间件参数和SDK文档稍后发你", PlatType.HUNFU);
        registerPlat("afJjfz_appstore", 212, AfJjfzAppstorePlat.class, "安峰IOS机甲纷争", PlatType.HUNFU);
        registerPlat("afTkjs_appstore", 213, AfTkjsAppstorePlat.class, "安峰IOS坦克机师", PlatType.HUNFU);
        registerPlat("chJhNew1", 214, ChJhNew1Plat.class, "草花硬核新中间件母包1", PlatType.HUNFU);
        registerPlat("chQzZzzhg_xiaoqi", 215, ChQzZzzhgXiaoQiPlat.class, "草花仟指战争指挥官--小七chQzZzzhg_xiaoqi215", PlatType.HUNFU);
        registerPlat("chQzZzzhg_yijie", 216, ChQzZzzhgYijiePlat.class, "草花仟指战争指挥官--易接chQzZzzhg_yijie216", PlatType.HUNFU);
        registerPlat("chQzZzzhg_360", 217, ChQzZzzhg_360Plat.class, "草花仟指战争指挥官--360chQzZzzhg_360217", PlatType.HUNFU);
        registerPlat("chQzZzzhg_meizu", 218, ChQzZzzhgMeizuPlat.class, "草花仟指战争指挥官--魅族chQzZzzhg_meizu218", PlatType.HUNFU);
        registerPlat("chQzZzzhg_gionee", 219, ChQzZzzhgGioneePlat.class, "草花仟指战争指挥官--金立chQzZzzhg_gionee219", PlatType.HUNFU);
        registerPlat("chQzZzzhg_yxf", 220, ChQzZzzhgYxfPlat.class, "草花仟指战争指挥官--游戏fanchQzZzzhg_yxf220", PlatType.HUNFU);
        registerPlat("chQzZzzhg_baidu", 221, ChQzZzzhgBaiduPlat.class, "草花仟指战争指挥官--百度chQzZzzhg_baidu221", PlatType.HUNFU);
        registerPlat("chQzZzzhg_sougou", 222, ChQzZzzhgSogoPlat.class, "草花仟指战争指挥官--搜狗chQzZzzhg_sogo222", PlatType.HUNFU);
        registerPlat("mzUnicom", 223, MzUnicomPlat.class, "拇指联通", PlatType.LIANYUN);
        registerPlat("caohuaNewZjj", 224, ChQzZzzhgCaoHua.class, "草花《战争指挥官》主包中间件", PlatType.HUNFU);
        registerPlat("chYhYijie2", 225, ChYhYijie2Plat.class, "红警4-英雄复仇2", PlatType.YINGHE);
        registerPlat("chyh_hjfc", 226, ChjhHjfcPlat.class, "【草花硬核】英雄复仇-玩嗨", PlatType.YINGHE);
        registerPlat("chyh_gamefan_hjfc", 227, ChyhGameFanHjfcPlat.class, "【草花硬核】红警复仇", PlatType.YINGHE);
        registerPlat("chhjfc_qhwx", 228, ChhjfcQhwx.class, "红警4-英雄复仇", PlatType.YINGHE);




        registerPlat("mz_appstore", 501, MzAppstorePlat.class, "拇指APPstore", PlatType.HUNFU);
        registerPlat("chlhtk_appstore", 502, ChlhtkAppstorePlat.class, "草花lhtkAPPstore", PlatType.HUNFU);
        registerPlat("mztkwz_appstore", 503, MztkwzAppstorePlat.class, "拇指坦克武装APPstore", PlatType.HUNFU);
        registerPlat("mztkdg_appstore", 504, MztkdgAppstorePlat.class, "拇指坦克帝国：重器APPstore", PlatType.HUNFU);
        registerPlat("mzeztk_appstore", 505, MzeztkAppstorePlat.class, "拇指二战坦克APPstore", PlatType.HUNFU);
        registerPlat("mztkwc_appstore", 506, MztkwcAppstorePlat.class, "拇指坦克围城APPstore", PlatType.HUNFU);
        registerPlat("mztkjj_appstore", 507, MztkjjAppstorePlat.class, "拇指坦克警戒：重返战场APPstore", PlatType.HUNFU);
        registerPlat("afTkxjy_appstore", 508, AfTkxjyAppstorePlat.class, "安峰APPstore：坦克新纪元", PlatType.HUNFU);
        registerPlat("mztkjjylfc_appstore", 509, MztkjjylfcAppstorePlat.class, "拇指坦克appStroe:坦克警戒尤里复仇", PlatType.OTHER);
        registerPlat("chdgzhg_appstore", 510, ChdgzhgAppstorePlat.class, "草花帝国指挥官APPstore", PlatType.HUNFU);
        registerPlat("mztkjjhwcn_appstore", 511, MztkjjhwcnAppstorePlat.class, "拇指坦克appStroe:坦克警戒海外简体中文", PlatType.OVERSEAS);
        registerPlat("chjxtk_appstore", 512, Chjxtk_appstorePlat.class, "草花极限坦克", PlatType.HUNFU);
        registerPlat("chcjzj_appstore", 513, ChcjzjAppstorePlat.class, "草花IOS超级装甲", PlatType.HUNFU);
        registerPlat("chxsjt_appstore", 514, ChxsjtAppstorePlat.class, "草花IOS血色军团", PlatType.HUNFU);
        registerPlat("mzen_appstore", 515, MzenAppstorePlat.class, "坦克拇指海外英文版新增渠道", PlatType.OVERSEAS);
        registerPlat("chgtfc_appstore", 516, ChgtfcAppstorePlat.class, "草花IOS钢铁复仇", PlatType.HUNFU);
        registerPlat("chzdjj_appstore", 517, ChzdjjAppstorePlat.class, "草花IOS战地警戒", PlatType.HUNFU);
        registerPlat("chdgfb_appstore", 518, ChdgfbAppstorePlat.class, "草花IOS帝国风暴（战争指挥官CPS包）", PlatType.HUNFU);
        registerPlat("chzjqy_appstore", 519, ChzjqyAppstorePlat.class, "草花IOS装甲起源", PlatType.HUNFU);
        registerPlat("mzAqHszz_appstore", 520, MzaqhszzAppstorePlat.class, "拇指IOS安趣坦克·红色战争", PlatType.HUNFU);
        registerPlat("mzAqTkjt_appstore", 521, MzaqtkjtAppstorePlat.class, "拇指IOS安趣红警坦克军团", PlatType.HUNFU);
        registerPlat("cmge_appstore", 522, CmgeAppstorePlat.class, "中手游IOS英文版", PlatType.OVERSEAS);
        registerPlat("mzXmly_appstore", 523, MzXmlyAppstorePlat.class, "拇指喜马拉雅IOS", PlatType.HUNFU);
        registerPlat("mzAqGtdg_appstore", 524, MzaqgtdgAppstorePlat.class, "拇指IOS安趣坦克•钢铁帝国", PlatType.HUNFU);
        registerPlat("mzAqHxzz_appstore", 525, MzaqhxzzAppstorePlat.class, "拇指IOS安趣坦克•火线战争", PlatType.HUNFU);
        registerPlat("mzAqZbshj_appstore", 526, MzaqzbshjAppstorePlat.class, "拇指IOS安趣这不是红警", PlatType.HUNFU);
        registerPlat("mzAqZzfy_appstore", 527, MzaqzzfyAppstorePlat.class, "拇指IOS安趣战争风云", PlatType.HUNFU);
        registerPlat("chzzzhg_appstore", 528, ChzzzhgAppstorePlat.class, "草花IOS战争指挥官-跨服团战", PlatType.HUNFU);
        registerPlat("afGhgxs_appstore", 529, AfGhgxsAppstorePlat.class, "安峰IOS共和国+雄狮账号与95互通", PlatType.HUNFU);
        registerPlat("afMjdzh_appstore", 530, AfMjdzhAppstorePlat.class, "安峰IOS盟军的召唤", PlatType.HUNFU);
        registerPlat("afWpzj_appstore", 531, AfWpzjAppstorePlat.class, "安峰IOS王牌战警", PlatType.HUNFU);
        registerPlat("afTqdkn_appstore", 532, AfTqdknAppstorePlat.class, "安峰IOS天启的狂怒（新）账号与95互通", PlatType.HUNFU);
        registerPlat("afXzlm_appstore", 533, AfXzlmAppstorePlat.class, "安峰IOS血战黎明账号与95互通", PlatType.HUNFU);
        registerPlat("chzzzhg1_appstore", 534, Chzzzhg1AppstorePlat.class, "草花IOS战争指挥官-军团战役账号与94互通", PlatType.HUNFU);
        registerPlat("chzzzhg2_appstore", 535, Chzzzhg2AppstorePlat.class, "草花IOS战争指挥官-装甲兵团账号与94互通", PlatType.HUNFU);
        registerPlat("afGhgzh_appstore", 536, AfGhgzhAppstorePlat.class, "安峰IOS共和国之徽账号与95互通", PlatType.HUNFU);
        registerPlat("mzGhgzh_appstore", 537, MzGhgzhAppstorePlat.class, "拇指IOS红警：共和国之辉", PlatType.HUNFU);
        registerPlat("68play_appstore", 538, Play68AppstorePlat.class, "台湾68playios账号与151互通", PlatType.OTHER);
        registerPlat("mzYiwanCyzc_appstore", 539, MzYiwanCyzcAppstorePlat.class, "IOS拇指&一玩穿越战场", PlatType.HUNFU);
        registerPlat("afTqdknHD_appstore", 540, AfTqdknHDAppstorePlat.class, "安峰IOS天启的狂怒HD账号与95互通", PlatType.HUNFU);
        registerPlat("chCjzjtkzz_appstore", 541, ChCjzjtkzzAppstorePlat.class, "草花新版IOS提审包", PlatType.HUNFU);
        registerPlat("afNew_appstore", 542, afNewAppstorePlat.class, "安峰ios账号与95互通", PlatType.HUNFU);
        registerPlat("chZjqytkdz_appstore", 543, ChZjqytkdzAppstorePlat.class, "草花IOS坦克风暴-战争世界账号与541互通", PlatType.HUNFU);
        registerPlat("mzLzwz_appstore", 544, MzLzwzAppstorePlat.class, "拇指IOS陆战王者账号与501互通", PlatType.HUNFU);
        registerPlat("afNewMjdzh_appstore", 545, AfNewMjdzhAppstorePlat.class, "安峰IOS新盟军的召唤和530互通", PlatType.HUNFU);
        registerPlat("afNewWpzj_appstore", 546, AfNewWpzjAppstorePlat.class, "安峰IOS新王牌战警和531互通", PlatType.HUNFU);
        registerPlat("afLzyp_appstore", 547, AfLzypAppstorePlat.class, "安峰IOS老子有炮和af_appstore互通", PlatType.HUNFU);
        registerPlat("chhjfc_appstore", 548, ChhjfcAppstorePlat.class, "草花ios红警复仇", PlatType.YINGHE);
        registerPlat("afNew1_appstore", 549, AfNew1AppstorePlat.class, "天启的狂怒（新版sdk4.0.8）", PlatType.HUNFU);
        registerPlat("afNewMjdzh1_appstore", 550, AfNewMjdzh1AppstorePlat.class, "安峰IOS盟军的召唤新版sdk和95互通", PlatType.HUNFU);
        registerPlat("afNewWpzj1_appstore", 551, AfNewWpzj1AppstorePlat.class, "：安峰IOS王牌战警新版sdk和531互通", PlatType.HUNFU);
        registerPlat("caohuaEn_appstore", 552, CaoHuaEnAppstorePlat.class, "草花手游海外SDK【CP对接】", PlatType.OVERSEAS);
        registerPlat("afNewTqdknHD_appstore", 553, AfNewTqdknHDAppstorePlat.class, "安峰IOS天启的狂怒HD新版sdk", PlatType.HUNFU);
        registerPlat("jq_appstore", 553, JqIosPlat.class, "安峰IOS极趣", PlatType.HUNFU);
        registerPlat("chzzzhg3_appstore", 554, Chzzzhg3AppstorePlat.class, "草花IOS战争指挥官-装甲兵团", PlatType.HUNFU);
        registerPlat("chQzHjsj_appstore", 555, ChQzHjsjAppstorePlat.class, "草花仟指IOS红警世界", PlatType.YINGHE);
        registerPlat("chQzHjtkzb_appstore", 556, ChQzHjtkzbAppstorePlat.class, "草花仟指IOS红警坦克争霸与555互通", PlatType.YINGHE);
        registerPlat("chQzQmtkzz_appstore", 557, ChQzQmtkzzAppstorePlat.class, "草花仟指IOS全民坦克战争OL与555互通", PlatType.YINGHE);
        registerPlat("chQzHjdg_appstore", 558, ChQzHjdgPlat.class, "备注草花IOS仟指红警帝国（爱贝登录和聚合支付）", PlatType.YINGHE);
        registerPlat("mzHszzjj_appstore", 559, MzHszzjjAppstorePlat.class, "拇指IOS红色战争警戒", PlatType.HUNFU);
        registerPlat("mzTksjdz_appstore", 560, MzTksjdzAppstorePlat.class, "拇指IOS坦克世界大战", PlatType.HUNFU);
        registerPlat("chQzJdtk_appstore", 561, ChQzJdtkAppstorePlat.class, "草花仟指IOS绝地坦克OL", PlatType.YINGHE);
        registerPlat("chQzHjtkzc_appstore", 562, ChQzHjtkzcAppstorePlat.class, "草花仟指IOS红警-坦克战场", PlatType.YINGHE);
        registerPlat("chQzTkry_appstore", 563, ChQzTkryAppstorePlat.class, "草花仟指IOS坦克荣耀", PlatType.YINGHE);
        registerPlat("chQzZjldz_appstore", 564, ChQzZjldzAppstorePlat.class, "草花仟指IOS红警-装甲掠夺者", PlatType.YINGHE);
        registerPlat("mzTkbtdz_appstore", 565, MzTkbtdzAppstorePlat.class, "拇指IOS坦克百团大战", PlatType.HUNFU);
        registerPlat("mzHjxd_appstore", 566, MzHjxdAppstorePlat.class, "拇指IOS红警行动", PlatType.HUNFU);
        registerPlat("mzHjylgl_appstore", 567, MzHjylglAppstorePlat.class, "拇指IOS红警尤里归来", PlatType.HUNFU);
        registerPlat("chQzQmtkzb_appstore", 568, ChQzQmtkzbAppstorePlat.class, "草花仟指IOS全民坦克争霸", PlatType.YINGHE);
        registerPlat("chQzTkzhg_appstore", 569, ChQzTkzhgAppstorePlat.class, "草花仟指IOS坦克指挥官", PlatType.YINGHE);
        registerPlat("chQzTkzzwzxd_appstore", 570, ChQzTkzzwzxdAppstorePlat.class, "草花仟指IOS坦克战争·王者行动", PlatType.YINGHE);
        registerPlat("chQzTkzjz_appstore", 571, ChQzTkzjzAppstorePlat.class, "草花仟指IOS坦克终结者571", PlatType.YINGHE);
        registerPlat("mzTkfb_appstore", 572, MuZhiDgzzsdAppstorePlat.class, "拇指 混服 IOS 坦克风暴", PlatType.HUNFU);
        registerPlat("mzTkbwz_appstore", 573, MzTkbwzAppstorePlat.class, "拇指 混服 IOS 坦克保卫战", PlatType.HUNFU);
        registerPlat("mzTkhslx_appstore", 574, MzTkhslxAppstorePlat.class, "拇指IOS 坦克：红色来袭", PlatType.HUNFU);
        registerPlat("chxz_appstore", 575, ChxzAppstorePlat.class, "草花-《战争指挥官》新", PlatType.HUNFU);
        registerPlat("mzHsTkzz_appstore", 576, MzHsTkzzAppstorePlat.class, "拇指IOS 红色：坦克战争", PlatType.HUNFU);
        registerPlat("afJsyd_appstore", 577, AfJsyd_appstorePlat.class, "安峰 IOS 坚守营地", PlatType.HUNFU);
        registerPlat("mzHsbwz_appstore", 578, MzHsbwzAppstorePlat.class, "拇指 IOS 红色保卫战", PlatType.HUNFU);
        registerPlat("mzTkjjQy_appstore", 579, MzTkjjQyAppstorePlat.class, "拇指IOS 企业签名包", PlatType.HUNFU);
        registerPlat("mzDgjq_appstore", 580, MzDgjqAppstorePlat.class, "拇指IOS 坦克警戒 大国崛起", PlatType.HUNFU);
        registerPlat("mzZztx_appstore", 581, MzZztxAppstorePlat.class, "拇指IOS 战争突袭", PlatType.HUNFU);
        registerPlat("mzZjhwd_appstore", 582, MzZjhwdAppstorePlat.class, "拇指IOS 装甲护卫队", PlatType.HUNFU);
        registerPlat("chhjfcQy_appstore", 583, ChhjfcQyAppStorePlat.class, " 草花 IOS 红警复仇企业签", PlatType.YINGHE);
        registerPlat("mzjttx_appstore", 584, MzzjTtxAppstorePlat.class, " 拇指IOS 军团突袭", PlatType.HUNFU);


    }

    public PlatBase getPlatInst(String platName) {
        return platBump.get(platName);
    }

    public PlatBase getPlatInst(int platNo) {
        return platNoMap.get(platNo);
    }

    public boolean isNeedActionPointPlatNo(int platNo) {
        return actionPointPlatNoSet.contains(platNo);
    }

    /**
     * 是否是需要返回角色信息的渠道
     *
     * @param platNo
     * @return
     */
    public boolean isNeedRecordRolePlatNo(int platNo) {
        return recordRolePlatNoSet.contains(platNo);
    }

    /**
     * 是否是需要元宝充值的渠道
     *
     * @param platNo
     * @return
     */
    public boolean isNeedYBPayCallBackPlatNo(int platNo) {
        return yBPayCallBackPlatNoSet.contains(platNo);
    }

    public Register getRigisterInst(String platName) {
        return registerBump.get(platName);
    }

    // public Register getSelfPlat() {
    // return selfPlat;
    // }

    private void registerSelfPlat(String platName, Class<?> c) {
        Register register = (Register) getApplicationContext().getBean(c);
        registerBump.put(platName, register);
    }

    private void registerPlat(String platName, int platNo, Class<?> c, String desc, PlatType platType) {
        PlatBase plat = (PlatBase) getApplicationContext().getBean(c);
        plat.setPlatName(platName);
        plat.setPlatNo(platNo);
        plat.setDesc(desc);
        plat.setPlatType(platType);

        if (platBump.containsKey(platName)) {
            throw new AccountException("有重复的platName   " + platName);
        }
        // 也不知道为啥553重复 也没有人提出问题 也不敢改
        if (platNoMap.containsKey(platNo) && platNo != 553) {
            throw new AccountException("有重复的platNo   " + platNo);
        }

        platBump.put(platName, plat);
        platNoMap.put(platNo, plat);
    }

    public Map<Integer, PlatBase> getPlatNoMap() {
        return platNoMap;
    }
}
