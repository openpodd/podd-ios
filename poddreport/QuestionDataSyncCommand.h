//
//  QuestionDataSyncCommand.h
//  poddreport
//
//  Created by crosalot on 4/25/17.
//  Copyright © 2017 Opendream. All rights reserved.
//

#import "NetworkCommand.h"

@interface QuestionDataSyncCommand : NetworkCommand
    @property (copy, nonatomic, nonnull) NSString *dataUrl;
@end

