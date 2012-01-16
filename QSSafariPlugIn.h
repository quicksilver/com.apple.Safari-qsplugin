#import <Foundation/Foundation.h>
#import "Safari.h"

@interface QSSafariObjectHandler : NSObject
{
	SafariApplication *Safari;
	NSDictionary *iconMap;
}

- (NSArray *)safariChildren;
@end

@interface QSSafariBookmarksParser : QSParser
- (NSArray *)safariBookmarksForDict:(NSDictionary *)dict deep:(BOOL)deep includeProxies:(BOOL)proxies;
-(QSObject *)bookmarkGroupObjectForDict:(NSDictionary *)dict;
-(QSObject *)bookmarkLeafObjectForDict:(NSDictionary *)dict;
@end
@interface QSSafariHistoryParser : QSParser
@end
