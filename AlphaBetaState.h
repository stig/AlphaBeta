//
//  AlphaBetaState.h
//  AlphaBeta
//
//  Created by Stig Brautaset on 11/12/2005.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSObject (AlphaBetaState)

- (float)fitnessValue;
- (NSMutableArray *)listAvailableMoves;
- (void)applyMove:(id)m;

@end