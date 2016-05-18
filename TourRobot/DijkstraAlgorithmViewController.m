//
//  ViewController.m
//  TourRobot
//
//  Created by 郭龙 on 16/1/18.
//  Copyright © 2016年 郭龙. All rights reserved.
//

#import "DijkstraAlgorithmViewController.h"

const int MAXINT = 32767;
const int MAXNUM = 5; //10;
int dist[MAXNUM];
int prev[MAXNUM];
int A[MAXNUM][MAXNUM];

@interface Edge : NSObject
@property (nonatomic) NSString *startNodeId;
@property (nonatomic) NSString *endId;
@property (nonatomic) float     weight;
+ (instancetype)initWithPara:(NSString *)startNodeId endId:(NSString *)endId weight:(float)weight ;
@end
@implementation Edge
- (instancetype)init {
    self = [super init];
    if (self) {
        return self;
    }
    return nil;
}
+ (instancetype)initWithPara:(NSString *)startNodeId endId:(NSString *)endId weight:(float)weight {
    Edge *edge = [self init];
    edge.startNodeId = startNodeId;
    edge.endId = endId;
    edge.weight = weight;
    return edge;
}
@end

@interface Node : NSObject
@property (nonatomic) NSString *idString;
@property (nonatomic) NSMutableArray *edgesArray;
+ (instancetype)initWithId :(NSString *)idString ;
- (void)addEdgeWithEndId:(NSString *)endId weight:(float)weight;
@end
@implementation Node
- (instancetype)init {
    if (self = [super init]) {
        self.idString = @"";
        self.edgesArray = [NSMutableArray new];
        return self;
    }
    return nil;
}
+ (instancetype)initWithId :(NSString *)idString{
    Node *node =[self init];
    node.idString = idString;
    return node;
}
- (void)addEdgeWithEndId:(NSString *)endId weight:(float)weight {
    Edge *edge = [Edge initWithPara:self.idString endId:endId weight:weight];
    [self.edgesArray addObject:edge];
}
@end

@interface PlanCourse : NSObject
@end
@implementation PlanCourse
- (instancetype)init {
    self = [super init];
    if (self) {
        return self;
    }
    return nil;
}

+ (void) planCourese:(NSMutableArray *)nodesArray originId:(NSString *)originId {
    Node *originNode = nil;
    for (Node *node in nodesArray) {
        if ([node.idString isEqualToString:originId]) {
            originNode = node;
        }else {
            
        }
    }
}

@end


@interface DijkstraAlgorithmViewController (){
    NSMutableArray *nodesArray ;
}
@end

@implementation DijkstraAlgorithmViewController

- (void)initDijkstra {
    for (int i = 0; i < MAXNUM; i++) {
        for (int j = 0; j < MAXNUM ; j++) {
            if (i == j) {
                A[i][j] = 0;
            }
            if (i < j) {
                A[i][j] = MAXINT;
            }
        }
    }
    
    A[0][1] = 2;
    A[0][3] = 1;
    A[1][2] = 2;
    A[2][3] = 5;//0->2
//    A[2][4] = 3;
    A[3][4] = 2;
    
    for (int i = 0; i < MAXNUM; i++) {
        for (int j = 0; j < MAXNUM ; j++) {
            if (i < j) {
                A[j][i] = A[i][j];
            }
        }
    }
    
    for (int i = 0; i < MAXNUM; i++) {
        dist[i] = MAXNUM;
    }
}

- (void) DijkstraShortedstPath :(int) stratId { //startId to everypoint
    BOOL S[MAXNUM] ;
    for (int i = 0; i < MAXNUM; i++) { //init startid
        dist[i] = A[stratId][i];
        S[i] = false;
        if (dist[i] == MAXINT) {
            prev[i] = -1;
        }else
            prev[i] = stratId;
    }
    dist[stratId] = 0;
    S[stratId] = true;
    
    for (int i = 1; i < MAXNUM; i ++) { //
        int u = stratId;
        int mindist = MAXINT;
        for (int j = 0; j < MAXNUM; j++) {
            if (i==j) {
                continue;
            }
            if (!S[j] && dist[j] < mindist) {
                u = j;   //u保存当前邻接点钟距离最小的点的号码
                mindist = dist[j];
            }
        }
        
        S[u] = true;
        
        for (int j = 0; j < MAXNUM; j++) {
            if (u == j) {
                continue;
            }
            if (!S[j] && A[u][i] != MAXINT) {
                int t1 = dist[j];
                int t2 = dist[u] + A[u][j];
                if (t1 > t2) {
                    dist[j] = dist[u] + A[u][j];
                    prev[j] = u;
                }
            }
        }
    }
    
}


- (void)searchPath:(int *)pre startId:(int)startId to:(int)T {
    
    NSLog(@"tmp %d ->",T);
    int tmp = prev[T];
    while (tmp != startId) {
        NSLog(@" %d ->",tmp);
        tmp = pre[tmp];
    }

    NSLog(@"tmp:%d--least path: %d",tmp, dist[T]);
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initDijkstra];
    [self DijkstraShortedstPath:0];
    
    NSLog(@"distance:");
    NSString *t = @"";
    for (int v = 0; v < MAXNUM; v++) {
        NSString *tmp = [NSString stringWithFormat:@" %d",dist[v]];
        t = [t stringByAppendingString:tmp];
    }
    NSLog(@"%@",t);

    NSLog(@"origin");
    for (int v = 0; v < MAXNUM; v++) {
        NSString *t = @"";
        for (int w = 0; w < MAXNUM; w++) {
            NSString *tmp = [NSString stringWithFormat:@" %d",A[v][w]];
            t = [t stringByAppendingString:tmp];
        }
        NSLog(@"%@",t);
    }
   
    [self searchPath:prev startId:0 to:4];
    
    
    
//    nodesArray = [NSMutableArray new];
//    
//    //A node
//    Node *aNode = [Node initWithId:@"A"];
//    [nodesArray addObject:aNode];
//    [aNode addEdgeWithEndId:@"B" weight:10];
//    [aNode addEdgeWithEndId:@"C" weight:20];
//    [aNode addEdgeWithEndId:@"E" weight:30];
//    
//    Node *bNode = [Node initWithId:@"B"];
//    [nodesArray addObject:bNode];
//    [bNode addEdgeWithEndId:@"C" weight:5];
//    [bNode addEdgeWithEndId:@"E" weight:10];
//    
//    Node *cNode = [Node initWithId:@"C"];
//    [nodesArray addObject:cNode];
//    [cNode addEdgeWithEndId:@"D" weight:30];
//    
//    Node *dNode = [Node initWithId:@"D"];
//    [nodesArray addObject:dNode];
//    
//    Node *eNode = [Node initWithId:@"E"];
//    [nodesArray addObject:eNode];
//    [eNode addEdgeWithEndId:@"D" weight:20];
    
}


//- (Node *)getMinWeithRoadNode :(NSMutableArray *)nodesArray origin:(NSString *)originId {
//    float weidht = 100000;
//    Node *destNode = nil;
//    for (Node *node in nodesArray) {
//        if ([node.idString isEqualToString:originId]) {
//            continue;
//        }
//        
//    }
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
