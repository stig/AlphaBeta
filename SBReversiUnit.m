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

#import <SBAlphaBeta/SBAlphaBeta.h>

#import "SBReversiUnit.h"


@implementation SBReversiUnit

- (void)setUp
{
    st = [SBReversiState new];
    moves = nil;
}

- (void)tearDown
{
    [st release];
}

- (void)testAvailMoves6x6
{
    [st release];
    st = [[SBReversiState alloc] initWithBoardSize:6];
    SBReversiStateCount c = [st countSquares];
    STAssertEquals(c.c[0], (unsigned)32, nil);
    STAssertEquals(c.c[1], (unsigned)2, nil);
    STAssertEquals(c.c[2], (unsigned)2, nil);
    STAssertNotNil(moves = [st movesAvailable], nil);
    STAssertEquals([moves count], (unsigned)4, nil);
    int i;
    for (i = 0; i < 4; i++) {
        id m2;
        switch (i) {
            case 0: m2 = [st moveWithCol:1 andRow:2]; break;
            case 1: m2 = [st moveWithCol:2 andRow:1]; break;
            case 2: m2 = [st moveWithCol:3 andRow:4]; break;
            case 3: m2 = [st moveWithCol:4 andRow:3]; break;
        }
        STAssertEqualObjects([[moves objectAtIndex:i] objectAtIndex:0], m2, nil);
    }
}

- (void)testAvailMoves8x8
{
    STAssertNotNil(moves = [st movesAvailable], nil);
    STAssertEquals([moves count], (unsigned)4, nil);
    int i;
    for (i = 0; i < 4; i++) {
        id m2;
        switch (i) {
            case 0: m2 = [st moveWithCol:2 andRow:3]; break;
            case 1: m2 = [st moveWithCol:3 andRow:2]; break;
            case 2: m2 = [st moveWithCol:4 andRow:5]; break;
            case 3: m2 = [st moveWithCol:5 andRow:4]; break;
        }
        STAssertEqualObjects([[moves objectAtIndex:i] objectAtIndex:0], m2, nil);
    }
}

- (void)testIterativeTimeKeeping
{
    SBAlphaBeta *ab = [SBAlphaBeta newWithState:st];
    id times = [@"0.05 0.1 0.2 0.5 1.0 2.0" componentsSeparatedByString:@" "];
    for (unsigned i = 0; i < [times count]; i++) {
        double interval = [[times objectAtIndex:i] doubleValue];

        NSDate *start = [NSDate date];
        [ab moveFromSearchWithInterval:interval];
        double duration = -[start timeIntervalSinceNow];

        /* _Must_ finish in less time than the interval */
        STAssertTrue( duration < interval, @"%f <= %f", duration, interval);

        /* We should really tolerate finishing up to 10% early...
        double accuracy = interval * 0.9;
        STAssertTrue( duration > accuracy, @"%f <= %f", duration, accuracy);
        */
    }
}

- (void)testPlayer
{
    SBAlphaBeta *ab = [SBAlphaBeta newWithState:st];
    STAssertEquals([ab playerTurn], (unsigned)1, nil);
    [ab applyMoveFromSearchWithPly:1];
    STAssertEquals([ab playerTurn], (unsigned)2, nil);
    [ab undoLastMove];
    STAssertEquals([ab playerTurn], (unsigned)1, nil);
}

- (void)testStateAndFitness8x8
{
    SBAlphaBeta *ab = [SBAlphaBeta newWithState:st];

    STAssertTrue([ab playerTurn] == 1, nil);
    STAssertTrue([ab currentFitness] == 0.0, @"got: %f", [st currentFitness]);

    SBReversiStateCount c = [st countSquares];
    STAssertEquals(c.c[0], (unsigned)60, nil);
    STAssertEquals(c.c[1], (unsigned)2, nil);
    STAssertEquals(c.c[2], (unsigned)2, nil);

    STAssertEqualObjects([st description], @"1: 00000000 00000000 00000000 00021000 00012000 00000000 00000000 00000000", nil);

    st = [ab applyMove:[st moveForCol:3 andRow:2]];
    STAssertEqualsWithAccuracy([ab currentFitness], (double)-3.0, 0.0001, @"got %f", [st currentFitness]);
    STAssertEqualObjects([st description], @"2: 00000000 00000000 00010000 00011000 00012000 00000000 00000000 00000000", nil);

    st = [ab applyMove:[st moveForCol:4 andRow:2]];
    STAssertEqualsWithAccuracy([ab currentFitness], (double)0.0, 0.0001, @"got %f", [st currentFitness]);
    STAssertEqualObjects([st description], @"1: 00000000 00000000 00012000 00012000 00012000 00000000 00000000 00000000", nil);

    st = [ab applyMove:[st moveForCol:5 andRow:5]];
    STAssertEqualsWithAccuracy([ab currentFitness], (double)-2.0, 0.0001, @"got %f", [st currentFitness]);
    STAssertEqualObjects([st description], @"2: 00000000 00000000 00012000 00012000 00011000 00000100 00000000 00000000", nil);
}

- (void)testStateAndFitness4x4
{
    [st release];
    st = [[SBReversiState alloc] initWithBoardSize:4];
    SBAlphaBeta *ab = [SBAlphaBeta newWithState:st];

    STAssertEquals([ab playerTurn], (unsigned)1, nil);
    STAssertEquals([ab currentFitness], (double)0.0, nil);

    STAssertEqualObjects([st description], @"1: 0000 0210 0120 0000", nil);

    STAssertNoThrow(st = [ab applyMove:[st moveForCol:1 andRow:0]], nil);
    STAssertEqualObjects([st description], @"2: 0100 0110 0120 0000", nil);
    STAssertEqualsWithAccuracy([ab currentFitness], (double)-3.0, 0.0001, @"got %f", [st currentFitness]);
    STAssertEquals([ab playerTurn], (unsigned)2, nil);

    STAssertNoThrow(st = [ab applyMove:[st moveForCol:2 andRow:0]], nil);
    STAssertEqualObjects([st description], @"1: 0120 0120 0120 0000", nil);
    STAssertEqualsWithAccuracy([ab currentFitness], (double)0.0, 0.0001, @"got %f", [st currentFitness]);
    STAssertEquals([ab playerTurn], (unsigned)1, nil);

    STAssertNoThrow(st = [ab applyMove:[st moveForCol:3 andRow:3]], nil);
    STAssertEqualObjects([st description], @"2: 0120 0120 0110 0001", nil);
    STAssertEqualsWithAccuracy([ab currentFitness], (double)-1.0, 0.0001, @"got %f", [st currentFitness]);
    STAssertEquals([ab playerTurn], (unsigned)2, nil);
}

- (void)testTrace
{
    [st release];
    st = [[SBReversiState alloc] initWithBoardSize:6];

    SBAlphaBeta *ab = [[SBAlphaBeta alloc] initWithState:st];
    STAssertEqualObjects([st description], @"1: 000000 000000 002100 001200 000000 000000", nil);
    
    id s, states = [[NSArray arrayWithObjects:
        @"2: 000000 000000 011100 001200 000000 000000",
        @"1: 000000 000000 011100 022200 000000 000000",
        @"2: 000000 000000 011100 021200 001000 000000",
        @"1: 000000 000200 012200 021200 001000 000000",
        @"2: 000000 000200 011110 021100 001000 000000",
        @"1: 000000 000200 011210 021200 001200 000000",
        @"2: 000000 000210 011110 021200 001200 000000",
        @"1: 000000 200210 021110 022200 001200 000000",
        @"2: 000000 200210 111110 012200 001200 000000",
        @"1: 000000 200210 211110 222200 001200 000000",
        @"2: 000000 200210 211110 212200 101200 000000",
        @"1: 000000 200210 211110 212200 201200 200000",
        @"2: 000100 200110 211110 212200 201200 200000",
        @"1: 000102 200120 211210 212200 201200 200000",
        @"2: 000102 200120 211210 211110 201200 200000",
        @"1: 000122 200220 212210 221110 201200 200000",
        @"2: 000122 200210 212211 221110 201200 200000",
        @"1: 000122 200222 212211 221110 201200 200000",
        @"2: 001122 200122 212211 221110 201200 200000",
        @"1: 022222 200122 212211 221110 201200 200000",
        @"2: 022222 201122 211111 221110 201200 200000",
        @"1: 022222 222222 221111 221110 201200 200000",
        @"2: 122222 212222 221111 221110 201200 200000",
        @"1: 122222 212222 222111 222110 202200 202000",
        @"2: 122222 212222 222111 222110 202100 202100",
        @"1: 122222 212222 222211 222120 202102 202100",
        @"2: 122222 212222 222211 222111 202102 202100",
        @"1: 122222 212222 222211 222111 202202 202220",
        @"2: 122222 212222 222211 222111 201202 212220",
        @"1: 122222 212222 222211 222111 222202 212220",
        @"2: 122222 212222 222211 222111 222201 211111",
        @"1: 122222 212222 222221 222221 222221 211111",
        nil] objectEnumerator];
    
    while (s = [states nextObject]) {
        STAssertEqualObjects([[ab applyMoveFromSearchWithPly:3] description], s, nil);
    }
    
    STAssertEquals([ab winner], (unsigned)2, @"player 2 won");
}

- (void)testWeirdExceptionCase
{
    [st release];
    st = [[SBReversiState alloc] initWithBoardSize:6];
    
    SBAlphaBeta *ab = [[SBAlphaBeta alloc] initWithState:st];
    
    /* make player 2 start this time. Cannot go via ab to do this, as it's strictly an illegal move. */
    [st transformWithMove:[st moveForCol:-1 andRow:-1]];
    STAssertEqualObjects([st description], @"2: 000000 000000 002100 001200 000000 000000", nil);
    
    STAssertEqualObjects([[ab applyMove:[st moveForCol:2 andRow:4]] description], @"1: 000000 000000 002100 002200 002000 000000", nil);
    STAssertEqualObjects([[ab applyMove:[st moveForCol:3 andRow:4]] description], @"2: 000000 000000 002100 002100 002100 000000", nil);

    STAssertEqualObjects([[ab applyMove:[st moveForCol:4 andRow:4]] description], @"1: 000000 000000 002100 002200 002220 000000", nil);
    STAssertEqualObjects([[ab applyMove:[st moveForCol:3 andRow:5]] description], @"2: 000000 000000 002100 002100 002120 000100", nil);
    
    STAssertEqualObjects([[ab applyMove:[st moveForCol:4 andRow:3]] description], @"1: 000000 000000 002100 002220 002120 000100", nil);
    STAssertEqualObjects([[ab applyMove:[st moveForCol:5 andRow:4]] description], @"2: 000000 000000 002100 002210 002111 000100", nil);
    
    STAssertEqualObjects([[ab applyMove:[st moveForCol:4 andRow:5]] description], @"1: 000000 000000 002100 002210 002211 000120", nil);
    STAssertEqualObjects([[ab applyMove:[st moveForCol:5 andRow:5]] description], @"2: 000000 000000 002100 002210 002211 000111", nil);
    
    STAssertEqualObjects([[ab applyMove:[st moveForCol:4 andRow:2]] description], @"1: 000000 000000 002220 002210 002211 000111", nil);
    STAssertEqualObjects([[ab applyMove:[st moveForCol:2 andRow:5]] description], @"2: 000000 000000 002220 002210 002111 001111", nil);

    STAssertEqualObjects([[ab applyMove:[st moveForCol:5 andRow:3]] description], @"1: 000000 000000 002220 002222 002111 001111", nil);
    STAssertEquals([ab countMoves], (unsigned)11, nil);
    STAssertNotNil([ab applyMoveFromSearchWithPly:3], nil);
    STAssertEquals([ab countMoves], (unsigned)12, nil);

    /* Test for weird case where with finding moves */
    [ab undoLastMove];
    STAssertEqualObjects([[ab applyMove:[st moveForCol:5 andRow:2]] description], @"2: 000000 000000 002221 002211 002111 001111", nil);
    STAssertEquals([ab playerTurn], (unsigned)1, nil);
    NSArray *a = [[ab currentState] movesAvailable];
    STAssertEquals([a count], (unsigned)1, nil);
    STAssertTrue([[a lastObject] isKindOfClass:[NSNull class]], nil);
}

- (void)testFailMove
{
    SBAlphaBeta *ab = [[SBAlphaBeta alloc] initWithState:st];
    STAssertEquals([ab playerTurn], (unsigned)1, nil);    

    STAssertThrows([ab applyMove:[st moveForCol:0 andRow:0]], nil);
    STAssertEquals([ab playerTurn], (unsigned)1, nil);    
    STAssertEquals([ab countMoves], (unsigned)0, nil);

    STAssertThrows([ab applyMove:[st moveForCol:0 andRow:-10]], nil);
    STAssertEquals([ab playerTurn], (unsigned)1, nil);    
    STAssertEquals([ab countMoves], (unsigned)0, nil);
    
    STAssertThrows([ab applyMove:[st moveForCol:3 andRow:4]], nil);
    STAssertEquals([ab playerTurn], (unsigned)1, nil);
    STAssertEquals([ab countMoves], (unsigned)0, nil);
}

- (void)testMustPass
{
    [st release];
    st = [[SBReversiState alloc] initWithBoardSize:4];
    
    int **board = ((SBReversiState *)st)->board;
    int i, j;
    for (i = 0; i < 4; i++)
        for (j = 0; j < 4; j++)
            board[i][j] = 0;

    board[0][0] = 2;
    board[1][0] = 1;

    SBAlphaBeta *ab = [SBAlphaBeta newWithState:st];
    STAssertEquals([ab playerTurn], (unsigned)1, @"it is player 1");
    STAssertTrue([ab currentPlayerMustPass], @"must pass");
    
    STAssertNotNil([ab applyMove:[NSNull null]], @"can apply pass move");
    STAssertEquals([ab playerTurn], (unsigned)2, @"it is player 1");
    STAssertFalse([ab currentPlayerMustPass], @"must NOT pass");
}


- (void)testSBAlphaBeta
{
    [st release];
    st = [[SBReversiState alloc] initWithBoardSize:4];

    SBAlphaBeta *ab = [[SBAlphaBeta alloc] initWithState:st];
    STAssertNotNil(ab, @"got nil back");
    STAssertTrue([ab currentState] == st, @"did not get expected state back");
    STAssertEquals([ab countMoves], (unsigned)0, nil);
    STAssertEqualsWithAccuracy([ab currentFitness], (double)0.0, 0.0001, @"got %f", [ab currentFitness]);

    STAssertNil([ab lastMove], nil);

    STAssertNoThrow([ab applyMoveFromSearchWithPly:1], nil);
    STAssertEquals([ab countMoves], (unsigned)1, nil);
    STAssertEqualsWithAccuracy([ab currentFitness], (double)-3.0, 0.0001, @"got %f", [ab currentFitness]);
    
    STAssertNoThrow([ab applyMoveFromSearchWithPly:1], nil);
    STAssertEquals([ab countMoves], (unsigned)2, nil);
    STAssertEqualsWithAccuracy([ab currentFitness], (double)-1.0, 0.0001, @"got %f", [ab currentFitness]);
}

@end
