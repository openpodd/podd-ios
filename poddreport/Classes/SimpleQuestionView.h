//
//  SimpleQuestionView.h
//  poddmodel
//
//  Created by Opendream-iOS on 1/26/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "QuestionView.h"

@interface SimpleQuestionView : QuestionView <UITextViewDelegate>
@property (strong, nonatomic, nonnull) UITextView *textView;
@end
