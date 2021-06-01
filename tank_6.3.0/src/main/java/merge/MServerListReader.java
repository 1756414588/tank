package merge;

import com.alibaba.fastjson.JSONObject;
import com.game.util.LogUtil;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;


public class MServerListReader {

	public static JSONObject readServerList() {
		String path = "mergeServerList.json";
		Resource resource = new FileSystemResource(path);
		String content = new String();
		if (resource.isReadable()) {
			try {
				String encoding = "UTF-8";
				InputStream is = resource.getInputStream();
				InputStreamReader read = new InputStreamReader(is, encoding);// 考虑到汉子编码格式
				BufferedReader bufferedReader = new BufferedReader(read);
				String lineTxt = null;
				while ((lineTxt = bufferedReader.readLine()) != null) {
					content += lineTxt;
				}

				if (is != null) {
					is.close();
				}
				if (bufferedReader != null) {
					bufferedReader.close();
				}

			} catch (Exception e) {
				LogUtil.error("读取文件内容出错:" + path, e);
				e.printStackTrace();
			}

		} else {
			path = "mergeServerList.json";
			try {
				String encoding = "UTF-8";
				InputStream inputStream = MServerListReader.class.getClassLoader().getResourceAsStream(path);

				InputStreamReader read = new InputStreamReader(inputStream, encoding);// 考虑到汉子编码格式
				BufferedReader bufferedReader = new BufferedReader(read);
				String lineTxt = null;
				while ((lineTxt = bufferedReader.readLine()) != null) {
					content += lineTxt;
				}

				if (inputStream != null) {
					inputStream.close();
				}
				if (bufferedReader != null) {
					bufferedReader.close();
				}
			} catch (Exception e) {
				LogUtil.error("读取资源文件内容出错:" + path, e);
				e.printStackTrace();
			}
		}
		return JSONObject.parseObject(content);
	}
}
