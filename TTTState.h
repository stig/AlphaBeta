//
//  TTTState.h
//  AlphaBeta
//
//  Created by Stig Brautaset on 11/12/2005.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlphaBetaState.h"
#import "TTTMove.h"

@interface TTTState : NSObject <NSCopying> {
    int board[3][3];
    int playerTurn;
}
- (NSString *)string;
- (int)playerTurn;
@end
