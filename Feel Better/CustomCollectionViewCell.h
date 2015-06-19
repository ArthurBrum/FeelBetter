//
//  CustomCollectionViewCell.h
//  healthApp
//
//  Created by Plinio Massaki Nishiye Umezaki on 6/17/15.
//  Copyright (c) 2015 Plinio Massaki Nishiye Umezaki. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCollectionViewCell : UICollectionViewCell
@property (nonatomic, weak) IBOutlet UIImageView *photo;
@property (nonatomic, weak) IBOutlet UILabel *label;
@end
