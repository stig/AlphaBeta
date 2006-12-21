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

/** @mainpage

@section Introduction

SBAlphaBeta is a generic implementation of Alpha-Beta algorithm (aka MiniMax
search with alpha-beta pruning). This implementation in Objective-C is heavily
inspired by GGTL[0], but method names have been changed to comply with
Objective-C naming guidelines.

[0] http://brautaset.org/software/#ggtl

@section Synopsis

@code
#import <SBAlphaBeta/SBAlphaBeta.h>

MyGameState *state = [[MyGameState alloc] init];
SBAlphaBeta *ab = [[SBAlphaBeta alloc] initWithState:state];

// Traverse the game tree depth-first to a depth of 4. Pick
// the move that will put the current player in the best worst
// case if its opponent plays optimally.
[ab fixedDepthSearchWithPly:4];

// Iterate down the game-tree for 5 seconds, starting at depth
// N=1, then to depths N+1, N+2 etc. Pick the move found at the
// deepest completed search.
[ab iterativeSearchWithTime:5.0];

// Perform a user-selected move
[ab move:[MyGameMove moveWithString:@"attack!"];

@endcode

@section Description

SBAlphaBeta works with states and moves. It must be initialised with the initial
state of the game before use (using either the -[initWithState:] constructor or
the -[setState:] method). All states must implement the SBGameState protocol.

SBAlphaBeta is much less picky about moves than states. At the moment the only
restriction for moves is that they have to be real objects; you cannot use a
struct. You can use any Objective-C object of your choice though.

*/


#import <SBAlphaBeta/SBGame.h>

@interface SBAlphaBeta : SBGame {
    unsigned maxPly;
    NSTimeInterval maxTime;
    int reachedPly;
    BOOL foundEnd;
}

- (id)fixedDepthSearch;
- (id)fixedDepthSearchWithPly:(unsigned)ply;
- (id)iterativeSearch;
- (id)iterativeSearchWithTime:(double)seconds;

- (int)reachedPly;
- (unsigned)maxPly;
- (void)setMaxPly:(unsigned)ply;
- (NSTimeInterval)maxTime;
- (void)setMaxTime:(NSTimeInterval)time;


@end


