//
//  MultipleChoiceQuestionView.m
//  poddmodel
//
//  Created by Opendream-iOS on 1/26/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "AddressQuestionView.h"
#import "MultipleChoiceItemView.h"
#import "Question.h"
#import "QuestionItem.h"
#import "QuestionDataSyncCommand.h"
#import "ConfigurationManager.h"
#import "SimpleQuestionView.h"

@interface AddressQuestionView () <UIPickerViewDelegate, UIPickerViewDataSource>
    @property (strong, nonatomic, nonnull) NSArray<UIView *> *itemViews;
    @property (strong, nonatomic, nonnull) NSArray<NSDictionary *> *levels;
    @property (strong, nonatomic, nonnull) NSMutableDictionary *levelsMap;
    @property (strong, nonatomic, nonnull) NSArray<NSDictionary *> *results;
    @property (strong, nonatomic) NSMutableDictionary *currentLevels;
    @property (strong, nonatomic) NSMutableDictionary *currentSelectedLevels;
    
    @property (strong, nonatomic) NSString *defaultValue;

@end

@implementation AddressQuestionView
    
- (instancetype)initWithQuestion:(Question *)question
                    defaultValue:(NSString *)values
                        delegate:(id<QuestionViewDelegate>)delegate {
    
    if (self = [super initWithQuestion:question
                          defaultValue:values
                              delegate:delegate]) {
        
        self.defaultValue = values;
        [self loadItemViews];

    }
    return self;
}
    
- (void)buildCurrentLevels {
    
    self.currentLevels = [NSMutableDictionary new];
    
    for (NSMutableDictionary *level in self.levels) {
        [self.currentLevels setObject:[NSMutableArray new] forKey: level[@"key"]];
        for (NSDictionary *item in self.results) {
            NSString *label = [item objectForKey:level[@"key"]];
            if (label) {
                
                BOOL allowAddObject = YES;

                NSDictionary *prevLevel = level[@"prevLevel"];
                if (prevLevel && ![prevLevel isEqual:[NSNull null]] && [self.currentLevels[prevLevel[@"key"]] count] > 0) {
                    
                    NSDictionary *backwardLevel = prevLevel;
                    while (backwardLevel && ![backwardLevel isEqual:[NSNull null]]) {
                        NSString *backwardLabel = [self.currentSelectedLevels objectForKey:backwardLevel[@"key"]];
                        
                        if (!backwardLabel || ([item objectForKey:backwardLevel[@"key"]] && [item[backwardLevel[@"key"]] isEqualToString: backwardLabel])) {
                            allowAddObject = allowAddObject && YES;
                        }
                        else {
                            allowAddObject = NO;
                            break;
                        }
                        
                        backwardLevel = [backwardLevel objectForKey: @"prevLevel"];
                    }
                }
                
                if (allowAddObject) {
                    [self.currentLevels[level[@"key"]] addObject: label];
                }
            }
        }
        NSArray *uniqueArray = [NSArray arrayWithArray:[[NSOrderedSet orderedSetWithArray:self.currentLevels[level[@"key"]]] array]];
        [self.currentLevels setObject:uniqueArray forKey: level[@"key"]];
        
        if (![self.currentSelectedLevels objectForKey:level[@"key"]] && [self.currentLevels[level[@"key"]] count] > 0) {
            [self.currentSelectedLevels setObject:[self.currentLevels[level[@"key"]] objectAtIndex:0 ] forKey:level[@"key"]];
        }

        
    }
}
    
- (void)renderItemViews {
    
    NSString *originTitle = self.question.title;
    
    

    // Has default value
    if (self.defaultValue) {

        
        for (NSDictionary *level in self.levels) {
            
            NSError  *error = nil;
            NSString *pattern = [NSString stringWithFormat:@"\\[%@:(.*?)\\]", level[@"label"]];
            NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern: pattern options:0 error:&error];
            NSString* defaultValueLevel = @"";
            
            NSTextCheckingResult* match = [regex firstMatchInString:self.defaultValue options:0 range: NSMakeRange(0, [self.defaultValue length])];
            defaultValueLevel = [self.defaultValue substringWithRange:[match rangeAtIndex:1]];
            
            if (![defaultValueLevel isEqualToString:@""]) {
                [self.currentSelectedLevels setObject:defaultValueLevel forKey:level[@"key"]];
            }
        }
        
    }
    
    
    [self buildCurrentLevels];
    
    NSMutableArray<UIView *> *itemViews = [NSMutableArray new];
    [self.contentView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    UIView *itemView;

    long i = 1;
    for (NSDictionary *level in self.levels) {
        

        
        if ([[self.currentLevels objectForKey:level[@"key"]] count] > 0) {
            itemView = [UIPickerView new];
            [(UIPickerView *)itemView setDataSource: self];
            [(UIPickerView *)itemView setDelegate: self];
            ((UIPickerView *)itemView).showsSelectionIndicator = YES;
        }
        else {
            self.question.title = level[@"label"];
            itemView = [[SimpleQuestionView alloc] initWithQuestion:self.question defaultValue:self.currentSelectedLevels[level[@"key"]] delegate:self.delegate];
        }
        
        itemView.tag = i;
        [self.levelsMap setObject:@{@"key": level[@"key"], @"label": level[@"label"], @"view": itemView} forKey:[NSString stringWithFormat:@"%li", i]];
        [self.contentView addSubview:itemView];
        [itemViews addObject:itemView];
        i++;
        
    }
    
    
    if (self.defaultValue) {
        i = 1;
        for (NSDictionary *level in self.levels) {
            
            itemView = self.levelsMap[[NSString stringWithFormat:@"%li", i]][@"view"];
            if ([[self.currentLevels objectForKey:level[@"key"]] count] > 0) {
                NSInteger row = [self.currentLevels[level[@"key"]] indexOfObject:self.currentSelectedLevels[level[@"key"]]];
                [(UIPickerView *)itemView selectRow:row inComponent:0 animated:NO];
            }
            i++;
        }
    }
    
    

    
    self.itemViews = itemViews;
    self.question.title = originTitle;
    [self autolayout];
}
    
- (void)loadItemViews {
    
    
    NSMutableArray<NSDictionary *> *levels = [NSMutableArray new];
    
    NSObject *prevLevel = [NSNull null];
    for (NSString *levelString in [self.question.filterFields componentsSeparatedByString:@","]) {
        
        NSArray *levelSplit = [levelString componentsSeparatedByString:@"|"];
        NSDictionary *level = @{@"key": levelSplit[0], @"label": levelSplit[1], @"prevLevel": prevLevel};
        [levels addObject: level];
        prevLevel = level;
    }
    
    self.levels = levels;

    
    self.currentSelectedLevels = [NSMutableDictionary new];
    self.levelsMap = [NSMutableDictionary new];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

    self.results = [prefs objectForKey:self.question.dataUrl];
    [self renderItemViews];


    // Prepare data from dataUrl
    QuestionDataSyncCommand *command = [[QuestionDataSyncCommand alloc] initWithConfiguration:[ConfigurationManager sharedConfiguration]];
    [command setDataUrl: self.question.dataUrl];
    [command setCompletionBlock:^(NSDictionary *params) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.results = params[@"results"];
            [self renderItemViews];
            [prefs setObject:self.results forKey:self.question.dataUrl];

        });
    }];
    
    
    [command setFailedBlock:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // Do nothing
        });
    }];
    
    
    [command start];

    
}

-(NSDictionary *) levelFromItemView:(UIView *)itemView {
    return [self.levelsMap objectForKey:[NSString stringWithFormat:@"%li", (long)itemView.tag]];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
    
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSDictionary *level = [self levelFromItemView:pickerView];
    return [[self.currentLevels objectForKey:level[@"key"]] count];
}
    
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSDictionary *level = [self levelFromItemView:pickerView];
    return [[self.currentLevels objectForKey:level[@"key"]] objectAtIndex:row];
}
    
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    NSDictionary *level = [self levelFromItemView:pickerView];

    [self.currentSelectedLevels setObject:[self.currentLevels[level[@"key"]] objectAtIndex:row] forKey:level[@"key"]];
    [self buildCurrentLevels];

    BOOL updateView = NO;
    
    for (UIView *itemView in self.itemViews) {

        if (updateView && [itemView isKindOfClass:[UIPickerView class]]) {
            
            level = [self levelFromItemView:itemView];
            
            [self.currentSelectedLevels setObject:[self.currentLevels[level[@"key"]] objectAtIndex:0] forKey:level[@"key"]];
            [(UIPickerView *)itemView reloadAllComponents];
            [(UIPickerView *)itemView selectRow:0 inComponent:0 animated:YES];
        }
        
        if (pickerView == itemView) {
            updateView = YES;
        }
        
    }
    
    
}


- (void)prepareForSubmit {
    
    [super prepareForSubmit];
    
    NSMutableArray *items = [NSMutableArray new];
    for (UIView *itemView in self.itemViews) {
        NSDictionary *level = [self levelFromItemView:itemView];
        NSString *value = @"";
        
        if ([itemView isKindOfClass:[UIPickerView class]]) {
            value = self.currentSelectedLevels[level[@"key"]];
        }
        else {
            value = ((SimpleQuestionView *)itemView).textView.text;
        }
        
        if (![value isEqualToString:@""]) {
            value = [NSString stringWithFormat:@"[%@:%@]", level[@"label"], value];
            [items addObject:value];
        }
    }
    
    NSString *formValue;
    if (items.count > 0) {
        formValue = [items componentsJoinedByString:@""];
    }
    
    [self.delegate setFormValue:formValue forKey:self.question.name];
    
}

    
    
@end


#import <Masonry.h>

@implementation AddressQuestionView (Layout)
    
- (void)autolayoutContent {
    
    [super autolayoutContent];
    
    UIView *previousView;
    UIView *superview = self.contentView;
    
    for (UIView *level in self.itemViews) {
        [level mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(superview.mas_left);
            make.right.equalTo(superview.mas_right);
            
            if (previousView) {
                make.top.equalTo(previousView.mas_bottom);
            } else {
                make.top.equalTo(superview.mas_top);
            }
        }];
        
        previousView = level;
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
