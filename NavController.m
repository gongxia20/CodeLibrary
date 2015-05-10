//
//  NavController.m
//  POST练习
//
//  Created by dfpo on 15/5/10.
//  Copyright (c) 2015年 dfpo. All rights reserved.
//

#import "NavController.h"
#import <QuartzCore/QuartzCore.h>

@interface NavController ()

@end

@implementation NavController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//重写uinavigationcontroller的initwithrootviewcontroller方法
- (id)initWithRootViewController:(UIViewController *)rootViewController{
    _items = [[NSMutableArray alloc]initWithCapacity:0];
    currIndex = -1;
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        //创建镜像图片的初始化大小
        _mirrorView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width*kMirrorRate, self.view.frame.size.height*kMirrorRate)];
        mirrorOrigal = _mirrorView.bounds;
        _mirrorView.center = self.view.center;
        self.delegate = self;
    }
    return self;
} // Convenience method pushes the root view controller without animation.

//重写pushviewcontroller方法
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    //添加镜像view到navigation的view的superview中
    if (!_mirrorView.superview&&self.view.superview) {
        [self.view.superview insertSubview:_mirrorView atIndex:0];
    }
    isPush = YES;
    currIndex++;
    [super pushViewController:viewController animated:animated];
    
}// Uses a horizontal slide transition. Has no effect if the view controller is already in the stack.

//重写popviewcontroller方法
- (UIViewController *)popViewControllerAnimated:(BOOL)animated{
    isPush = NO;
    currIndex--;
    return [super popViewControllerAnimated:animated];
} // Returns the popped controller.

-(UIImage*)genPreviousViewPage{
    if ((currIndex)>=0) {
        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, NO, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        //把当前的整个画面导入到context中，然后通过context输出UIImage，这样就可以把整个屏幕转化为图片
        [self.view.layer renderInContext:context];
        __autoreleasing UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        //把当前页面生成的镜像保存起来
        [_items addObject:image];
        return image;
    }
    return nil;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
}
//实现回调，当成功切换了viewcontroller后回调
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    //当是push进新的viewcontroller
    if (isPush) {
        //调用产生镜像方法，把当前页面生成图片镜像
        [self genPreviousViewPage];
        if (currIndex>0) {
            //把镜像view的image设置成上一个viewcontroller的镜像图片
            [_mirrorView setImage:[_items objectAtIndex:currIndex-1]];
        }
        //如果是pop出了viewcontroller
    }else{
        if (_items.count>=1) {
            //把当前的镜像图片删除
            [_items removeLastObject];
            if (currIndex==0) {
                [_mirrorView setImage:nil];
            }else{
                //把镜像view的image设置成上一个viewcontroller的镜像图片
                [_mirrorView setImage:[_items objectAtIndex:currIndex-1]];
            }
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    
}
//当滑动手势时回调
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if (_items.count<=1) {
        return;
    }
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    CGPoint preppoint  = [touch previousLocationInView:self.view];
    //计算出这次和上次的距离差
    double offset = (point.x-preppoint.x);
    //判断当前view的位置加上距离差有没有超过屏幕范围
    if (self.view.frame.origin.x+offset>=0&&self.view.frame.origin.x+offset<=self.view.frame.size.width) {
        //移动当前view的位置
        self.view.center = CGPointMake(self.view.center.x+offset, self.view.center.y);
        //缩放镜像view的大小
        _mirrorView.bounds = CGRectMake(0, 0, mirrorOrigal.size.width+(self.view.frame.origin.x/self.view.frame.size.width)*(1-kMirrorRate)*mirrorOrigal.size.width, mirrorOrigal.size.height+(self.view.frame.origin.x/self.view.frame.size.width)*(1-kMirrorRate)*mirrorOrigal.size.height);
    }
    
}
//当滑动手势结束后回调
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (_items.count<=1) {
        return;
    }
    //判断view当前的位置，如果超过屏幕一半则认为pop出当前页面
    if (self.view.frame.origin.x>=self.view.frame.size.width/2) {
        [self silderAnimation:RIGHT];
    }else{
        [self silderAnimation:LEFT];
    }
}
//当滑动手势中断时回调
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    if (_items.count<=1) {
        return;
    }
    if (self.view.frame.origin.x>=self.view.frame.size.width/2) {
        [self silderAnimation:RIGHT];
    }else{
        [self silderAnimation:LEFT];
    }
}
//手势结束后调用的动画效果
-(void)silderAnimation:(AnimationDirect)direct{
    switch (direct) {
        case LEFT:
        {   [self.view setUserInteractionEnabled:NO];
            [UIView animateWithDuration:0.5 animations:^{
                self.view.frame = CGRectMake(0, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
                _mirrorView.bounds = CGRectMake(0, 0, mirrorOrigal.size.width, mirrorOrigal.size.height);
            } completion:^(BOOL finished) {
                [self.view setUserInteractionEnabled:YES];
            }];
        }
            break;
        case RIGHT:{
            [self.view setUserInteractionEnabled:NO];
            [UIView animateWithDuration:0.5 animations:^{
                self.view.frame = CGRectMake(self.view.frame.size.width, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
                _mirrorView.bounds = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
            } completion:^(BOOL finished) {
                if (finished) {
                    [self.view setUserInteractionEnabled:YES];
                    [self popViewControllerAnimated
                     :NO];
                    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
                }
            }];
        }
            break;
        default:
            break;
    }
    
}

-(void)dealloc{
    self.delegate = nil;
}
@end