//
//  WSTableViewCell.m
//  WSTableView
//
//  Created by Tilink on 15/9/16.
//  Copyright (c) 2015年 Jianer. All rights reserved.
//

#import "WSTableViewCell.h"
#import "WSMaskView.h"

#define INDEX_X_FOR_DELETING 50.0f

@interface WSTableViewCell() <WSMaskViewDelegate>
{
    BOOL _isMoving;
    BOOL _hasMoved;
}
@property (nonatomic) WSTableViewCellStyle style;

@property (nonatomic, strong) NSMutableArray *rightActionButtons;
@property (nonatomic, strong) NSMutableArray *leftActionButtons;

@property (nonatomic) CGFloat touchBeganPointX;
@property (nonatomic) CGFloat buttonWidth;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) WSMaskView *maskView;
@end

@implementation WSTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier inTableView:(UITableView *)tableView withWSStyle:(WSTableViewCellStyle)ws_style
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        self.style = ws_style;
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.touchBeganPointX = 0.0f;
        self.dragAnimationDuration = 0.2f;
        self.resetAnimationDuration = 0.4f;
        self.buttonWidth = WSScreenWidth / 6.0f;
        self.dragAcceleration = 1.2f;
        self.isEditing = NO;
        self.tableView = tableView;
        _isMoving = NO;
        _hasMoved = NO;
        assert([self.tableView isKindOfClass:[UITableView class]]);
    }
    return self;
}

-(id)updateWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier inTableView:(UITableView *)tableView withWSStyle:(WSTableViewCellStyle)ws_style {
    if(self)
    {
        self.style = ws_style;
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.touchBeganPointX = 0.0f;
        self.dragAnimationDuration = 0.2f;
        self.resetAnimationDuration = 0.4f;
        self.buttonWidth = WSScreenWidth / 6.0f;
        self.dragAcceleration = 1.2f;
        self.isEditing = NO;
        self.tableView = tableView;
        _isMoving = NO;
        _hasMoved = NO;
        assert([self.tableView isKindOfClass:[UITableView class]]);
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)rightButtonPressed:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    NSInteger index = btn.tag;
    [self actionTrigger:YES index:index];
}

/**
 *  触发事件的最终汇总出口
 *
 *  @param isRight 是否是右边滑动菜单
 *  @param index   索引
 */
- (void)actionTrigger:(BOOL)isRight index:(NSInteger)index
{
    self.indexPath = [self.tableView indexPathForCell:self];
    
    if(isRight)
    {
        // 判断index是否是最后一个
        if([self.delegate respondsToSelector:@selector(WSTableView:commitActionIndex:forIndexPath:)])
        {
            [self.delegate WSTableView:self.tableView commitActionIndex:index forIndexPath:self.indexPath];
        }
    }
    
    self.isEditing = NO;
}

- (void)layoutSubviews
{
    if(_isMoving)
    {
        return;
    }
    [super layoutSubviews];
    [self getSCStyle];
    [self getActionsArray];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(touches.count == 1)
    {
        for(UITouch *touch in touches)
        {
            if(touch.phase != UITouchPhaseBegan)
            {
                return;
            }
            else
            {
                NSLog(@"begin!");
                if(self.contentView.left == 0.0f)
                {
                    self.touchBeganPointX = [touch locationInView:self.tableView].x;
                }
                _isMoving = YES;
            }
        }
    }
    else
    {
        [super touchesBegan:touches withEvent:event];
        return;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(touches.count == 1)
    {
        for(UITouch *touch in touches)
        {
            if(touch.phase == UITouchPhaseEnded || touch.phase == UITouchPhaseCancelled)
            {
                self.tableView.scrollEnabled = YES;
                [super touchesMoved:touches withEvent:event];
                return;
            }
            else if(touch.phase == UITouchPhaseMoved)
            {
//                self.tableView.scrollEnabled = NO;    // 屏蔽tableView的滑动
                _hasMoved = YES;
                self.isEditing = YES;
                CGFloat CurrentXIndex = [touch locationInView:self.tableView].x;
                CGFloat PreviousXIndex = [touch previousLocationInView:self.tableView].x;
                NSLog(@"--- (%f,%f) --- %f",PreviousXIndex,CurrentXIndex,self.touchBeganPointX - CurrentXIndex);
                CGFloat delta = (self.touchBeganPointX - CurrentXIndex) * self.dragAcceleration;
                if(delta > 0)
                {
                    if(delta > WSScreenWidth / 2.0f)
                    {
                        if(CurrentXIndex < INDEX_X_FOR_DELETING)
                        {
                            // 最后一个button需要变宽度了
                            if(delta > WSScreenWidth / 2.0f)
                            {
                                CGFloat t_delta = (delta - (WSScreenWidth / 2.0f))/ self.rightActionButtons.count;
                                [UIView animateWithDuration:self.dragAnimationDuration animations:^{
                                    self.contentView.frame = CGRectMake(-delta, self.contentView.top, self.contentView.width, self.contentView.height);
                                    
                                    CGFloat p_delta = delta;
                                    for(NSInteger i=0;i<self.rightActionButtons.count-1;i++)
                                    {
                                        UIButton *button = [self.rightActionButtons objectAtIndex:i];
                                        button.frame = CGRectMake(self.width - p_delta, 0.0f, self.buttonWidth + t_delta, self.height);
                                        p_delta -= delta / self.rightActionButtons.count;
                                    }
                                    
                                    UIButton *lastOne = [self.rightActionButtons lastObject];
                                    lastOne.frame = CGRectMake(self.width - delta, 0.0f, (self.buttonWidth + t_delta ) * self.rightActionButtons.count , self.height);
                                }];
                            }
                            else
                            {
                                // 位移量超过0像素才移动，这是保证只有右边的区域会出现
                                [UIView animateWithDuration:self.dragAnimationDuration animations:^{
                                    self.contentView.frame = CGRectMake(-delta, self.contentView.top, self.contentView.width, self.contentView.height);
                                    
                                    CGFloat t_delta = delta;
                                    for(NSInteger i=0;i<self.rightActionButtons.count-1;i++)
                                    {
                                        UIButton *button = [self.rightActionButtons objectAtIndex:i];
                                        button.frame = CGRectMake(self.width - t_delta, 0.0f, self.buttonWidth, self.height);
                                        t_delta -= delta / self.rightActionButtons.count;
                                    }
                                    
                                    UIButton *lastOne = [self.rightActionButtons lastObject];
                                    lastOne.frame = CGRectMake(self.width - delta, 0.0f,self.buttonWidth * self.rightActionButtons.count, self.height);
                                }];
                            }
                        }
                        else
                        {
                            CGFloat t_delta = (delta - (WSScreenWidth / 2.0f))/ self.rightActionButtons.count;
                            [UIView animateWithDuration:self.dragAnimationDuration animations:^{
                                self.contentView.frame = CGRectMake(-delta, self.contentView.top, self.contentView.width, self.contentView.height);
                                
                                CGFloat p_delta = delta;
                                for(UIButton *button in self.rightActionButtons)
                                {
                                    button.frame = CGRectMake(self.width - p_delta, 0.0f, self.buttonWidth + t_delta, self.height);
                                    p_delta -= delta / self.rightActionButtons.count;
                                }
                            }];
                        }
                    }
                    else
                    {
                        // 位移量超过0像素才移动，这是保证只有右边的区域会出现
                        [UIView animateWithDuration:self.dragAnimationDuration animations:^{
                            self.contentView.frame = CGRectMake(- delta, self.contentView.top, self.contentView.width, self.contentView.height);
                            
                            CGFloat t_delta = delta;
                            for(UIButton *button in self.rightActionButtons)
                            {
                                button.frame = CGRectMake(self.width - t_delta, 0.0f, self.buttonWidth, self.height);
                                t_delta -= delta / self.rightActionButtons.count;
                            }
                        }];
                    }
                }
            }
            else
            {
                [super touchesMoved:touches withEvent:event];
            }
        }
    }
    else
    {
        [super touchesMoved:touches withEvent:event];
        return;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(touches.count == 1)
    {
        self.tableView.scrollEnabled = YES;
        for(UITouch *touch in touches)
        {
            if(touch.tapCount > 1)
            {
                //双击事件可以由其他recognizer捕获到
                [super touchesEnded:touches withEvent:event];
                return;
            }
            if(touch.phase == UITouchPhaseEnded || touch.phase == UITouchPhaseCancelled)
            {
                CGFloat CurrentXIndex = [touch locationInView:self.tableView].x;
                CGFloat PreviousXIndex = [touch previousLocationInView:self.tableView].x;
                NSLog(@"end ! --(%f)-- %f",CurrentXIndex, PreviousXIndex - CurrentXIndex);
                
                // 判断特殊的删除情况
                if([(UIButton *)self.rightActionButtons.lastObject width] > self.buttonWidth * self.rightActionButtons.count)
                {
                    [self actionTrigger:YES index:2];
                    return;
                }
                
                if(fabs(PreviousXIndex - CurrentXIndex) <= 3.0f)
                {
                    if(!_isEditing)
                    {
                        // 由于把整个手势的检测判断都覆盖了，这里需要把系统的didSelect也重新实现一下
                        self.indexPath = [self.tableView indexPathForCell:self];
                        [self.tableView.delegate tableView:self.tableView didSelectRowAtIndexPath:self.indexPath];
                        return;
                    }
                    
                    // 并没有怎么移动
                    if(self.contentView.left < - WSScreenWidth / 2.0f)
                    {
                        // 需要还原到显示的位置
                        if(!_hasMoved)
                        {
                            return;
                        }
                        [self resetButtonsToDisplayPosition];
                    }
                    else
                    {
                        // 需要还原到初始位置
                        [self resetButtonsToOriginPosition];
                    }
                }
                else
                {
                    if(CurrentXIndex > WSScreenWidth / 2.0f)
                    {
                        // 需要还原到初始位置
                        [self resetButtonsToOriginPosition];
                    }
                    else
                    {
                        // 需要还原到显示的位置
                        if(!_hasMoved)
                        {
                            return;
                        }
                        [self resetButtonsToDisplayPosition];
                    }
                }
            }
        }
    }
    else
    {
        [super touchesEnded:touches withEvent:event];
        return;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(touches.count == 1)
    {
        self.tableView.scrollEnabled = YES;
        for(UITouch *touch in touches)
        {
            if(touch.phase == UITouchPhaseEnded || touch.phase == UITouchPhaseCancelled)
            {
                NSLog(@"cancelled!");
                CGFloat CurrentXIndex = [touch locationInView:self.tableView].x;
                if(CurrentXIndex > WSScreenWidth/2.0f)
                {
                    [self resetButtonsToOriginPosition];
                }
                else
                {
                    [self resetButtonsToDisplayPosition];
                }
            }
        }
    }
    else
    {
        [super touchesCancelled:touches withEvent:event];
        return;
    }
}

- (void)resetButtonsToOriginPosition
{
    [UIView animateWithDuration:self.resetAnimationDuration animations:^{
        self.contentView.frame = CGRectMake(0.0f, self.contentView.top, self.contentView.width, self.contentView.height);
        for(UIButton *button in self.rightActionButtons)
        {
            button.frame = CGRectMake(WSScreenWidth, 0.0f, self.buttonWidth, self.height);
        }
    } completion:^(BOOL finished) {
        _isMoving = NO;
        _hasMoved = NO;
        self.isEditing= NO;
    }];
}

- (void)resetButtonsToDisplayPosition
{
    [UIView animateWithDuration:self.resetAnimationDuration animations:^{
        self.contentView.frame = CGRectMake(- WSScreenWidth/2.0f, self.contentView.top, self.contentView.width, self.contentView.height);
        CGFloat t_start = WSScreenWidth / 2.0f;
        for(UIButton *button in self.rightActionButtons)
        {
            button.frame = CGRectMake(t_start, 0.0f, self.buttonWidth, self.height);
            t_start += self.buttonWidth;
        }
    } completion:^(BOOL finished) {
        _isMoving = NO;
        _hasMoved = NO;
        self.isEditing= YES;
    }];
}

- (void)getActionsArray
{
    self.indexPath = [self.tableView indexPathForCell:self];
    switch (self.style) {
        case WSTableViewCellStyleRight:
        {
            if([self.delegate respondsToSelector:@selector(WSTableView:rightEditActionsForRowAtIndexPath:)])
            {
                NSLog(@"get Actions!");
                self.rightActionButtons = [[self.delegate WSTableView:self.tableView rightEditActionsForRowAtIndexPath:self.indexPath] mutableCopy];
                self.buttonWidth = (self.width / 2.0f)/ self.rightActionButtons.count;
                
                for(UIButton *button in self.rightActionButtons)
                {
                    button.frame = CGRectMake(WSScreenWidth, 0.0f, self.buttonWidth, self.height);
                    button.tag = [self.rightActionButtons indexOfObject:button];
                    [button addTarget:self action:@selector(rightButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                    [self addSubview:button];
                }
            }
        }
            break;
        case WSTableViewCellStyleLeft:
        {
            if([self.delegate respondsToSelector:@selector(WSTableView:leftEditActionsForRowAtIndexPath:)])
            {
                self.leftActionButtons = [[self.delegate WSTableView:self.tableView leftEditActionsForRowAtIndexPath:self.indexPath] mutableCopy];
            }
        }
            break;
        case WSTableViewCellStyleBoth:
        {
            if([self.delegate respondsToSelector:@selector(WSTableView:rightEditActionsForRowAtIndexPath:)])
            {
                self.rightActionButtons = [[self.delegate WSTableView:self.tableView rightEditActionsForRowAtIndexPath:self.indexPath] mutableCopy];
            }
            if([self.delegate respondsToSelector:@selector(WSTableView:leftEditActionsForRowAtIndexPath:)])
            {
                self.leftActionButtons = [[self.delegate WSTableView:self.tableView leftEditActionsForRowAtIndexPath:self.indexPath] mutableCopy];
            }
        }
            break;
        case WSTableViewCellStyleDefault:
        default:
            break;
    }
}

- (void)getSCStyle
{
    self.indexPath = [self.tableView indexPathForCell:self];
    if([self.delegate respondsToSelector:@selector(WSTableView:editStyleForRowAtIndexPath:)])
    {
        self.style = [self.delegate WSTableView:self.tableView editStyleForRowAtIndexPath:self.indexPath];
    }
}

-(void)setIsEditing:(BOOL)isEditing {
    if (_isEditing != isEditing) {
        _isEditing= isEditing;
    }
    
    if (_isEditing) {
        if (!_maskView) {
            _maskView = [[WSMaskView alloc]initWithFrame:self.tableView.bounds];
            _maskView.backgroundColor = [UIColor clearColor];
            _maskView.delegate = self;
            [self.tableView addSubview:_maskView];
        }
    }else {
        [_maskView removeFromSuperview];
        _maskView = nil;
    }
}

-(UIView *)maskView:(WSMaskView *)view didHitPoint:(CGPoint)didHitPoint withEvent:(UIEvent *)event {
    BOOL shouldReceivePointTouch = YES;
    
    CGPoint location = [self.tableView convertPoint:didHitPoint fromView:view];
    CGRect rect = [self.tableView convertRect:self.frame toView:self.tableView];
    shouldReceivePointTouch = CGRectContainsPoint(rect, location);  // location是否在rect里面
    if (!shouldReceivePointTouch) {
        [self hideMenuActive];
        return view;
    }else {
        return [self.contentView hitTest:didHitPoint withEvent:event];
    }
}
-(void)hideMenuActive {
    [self resetButtonsToOriginPosition];
}
@end
