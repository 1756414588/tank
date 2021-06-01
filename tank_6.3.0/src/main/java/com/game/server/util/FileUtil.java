/**   
 * @Title: FileUtil.java    
 * @Package com.game.server.util    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年7月29日 下午1:58:31    
 * @version V1.0   
 */
package com.game.server.util;

import com.game.util.LogUtil;
import org.apache.log4j.Logger;

import java.io.File;
import java.io.FileInputStream;
import java.util.Map;

/**
 * @ClassName: FileUtil
 * @Description: 文件处理工具类
 * @author ZhangJun
 * @date 2015年7月29日 下午1:58:31
 * 
 */
public class FileUtil {
	private static final Logger logger = Logger.getLogger(FileUtil.class);
	
	/**
	 * 
	* @Title: readFile 
	* @Description: 读取一个本地文件
	* @param path
	* @return  
	* String   

	 */
	public static String readFile(String path) {
		File file = new File(path);
		Long filelength = file.length(); // 获取文件长度
		byte[] filecontent = new byte[filelength.intValue()];
		try {
			FileInputStream in = new FileInputStream(file);
			in.read(filecontent);
			in.close();
		} catch (Exception e) {
			logger.error(e, e);
			return null;
		}

		return new String(filecontent);// 返回文件内容,默认编码
	}

    public static void readHotfixDir(String parent, File curFile, Map<String, Long> fileTimeMap, boolean bDelete) {
        if (curFile.isDirectory()) {
            File[] files = curFile.listFiles();
            if (files != null && files.length > 0) {
                for (File file : files) {
                    if (file.isDirectory()) {
                        String packageName = parent != null ? parent + "." + file.getName() : file.getName();
                        readHotfixDir(packageName, file, fileTimeMap, bDelete);
                    } else {
                        readHotfixDir(parent, file, fileTimeMap, bDelete);
                    }
                }
            }
        } else {
            try {
                int classNameIdx = curFile.getName().indexOf(".class");
                if (classNameIdx >= 0) {
                    String className = curFile.getName().substring(0, classNameIdx);
                    String clsFullName = parent != null ? parent + "." + className : className;
                    fileTimeMap.put(clsFullName, curFile.lastModified());
                }
                if (bDelete && curFile.delete()) {
                    LogUtil.hotfix("delete class file :" + curFile.getName());
                }

            } catch (Exception e) {
                LogUtil.hotfix(String.format("parent :%s, file :%s", parent, curFile.getName()), e);
            }

        }
    }
	
	
	
	
}
