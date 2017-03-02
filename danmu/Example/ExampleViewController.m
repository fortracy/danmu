//
//  ExampleViewController.m
//  danmu
//
//  Created by newworld on 2017/3/2.
//  Copyright © 2017年 siyuxing. All rights reserved.
//

#import "ExampleViewController.h"
#import "GLDanmuView.h"

@interface ExampleViewController ()<GLDanmuViewDelegate,GLDanmuViewDataSource>

@property (weak, nonatomic) IBOutlet GLDanmuView *danmuView;

@end

@implementation ExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.danmuView.delegate = self;
    self.danmuView.dataSource = self;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.danmuView play];
    //测试
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setupTimer];
    });

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

#pragma mark - timer

- (void) setupTimer
{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerUp:) userInfo:nil repeats:YES];
    [timer fire];
}

- (void) timerUp:(NSTimer *)timer
{
    int i = arc4random() % self.danmuView.channelCount;
    
    NSString *danmuContent = [NSString stringWithFormat:@"这里是第%d行弹幕~~~",i];
    [self testDanmu:danmuContent index:i];
    
}

- (void) testDanmu:(NSString *)content index:(NSUInteger)index
{
    NSMutableAttributedString *mutableattributedString = [[NSMutableAttributedString alloc] initWithString:content];
    [mutableattributedString addAttribute:NSForegroundColorAttributeName value:[UIColor brownColor] range:NSMakeRange(0, mutableattributedString.string.length)];
    UIFont *boldFont = [UIFont boldSystemFontOfSize:12.0];
    [mutableattributedString addAttribute:NSFontAttributeName value:boldFont range:NSMakeRange(0,mutableattributedString.string.length)];
    
    [self.danmuView shootADanmuWithAttributedString:mutableattributedString index:index speed:-100.0];
}

#pragma mark button

- (IBAction)clearDanmu:(id)sender {
    [self.danmuView clear];
}

- (IBAction)pauseDanmu:(id)sender {
    [self.danmuView pause];
}

- (IBAction)startDanmu:(id)sender {
    if (![self.danmuView isPlay]) {
        [self.danmuView play];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
