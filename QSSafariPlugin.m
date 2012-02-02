#import "QSSafariPlugin.h"

@implementation QSSafariObjectHandler

- (id)init {
    self = [super init];
    if (self) {
        Safari = [[SBApplication applicationWithBundleIdentifier:@"com.apple.Safari"] retain];
		iconMap = [[NSDictionary alloc] initWithObjectsAndKeys:
					@"SafariBookmarkMenuIcon", @"BookmarksMenu",
					@"SafariBookmarkBarIcon", @"BookmarksBar",
					@"Recent", @"History",
					@"Bonjour", @"Bonjour",
					@"com.apple.AddressBook", @"Address Book",
					@"SafariBookmarkRSSIcon", @"All RSS Feeds",
					@"SafariBookmarkReadingListIcon", @"com.apple.ReadingList",
				   nil];
    }
    return self;
}

- (void)dealloc {
    [Safari release];
	[iconMap release];
    [super dealloc];
}

- (void)performJavaScript:(NSString *)jScript
{
	SafariTab *frontTab = [[[Safari windows] objectAtIndex:0] currentTab];
	[Safari doJavaScript:jScript in:frontTab];
}

- (id)resolveProxyObject:(id)proxy
{
	if ([Safari isRunning]) {
		NSString *url = [[[[Safari windows] objectAtIndex:0] currentTab] URL];
		if (url) {
			if ([[proxy identifier] isEqualToString:@"QSSafariFrontPageProxy"]) {
				return [QSObject URLObjectWithURL:url title:nil];
			}
			if ([[proxy identifier] isEqualToString:@"QSSafariSearchCurrentSite"]) {
				NSURL *currentURL = [NSURL URLWithString:url];
				NSString *searchShortcut = [NSString stringWithFormat:@"http://www.google.com/search?q=*** site:%@", [currentURL host]];
				return [QSObject URLObjectWithURL:searchShortcut title:nil];
			}
		}
	}
	return nil;
}

- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry
{
	return NO;
}

- (NSArray *)objectsForEntry:(NSDictionary *)theEntry
{
	if ([[theEntry objectForKey:@"ID"] isEqualToString:@"QSPresetSafariOpenPages"]) {
		return [NSArray arrayWithObject:[self currentPagesParent]];
	}
	return nil;
}

- (BOOL)loadChildrenForObject:(QSObject *)object {
	if ([[object primaryType] isEqualToString:NSFilenamesPboardType]) {
		[object setChildren:[self safariChildren]];
		return YES; 	
	}
    if ([[object primaryType] isEqualToString:QSProxyType]) {
        QSObject *realObject = [QSObject URLObjectWithURL:[object objectForType:QSURLType] title:nil];
        [object setChildren:[NSArray arrayWithObject:realObject]];
        return YES;
    }
	if ([[object primaryType] isEqualToString:@"qs.safari.openPages"]) {
		if ([Safari isRunning]) {
			NSMutableArray *openPages = [NSMutableArray arrayWithCapacity:1];
			NSString *url;
			NSString *title;
			QSObject *page;
			for (SafariWindow *openWindow in [Safari windows]) {
				for (SafariTab *openTab in [openWindow tabs]) {
					url = [openTab URL];
					title = [openTab name];
					page = [QSObject URLObjectWithURL:url title:title];
					[openPages addObject:page];
				}
			}
			[object setChildren:openPages];
			return YES;
		} else {
			return NO;
		}
	}
	NSDictionary *dict = [object objectForType:@"qs.safari.bookmarkGroup"];
	NSString *type = [dict objectForKey:@"WebBookmarkType"];
	NSString *ident = [dict objectForKey:@"WebBookmarkIdentifier"];
	//NSLog(@"bookmark type: %@ and ID: %@", type, ident);
	
	NSArray *children = nil;
	
	if (![type isEqualToString:@"WebBookmarkTypeProxy"]) {
		id parser = [[[QSSafariBookmarksParser alloc] init] autorelease];
		children = [parser safariBookmarksForDict:dict deep:NO includeProxies:YES];
	} else if ([ident isEqualToString:@"History"]) {
		QSCatalogEntry *theEntry = [QSLib entryForID:@"QSPresetSafariHistory"];
		children = [theEntry scanAndCache];
	} else if ([ident isEqualToString:@"Bonjour"]) {
		return NO;
	} else if ([ident isEqualToString:@"Address Book"]) {
		children = [[QSReg getClassInstance:@"QSAddressBookObjectSource"] performSelector:@selector(contactWebPages)];
	}
	
	if (children) {
		[object setChildren:children];
		return YES;  
	}
	return NO;
}

- (BOOL)objectHasChildren:(id <QSObject>)object {
	return YES;
}

- (NSString *)detailsOfObject:(QSObject *)object {
	
	NSDictionary *dict = [object objectForType:@"qs.safari.bookmarkGroup"];
	
	NSString *type = [dict objectForKey:@"WebBookmarkType"];
	//NSString *ident = [dict objectForKey:@"WebBookmarkIdentifier"];
	
	if (![type isEqualToString:@"WebBookmarkTypeProxy"]) {
		
		int count = [[dict objectForKey:@"Children"] count];
		return [NSString stringWithFormat:@"%d item%@", count, ESS(count)];
	}
	return nil;
}

- (NSArray *)safariChildren {
	id parser = [[[QSSafariBookmarksParser alloc] init] autorelease];
	
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: [@"~/Library/Safari/Bookmarks.plist" stringByStandardizingPath]];
	
	NSMutableArray *children = [parser safariBookmarksForDict:dict deep:NO includeProxies:YES];
	[children addObject:[self currentPagesParent]];
	return children;
}

- (QSObject *)currentPagesParent
{
	QSObject *currentPages = [QSObject makeObjectWithIdentifier:@"QSSafariOpenPages"];
	[currentPages setName:@"Open Web Pages (Safari)"];
	[currentPages setDetails:@"URLs from all open windows and tabs"];
	[currentPages setPrimaryType:@"qs.safari.openPages"];
	return currentPages;
}

// Object Handler Methods
- (void)setQuickIconForObject:(QSObject *)object {
	if ([[object primaryType] isEqualToString:@"qs.safari.openPages"]) {
		[object setIcon:[QSResourceManager imageNamed:@"com.apple.Safari"]];
	} else {
		[object setIcon:[QSResourceManager imageNamed:@"GenericFolderIcon"]];
	}
}

- (BOOL)loadIconForObject:(QSObject *)object {
	NSDictionary *dict = [object objectForType:@"qs.safari.bookmarkGroup"];
	NSString *title = [dict objectForKey:@"Title"];
		
	NSString *icon = [iconMap objectForKey:title];
	if (icon) {
		[object setIcon:[QSResourceManager imageNamed:icon]];
		return YES;
	}
	return NO;
}

@end

@implementation QSSafariBookmarksParser

- (BOOL)validParserForPath:(NSString *)path {
    return [[path lastPathComponent] isEqualToString:@"Bookmarks.plist"];
}

- (NSArray *)objectsFromPath:(NSString *)path withSettings:(NSDictionary *)settings {
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: [path stringByStandardizingPath]];
    return [self safariBookmarksForDict:dict deep:YES includeProxies:NO];
}

- (NSArray *)safariBookmarksForDict:(NSDictionary *)dict deep:(BOOL)deep includeProxies:(BOOL)proxies {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:1];
	NSString *title = [dict objectForKey:@"Title"];
	if ([title isEqualToString:@"Archive"]) return nil; //***Skip Archive Folder
	
	
	NSEnumerator *childEnum = [[dict objectForKey:@"Children"] objectEnumerator];
	NSDictionary *child;
	while (child = [childEnum nextObject]) {
		NSString *type = [child objectForKey:@"WebBookmarkType"];
		QSObject *object = nil;
		if ([type isEqualToString:@"WebBookmarkTypeLeaf"]) {
			//if ([ident isEqualToString:@"Address Book Bookmark Proxy Identifier"]) 			
			if (object = [self bookmarkLeafObjectForDict:child])
				[array addObject:object];
		} else if ([type isEqualToString:@"WebBookmarkTypeList"]) {
			if (deep)
				[array addObjectsFromArray:[self safariBookmarksForDict:child deep:YES includeProxies:proxies]];
			if (object = [self bookmarkGroupObjectForDict:child])
				[array addObject:object]; 			
		} else if ([type isEqualToString:@"WebBookmarkTypeProxy"] && proxies) {
			NSString *ident = [child objectForKey:@"WebBookmarkIdentifier"];
			if ([ident isEqualToString:@"Bonjour Bookmark Proxy Identifier"])
				continue;
		
			//if ([ident isEqualToString:@"Address Book Bookmark Proxy Identifier"])
			QSObject *object = [self bookmarkGroupObjectForDict:child];
		
			if (object)
				[array addObject:object];
			//else NSLog(@"child %@", child);
		}
	}
	return  array;
}

- (NSString *)safariLocalizedString:(NSString *)string {
	NSBundle *bundle = [NSBundle bundleWithPath:[[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:@"com.apple.Safari"]]; 	
	return [bundle localizedStringForKey:string value:string table:@"Localizable"];
}

- (QSObject *)bookmarkGroupObjectForDict:(NSDictionary *)dict {

	NSString *title = [dict objectForKey:@"Title"];
	NSString *identifier = [dict objectForKey:@"WebBookmarkUUID"];
	
	if ([title isEqualToString:@"BookmarksBar"]) {
		title = [self safariLocalizedString:@"Bookmarks Bar"];
	}
	if ([title isEqualToString:@"BookmarksMenu"]) {
		title = [self safariLocalizedString:@"Bookmarks Menu"];
	}
	if ([title isEqualToString:@"com.apple.ReadingList"]) {
		title = @"Reading List";
	}
	QSObject *group = [QSObject objectWithName:title];
	//NSLog(@"title %@", title);
	[group setIdentifier:identifier];
	[group setObject:dict forType:@"qs.safari.bookmarkGroup"];
	[group setPrimaryType:@"qs.safari.bookmarkGroup"];
	[group setObject:@"" forMeta:kQSObjectDefaultAction];
	
	//	if ([dict objectForKey:@"WebBookmarkAutoTab"])
	
	NSMutableArray *urls = [[[[dict objectForKey:@"Children"] valueForKey:@"URLString"] mutableCopy] autorelease];
	[urls removeObject:[NSNull null]];
	//NSLog(@"urls %@", urls);
	[group setObject:urls forType:QSURLType];
	//[group setObject:@"GenericFolderIcon" forMeta:kQSObjectDefaultAction];
	//NSLog(@"dict %@", urls);
	
	return group;
}

- (QSObject *)bookmarkLeafObjectForDict:(NSDictionary *)dict {
	NSString *url = [dict objectForKey:@"URLString"];
	NSString *title = [[dict objectForKey:@"URIDictionary"] objectForKey:@"title"];
	QSObject *leaf = [QSObject URLObjectWithURL:url title:title];
	return leaf;
}

@end

@implementation QSSafariHistoryParser

- (BOOL)validParserForPath:(NSString *)path {
    return [[path lastPathComponent] isEqualToString:@"History.plist"];
}

- (NSArray *)objectsFromPath:(NSString *)path withSettings:(NSDictionary *)settings {
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: [path stringByStandardizingPath]];
    NSArray *history = [dict objectForKey:@"WebHistoryDates"];
    
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:1];
    
    NSEnumerator *childEnum = [history objectEnumerator];
    NSDictionary *child;
    while (child = [childEnum nextObject]) {
        NSString *url = [child objectForKey:@""];
        NSString *title = [child objectForKey:@"title"];
        QSObject *object = [QSObject URLObjectWithURL:url title:title];
        if (object) [array addObject:object];
    }
    return  array;
    
}

@end
