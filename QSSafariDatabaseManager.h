//
//  QSSafariDatabaseManager.h
//  QSSafariPlugIn
//
//  Created by Patrick Robertson on 05/02/2016.
//
//

#import <QSFoundation/FMDB.h>

@interface QSSafariDatabaseManager : NSObject

+(FMDatabase *)openDatabase:(NSString *)name;

@end
