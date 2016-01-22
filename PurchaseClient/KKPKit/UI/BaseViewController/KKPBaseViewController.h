

#import <UIKit/UIKit.h>
#import "SCPullRefreshViewController.h"

@interface KKPBaseViewController : SCPullRefreshViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) BOOL needsRefresh;

- (void)viewDidPop;

@end
