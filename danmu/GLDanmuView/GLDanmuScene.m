//
//  GLDanmuScene.m
//  danmu
//
//  Created by newworld on 16/10/19.
//  Copyright © 2016年 siyuxing. All rights reserved.
//

#import "GLDanmuScene.h"

@interface GLDanmuScene ()

@property (nonatomic) GLKBaseEffect *effect;

@end


@implementation GLDanmuScene

- (instancetype) initWithEffect:(GLKBaseEffect *)effect
{
    if (!effect) {
        return nil;
    }
    
    if (self = [super init]) {
        self.effect = effect;
    }
    
    return self;
}

- (instancetype) init
{
    return [self initWithEffect:nil];
}

@end
