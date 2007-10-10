/*

Copyright (C) 2006,2007 Stig Brautaset. All rights reserved.

This file is part of AlphaBeta.

AlphaBeta is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

AlphaBeta is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with AlphaBeta; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

*/

#import <Foundation/Foundation.h>

// Required protocol for states.
@protocol SBAlphaBetaSearching < NSCopying >

- (double)fitness;
- (double)endStateScore;
- (NSArray *)legalMoves;
- (void)applyMove:(id)m;

@end

// Optional protocol for states.
@protocol SBUndoableAlphaBetaSearching

- (void)undoMove:(id)m;

@end


@interface SBAlphaBeta : NSObject {
    @private
    BOOL mutableStates;
    NSMutableArray *stateHistory;
    NSMutableArray *moveHistory;

    NSDate *dateLimit;
    unsigned plyReached;
    unsigned statesVisited;
    BOOL foundEnd;
}

+ (id)newWithState:(id)this;
- (id)initWithState:(id)this;

- (id)currentState;
- (double)currentFitness;
- (NSArray *)currentLegalMoves;
- (unsigned)currentPlayer;

- (id)performMove:(id)m;
- (id)undoLastMove;

- (id)lastMove;
- (unsigned)countPerformedMoves;

- (BOOL)isGameOver;
- (BOOL)isForcedPass;
- (unsigned)winner;

/* search methods */
- (id)moveFromSearchWithDepth:(unsigned)ply;
- (id)moveFromSearchWithInterval:(NSTimeInterval)interval;
- (id)performMoveFromSearchWithDepth:(unsigned)ply;
- (id)performMoveFromSearchWithInterval:(NSTimeInterval)interval;

/* metadata releated to previous search */
- (unsigned)stateCountForSearch;
- (unsigned)depthForSearch;

@end

