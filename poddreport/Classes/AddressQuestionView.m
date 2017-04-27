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

@end

@implementation AddressQuestionView
    
- (instancetype)initWithQuestion:(Question *)question
                    defaultValue:(NSString *)values
                        delegate:(id<QuestionViewDelegate>)delegate {
    
    if (self = [super initWithQuestion:question
                          defaultValue:values
                              delegate:delegate]) {
        [self loadItemViews];
        //[self autolayout];
        //[self choiceItemDidSelectItem:values];
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
                if (prevLevel && [self.currentLevels[prevLevel[@"key"]] count] > 0) {
                    
                    NSDictionary *backwardLevel = prevLevel;
                    while (backwardLevel && ![backwardLevel isEqual:[NSNull null]]) {
                        NSString *backwardLabel = [self.currentSelectedLevels objectForKey:backwardLevel[@"key"]];
                        
                        NSLog(@"%@ %@ %@ %d", backwardLabel, [item objectForKey:backwardLevel[@"key"]], item[backwardLevel[@"key"]], [item[backwardLevel[@"key"]] isEqualToString: backwardLabel]);
                        
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
    
- (void)loadItemViews {
    
    /*
     {
         "dataUrl": "/places/?category__code=subdistrict",
         "name": "address",
         "title": "\u0e17\u0e35\u0e48\u0e2d\u0e22\u0e39\u0e48\u0e1c\u0e39\u0e49\u0e1b\u0e48\u0e27\u0e22",
         "filterFields": "level_name|\u0e40\u0e25\u0e02\u0e17\u0e35\u0e48\u0e1a\u0e49\u0e32\u0e19\u0e1c\u0e39\u0e49\u0e1b\u0e48\u0e27\u0e22,level0_name|\u0e08\u0e31\u0e07\u0e2b\u0e27\u0e31\u0e14,level1_name|\u0e2d\u0e33\u0e40\u0e20\u0e2d,level2_name|\u0e15\u0e33\u0e1a\u0e25,level_name|\u0e2b\u0e21\u0e39\u0e48\u0e17\u0e35\u0e48",
         "validations": [
             {
                 "message": "\u0e01\u0e23\u0e38\u0e13\u0e32\u0e01\u0e23\u0e2d\u0e01\u0e02\u0e49\u0e2d\u0e21\u0e39\u0e25\u0e43\u0e2b\u0e49\u0e04\u0e23\u0e1a\u0e16\u0e49\u0e27\u0e19",
                 "type": "address"
             }
         ],
         "type": "address",
         "id": 1361
     }
     
     */
    
    self.currentSelectedLevels = [NSMutableDictionary new];
    self.levelsMap = [NSMutableDictionary new];

    
    // Prepare data from dataUrl
    QuestionDataSyncCommand *command = [[QuestionDataSyncCommand alloc] initWithConfiguration:[ConfigurationManager sharedConfiguration]];
    [command setDataUrl: self.question.dataUrl];
    [command setCompletionBlock:^(NSDictionary *params) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSString *originTitle = self.question.title;
            
            self.results = params[@"results"];
            
            [self buildCurrentLevels];
            
            NSMutableArray<UIView *> *itemViews = [NSMutableArray new];
            [self.contentView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
            
            long i = 1;
            for (NSDictionary *level in self.levels) {
                
                UIView *itemView;
                
                if ([[self.currentLevels objectForKey:level[@"key"]] count] > 0) {
                    itemView = [UIPickerView new];
                    [(UIPickerView *)itemView setDataSource: self];
                    [(UIPickerView *)itemView setDelegate: self];
                    ((UIPickerView *)itemView).showsSelectionIndicator = YES;
                    // TODO: add default value
                }
                else {
                    // TODO: add default value
                    self.question.title = level[@"label"];
                    itemView = [[SimpleQuestionView alloc] initWithQuestion:self.question defaultValue:@"todo: default value" delegate:self.delegate];
                }
                
                itemView.tag = i;
                [self.levelsMap setObject:@{@"key": level[@"key"], @"view": itemView} forKey:[NSString stringWithFormat:@"%li", i]];
                [self.contentView addSubview:itemView];
                [itemViews addObject:itemView];
                i++;

            }
            self.itemViews = itemViews;
            self.question.title = originTitle;
            [self autolayout];
        
        });
    }];
    
    /*
    [command setFailedBlock:^(NSError *error) {
        //dispatch_sync(dispatch_get_main_queue(), ^{
            NSString *errorCode = [NSString stringWithFormat:@"%tu", error.code];
            //[self resultFailure: NSLocalizedString(errorCode, nil)];
        //});
    }];
     */
    
    [command start];
    
    NSMutableArray<NSDictionary *> *levels = [NSMutableArray new];

    NSObject *prevLevel = [NSNull null];
    for (NSString *levelString in [self.question.filterFields componentsSeparatedByString:@","]) {
        
        NSArray *levelSplit = [levelString componentsSeparatedByString:@"|"];
        NSDictionary *level = @{@"key": levelSplit[0], @"label": levelSplit[1], @"prevLevel": prevLevel};
        [levels addObject: level];
        prevLevel = level;
    }
    
    self.levels = levels;
    
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
    NSLog(@"%@ -- %@", level[@"key"], [self.currentLevels[level[@"key"]] objectAtIndex:row]);

    [self.currentSelectedLevels setObject:[self.currentLevels[level[@"key"]] objectAtIndex:row] forKey:level[@"key"]];
    [self buildCurrentLevels];
    
    for (UIView *itemView in self.itemViews) {
        if ([itemView isKindOfClass:[UIPickerView class]]) {
            [((UIPickerView *)itemView) reloadAllComponents];
        }
    }
    
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
