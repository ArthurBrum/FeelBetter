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
@synthesize indexPath;

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.imageView.image = mealImage;
    self.unavailableLabel.hidden = hidden;
}

- (IBAction)ReturnToView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)removePhoto:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Remove Photo" message:@"Do you really want to remove this photo?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    [alert show];
}

/*- (void) alertView:(UIAlertView *) didDismissWithButtonIndex:(NSInteger)buttonIndex) {
    
}*/


- (void) removeImage : (NSString *) imagePath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *path = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat: @"%@.png", imagePath]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    if ([fileManager removeItemAtPath:path error:&error]) {
        NSLog(@"Removed successful");
    }
    else {
        NSLog(@"Could not delete file -:%@", [error localizedDescription]);
    }
}
@end
