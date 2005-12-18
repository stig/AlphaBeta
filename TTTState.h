//
//  TTTState.h
//  AlphaBeta
//
//  Created by Stig Brautaset on 11/12/2005.
//  Copyright 2005 Stig Brautaset. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTTMove.h"

@interface TTTState : NSObject <NSCopying> {
    int board[3][3];
    int playerTurn;
}
- (NSString *)string;
- (int)playerTurn;

/* for now specify the methods here... */
- (float)fitness;
- (NSMutableArray *)listAvailableMoves;
- (void)applyMove:(id)m;
- (void)undoMove:(id)m;
@end
