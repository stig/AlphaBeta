//
//  AlphaBeta.h
//  AlphaBeta
//
//  Created by Stig Brautaset on 11/12/2005.
//  Copyright 2005 Stig Brautaset. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const float AlphaBetaFitnessMax;
extern const float AlphaBetaFitnessMin;

@interface AlphaBeta : NSObject {
    NSMutableArray *states;
    NSMutableArray *moves;
    unsigned maxPly;
    int reachedPly;
    BOOL foundEnd;
    BOOL canUndo;
}
- (id)initWithState:(id)st;
- (void)setState:(id)st;
- (id)currentState;
- (id)lastMove;
- (id)fixedDepthSearch;
- (id)fixedDepthSearchToDepth:(unsigned)ply;
- (id)iterativeSearch;
- (id)iterativeSearchWithTime:(NSTimeInterval)s;
- (int)reachedPly;
- (unsigned)countMoves;
- (unsigned)countStates;
- (float)abWithAlpha:(float)alpha beta:(float)beta plyLeft:(unsigned)ply;
- (id)move:(id)m;
- (id)undo;
- (unsigned)maxPly;
- (void)setMaxPly:(unsigned)ply;
- (float)fitness;
- (BOOL)isGameOver;
@end
