//
//  ReportFeedItem.m
//  poddreport
//
//  Created by Opendream-iOS on 2/23/2559 BE.
//  Copyright © 2559 Opendream. All rights reserved.
//

#import "ReportFeedItem.h"

@interface ReportFeedItem () {
    NSAttributedString *_reportFeedAttributedString;
}
@end

@implementation ReportFeedItem

- (instancetype _Nonnull)initWithDictionary:(NSDictionary * _Nonnull)dictionary {
    
    if (self = [super init]) {
        _createdBy = [dictionary[@"createdBy"] intValue];
        _reportId = [dictionary[@"reportId"] intValue];
        _uid = [dictionary[@"uid"] intValue];
        _administrationAreaId = [dictionary[@"administrationAreaId"] intValue];
        _reportTypeId = [dictionary[@"reportTypeId"] intValue];
        _negative = [dictionary[@"negative"] boolValue];
        _testFlag = [dictionary[@"testFlag"] boolValue];
        _administrationAreaAddress = dictionary[@"administrationAreaAddress"];
        _createdByName = dictionary[@"createdByName"];
        _formDataExplanation = dictionary[@"formDataExplanation"];
        _firstImageThumbnail = dictionary[@"firstImageThumbnail"];
        _guid = dictionary[@"guid"];
        _reportLocation = dictionary[@"reportLocation"];
        _reportTypeName = dictionary[@"reportTypeName"];
        _createdByTelephone = dictionary[@"createdByTelephone"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setCalendar:[NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian]];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en"]];
        
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        _incidentDate = [dateFormatter dateFromString:dictionary[@"incidentDate"]];
        
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        _date = [dateFormatter dateFromString:dictionary[@"date"]];
    }
    return self;
}

- (NSString *)description {
    
    return [NSString stringWithFormat:@"reportId %i, date %@, reportType %@, firstImageThumbnail %@ formDataExp. %@"
            ,self.reportId
            ,self.date
            ,self.reportTypeName
            ,self.firstImageThumbnail
            ,self.formDataExplanation];
}

- (NSAttributedString *)reportDescriptionAttributedString {
    
    if (!_reportFeedAttributedString) {
        NSMutableAttributedString *attributedString;
        attributedString = [[NSMutableAttributedString alloc]
                           initWithData:[self.formDataExplanation dataUsingEncoding:NSUTF8StringEncoding] 
                           options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType
                                     ,NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}
                           documentAttributes:nil
                           error:nil]; 
        
        NSDictionary *labelAttributes = @{
                                          NSForegroundColorAttributeName: [UIColor blackColor]
                                          ,NSFontAttributeName: [UIFont fontWithName:@"SukhumvitSet-Light" size:15]
                                          };
        [attributedString setAttributes:labelAttributes 
                                  range:NSMakeRange(0, attributedString.length)];
        
        _reportFeedAttributedString = attributedString;
    }
    
    return _reportFeedAttributedString;
}
@end
