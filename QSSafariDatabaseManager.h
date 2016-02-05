//
//  QSSafariDatabaseManager.h
//  QSSafariPlugIn
//
//  Created by Patrick Robertson on 05/02/2016.
//
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface QSSafariDatabaseManager : NSObject

+(FMDatabase *)openDatabase:(NSString *)name;

@end
