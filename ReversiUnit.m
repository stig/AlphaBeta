//
//  ReversiUnit.m
//  AlphaBeta
//
//  Created by Stig Brautaset on 18/12/2005.
//  Copyright 2005 Stig Brautaset. All rights reserved.
//

#import "ReversiUnit.h"
#import "ReversiMove.h"
#import "AlphaBeta.h"
#import "ReversiState.h"


@implementation ReversiUnit

- (void)setUp
{
    st = [[ReversiState alloc] init];
    moves = nil;
}

- (void)tearDown
{
    [st release];
}

- (void)testMove
{
    id move = [[ReversiMove alloc] initWithCol:2 andRow:1];
    STAssertTrue([move col] == 2, nil);
    STAssertTrue([move row] == 1, nil);
    STAssertTrue([[move string] isEqualToString:@"21"], nil);
    [move release];
}

- (void)testAvailMoves6x6
{
    [st release];
    st = [[ReversiState alloc] initWithBoardSize:6];
    ReversiStateCount c = [st countSquares];
    STAssertEquals(c.c[0], (unsigned)32, nil);
    STAssertEquals(c.c[1], (unsigned)2, nil);
    STAssertEquals(c.c[2], (unsigned)2, nil);
    STAssertNotNil(moves = [st listAvailableMoves], nil);
    STAssertEquals([moves count], (unsigned)4, nil);
    int i;
    for (i = 0; i < 4; i++) {
        NSString *s;
        switch (i) {
            case 0: s = @"12"; break;
            case 1: s = @"21"; break;
            case 2: s = @"34"; break;
            case 3: s = @"43"; break;
        }
        STAssertEqualObjects([[moves objectAtIndex:i] string], s, nil);
    }
}

- (void)testAvailMoves8x8
{
    STAssertNotNil(moves = [st listAvailableMoves], nil);
    STAssertEquals([moves count], (unsigned)4, nil);
    int i;
    for (i = 0; i < 4; i++) {
        NSString *s;
        switch (i) {
            case 0: s = @"23"; break;
            case 1: s = @"32"; break;
            case 2: s = @"45"; break;
            case 3: s = @"54"; break;
        }
        STAssertEqualObjects([[moves objectAtIndex:i] string], s, nil);
    }
}

- (void)testStateAndFitness8x8
{
    STAssertTrue([st player] == 1, nil);
    STAssertTrue([st fitness] == 0.0, @"got: %f", [st fitness]);

    ReversiStateCount c = [st countSquares];
    STAssertEquals(c.c[0], (unsigned)60, nil);
    STAssertEquals(c.c[1], (unsigned)2, nil);
    STAssertEquals(c.c[2], (unsigned)2, nil);

    STAssertEqualObjects([st string], @"00000000 00000000 00000000 00021000 00012000 00000000 00000000 00000000", nil);
    id copy = [st copy];
    STAssertEqualObjects([copy string], [st string], nil);

    [st applyMove:[[ReversiMove alloc] initWithCol:3 andRow:2]];
    STAssertEqualsWithAccuracy([st fitness], (float)-3.0, 0.0001, @"got %f", [st fitness]);
    STAssertEqualObjects([st string], @"00000000 00000000 00010000 00011000 00012000 00000000 00000000 00000000", nil);
    STAssertTrue(![[copy string] isEqualToString:[st string]], nil);
    [copy release];

    [st applyMove:[[ReversiMove alloc] initWithCol:4 andRow:2]];
    STAssertEqualsWithAccuracy([st fitness], (float)0.0, 0.0001, @"got %f", [st fitness]);
    STAssertEqualObjects([st string], @"00000000 00000000 00012000 00012000 00012000 00000000 00000000 00000000", nil);

    [st applyMove:[[ReversiMove alloc] initWithCol:5 andRow:5]];
    STAssertEqualsWithAccuracy([st fitness], (float)-2.0, 0.0001, @"got %f", [st fitness]);
    STAssertEqualObjects([st string], @"00000000 00000000 00012000 00012000 00011000 00000100 00000000 00000000", nil);
}

- (void)testStateAndFitness4x4
{
    [st release];
    st = [[ReversiState alloc] initWithBoardSize:4];

    STAssertEquals([st player], (int)1, nil);
    STAssertEquals([st fitness], (float)0.0, nil);

    STAssertEqualObjects([st string], @"0000 0210 0120 0000", nil);
    STAssertEqualObjects([[st copy] string], [st string], nil);

    [st applyMove:[[ReversiMove alloc] initWithCol:1 andRow:0]];
    STAssertEqualsWithAccuracy([st fitness], (float)-3.0, 0.0001, @"got %f", [st fitness]);
    STAssertEqualObjects([st string], @"0100 0110 0120 0000", nil);

    [st applyMove:[[ReversiMove alloc] initWithCol:2 andRow:0]];
    STAssertEqualsWithAccuracy([st fitness], (float)0.0, 0.0001, @"got %f", [st fitness]);
    STAssertEqualObjects([st string], @"0120 0120 0120 0000", nil);

    [st applyMove:[[ReversiMove alloc] initWithCol:3 andRow:3]];
    STAssertEqualsWithAccuracy([st fitness], (float)-1.0, 0.0001, @"got %f", [st fitness]);
    STAssertEqualObjects([st string], @"0120 0120 0110 0001", nil);
}

- (void)testTrace
{
    [st release];
    st = [[ReversiState alloc] initWithBoardSize:6];

    AlphaBeta *ab = [[AlphaBeta alloc] initWithState:st];
    [ab setMaxPly:3];
    
    STAssertEqualObjects([st string], @"000000 000000 002100 001200 000000 000000", nil);
    STAssertEqualObjects([[ab aiMove] string], @"000000 000000 011100 001200 000000 000000", nil);
    STAssertEqualObjects([[ab aiMove] string], @"000000 000000 011100 022200 000000 000000", nil);
    STAssertEqualObjects([[ab aiMove] string], @"000000 000000 011100 021200 001000 000000", nil);
    STAssertEqualObjects([[ab aiMove] string], @"000000 000200 012200 021200 001000 000000", nil);
    STAssertEqualObjects([[ab aiMove] string], @"000000 000200 011110 021100 001000 000000", nil);
    STAssertEqualObjects([[ab aiMove] string], @"000000 000200 011210 021200 001200 000000", nil);
    STAssertEqualObjects([[ab aiMove] string], @"000000 000210 011110 021200 001200 000000", nil);
    STAssertEqualObjects([[ab aiMove] string], @"000000 200210 021110 022200 001200 000000", nil);
    STAssertEqualObjects([[ab aiMove] string], @"000000 200210 111110 012200 001200 000000", nil);
    STAssertEqualObjects([[ab aiMove] string], @"000000 200210 211110 222200 001200 000000", nil);
    STAssertEqualObjects([[ab aiMove] string], @"000000 200210 211110 212200 101200 000000", nil);
    STAssertEqualObjects([[ab aiMove] string], @"000000 200210 211110 212200 201200 200000", nil);
    STAssertEqualObjects([[ab aiMove] string], @"000100 200110 211110 212200 201200 200000", nil);
    STAssertEqualObjects([[ab aiMove] string], @"000102 200120 211210 212200 201200 200000", nil);
    STAssertEqualObjects([[ab aiMove] string], @"000102 200120 211210 211110 201200 200000", nil);
    STAssertEqualObjects([[ab aiMove] string], @"000122 200220 212210 221110 201200 200000", nil);
    STAssertEqualObjects([[ab aiMove] string], @"000122 200210 212211 221110 201200 200000", nil);
    STAssertEqualObjects([[ab aiMove] string], @"000122 200222 212211 221110 201200 200000", nil);
    STAssertEqualObjects([[ab aiMove] string], @"001122 200122 212211 221110 201200 200000", nil);
    STAssertEqualObjects([[ab aiMove] string], @"022222 200122 212211 221110 201200 200000", nil);
    STAssertEqualObjects([[ab aiMove] string], @"022222 201122 211111 221110 201200 200000", nil);
    STAssertEqualObjects([[ab aiMove] string], @"022222 222222 221111 221110 201200 200000", nil);
    STAssertEqualObjects([[ab aiMove] string], @"122222 212222 221111 221110 201200 200000", nil);
    STAssertEqualObjects([[ab aiMove] string], @"122222 212222 222111 222110 202200 202000", nil);
    STAssertEqualObjects([[ab aiMove] string], @"122222 212222 222111 222110 202100 202100", nil);
    STAssertEqualObjects([[ab aiMove] string], @"122222 212222 222211 222120 202102 202100", nil);
    STAssertEqualObjects([[ab aiMove] string], @"122222 212222 222211 222111 202102 202100", nil);
    STAssertEqualObjects([[ab aiMove] string], @"122222 212222 222211 222111 202202 202220", nil);
    STAssertEqualObjects([[ab aiMove] string], @"122222 212222 222211 222111 201202 212220", nil);
    STAssertEqualObjects([[ab aiMove] string], @"122222 212222 222211 222111 222202 212220", nil);
    STAssertEqualObjects([[ab aiMove] string], @"122222 212222 222211 222111 222201 211111", nil);
    STAssertEqualObjects([[ab aiMove] string], @"122222 212222 222221 222221 222221 211111", nil);    
}

- (void)testWeirdExceptionCase
{
    [st release];
    st = [[ReversiState alloc] initWithBoardSize:6];
    
    AlphaBeta *ab = [[AlphaBeta alloc] initWithState:st];
    STAssertEqualObjects([[ab move:[ReversiMove newWithCol:-1 andRow:-1]] string], @"000000 000000 002100 001200 000000 000000", nil);
    
    STAssertEqualObjects([[ab move:[ReversiMove newWithCol:2 andRow:4]] string], @"000000 000000 002100 002200 002000 000000", nil);
    STAssertEqualObjects([[ab move:[ReversiMove newWithCol:3 andRow:4]] string], @"000000 000000 002100 002100 002100 000000", nil);

    STAssertEqualObjects([[ab move:[ReversiMove newWithCol:4 andRow:4]] string], @"000000 000000 002100 002200 002220 000000", nil);
    STAssertEqualObjects([[ab move:[ReversiMove newWithCol:3 andRow:5]] string], @"000000 000000 002100 002100 002120 000100", nil);
    
    STAssertEqualObjects([[ab move:[ReversiMove newWithCol:4 andRow:3]] string], @"000000 000000 002100 002220 002120 000100", nil);
    STAssertEqualObjects([[ab move:[ReversiMove newWithCol:5 andRow:4]] string], @"000000 000000 002100 002210 002111 000100", nil);
    
    STAssertEqualObjects([[ab move:[ReversiMove newWithCol:4 andRow:5]] string], @"000000 000000 002100 002210 002211 000120", nil);
    STAssertEqualObjects([[ab move:[ReversiMove newWithCol:5 andRow:5]] string], @"000000 000000 002100 002210 002211 000111", nil);
    
    STAssertEqualObjects([[ab move:[ReversiMove newWithCol:4 andRow:2]] string], @"000000 000000 002220 002210 002211 000111", nil);
    STAssertEqualObjects([[ab move:[ReversiMove newWithCol:2 andRow:5]] string], @"000000 000000 002220 002210 002111 001111", nil);

    STAssertEqualObjects([[ab move:[ReversiMove newWithCol:5 andRow:3]] string], @"000000 000000 002220 002222 002111 001111", nil);
    STAssertEquals([ab countStates], (unsigned)13, nil);
    STAssertNotNil([[ab aiMove] string], nil);
    STAssertEquals([ab countStates], (unsigned)14, nil);

    /* Test for weird case where with finding moves */
    [ab undo];
    STAssertEqualObjects([[ab move:[ReversiMove newWithCol:5 andRow:2]] string], @"000000 000000 002221 002211 002111 001111", nil);
    STAssertEquals([[ab currentState] player], (int)2, nil);
    NSArray *a = [[ab currentState] listAvailableMoves];
    STAssertEquals([a count], (unsigned)1, nil);
    STAssertEqualObjects([[a lastObject] string], @"-1-1", nil);
}

- (void)testFailMove
{
    AlphaBeta *ab = [[AlphaBeta alloc] initWithState:st];
    STAssertNil([ab move:[ReversiMove newWithCol:0 andRow:0]], nil);
    
    STAssertEquals([ab countStates], (unsigned)1, nil);
    STAssertEquals([ab countMoves], (unsigned)0, nil);

    STAssertNil([ab move:[ReversiMove newWithCol:0 andRow:-10]], nil);
    STAssertEquals([st player], (int)1, nil);

    STAssertNil([ab move:[ReversiMove newWithCol:3 andRow:4]], nil);
    STAssertEquals([st player], (int)1, nil);
}

- (void)testAlphaBeta
{
    [st release];
    st = [[ReversiState alloc] initWithBoardSize:4];

    AlphaBeta *ab = [[AlphaBeta alloc] initWithState:st];
    STAssertNotNil(ab, @"got nil back");
    STAssertTrue([ab currentState] == st, @"did not get expected state back");
    STAssertEquals([ab countMoves], (unsigned)0, nil);
    STAssertEqualsWithAccuracy([ab fitness], (float)0.0, 0.0001, @"got %f", [ab fitness]);

    [ab setMaxPly:1];   // states below assumes a ply 2 search
    STAssertNil([ab lastMove], nil);

    STAssertNoThrow([ab aiMove], nil); // why is this failing?
    STAssertEquals([ab countMoves], (unsigned)1, nil);
    STAssertEquals([ab countStates], (unsigned)2, nil);
    STAssertEqualsWithAccuracy([ab fitness], (float)-3.0, 0.0001, @"got %f", [ab fitness]);
    
    STAssertNoThrow([ab aiMove], nil); // why is this failing?
    STAssertEquals([ab countMoves], (unsigned)2, nil);
    STAssertEquals([ab countStates], (unsigned)3, nil);
    STAssertEqualsWithAccuracy([ab fitness], (float)-1.0, 0.0001, @"got %f", [ab fitness]);
}

@end
