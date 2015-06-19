//
//  ImageViewController.h
//  healthApp
//
//  Created by Plinio Massaki Nishiye Umezaki on 6/19/15.
//  Copyright (c) 2015 Plinio Massaki Nishiye Umezaki. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIImage *mealImage;
@property (weak, nonatomic) IBOutlet UILabel *unavailableLabel;
@property NSString *imagePath;
@property BOOL hidden;

- (IBAction)ReturnToView:(id)sender;
@end
