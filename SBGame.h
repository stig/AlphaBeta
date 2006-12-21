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

#import <Foundation/Foundation.h>


/**
Protocol for states. States used with SBGame must conform to this protocol in
order for things to work. 
*/
@protocol SBGameState

/**
Should return the current fitness, i.e. a number indicating for fortuitous the
state is for the current player. Use a high positive number for very good, high
negative number for very bad.

The number returned from this method must lie in the range defined by
SBAlphaBetaFitnessMax and SBAlphaBetaFitnessMin (currently +1e6 to -1e6).

@todo should this return an NSNumber instance instead of a float?
*/
- (float)currentFitness;

/** 
Should return an array of moves. Must be implemented to return all the
currently available moves for the current player. If the only available
move at the current state is to pass, an array containing a single
NSNull value must be returned.
*/
- (NSArray *)movesAvailable;

/**
Should apply the given move to the state, thereby transforming it into its
successor.
*/
- (id)applyMove:(id)m;

/** 
If given the same move, should reverse the effect of applyMove: on a state.
That is, it should transform the state into the previous.
*/
- (id)undoMove:(id)m;

/**
Should return an integer-representation of the player that is about to move.
*/
- (int)player;

/**
Should return an integer-representation of who the winner is. This would
nominally be 0 for draw, 1 or 2.

The result of calling this method before the game is over (i.e. while
movesAvailable still returns valid moves) is undefined.
*/
- (int)winner;

@end


/**
Protocol for searcher classes.
Any object implementing this protocol can be plugged into a SBGame object to
provide it with a different search algorithm at runtime. 
*/
@protocol SBGameSearcher
- (id)moveFromState:(id)state withLimit:(id)limit;
@end

/**
A generic game-building framework.
*/
@interface SBGame : NSObject {
    id state;
    NSMutableArray *moves;
    id searcher;
    id defaultLimit;
}

+ (id)newWithState:(id)st;
- (id)initWithState:(id)st;

/* accessors */
- (void)setState:(id)st;
- (id)state;
- (void)setSearcher:(id)aSearcher;
- (id)searcher;
- (void)setDefaultLimit:(id)lim;
- (id)defaultLimit;

/* messages forwarded to the state */
- (id)move:(id)m;
- (id)undo;
- (float)currentFitness;
- (NSArray *)movesAvailable;
- (int)winner;
- (int)player;

/* search messages */
- (id)search;
- (id)searchWithLimit:(id)lim;
- (id)searchWithSearcher:(id)lim;
- (id)searchWithSearcher:(id)strategy andLimit:(id)lim;

/* other messages */
- (BOOL)isGameOver;
- (BOOL)mustPass;
- (unsigned)countMoves;
- (id)lastMove;
@end
