//
//  QSSafariActionProvider.h
//  QSSafariPlugIn
//
//  Created by Rob McBroom on 2011/12/7.
//

#import <QSCore/QSCore.h>
#import "Safari.h"

@interface QSSafariActionProvider : QSActionProvider
{
	SafariApplication *Safari;
}

- (QSObject *)addToReadingList:(QSObject *)dObject;

@end
