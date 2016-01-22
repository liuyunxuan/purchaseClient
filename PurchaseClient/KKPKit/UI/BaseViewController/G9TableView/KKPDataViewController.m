

#import "KKPDataViewController.h"

#import "SCNavigation.h"
#import "KKPColor.h"

#import "KKPTableViewCell.h"

#define RGB(c,a)    [UIColor colorWithRed:((c>>16)&0xFF)/256.0  green:((c>>8)&0xFF)/256.0   blue:((c)&0xFF)/256.0   alpha:a]

#define kLineColorBlackDark  RGB(0xdbdbdb, 1.0)
#define kLineColorBlackLight RGB(0xebebeb, 1.0)

static NSString * const cellIndentifier = @"cellIndentifier";

@interface KKPDataViewController ()

@end

@implementation KKPDataViewController


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) {
        return nil;
    }
    
    return self;
    
}

- (void)loadView
{
    [super loadView];
    
    [self _configureViews];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableViewInsertTop = 64;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Configure Views

- (void)_configureViews {
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    [self.view addSubview:self.tableView];
    
    [self.tableView registerClass:[KKPTableViewCell class] forCellReuseIdentifier:cellIndentifier];
    
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *data = self.dataList[section];
    return data.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *data = self.dataList[indexPath.section];
    return [KKPTableViewCell cellHeightForDict:data[indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KKPTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[KKPTableViewCell alloc] initWithStyle:KKPTableViewCellStyleDefault reuseIdentifier:cellIndentifier];
    }
    
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(KKPTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // configure line
    cell.topLineHidden = (indexPath.row != 0);
    cell.bottomLineColor = kLineColorBlackDark;
    cell.bottomLineHidden = NO;
    if (indexPath.row == ([self.tableView numberOfRowsInSection:indexPath.section] - 1)) {
        cell.bottomLineColor = kLineColorBlackDark;
        cell.bottomLineInsertLeft = 0;
        cell.bottomLineInsertRight = 0;
    } else {
        cell.bottomLineColor = kLineColorBlackLight;
        cell.bottomLineInsertLeft = 10;
        cell.bottomLineInsertRight = 10;
    }
    
    if ([cell respondsToSelector:@selector(setDataDict:)]) {
        cell.dataDict = self.dataList[indexPath.section][indexPath.row];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

@end