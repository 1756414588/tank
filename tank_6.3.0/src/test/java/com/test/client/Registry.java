package com.test.client;

import com.game.pb.AccountPb;
import com.game.pb.AdvertisementPb;
import com.game.pb.CommonPb;
import com.game.pb.CrossGamePb;
import com.game.pb.GamePb1;
import com.game.pb.GamePb2;
import com.game.pb.GamePb3;
import com.game.pb.GamePb4;
import com.game.pb.GamePb5;
import com.game.pb.InnerPb;
import com.game.pb.SerializePb;
import com.google.protobuf.ExtensionRegistry;

/**
 * @ClassName Registry.java
 * @author TanDonghai
 * @date 创建时间：2016年11月26日 上午11:27:45
 *
 */
public class Registry {

	static public ExtensionRegistry registry = ExtensionRegistry.newInstance();
	static {
		AccountPb.registerAllExtensions(registry);
		AdvertisementPb.registerAllExtensions(registry);
		CommonPb.registerAllExtensions(registry);
		CrossGamePb.registerAllExtensions(registry);
		GamePb1.registerAllExtensions(registry);
		GamePb2.registerAllExtensions(registry);
		GamePb3.registerAllExtensions(registry);
		GamePb4.registerAllExtensions(registry);
		GamePb5.registerAllExtensions(registry);
		InnerPb.registerAllExtensions(registry);
		SerializePb.registerAllExtensions(registry);
	}



}
