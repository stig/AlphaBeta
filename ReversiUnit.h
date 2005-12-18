//
//  ReversiUnit.h
//  AlphaBeta
//
//  Created by Stig Brautaset on 18/12/2005.
//  Copyright 2005 Stig Brautaset. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "ReversiState.h"

@interface ReversiUnit : SenTestCase {
    ReversiState *st;
    NSMutableArray *moves;
}

@end
