//
//  ViewController.m
//  danmu
//
//  Created by newworld on 16/9/29.
//  Copyright © 2016年 siyuxing. All rights reserved.
//

#import "ViewController.h"
#import "DanmuView.h"


typedef NS_ENUM(NSUInteger,DanmuType) {
    DanmuTypeCoreAnimtion,
    DanmuTypeOpengl
};

@interface ViewController ()

@property (nonatomic) DanmuView *danmuView;

@property (nonatomic) DanmuType type;

@property (weak, nonatomic) IBOutlet UIView *backView;


@end

@implementation ViewController

- (IBAction)renderByOpengl:(id)sender {
    self.type = DanmuTypeOpengl;
}

- (IBAction)renderByAnimation:(id)sender {
    self.type = DanmuTypeCoreAnimtion;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    self.danmuView = [[DanmuView alloc] initWithFrame:self.view.bounds];
    [self.danmuView setUpDanmuChannel:10];
    [self.backView addSubview:self.danmuView];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void) viewDidAppear:(BOOL)animated
{
    [self setupTimer];
   // [self testDanmu:@"你好你好" index:4];
}

- (void) testDanmu:(NSString *)content index:(NSUInteger)index
{
    NSMutableAttributedString *mutableattributedString = [[NSMutableAttributedString alloc] initWithString:content];
    [mutableattributedString addAttribute:NSForegroundColorAttributeName value:[UIColor brownColor] range:NSMakeRange(0, mutableattributedString.string.length)];
    UIFont *boldFont = [UIFont boldSystemFontOfSize:12.0];
    [mutableattributedString addAttribute:NSFontAttributeName value:boldFont range:NSMakeRange(0,mutableattributedString.string.length)];
    
    if (self.type == DanmuTypeOpengl) {
        [self.danmuView shootADanmuWithAttributedString:mutableattributedString index:index speed:2.0];
    }
    if (self.type == DanmuTypeCoreAnimtion) {
        [self.danmuView shootAAnimationWithAttributedString:mutableattributedString index:index speed:2.0];
    }

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setupTimer
{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerUp:) userInfo:nil repeats:YES];
    [timer fire];
}

- (void) timerUp:(NSTimer *)timer
{
    NSArray *danmu = @[@"你好啦啦啦",@"1234",@"opengl大法好",@"性能优化的牛逼",@"发生崩溃怎么办",@"这里是一个超级超级超级长的弹幕，哈哈哈！",@"凑够十个",@"第七个",@"就快成功了",@"hahahahhahahh1213"];
    int i = arc4random() % 10;
    
    [self testDanmu:danmu[i] index:i];
    
}



@end
