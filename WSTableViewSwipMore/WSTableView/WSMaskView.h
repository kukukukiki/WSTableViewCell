//
//  WSMaskView.h
//  WSTableViewSwipMore
//
//  Created by Tilink on 15/9/16.
//  Copyright (c) 2015年 Jianer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WSMaskView;
@protocol WSMaskViewDelegate <NSObject>

-(UIView *)maskView:(WSMaskView *)view didHitPoint:(CGPoint)didHitPoint withEvent:(UIEvent *)event;

@end

@interface WSMaskView : UIView

@property (nonatomic, assign) id <WSMaskViewDelegate> delegate;

@end
