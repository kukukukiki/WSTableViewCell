//
//  ViewController.m
//  WSTableViewSwipMore
//
//  Created by Tilink on 15/9/15.
//  Copyright (c) 2015年 Jianer. All rights reserved.
//

#import "ViewController.h"
#import "MessageCell.h"

static NSString * const cellIdentifier = @"cellID";

@interface ViewController () <WSTableViewCellDelegate>

@property (strong, nonatomic) NSMutableArray *itemsArray;
@property (strong, nonatomic) UITableView *tableView;

@end

@implementation ViewController

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.itemsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    if(!cell)
    {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"MessageCell" owner:self options:nil]lastObject];
        [cell updateWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuseIdentifier" inTableView:self.tableView withWSStyle:WSTableViewCellStyleRight];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }
    return cell;
}

#pragma mark - WSTableViewCell Delegate
- (WSTableViewCellStyle)WSTableView:(UITableView *)tableView editStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return WSTableViewCellStyleRight;
}

- (void)WSTableView:(UITableView *)tableView commitActionIndex:(NSInteger)index forIndexPath:(NSIndexPath *)indexPath
{
    if(index == 2)
    {
        [self.itemsArray removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    }
}

- (NSArray *)WSTableView:(UITableView *)tableView leftEditActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @[];
}

- (NSArray *)WSTableView:(UITableView *)tableView rightEditActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIButton *actionButton_1 = [[UIButton alloc]init];
    actionButton_1.backgroundColor = [UIColor lightGrayColor];
    actionButton_1.tag = 0;
    [actionButton_1 setTitle:@"更多" forState:UIControlStateNormal];
    actionButton_1.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    actionButton_1.contentEdgeInsets = UIEdgeInsetsMake(0,15,0,0);
    
    UIButton *actionButton_2 = [[UIButton alloc]init];
    actionButton_2.backgroundColor = [UIColor orangeColor];
    actionButton_2.tag = 1;
    [actionButton_2 setTitle:@"旗标" forState:UIControlStateNormal];
    actionButton_2.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    actionButton_2.contentEdgeInsets = UIEdgeInsetsMake(0,15,0,0);
    
    UIButton *actionButton_3 = [[UIButton alloc]init];
    actionButton_3.backgroundColor = [UIColor redColor];
    actionButton_3.tag = 2;
    [actionButton_3 setTitle:@"删除" forState:UIControlStateNormal];
    actionButton_3.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    actionButton_3.contentEdgeInsets = UIEdgeInsetsMake(0,15,0,0);
    
    return @[actionButton_1,actionButton_2,actionButton_3];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"did select at %@",indexPath);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.itemsArray = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13"].mutableCopy;
    
    //createTableView
    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
