/*
Copyright (C) 2007 Stig Brautaset. All rights reserved.

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

/**
@file SBAlphaBetaState.h
@brief Protocols used for working with SBAlphaBeta.
*/

/**
Protocol for immutable states.

Your immutable states must implement the following methods.
*/
@protocol SBAlphaBetaState < NSCopying >

/**
Should return the current fitness. The fitness is a number indicating for fortuitous the state is for the current player.

Use a high positive number for very good, high negative number for very bad.
*/
- (double)fitness;

/**
Indicates the result at an end state. Return a positive value if the receiving state is a winning state for the current player, negative for a loss, or 0 if it is a draw. The result of calling this method on a non-leaf state is undefined.

SBAlphaBeta only cares whether the values returned from this method are negative, positive or zero; but you may wish to implement it to return a score that you can use for a high-score list.
*/
- (double)endStateScore;

/** 
Returns an array of all the available moves for the current player. An empty array means that there are no moves possible and that this is an end state. Use NSNull instances for pass moves, if your game allows passing.
*/
- (NSArray *)legalMoves;

/**
Should apply the given move to the state, transforming it into its successor. Please make sure to handle pass moves, if your game allow those.
*/
- (void)applyMove:(id)m;

@end

/**
Protocol for mutable states.

The following methods are required for SBAlphaBeta to work with mutable states.
*/
@protocol SBMutableAlphaBetaState < SBAlphaBetaState >

/** 
The opposite of -applyMove:. The move passed in will always be the <em>last</em> move that was applied to it with -applyMove:, and the effect of this method should be to produce the previous state.

This means that each move returned by -legalMoves must contain enough information to revert the move. For Othello, for example, each move could be an of co-ordinates: the first is the slot to put the current piece, the remaining are for pieces to flip.

*/
- (void)undoTransformWithMove:(id)m;

@end
