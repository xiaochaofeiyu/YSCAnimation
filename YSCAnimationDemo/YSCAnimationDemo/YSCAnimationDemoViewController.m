//
//  YSCAnimationDemoViewController.m
//  AnimationLearn
//
//  Created by yushichao on 16/8/19.
//  Copyright © 2016年 yushichao. All rights reserved.
//

#import "YSCAnimationDemoViewController.h"

@interface YSCAnimationDemoViewController ()

@property (nonatomic, strong) NSMutableArray *cellDataArray;
@end

static NSString * const YSCCellDataName     = @"YSCCellDataName";
static NSString * const YSCCellDataClass    = @"YSCCellDataClass";

@implementation YSCAnimationDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Animation Demo";
    self.cellDataArray = [NSMutableArray array];
    [self initCellDates];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initCellDates
{
    [_cellDataArray addObject:@{YSCCellDataName:@"Layer animation", YSCCellDataClass:@"YSCLayerAnimationViewController"}];
    [_cellDataArray addObject:@{YSCCellDataName:@"heart beat animation", YSCCellDataClass:@"YSCHeartBeatPulseViewController"}];
    [_cellDataArray addObject:@{YSCCellDataName:@"ripple animation", YSCCellDataClass:@"YSCRippleAnimationViewController"}];
    [_cellDataArray addObject:@{YSCCellDataName:@"wave animation", YSCCellDataClass:@"YSCWaveAnimationViewController"}];
    [_cellDataArray addObject:@{YSCCellDataName:@"mask animation", YSCCellDataClass:@"YSCMaskAnimationViewController"}];
    [_cellDataArray addObject:@{YSCCellDataName:@"voiceWave animation", YSCCellDataClass:@"YSCVoiceWaveViewController"}];
    [_cellDataArray addObject:@{YSCCellDataName:@"waterWave animation", YSCCellDataClass:@"YSCWaterWaveViewController"}];
    [_cellDataArray addObject:@{YSCCellDataName:@"seawaterWave animation", YSCCellDataClass:@"YSCSeaWaterWaveViewController"}];
    [_cellDataArray addObject:@{YSCCellDataName:@"emitter animation", YSCCellDataClass:@"YSCEmitterAnimationViewController"}];
    [_cellDataArray addObject:@{YSCCellDataName:@"replicator animation", YSCCellDataClass:@"YSCReplicatorAnimationViewController"}];
    [_cellDataArray addObject:@{YSCCellDataName:@"loadGif animation", YSCCellDataClass:@"YSCloadGifViewController"}];
    
    //add 2017/03/01
    [_cellDataArray addObject:@{YSCCellDataName:@"carouselTitle animation", YSCCellDataClass:@"YSCCarouselTitleViewController"}];
    [_cellDataArray addObject:@{YSCCellDataName:@"refreshTable animation", YSCCellDataClass:@"YSCRefreshTableViewController"}];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _cellDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    NSDictionary *cellData = nil;
    if (_cellDataArray.count > indexPath.row) {
        cellData = [_cellDataArray objectAtIndex:indexPath.row];
        cell.textLabel.text = [cellData objectForKey:YSCCellDataName];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *cellData = nil;
    if (_cellDataArray.count > indexPath.row) {
        cellData = [_cellDataArray objectAtIndex:indexPath.row];
        NSString *className = [cellData objectForKey:YSCCellDataClass];
        Class class = NSClassFromString(className);
        if ([class isSubclassOfClass:[UIViewController class]]) {
            UIViewController *entranceClassinStance = [[class alloc] init];
            [self.navigationController pushViewController:entranceClassinStance animated:YES];
        }
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
