//
//  CalcuViewController.h
//  Calculator
//
//  Created by 古玉彬 on 15/10/13.
//  Copyright © 2015年 guyubin. All rights reserved.
//

#import "CalcuViewController.h"
#define MAX_WIDTH  self.view.frame.size.width
#define MAX_HEIGHT self.view.frame.size.height
#define BUTTON_WIDTH MAX_WIDTH / 4
#define BORDER_WIDTH 0.5
#define BUTTON_HEIGHT ( MAX_HEIGHT - 6 * MAX_HEIGHT / 21 ) / 5

@interface CalcuViewController (){
    
    UILabel *_mainScreen; //计算器主界面
    NSArray *_numberArray; //number名字数组
    NSMutableArray *_numberStack; // 操作数栈
    NSInteger _numberIndex; //当前number下标
    NSMutableDictionary *_tagDic; //tag
    UIButton *_operation; //操作符
    NSString *_spoltNumbers; //用户点击小数之后
    float _tempNumber; //屏幕连续输入数字
    BOOL _isNumberChanged; //是否有数字输入
    BOOL _isError; //出错

    
}

@end

@implementation CalcuViewController

static void * ob = (void *)&ob;
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNumberArrayData]; //设置number数组
    [self setLayout];//布局
    [self initOPerator]; //初始化操作数和操作符
    
}


- (void)setLayout{
    

    _mainScreen = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,MAX_WIDTH,  3 * MAX_HEIGHT / 7)];
    [_mainScreen setFont:[UIFont systemFontOfSize:39]];
    [_mainScreen setTextColor:[UIColor whiteColor]];
    [_mainScreen setText:@"0"];
    [_mainScreen setTextAlignment:NSTextAlignmentRight];
    [_mainScreen setAdjustsFontSizeToFitWidth:YES];
    [self.view addSubview:_mainScreen];
    
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_mainScreen.frame) * (2.0/3), MAX_WIDTH, MAX_HEIGHT - CGRectGetMaxY(_mainScreen.frame))];
    bgView.image = [UIImage imageNamed:@"fu_pic.jpg"];
    [self.view insertSubview:bgView belowSubview:_mainScreen];//放到mainScreen底下
    //设置按钮
    _numberIndex = 0;
    for (int i = 0; i < 5; i++) {
        for (int j = 0 ; j < 4; j++) {
            NSString *title = _numberArray[_numberIndex++];
            UIButton *btn = [self customBtn];
            if ([title isEqualToString:@"0"]) {
                btn.frame = CGRectMake(j * BUTTON_WIDTH , BUTTON_HEIGHT * i + 2 * CGRectGetMaxY(_mainScreen.frame) / 3 , BUTTON_WIDTH * 2, BUTTON_HEIGHT);
                [btn setTitleEdgeInsets:UIEdgeInsetsMake(BUTTON_HEIGHT / 2, BUTTON_WIDTH / 5, BUTTON_HEIGHT / 2, BUTTON_HEIGHT)];
                _numberIndex++;
                j++;
            }
            else{
                btn.frame = CGRectMake(j * BUTTON_WIDTH , BUTTON_HEIGHT * i + 2 * CGRectGetMaxY(_mainScreen.frame)/3 , BUTTON_WIDTH, BUTTON_HEIGHT);
            }
            if (j == 3) {
                [btn setBackgroundColor:[UIColor colorWithRed:242 / 255.0 green:127 / 255.0 blue:39 / 255.0 alpha:1]];
            }
            [btn setTitle:title forState:UIControlStateNormal];
            [btn setTag:[_tagDic[title] intValue]];
            [btn setTitle:title forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            [btn addTarget:self action:@selector(btnTouched:) forControlEvents:UIControlEventTouchDown];
            [self.view addSubview:btn];
        }
    }
    
}

//得到自定义btn
- (UIButton *)customBtn{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.titleLabel.font = [UIFont systemFontOfSize:25];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor whiteColor]];
    [btn setAlpha:0.6];
    [btn.layer setMasksToBounds:YES];
    [btn.layer setBorderWidth:BORDER_WIDTH];
    return btn;
}

//设置字母按键名
- (void)setNumberArrayData{
    _numberArray = @[@"AC",@"±",@"%",@"÷",@"7",@"8",@"9",@"×",@"4",@"5",@"6",@"−",@"1",@"2",@"3",@"+",@"0",@"0",@".",@"="];
    if (!_tagDic) {
        _tagDic = [[NSMutableDictionary alloc] init];
    }
    
    [_numberArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj isEqualToString:@"÷"]) {
            [_tagDic setObject:[NSNumber numberWithInt:107] forKey:obj];
        }
        else if([obj isEqualToString:@"±"]){
            
            [_tagDic setObject:[NSNumber numberWithInt:102] forKey:obj];
        }
        else if([obj isEqualToString:@"×"]){
            
            [_tagDic setObject:[NSNumber numberWithInt:106] forKey:obj];
        }
        else if([obj isEqualToString:@"−"]){
            
            [_tagDic setObject:[NSNumber numberWithInt:105] forKey:obj];
        }
        else{
            char ch = [obj characterAtIndex:0];
            switch (ch) {
                case '0' ... '9':
                    [_tagDic setObject:[NSNumber numberWithInt:[obj intValue]] forKey:obj];
                    break;
                case 'A':
                    [_tagDic setObject:[NSNumber numberWithInt:100] forKey:obj];
                    break;
                case '%':
                    [_tagDic setObject:[NSNumber numberWithInt:103] forKey:obj];
                    break;
                case '+':
                    [_tagDic setObject:[NSNumber numberWithInt:104] forKey:obj];
                    break;
                case '.':
                    [_tagDic setObject:[NSNumber numberWithInt:109] forKey:obj];
                    break;
                case '=':
                    [_tagDic setObject:[NSNumber numberWithInt:108] forKey:obj];
                default:
                    break;
            }
        }
        
    }];
}
//初始化操作数和操作符
- (void)initOPerator{
    
    _numberStack = [[NSMutableArray alloc] init];
    if (_operation) {
        [_operation.layer setBorderWidth:BORDER_WIDTH];
        _operation = nil;
    }
    _tempNumber = 0;
    _isNumberChanged = NO;
    _spoltNumbers = @"";
}

//鼠标点击事件
- (void)btnClick:(UIButton *)btn{
    
    
    if (btn.tag >= 104 && btn.tag <= 108) { //操作符
        
        [self updateBtnColor:btn]; //更新背景色
        
    }else{
        [btn setBackgroundColor:[UIColor whiteColor]]; //数字和AC += %
    }
    
    [self claLogic:btn]; //逻辑计算操作
    
}

//更新btn背景颜色
- (void)updateBtnColor:(UIButton *)btn{
    
    [btn setBackgroundColor:[UIColor colorWithRed:242 / 255.0 green:127 / 255.0 blue:39 / 255.0 alpha:1]];
    [btn.layer setBorderWidth:1.5];
    if(btn.tag == 108){ //如果是等于号 直接恢复边框
        [btn.layer setBorderWidth:BORDER_WIDTH];
    }
    
    if (_operation) {
        if (btn.tag != _operation.tag) {
            [_operation.layer setBorderWidth:BORDER_WIDTH];
            
            if (_operation.tag != 108) { //不是等号
                _operation = btn;
                _operation = nil;
            }
        }
        
    }{
        _operation = btn; // 当前操作数
    }
    
}

//更新结果
- (void)updateResult:(float)resuult{
    
    if (_isError) {
        [_mainScreen setText:@"不是数字"];
        _isError = NO;
        
    }else{
        [_mainScreen setText:[NSString stringWithFormat:@"%g",resuult]];
    }
    
}

//鼠标点住颜色变化
- (void)btnTouched:(UIButton *)btn{
    [btn setBackgroundColor:[UIColor grayColor]];
}

//逻辑操作计算
- (void)claLogic:(UIButton *)btn{
    if (btn.tag >= 0 && btn.tag <= 9) { //数字
        
        //判断正负号是否被点击。如果被点击了，则清空tempNumber
        UIButton *btns = (UIButton *)[self.view viewWithTag:102];
        if (btns.selected) {
            _tempNumber = 0;
            btns.selected = NO;
        }
        
        [(UIButton *)[self.view viewWithTag:100] setTitle:@"C" forState:UIControlStateNormal]; //更新AC名字

        [self operateStackNumber:btn isNumber:1]; //操作栈.
        
        
    }else if(btn.tag >= 104 && btn.tag <= 107){ //加减乘除操作数
        
        [self operateStackNumber:btn isNumber:0]; //操作栈
        
    }else if (btn.tag == 108){ //=号
        id obj;
               //判断最后一个操作数
        if (_isNumberChanged) { //数字改变
            obj = [_numberStack firstObject];
            if ([obj isKindOfClass:[NSNumber class]]) {
                [_numberStack replaceObjectAtIndex:0 withObject:[NSNumber numberWithFloat:_tempNumber]]; //替换掉数字
            }else{ //是操作符或者空
                [_numberStack insertObject:[NSNumber numberWithFloat:_tempNumber] atIndex:0];
            }
            _tempNumber = 0;
            _isNumberChanged = NO;
        }
        obj = [_numberStack firstObject];
        if (obj) {
            if ([obj isKindOfClass:[NSNumber class]]) {
                [self updateResult:[self calcuStackResult]]; //更新界面
            }else{ //操作符。默认把另一个操作数，复制过来
                [_numberStack insertObject:_numberStack[1] atIndex:0]; //入栈
                [self updateResult:[self calcuStackResult]]; //更新界面
            }
            
        }else{//栈为空。输出0
            [self updateResult:0];
        }
        //[_mainScreen setText:[NSString stringWithFormat:@"%d",[self operateStackNumber:]]];
        
    }else if (btn.tag == 100){ //AC
        [self initOPerator]; //清空数据
        [self updateResult:[[_numberStack firstObject] intValue]]; //更新界面
        [(UIButton *)[self.view viewWithTag:100] setTitle:@"AC" forState:UIControlStateNormal]; //更新AC名字
    }
    
    else if(btn.tag == 102){ //正负号
        
        btn.selected = YES; //开启选择标志
        
        if (_tempNumber) { //不为0
            _tempNumber *= -1;
            [self updateResult:_tempNumber]; //更新UI
        }else{ //判断栈中的数。如果为数字则更新。如果为操作数。则更新上个操作数
            id obj = [_numberStack firstObject];
            if (obj) { //有数
                int index;
                if([obj isKindOfClass:[UIButton class]]){ //是button
                    index = 1;
                }else{
                    index = 0;
                }
                float currentNumber = -1 * [_numberStack[index] floatValue];
                [_numberStack replaceObjectAtIndex:index withObject:[NSNumber numberWithFloat:currentNumber]]; //操作数*-1
                [self updateResult:currentNumber];
            }
        }
    }
    else if (btn.tag == 103){ //%
        id obj = [_numberStack firstObject];
        if ([obj isKindOfClass:[UIButton class]]) { //操作符。需要先计算栈中的内容
            [_numberStack insertObject:_numberStack[1] atIndex:0]; //拿出来后一个结果，放到栈顶
            [self calcuStackResult]; //计算结果
            float result =  [self calcuResultOp1:[[_numberStack firstObject] floatValue] op2:100 op:107];
            [_numberStack replaceObjectAtIndex:0 withObject:[NSNumber numberWithFloat:result]];
            [self updateResult:result]; // 计算,输出结果

        }else{
            _tempNumber = [self calcuResultOp1:_tempNumber op2:100 op:107]; //除法操作
            [self updateResult:_tempNumber];
        }
        
    }
    else if (btn.tag == 109){ //小数
        
        if (!btn.selected) { //连续点击失效
            
            btn.selected = YES;
            _spoltNumbers = [NSString stringWithFormat:@"%g.",_tempNumber];
            [_mainScreen setText:_spoltNumbers]; //更新UI
        }
    }
        
    
}

//操作栈
- (void)operateStackNumber:(UIButton *)btn isNumber:(BOOL)isNNumber{
    id obj = [_numberStack firstObject];
    if (isNNumber) { //操作数
        _isNumberChanged = YES;
        _tempNumber  = _tempNumber * 10 + btn.tag;
        [self updateResult:_tempNumber];//更新界面
    }
    else{ //操作符
        if (_isNumberChanged) { //数字改变
            if ([obj isKindOfClass:[NSNumber class]]) {
                [_numberStack replaceObjectAtIndex:0 withObject:[NSNumber numberWithFloat:_tempNumber]]; //替换掉数字
            }else{ //是操作符或者空
                [_numberStack insertObject:[NSNumber numberWithFloat:_tempNumber] atIndex:0];
            }
            _tempNumber = 0;
            _isNumberChanged = NO;
        }
        obj = [_numberStack firstObject];
        if (obj) {
            if ([obj isKindOfClass:[UIButton class]]) { //说明是操作符
                _tempNumber = 0;//清空数字
                [_numberStack removeObjectAtIndex:0]; //出栈
                [_numberStack insertObject:btn atIndex:0]; //替换掉刚才的操作数
            }
            else{ //说明为操作数
                //如果数组中已经存在3个变量。
                if (_numberStack.count >= 3) {
                    //计算。出栈。然后入栈
                    //出栈
                    float result = [self calcuResultOp1:[_numberStack[2] floatValue] op2:[_numberStack[0] floatValue] op:[_numberStack[1] tag]];
                    [self updateResult:result];//更新界面
                    [_numberStack removeObjectsInRange:NSMakeRange(0, 3)];//删除
                    //结果入栈
                    [_numberStack insertObject:[NSNumber numberWithFloat:result] atIndex:0];
                    //操作符入栈
                    //[_numberStack insertObject:btn atIndex:0];
                }
                //如果不构成操作
                //加入栈
                [_numberStack insertObject:btn atIndex:0]; //入栈
            }
        }else{
            [_numberStack insertObject:[NSNumber numberWithFloat:0] atIndex:0]; //没有操作数。默认放0
            [_numberStack insertObject:btn atIndex:0]; //入栈
        }
    }
}


//计算栈结果
- (float)calcuStackResult{
    float result;
    if (_numberStack.count >= 3) { //3个数合并
         result = [self calcuResultOp1:[_numberStack[2] floatValue] op2:[_numberStack[0] floatValue] op:[_numberStack[1] tag]];
        [_numberStack removeObjectsInRange:NSMakeRange(0, 3)];//出栈
        [_numberStack insertObject:[NSNumber numberWithFloat:result] atIndex:0]; //结果入栈
    }else{
        result = [[_numberStack firstObject] floatValue]; //只有一个数
    }
    return  result;
}

//计算结果
//op1 操作数1
//op2 操作数2
//op 操作符
- (float)calcuResultOp1:(float)op1 op2:(float)op2 op:(NSInteger)op{
    float result; //保存结果
    //有操作数
    if (op >= 100) {
        switch (op) {
            case 104: //+
                result = op1 + op2;
                break;
            case 105://-
                result = op1 - op2;
                break;
            case 106: //*
                result = op1 * op2;
                break;
            case 107: //  /
                if (op2 == 0) {
                    _isError = YES;// 出错
                    return 0;
                }
                result = op1 / op2;
                break;
            default:
                break;
        }
    }
    return result;
}




@end
