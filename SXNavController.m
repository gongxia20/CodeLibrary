
#import "SXNavController.h"
#import "QuartzCore/QuartzCore.h"

@interface SXNavController ()
{   // screenshot
    UIImageView *_screenshotImageView;
    // cover view
    UIView *_coverView;
    // save all screenshot images
    NSMutableArray *_screenshotImagesArray;
}
@end

@implementation SXNavController
+ (void)initialize {
    
    [self setupNavBarAppearance];
    [self setupBarButtonItemAppearance];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // create pan gesture
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRec:)];
    [self.view addGestureRecognizer:pan];
    // create screenshot imageView
    _screenshotImageView = [[UIImageView alloc] init];
    // app的frame是除去了状态栏高度的frame
    _screenshotImageView.frame = [UIScreen mainScreen].applicationFrame;
    // create cover view
    _coverView = [[UIView alloc] init];
    _coverView.frame = _screenshotImageView.frame;
    _coverView.backgroundColor = [UIColor blackColor];
    _screenshotImagesArray = [NSMutableArray array];
}

+ (void)setupNavBarAppearance {
    
    
    UINavigationBar *barStyle = [UINavigationBar appearance];
    
    if (!iOS7) {
        // 统一iOS6和iOS7的效果，iOS6需要设置外观来达到iOS7的样子
        [barStyle setBackgroundImage:[UIImage imageNamed:@"navigationbar_background"] forBarMetrics:UIBarMetricsDefault];
    }
    NSMutableDictionary *barAttrs            = [NSMutableDictionary dictionary];
    barAttrs[NSForegroundColorAttributeName] = [UIColor blackColor];
    barAttrs[NSFontAttributeName]            = [UIFont systemFontOfSize:20];
    // 去除文字阴影
    NSShadow *shadow                = [[NSShadow alloc] init];
    shadow.shadowOffset             = CGSizeZero;
    barAttrs[NSShadowAttributeName] = shadow;
    [barStyle setTitleTextAttributes:barAttrs];
}
+ (void)setupBarButtonItemAppearance {
    
    UIBarButtonItem *itemStyle                = [UIBarButtonItem appearance];
    // normal style
    NSMutableDictionary *itemAttrs            = [NSMutableDictionary dictionary];
    itemAttrs[NSForegroundColorAttributeName] = [UIColor orangeColor];
    itemAttrs[NSFontAttributeName]            = [UIFont systemFontOfSize:13];
    [itemStyle setTitleTextAttributes:itemAttrs forState:UIControlStateNormal];
    
    // highlighted style
    NSMutableDictionary *itemHighAttrs            = [NSMutableDictionary dictionary];
    itemHighAttrs[NSForegroundColorAttributeName] = [UIColor redColor];
    itemHighAttrs[NSFontAttributeName]            = [UIFont systemFontOfSize:13];
    [itemStyle setTitleTextAttributes:itemHighAttrs forState:UIControlStateHighlighted];
    
    // disable style
    NSMutableDictionary *itemDisabledAttrs            = [NSMutableDictionary dictionary];
    itemDisabledAttrs[NSForegroundColorAttributeName] = SXAColor(0.6, 0.6, 0.6, 0.7);
    itemDisabledAttrs[NSFontAttributeName]            = [UIFont systemFontOfSize:13];
    [itemStyle setTitleTextAttributes:itemDisabledAttrs forState:UIControlStateDisabled];
}
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    // 不是根控制器可进入
    if (self.viewControllers.count > 0) {
        [self screenshot];
        // 隐藏底部的tabbar
        viewController.hidesBottomBarWhenPushed = YES;
        
        
        viewController.navigationItem.leftBarButtonItem  = [UIBarButtonItem itemWithImageName:@"navigationbar_back" highImageName:@"navigationbar_back_highlighted" target:self action:@selector(backBtnClick)];

        viewController.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithImageName:@"navigationbar_more" highImageName:@"navigationbar_more_highlighted" target:self action:@selector(moreBtnClick)];
    }
    [super pushViewController:viewController animated:animated];
}

- (void)backBtnClick {
    [self popViewControllerAnimated:YES];
}
- (void)moreBtnClick {
    [self popToRootViewControllerAnimated:YES];
}

- (void)screenshot {
    // 将要被截图的view,即窗口的根控制器的view(必须不含状态栏,默认ios7中控制器是包含了状态栏的)
    UIViewController *beyondVC = (UIViewController *)self.view.window.rootViewController;
    // 背景图片 总的大小
    CGSize size = beyondVC.view.frame.size;
    // 开启上下文,使用参数之后,截出来的是原图（YES  0.0 质量高）
    UIGraphicsBeginImageContextWithOptions(size, YES, 0.0);
    // 要裁剪的矩形范围
    CGRect rect = CGRectMake(0, -20.8, size.width, size.height + 20 );
    //注：iOS7以后renderInContext：由drawViewHierarchyInRect：afterScreenUpdates：替代
    [beyondVC.view drawViewHierarchyInRect:rect  afterScreenUpdates:NO];
    // 从上下文中,取出UIImage
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    // 添加截取好的图片到图片数组
    [_screenshotImagesArray addObject:snapshot];
    
    // 千万记得,结束上下文(移除栈顶的基于当前位图的图形上下文)
    UIGraphicsEndImageContext();
}

// 监听手势的方法,只要是有手势就会执行
- (void)panGestureRec:(UIPanGestureRecognizer *)panGestureRec
{
    
    // 如果当前显示的控制器已经是根控制器了，不需要做任何切换动画,直接返回
    if(self.topViewController == self.viewControllers[0]) return;
    // 判断pan手势的各个阶段
    switch (panGestureRec.state) {
        case UIGestureRecognizerStateBegan:
            // 开始拖拽阶段
            [self dragBegin];
            break;
            
        case UIGestureRecognizerStateEnded:
            // 结束拖拽阶段
            [self dragEnd];
            break;
            
        default:
            // 正在拖拽阶段
            [self dragging:panGestureRec];
            break;
    }
}

#pragma mark 开始拖动,添加图片和遮罩
- (void)dragBegin
{
    // 重点,每次开始Pan手势时,都要添加截图imageview 和 遮盖cover到window中
    [self.view.window insertSubview:_screenshotImageView atIndex:0];
    [self.view.window insertSubview:_coverView aboveSubview:_screenshotImageView];
    
    // 并且,让imgView显示截图数组中的最后(最新)一张截图
    _screenshotImageView.image = [_screenshotImagesArray lastObject];
}

// 默认的将要进行缩放的截图的初始比例
#define kDefaultScale 0.6
// 默认的将要变透明的遮罩的初始透明度(全黑)
#define kDefaultAlpha 1.0
// 当拖动的距离,占了屏幕的总宽度的3/4时, 就让imageview完全显示，遮盖完全消失
#define kTargetTranslateScale 0.75

#pragma mark 正在拖动,动画效果的精髓,进行缩放和透明度变化
- (void)dragging:(UIPanGestureRecognizer *)pan
{
    
    // 得到手指拖动的位移
    CGFloat offsetX = [pan translationInView:self.view].x;
    // 只允许往右边拖,禁止向左拖
    if (offsetX < 0) offsetX = 0;
    // 让整个导航的view都平移
    self.view.transform = CGAffineTransformMakeTranslation(offsetX, 0);
    
    // 计算目前手指拖动位移占屏幕总的宽度的比例,当这个比例达到3/4时, 就让imageview完全显示，遮盖完全消失
    double currentTranslateScaleX = offsetX/self.view.frame.size.width;
    
    // 让imageview缩放,默认的比例+(当前平移比例/目标平移比例)*(1-默认的比例)
    double scale = kDefaultScale + (currentTranslateScaleX/kTargetTranslateScale) * (1 - kDefaultScale);
    // 已经达到原始大小了,就可以了,不用放得更大了
    if (scale > 1) scale = 1;
    _screenshotImageView.transform = CGAffineTransformMakeScale(scale, scale);
    
    // 让遮盖透明度改变,直到减为0,让遮罩完全透明,默认的比例-(当前平移比例/目标平移比例)*默认的比例
    double alpha = kDefaultAlpha - (currentTranslateScaleX/kTargetTranslateScale) * kDefaultAlpha;
    _coverView.alpha = alpha;
}

#pragma mark 结束拖动,判断结束时拖动的距离作相应的处理,并将图片和遮罩从父控件上移除
- (void)dragEnd
{
    // 取出挪动的距离
    CGFloat translateX = self.view.transform.tx;
    // 取出宽度
    CGFloat width = self.view.frame.size.width;
    
    if (translateX <= width * 0.5) {
        // 如果手指移动的距离还不到屏幕的一半,往左边挪 (弹回)
        [UIView animateWithDuration:0.3 animations:^{
            // 重要~~让被右移的view弹回归位,只要清空transform即可办到
            self.view.transform = CGAffineTransformIdentity;
            // 让imageView大小恢复默认的scale
            _screenshotImageView.transform = CGAffineTransformMakeScale(kDefaultScale, kDefaultScale);
            // 让遮盖的透明度恢复默认的alpha 1.0
            _coverView.alpha = kDefaultAlpha;
        } completion:^(BOOL finished) {
            // 重要,动画完成之后,每次都要记得 移除两个view,下次开始拖动时,再添加进来
            [_screenshotImageView removeFromSuperview];
            [_coverView removeFromSuperview];
        }];
    } else {
        // 如果手指移动的距离还超过了屏幕的一半,往右边挪
        [UIView animateWithDuration:0.3 animations:^{
            // 让被右移的view完全挪到屏幕的最右边,结束之后,还要记得清空view的transform
            self.view.transform = CGAffineTransformMakeTranslation(width, 0);
            // 让imageView缩放置为1
            _screenshotImageView.transform = CGAffineTransformMakeScale(1, 1);
            // 让遮盖alpha变为0,变得完全透明
            _coverView.alpha = 0;
        } completion:^(BOOL finished) {
            // 重要~~让被右移的view完全挪到屏幕的最右边,结束之后,还要记得清空view的transform,不然下次再次开始drag时会出问题,因为view的transform没有归零
            self.view.transform = CGAffineTransformIdentity;
            // 移除两个view,下次开始拖动时,再加回来
            [_screenshotImageView removeFromSuperview];
            [_coverView removeFromSuperview];
            
            // 执行正常的Pop操作:移除栈顶控制器,让真正的前一个控制器成为导航控制器的栈顶控制器
            [self popViewControllerAnimated:NO];
            
            // 重要~记得这时候,可以移除截图数组里面最后一张没用的截图了
            [_screenshotImagesArray removeLastObject];
        }];
    }
}
@end
