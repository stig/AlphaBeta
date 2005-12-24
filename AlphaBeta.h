//
//  AlphaBeta.h
//  AlphaBeta
//
//  Created by Stig Brautaset on 11/12/2005.
//  Copyright 2005 Stig Brautaset. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlphaBeta : NSObject {
    NSMutableArray *states;
    NSMutableArray *moves;
    unsigned maxPly;
}
- (id)initWithState:(id)st;
- (void)setState:(id)st;
- (id)currentState;
- (id)lastMove;
- (id)aiMove;
- (unsigned)countMoves;
- (unsigned)countStates;
- (float)abWithAlpha:(float)alpha beta:(float)beta plyLeft:(unsigned)ply;
- (id)move:(id)m;
- (id)undo;
- (unsigned)maxPly;
- (void)setMaxPly:(unsigned)ply;
@end
