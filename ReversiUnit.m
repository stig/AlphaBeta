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
