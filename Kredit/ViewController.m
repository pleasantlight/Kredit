//
//  ViewController.m
//  Kredit
//
//  Created by Noam Etzion-Rosenberg on 15-Oct-15.
//  Copyright © 2015 PleasantLight. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "ViewController.h"
#import "DataManager.h"
#import "CardTableViewCell.h"

@interface ViewController()

@property (nonatomic, strong) NSArray* localCards;
@property (nonatomic, strong) UIRefreshControl* refreshControl;

- (void)refreshCards;

@end


@implementation ViewController

#pragma mark - Public Methods:

- (void)refresh {
    [[DataManager sharedInstance] getCardsWithCompletion:^(BOOL success, NSArray* cards) {
        if (success) {
            self.localCards = cards;
            [self.mainTableView reloadData];
        }
    }];
}

- (void)showSpinner {
    self.loadingView.alpha = 0.0;
    self.loadingView.hidden = NO;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.loadingView.alpha = 1.0;
    }];
}

- (void)hideSpinner {
    [UIView animateWithDuration:0.25 animations:^{
        self.loadingView.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.loadingView.hidden = YES;
    }];
}


#pragma mark - UIViewController methods:

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor darkGrayColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(refreshCards) forControlEvents:UIControlEventValueChanged];

    [self.mainTableView addSubview:self.refreshControl];
    [self.mainTableView sendSubviewToBack:self.refreshControl];
    
    self.localCards = @[];
    [self refresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


#pragma mark - UITableViewDataSource Methods:

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.localCards count];
}


- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    NSString* cellID = @"CARD_TABLE_VIEW_CELL_ID";

    NSManagedObject* card = self.localCards[indexPath.row];
    
    CardTableViewCell* cell = (CardTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[CardTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    [cell setCard:card];
    
    return cell;
}


#pragma mark - UITableViewDelegate Methods:

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    return [CardTableViewCell cellHeight];
}


#pragma mark - Private Methods:

- (void)refreshCards {
    [[DataManager sharedInstance] updateCardsWithCompletion:^(BOOL success) {
        [self refresh];
        [self.mainTableView layoutIfNeeded];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
        });
    }];
}

@end
