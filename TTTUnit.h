//
//  TTTUnit.h
//  AlphaBeta
//
//  Created by Stig Brautaset on 11/12/2005.
//  Copyright 2005 Stig Brautaset. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "TTTState.h"
#import "AlphaBeta.h"

@interface TTTUnit : SenTestCase {
    TTTState *st;
    AlphaBeta *ab;
    NSMutableArray *moves;
}

@end
