//
//  ImageViewController.m
//  healthApp
//
//  Created by Plinio Massaki Nishiye Umezaki on 6/19/15.
//  Copyright (c) 2015 Plinio Massaki Nishiye Umezaki. All rights reserved.
//

#import "ImageViewController.h"

@implementation ImageViewController

@synthesize mealImage;
@synthesize hidden;
@synthesize imagePath;

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.imageView.image = mealImage;
    self.unavailableLabel.hidden = hidden;
}

- (IBAction)ReturnToView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
