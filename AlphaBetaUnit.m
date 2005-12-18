//
//  AlphaBetaUnit.m
//  AlphaBeta
//
//  Created by Stig Brautaset on 17/12/2005.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "TTTState.h"
#import "AlphaBeta.h"
#import "AlphaBetaUnit.h"

@implementation AlphaBetaUnit

- (void)testInitWithState
{
    id st = [[TTTState alloc] init];
    STAssertTrue([st playerTurn] == 1, nil);
    STAssertTrue([[st string] isEqualToString:@"000000000"], @"is the initial state");
    
    id ab = [[AlphaBeta alloc] initWithState:st];
    STAssertNotNil(ab, @"got nil back");
    STAssertTrue([ab currentState] == st, @"did not get expected move back");
}

@end
