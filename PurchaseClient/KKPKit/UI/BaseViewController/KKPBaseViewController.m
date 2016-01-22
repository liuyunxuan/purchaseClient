

#import "KKPBaseViewController.h"

#import "FrameAccessor.h"

#import "KKPColor.h"

static NSInteger kNaviStackCount = 0;

@interface KKPBaseViewController ()

@end

@implementation KKPBaseViewController

- (void)loadView {
    [super loadView];
    
    self.needsRefresh = YES;

}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = kColor.colorBackgroundGray;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.tableViewInsertTop = 64;

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    kNaviStackCount = self.navigationController.viewControllers.count;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (self.navigationController.viewControllers.count < kNaviStackCount) {
        [self viewDidPop];
    }
}

- (void)viewDidPop {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

@end
