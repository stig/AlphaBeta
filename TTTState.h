//
//  TTTState.h
//  AlphaBeta
//
//  Created by Stig Brautaset on 11/12/2005.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AlphaBetaState.h"
#import "TTTMove.h"

@interface TTTState : NSObject {
    int board[3][3];
    int player;
}

@end
