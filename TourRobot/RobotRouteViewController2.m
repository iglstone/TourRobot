//
//  RobotRouteViewController.m
//  TourRobot
//
//  Created by 郭龙 on 16/5/5.
//  Copyright © 2016年 郭龙. All rights reserved.
//  copy form:http://blog.chinaunix.net/uid-26548237-id-3834873.html

#import "RobotRouteViewController2.h"
#import "RouteHeader.h"
#import "FloydAlgorithm.h"
#import "RouteView.h"

@interface RobotRouteViewController2 ()
{
    mGraph m_graph;
    NSMutableArray *m_realPosotionsArray;
    
    vexAngels vexsAngel;
    vexsPre2DTabel vexsPre2D;
    distancesSum2DTabel distanceSum2D;
}
@end

@implementation RobotRouteViewController2

#pragma mark - life cicle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initPara];
    
    [FloydAlgorithm initSingelPointIdAndAngel:&vexsAngel withIdAndAngels:@[@0,@30,@60,@90,@100,@160,@150,@30,@30]];
    [FloydAlgorithm floydShortestPath:&m_graph pointsTabel:&vexsPre2D shortTable:&distanceSum2D];
    [FloydAlgorithm findShortestPath:&m_graph from:0 to:5 pointsTabel:&vexsPre2D robotAngels:&vexsAngel];
    [FloydAlgorithm findShortestPath:&m_graph from:5 to:0 pointsTabel:&vexsPre2D robotAngels:&vexsAngel];
    
    [self logSomeThing];
    
    //数据驱动绘图
    RouteView *routeView = [[RouteView alloc] initWithFrame:CGRectMake(0, 0, 500, 500)];
    [self.view addSubview:routeView];
    routeView.m_pointPositionsArray = m_realPosotionsArray;
    [routeView drawLineAndPoints:&m_graph withTailAngel:&vexsAngel];
}

- (void) initPara {
    NSArray *pointsArr = @[@[@0,@0], @[@1,@0], @[@2,@0], @[@3,@0], @[@4,@1], @[@3,@2], @[@2,@2], @[@1,@2], @[@0,@2]];
    for (int i = 0; i < pointsArr.count; i++) {
        int x = (int)[pointsArr[i][0] integerValue];
        int y = (int)[pointsArr[i][1] integerValue];
        CGPoint pt = CGPointMake(x, y);
        [m_realPosotionsArray insertObject:[NSValue valueWithCGPoint:pt] atIndex:i];
    }
    
    NSArray *angels = @[@100, @11, @100, @99, @110, @199, @11, @11, @11];
    for (int v = 0; v < POINTSNUM; v++) {
        float angel = [[angels objectAtIndex:v] floatValue];
        vexsAngel[v] = angel;
    }
    
    //draw-datasource
    m_realPosotionsArray = [[NSMutableArray alloc] initWithCapacity:m_graph.numVertexes];//顶点个数
    for (int v = 0; v < m_graph.numVertexes; v++) {
        [m_realPosotionsArray insertObject:[NSValue valueWithCGPoint:CGPointMake(0, 0)] atIndex:v];
    }
    
    [self creatMGragh];//初始信息需要手动输入
}

#pragma mark - logic
/**
 *  当机器人在朝着一个方向走的时候，反方向给堵住，，设置为intmax即可
 *  @param start 相邻两点的起始点
 *  @param end   相邻两点的终点
 *  @param gragh 待修改的图
 */
- (void )onTheWayOfStart:(int)start end:(int)end {//gragh:(mGraph *)gragh {
//    int weight = gragh -> weightAndAngels[start][end].weight;
    int weight = m_graph.weightAndAngels[start][end].weight;
    if (weight == INTMAX) {
        NSLog(@"start and end point not in passed by");
        return;
    }
    m_graph.weightAndAngels[end][start].weight = INTMAX;//反方向给堵住
//    gragh.weightAndAngels[end][start].weight = INTMAX;//反方向给堵住
}

#pragma mark - initNodeFonc
- (void)creatMGragh {
    mGraph *graph = &m_graph;
    int i,j;
    graph->numEdges = 16;
    graph->numVertexes = POINTSNUM; // point num
    for (i = 0; i < graph->numVertexes; i++) {// init vexs
        graph->vexs[i] = i;
    }
    for (i = 0; i< graph->numVertexes; i++) { // init arcs
        for (j = 0; j< graph->numVertexes; j++) {
            if (i == j) {
                graph -> weightAndAngels[i][j].weight = 0;
                graph -> weightAndAngels[i][j].angel = 0;
            }else {
                graph -> weightAndAngels[i][j].weight = graph ->weightAndAngels[j][i].weight = INTMAX;
            }
        }
    }
    
    //初始化一半，start < end
    [self initGrghNodeStart:0 end:@[@1,@8]];
    [self initGrghNodeStart:1 end:@[@2]];
    [self initGrghNodeStart:2 end:@[@3,@6]];
    [self initGrghNodeStart:3 end:@[@4,@5]];
    [self initGrghNodeStart:4 end:@[@5]];
    [self initGrghNodeStart:5 end:@[@6]];
    [self initGrghNodeStart:6 end:@[@7]];
    [self initGrghNodeStart:7 end:@[@8]];
    
    //初始化另外一半
    for (i = 0; i < graph->numVertexes; i++) {
        for (j = 0; j < graph ->numVertexes; j++) {
            graph->weightAndAngels[j][i].weight = graph->weightAndAngels[i][j].weight; //important***,connot inverse
            int banckAngel = graph->weightAndAngels[i][j].angel + 180;
            graph->weightAndAngels[j][i].angel = banckAngel + 180 >=360 ? banckAngel - 360 : banckAngel;//返程是逆向
        }
    }
}

/**
 *  辅助初始化mGragh函数, 只初始化一半, 自己计算距离和角度
 *  @param g      gragh
 *  @param start,要求 start < end
 *  @param end
 *  @param weight
 *  @param angles
 */
- (void)initGrghNodeStart:(int)start end:(NSArray*)ends {
    mGraph *g = &m_graph;
    for (int i = 0; i<ends.count; i++) {
        NSInteger end = [[ends objectAtIndex:i] integerValue];
        if (start >= end) {
            NSLog(@"start num >= ending num");
            continue;
        }
        
        CGPoint st = [[m_realPosotionsArray objectAtIndex:start] CGPointValue];
        CGPoint ed = [[m_realPosotionsArray objectAtIndex:end] CGPointValue];
        float disX = ed.x - st.x;
        float disY = ed.y - st.y;
        float weight = sqrtf(disX*disX + disY*disY);
        float angelf = atan2f(disY, disX);//  atan2f(disY/disX);
        int angel = (int) (angelf / M_PI *180);
        //        if (angel < 0) {
        //            angel = angel +180;
        //        }
        g->weightAndAngels[start][end].weight = weight;
        g->weightAndAngels[start][end].angel = angel;
    }
}

/**
 *  辅助初始化mGragh函数, 只初始化一半, 带绝对角度，不是相对角度的，自计算距离
 *  @param g      gragh
 *  @param start,要求 start < end
 *  @param end
 *  @param angles
 */
- (void)initGrghNodeStart:(int)start end:(NSArray*)ends angel:(NSArray *)angels {
    mGraph *g = &m_graph;
    for (int i = 0; i<ends.count; i++) {
        NSInteger end = [[ends objectAtIndex:i] integerValue];
        if (start >= end) {
            NSLog(@"start num >= ending num");
            continue;
        }
        
        CGPoint st = [[m_realPosotionsArray objectAtIndex:start] CGPointValue];
        CGPoint ed = [[m_realPosotionsArray objectAtIndex:end] CGPointValue];
        float disX = ed.x - st.x;float disY = ed.y - st.y;
        float weight = sqrtf(disX*disX + disY*disY);
        float angel = [[angels objectAtIndex:i] floatValue];
        g->weightAndAngels[start][end].weight = weight;
        g->weightAndAngels[start][end].angel = angel;
    }
}

/**
 *  辅助初始化mGragh函数, 只初始化一半, 带绝对距离和角度，非计算距离与计算角度
 *  @param g      gragh
 *  @param start,要求 start < end
 *  @param end
 *  @param weight
 *  @param angles
 */
- (void)initGrghStart:(int)start end:(NSArray*)ends weight:(NSArray *)weight angle:(NSArray *)angles {
    mGraph *graph = &m_graph;
    if ([ends count] != [weight count]) {
        return;
    }
    for (int i = 0; i<ends.count; i++) {
        NSInteger end = [[ends objectAtIndex:i] integerValue];
        if (start >= end) {
            NSLog(@"start num >= ending num");
            continue;
        }
        float angel = [[angles objectAtIndex:i] floatValue];
        float weights = [[weight objectAtIndex:i] floatValue];
        graph->weightAndAngels[start][end].weight = weights;
        graph->weightAndAngels[start][end].angel = angel;
    }
}

#pragma mark - privateMethod 
- (void)logSomeThing {
    //    NSLog(@"各顶点间最短路径如下：");
    //    [self printShortestPath:&graph pointsTabel:&vexsPre2D shortestTabel:&distanceSum2D];
    
    NSLog(@"最短路劲P：position");
    int v,w;
    for (v = 0; v < m_graph.numVertexes; v++) {
        NSString *t = @"";
        for (w = 0; w < m_graph.numVertexes; w++) {
            NSString *tmp = [NSString stringWithFormat:@" %d",vexsPre2D[v][w]];
            t = [t stringByAppendingString:tmp];
        }
        NSLog(@"%@",t);
    }
    
    NSLog(@"最短路劲distanceSum2D:distance：");
    for (v = 0; v < m_graph.numVertexes; v++) {
        NSString *t = @"";
        for (w = 0; w < m_graph.numVertexes; w++) {
            NSString *tmp = [NSString stringWithFormat:@"  %d",distanceSum2D[v][w]];
            t = [t stringByAppendingString:tmp];
        }
        NSLog(@"%@",t);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
