//
//  MultipleChoiceQuestionView.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/26/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "MultipleChoiceQuestionView.h"
#import "MultipleChoiceItemView.h"
#import "Question.h"
#import "QuestionItem.h"

@interface MultipleChoiceQuestionView () <ChoiceItemViewDelegate>
@property (strong, nonatomic, nonnull) NSArray<SingleChoiceItemView *> *itemViews;
@end

@implementation MultipleChoiceQuestionView

- (instancetype)initWithQuestion:(Question *)question
                    defaultValue:(NSString *)values
                        delegate:(id<QuestionViewDelegate>)delegate {
    
    if (self = [super initWithQuestion:question
                          defaultValue:values
                              delegate:delegate]) {
        [self loadItemViews]; 
        [self autolayout];
        [self choiceItemDidSelectItem:values];
    }
    return self;
}

- (void)loadItemViews {
    
    NSMutableArray *itemViews = [NSMutableArray new];
    for (QuestionItem *item in self.question.items) {
        MultipleChoiceItemView *itemView = [MultipleChoiceItemView 
                                          newChoiceForItem:item.identifier
                                          title:item.text
                                          delegate:self];
        [self.contentView addSubview:itemView];
        [itemViews addObject:itemView];
    }
    
    if (self.question.freeTextChoiceEnable) {
        MultipleChoiceItemView *itemView = [MultipleChoiceItemView 
                                          newChoiceForItem:self.question.freeTextId
                                          title:NSLocalizedString(self.question.freeTextText, nil)
                                          delegate:self];
        [self.contentView addSubview:itemView];
        [itemViews addObject:itemView];
    }
    
    self.itemViews = itemViews;
}

#pragma mark - ChoiceItem Delegate

- (void)choiceItemDidSelectItem:(NSString * _Nonnull)identifier {
    
    NSArray *values = [identifier componentsSeparatedByString:@","];
    for (SingleChoiceItemView *choice in self.itemViews) {
        if ([values containsObject:choice.item]) {
            choice.selected = !choice.selected;
            [choice setNeedsLayout];
        }
    } 
}

- (void)prepareForSubmit {
    
    [super prepareForSubmit];
    
    NSMutableArray *items = [NSMutableArray new];
    for (SingleChoiceItemView *choiceItem in self.itemViews) {
        if (choiceItem.selected) {
            [items addObject:choiceItem.item];
        }
    }
    
    NSString *formValue;
    if (items.count > 0) {
        formValue = [items componentsJoinedByString:QuestionItemSeparatorSymbol];
    }
    
    [self.delegate setFormValue:formValue forKey:self.question.name];
    
    if (self.question.hiddenName) {
        NSMutableArray *hiddenValues = [NSMutableArray new];
        for (NSString *itemIdentifier in items) {
            NSString *hiddenValue = [self.question hiddenValueForItemIdentifier:itemIdentifier];
            if (hiddenValue) {
                [hiddenValues addObject:hiddenValue];
            }
        }
        
        if (hiddenValues.count > 0) {
            NSString *hiddenformValues = [items componentsJoinedByString:QuestionItemSeparatorSymbol];
            [self.delegate setFormValue:hiddenformValues forKey:self.question.hiddenName];
        }
    }
}

@end

#import <Masonry.h>

@implementation MultipleChoiceQuestionView (Layout)

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

@end
