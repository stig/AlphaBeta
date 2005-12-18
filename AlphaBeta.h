//
//  AlphaBeta.h
//  AlphaBeta
//
//  Created by Stig Brautaset on 11/12/2005.
//  Copyright 2005 Stig Brautaset. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTTState.h"

@interface AlphaBeta : NSObject {
    TTTState *state;
    int maxPly;
    NSMutableArray *moves;
}
- (id)initWithState:(id)st;
- (void)setState:(id)st;
- (id)currentState;
- (void)aiMove;
- (int)countMoves;
- (float)abWithAlpha:(float)alpha beta:(float)beta plyLeft:(int)ply;
@end
