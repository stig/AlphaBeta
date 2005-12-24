//
//  AlphaBetaUnit.m
//  AlphaBeta
//
//  Created by Stig Brautaset on 17/12/2005.
//  Copyright 2005 Stig Brautaset. All rights reserved.
//

#import "AlphaBetaUnit.h"

@implementation AlphaBetaUnit

- (void)setUp
{
    st = [[TTTState alloc] init];
    STAssertTrue([st player] == 1, nil);
    STAssertTrue([[st string] isEqualToString:@"000000000"], @"is the initial state");

    ab = [[AlphaBeta alloc] initWithState:st];
    STAssertNotNil(ab, @"got nil back");
    STAssertTrue([ab currentState] == st, @"did not get expected state back");
    STAssertEquals([ab countMoves], (unsigned)0, nil);
}

- (void)tearDown
{
    [st release];
    [ab release];
}

- (void)testInitAndSetState
{
    [ab release];
    ab = [[AlphaBeta alloc] init];
    STAssertNotNil(ab, @"got nil back");
    STAssertNil([ab currentState], @"did not get expected state back");
    [ab setState:st];
    STAssertTrue([ab currentState] == st, @"did not get expected state back");
    STAssertThrows([ab setState:nil], @"can set state when already set");
    STAssertThrows([ab setState:st], @"can set state when already set");
    STAssertEquals([ab countMoves], (unsigned)0, nil);
}

- (void)testMaxPly
{
    STAssertEquals([ab maxPly], (unsigned)3, nil);
    STAssertThrows([ab setMaxPly:-3], @"allowed negative ply");
    [ab setMaxPly:5];
    STAssertEquals([ab maxPly], (unsigned)5, nil);
}

- (void)testFindMoves
{
    [ab setMaxPly:2];   // states below assumes a ply 2 search
    STAssertNil([ab lastMove], nil);

    STAssertNotNil([ab aiMove], nil);
    NSString *s = [[ab currentState] string];
    STAssertTrue([s isEqualToString:@"000010000"], @"got: %@", s);
    STAssertEquals([ab countMoves], (unsigned)1, nil);
    STAssertEqualsWithAccuracy([[ab currentState] fitness], (float)-4.0, 0.1, nil);
    s = [[ab lastMove] string];
    STAssertTrue([s isEqualToString:@"11"], @"got: %@", s);

    [ab aiMove];
    s = [[ab currentState] string];
    STAssertTrue([s isEqualToString:@"200010000"], @"got: %@", s);
    STAssertEquals([ab countMoves], (unsigned)2, nil);
    STAssertEqualsWithAccuracy([[ab currentState] fitness], (float)1.0, 0.1, nil);
    s = [[ab lastMove] string];
    STAssertTrue([s isEqualToString:@"00"], @"got: %@", s);
}

@end
