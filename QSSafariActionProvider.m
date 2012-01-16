//
//  QSSafariActionProvider.m
//  QSSafariPlugIn
//
//  Created by Rob McBroom on 2011/12/7.
//

#import "QSSafariActionProvider.h"

@implementation QSSafariActionProvider

- (id)init {
    self = [super init];
    if (self) {
        Safari = [[SBApplication applicationWithBundleIdentifier:@"com.apple.Safari"] retain];
    }
    return self;
}

- (void)dealloc {
    [Safari release];
    [super dealloc];
}

- (QSObject *)addToReadingList:(QSObject *)dObject
{
	NSString *url;
//	NSString *preview;
	NSString *title;
	for (QSObject *bookmark in [dObject splitObjects]) {
		url = [bookmark objectForType:QSURLType];
		title = [bookmark displayName];
		[Safari addReadingListItem:url andPreviewText:nil withTitle:title];
	}
	return nil;
}

@end
