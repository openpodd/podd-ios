//
//  PageController.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/25/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "PageController.h"
#import "ReportNavigationController.h"

#import "QuestionView.h"
#import "SimpleQuestionView.h"
#import "SingleChoiceQuestionView.h"
#import "MultipleChoiceQuestionView.h"
#import "IntegerQuestionView.h"
#import "AddressQuestionView.h"
#import "DateQuestionView.h"
#import "AutocompleteQuestionView.h"

#import "ContextManager.h"
#import "PageContext.h"
#import "Page.h"

#import <Masonry/Masonry.h>

@interface PageController () <QuestionViewDelegate>
@property (weak, nonatomic, nullable) IBOutlet NSLayoutConstraint *bottomLayoutConstraint;
@property (strong, nonatomic, nonnull) IBOutlet UIScrollView *questionScrollView; 
@property (strong, nonatomic, nonnull) NSArray<QuestionView *> *questionViews;
@property (strong, nonatomic, nullable) NSMutableDictionary *errors;
@end

@interface PageController (QuestionSelector)
- (Class)questionViewClassForQuestion:(Question * _Nonnull)question;
@end

@interface PageController (Keyboard)
- (void)setupKeyboardObservers;
- (void)removeKeyboardObservers;
@end

@interface PageController (Validation)
- (BOOL)validate;
- (void)showErrorMessages;
@end

#import "ReportType.h"

@implementation PageController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self loadQuestionViews];
    [self layoutQuestionViews];
    self.title = self.navigationController.reportType.name;
    
    if (!self.navigationController.isSubmitted) {
        self.reportStatusViewHeightConstraint.constant = 0;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self setupKeyboardObservers];
    [self setupNextButton];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [self removeKeyboardObservers];
}

- (void)loadQuestionViews {
    
    NSMutableArray *questionViews = [NSMutableArray new];
    NSArray<Question *> *questions = self.pageContext.page.questions;
    UIView *superview = self.questionScrollView;
    
    for (Question *question in questions) {
        Class QuestionViewClass = [self questionViewClassForQuestion:question];
        if (QuestionViewClass != NULL) {
            id defaultValue = [self.pageContext formValueForKey:question.name];
            QuestionView *questionView = [[QuestionViewClass alloc]
                                          initWithQuestion:question
                                          defaultValue:defaultValue
                                          delegate:self];
            [superview addSubview:questionView];
            [questionViews addObject:questionView];
        }
    }
    
    self.questionViews = questionViews;
}

- (void)layoutQuestionViews {
    
    UIView *previousView;
    
    for (QuestionView *questionView in self.questionViews) {
        UIView *superview = self.questionScrollView;
        
        [questionView mas_makeConstraints:^(MASConstraintMaker *make) {
            MASViewAttribute *topAttribute = superview.mas_top;
            if (previousView) {
                topAttribute = previousView.mas_bottom;
            }
            
            // Cannot use left/right margin attributes due to ScrollView
            make.top.equalTo(topAttribute);
            make.width.equalTo(superview.mas_width);
            make.centerX.equalTo(superview.mas_centerX);
        }];
        
        BOOL isTheLastOne = [questionView isEqual:self.questionViews.lastObject];
        if (isTheLastOne) {
            [questionView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(superview.mas_bottom);
            }];
        }
        
        previousView = questionView;
    }
}

- (void)setupNextButton {
    
    UIBarButtonItem *nextButtonItem = [[UIBarButtonItem alloc] 
                                       initWithTitle:NSLocalizedString(@"Next", nil)
                                       style:UIBarButtonItemStylePlain
                                       target:self
                                       action:@selector(nextPage:)];
    self.navigationItem.rightBarButtonItem = nextButtonItem;
}

#pragma mark - QuestionView Delegate

- (void)setFormValue:(id)formValue forKey:(NSString *)key {
    
    [self.pageContext setFormValue:formValue forKey:key];
    
#if DEBUG
    id values = [self.pageContext.contextManager values];
    NSData *data = [NSJSONSerialization dataWithJSONObject:values options:NSJSONWritingPrettyPrinted error:nil];
    NSLog(@"all values %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
#endif
}

- (id)formValueForKey:(NSString *)key {
    
    return [self.pageContext formValueForKey:key];
}

#pragma mark - Navigation Controller

- (IBAction)resign:(id)sender {
    
    [self resignFirstResponder];
}

- (BOOL)becomeFirstResponder {
    
    if (self.navigationController.isSubmitted) {
        self.questionScrollView.userInteractionEnabled = NO;
        
    } else if (self.questionViews.count == 1) {
        [self.questionViews.firstObject becomeFirstResponder];
    }
    return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    
    for (QuestionView *questionView in self.questionViews) {
        [questionView resignFirstResponder];
    }
    return [super resignFirstResponder];
}

- (IBAction)nextPage:(id)sender {
    
    [self resignFirstResponder];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [self saveFormData];
    if ([self validate]) {
        [self.navigationController nextPage];
        
    } else {
        [self showErrorMessages];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.navigationItem.rightBarButtonItem.enabled = YES;
    });
}

- (void)saveFormData {
    
    for (QuestionView *questionView in self.questionViews) {
        [questionView prepareForSubmit];
    }
}

@end


@implementation PageController (QuestionSelector)

- (Class)questionViewClassForQuestion:(Question * _Nonnull)question {
    
    NSDictionary *mapping = @{ QUESTION_TYPE_TEXT: NSStringFromClass(SimpleQuestionView.class)
                               ,QUESTION_TYPE_SINGLE: NSStringFromClass(SingleChoiceQuestionView.class) 
                               ,QUESTION_TYPE_MULTIPLE: NSStringFromClass(MultipleChoiceQuestionView.class)
                               ,QUESTION_TYPE_INTEGER: NSStringFromClass(IntegerQuestionView.class)
                               ,QUESTION_TYPE_ADDRESS: NSStringFromClass(AddressQuestionView.class)
                               ,QUESTION_TYPE_AUTOCOMPLETE: NSStringFromClass(AutocompleteQuestionView.class)
                               ,QUESTION_TYPE_DATE: NSStringFromClass(DateQuestionView.class)
                               };
    return NSClassFromString(mapping[question.type]);
}

@end


#import "ReportAppDelegate.h"

@implementation PageController (Validation)

- (BOOL)validate {
    
    NSMutableDictionary *errors = [NSMutableDictionary new];
    BOOL valid = YES;
    
    for (Question *question in self.pageContext.page.questions) {
        valid = [question validate:self.pageContext.contextManager] && valid;
        if (!valid) {
            errors[[@(question.uid) stringValue]] = question.validationErrors;
        }
    }
    
    self.errors = errors;
    return valid;
}

- (void)showErrorMessages {
    
    NSMutableArray *errorMessages = [NSMutableArray new];
    
    for (NSString *questionKey in self.errors.allKeys) {
        NSArray<NSString *> *errors = [self.errors valueForKey:questionKey];
        for (NSString *error in errors) {
            NSString *message = NSLocalizedString(error, nil);
            [errorMessages addObject:message];
        }
    }
    
    NSString *message = [errorMessages componentsJoinedByString:@", "];
    ReportAppDelegate *delegate = (ReportAppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate presentAlerWithTitle:NSLocalizedString(@"QuestionValidationErrorTitle", nil)  withMessage:message]; 
}

@end

@implementation PageController (Keyboard)

- (void)setupKeyboardObservers {
    
    [[NSNotificationCenter defaultCenter] 
     addObserver:self
     selector:@selector(observeKeyboard:)
     name:UIKeyboardWillShowNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter] 
     addObserver:self
     selector:@selector(observeKeyboard:)
     name:UIKeyboardWillHideNotification
     object:nil];
}

- (void)removeKeyboardObservers {
    
    [[NSNotificationCenter defaultCenter] 
     removeObserver:self
     name:UIKeyboardWillShowNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter] 
     removeObserver:self
     name:UIKeyboardWillHideNotification
     object:nil];
}

- (void)observeKeyboard:(NSNotification *)notification {
    
    NSValue *keyboardRectValue = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [keyboardRectValue CGRectValue];
    
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    self.bottomLayoutConstraint.constant = CGRectGetMaxY(screenBound) - keyboardRect.origin.y;
}

@end
