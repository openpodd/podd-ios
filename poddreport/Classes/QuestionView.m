//
//  QuestionView.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/26/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "QuestionView.h"
#import "Question.h"
#import <Masonry.h>

@interface QuestionView () <UITextViewDelegate>
@end

@implementation QuestionView

- (instancetype _Nonnull)initWithQuestion:(Question * _Nonnull)question defaultValue:(NSString * _Nullable)value delegate:(id<QuestionViewDelegate> _Nullable)delegate {
    
    if (self = [super init]) {
        _question = question;
        _delegate = delegate;
        
        UIView *freeTextView = [[UIView alloc] init];
        freeTextView.clipsToBounds = YES;
        freeTextView.backgroundColor = [UIColor whiteColor];
        [self addSubview:freeTextView];
        _freeTextView = freeTextView;
        
        UITextView *textView = [[UITextView alloc] init];
        textView.delegate = self;
        textView.text = value;
        textView.backgroundColor = [UIColor whiteColor];
        textView.layer.cornerRadius = 5;
        textView.layer.borderColor = [UIColor colorWithRed:0.7373 green:0.7373 blue:0.7373 alpha:1.0].CGColor;
        textView.layer.borderWidth = 1;
        textView.clipsToBounds = YES;
        textView.delegate = self;
        textView.returnKeyType = UIReturnKeyNext;
        textView.font = [UIFont fontWithName:@"SukhumvitSet-Text" size:17];
        textView.spellCheckingType = UITextSpellCheckingTypeNo;
        textView.autocorrectionType = UITextAutocorrectionTypeNo;
        textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textView.backgroundColor = [UIColor whiteColor];
        textView.scrollEnabled = YES;
        [_freeTextView addSubview:textView];
        _freeTextTextView = textView;
        
        NSString *freeTextString = [delegate formValueForKey:self.question.freeTextName];
        textView.text = freeTextString;
        
        UILabel *freeTextLabel = [[UILabel alloc] init];
        freeTextLabel.numberOfLines = 0;
        freeTextLabel.font = [UIFont fontWithName:@"SukhumvitSet-Bold" size:19];
        [_freeTextView addSubview:freeTextLabel];
        _freeTextLabel = freeTextLabel;
        
        NSString *title = [NSLocalizedString(question.title, nil) stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        UILabel *headerLabel = [[UILabel alloc] init];
        headerLabel.numberOfLines = 0;
        headerLabel.text = title;
        headerLabel.font = [UIFont fontWithName:@"SukhumvitSet-Bold" size:19];

        [self addSubview:headerLabel];
        _headerView = headerLabel;
        
        UILabel *footerLabel = [[UILabel alloc] init];
        footerLabel.numberOfLines = 0;
        [self addSubview:footerLabel];
        _footerView = footerLabel;
        
        UIView *contentView = [[UIView alloc] init];
        contentView.clipsToBounds = YES;
        contentView.backgroundColor = [UIColor clearColor];
        [self addSubview:contentView];
        _contentView = contentView;
        
        self.backgroundColor = [UIColor clearColor];    
        
        NSLog(@"freeTextChoiceEnable %@", self.question.freeTextChoiceEnable ? @"YES":@"NO");
    }
    return self;
}

#pragma mark - UIControl

- (BOOL)becomeFirstResponder {
    
    return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    
    [self.freeTextTextView resignFirstResponder];
    return [super resignFirstResponder];
}

@end

@implementation QuestionView (Layout)

- (void)autolayout {
    
    [self autolayoutHeader];
    [self autolayoutFooter];
    [self autolayoutFreeText];
    [self autolayoutContent];
}

- (void)autolayoutHeader {
    
    UIView *superview = self;
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(superview.mas_top).with.offset(16);
        make.left.equalTo(superview.mas_left).with.offset(23);
        make.right.equalTo(superview.mas_right).with.offset(-23);
    }];
}

- (void)autolayoutContent {
    
}

- (void)autolayoutFreeText {
     
    UIView *superview;
    
    superview = self.freeTextView;
    [self.freeTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(superview.mas_top);
        make.left.equalTo(superview.mas_left);
        make.right.equalTo(superview.mas_right);
    }];
    
    [self.freeTextTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.freeTextLabel.mas_bottom);
        make.left.equalTo(superview.mas_left);
        make.right.equalTo(superview.mas_right);
    }];
    
    superview = self;
    [self.freeTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_bottom).with.offset(5);
        make.bottom.equalTo(self.freeTextTextView.mas_bottom).with.offset(5);
        make.left.equalTo(superview.mas_left).with.offset(5);
        make.right.equalTo(superview.mas_right).with.offset(-5);
    }];
    
    [self updateFreeTextEnable];
}

- (void)updateFreeTextEnable {
    
    CGFloat freeTextHeight;
    
    if (self.question.freeTextChoiceEnable) {
        freeTextHeight = 100;
        self.freeTextView.hidden = NO;
    } else {
        freeTextHeight = 0;
        self.freeTextView.hidden = YES;
    }
    
    [self.freeTextTextView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(freeTextHeight));
    }];
    
    [self.freeTextView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_bottom).with.offset(0);
        make.bottom.equalTo(self.freeTextTextView.mas_bottom).with.offset(0);
    }];
}

- (void)autolayoutFooter {
    
    UIView *superview = self;
    [self.footerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.freeTextView.mas_bottom);
        make.bottom.equalTo(superview.mas_bottom);
        make.left.equalTo(superview.mas_left);
        make.right.equalTo(superview.mas_right);
    }];
}

@end

@implementation QuestionView (Submit)

- (void)prepareForSubmit {
    
    if (self.question.freeTextChoiceEnable) {
        [self.delegate setFormValue:self.freeTextTextView.text forKey:self.question.freeTextName];
    }
}

@end