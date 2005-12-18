//
//  TTTState.m
//  AlphaBeta
//
//  Created by Stig Brautaset on 11/12/2005.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "TTTState.h"

@implementation TTTState

- (id)init
{
    if (self = [super init]) {
        int i, j;
        for (i = 0; i < 3; i++) {
            for (j = 0; j < 3; j++) {
                board[i][j] = 0;
            }
        }
        player = 1;
    }
    return self;
}

- (float)fitnessValue
{
    return 0.0;
}

@end
