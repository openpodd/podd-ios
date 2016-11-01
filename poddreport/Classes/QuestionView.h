//
//  QuestionView.h
//  poddmodel
//
//  Created by Opendream-iOS on 1/26/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

@import UIKit;
@class Question;

#import "ContextDelegate.h"

@protocol QuestionViewDelegate <ContextDelegate> 
@end

@interface QuestionView : UIView
@property (unsafe_unretained, nullable) id<QuestionViewDelegate> delegate;
@property (strong, nonatomic, nonnull) Question *question;

@property (strong, nonatomic, nonnull) UILabel *headerView;
@property (strong, nonatomic, nonnull) UIView *contentView;
@property (strong, nonatomic, nonnull) UILabel *footerView;

@property (strong, nonatomic, nonnull) UIView *freeTextView;
@property (strong, nonatomic, nonnull) UITextView *freeTextTextView;
@property (strong, nonatomic, nonnull) UILabel *freeTextLabel;

- (instancetype _Nonnull)initWithQuestion:(Question * _Nonnull)question defaultValue:(NSString * _Nullable)value delegate:(id<QuestionViewDelegate> _Nullable)delegate;
- (void)formDidChangeValue:(NSString * _Nullable)value forKey:(NSString * _Nonnull)key;

@end

@interface QuestionView (Layout)
- (void)autolayout;
- (void)autolayoutContent;
- (void)autolayoutFreeText;
- (void)updateFreeTextEnable;
@end

@interface QuestionView (Submit)
- (void)prepareForSubmit;
@end
