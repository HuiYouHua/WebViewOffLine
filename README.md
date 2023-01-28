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

5. 打开webView

   1. 设置`  [self.webView.configuration.preferences setValue:@YES forKey:@"allowFileAccessFromFileURLs"];`允许加载file URL的页面

   2. 重写父类实现的`shouldStartLoadWithRequest`可控制是否加载当前URL，子类实现离线包和URL映射配置化

      1. 根据配置和请求的 URL 生成新的url【配置可以通过网络下发】

         1. 地址中包含有 `/#/`

            1. 获取 host 匹配、path 匹配、fragmentprefixs匹配 的offweb 资源名
            2. 修改 url，有offweb 字段则替换，没有则在 url 中添加

         2. 地址中包含有 `#/`，但不包含 `/#/`

            1. 同上

         3. 正常 H5页面，即不带 `#`

            1. 获取 host 匹配、path 匹配 的offweb 资源名

            2. 如果 url 自带 `offweb=`，则直接替换掉，将上面匹配到的 offweb 字段进行替换 url 中的

            3. 如果 url 中没有 `offweb=`，则直接在 url 中添加

            4. ```
               比如 请求的地址是: https://www.baidu.com/testapp?offweb=act3-offline-package-test
               
               它的 rules 是：
               {
                   "rules" :[
                       {
                           "host" :[
                               "baidu.com" ,
                               "test2.zzz.cn"
                           ],
                           "path" :[
                               "/testapp"
                           ],
                           "offweb" : "test-offline1"
                       },
                   ]
               }
               
               这里的 host、path都匹配上了
               那么就去取 offweb 叫 test-offline1 的本地资源
               ```

      2. 加载本地H5 资源，如果没有加载原始的URL 地址















