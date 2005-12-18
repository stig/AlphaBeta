//
//  AlphaBeta.h
//  AlphaBeta
//
//  Created by Stig Brautaset on 11/12/2005.
//  Copyright 2005 Stig Brautaset. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlphaBeta : NSObject {
    id state;
    NSMutableArray *moves;
}
- (id)initWithState:(id)st;
- (id)currentState;
@end
