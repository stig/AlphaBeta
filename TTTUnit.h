//
//  TTTUnit.h
//  AlphaBeta
//
//  Created by Stig Brautaset on 11/12/2005.
//  Copyright 2005 Stig Brautaset. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "TTTState.h"

@interface TTTUnit : SenTestCase {
    TTTState *st;
    NSMutableArray *moves;
}

@end
