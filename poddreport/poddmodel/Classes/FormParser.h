//
//  FormParser.h
//  poddmodel
//
//  Created by Opendream-iOS on 1/12/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Form.h"

@interface FormParser : NSObject
@end

@interface FormParser (Parse)
- (Form *)parse:(NSDictionary *)data;
@end
