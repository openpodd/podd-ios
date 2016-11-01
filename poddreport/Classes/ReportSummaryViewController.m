//
//  ReportSummaryViewController.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/27/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "ReportSummaryViewController.h"
#import "ReportAppDelegate.h"
#import "ReportNavigationController.h"
#import "ConfigurationManager.h"

@interface ReportSummaryViewController () <UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic, nullable) IBOutlet UIView *dateFormView;
@property (weak, nonatomic, nullable) IBOutlet UIView *areaFormView;
@property (weak, nonatomic, nullable) IBOutlet UILabel *areaFormLabel;
@property (weak, nonatomic, nullable) IBOutlet UILabel *incidentDateFormLabel;
@property (weak, nonatomic, nullable) IBOutlet UIDatePicker *incidentDatePicker;
@property (weak, nonatomic, nullable) IBOutlet UIPickerView *administrationAreaPicker;
@property (weak, nonatomic, nullable) IBOutlet UIScrollView *contentScrollView;
@property (strong, nonatomic, nullable) NSArray * administrationAreaItems;
@end

@implementation ReportSummaryViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setupDatePicker];
    [self setupEditFormView];
    [self loadIncidentDate];
    [self loadAdministrationAreas];
    [self setupDoneButton];
}

- (void)setupDoneButton {
   
    NSString *titleString;
    SEL nextSEL;
    
    if (!self.navigationController.isSubmitted) {
        nextSEL = @selector(confirm:);
        titleString = NSLocalizedString(@"Confirm", nil);
    } else {
        nextSEL = @selector(close:);
        titleString = NSLocalizedString(@"End", nil);
    }
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextButton setBackgroundColor:[UIColor colorWithRed:0.4962 green:0.3364 blue:0.764 alpha:1.0]];
    [nextButton.titleLabel setFont:[UIFont fontWithName:@"SukhumvitSet-Bold" size:21]];
    [nextButton setTitle:titleString forState:UIControlStateNormal];
    [nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextButton addTarget:self action:nextSEL forControlEvents:UIControlEventTouchUpInside];
    [nextButton setFrame:CGRectMake(5, 0, 70, 30)];
    nextButton.layer.cornerRadius = 4;
    nextButton.clipsToBounds = YES;
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:nextButton];
    self.navigationItem.rightBarButtonItem = buttonItem;
}

- (void)setupDatePicker {
    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierBuddhist];
    calendar.locale = [NSLocale localeWithLocaleIdentifier:@"th"];
    [self.incidentDatePicker setLocale:[NSLocale localeWithLocaleIdentifier:@"th"]];
    [self.incidentDatePicker setCalendar:calendar];
    
    [self.incidentDatePicker setMinimumDate:[NSDate dateWithTimeIntervalSinceNow:(-1 * 24 * 60 * 60 * 7)]];
    [self.incidentDatePicker setMaximumDate:[NSDate date]];
}

- (void)setupEditFormView {
    
    self.contentScrollView.userInteractionEnabled = !self.navigationController.isSubmitted;
    if (!self.navigationController.isSubmitted) {
        self.reportStatusViewHeightConstraint.constant = 0;
    }
}

- (void)loadIncidentDate {
    
    NSDate *incidentDate = [self.navigationController incidentDate];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"th"]];
    NSString *dateString = [dateFormatter stringFromDate:incidentDate]; 
    
    self.incidentDateFormLabel.text = dateString;
}

- (void)loadAdministrationAreas {
    
    self.administrationAreaItems = [[ConfigurationManager sharedConfiguration] administrationAreas];
    [self.administrationAreaPicker reloadAllComponents]; 
    
    // Select current value
    int selectedAdministrationArea = self.navigationController.administrationAreaId;
    for (NSUInteger i = 0; i < self.administrationAreaItems.count; i++) {
        NSDictionary *administrationArea = self.administrationAreaItems[i];
        int uid = [administrationArea[@"id"] intValue];
        
        if (uid == selectedAdministrationArea) {
            self.areaFormLabel.text = administrationArea[@"name"];
            [self.administrationAreaPicker selectRow:i inComponent:0 animated:NO];
            break;
        }
    }
}

- (IBAction)dateForm:(id)sender {
    
    self.dateFormView.alpha = 1;
    self.areaFormView.alpha = 0;
}

- (IBAction)areaForm:(id)sender {
    
    self.areaFormView.alpha = 1;
    self.dateFormView.alpha = 0;
}

- (BOOL)resignFirstResponder {
    
    self.dateFormView.alpha = 0;
    self.areaFormView.alpha = 0;
    return [super resignFirstResponder];
}

- (IBAction)dismissModalForm:(id)sender {
    
    [self resignFirstResponder];
    
    NSDictionary *item = [self.administrationAreaItems objectAtIndex:[self.administrationAreaPicker selectedRowInComponent:0]];
    [self.navigationController setAdministrationAreaId:[item[@"id"] intValue]];
    [self loadAdministrationAreas];
    
    NSDate *incidentDate = self.incidentDatePicker.date;
    [self.navigationController setIncidentDate:incidentDate];
    [self loadIncidentDate];
}

- (IBAction)saveDraft:(id)sender {
    
    UIAlertController *alertController = [UIAlertController 
                                          alertControllerWithTitle:NSLocalizedString(@"SaveDraftTitleString", nil)
                                          message:NSLocalizedString(@"SaveDraftDetailString", nil)
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction 
                                actionWithTitle:NSLocalizedString(@"Save", nil) 
                                style:UIAlertActionStyleDefault 
                                handler:^(UIAlertAction * _Nonnull action) {
                                    [self submitForm:self];
                                }]];
    
    [self presentViewController:alertController
                       animated:YES 
                     completion:nil];
}

- (IBAction)confirm:(id)sender {
    
    UIAlertController *alertController = [UIAlertController 
                                          alertControllerWithTitle:nil
                                          message:nil
                                          preferredStyle:UIAlertControllerStyleActionSheet];
    
    if (!self.navigationController.isTesting) {
        [alertController addAction:[UIAlertAction 
                                    actionWithTitle:NSLocalizedString(@"ReportConfirm", nil) 
                                    style:UIAlertActionStyleDefault 
                                    handler:^(UIAlertAction * _Nonnull action) {
                                        [self submitForm:self];
                                    }]];
    }
    
    [alertController addAction:[UIAlertAction 
                                actionWithTitle:NSLocalizedString(@"ReportTesting", nil) 
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * _Nonnull action) {
                                    [self testForm:self];
                                }]];
    
    [alertController addAction:[UIAlertAction 
                                actionWithTitle:NSLocalizedString(@"Cancel", nil) 
                                style:UIAlertActionStyleCancel
                                handler:nil]];
    
    [self presentViewController:alertController
                       animated:YES 
                     completion:nil];
}

- (void)submitForm:(id)sender {
    
    [self.navigationController setTesting:NO];
    [self dismiss:sender];
}

- (void)testForm:(id)sender {
    
    [self.navigationController setTesting:YES];
    [self dismiss:sender];
}

- (void)dismiss:(id)sender {
    
    if (self.navigationController.administrationAreaId != 0) {
        [self.navigationController submit];
        
    } else {
        [(ReportAppDelegate *)[[UIApplication sharedApplication] delegate] 
         presentAlerWithTitle:NSLocalizedString(@"InformationRequiredErrorTitle", nil) 
         withMessage:NSLocalizedString(@"InformationRequiredErrorMessage", nil)];
    }
}

- (IBAction)close:(id)sender {
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIPickerView DataSource

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return self.administrationAreaItems.count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSDictionary *item = [self.administrationAreaItems objectAtIndex:row];
    return item[@"name"];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    [self dismissModalForm:pickerView];
}

@end
