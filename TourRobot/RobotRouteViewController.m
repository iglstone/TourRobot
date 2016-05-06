//
//  RobotRouteViewController.m
//  TourRobot
//
//  Created by 郭龙 on 16/5/5.
//  Copyright © 2016年 郭龙. All rights reserved.
//  copy form:http://blog.chinaunix.net/uid-26548237-id-3834873.html

#import "RobotRouteViewController.h"

#define MAXVEX  20
#define MAXEDGE 20
#define POINTSNUM 9

typedef struct{
    int pointNum;//到达指定地点的id号
    float angel;//指定点的Angel
} pointIdAndAngel;//指定点的id&角度

typedef struct{
    int weight;//连线长度
    float angel;//连线在空间的角度
} lineWeightAndAngel;//连接线的长度角度

typedef struct {
    int vexs[MAXVEX];
    lineWeightAndAngel weightAndAngels[MAXVEX][MAXVEX];//连线长度和连线角度
    int numVertexes, numEdges;
}mGraph;

typedef int pointsTabel[MAXVEX][MAXVEX];//路径下标列表
typedef int distanceTabel[MAXVEX][MAXVEX];//两点间最短路径“和“值列表
typedef pointIdAndAngel ponitIdAngel[POINTSNUM];//路径下标列表以及对应下标下的角度

@interface RobotRouteViewController ()
@end
@implementation RobotRouteViewController

- (void)creatMGragh:(mGraph *) graph {
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
                graph -> weightAndAngels[i][j].weight = graph ->weightAndAngels[j][i].weight = 65535;
            }
        }
    }

    //初始化一半，start < end
    [self initGrgh:graph Start:0 end:@[@1,@2]      weight:@[@1,@5]         angle:@[@100,@90]];
    [self initGrgh:graph Start:1 end:@[@2,@3,@4]   weight:@[@3,@7,@5]      angle:@[@100,@90,@80]];
    [self initGrgh:graph Start:2 end:@[@4,@5]      weight:@[@1,@7]         angle:@[@100,@90]];
    [self initGrgh:graph Start:3 end:@[@4,@6]      weight:@[@2,@3]         angle:@[@100,@90]];
    [self initGrgh:graph Start:4 end:@[@5,@6,@7]   weight:@[@3,@6,@9]      angle:@[@100,@90,@80]];
    [self initGrgh:graph Start:5 end:@[@7]         weight:@[@5]            angle:@[@100]];
    [self initGrgh:graph Start:6 end:@[@7,@8]      weight:@[@2,@7]         angle:@[@100,@90]];
    [self initGrgh:graph Start:7 end:@[@8]         weight:@[@4]            angle:@[@100]];
    
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
 *  辅助初始化mGragh函数, 只初始化一半
 *  @param g      gragh
 *  @param start,要求 start < end
 *  @param end
 *  @param weight
 *  @param angles
 */
- (void)initGrgh:(mGraph *)g Start:(int)start end:(NSArray*)ends weight:(NSArray *)weight angle:(NSArray *)angles {
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
        g->weightAndAngels[start][end].weight = weights;
        g->weightAndAngels[start][end].angel = angel;
    }
}

/**
 *  初始化最终到某一终点的角度信息
 *  @param idAndAngels 一维数组
 *  @param angels      角度信息
 */
- (void )initSingelPointIdAndAngel:(pointIdAndAngel *)idAndAngels angels:(NSArray *)angels{
    int v;
    if (angels.count != POINTSNUM) {
        NSLog(@"points num is not equal to angels num");
        return;
    }
    for (v = 0; v < POINTSNUM; v++) {
        float angel = [[angels objectAtIndex:v] floatValue];
        idAndAngels[v].angel = angel;
        idAndAngels[v].pointNum = v;//从0开始
    }
}

//Floyd algorithm : 计算图graph中各定点v到其余定点w的最短路径points[v][w]及带权长度distances[v][w]
- (void) floydShortestPath:(mGraph )graph pointsTabel:(pointsTabel *)points shortTable:(distanceTabel *)distances robotRoute:(ponitIdAngel *)idAndAngels{
    int v,w,k;
    for (v = 0; v < graph.numVertexes; v++) {// init points distances
        for (w = 0; w < graph.numVertexes; w++) {
            (*distances)[v][w] = graph.weightAndAngels[v][w].weight;//distances[v][w]为对应的权值
            (*points)[v][w] = w;//初始化points
        }
    }
    for (k = 0; k < graph.numVertexes; k++) {
        for (v = 0; v < graph.numVertexes; v++) {
            for (w = 0; w < graph.numVertexes; w++) {
                if ((*distances)[v][w] > (*distances)[v][k] + (*distances)[k][w]) {
                    (*distances)[v][w] = (*distances)[v][k] + (*distances)[k][w];
                    (*points)[v][w] = (*points)[v][k];//路径设置为净多下标为k的顶点
                }
            }
        }
    }
}

/**
 *  输出图中任意两点的前驱点信息和距离和信息
 *  @param graph     图
 *  @param points    点前驱二维数组
 *  @param distances 距离和二维数组
 */
- (void)printShortestPath:(mGraph *)graph pointsTabel:(pointsTabel *)points shortestTabel:(distanceTabel *)distances{
    int v,w,k;
    //    for (v  = 0; v < graph->numVertexes; v++) {
    for (v  = 0; v < 1; v++) { //测试从0到任意一点
        for (w = v+1; w < graph->numVertexes; w++) {
            NSLog(@"v%d - w%d: weight :%d",v,w,(*distances)[v][w]);
            k = (*points)[v][w];       //get the first point
            NSLog(@"path: %d",v); // log sorce point
            while (k != w) {
                NSLog(@"-> %d",k);// log vertex
                k = (*points)[k][w];   //get next vertex point
            }
            NSLog(@"-> %d",w);    // log final point
        }
    }
}

/**
 *  输出任意两点最短路径，以及路径上的角度以及终点信息
 *  @param graph       图
 *  @param m           start
 *  @param n           end
 *  @param points      pointsTable, 前驱信息
 *  @param distances   distanceTable,距离信息
 *  @param idAndAngels 终点角度信息
 */
- (void)printShortestPath:(mGraph *)graph from:(int)m to:(int)n pointsTabel:(pointsTabel *)points shortestTabel:(distanceTabel *)distances robotRoute:(ponitIdAngel *)idAndAngels{
    int k =  (*points)[m][n];//robot.pointNum;
    int angelm2k = graph->weightAndAngels[m][k].angel;
    NSString *tem = [NSString stringWithFormat:@"path: %d,%d -> %d,", m, angelm2k, k];
    while (k != n) {
        int tmpk = k;
        k = (*points)[k][n];// robot.pointNum; //get next vertex point
        int angelTemk2k = graph->weightAndAngels[tmpk][k].angel;
        tem = [tem stringByAppendingString:[NSString stringWithFormat:@"%d -> %d,",angelTemk2k, k]];
    }
    tem = [tem stringByAppendingString:[NSString stringWithFormat:@"%f",(*idAndAngels)[n].angel]];
    NSLog(@"%@",tem);
}

- (instancetype)init {
    self = [super init];
    if (self) {
        return self;
    }
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    int v,w;
    mGraph graph;
    pointsTabel points;
    distanceTabel distances;
    ponitIdAngel idAndAngels;
    [self creatMGragh:&graph];
    [self initSingelPointIdAndAngel:idAndAngels angels:@[@90,@90,@80,@70,@180,@60,@50,@30,@30]];
    [self floydShortestPath:graph pointsTabel:&points shortTable:&distances robotRoute:&idAndAngels];
    
    [self printShortestPath:&graph from:7 to:4 pointsTabel:&points shortestTabel:&distances robotRoute:&idAndAngels];
    
    //    NSLog(@"各顶点间最短路径如下：");
    //    [self printShortestPath:&graph pointsTabel:&points shortestTabel:&distances];
    
    NSLog(@"最短路劲P：position");
    for (v = 0; v < graph.numVertexes; v++) {
        NSString *t = @"";
        for (w = 0; w < graph.numVertexes; w++) {
            NSString *tmp = [NSString stringWithFormat:@" %d",points[v][w]];
            t = [t stringByAppendingString:tmp];
        }
        NSLog(@"%@",t);
    }
    
    NSLog(@"最短路劲distances:distance：");
    for (v = 0; v < graph.numVertexes; v++) {
        NSString *t = @"";
        for (w = 0; w < graph.numVertexes; w++) {
            NSString *tmp = [NSString stringWithFormat:@"  %d",distances[v][w]];
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
