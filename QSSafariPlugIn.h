#import <Foundation/Foundation.h>
#import "Safari.h"

@interface QSSafariObjectHandler : NSObject
- (NSArray *)safariChildren;
- (SafariApplication *)getSafari;
@end

@interface QSSafariBookmarksParser : QSParser
- (NSArray *)safariBookmarksForDict:(NSDictionary *)dict deep:(BOOL)deep includeProxies:(BOOL)proxies;
-(QSObject *)bookmarkGroupObjectForDict:(NSDictionary *)dict;
-(QSObject *)bookmarkLeafObjectForDict:(NSDictionary *)dict;
@end
@interface QSSafariHistoryParser : QSParser
@end
