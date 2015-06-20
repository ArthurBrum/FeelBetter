//
//  MainViewController.m
//  healthApp
//
//  Created by Plinio Massaki Nishiye Umezaki on 6/16/15.
//  Copyright (c) 2015 Plinio Massaki Nishiye Umezaki. All rights reserved.
//

#import "MainViewController.h"
#import "CustomCollectionViewCell.h"
#import "CustomCollectionHeaderView.h"
#import "ImageViewController.h"

@interface MainViewController() <UICollectionViewDataSource, UICollectionViewDelegate>
    
@property (nonatomic) NSMutableArray *monthPhotos;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UIButton *takePhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *homeButton;
@end

@implementation MainViewController


- (void) viewDidLoad {
    [super viewDidLoad];
    
    
    self.takePhotoButton.layer.cornerRadius = 10;
    self.homeButton.layer.cornerRadius = 10;
    if(!(self.monthPhotos = [[self returnArrayData] mutableCopy])) {
        NSMutableArray *arrayData = [self createTwoDimentionsArray];
        [self storeArrayData:arrayData];
        [self.collectionView reloadData];
    }
    self.monthPhotos = [[self returnArrayData] mutableCopy];
    [self printArray:self.monthPhotos];
}

- (IBAction)returnToHome:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Camera related methods

- (IBAction)takePhoto:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *takenImage = info[UIImagePickerControllerEditedImage];
    
    NSData *imageData = UIImagePNGRepresentation(takenImage);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *imagePathName;
    NSString *imagePath;
    
    NSInteger dayPosition = [self getCurrentDay] - 1; // Position of array that shows a current day.
    NSInteger mealPosition = [self getHourCode]; // Position of array that shows a current meal.
    
    
    if((imagePathName = [self generateImagePathName])) {
        imagePath = [documentsDirectory stringByAppendingPathComponent: [NSString stringWithFormat:@"%@.png", imagePathName]];
        NSLog(@"Pre Writing to File");
        if(![imageData writeToFile:imagePath atomically: NO]) {
            NSLog(@"Failed to cache image data to disk");
        }
        else {
          
            NSLog(@"The CachedImagePath is %@", imagePath);
        }
        NSLog(@"imagePathName = %@", imagePathName);
        
        NSMutableArray *monthArray = [self.monthPhotos mutableCopy];
        NSMutableArray *dayArray = [[self.monthPhotos objectAtIndex:dayPosition] mutableCopy];
        [dayArray replaceObjectAtIndex:mealPosition withObject: imagePathName];
        [monthArray replaceObjectAtIndex:dayPosition withObject:dayArray];
        [self storeArrayData:monthArray];
        self.monthPhotos = monthArray;
        [self.collectionView reloadData];
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hey!!" message:@"It isn't time to eat yet!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
    
}

- (UIImage *) loadImage:(NSInteger) section : (NSInteger) item {
    
    UIImage *image;
    if(![[[self.monthPhotos objectAtIndex:section] objectAtIndex:item] isEqualToString:@"N"]){
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [paths objectAtIndex:0];
        NSString *imagePath = self.monthPhotos[section][item];
        NSString *path = [documentDirectory stringByAppendingPathComponent:[NSString stringWithString: imagePath]];
        image = [UIImage imageWithContentsOfFile:path];
    }
    else {
        image = [UIImage imageNamed:@"black.png"];
    }
    return image;
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - current data related methods

- (NSInteger) getCurrentDay {
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitDay fromDate: now];
    NSInteger day = [components day];
    return day;
}

- (NSInteger) getCurrentHour {
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitHour fromDate: now];
    NSInteger hour = [components hour];
    return hour;
}

#pragma mark - Array related methods

- (NSMutableArray *) createTwoDimentionsArray {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity: 31];
    for(int i = 0; i < 31; i++) {
        array[i] = [[NSMutableArray alloc] initWithObjects:@"N", @"N", @"N", nil];
    }
    return array;
}

- (NSMutableArray *) returnArrayData {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    return [user objectForKey:@"arrayData"];
}

- (void) storeArrayData: (NSMutableArray *) arrayData {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:arrayData forKey:@"arrayData"];
    [user synchronize];
}

- (void) removeArrayData {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user removeObjectForKey:@"arrayData"];
    [user synchronize];
}

#pragma mark - Collection View related methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.monthPhotos count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *sectionArray = [self.monthPhotos objectAtIndex:section];
    return [sectionArray count];
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"Cell";
    
    CustomCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];

    cell.photo.image = [self loadImage: indexPath.section : indexPath.item];
    
    switch(indexPath.item) {
        case 0:
            cell.label.text = [NSString stringWithFormat:@"breakfast"];
            break;
        case 1:
            cell.label.text = [NSString stringWithFormat:@"lunch"];
            break;
        case 2:
            cell.label.text = [NSString stringWithFormat:@"dinner"];
            break;
        default:
            cell.label.text = [NSString stringWithFormat:@""];
            break;
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *reusableView = nil;
    
    if(kind == UICollectionElementKindSectionHeader) {
        CustomCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        NSString *title = [[NSString alloc] initWithFormat:@"Day %ld", indexPath.section + 1];
        headerView.headerLabel.text = title;
        
        reusableView = headerView;
    }
    return reusableView;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier]isEqualToString:@"zoomImage"]) {
        NSIndexPath *selectedIndexPath = [[self.collectionView indexPathsForSelectedItems]objectAtIndex:0];
        ImageViewController *imageViewController = [segue destinationViewController];
        if(![[[self.monthPhotos objectAtIndex:selectedIndexPath.section]objectAtIndex:selectedIndexPath.item] isEqualToString:@"N"]){
            imageViewController.mealImage = [self loadImage:selectedIndexPath.section :selectedIndexPath.row];
            imageViewController.imagePath = [[self.monthPhotos objectAtIndex:selectedIndexPath.section] objectAtIndex:selectedIndexPath.item];
            imageViewController.hidden = YES;
        }
        else {
            imageViewController.hidden = NO;
        }
    }
}
#pragma mark - Auxiliar methods

- (NSString *) generateImagePathName {
    NSInteger day = [self getCurrentDay];
    NSInteger hourCode = [self getHourCode];
    switch(hourCode){
        case 0:
            return [NSString stringWithFormat:@"day%ldBreakfast", day];
            break;
        case 1:
            return [NSString stringWithFormat:@"day%ldLunch", day];
            break;
        case 2:
            return [NSString stringWithFormat:@"day%ldDinner", day];
            break;
        default:
            return nil;
    }
}

- (NSInteger) getHourCode {
    NSInteger hour = [self getCurrentHour];
    if(hour >= 4 && hour < 9){
        return 0;
    }
    else if(hour >= 9 && hour < 14){
        return 1;
    }
    else if(hour >= 19 && hour < 23) {
        return 2;
    }
    else {
        return 3;
    }
    
}

- (void) printArray: (NSArray *) array {
    for (int i = 0; i < 31; i++){
        NSLog(@"%@", array[i]);
    }
}
@end
