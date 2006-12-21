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
#import "SBReversiMove.h"
#import "SBReversiState.h"


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

- (void)testMove
{
    id move = [SBReversiMove moveWithCol:2 andRow:1];
    STAssertTrue([move col] == 2, nil);
    STAssertTrue([move row] == 1, nil);
    STAssertEqualObjects([move description], @"(2,1)", nil);
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
        NSString *s;
        switch (i) {
            case 0: s = @"(1,2)"; break;
            case 1: s = @"(2,1)"; break;
            case 2: s = @"(3,4)"; break;
            case 3: s = @"(4,3)"; break;
        }
        STAssertEqualObjects([[[moves objectAtIndex:i] objectAtIndex:0] description], s, nil);
    }
}

- (void)testAvailMoves8x8
{
    STAssertNotNil(moves = [st movesAvailable], nil);
    STAssertEquals([moves count], (unsigned)4, nil);
    int i;
    for (i = 0; i < 4; i++) {
        NSString *s;
        switch (i) {
            case 0: s = @"(2,3)"; break;
            case 1: s = @"(3,2)"; break;
            case 2: s = @"(4,5)"; break;
            case 3: s = @"(5,4)"; break;
        }
        STAssertEqualObjects([[[moves objectAtIndex:i] objectAtIndex:0] description], s, nil);
    }
}

- (void)testStateAndFitness8x8
{
    STAssertTrue([st player] == 1, nil);
    STAssertTrue([st currentFitness] == 0.0, @"got: %f", [st currentFitness]);

    SBReversiStateCount c = [st countSquares];
    STAssertEquals(c.c[0], (unsigned)60, nil);
    STAssertEquals(c.c[1], (unsigned)2, nil);
    STAssertEquals(c.c[2], (unsigned)2, nil);

    STAssertEqualObjects([st description], @"1: 00000000 00000000 00000000 00021000 00012000 00000000 00000000 00000000", nil);

    [st applyMove:[st moveForCol:3 andRow:2]];
    STAssertEqualsWithAccuracy([st currentFitness], (float)-3.0, 0.0001, @"got %f", [st currentFitness]);
    STAssertEqualObjects([st description], @"2: 00000000 00000000 00010000 00011000 00012000 00000000 00000000 00000000", nil);

    [st applyMove:[st moveForCol:4 andRow:2]];
    STAssertEqualsWithAccuracy([st currentFitness], (float)0.0, 0.0001, @"got %f", [st currentFitness]);
    STAssertEqualObjects([st description], @"1: 00000000 00000000 00012000 00012000 00012000 00000000 00000000 00000000", nil);

    [st applyMove:[st moveForCol:5 andRow:5]];
    STAssertEqualsWithAccuracy([st currentFitness], (float)-2.0, 0.0001, @"got %f", [st currentFitness]);
    STAssertEqualObjects([st description], @"2: 00000000 00000000 00012000 00012000 00011000 00000100 00000000 00000000", nil);
}

- (void)testStateAndFitness4x4
{
    [st release];
    st = [[SBReversiState alloc] initWithBoardSize:4];

    STAssertEquals([st player], (int)1, nil);
    STAssertEquals([st currentFitness], (float)0.0, nil);

    STAssertEqualObjects([st description], @"1: 0000 0210 0120 0000", nil);

    STAssertNoThrow([st applyMove:[st moveForCol:1 andRow:0]], nil);
    STAssertEqualObjects([st description], @"2: 0100 0110 0120 0000", nil);
    STAssertEqualsWithAccuracy([st currentFitness], (float)-3.0, 0.0001, @"got %f", [st currentFitness]);
    STAssertEquals([st player], (int)2, nil);

    STAssertNoThrow([st applyMove:[st moveForCol:2 andRow:0]], nil);
    STAssertEqualObjects([st description], @"1: 0120 0120 0120 0000", nil);
    STAssertEqualsWithAccuracy([st currentFitness], (float)0.0, 0.0001, @"got %f", [st currentFitness]);
    STAssertEquals([st player], (int)1, nil);

    STAssertNoThrow([st applyMove:[st moveForCol:3 andRow:3]], nil);
    STAssertEqualObjects([st description], @"2: 0120 0120 0110 0001", nil);
    STAssertEqualsWithAccuracy([st currentFitness], (float)-1.0, 0.0001, @"got %f", [st currentFitness]);
    STAssertEquals([st player], (int)2, nil);
}

- (void)testTrace
{
    [st release];
    st = [[SBReversiState alloc] initWithBoardSize:6];

    SBAlphaBeta *ab = [[SBAlphaBeta alloc] initWithState:st];
    [ab setMaxPly:3];
    
    STAssertEqualObjects([st description], @"1: 000000 000000 002100 001200 000000 000000", nil);
    STAssertEqualObjects([[ab fixedDepthSearch] description], @"2: 000000 000000 011100 001200 000000 000000", nil);
    STAssertEqualObjects([[ab fixedDepthSearch] description], @"1: 000000 000000 011100 022200 000000 000000", nil);
    STAssertEqualObjects([[ab fixedDepthSearch] description], @"2: 000000 000000 011100 021200 001000 000000", nil);
    STAssertEqualObjects([[ab fixedDepthSearch] description], @"1: 000000 000200 012200 021200 001000 000000", nil);
    STAssertEqualObjects([[ab fixedDepthSearch] description], @"2: 000000 000200 011110 021100 001000 000000", nil);
    STAssertEqualObjects([[ab fixedDepthSearch] description], @"1: 000000 000200 011210 021200 001200 000000", nil);
    STAssertEqualObjects([[ab fixedDepthSearch] description], @"2: 000000 000210 011110 021200 001200 000000", nil);
    STAssertEqualObjects([[ab fixedDepthSearch] description], @"1: 000000 200210 021110 022200 001200 000000", nil);
    STAssertEqualObjects([[ab fixedDepthSearch] description], @"2: 000000 200210 111110 012200 001200 000000", nil);
    STAssertEqualObjects([[ab fixedDepthSearch] description], @"1: 000000 200210 211110 222200 001200 000000", nil);
    STAssertEqualObjects([[ab fixedDepthSearch] description], @"2: 000000 200210 211110 212200 101200 000000", nil);
    STAssertEqualObjects([[ab fixedDepthSearch] description], @"1: 000000 200210 211110 212200 201200 200000", nil);
    STAssertEqualObjects([[ab fixedDepthSearch] description], @"2: 000100 200110 211110 212200 201200 200000", nil);
    STAssertEqualObjects([[ab fixedDepthSearch] description], @"1: 000102 200120 211210 212200 201200 200000", nil);
    STAssertEqualObjects([[ab fixedDepthSearch] description], @"2: 000102 200120 211210 211110 201200 200000", nil);
    STAssertEqualObjects([[ab fixedDepthSearch] description], @"1: 000122 200220 212210 221110 201200 200000", nil);
    STAssertEqualObjects([[ab fixedDepthSearch] description], @"2: 000122 200210 212211 221110 201200 200000", nil);
    STAssertEqualObjects([[ab fixedDepthSearch] description], @"1: 000122 200222 212211 221110 201200 200000", nil);
    STAssertEqualObjects([[ab fixedDepthSearch] description], @"2: 001122 200122 212211 221110 201200 200000", nil);
    STAssertEqualObjects([[ab fixedDepthSearch] description], @"1: 022222 200122 212211 221110 201200 200000", nil);
    STAssertEqualObjects([[ab fixedDepthSearch] description], @"2: 022222 201122 211111 221110 201200 200000", nil);
    STAssertEqualObjects([[ab fixedDepthSearch] description], @"1: 022222 222222 221111 221110 201200 200000", nil);
    STAssertEqualObjects([[ab fixedDepthSearch] description], @"2: 122222 212222 221111 221110 201200 200000", nil);
    STAssertEqualObjects([[ab fixedDepthSearch] description], @"1: 122222 212222 222111 222110 202200 202000", nil);
    STAssertEqualObjects([[ab fixedDepthSearch] description], @"2: 122222 212222 222111 222110 202100 202100", nil);
    STAssertEqualObjects([[ab fixedDepthSearch] description], @"1: 122222 212222 222211 222120 202102 202100", nil);
    STAssertEqualObjects([[ab fixedDepthSearch] description], @"2: 122222 212222 222211 222111 202102 202100", nil);
    STAssertEqualObjects([[ab fixedDepthSearch] description], @"1: 122222 212222 222211 222111 202202 202220", nil);
    STAssertEqualObjects([[ab fixedDepthSearch] description], @"2: 122222 212222 222211 222111 201202 212220", nil);
    STAssertEqualObjects([[ab fixedDepthSearch] description], @"1: 122222 212222 222211 222111 222202 212220", nil);
    STAssertEqualObjects([[ab fixedDepthSearch] description], @"2: 122222 212222 222211 222111 222201 211111", nil);
    STAssertEqualObjects([[ab fixedDepthSearch] description], @"1: 122222 212222 222221 222221 222221 211111", nil);
    
    STAssertEquals([ab winner], (int)2, @"player 2 won");
}

- (void)testWeirdExceptionCase
{
    [st release];
    st = [[SBReversiState alloc] initWithBoardSize:6];
    
    SBAlphaBeta *ab = [[SBAlphaBeta alloc] initWithState:st];
    STAssertEqualObjects([[ab move:[st moveForCol:-1 andRow:-1]] description], @"2: 000000 000000 002100 001200 000000 000000", nil);
    
    STAssertEqualObjects([[ab move:[st moveForCol:2 andRow:4]] description], @"1: 000000 000000 002100 002200 002000 000000", nil);
    STAssertEqualObjects([[ab move:[st moveForCol:3 andRow:4]] description], @"2: 000000 000000 002100 002100 002100 000000", nil);

    STAssertEqualObjects([[ab move:[st moveForCol:4 andRow:4]] description], @"1: 000000 000000 002100 002200 002220 000000", nil);
    STAssertEqualObjects([[ab move:[st moveForCol:3 andRow:5]] description], @"2: 000000 000000 002100 002100 002120 000100", nil);
    
    STAssertEqualObjects([[ab move:[st moveForCol:4 andRow:3]] description], @"1: 000000 000000 002100 002220 002120 000100", nil);
    STAssertEqualObjects([[ab move:[st moveForCol:5 andRow:4]] description], @"2: 000000 000000 002100 002210 002111 000100", nil);
    
    STAssertEqualObjects([[ab move:[st moveForCol:4 andRow:5]] description], @"1: 000000 000000 002100 002210 002211 000120", nil);
    STAssertEqualObjects([[ab move:[st moveForCol:5 andRow:5]] description], @"2: 000000 000000 002100 002210 002211 000111", nil);
    
    STAssertEqualObjects([[ab move:[st moveForCol:4 andRow:2]] description], @"1: 000000 000000 002220 002210 002211 000111", nil);
    STAssertEqualObjects([[ab move:[st moveForCol:2 andRow:5]] description], @"2: 000000 000000 002220 002210 002111 001111", nil);

    STAssertEqualObjects([[ab move:[st moveForCol:5 andRow:3]] description], @"1: 000000 000000 002220 002222 002111 001111", nil);
    STAssertEquals([ab countMoves], (unsigned)12, nil);
    STAssertNotNil([[ab fixedDepthSearch] description], nil);
    STAssertEquals([ab countMoves], (unsigned)13, nil);

    /* Test for weird case where with finding moves */
    [ab undo];
    STAssertEqualObjects([[ab move:[st moveForCol:5 andRow:2]] description], @"2: 000000 000000 002221 002211 002111 001111", nil);
    STAssertEquals([[ab state] player], (int)2, nil);
    NSArray *a = [[ab state] movesAvailable];
    STAssertEquals([a count], (unsigned)1, nil);
    STAssertTrue([[a lastObject] isKindOfClass:[NSNull class]], nil);
}

- (void)testFailMove
{
    SBAlphaBeta *ab = [[SBAlphaBeta alloc] initWithState:st];
    STAssertThrows([ab move:[st moveForCol:0 andRow:0]], nil);
    STAssertEquals([ab countMoves], (unsigned)0, nil);

    STAssertThrows([ab move:[st moveForCol:0 andRow:-10]], nil);
    STAssertEquals([st player], (int)1, nil);    
    STAssertEquals([ab countMoves], (unsigned)0, nil);
    
    STAssertThrows([ab move:[st moveForCol:3 andRow:4]], nil);
    STAssertEquals([st player], (int)1, nil);
    STAssertEquals([ab countMoves], (unsigned)0, nil);
}

- (void)testMustPass
{
    [st release];
    st = [[SBReversiState alloc] initWithBoardSize:4];
    
    int **board = [st board];
    int i, j;
    for (i = 0; i < 4; i++)
        for (j = 0; j < 4; j++)
            board[i][j] = 0;

    board[0][0] = 2;
    board[1][0] = 1;

    SBAlphaBeta *ab = [SBAlphaBeta newWithState:st];
    STAssertEquals([ab player], (int)1, @"it is player 1");
    STAssertTrue([ab mustPass], @"must pass");
    
    STAssertNotNil([ab move:[NSNull null]], @"can apply pass move");
    STAssertEquals([ab player], (int)2, @"it is player 1");
    STAssertFalse([ab mustPass], @"must NOT pass");
}


- (void)testSBAlphaBeta
{
    [st release];
    st = [[SBReversiState alloc] initWithBoardSize:4];

    SBAlphaBeta *ab = [[SBAlphaBeta alloc] initWithState:st];
    STAssertNotNil(ab, @"got nil back");
    STAssertTrue([ab state] == st, @"did not get expected state back");
    STAssertEquals([ab countMoves], (unsigned)0, nil);
    STAssertEqualsWithAccuracy([ab currentFitness], (float)0.0, 0.0001, @"got %f", [ab currentFitness]);

    [ab setMaxPly:1];   // states below assumes a ply 2 search
    STAssertNil([ab lastMove], nil);

    STAssertNoThrow([ab fixedDepthSearch], nil); // why is this failing?
    STAssertEquals([ab countMoves], (unsigned)1, nil);
    STAssertEqualsWithAccuracy([ab currentFitness], (float)-3.0, 0.0001, @"got %f", [ab currentFitness]);
    
    STAssertNoThrow([ab fixedDepthSearch], nil); // why is this failing?
    STAssertEquals([ab countMoves], (unsigned)2, nil);
    STAssertEqualsWithAccuracy([ab currentFitness], (float)-1.0, 0.0001, @"got %f", [ab currentFitness]);
}

@end
