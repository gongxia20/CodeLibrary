
#import <Foundation/Foundation.h>

@interface NSString (Base64)

#pragma mark - base64的编码和解码
// 从 iOS 7.0 开始，苹果提供了 base64 的编码和解码的支持
// 如果是老项目，可能会看到 base64 的第三方框架
// 如果不需要支持 iOS 7.0 以下版本，可以替换成苹果原生的编码方案

/**
 给定一个字符串，进行 base64 编码，返回结果
 
 终端 echo -n A | base64
 */
- (NSString *)base64Endcode:(NSString *)string;
/**
 终端 echo -n QQ== | base64 -D
 */
- (NSString *)base64Decode:(NSString *)string;

@end
