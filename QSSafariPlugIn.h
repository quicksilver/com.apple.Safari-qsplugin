#import <Foundation/Foundation.h>
#import "Safari.h"

@interface QSSafariObjectHandler : QSObjectSource
{
	SafariApplication *Safari;
	NSDictionary *iconMap;
}

- (NSArray *)safariChildren;
- (QSObject *)currentPagesParent;
- (QSObject *)addToReadingList:(QSObject *)dObject;
@end

@interface QSSafariBookmarksParser : QSParser
- (NSArray *)safariBookmarksForDict:(NSDictionary *)dict deep:(BOOL)deep includeProxies:(BOOL)proxies;
-(QSObject *)bookmarkGroupObjectForDict:(NSDictionary *)dict;
-(QSObject *)bookmarkLeafObjectForDict:(NSDictionary *)dict;
@end
@interface QSSafariHistoryParser : QSParser
@end
