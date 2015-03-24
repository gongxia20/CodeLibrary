1.下载框架
// 让控制台可以输出颜色插件
https://github.com/robbiehanson/XcodeColors
// 带色彩日志框架
https://github.com/CocoaLumberjack/CocoaLumberjack

2.安装XcodeColors(输出颜色插件)  -- > command + Q -->再次打开工程选择Test测试是否安装成功

3.导入色彩日志框架

===========================================================

1.导入相关头文件以及定义日志级别，一般在pch文件中
#import "DDLog.h"
#import "DDFileLogger.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_OFF;
#endif

2. 在didFinishLaunchingWithOptions方法中初始化带色彩日志
[DDLog addLogger:[DDTTYLogger sharedInstance]];

3.开启色彩日志
[[DDTTYLogger sharedInstance] setColorsEnabled:YES];

4.使用带色彩日志

5.修复Xcode6不显示色彩日志问题
>In Xcode bring up the Scheme Editor (Product -> Edit Scheme...)
>Select "Run" (on the left), and then the "Arguments" tab
>Add a new Environment Variable named "XcodeColors", with a value of "YES"

===========================================================

1.日志类型
DDLog：基础类，必须引入的。
DDASLLogger：支持将调试语句写入到苹果的日志中。一般正对Mac开发。可选。
DDTTYLogger：支持将调试语句写入xCode控制台。我们即使要用它。可选。
DDFileLogger：支持将调试语句写入到文件系统。可选。

2.DDLog日志种类。
DDLogError：定义输出错误文本
DDLogWarn：定义输出警告文本
DDLogInfo：定义输出信息文本
DDLogDebug：定义输出调试文本
DDLogVerbose：定义输出详细文本

3.日志级别
>LOG_LEVEL_ERROR，那么你只会看到DDlogError语句。
>LOG_LEVEL_WARN，那么你只会看到DDLogError和DDLogWarn语句。
>LOG_LEVEL_INFO,那么你会看到error、Warn和Info语句。
>LOG_LEVEL_VERBOSE,那么你会看到所有DDLog语句。
>LOG_LEVEL_OFF,你将不会看到任何DDLog语句。

===========================================================

1.自定义颜色
[[DDTTYLogger sharedInstance] setForegroundColor:[UIColor greenColor] backgroundColor:[UIColor purpleColor] forFlag:DDLogFlagInfo];


// 快速定位打印方法
#define DDInfoLog DDLogWarn(@"%d %s", __LINE__ ,__func__)
