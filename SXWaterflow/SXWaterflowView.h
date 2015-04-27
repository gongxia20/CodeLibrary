#import <UIKit/UIKit.h>

typedef enum {
    SXWaterflowViewMarginTypeTop,
    SXWaterflowViewMarginTypeBottom,
    SXWaterflowViewMarginTypeLeft,
    SXWaterflowViewMarginTypeRight,
    SXWaterflowViewMarginTypeColumn, // 每一列
    SXWaterflowViewMarginTypeRow, // 每一行
} SXWaterflowViewMarginType;

@class SXWaterflowView, SXWaterflowViewCell;

/**
 *  数据源方法
 */
@protocol SXWaterflowViewDataSource <NSObject>
@required
/**
 *  一共有多少个数据
 */
- (NSUInteger)numberOfCellsInWaterflowView:(SXWaterflowView *)waterflowView;
/**
 *  返回index位置对应的cell
 */
- (SXWaterflowViewCell *)waterflowView:(SXWaterflowView *)waterflowView cellAtIndex:(NSUInteger)index;

@optional
/**
 *  一共有多少列
 */
- (NSUInteger)numberOfColumnsInWaterflowView:(SXWaterflowView *)waterflowView;
@end

/**
 *  代理方法
 */
@protocol SXWaterflowViewDelegate <UIScrollViewDelegate>
@optional
/**
 *  第index位置cell对应的高度
 */
- (CGFloat)waterflowView:(SXWaterflowView *)waterflowView heightAtIndex:(NSUInteger)index;
/**
 *  选中第index位置的cell
 */
- (void)waterflowView:(SXWaterflowView *)waterflowView didSelectAtIndex:(NSUInteger)index;
/**
 *  返回间距
 */
- (CGFloat)waterflowView:(SXWaterflowView *)waterflowView marginForType:(SXWaterflowViewMarginType)type;
@end

/**
 *  瀑布流控件
 */
@interface SXWaterflowView : UIScrollView
/**
 *  数据源
 */
@property (nonatomic, weak) id<SXWaterflowViewDataSource> dataSource;
/**
 *  代理
 */
@property (nonatomic, weak) id<SXWaterflowViewDelegate> delegate;

/**
 *  刷新数据（只要调用这个方法，会重新向数据源和代理发送请求，请求数据）
 */
- (void)reloadData;

/**
 *  cell的宽度
 */
- (CGFloat)cellWidth;

/**
 *  根据标识去缓存池查找可循环利用的cell
 */
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier;
@end
