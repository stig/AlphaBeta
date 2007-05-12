/*
Copyright (C) 2006 Stig Brautaset. All rights reserved.

This file is part of SBAlphaBeta.

SBAlphaBeta is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

SBAlphaBeta is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with SBAlphaBeta; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

*/

/**
@file SBAlphaBeta/SBAlphaBeta.h
@brief MiniMax with Alpha-Beta pruning (aka Alpha-Beta algorithm)
@mainpage SBAlphaBeta

SBAlphaBeta encapsulates the Alpha-Beta algorithm (aka MiniMax search with Alpha-Beta pruning) and can be used to create AIs for a large range of two-player games. No prior experience with Artificial Intelligence  is necessary.

In order to use SBAlphaBeta your state class must implement the four methods in the SBAlphaBetaState protocol.

Assuming MyGameState implements the required protocol, here's how one could implement a very simple game:

@code
id state = [MyGameState new];
id ab = [SBAlphaBeta newWithState:state];

for (int turn = 1; ; turn++) {

    // This NSLog output will be boring
    // unless you override -description.
    NSLog(@"%@", [ab currentState]);
    
    if ([ab isGameOver]) {
        // Could be done in the loop condition, but then
        // we wouldn't see the final state of the game
        break;
     
    } else if (turn & 2) {
        // Spend 300 ms searching for the best move,
        // then apply that move to the current state
        [ab applyMoveFromSearchWithInterval:0.3];
        
    }
    else {
        id move = <get move from user>;
        [ab applyMove:move];
    }
}
@endcode

@section maturity_sec A note on code & interface maturity

Though the code is mature and well tested, I'm still not entirely happy with the interface presented to the user. Thus, the interface may change between releases. The broad strokes are there, however, so if you use SBAlphaBeta to implement a game you should find it relatively simple to update to new versions.

@section users_sec Who/what uses SBAlphaBeta?

I maintain several Cocoa games for Mac OS X that all use SBAlphaBeta to provide their AIs. For example:

@li <a href="/Phage">Phage</a> - an abstract strategy game not <em>entirely</em> unlike Chess
@li <a href="/Auberon">Auberon</a> - a Connect-4 game
@li <a href="/Desdemona">Desdemona</a> - a Reversi (Othello) game

@section applicability_sec Applicability

For the Alpha-Beta algorithm to be applicable for your game, it needs to be a so-called two-player <a href="http://en.wikipedia.org/wiki/Zero-sum">zero-sum</a> <a href="http://en.wikipedia.org/wiki/Perfect_information">perfect information</a> game. This sounds like very small slice of the whole game pai, but it actually encompasses a whole slew of games. Chess, Go, Othello, Connect-4 etc all fall in this category.

@section code_sec Getting the code

Download <a href="__DMGURL__">SBAlphaBeta __VERSION__</a>, containing an embeddable framework, or get the source from Subversion:

@verbatim
# bleeding edge
svn co http://svn.brautaset.org/SBAlphaBeta/trunk SBAlphaBeta

# latest released version
svn co http://svn.brautaset.org/SBAlphaBeta/tags/__VERSION__ SBAlphaBeta
@endverbatim

@section feedback_sec Feedback / Bugreports

Please send praise and bile to <a href="mailto:stig@brautaset.org">stig@brautaset.org</a>.

*/

#import <Foundation/Foundation.h>
#import "SBAlphaBetaState.h"

@interface SBAlphaBeta : NSObject {
    @private
    BOOL mutableStates;
    NSMutableArray *stateHistory;
    NSMutableArray *moveHistory;

    unsigned plyReached;
    BOOL foundEnd;
}

+ (id)newWithState:(id)this;
- (id)initWithState:(id)this;

- (id)lastMove;
- (id)currentState;
- (BOOL)isGameOver;
- (BOOL)currentPlayerMustPass;
- (unsigned)countMoves;
- (id)applyMove:(id)m;
- (id)undoLastMove;

/* messages forwarded to the state */
- (double)currentFitness;
- (NSArray *)movesAvailable;

/* search methods */
- (id)moveFromSearchWithPly:(unsigned)ply;
- (id)moveFromSearchWithInterval:(NSTimeInterval)interval;
- (id)applyMoveFromSearchWithPly:(unsigned)ply;
- (id)applyMoveFromSearchWithInterval:(NSTimeInterval)interval;
- (unsigned)plyReachedForSearch;
@end

