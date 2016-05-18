//
//  RobotRouteViewController.m
//  TourRobot
//
//  Created by 郭龙 on 16/5/5.
//  Copyright © 2016年 郭龙. All rights reserved.
//  copy form:http://blog.chinaunix.net/uid-26548237-id-3834873.html

#import "RobotRouteViewController.h"
#import <math.h>

#define MAXVEX  20
#define MAXEDGE 20
#define POINTSNUM 9
#define INTMAX 65535
#define POINTRADUS 7

typedef struct{
    int pointNum;//到达指定地点的id号
    float angel;//指定点的Angel
} pointIdAndAngel;//指定点的id&角度

typedef struct{
    float weight;//连线长度
    float angel;//连线在空间的角度
} lineWeightAndAngel;//连接线的长度角度

typedef struct {
    int vexs[MAXVEX];
    lineWeightAndAngel weightAndAngels[MAXVEX][MAXVEX];//连线长度和连线角度
    int numVertexes, numEdges;
}mGraph;

typedef int pointsTabel[MAXVEX][MAXVEX];//路径下标列表
typedef int distancesSum2DTabel[MAXVEX][MAXVEX];//两点间最短路径“和“值列表
typedef pointIdAndAngel ponitIdAngelsArr[POINTSNUM];//路径下标列表以及对应下标下的角度

@interface RobotRouteViewController ()
{
    mGraph m_graph;
    NSMutableArray *m_pointPositionsArray;
    
    CAShapeLayer *m_lineShapLayer;
    UIBezierPath *m_bezierPath;
    ponitIdAngelsArr vexsAngel;
    NSMutableArray *m_realPosotionsArray;
}
@end
@implementation RobotRouteViewController

#pragma mark - life cicle
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
    m_lineShapLayer = [CAShapeLayer new];
    m_lineShapLayer.strokeColor = [UIColor redColor].CGColor;
//    m_lineShapLayer.fillColor = [UIColor blueColor].CGColor;
    m_bezierPath = [UIBezierPath new];
    [self.view.layer addSublayer:m_lineShapLayer];
    
    
    m_realPosotionsArray = [[NSMutableArray alloc] initWithCapacity:POINTSNUM];
    for (int i = 0; i < 4 ; i++) {
        CGPoint pt = CGPointMake(i, 0);
        [m_realPosotionsArray insertObject:[NSValue valueWithCGPoint:pt] atIndex:i];
        
    }
    [m_realPosotionsArray insertObject:[NSValue valueWithCGPoint:CGPointMake(4, 1)] atIndex:4];
    for (int i = 0; i < 4 ; i++) {
        CGPoint pt2 = CGPointMake(3-i, 2);
        [m_realPosotionsArray insertObject:[NSValue valueWithCGPoint:pt2] atIndex:i+5];
    }
    
    
    
    int v,w;
    //    mGraph graph;
    pointsTabel points;
    distancesSum2DTabel distances;
    
    [self creatMGragh:&m_graph];
    [self initSingelPointIdAndAngel:vexsAngel angels:@[@0,@30,@60,@90,@100,@160,@150,@30,@30]];
    [self floydShortestPath:m_graph pointsTabel:&points shortTable:&distances robotRoute:&vexsAngel];
    
    //test
    [self printShortestPath:&m_graph from:0 to:5 pointsTabel:&points shortestTabel:&distances robotRoute:&vexsAngel];
    [self printShortestPath:&m_graph from:5 to:0 pointsTabel:&points shortestTabel:&distances robotRoute:&vexsAngel];
    
    //    NSLog(@"各顶点间最短路径如下：");
    //    [self printShortestPath:&graph pointsTabel:&points shortestTabel:&distances];
    
    m_pointPositionsArray = [[NSMutableArray alloc] initWithCapacity:m_graph.numVertexes];//顶点个数
    for (v = 0; v < m_graph.numVertexes; v++) {
        [m_pointPositionsArray insertObject:[NSValue valueWithCGPoint:CGPointMake(0, 0)] atIndex:v];
    }
    
    
    NSLog(@"最短路劲P：position");
    for (v = 0; v < m_graph.numVertexes; v++) {
        NSString *t = @"";
        for (w = 0; w < m_graph.numVertexes; w++) {
            NSString *tmp = [NSString stringWithFormat:@" %d",points[v][w]];
            t = [t stringByAppendingString:tmp];
        }
        NSLog(@"%@",t);
    }
    
    NSLog(@"最短路劲distances:distance：");
    for (v = 0; v < m_graph.numVertexes; v++) {
        NSString *t = @"";
        for (w = 0; w < m_graph.numVertexes; w++) {
            NSString *tmp = [NSString stringWithFormat:@"  %d",distances[v][w]];
            t = [t stringByAppendingString:tmp];
        }
        NSLog(@"%@",t);
    }
    
    //数据驱动绘图
    [self drawViewByGraph:&m_graph pointIdAngel:vexsAngel];
}

#pragma mark - draw views
- (void)drawViewByGraph :(mGraph *)graph pointIdAngel:(pointIdAndAngel *)pointIdAndAngel {
    int i,j;
    CGPoint positionZero = CGPointMake(50, 50);

    [m_pointPositionsArray replaceObjectAtIndex:0 withObject:[NSValue valueWithCGPoint:positionZero]];
    
    for (i = 0; i < graph->numVertexes; i++) {
        for (j = i+1; j < graph->numVertexes; j++) {
            int weight = m_graph.weightAndAngels[i][j].weight;
            if (weight != INTMAX && weight != 0) {
                weight = weight * 100;//测试用
                //确定J的点坐标
                float angel = m_graph.weightAndAngels[i][j].angel;
                angel = (angel/360)*M_PI*2;
                
                CGPoint positionI = [[m_pointPositionsArray objectAtIndex:i] CGPointValue];
//                if (positionI.x == 0 && positionI.y == 0) {
//                    continue;
//                }
                CGPoint positionJ = CGPointMake(positionI.x + weight*cosf(angel), positionI.y + weight*sinf(angel)); // 这里可以考虑平均值一下
                NSValue *oldJ ;
                if (j >= m_pointPositionsArray.count) {
                    
                }else
                    oldJ = [m_pointPositionsArray objectAtIndex:j];
                
                if (((CGPoint )[oldJ CGPointValue]).x != 0 && ((CGPoint )[oldJ CGPointValue]).y != 0) {
                    CGPoint oldJPosition = [oldJ CGPointValue];
                    CGPoint newJPosition = CGPointMake(positionJ.x/2 + oldJPosition.x/2, positionJ.y/2 + oldJPosition.y/2);
                    [m_pointPositionsArray replaceObjectAtIndex:j withObject:[NSValue valueWithCGPoint:newJPosition]];
                }else{
//                    [m_pointPositionsArray insertObject:[NSValue valueWithCGPoint:positionJ] atIndex:j];//如果没有怎么办
                    [m_pointPositionsArray replaceObjectAtIndex:j withObject:[NSValue valueWithCGPoint:positionJ]];
                }
            }
        }
    }
    [self drawLineAndPoints];
}

- (void)drawLineAndPoints{
    int i,j;
    for (i = 0; i < m_graph.numVertexes; i++) {
        for (j = i+1; j < m_graph.numVertexes; j++) {
            int weight = m_graph.weightAndAngels[i][j].weight;
            float angel = m_graph.weightAndAngels[i][j].angel;
            if (weight != INTMAX && weight != 0) {
                CGPoint ptI = [[m_pointPositionsArray objectAtIndex:i] CGPointValue];
                CGPoint ptJ = [[m_pointPositionsArray objectAtIndex:j] CGPointValue];
                UIBezierPath *path = [UIBezierPath new];
                [path moveToPoint:ptI];
                [path addLineToPoint:ptJ];
                [m_bezierPath appendPath:path];
                
                UILabel *numL = [[UILabel alloc] initWithFrame:CGRectMake(ptI.x/2+ptJ.x/2, ptI.y/2 + ptJ.y/2, 30, 10)];
                numL.font = [UIFont systemFontOfSize:10];
                numL.text = [NSString stringWithFormat:@"%d,%.0f",weight,angel];
                [self.view addSubview:numL];
                numL.backgroundColor = [UIColor blueColor];
            }
        }
    }
    
    for (int i = 0; i  < m_pointPositionsArray.count; i++ ) {
        CGPoint position = [[m_pointPositionsArray objectAtIndex:i] CGPointValue];
        UIBezierPath *pointPath = [UIBezierPath bezierPathWithArcCenter:position radius:POINTRADUS startAngle:0 endAngle:2*M_PI clockwise:0];
        [m_bezierPath appendPath:pointPath];
        
        UILabel *numL = [[UILabel alloc] initWithFrame:CGRectMake(position.x+POINTRADUS/2, position.y+POINTRADUS/2, 13, 10)];
        numL.font = [UIFont systemFontOfSize:10];
        numL.text = [NSString stringWithFormat:@"%d",i];
        [self.view addSubview:numL];
        numL.backgroundColor = [UIColor orangeColor];
        
        float angel = (vexsAngel[i].angel / 180) * M_PI;
        UIBezierPath *path = [UIBezierPath new];
        path.lineWidth = 3.0;
        [path moveToPoint:position];
        [path addLineToPoint:CGPointMake(position.x + 20*cosf(angel), position.y + 20*sinf(angel))];
        [m_bezierPath appendPath:path];
    }
    
    m_lineShapLayer.path = m_bezierPath.CGPath;
}

#pragma mark - init graph and algrithem
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
                graph -> weightAndAngels[i][j].weight = graph ->weightAndAngels[j][i].weight = INTMAX;
            }
        }
    }

    //初始化一半，start < end
//    [self initGrgh:graph Start:0 end:@[@1,@2]      weight:@[@1,@5]         angle:@[@10,@90]];
//    [self initGrgh:graph Start:1 end:@[@2,@3,@4]   weight:@[@3,@7,@5]      angle:@[@100,@90,@80]];
//    [self initGrgh:graph Start:2 end:@[@4,@5]      weight:@[@1,@7]         angle:@[@100,@90]];
//    [self initGrgh:graph Start:3 end:@[@4,@6]      weight:@[@2,@3]         angle:@[@100,@90]];
//    [self initGrgh:graph Start:4 end:@[@5,@6,@7]   weight:@[@3,@6,@9]      angle:@[@100,@90,@80]];
//    [self initGrgh:graph Start:5 end:@[@7]         weight:@[@5]            angle:@[@100]];
//    [self initGrgh:graph Start:6 end:@[@7,@8]      weight:@[@2,@7]         angle:@[@100,@90]];
//    [self initGrgh:graph Start:7 end:@[@8]         weight:@[@4]            angle:@[@100]];
    
//    [self initGrgh:graph Start:0 end:@[@1,@2]       weight:@[@2,@1]         angle:@[@10,@90]];
//    [self initGrgh:graph Start:1 end:@[@3,@4]       weight:@[@1,@2]         angle:@[@90,@10]];
//    [self initGrgh:graph Start:2 end:@[@3]          weight:@[@1]            angle:@[@10]];
//    [self initGrgh:graph Start:4 end:@[@5, @6]      weight:@[@3,@2]         angle:@[@60,@20]];
//    [self initGrgh:graph Start:5 end:@[@6]          weight:@[@2]            angle:@[@-30]];
//    [self initGrgh:graph Start:6 end:@[@7]          weight:@[@2]            angle:@[@10]];
//    [self initGrgh:graph Start:7 end:@[@8]          weight:@[@1]            angle:@[@10]];
    
    [self initGrgh:graph Start:0 end:@[@1,@8]];
    [self initGrgh:graph Start:1 end:@[@2]];
    [self initGrgh:graph Start:2 end:@[@3,@6]];
    [self initGrgh:graph Start:3 end:@[@4,@5]];
    [self initGrgh:graph Start:4 end:@[@5]];
    [self initGrgh:graph Start:5 end:@[@6]];
    [self initGrgh:graph Start:6 end:@[@7]];
    [self initGrgh:graph Start:7 end:@[@8]];
    
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
- (void)initGrgh:(mGraph *)g Start:(int)start end:(NSArray*)ends {
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
 *  当机器人在朝着一个方向走的时候，反方向给堵住，，设置为intmax即可
 *  @param start 相邻两点的起始点
 *  @param end   相邻两点的终点
 *  @param gragh 待修改的图
 */
- (void )onTheWayOfStart:(int)start end:(int)end gragh:(mGraph *)gragh {
    int weight = gragh->weightAndAngels[start][end].weight;
    if (weight == INTMAX) {
        NSLog(@"start and end point not in passed by");
        return;
    }
    gragh->weightAndAngels[end][start].weight = INTMAX;//反方向给堵住
}

/**
 *  初始化最终到某一终点的角度信息
 *  @param vexsAngel 一维数组
 *  @param angels      角度信息
 */
- (void )initSingelPointIdAndAngel:(pointIdAndAngel *)idsAndAngels angels:(NSArray *)angels{
    int v;
    if (angels.count != POINTSNUM) {
        NSLog(@"points num is not equal to angels num");
        return;
    }
    for (v = 0; v < POINTSNUM; v++) {
        float angel = [[angels objectAtIndex:v] floatValue];
        idsAndAngels[v].angel = angel;
        idsAndAngels[v].pointNum = v;//从0开始
    }
}

//Floyd algorithm : 计算图graph中各定点v到其余定点w的最短路径points[v][w]及带权长度distances[v][w]
- (void) floydShortestPath:(mGraph )graph pointsTabel:(pointsTabel *)points shortTable:(distancesSum2DTabel *)distances robotRoute:(ponitIdAngelsArr *)vexsAngel{
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
- (void)printShortestPath:(mGraph *)graph pointsTabel:(pointsTabel *)points shortestTabel:(distancesSum2DTabel *)distances{
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
 *  @param vexsAngel 终点角度信息
 */
- (void)printShortestPath:(mGraph *)graph from:(int)m to:(int)n pointsTabel:(pointsTabel *)points shortestTabel:(distancesSum2DTabel *)distances robotRoute:(ponitIdAngelsArr *)idsAndAngels{
    int k =  (*points)[m][n];//robot.pointNum;
    int angelm2k = graph->weightAndAngels[m][k].angel;
    NSString *tem = [NSString stringWithFormat:@"path: %d,%d -> %d,", m, angelm2k, k];
    while (k != n) {
        int tmpk = k;
        k = (*points)[k][n];// robot.pointNum; //get next vertex point
        int angelTemk2k = graph->weightAndAngels[tmpk][k].angel;
        tem = [tem stringByAppendingString:[NSString stringWithFormat:@"%d -> %d,",angelTemk2k, k]];
    }
    tem = [tem stringByAppendingString:[NSString stringWithFormat:@"%f",(*idsAndAngels)[n].angel]];
    NSLog(@"%@",tem);
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
