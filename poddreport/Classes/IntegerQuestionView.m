//
//  IntegerQuestionView.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/27/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "IntegerQuestionView.h"
#import "Question.h"

@interface IntegerQuestionView () <UITextFieldDelegate> {
    NSNumberFormatter *_numberFormatter;
}
@property (strong, nonatomic, nonnull) UIButton *minusButton;
@property (strong, nonatomic, nonnull) UIButton *plusButton;
@property (strong, nonatomic, nonnull) UIView *lineView;
@end

@implementation IntegerQuestionView

- (instancetype)initWithQuestion:(Question *)question defaultValue:(NSString *)value delegate:(id<QuestionViewDelegate>)delegate {
    
    if (self = [super initWithQuestion:question defaultValue:value delegate:delegate]) {
        UITextField *textField = [[UITextField alloc] init];
        textField.delegate = self;
        textField.text = value ? value : @"0";
        textField.textAlignment = NSTextAlignmentCenter;
        textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        textField.backgroundColor = [UIColor clearColor];
        textField.returnKeyType = UIReturnKeyNext;
        textField.font = [UIFont fontWithName:@"SukhumvitSet-Bold" size:84];
        textField.spellCheckingType = UITextSpellCheckingTypeNo;
        [self.contentView addSubview:textField];
        
        UIButton *minusButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [minusButton setImage:[UIImage imageNamed:@"btn-form-minus"] forState:UIControlStateNormal];
        [minusButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [minusButton addTarget:self action:@selector(minus:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:minusButton];
        
        UIButton *plusButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [plusButton setImage:[UIImage imageNamed:@"btn-form-plus"] forState:UIControlStateNormal];
        [plusButton addTarget:self action:@selector(plus:) forControlEvents:UIControlEventTouchUpInside];
        [plusButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.contentView addSubview:plusButton];
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = [UIColor colorWithRed:0.7373 green:0.7373 blue:0.7373 alpha:1.0];
        [self.contentView addSubview:lineView];
        
        _textField = textField;
        _minusButton = minusButton;
        _plusButton = plusButton;
        _lineView = lineView;
        
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        _numberFormatter = [[NSNumberFormatter alloc] init];
        
        [self autolayout];
    }
    return self;
}

- (BOOL)becomeFirstResponder {
    
    return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    
    [self.textField resignFirstResponder];
    return [super resignFirstResponder];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    CGFloat buttonWidth = 64;
    CGFloat contentHeight = 100;
    CGFloat contentOffset = 10;
    CGRect contentRect = self.contentView.frame;
    contentRect.size.height = contentHeight;
    contentRect.origin.x = contentOffset;
    contentRect.size.width = CGRectGetWidth(self.bounds) - (contentOffset * 2);
    
    // Left Button
    CGRect leftButtonFrame = CGRectMake(10, 0, buttonWidth, contentHeight);
    self.minusButton.frame = leftButtonFrame;
    
    
    // Right Button
    CGRect rightButtonFrame = CGRectMake(CGRectGetWidth(self.contentView.bounds) - buttonWidth - contentOffset
                                         , 0
                                         , buttonWidth
                                         , contentHeight);
    self.plusButton.frame = rightButtonFrame;
    
    
    // Center
    CGFloat centerWidth = CGRectGetMinX(self.plusButton.frame) - CGRectGetMaxX(self.minusButton.frame);
    CGRect centerFrame = CGRectMake(CGRectGetMaxX(self.minusButton.frame)
                                    , 0
                                    , centerWidth
                                    , contentHeight);
    self.textField.frame = centerFrame;
    
    
    // Line
    CGRect lineFrame = CGRectMake(CGRectGetWidth(self.contentView.bounds) / 2 - 100 / 2, contentHeight - contentOffset, 100, 2);
    self.lineView.frame = lineFrame;
}

- (void)prepareForSubmit {
    
    [super prepareForSubmit];
    [self.delegate setFormValue:self.textField.text forKey:self.question.name];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // Delete a character
    if ([string isEqualToString:@""]) {
        return YES;
    }
    
    if ([_numberFormatter numberFromString:string]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)plus:(id)sender {
    
    NSNumber *value = [_numberFormatter numberFromString:self.textField.text];
    NSNumber *newValue = @(MIN(value.integerValue + 1, 100000));
    self.textField.text = [_numberFormatter stringFromNumber:newValue];
    [self resignFirstResponder];
}

- (IBAction)minus:(id)sender {
    
    NSNumber *value = [_numberFormatter numberFromString:self.textField.text];
    NSNumber *newValue = @(MAX(value.integerValue - 1, 0));
    self.textField.text = [_numberFormatter stringFromNumber:newValue];
    [self resignFirstResponder];
}

@end

#import <Masonry.h>

@implementation IntegerQuestionView (Layout)

- (void)autolayoutContent {
    
    [super autolayoutContent];
    
    UIView *superview = self;
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerView.mas_bottom).with.offset(8);
        make.left.equalTo(superview.mas_left);
        make.right.equalTo(superview.mas_right);
        make.height.equalTo(@100);
    }];
}

@end