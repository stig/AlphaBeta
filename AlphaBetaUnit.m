//
//  AlphaBetaUnit.m
//  AlphaBeta
//
//  Created by Stig Brautaset on 17/12/2005.
//  Copyright 2005 Stig Brautaset. All rights reserved.
//

#import "TTTState.h"
#import "AlphaBeta.h"
#import "AlphaBetaUnit.h"

@implementation AlphaBetaUnit

- (void)setUp
{
    st = [[TTTState alloc] init];
    STAssertTrue([st playerTurn] == 1, nil);
    STAssertTrue([[st string] isEqualToString:@"000000000"], @"is the initial state");
}

- (void)tearDown
{
    [st release];
}

- (void)testInitAndSetState
{
    id ab = [[AlphaBeta alloc] init];
    STAssertNotNil(ab, @"got nil back");
    STAssertNil([ab currentState], @"did not get expected state back");
    [ab setState:st];
    STAssertTrue([ab currentState] == st, @"did not get expected state back");
    STAssertThrows([ab setState:nil], @"can set state when already set");
    STAssertThrows([ab setState:st], @"can set state when already set");
    STAssertEquals([ab countMoves], (int)0, nil);
}

- (void)testFindMoves
{
    id ab = [[AlphaBeta alloc] initWithState:st];
    STAssertNotNil(ab, @"got nil back");
    STAssertTrue([ab currentState] == st, @"did not get expected state back");
    STAssertEquals([ab countMoves], (int)0, nil);

    
    [ab aiMove];
    NSString *s = [[ab currentState] string]; 
    STAssertTrue([s isEqualToString:@"000010000"], @"got: %@", s);
    STAssertEquals([ab countMoves], (int)1, nil);
    STAssertEqualsWithAccuracy([[ab currentState] fitnessValue], (float)-4.0, 0.1, nil);
    
    [ab aiMove];
    s = [[ab currentState] string]; 
    STAssertTrue([s isEqualToString:@"200010000"], @"got: %@", s);
    STAssertEquals([ab countMoves], (int)2, nil);
    STAssertEqualsWithAccuracy([[ab currentState] fitnessValue], (float)1.0, 0.1, nil);
}

@end
