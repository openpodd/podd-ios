//
//  SingleChoiceQuestionView.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/26/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "SingleChoiceQuestionView.h"
#import "SingleChoiceItemView.h"
#import "Question.h"
#import "QuestionItem.h"

@interface SingleChoiceQuestionView () <ChoiceItemViewDelegate>
@property (strong, nonatomic, nonnull) NSArray<SingleChoiceItemView *> *itemViews;
@end

@implementation SingleChoiceQuestionView

- (instancetype)initWithQuestion:(Question *)question defaultValue:(NSString *)value delegate:(id<QuestionViewDelegate>)delegate {
    
    if (self = [super initWithQuestion:question defaultValue:value delegate:delegate]) {
        [self loadItemViews]; 
        [self autolayout];
        [self choiceItemDidSelectItem:value];
    }
    return self;
}

- (void)loadItemViews {
    
    NSMutableArray *itemViews = [NSMutableArray new];
    for (QuestionItem *item in self.question.items) {
        SingleChoiceItemView *itemView = [SingleChoiceItemView 
                                          newChoiceForItem:item.identifier
                                          title:item.text
                                          delegate:self];
        [self.contentView addSubview:itemView];
        [itemViews addObject:itemView];
    }
    
    if (self.question.freeTextChoiceEnable) {
        SingleChoiceItemView *itemView = [SingleChoiceItemView 
                                          newChoiceForItem:self.question.freeTextId
                                          title:NSLocalizedString(self.question.freeTextText, nil)
                                          delegate:self];
        [self.contentView addSubview:itemView];
        [itemViews addObject:itemView];
    }
    
    self.itemViews = itemViews;
}

- (BOOL)becomeFirstResponder {
    
    return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    
    return [super resignFirstResponder];
}

#pragma mark - ChoiceItemDelegate

- (void)choiceItemDidSelectItem:(NSString * _Nonnull)identifier {
    
    for (SingleChoiceItemView *choice in self.itemViews) {
        choice.selected = [identifier isEqualToString:choice.item];
        [choice setNeedsLayout];
    }
}

- (void)prepareForSubmit {
    
    [super prepareForSubmit];
    
    NSString *selectedIdentifier;
    for (SingleChoiceItemView *choiceView in self.itemViews) {
        if (choiceView.selected) {
            selectedIdentifier = choiceView.item;
            break;
        }
    }
    
    [self.delegate setFormValue:selectedIdentifier forKey:self.question.name];
    
    if (self.question.hiddenName) {
        NSString *hiddenValue = [self.question hiddenValueForItemIdentifier:selectedIdentifier];
        [self.delegate setFormValue:hiddenValue forKey:self.question.hiddenName];
    }
}

@end


#import <Masonry.h>

@implementation SingleChoiceQuestionView (Layout)

- (void)autolayoutContent {
    
    [super autolayoutContent];
    
    UIView *previousView;
    UIView *superview = self.contentView;
    
    for (SingleChoiceItemView *choice in self.itemViews) {
        [choice mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(superview.mas_left);
            make.right.equalTo(superview.mas_right);
            
            if (previousView) {
                make.top.equalTo(previousView.mas_bottom);
            } else {
                make.top.equalTo(superview.mas_top);
            }
        }];
        
        previousView = choice;
    }
    
    superview = self;
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerView.mas_bottom).with.offset(8);
        make.left.equalTo(superview.mas_left);
        make.right.equalTo(superview.mas_right);
        if (previousView) {
            make.bottom.equalTo(previousView.mas_bottom);
        }
    }];
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
        make.left.equalTo(superview.mas_left).with.offset(67);
        make.right.equalTo(superview.mas_right).with.offset(-20);
        make.height.equalTo(@100);
    }];
    
    superview = self;
    [self.freeTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_bottom).with.offset(-5);
        make.bottom.equalTo(self.freeTextTextView.mas_bottom).with.offset(22);
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
        [self.freeTextView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_bottom).with.offset(0);
            make.bottom.equalTo(self.freeTextTextView.mas_bottom).with.offset(0);
            make.left.equalTo(self.mas_left).with.offset(0);
            make.right.equalTo(self.mas_right).with.offset(0);
        }]; 
    }
    
    [self.freeTextTextView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(freeTextHeight));
    }];
}

@end