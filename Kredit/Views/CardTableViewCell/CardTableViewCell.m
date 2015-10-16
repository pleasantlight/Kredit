//
//  CardTableViewCell.m
//  Kredit
//
//  Created by Noam Etzion-Rosenberg on 15-Oct-15.
//  Copyright © 2015 PleasantLight. All rights reserved.
//

#import "CardTableViewCell.h"
#import "CommManager.h"

@interface CardTableViewCell()

@property (nonatomic, strong) UIImageView* backgroundImageView;
@property (nonatomic, strong) UILabel* creditCardNumberLabel;
@property (nonatomic, strong) UILabel* nameLabel;
@property (nonatomic, strong) UILabel* goodTitleLabel;
@property (nonatomic, strong) UILabel* thruTitleLabel;
@property (nonatomic, strong) UILabel* expirationDateLabel;

- (void)createSubviews;
- (NSString*)formatNameForCard:(NSManagedObject*)theCard;
- (NSString*)formatNumberForCard:(NSManagedObject*)theCard;
- (NSString*)formatExpirationForCard:(NSManagedObject*)theCard;
- (void)loadImageForCard:(NSManagedObject*)theCard;

@end


@implementation CardTableViewCell

#pragma mark - Class Methods:

+ (CGFloat)cellHeight {
    CGSize mainScreenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat cellWidth = mainScreenSize.width;
    CGFloat cellHeight = cellWidth / 1.6f;
    return cellHeight;
}


#pragma mark - Initializers:

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _backgroundImageView = nil;
        _creditCardNumberLabel = nil;
        _nameLabel = nil;
        _goodTitleLabel = nil;
        _thruTitleLabel = nil;
        _expirationDateLabel = nil;
        
        [self createSubviews];
    }
    
    return self;
}


#pragma mark - Setters:

- (void)setCard:(NSManagedObject*)theNewCard {
    self.creditCardNumberLabel.text = [self formatNumberForCard:theNewCard];
    self.nameLabel.text = [self formatNameForCard:theNewCard];
    self.expirationDateLabel.text = [self formatExpirationForCard:theNewCard];
    [self loadImageForCard:theNewCard];

    self.contentView.backgroundColor = RGB(36,41,56);
}


#pragma mark - UIView Methods:

- (void)layoutSubviews {
    CGFloat cellWidth = CGRectGetWidth(self.bounds);
    CGFloat cellHeight = CGRectGetHeight(self.bounds);
    CGFloat creditCardLabelFrameHeight = MAX(cellHeight * 0.1, 10.0);
    CGRect creditCardNumberLabelFrame = CGRectMake(0, 0, cellWidth - 20.0, creditCardLabelFrameHeight);
    self.creditCardNumberLabel.frame = creditCardNumberLabelFrame;
    self.creditCardNumberLabel.center = CGPointMake(cellWidth / 2, cellHeight / 2);
    self.creditCardNumberLabel.alpha = 1.0;
    
    CGFloat nameLabelFrameOriginY = roundf(CGRectGetMaxY(self.creditCardNumberLabel.frame) + (1 * creditCardLabelFrameHeight));
    CGFloat nameLabelFrameHeight = roundf(creditCardLabelFrameHeight * 0.8);
    CGRect nameLabelFrame = CGRectMake(40.0f, nameLabelFrameOriginY, cellWidth - 60.0f, nameLabelFrameHeight);
    self.nameLabel.frame = nameLabelFrame;
    self.nameLabel.alpha = 1.0;
    
    CGFloat goodTitleLabelOriginX = CGRectGetMinX(nameLabelFrame);
    CGFloat goodTitleLabelOriginY = roundf(CGRectGetMaxY(nameLabelFrame) + (0.7 * creditCardLabelFrameHeight));
    CGFloat goodTitleLabelWidth = roundf(creditCardLabelFrameHeight);
    CGFloat goodTitleLabelHeight = roundf(creditCardLabelFrameHeight * 0.35);
    CGRect goodTitleLabelFrame = CGRectMake(goodTitleLabelOriginX, goodTitleLabelOriginY, goodTitleLabelWidth, goodTitleLabelHeight);
    self.goodTitleLabel.frame = goodTitleLabelFrame;
    self.goodTitleLabel.alpha = 1.0;

    CGFloat thruTitleLabelOriginX = CGRectGetMinX(nameLabelFrame);
    CGFloat thruTitleLabelOriginY = CGRectGetMaxY(goodTitleLabelFrame);
    CGFloat thruTitleLabelWidth = roundf(creditCardLabelFrameHeight);
    CGFloat thruTitleLabelHeight = goodTitleLabelHeight;
    CGRect thruTitleLabelFrame = CGRectMake(thruTitleLabelOriginX, thruTitleLabelOriginY, thruTitleLabelWidth, thruTitleLabelHeight);
    self.thruTitleLabel.frame = thruTitleLabelFrame;
    self.thruTitleLabel.alpha = 1.0;
    
    CGFloat expirationDateLabelOriginX = CGRectGetMaxX(thruTitleLabelFrame) + 2;
    CGFloat expirationDateLabelOriginY = CGRectGetMinY(goodTitleLabelFrame);
    CGFloat expirationDateLabelWidth = cellWidth - expirationDateLabelOriginX - 20.0;
    CGFloat expirationDateLabelHeight = CGRectGetMaxY(thruTitleLabelFrame) - CGRectGetMinY(goodTitleLabelFrame);
    CGRect expirationDateLabelFrame = CGRectMake(expirationDateLabelOriginX, expirationDateLabelOriginY, expirationDateLabelWidth, expirationDateLabelHeight);
    self.expirationDateLabel.frame = expirationDateLabelFrame;
    self.expirationDateLabel.alpha = 1.0;
}


#pragma mark - Private Methods:

- (void)createSubviews {
    CGFloat cellWidth = [[UIScreen mainScreen] bounds].size.width;

    self.backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectInset(self.contentView.bounds, 8, 5)];
    self.backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.backgroundImageView.image = nil;
    [self.contentView addSubview:self.backgroundImageView];
    
    CGFloat creditCardNumberFontSize = roundf(20.0f + (6.0f * ((cellWidth - 320.0f) / 94.0f)));
    UIFont* creditCardNumberFont = [UIFont fontWithName:@"Kredit-Regular" size:creditCardNumberFontSize];
    
    self.creditCardNumberLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.creditCardNumberLabel.font = creditCardNumberFont;
    self.creditCardNumberLabel.textColor = [UIColor whiteColor];
    self.creditCardNumberLabel.autoresizingMask = 0;
    self.creditCardNumberLabel.textAlignment = NSTextAlignmentCenter;
    self.creditCardNumberLabel.alpha = 0.0;
    [self.contentView addSubview:self.creditCardNumberLabel];
    
    UIFont* nameLabelFont = [UIFont fontWithName:@"Kredit-Regular" size:(creditCardNumberFontSize - 4)];

    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.nameLabel.font = nameLabelFont;
    self.nameLabel.textColor = [UIColor whiteColor];
    self.nameLabel.autoresizingMask = 0;
    self.nameLabel.textAlignment = NSTextAlignmentLeft;
    self.nameLabel.lineBreakMode = NSLineBreakByClipping;
    self.nameLabel.alpha = 0.0;
    [self.contentView addSubview:self.nameLabel];
    
    CGFloat goodThruLabelsFontSize = roundf(creditCardNumberFontSize / 3.0f);
    UIFont* kreditFontTiny = [UIFont fontWithName:@"Kredit-Regular" size:goodThruLabelsFontSize];
    
    self.goodTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.goodTitleLabel.font = kreditFontTiny;
    self.goodTitleLabel.textColor = [UIColor whiteColor];
    self.goodTitleLabel.autoresizingMask = 0;
    self.goodTitleLabel.text = @"GOOD";
    self.goodTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.goodTitleLabel.alpha = 0.0;
    [self.contentView addSubview:self.goodTitleLabel];
    
    self.thruTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.thruTitleLabel.font = kreditFontTiny;
    self.thruTitleLabel.textColor = [UIColor whiteColor];
    self.thruTitleLabel.autoresizingMask = 0;
    self.thruTitleLabel.text = @"THRU";
    self.thruTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.thruTitleLabel.alpha = 0.0;
    [self.contentView addSubview:self.thruTitleLabel];

    self.expirationDateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.expirationDateLabel.font = nameLabelFont;
    self.expirationDateLabel.textColor = [UIColor whiteColor];
    self.expirationDateLabel.autoresizingMask = 0;
    self.expirationDateLabel.textAlignment = NSTextAlignmentLeft;
    self.expirationDateLabel.alpha = 0.0;
    [self.contentView addSubview:self.expirationDateLabel];
}

- (NSString*)formatNameForCard:(NSManagedObject*)theCard {
    NSString* firstName = [theCard valueForKey:@"first_name"];
    NSString* lastName = [theCard valueForKey:@"last_name"];
    NSString* name = ([firstName isKindOfClass:[NSString class]] && [firstName length] > 0) ? firstName : @"";
    if ([lastName isKindOfClass:[NSString class]] && [lastName length] > 0) {
        if ([name length] > 0) {
            name = [NSString stringWithFormat:@"%@ %@", name, lastName];
        }
        else {
            name = lastName;
        }
    }

    return name;
}

- (NSString*)formatNumberForCard:(NSManagedObject*)theCard {
    NSString* number = [theCard valueForKey:@"card_number"];
    if ([number isKindOfClass:[NSString class]] == NO || [number length] == 0)
        return @"";
    
    NSArray* parts = [number componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
    NSString* formattedNumber = [parts componentsJoinedByString:@"   "];
    return formattedNumber;
}

- (NSString*)formatExpirationForCard:(NSManagedObject*)theCard {
    NSString* expiration = [theCard valueForKey:@"expiration_date"];
    if ([expiration isKindOfClass:[NSString class]] == NO || [expiration length] == 0)
        return @"";
    
    NSArray* parts = [expiration componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
    if ([parts count] == 0 || [parts count] > 2)
        return expiration;
    
    NSUInteger month = [parts[0] integerValue];
    if (month == 0 || month > 12)
        return expiration;
    
    NSUInteger year = [parts[1] integerValue];
    if (year < 1970 || year > 2069)
        return expiration;
    
    NSString* formattedExpiration = [NSString stringWithFormat:@"%02d / %02d", (int)(month), (int)(year % 100)];
    return formattedExpiration;
}

- (void)loadImageForCard:(NSManagedObject*)theCard {
    NSString* imageURLString = [theCard valueForKey:@"background_image_url"];
    if ([imageURLString isKindOfClass:[NSString class]] == NO || [imageURLString length] == 0) {
        self.backgroundImageView.alpha = 0.0;
        return;
    }

    NSURL* imageURL = [NSURL URLWithString:imageURLString];
    [[CommManager sharedInstance] loadImageWithURL:imageURL andCompletion:^(BOOL success, UIImage *image) {
        if ([image isKindOfClass:[UIImage class]]) {
            self.backgroundImageView.image = image;
            self.backgroundImageView.alpha = 1.0;
        }
        else {
            self.backgroundImageView.alpha = 0.0;
        }
    }];
}

@end
