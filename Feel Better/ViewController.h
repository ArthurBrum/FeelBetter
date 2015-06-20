//
//  ViewController.h
//  TESTEAD3
//
//  Created by Lucas Yamashita on 6/17/15.
//  Copyright (c) 2015 YUKIOSOFTWARE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@interface ViewController : UIViewController <ADBannerViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *pressureMbLabel;
@property (weak, nonatomic) IBOutlet UILabel *tempCLabel;

@end

