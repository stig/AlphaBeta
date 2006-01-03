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
    STAssertEqualObjects([[ab aiMove] string], @"122222 212222 222111 222110 201200 212000", nil);
    STAssertEqualObjects([[ab aiMove] string], @"122222 212222 222111 222110 202200 212200", nil);
    STAssertEqualObjects([[ab aiMove] string], @"122222 212222 212111 211110 212200 212200", nil);
    STAssertEqualObjects([[ab aiMove] string], @"122222 212222 212122 222222 212200 212200", nil);
    STAssertEqualObjects([[ab aiMove] string], @"122222 212222 211122 222122 211110 212200", nil);
    STAssertEqualObjects([[ab aiMove] string], @"122222 212222 211122 222122 211220 212220", nil);
    STAssertEqualObjects([[ab aiMove] string], @"122222 212222 211122 222112 211111 212220", nil);
    STAssertEqualObjects([[ab aiMove] string], @"122222 212222 211122 222112 211112 212222", nil);    
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
