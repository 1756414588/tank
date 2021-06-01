package com.game.manager;

import java.util.Calendar;
import java.util.Date;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.game.dao.impl.p.AdvertisementDao;
import com.game.domain.p.Advertisement;
/**
* @ClassName: AdvertisementDateManager 
* @Description: 广告播放数据处理
* @author
 */
@Component
public class AdvertisementDateManager {
    @Autowired
    private AdvertisementDao advertisementDao;

    /**
    * @Title: getLoginADStatus 
    * @Description: 初始化玩家登陆广告奖励状态
    * @param advertisement  
    * void   

     */
    public void getLoginADStatus(Advertisement advertisement) {
        Date now = new Date();
        Date zero = getDateZeroTime(now);
        Date last = advertisement.getLastLoginTime();
        if (!last.after(zero)) {
            advertisement.setLoginStatus(0);
        }
        advertisementDao.updateAdvertisement(advertisement);
    }

    /**
    * @Title: playLoginAD 
    * @Description: 更新玩家登陆广告奖励状态
    * @param date
    * @param advertisement
    * @return  
    * int   

     */
    public int playLoginAD(Date date, Advertisement advertisement) {
        /**如果今天没播放过 播放状态设置为0*/
        if (!advertisement.getLastLoginTime().after(getDateZeroTime(date))) {
            advertisement.setLoginStatus(0);
            advertisementDao.updateAdvertisement(advertisement);
        }
        
        /**更新播放状态*/
        advertisement.setLastLoginTime(date);
        advertisement.setLoginStatus(advertisement.getLoginStatus() + 1);
        advertisementDao.updateAdvertisement(advertisement);
        
        return advertisement.getLoginStatus();
    }

    /**
    * @Title: getFirstGiftADStatus 
    * @Description: 初始化玩家首冲广告奖励状态
    * @param advertisement
    * @return  
    * Advertisement   

     */
    public Advertisement getFirstGiftADStatus(Advertisement advertisement) {
        Date now = new Date();
        Date zero = getDateZeroTime(now);
        Date last = advertisement.getLastFirstPayADTime();//最后播放首冲广告时间
        long zerol = zero.getTime();
        long lastl = last.getTime();
        if (last.after(zero)) {

        } else {
            if ((zerol - lastl) > 86400000) {//如果超过两天没有播放首冲广告 则把连续首冲广告播放天数清零
                advertisement.setFirstPayCount(0);
                advertisement.setFirstPay(0);
            } else {
                advertisement.setFirstPay(0);
            }
        }
        advertisementDao.updateAdvertisement(advertisement);
        return advertisement;
    }

    /**
    * @Title: playFirstGiftAD 
    * @Description: 更新玩家首冲广告奖励状态
    * @param advertisement
    * @return  
    * Advertisement   

     */
    public Advertisement playFirstGiftAD(Advertisement advertisement) {
        Date now = new Date();
        Date zero = getDateZeroTime(now);
        Date last = advertisement.getLastFirstPayADTime();
        long zerol = zero.getTime();
        long lastl = last.getTime();
        if (last.after(zero)) {
            advertisement.setFirstPay(advertisement.getFirstPay() + 1);
            if (advertisement.getFirstPay() == 5) {
                advertisement.setFirstPayCount(advertisement.getFirstPayCount() + 1);
            }
        } else {
            if ((zerol - lastl) > 86400000) {
                advertisement.setFirstPayCount(0);
                advertisement.setFirstPay(1);
            } else {
                advertisement.setFirstPay(1);
            }
        }
        if (advertisement.getFirstPayCount() == 7) {
            advertisement.setFirstPayStatus(1);
        }
        advertisement.setLastFirstPayADTime(now);
        advertisementDao.updateAdvertisement(advertisement);
        return advertisement;
    }

    // public int AwardFirstGiftAD(long lordId){
    // Advertisement advertisement = advertisementDao.selectAdvertisement(lordId);
    // int status = advertisement.getFirstPayStatus();
    // return status;
    // }

    /**
     * 
    * @Title: getStaffingAddStatus 
    * @Description: 初始化玩家编制经验广告buff状态
    * @param advertisement
    * @return  
    * Advertisement   

     */
    public Advertisement getStaffingAddStatus(Advertisement advertisement) {
        Date now = new Date();
        Date zero = getDateZeroTime(now);
        Date last = advertisement.getLastBuffTime();
        if (!last.after(zero)) {
            advertisement.setBuffCount(0);
        }
        advertisementDao.updateAdvertisement(advertisement);
        return advertisement;
    }

    /**
    * @Title: playStaffingAddAD 
    * @Description: 更新玩家编制经验广告buff状态
    * @param advertisement
    * @return  
    * Advertisement   

     */
    public Advertisement playStaffingAddAD(Advertisement advertisement) {
        Date now = new Date();
        Date zero = getDateZeroTime(now);
        Date last = advertisement.getLastBuffTime();
        if (!last.after(zero)) {
            advertisement.setBuffCount(1);
            advertisement.setLastBuffTime(now);
        } else {
            advertisement.setBuffCount(advertisement.getBuffCount() + 1);
            advertisement.setLastBuffTime(now);
        }
        advertisementDao.updateAdvertisement(advertisement);
        return advertisement;
    }

    /**
    * @Title: getDay7ActLvUpADStatus 
    * @Description: 初始化秒升一级状态
    * @param advertisement
    * @return  
    * Advertisement   

     */
    public Advertisement getDay7ActLvUpADStatus(Advertisement advertisement) {
        Date now = new Date();
        Date zero = getDateZeroTime(now);
        Date last = advertisement.getLvUpLastTime();
        if (!last.after(zero)) {
            advertisement.setLvUpStatus(0);
            advertisementDao.updateAdvertisement(advertisement);
        }
        return advertisement;
    }

    /**
    * @Title: playDay7ActLvUpAD 
    * @Description: 更新观看秒升一级状态
    * @param advertisement
    * @return  
    * Advertisement   

     */
    public Advertisement playDay7ActLvUpAD(Advertisement advertisement) {
        Date now = new Date();
        Date zero = getDateZeroTime(now);
        Date last = advertisement.getLvUpLastTime();
        advertisement.setLvUpLastTime(now);
        if (!last.after(zero)) {
            advertisement.setLvUpStatus(1);
        } else {
            advertisement.setLvUpStatus(advertisement.getLvUpStatus() + 1);
        }
        advertisementDao.updateAdvertisement(advertisement);
        return advertisement;
    }

    /**
    * @Title: doDay7ActLvUpAD 
    * @Description: 观看秒升一级（更新最后观看时间）
    * @param advertisement
    * @return  
    * Advertisement   

     */
    public Advertisement doDay7ActLvUpAD(Advertisement advertisement) {
        Date now = new Date();
        advertisement.setLvUpLastTime(now);
        advertisementDao.updateAdvertisement(advertisement);
        return advertisement;
    }

    /**
    * @Title: getExpAddStatus 
    * @Description: 初始化指挥官经验广告buff状态
    * @param advertisement
    * @return  
    * Advertisement   

     */
    public Advertisement getExpAddStatus(Advertisement advertisement) {
        Date now = new Date();
        Date zero = getDateZeroTime(now);
        Date last = advertisement.getLastBuff2Time();
        if (!last.after(zero)) {
            advertisement.setBuffCount2(0);
        }
        advertisementDao.updateAdvertisement(advertisement);
        return advertisement;
    }

    /**
    * @Title: playExpAddAD 
    * @Description: 更新指挥官经验广告buff状态
    * @param advertisement
    * @return  
    * Advertisement   

     */
    public Advertisement playExpAddAD(Advertisement advertisement) {
        Date now = new Date();
        Date zero = getDateZeroTime(now);
        Date last = advertisement.getLastBuff2Time();
        if (!last.after(zero)) {
            advertisement.setBuffCount2(1);
            advertisement.setLastBuff2Time(now);
        } else {
            advertisement.setBuffCount2(advertisement.getBuffCount2() + 1);
            advertisement.setLastBuff2Time(now);
        }
        advertisementDao.updateAdvertisement(advertisement);
        return advertisement;
    }

    /**
    * @Title: playAddPowerAD 
    * @Description: 更新玩家体力恢复广告状态
    * @param advertisement
    * @return  
    * Advertisement   

     */
    public Advertisement playAddPowerAD(Advertisement advertisement) {
        Date now = new Date();
        Date zero = getDateZeroTime(now);
        Date last = advertisement.getPowerTime();
        if (!last.after(zero)) {
            advertisement.setPowerCount(1);
            advertisement.setPowerTime(now);
        } else {
            advertisement.setPowerCount(advertisement.getPowerCount() + 1);
            advertisement.setPowerTime(now);
        }
        advertisementDao.updateAdvertisement(advertisement);
        return advertisement;
    }

    /**
    * @Title: playAddCommandAD 
    * @Description: 更新玩家统率书广告状态
    * @param advertisement
    * @return  
    * Advertisement   

     */
    public Advertisement playAddCommandAD(Advertisement advertisement) {
        Date now = new Date();
        Date zero = getDateZeroTime(now);
        Date last = advertisement.getCommondTime();
        if (!last.after(zero)) {
            advertisement.setCommondCount(1);
            advertisement.setCommondTime(now);
        } else {
            advertisement.setCommondCount(advertisement.getCommondCount() + 1);
            advertisement.setCommondTime(now);
        }
        advertisementDao.updateAdvertisement(advertisement);
        return advertisement;
    }

    /**
    * @Title: getAddPowerAD 
    * @Description:  初始化玩家体力恢复广告状态
    * @param advertisement
    * @return  
    * Advertisement   

     */
    public Advertisement getAddPowerAD(Advertisement advertisement) {
        Date now = new Date();
        Date zero = getDateZeroTime(now);
        Date last = advertisement.getPowerTime();
        if (!last.after(zero)) {
            advertisement.setPowerCount(0);
        }
        advertisementDao.updateAdvertisement(advertisement);
        return advertisement;
    }
    
    /**
    * @Title: getAddCommandAD 
    * @Description: 初始化玩家统率书广告状态
    * @param advertisement
    * @return  
    * Advertisement   

     */
    public Advertisement getAddCommandAD(Advertisement advertisement) {
        Date now = new Date();
        Date zero = getDateZeroTime(now);
        Date last = advertisement.getCommondTime();
        if (!last.after(zero)) {
            advertisement.setCommondCount(0);
        }
        advertisementDao.updateAdvertisement(advertisement);
        return advertisement;
    }
    
    /**
    * @Title: getDateZeroTime 
    * @Description: 获取当天零点整时间
    * @param date
    * @return  
    * Date   

     */
    private static Date getDateZeroTime(Date date) {
        Calendar cal = Calendar.getInstance();
        cal.setTime(date);
        cal.set(Calendar.HOUR_OF_DAY, 0);
        cal.set(Calendar.MINUTE, 0);
        cal.set(Calendar.SECOND, 0);
        cal.set(Calendar.MILLISECOND, 0);
        return cal.getTime();
    }

}
