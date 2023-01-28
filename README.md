# WebViewOffLine
离线H5



1. 基于GCDWebServer搭建的本地HTTP服务，提供离线包查询和下载服务，本地模拟服务端 `LocalServerTestController`

   1. 提供 /offweb 接口，查询离线包数据
   2. 提供 /resource 接口，用于进行离线包下载

2. `DefaultWebPackageConfig`默认配置

   1. ```swift
      /**
       参数名    参数含义    是否必填
       rules    H5页面和离线包参数映射规则    选填
       */
      /// 子配置项keys
      /// switch    1 开启离线包功能，0 关闭    必填
      NSString *const kHLLOfflineWebConfigKey_switch = @"switch";
      ///  disablelist    需要禁用离线包功能到页面    选填
      NSString *const kHLLOfflineWebConfigKey_disablelist = @"disablelist";
      /// predownloadlist    预下载离线包列表    选填
      NSString *const kHLLOfflineWebConfigKey_predownloadList = @"predownloadlist";
      ///  downloadsdk      设置下载sdk方式，默认不启用断点续传 0,  系统API下载方式
      NSString *const kHLLOfflineWebConfigKey_downloadSdk = @"downloadsdk";
      ```

3. `initOfflineWeb`设置默认配置，离线包初始化

   1. 是否开启离线包功能
   2. 某些离线包功能是否禁用
   3. 设置app版本参数
   4. 设置环境参数
   5. 设置日志、埋点、监听日志回调

4. `preDownloadOfflineWeb`开启预下载

   1. 根据配置中需要进行预下载离线包列表中的离线包进行下载
      1. 获取本地离线包版本号，传入离线包名称、终端类型、本地离线包版本、客户端版本，进行检查更新
      2. 获取到数据，删除 old 目录下的文件。根据结果决定是否需要下载解压离线包，并决定刷新方式
         1. 如果有新离线包，result > 0
            1. 请求到的版本 和 本地版本一致，无需更新
            2. 请求到的版本 和 本地版本不一致，需要下载并解压
               1. 解压过程中，先将文件解压到 tmp 目录下
               2. 解压成功后
                  1. 如果 cur 目录不存在，则将 temp 目录下文件移动到 cur 目录下（第一次下载解压该文件）
                  2. 如果 cur 目录存在，则移除 new 目录下文件，将 temp 目录下文件移动到 new 目录下（后续全量下载新版本文件）
               3. 移除压缩包文件

















