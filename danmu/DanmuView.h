//
//  DanmuView.h
//  danmu
//
//  Created by newworld on 16/10/1.
//  Copyright © 2016年 siyuxing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DanmuView : UIView

- (void) shootADanmuWithAttributedString:(NSAttributedString *)content index:(NSUInteger)index speed:(CGFloat)speed;

- (void) shootAAnimationWithAttributedString:(NSAttributedString *)content index:(NSUInteger)index speed:(CGFloat)speed;

- (void) setUpDanmuChannel:(NSUInteger)channelCount;

- (void) update:(BOOL)state;

@end
