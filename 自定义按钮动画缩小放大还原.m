



- (void)btnOnClick:(CZTabBarButton *)btn
{
    
    // 2.切换按钮的状态
    // 取消上一次选中
    self.currenSelectedBtn.selected = NO;
    // 选中当前点击的按钮
    btn.selected = YES;
    // 记录当前选中的按钮
    self.currenSelectedBtn = btn;
    
    // 3.让当前选中按钮执行动画
    // 缩小 -- > 放大 --> 还原
    [UIView animateWithDuration:0.2 animations:^{
        // 缩小
        // sx / sy 如果是1代表不缩放, 如果大于1代表放大 如果小于1代表缩小
        btn.transform = CGAffineTransformMakeScale(0.4, 0.4);
        
    } completion:^(BOOL finished) {
        
       [UIView animateWithDuration:0.1 animations:^{
           // 放大
            btn.transform = CGAffineTransformMakeScale(1.4, 1.4);
           
       } completion:^(BOOL finished) {
           
           [UIView animateWithDuration:0.1 animations:^{
               // 还原
               btn.transform = CGAffineTransformIdentity;
           }];
       }];
    }];
    
    // 1.切换控制器, 通知tabbarcontroller
    if ([self.delegate respondsToSelector:@selector(tabBar:selectedBtnFrom:to:)]) {
        [self.delegate tabBar:self selectedBtnFrom:self.currenSelectedBtn.tag to:btn.tag];
    }
    
}