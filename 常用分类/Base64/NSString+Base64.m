
#import "NSString+Base64.h"

@implementation NSString (Base64)

- (NSString *)base64Endcode:(NSString *)string {
    // 1. 将字符串转换成二进制数据
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    // 2. 返回base64编码后的结果
    return [data base64EncodedStringWithOptions:0];
}


- (NSString *)base64Decode:(NSString *)string {
    // 1. 将 base64 编码后的字符串"解码"成二进制数据
    NSData *data = [[NSData alloc] initWithBase64EncodedString:string options:0];
    
    // 2. 返回字符串
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}


@end
