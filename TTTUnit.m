//
//  TTTUnit.m
//  AlphaBeta
//
//  Created by Stig Brautaset on 11/12/2005.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "TTTUnit.h"
#import "TTTState.h"

@implementation TTTUnit

- (void)testMove
{
    id move = [[TTTMove alloc] initWithX:2 andY:1];
    STAssertTrue([move x] == 2, nil);
    STAssertTrue([move y] == 1, nil);
    STAssertTrue([[move string] isEqualToString:@"21"], nil);
}

- (void)testState
{
    id st = [[TTTState alloc] init];
    NSMutableArray *moves;
    
    STAssertTrue([st playerTurn] == 1, nil);
    STAssertTrue([[st string] isEqualToString:@"000000000"], @"is the initial state");
    STAssertTrue([st fitnessValue] == 0.0, @"initial state is neutral");
    
    STAssertNotNil(moves = [st listAvailableMoves], nil);
    STAssertTrue([moves count] == 9, @"got expected number of moves back");
    
    id m = [moves lastObject];
    [st applyMove:m];
    STAssertTrue([st playerTurn] == 2, nil);
    STAssertTrue([[st string] isEqualToString:@"000000001"], nil);

    [moves release];
    STAssertNotNil(moves = [st listAvailableMoves], nil);
    STAssertTrue([moves count] == 8, @"got expected number of moves back");

    m = [moves lastObject];
    [st applyMove:m];
    STAssertTrue([[st string] isEqualToString:@"000000021"], nil);
    
}


@end
