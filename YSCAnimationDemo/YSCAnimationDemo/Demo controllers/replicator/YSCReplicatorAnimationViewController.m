//
//  YSCReplicatorAnimationViewController.m
//  YSCAnimationDemo
//
//  Created by 工作号 on 16/8/28.
//  Copyright © 2016年 YSC. All rights reserved.
//

#import "YSCReplicatorAnimationViewController.h"

@interface YSCReplicatorAnimationViewController ()

@property (nonatomic, strong) NSMutableArray *cellDataArray;
@end

static NSString * const YSCCellDataName     = @"YSCCellDataName";
static NSString * const YSCCellDataClass    = @"YSCCellDataClass";

@implementation YSCReplicatorAnimationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Replicator Animation Demo";
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
    [_cellDataArray addObject:@{YSCCellDataName:@"matrix animation", YSCCellDataClass:@"YSCCircleReplicatorAnimationViewController"}];
    [_cellDataArray addObject:@{YSCCellDataName:@"ripple animation", YSCCellDataClass:@"YSCCircleRippleViewController"}];
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
