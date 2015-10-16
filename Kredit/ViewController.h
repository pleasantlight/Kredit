//
//  ViewController.h
//  Kredit
//
//  Created by Noam Etzion-Rosenberg on 15-Oct-15.
//  Copyright © 2015 PleasantLight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardTableViewCell.h"

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView* mainTableView;
@property (nonatomic, weak) IBOutlet UIView* loadingView;

- (void)refresh;
- (void)showSpinner;
- (void)hideSpinner;

@end

