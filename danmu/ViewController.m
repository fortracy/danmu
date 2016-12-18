//
//  ViewController.m
//  danmu
//
//  Created by newworld on 16/9/29.
//  Copyright © 2016年 siyuxing. All rights reserved.
//

#import "ViewController.h"
#import "DanmuView.h"
#import "GLDanmuView.h"


typedef NS_ENUM(NSUInteger,DanmuType) {
    DanmuTypeOpengl,
    DanmuTypeCoreAnimtion,
    
};

@interface ViewController ()<GLDanmuViewDataSource,GLDanmuViewDelegate>

@property (nonatomic) GLDanmuView *danmuView;

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

- (IBAction)changeDanmuChannel:(id)sender {
    UIStepper *stepper = sender;
    NSUInteger channelCount = self.danmuView.channelCount+stepper.value;
    if (channelCount>0 &&channelCount<1000) {
      //  [self.danmuView setUpDanmuChannel:channelCount];
    }
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.danmuView = [[GLDanmuView alloc] initWithFrame:self.view.bounds];
    self.danmuView.dataSource = self;
    self.danmuView.delegate = self;
    [self.backView addSubview:self.danmuView];
    [self.danmuView play];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void) viewDidAppear:(BOOL)animated
{
    [self setupTimer];
}

- (void) testDanmu:(NSString *)content index:(NSUInteger)index
{
    NSMutableAttributedString *mutableattributedString = [[NSMutableAttributedString alloc] initWithString:content];
    [mutableattributedString addAttribute:NSForegroundColorAttributeName value:[UIColor brownColor] range:NSMakeRange(0, mutableattributedString.string.length)];
    UIFont *boldFont = [UIFont boldSystemFontOfSize:12.0];
    [mutableattributedString addAttribute:NSFontAttributeName value:boldFont range:NSMakeRange(0,mutableattributedString.string.length)];
    
    if (self.type == DanmuTypeOpengl) {
        [self.danmuView shootADanmuWithAttributedString:mutableattributedString index:index speed:-100.0];
    }
    if (self.type == DanmuTypeCoreAnimtion) {
       // [self.danmuView shootAAnimationWithAttributedString:mutableattributedString index:index speed:2.0];
    }

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setupTimer
{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerUp:) userInfo:nil repeats:NO];
    [timer fire];
}

- (void) timerUp:(NSTimer *)timer
{
    int i = arc4random() % self.danmuView.channelCount;
    
    NSString *danmuContent = [NSString stringWithFormat:@"这里是第%d行弹幕~~~",i];
    [self testDanmu:danmuContent index:i];
    
}

#pragma mark - GLDanmuViewDataSource

- (NSUInteger) channelCountInDanmuView:(GLDanmuView *)danmuView
{
    return 10;
}

- (UIColor  *) defaultColorInDanmuView:(GLDanmuView *)danmuView
{
    return [UIColor yellowColor];
}

- (UIFont *) defaultFontIndanmuView:(GLDanmuView *)danmuView
{
    return [UIFont boldSystemFontOfSize:12.0];
;
}

- (CGFloat) defaultSpeedIndanmuView:(GLDanmuView *)danmuView
{
    return -30.0;
}

#pragma mark - GLDanmuViewDelegate

- (void) danmuSpiriteIsTouched:(GLNode*)danmuSpirite
{
    
}

- (void) danmuView:(GLDanmuView *)danmuView willDisplayDanmuSpirite:(GLNode *)danmuSpirite channelIndex:(NSIndexPath *)indexPath
{
    NSLog(@"current row is %ld",[indexPath indexAtPosition:0]);
    
}

- (void) danmuView:(GLDanmuView *)danmuView didEndDisplayDanmuSpirite:(GLNode *)danmuSpirite channelIndex:(NSIndexPath *)indexPath
{
    NSLog(@"current row is %ld",[indexPath indexAtPosition:0]);
}



@end
