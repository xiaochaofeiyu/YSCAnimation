//
//  YSCRefreshTableViewController.m
//  YSCAnimationDemo
//
//  Created by yushichao on 2017/2/28.
//  Copyright © 2017年 YSC. All rights reserved.
//

#import "YSCRefreshTableViewController.h"
#import "UITableViewController+YSCRefresh.h"


@interface YSCRefreshTableViewController ()

@property (nonatomic, assign) NSInteger dataNum;

@end

@implementation YSCRefreshTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataNum = 10;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"dataCell"];
}

- (void)viewDidAppear:(BOOL)animated
{
    __weak typeof(self) weakSelf = self;
    self.hasRefreshHeader = YES;
    [self setHeederRefreshingBlock:^{
        //网络请求数据...
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSInteger requestDataNum = 0;
            if (weakSelf.dataNum <= 90) {
                requestDataNum = 10;
            }
            weakSelf.dataNum = weakSelf.dataNum + requestDataNum;
            [weakSelf.tableView reloadData];
            //请求完成后，修改刷新状态
            [weakSelf headerRefreshFinished:MMSCTRefreshStatusSuccess refreshItemsCount:requestDataNum];
        });
    }];
    
    self.hasRefreshFooter = YES;
    [self setFooterRefreshingBlock:^{
        //网络请求数据...
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSInteger requestDataNum = 0;
            if (weakSelf.dataNum <= 90) {
                requestDataNum = 10;
            }
            weakSelf.dataNum = weakSelf.dataNum + requestDataNum;
            [weakSelf.tableView reloadData];
            //请求完成后，修改刷新状态
            [weakSelf footerRefreshFinished:MMSCTRefreshStatusSuccess refreshItemsCount:requestDataNum];
        });
    }];
}

- (void)viewDidDisappear:(BOOL)animated
{
    //一定要移除Observers，否则会crash
    [self removeRefreshHeaderViewObservers];
    [self removeRefreshFooterViewObservers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataNum;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"dataCell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [NSString stringWithFormat:@"第 %ld 行", indexPath.row];
    return cell;
}

@end
