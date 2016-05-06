//
//  ViewController.m
//  TourRobot
//
//  Created by 郭龙 on 16/1/18.
//  Copyright © 2016年 郭龙. All rights reserved.
//

#import "DijkstraAlgorithmViewController.h"

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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    nodesArray = [NSMutableArray new];
    
    //A node
    Node *aNode = [Node initWithId:@"A"];
    [nodesArray addObject:aNode];
    [aNode addEdgeWithEndId:@"B" weight:10];
    [aNode addEdgeWithEndId:@"C" weight:20];
    [aNode addEdgeWithEndId:@"E" weight:30];
    
    Node *bNode = [Node initWithId:@"B"];
    [nodesArray addObject:bNode];
    [bNode addEdgeWithEndId:@"C" weight:5];
    [bNode addEdgeWithEndId:@"E" weight:10];
    
    Node *cNode = [Node initWithId:@"C"];
    [nodesArray addObject:cNode];
    [cNode addEdgeWithEndId:@"D" weight:30];
    
    Node *dNode = [Node initWithId:@"D"];
    [nodesArray addObject:dNode];
    
    Node *eNode = [Node initWithId:@"E"];
    [nodesArray addObject:eNode];
    [eNode addEdgeWithEndId:@"D" weight:20];
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
