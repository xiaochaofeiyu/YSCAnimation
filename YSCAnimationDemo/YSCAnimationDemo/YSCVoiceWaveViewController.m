//
//  YSCVoiceWaveViewController.m
//  YSCAnimationDemo
//
//  Created by yushichao on 16/8/24.
//  Copyright © 2016年 YSC. All rights reserved.
//

#import "YSCVoiceWaveViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "YSCVoiceWaveView.h"
#import "YSCVoiceLoadingCircleView.h"

#import "YSCNewVoiceWaveView.h"

@interface YSCVoiceWaveViewController ()

@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) YSCVoiceWaveView *voiceWaveView;
@property (nonatomic,strong) UIView *voiceWaveParentView;
@property (nonatomic, strong) YSCVoiceLoadingCircleView *loadingView;
@property (nonatomic, strong) NSTimer *updateVolumeTimer;
@property (nonatomic, strong) UIButton *voiceWaveShowButton;

@property (nonatomic, strong) YSCNewVoiceWaveView *voiceWaveViewNew;
@property (nonatomic,strong) UIView *voiceWaveParentViewNew;
@end

@implementation YSCVoiceWaveViewController

- (void)dealloc
{
    [_voiceWaveView removeFromParent];
    [_loadingView stopLoading];
    _voiceWaveView = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupRecorder];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view insertSubview:self.voiceWaveParentView atIndex:0];
    [self.voiceWaveView showInParentView:self.voiceWaveParentView];
    [self.voiceWaveView startVoiceWave];
    
    [self.view insertSubview:self.voiceWaveParentViewNew atIndex:1];
    [self.voiceWaveViewNew showInParentView:self.voiceWaveParentViewNew];
    [self.voiceWaveViewNew startVoiceWave];
    
    [[NSRunLoop currentRunLoop] addTimer:self.updateVolumeTimer forMode:NSRunLoopCommonModes];
    
    [self.view addSubview:self.voiceWaveShowButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateVolume:(NSTimer *)timer
{
    [self.recorder updateMeters];
    CGFloat normalizedValue = pow (10, [self.recorder averagePowerForChannel:0] / 20);
    [_voiceWaveView changeVolume:normalizedValue];
    
    [_voiceWaveViewNew changeVolume:normalizedValue];
}

- (void)voiceWaveShowButtonTouched:(UIButton *)sender
{
    static NSInteger status = 1;
    status++;
    if (status % 2 == 0) {
        [_voiceWaveShowButton setTitle:@"show" forState:UIControlStateNormal];
        [self.voiceWaveView stopVoiceWaveWithShowLoadingViewCallback:^{
            [self.updateVolumeTimer invalidate];
            _updateVolumeTimer = nil;
            [self.loadingView startLoadingInParentView:self.view];
        }];
    } else {
        [_voiceWaveShowButton setTitle:@"hide" forState:UIControlStateNormal];
        [self.loadingView stopLoading];
        [self.voiceWaveView showInParentView:self.voiceWaveParentView];
        [self.voiceWaveView startVoiceWave];
        [[NSRunLoop currentRunLoop] addTimer:self.updateVolumeTimer forMode:NSRunLoopCommonModes];
    }
}

-(void)setupRecorder
{
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    NSDictionary *settings = @{AVSampleRateKey:          [NSNumber numberWithFloat: 44100.0],
                               AVFormatIDKey:            [NSNumber numberWithInt: kAudioFormatAppleLossless],
                               AVNumberOfChannelsKey:    [NSNumber numberWithInt: 2],
                               AVEncoderAudioQualityKey: [NSNumber numberWithInt: AVAudioQualityMin]};
    
    NSError *error;
    self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    if(error) {
        NSLog(@"Ups, could not create recorder %@", error);
        return;
    }
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (error) {
        NSLog(@"Error setting category: %@", [error description]);
    }
    [self.recorder prepareToRecord];
    [self.recorder setMeteringEnabled:YES];
    [self.recorder record];
}

#pragma mark - getters

- (YSCVoiceWaveView *)voiceWaveView
{
    if (!_voiceWaveView) {
        self.voiceWaveView = [[YSCVoiceWaveView alloc] init];
    }
    
    return _voiceWaveView;
}

- (UIView *)voiceWaveParentView
{
    if (!_voiceWaveParentView) {
        self.voiceWaveParentView = [[UIView alloc] init];
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        _voiceWaveParentView.frame = CGRectMake(0, 0, screenSize.width, 320);
//        _voiceWaveParentView.center = CGPointMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0);
    }
    
    return _voiceWaveParentView;
}

- (YSCNewVoiceWaveView *)voiceWaveViewNew
{
    if (!_voiceWaveViewNew) {
        self.voiceWaveViewNew = [[YSCNewVoiceWaveView alloc] init];
        [_voiceWaveViewNew setVoiceWaveNumber:6];
    }
    
    return _voiceWaveViewNew;
}

- (UIView *)voiceWaveParentViewNew
{
    if (!_voiceWaveParentViewNew) {
        self.voiceWaveParentViewNew = [[UIView alloc] init];
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        _voiceWaveParentViewNew.frame = CGRectMake(0, 330, screenSize.width, 320);
//        _voiceWaveParentViewNew.center = CGPointMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0);
    }
    
    return _voiceWaveParentViewNew;
}

- (YSCVoiceLoadingCircleView *)loadingView
{
    if (!_loadingView) {
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        CGPoint loadViewCenter = CGPointMake(screenSize.width / 2.0, 160);
        self.loadingView = [[YSCVoiceLoadingCircleView alloc] initWithCircleRadius:25 center:loadViewCenter];
    }
    
    return _loadingView;
}

- (UIButton *)voiceWaveShowButton
{
    if (!_voiceWaveShowButton) {
        self.voiceWaveShowButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
        _voiceWaveShowButton.center = CGPointMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0 + 200);
        [_voiceWaveShowButton setTitle:@"hide" forState:UIControlStateNormal];
        _voiceWaveShowButton.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
        [_voiceWaveShowButton addTarget:self action:@selector(voiceWaveShowButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _voiceWaveShowButton;
}

- (NSTimer *)updateVolumeTimer
{
    if (!_updateVolumeTimer) {
        self.updateVolumeTimer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(updateVolume:) userInfo:nil repeats:YES];
    }
    
    return _updateVolumeTimer;
}

@end
