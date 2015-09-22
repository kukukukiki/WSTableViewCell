//
//  WSMaskView.m
//  WSTableViewSwipMore
//
//  Created by Tilink on 15/9/16.
//  Copyright (c) 2015年 Jianer. All rights reserved.
//

#import "WSMaskView.h"

@implementation WSMaskView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    
    return self;
}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if ([_delegate respondsToSelector:@selector(maskView:didHitPoint:withEvent:)]) {
        return [self.delegate maskView:self didHitPoint:point withEvent:event];
    }
    return nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
