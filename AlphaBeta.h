//
//  AlphaBeta.h
//  AlphaBeta
//
//  Created by Stig Brautaset on 11/12/2005.
//  Copyright 2005 Stig Brautaset. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AlphaBetaState.h>

@interface AlphaBeta : NSObject {
    NSMutableArray *states;
    NSMutableArray *moves;
    int maxPly;
}
- (id)initWithState:(id)st;
- (void)setState:(id)st;
- (id)currentState;
- (id)lastMove;
- (id)aiMove;
- (int)countMoves;
- (int)countStates;
- (float)abWithAlpha:(float)alpha beta:(float)beta plyLeft:(int)ply;
- (id)move:(id)m;
- (id)undo;
- (int)maxPly;
- (void)setMaxPly:(int)ply;
@end
