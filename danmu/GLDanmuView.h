//
//  GLDanmuView.h
//  danmu
//
//  Created by newworld on 16/10/19.
//  Copyright © 2016年 siyuxing. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GLDanmuView;

@protocol GLDanmuViewDataSource <NSObject>

- (NSInteger) channelCountInDanmuView:(GLDanmuView *)danmuView;

@end



@interface GLDanmuView : UIView

- (void) stop;
- (void) pause;
- (void) play;

- (void) shootADanmuWithAttributedString:(NSAttributedString *)content index:(NSUInteger)index speed:(CGFloat)speed;


@end
