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
}

- (void)testState
{
    id st = [[TTTState alloc] init];
    
    STAssertTrue([st fitnessValue] == 0.0, @"initial state is neutral");
    
}

@end
