//
//  AlphaBetaUnit.h
//  AlphaBeta
//
//  Created by Stig Brautaset on 17/12/2005.
//  Copyright 2005 Stig Brautaset. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "TTTState.h"
#import "AlphaBeta.h"

@interface AlphaBetaUnit : SenTestCase {
    TTTState *st;
    AlphaBeta *ab;
}

@end
