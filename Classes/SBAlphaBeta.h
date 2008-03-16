/*
Copyright (c) 2006,2007 Stig Brautaset. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

  Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

  Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

  Neither the name of the author nor the names of its contributors may be used
  to endorse or promote products derived from this software without specific
  prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/


#import <Foundation/Foundation.h>

/// Required protocol for states.
@protocol SBAlphaBetaSearching < NSCopying >

/**
How good is a state for the current player?

This method should return a state's fitness: a number indicating how
fortuitous the state is for the current player. That is, the
probability of winning after reaching this state. A positive number
indicate a good state, negatives means bad. The magnitude of the value
indicates the confidence.
*/
- (double)fitness;

/**
Array of legal moves for the current player.

This method must be implemented to return an array of all the legal
moves available to the current player. An empty array signifies that
there are no moves possible and that this is an end state. (Also known
as a leaf state.)

If your game supports passing, return an array containing a single
NSNull instance to signify a pass. If passing is always an option,
this method must always return a pass move.
*/
- (NSArray *)legalMoves;

/**
Applies the move and transforms the state into its successor.

Given a valid move, this method should transform the receiver into its
successor state.

It must be implemented to handle pass moves, if your game supports
these. (Given a pass move, this method must at the very least update
the receiver's idea of which player's turn it is.)
*/
- (void)applyMove:(id)m;

@end

/// Optional protocol for states.
@protocol SBUndoableAlphaBetaSearching

/**
Revert the effect of the last -applyMove: on the receiver.

The effect of this method should be to revert the receiver back to the
previous state. The move passed to it will always be the last move
that was applied to the receiver with -applyMove:. 
*/
- (void)undoMove:(id)m;

@end

/// Another optional protocol for states.
@protocol SBAlphaBetaStatus

/**
Is the state a draw?

Must be implemented to return YES if this state is a draw, i.e. none
of the players won.
*/
- (BOOL)isDraw;

/**
Is the state a winning state for the current player?

Must be implemented to return YES if this state is a win from the
perspective of the current player.
*/
- (BOOL)isWin;

@end

/// AlphaBeta search class
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

/// shortcut for -alloc and -initWithState:.
+ (id)newWithState:(id)this;

/// Initialise an instance with a state.
- (id)initWithState:(id)this;

/// Returns the current state.
- (id)currentState;

/// Returns the fitness of the current state.
- (double)currentFitness;

/// Returns the legal moves at the current state.
- (NSArray *)currentLegalMoves;

/// Returns 1 if it is player 1's turn to move, or 2 otherwise.
- (unsigned)currentPlayer;

/// Apply the given move and move to the next state.
- (id)performMove:(id)m;

/// Undo the last move that was performed and move to the previous state.
- (id)undoLastMove;

/// Return the last move that was performed.
- (id)lastMove;

/// Count the number of moves for the entire game.
- (unsigned)countPerformedMoves;

/// Returns YES if the game is at an end state, NO otherwise.
- (BOOL)isGameOver;

/// Returns YES if the current player must pass, NO otherwise.
- (BOOL)isForcedPass;

/// Returns 1 or 2 if the game had a winner, 0 otherwise (requires SBAlphaBetaStatus)
- (unsigned)winner;

/// Returns the best move found searching to the given depth.
- (id)moveFromSearchWithDepth:(unsigned)ply;

/// Returns the best move found searching for the given time.
- (id)moveFromSearchWithInterval:(NSTimeInterval)interval;

/// Immediately apply the best move found searching to depth
- (id)performMoveFromSearchWithDepth:(unsigned)ply;

/// Immediately apply the best move found searching to interval
- (id)performMoveFromSearchWithInterval:(NSTimeInterval)interval;

/// Number of states visited in the last search.
- (unsigned)stateCountForSearch;

/// Depth reached in the last iterative search.
- (unsigned)depthForSearch;

@end

