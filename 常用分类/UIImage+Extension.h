

#import <UIKit/UIKit.h>

@interface UIImage (Extension)
+ (UIImage *)imageWithName:(NSString *)name;
#pragma mark 返回拉伸好的图片
+ (UIImage *)resizeImage:(NSString *)imgName;

- (UIImage *)resizeImage;

+ (UIImage *)imageWithColor:(UIColor *)color;
@end
