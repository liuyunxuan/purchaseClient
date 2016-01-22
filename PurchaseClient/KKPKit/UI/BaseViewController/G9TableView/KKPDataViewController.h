

#import "KKPBaseViewController.h"

@interface KKPDataViewController : KKPBaseViewController

@property (nonatomic, strong) NSArray *dataList;

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

@end
