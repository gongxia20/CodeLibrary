
#import "MeViewController.h"
#import <CoreImage/CoreImage.h>

@interface MeViewController ()
/**
 *  显示二维码的容器
 */
@property (weak, nonatomic) IBOutlet UIImageView *qrcodeImageView;

@end

@implementation MeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    /*
     注意:
     1.生成二维码时, 不建议让二维码保存过多数据, 因为数据越多, 那么二维码就越密集,那么扫描起来就越困难
     2.二维码有三个定位点, 着三个定位点不能被遮挡, 否则扫描不出来
     3.二维码即便缺失一部分也能正常扫描出结果, 但是需要注意, 这个缺失的范围是由限制的, 如果太多那么也扫面不出来
     */
    // 1.创建滤镜
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 2.还原滤镜默认属性
    [filter setDefaults];
    // 3.将需要生成二维码的数据转换为二进制
    NSData *data = [@"123" dataUsingEncoding:NSUTF8StringEncoding];
    // 4.给滤镜设置数据
    [filter setValue:data forKeyPath:@"inputMessage"];
    // 5.生成图片
    CIImage *qrcodeImage =  [filter outputImage];
    
    // 6.显示图片
//    self.qrcodeImageView.image = [UIImage imageWithCIImage:qrcodeImage];
//    self.qrcodeImageView.image = [self createNonInterpolatedUIImageFormCIImage:qrcodeImage withSize:600];
    
    UIImage *bg = [self createNonInterpolatedUIImageFormCIImage:qrcodeImage withSize:600];
    UIImage *icon = [UIImage imageNamed:@"icon"];
    self.qrcodeImageView.image = [self creteImageWithBg:bg icon:icon];
}

- (UIImage *)creteImageWithBg:(UIImage *)bg icon:(UIImage *)icon
{
    // 1.创建图形上下文
    UIGraphicsBeginImageContextWithOptions(bg.size, YES, 0.0);
    // 2.绘制背景
    [bg drawInRect:CGRectMake(0, 0, bg.size.width, bg.size.height)];
    // 3.绘制图标
    CGFloat iconW = 60;
    CGFloat iconH = 60;
    CGFloat iconX = (bg.size.width - iconW) * 0.5;
    CGFloat iconY = (bg.size.height - iconH) * 0.5;
    [icon drawInRect:CGRectMake(iconX, iconY, iconW, iconH)];
    // 4.取出图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    // 5.关闭上下文
    UIGraphicsEndImageContext();
    
    // 5.返回图片
    return newImage;
}

/**
 *  根据CIImage生成指定大小的UIImage
 *
 *  @param image CIImage
 *  @param size  图片宽度
 */
- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}


@end
