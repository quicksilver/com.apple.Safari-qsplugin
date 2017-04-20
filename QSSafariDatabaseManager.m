//
//  QSSafariDatabaseManager.m
//  QSSafariPlugIn
//
//  Created by Patrick Robertson on 05/02/2016.
//
//

#import "QSSafariDatabaseManager.h"
#import "QSSafariPlugIn.h"
#import <sqlite3.h>

@implementation QSSafariDatabaseManager


+ (FMDatabase *)openDatabase:(NSString *)name {
	NSString *tempFile = name;

	FMDatabase *db = [FMDatabase databaseWithPath:tempFile];
	NSString *vfsFile = @"unix-none";
	if (![db openWithFlags:SQLITE_OPEN_READONLY vfs:vfsFile]) {
		NSLog(@"Could not open database %@: %@", tempFile, [db lastError]);
		return nil;
	}
	return db;
}

@end
