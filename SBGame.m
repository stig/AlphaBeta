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

#import <SBAlphaBeta/SBGame.h>

@implementation SBGame


- (id)init
{
    if (self = [super init]) {
        moves = [NSMutableArray new];
    }
    return self;
}

/** Shortcut for calling alloc & initWithState:. */
+ (id)newWithState:(id)this
{
    return [[self alloc] initWithState:this];
}

/** Initialise an SBAlphaBeta object with a starting state */
- (id)initWithState:(id)st
{
    if (self = [self init]) {
        [self setState:st];
    }
    return self;
}

- (void)dealloc
{
    [searcher release];
    [state release];
    [moves release];
    [super dealloc];
}

#pragma mark Accessors

/** Set the searcher instance. A searcher instance is an instance of a class
that implements the SBAlphaBetaSearch protocol. This means you can plug in your
own search implementation at run-time. */
- (void)setSearcher:(id)this
{
    if (![this conformsToProtocol:@protocol(SBGameSearcher)]) {
        [NSException raise:@"searcher"
                    format:@"Doesn't implement the SBGameSearcher protocol"];
    }
    if (this != searcher) {
        [searcher release];
        searcher = [this retain];
    }
}

/** Returns the currently active searcher instance. */
- (id)searcher { return searcher; }

/** Sets the starting state of an SBAlphaBeta instance to @p st. Throws an
exception if the instance has already been instantiated with a state. */
- (void)setState:(id)this
{
    if (state) {
        [NSException raise:@"state set" format:@"State already set"];
    }
    if (![this conformsToProtocol:@protocol(SBGameState)]) {
        [NSException raise:@"state"
                    format:@"Doesn't implement the SBGameState protocol"];
    }
    state = [this retain];
}

/** Returns the current state. */
- (id)state { return state; }

/** Sets the default limit to be used for searches. */
- (void)setDefaultLimit:(id)this
{
    if (defaultLimit != this) {
        [defaultLimit release];
        defaultLimit = [this retain];
    }
}

/** Returns the default limit used in searches. */
- (id)defaultLimit { return defaultLimit; }

#pragma mark Misc

/** Returns the last move performed */
- (id)lastMove
{
    return [moves lastObject];
}

/** Returns a count of the number of moves since the initial state */
- (unsigned)countMoves
{
    return [moves count];
}

#pragma mark Search functions

/** @group Search functions */

/** Basic search using the default searcher and limit. */
- (id)search
{
    return [self searchWithSearcher:[self searcher]
                           andLimit:[self defaultLimit]];
}

/** Search for a move using a custom limit. */
- (id)searchWithLimit:(id)limit
{
    return [self searchWithSearcher:[self searcher]
                           andLimit:limit];
}

/** Search for a move using a custom searcher. */
- (id)searchWithSearcher:(id)this
{
    return [self searchWithSearcher:this
                           andLimit:[self defaultLimit]];
}

/** Search for a move using a custom searcher and limit. */
- (id)searchWithSearcher:(id)this andLimit:(id)lim
{
    id best = [this moveFromState:[self state] withLimit:lim];
    if (!best)
        [NSException raise:@"nomove"
					format:@"%@ with limit %@ returned no move for %@", this, lim, [self state]];
    return [self move:best];
}

/** @endgroup */

#pragma mark Forwarded functions

/** Calls currentFitness on the current state and returns its value. This 
method is provided for convenience. */
- (float)currentFitness
{
    return [[self state] currentFitness];
}

/** Returns the available moves at the current state. This method is
provided for convenience, and simply forwards its message to the
current state. */
- (NSArray *)movesAvailable
{
    return [[self state] movesAvailable];
}

/** Returns an integer-representation of who the winner is. This would
nominally be 0 for draw, 1 or 2. */
- (int)winner
{
    return [[self state] winner];
}

/** Apply the given move to the current state. */
- (id)move:(id)m
{
    @try {
        if (![[self state] applyMove:m]) {
            [NSException raise:@"movefail" format:@"applyMove returned false"];
        }
        [moves addObject:m];
    }
    @catch (id any) {
        [NSException raise:@"failmove" format:@"Failed applying move: %@", [any reason]];
    }
    return [self state];
}

/** Undo one position from the given state. */
- (id)undo
{
    if (![moves count]) {
        [NSException raise:@"undo" format:@"No moves to undo"];
    }
    
    id s = [self state];
    if (![s undoMove:[moves lastObject]]) {
        [NSException raise:@"undofail" format:@"Failed to undo move"];
    }
    [moves removeLastObject];
    return [self state];
}

/** Returns an integer representation of the current player. */
- (int)player
{
    return [[self state] player];
}

/** Returns true if the game is finished, false otherwise. */
- (BOOL)isGameOver
{
    NSArray *a = [[self state] movesAvailable];
    return [a count] ? NO : YES;
}

/** Returns true if the current player has no option but to pass. */
- (BOOL)mustPass
{
    id mvs = [self movesAvailable];
    if (mvs && [mvs count] == 1)
        if ([[mvs lastObject] isKindOfClass:[NSNull class]])
            return YES;
    return NO;
}

@end
