//
//  AutocompleteQuestionView.m
//  poddreport
//
//  Created by crosalot on 4/28/17.
//  Copyright © 2017 Opendream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AutocompleteQuestionView.h"
#import "Question.h"

// TODO: Change to autocomplete

@implementation AutocompleteQuestionView
    
- (instancetype)initWithQuestion:(Question *)question defaultValue:(NSString *)value delegate:(id<QuestionViewDelegate>)delegate {
    
    if (self = [super initWithQuestion:question defaultValue:value delegate:delegate]) {
        
        UITextView *textView = [[UITextView alloc] init];
        textView.text = value;
        textView.delegate = self;
        textView.returnKeyType = UIReturnKeyNext;
        textView.font = [UIFont fontWithName:@"SukhumvitSet-Text" size:17];
        textView.spellCheckingType = UITextSpellCheckingTypeNo;
        textView.autocorrectionType = UITextAutocorrectionTypeNo;
        textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textView.backgroundColor = [UIColor whiteColor];
        textView.scrollEnabled = YES;
        [self.contentView addSubview:textView];
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        _textView = textView;
        
        [self autolayout];
    }
    return self;
}
    
- (BOOL)becomeFirstResponder {
    
    [self.textView becomeFirstResponder];
    return [super becomeFirstResponder];
}
    
- (BOOL)resignFirstResponder {
    
    [self.textView resignFirstResponder];
    return [super resignFirstResponder];
}
    
- (void)prepareForSubmit {
    
    [super prepareForSubmit];
    [self.delegate setFormValue:self.textView.text forKey:self.question.name];
}
    
    @end

#import <Masonry.h>

@implementation AutocompleteQuestionView (Layout)
    
- (void)autolayoutContent {
    
    [super autolayoutContent];
    
    UIView *superview = self.contentView;
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
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
