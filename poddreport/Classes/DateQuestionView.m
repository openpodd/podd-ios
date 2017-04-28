//
//  DateQuestionView.m
//  poddreport
//
//  Created by crosalot on 4/28/17.
//  Copyright © 2017 Opendream. All rights reserved.
//

#import "DateQuestionView.h"
#import "Question.h"

@implementation DateQuestionView
    
- (instancetype)initWithQuestion:(Question *)question defaultValue:(NSString *)value delegate:(id<QuestionViewDelegate>)delegate {
    if (self = [super initWithQuestion:question defaultValue:value delegate:delegate]) {
        
        UIDatePicker *datePicker = [[UIDatePicker alloc] init];
        
        if (value) {
            // Convert string to date object
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
            dateFormatter.timeZone = [NSTimeZone defaultTimeZone];
            NSDate *date = [dateFormatter dateFromString:value];
            datePicker.date = date;
        }
        
        _datePicker = datePicker;
        
        [self setupDatePicker];
        [self.contentView addSubview:datePicker];
        [self autolayout];
    }
    return self;
}
    
- (void)setupDatePicker {
    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierBuddhist];
    calendar.locale = [NSLocale localeWithLocaleIdentifier:@"th"];
    [self.datePicker setLocale:[NSLocale localeWithLocaleIdentifier:@"th"]];
    [self.datePicker setCalendar:calendar];
    [self.datePicker setDatePickerMode:UIDatePickerModeDate];
    
    [self.datePicker setMaximumDate:[NSDate date]];
}
    
- (void)prepareForSubmit {
    
    [super prepareForSubmit];
    
    NSDate *date = [self.datePicker date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    dateFormatter.timeZone = [NSTimeZone defaultTimeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    [self.delegate setFormValue:dateString forKey:self.question.name];
}


@end

#import <Masonry.h>

@implementation DateQuestionView (Layout)
    
- (void)autolayoutContent {
    
    [super autolayoutContent];
    
    UIView *superview = self.contentView;
    [self.datePicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(superview).with.insets(UIEdgeInsetsMake(15,15,15,15));
        make.height.equalTo(@100);
    }];
    
    superview = self;
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerView.mas_bottom).with.offset(8);
        make.left.equalTo(superview.mas_left).with.offset(5);
        make.right.equalTo(superview.mas_right).with.offset(-5);
    }];
}
    
@end
