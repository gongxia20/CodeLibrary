#import "ViewController.h"

@interface ViewController ()
/**
 *  图片B
 */
@property (weak, nonatomic) IBOutlet UIImageView *imageB;

/**
 *  用于记录是否触摸到了图片B
 */
@property (nonatomic, assign, getter=isTouch) BOOL touch;

@end

@implementation ViewController

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // 1.取出手指
    UITouch *touch = [touches anyObject];
    // 2.判断手指是否触摸了图片B
    if (touch.view == self.imageB) {
        self.touch = YES;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // 1.判断手指是否触摸了图片B
    if (self.isTouch) {
        // 2.处理图片
        // 2.1创建一个图片上下文
        UIGraphicsBeginImageContext(self.imageB.bounds.size);
        // 2.2绘制图片到图片上下文中
        [self.imageB.image drawInRect:self.imageB.bounds];
        // 2.3清空手指触摸的区域
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:touch.view];
        CGRect rect = CGRectMake(point.x - 10, point.y - 10, 20, 20);
        
        CGContextClearRect(UIGraphicsGetCurrentContext(), rect);
        
        // 2.4取出图片重新设置给图片B
        self.imageB.image = UIGraphicsGetImageFromCurrentImageContext();
        
        // 2.5关闭图片的上下文
        UIGraphicsEndImageContext();
        
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // 还原手指状态
    self.touch = NO;
}

@end
