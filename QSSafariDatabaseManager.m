//
//  QSSafariDatabaseManager.m
//  QSSafariPlugIn
//
//  Created by Patrick Robertson on 05/02/2016.
//
//

#import "QSSafariDatabaseManager.h"
#import "QSSafariPlugIn.h"

@implementation QSSafariDatabaseManager


+(FMDatabase *)openDatabase:(NSString *)name {
	NSFileManager *manager = [NSFileManager defaultManager];
	NSString *tempFile = [NSTemporaryDirectory() stringByAppendingString:[name lastPathComponent]];
	NSError *err;
	
	[manager removeItemAtPath:tempFile error:&err];
	
	if (![manager copyItemAtPath:name toPath:tempFile error:&err]) {
		NSLog(@"Error while copying %@ to %@: %@", name, tempFile, err);
		return nil;
	}
	
	FMDatabase *db = [FMDatabase databaseWithPath:tempFile];
	if (![db open]) {
		NSLog(@"Could not open database %@", tempFile);
		return nil;
	}
	
	return db;
}

@end
