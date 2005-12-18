//
//  TTTState.h
//  AlphaBeta
//
//  Created by Stig Brautaset on 11/12/2005.
//  Copyright 2005 Stig Brautaset. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlphaBetaState.h"
#import "TTTMove.h"

@interface TTTState : NSObject <AlphaBetaState> {
    int board[3][3];
    int player;
}
- (NSString *)string;
- (int)player;
@end
