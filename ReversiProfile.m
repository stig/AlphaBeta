#include <Cocoa/Cocoa.h>
#include <AlphaBeta/AlphaBeta.h>
#include <SBReversi/SBReversiState.h>

int main(int argc, char **argv)
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];

    if (argc < 3) {
        fprintf(stderr, "Usage: %s cnt ply [mutable]\n", argv[0]);
        return EXIT_FAILURE;
    }
    int cnt = atoi(argv[1]);
    int ply = atoi(argv[2]);
    int mutable = argc > 3 && atoi(argv[3]);
    Class class = mutable ? [SBMutableReversiState class]: [SBReversiState class];
        
    SBAlphaBeta *ab = [SBAlphaBeta newWithState:[class new]];
    for (int i = 0; i < cnt; i++) {
        NSDate *date = [NSDate date];
        [ab moveFromSearchWithPly:ply];
        printf("%lf\n", (double)-[date timeIntervalSinceNow]);
        date = [NSDate date];
    }
    
    [pool release];
    return 0;
}
