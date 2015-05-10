//
//  NavController.h
//  POST练习
//
//  Created by dfpo on 15/5/10.
//  Copyright (c) 2015年 dfpo. All rights reserved.
//

#import <UIKit/UIKit.h>


//定义镜像图片的缩放比例
#define kMirrorRate 0.98

//定义动画方向
typedef enum{
    LEFT,
    RIGHT
} AnimationDirect;

@interface NavController : UINavigationController<UINavigationControllerDelegate>
{
    //存放push进去的每张镜像图
    NSMutableArray* _items;
    //记录当前页面位置
    NSInteger currIndex;
    //镜像图片的view，上一页的图片
    UIImageView* _mirrorView;
    //镜像图片的初始位置
    CGRect mirrorOrigal;
    //是否push进了一个页面，yes表示push了，no表示pop了
    BOOL isPush;
}
@end