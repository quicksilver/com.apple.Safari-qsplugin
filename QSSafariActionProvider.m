//
//  QSSafariActionProvider.m
//  QSSafariPlugIn
//
//  Created by Rob McBroom on 2011/12/7.
//

#import "QSSafariActionProvider.h"

@implementation QSSafariActionProvider

- (QSObject *)addToReadingList:(QSObject *)dObject
{
	SafariApplication *Safari = [self getSafari];
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

- (SafariApplication *)getSafari
{
	return [SBApplication applicationWithBundleIdentifier:@"com.apple.Safari"];
}

@end
