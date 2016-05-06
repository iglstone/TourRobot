//
//  FloydAlgorithmViewController.m
//  TourRobot
//
//  Created by 郭龙 on 16/5/4.
//  Copyright © 2016年 郭龙. All rights reserved.
//

#import "FloydAlgorithmViewController.h"
#define MAXVEX  20
#define MAXEDGE 20

typedef struct {
    int vexs[MAXVEX];
    int arc[MAXVEX][MAXVEX];
    int numVertexes, numEdges;
}mGraph;

//typedef int status;
typedef int pathArc[MAXVEX][MAXVEX];//路径下标列表
typedef int shortPathTable[MAXVEX][MAXVEX];//两点间最短路径“和“值列表

@interface FloydAlgorithmViewController ()
@end
@implementation FloydAlgorithmViewController

- (void)creatMGragh:(mGraph *) G {
    int i,j;
    G->numEdges = 16;
    G->numVertexes = 9; // point num
    for (i = 0; i < G->numVertexes; i++) {// init vexs
        G->vexs[i] = i;
    }
    for (i = 0; i< G->numVertexes; i++) { // init arcs
        for (j = 0; j< G->numVertexes; j++) {
            if (i == j) {
                G -> arc[i][j] = 0;
            }else {
                G -> arc[i][j] = G ->arc[j][i] = 65535;
            }
        }
    }
    G -> arc[0][1] = 1;
    G -> arc[0][2] = 5;
    
    G -> arc[1][2] = 3;
    G -> arc[1][3] = 7;
    G -> arc[1][4] = 5;
    
    G -> arc[2][4] = 1;
    G -> arc[2][5] = 7;
    
    G -> arc[3][4] = 2;
    G -> arc[3][6] = 3;
    
    G -> arc[4][5] = 3;
    G -> arc[4][6] = 6;
    G -> arc[4][7] = 9;
    
    G -> arc[5][7] = 5;
    
    G -> arc[6][7] = 2;
    G -> arc[6][8] = 7;
    
    G -> arc[7][8] = 4;
    
    for (i = 0; i < G->numVertexes; i++) {
        for (j = 0; j < G ->numVertexes; j++) {
            G->arc[j][i] = G->arc[i][j]; //important***,connot inverse
        }
    }
}

//Floyd algorithm : 计算图G中各定点v到其余定点w的最短路径P[v][w]及带权长度T[v][w]
- (void) floydShortestPath:(mGraph )G pathArc:(pathArc *)P shortTable:(shortPathTable *)T {
    int v,w,k;
    for (v = 0; v < G.numVertexes; v++) {// init P T
        for (w = 0; w < G.numVertexes; w++) {
            (*T)[v][w] = G.arc[v][w];//T[v][w]为对应的权值
            (*P)[v][w] = w;//初始化P
        }
    }
    for (k = 0; k < G.numVertexes; k++) {
        for (v = 0; v < G.numVertexes; v++) {
            for (w = 0; w < G.numVertexes; w++) {
                if ((*T)[v][w] > (*T)[v][k] + (*T)[k][w]) {
                    (*T)[v][w] = (*T)[v][k] + (*T)[k][w];
                    (*P)[v][w] = (*P)[v][k];//路径设置为净多下标为k的顶点
                }
            }
        }
    }
}

- (void)printShortestPath:(mGraph *)G pathArc:(pathArc *)P shortestTabel:(shortPathTable *)T{
    int v,w,k;
//    for (v  = 0; v < G->numVertexes; v++) {
    for (v  = 0; v < 1; v++) { //测试从0到任意一点
        for (w = v+1; w < G->numVertexes; w++) {
            NSLog(@"v%d - w%d: weight :%d",v,w,(*T)[v][w]);
            k = (*P)[v][w];       //get the first point
            NSLog(@"path: %d",v); // log sorce point
            while (k != w) {
                NSLog(@"-> %d",k);// log vertex
                k = (*P)[k][w];   //get next vertex point
            }
            NSLog(@"-> %d",w);    // log final point
        }
    }
}

- (void)printShortestPath:(mGraph *)G from:(int)m to:(int)n pathArc:(pathArc *)P shortestTabel:(shortPathTable *)T{
    int k;
    k = (*P)[m][n];//first point
    NSString *tem = [NSString stringWithFormat:@"path: %d -> %d", m, k];
    while (k != n) {
        k = (*P)[k][n]; //get next vertex point
        tem = [tem stringByAppendingString:[NSString stringWithFormat:@" -> %d",k]];
    }
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
    mGraph G;
    pathArc P;
    shortPathTable T;
    [self creatMGragh:&G];
    [self floydShortestPath:G pathArc:&P shortTable:&T];
    
    [self printShortestPath:&G from:6 to:1 pathArc:&P shortestTabel:&T];
    
//    NSLog(@"各顶点间最短路径如下：");
//    [self printShortestPath:&G pathArc:&P shortestTabel:&T];
    
    NSLog(@"最短路劲P：");
    for (v = 0; v < G.numVertexes; v++) {
        NSString *t = @"";
        for (w = 0; w < G.numVertexes; w++) {
            NSString *tmp = [NSString stringWithFormat:@" %d",P[v][w]];
            t = [t stringByAppendingString:tmp];
        }
        NSLog(@"%@",t);
    }
    
    NSLog(@"最短路劲T：");
    for (v = 0; v < G.numVertexes; v++) {
        NSString *t = @"";
        for (w = 0; w < G.numVertexes; w++) {
            NSString *tmp = [NSString stringWithFormat:@"  %d",T[v][w]];
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
