//
//  WSTableViewCell.h
//  WSTableView
//
//  Created by Tilink on 15/9/16.
//  Copyright (c) 2015年 Jianer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewExt.h"
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WSTableViewCellStyle) {
    WSTableViewCellStyleDefault = 0,    // default table view cell style, just like UITableViewCell
    WSTableViewCellStyleRight,          // table view cell with right button menu
    WSTableViewCellStyleLeft,           // table view cell with left button menu
    WSTableViewCellStyleBoth            // table view cell with both side button menu
};

@class WSTableViewCell;
@protocol WSTableViewCellDelegate <NSObject>

@required
/**
 *  获取每一行cell对应的编辑样式
 *
 *  @param tableView 父级tableview
 *  @param indexPath 索引
 *
 *  @return
 */
- (WSTableViewCellStyle)WSTableView:(UITableView *)tableView editStyleForRowAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  获取每一行cell对应的按钮集合的委托方法，在layoutsubview的时候调用
 *
 *  @param tableView 父级tableview
 *  @param indexPath 索引
 *
 *  @return WSTableViewCellRowActionButton的数组
 */
- (NSArray *)WSTableView:(UITableView *)tableView rightEditActionsForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSArray *)WSTableView:(UITableView *)tableView leftEditActionsForRowAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  每一行cell的动作触发回调
 *
 *  @param tableView 父级tableview
 *  @param index     动作index
 *  @param indexPath 索引
 */
- (void)WSTableView:(UITableView *)tableView commitActionIndex:(NSInteger)index forIndexPath:(NSIndexPath *)indexPath;

@end

@interface WSTableViewCell : UITableViewCell

/**
 *  滑动过程中的动画刷新间隔，减小这个值会加速滑动的动效，默认值是0.2s
 *  Duration of dragging animation, set it lower to increase the speed of dragging, default is 0.2s
 */
@property (nonatomic) CGFloat dragAnimationDuration;

/**
 *  重置动画的时长，设置的更大能够获得更好的用户体验，默认值是0.4s
 *  Duration of reset animation of buttons, set it higher to get better user experience, default is 0.4s
 */
@property (nonatomic) CGFloat resetAnimationDuration;

/**
 *  滑动的时候的加速度，这个可以放大你手指位移的距离，默认值是1.2，就可以和系统实现的效果差不多了
 *  Acceleration when dragging, set higher to make movement wider, default is 1.2, which is similar to the effect of system implementation
 */
@property (nonatomic) CGFloat dragAcceleration;

/**
 *  是否正在编辑状态
 *  Bool variable indicated the state whether you are editing your cell or not
 */
@property (nonatomic) BOOL isEditing;

@property (nonatomic, weak) id<WSTableViewCellDelegate> delegate;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier inTableView:(UITableView *)tableView withWSStyle:(WSTableViewCellStyle)ws_style;

- (instancetype)updateWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier inTableView:(UITableView *)tableView withWSStyle:(WSTableViewCellStyle)ws_style;

@end
