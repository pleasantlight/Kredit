//
//  CardTableViewCell.h
//  Kredit
//
//  Created by Noam Etzion-Rosenberg on 15-Oct-15.
//  Copyright © 2015 PleasantLight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface CardTableViewCell : UITableViewCell

@property (nonatomic, strong) NSManagedObject* card;

+ (CGFloat)cellHeight;

@end
