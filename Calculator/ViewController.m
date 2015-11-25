//
//  ViewController.m
//  Calculator
//
//  Created by 古玉彬 on 15/10/13.
//  Copyright © 2015年 guyubin. All rights reserved.
//

#import "ViewController.h"
#define MAX_WIDTH  self.view.frame.size.width
#define MAX_HEIGHT self.view.frame.size.height
#define BUTTON_WIDTH MAX_WIDTH / 4
#define BORDER_WIDTH 0.5
#define BUTTON_HEIGHT ( MAX_HEIGHT - 6 * MAX_HEIGHT / 21 ) / 5

@interface ViewController (){
    UILabel *_mainScreen; //计算器主界面
    NSArray *_numbersArray; //number名字数组
    NSInteger _numberIndex; //当前number下标
    NSMutableDictionary *_tagDic; //tag
    NSInteger _lastOPerationNumber; //上一个操作数
    NSInteger _currentOPerationNumber; //当前操作数
    NSInteger _stackOPerationNumber;//中间变量
    UIButton *_currentOperatorBtn; //当前操作符
    UIButton *_lastCurrentOperatorBtn; // 上一个操作符
    
}

@end

@implementation ViewController

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
    [_mainScreen setText:@""];
    [_mainScreen setTextAlignment:NSTextAlignmentRight];
    [_mainScreen setAdjustsFontSizeToFitWidth:YES];
    [self.view addSubview:_mainScreen];
    
    //设置按钮
    _numberIndex = 0;
    for (int i = 0; i < 5; i++) {
        for (int j = 0 ; j < 4; j++) {
            NSString *title = _numbersArray[_numberIndex++];
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
//            [btn setTitle:[NSString stringWithFormat:@"%@",_tagDic[title]] forState:UIControlStateNormal];
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
    [btn.layer setMasksToBounds:YES];
    [btn.layer setBorderWidth:BORDER_WIDTH];
    return btn;
}

//设置字母按键名
- (void)setNumberArrayData{
    _numbersArray = @[@"AC",@"±",@"%",@"÷",@"7",@"8",@"9",@"×",@"4",@"5",@"6",@"−",@"1",@"2",@"3",@"+",@"0",@"0",@".",@"="];
    if (!_tagDic) {
        _tagDic = [[NSMutableDictionary alloc] init];
    }
    
    [_numbersArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        if ([obj isEqualToString:@"÷"]) {
            [_tagDic setObject:[NSNumber numberWithInt:108] forKey:obj];
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
                    [_tagDic setObject:[NSNumber numberWithInt:107] forKey:obj];
                default:
                    break;
            }
        }
        
    }];
}
//初始化操作数和操作符
- (void)initOPerator{
    _lastOPerationNumber = 0;
    _currentOPerationNumber = 0;
    _stackOPerationNumber = 0;
    if (_currentOperatorBtn) {
        [_currentOperatorBtn.layer setBorderWidth:BORDER_WIDTH];
        _currentOperatorBtn = nil;
    }
    if(_lastOPerationNumber){
        _currentOperatorBtn = nil;
    }
    
}

//鼠标点击事件
- (void)btnClick:(UIButton *)btn{
    
    
    if (btn.tag >= 104 && btn.tag <= 108) { //操作符
        
    [self updateBtnColor:btn]; //更新背景色
    
        
    if (_currentOperatorBtn) {
        _currentOperatorBtn = nil;
    }
    
    _currentOperatorBtn = btn;
        
    }else{
        [btn setBackgroundColor:[UIColor whiteColor]]; //数字和AC += %
    }
    
    [self calulatorLogic:btn.tag]; //计算
    
}

//更新btn背景颜色
- (void)updateBtnColor:(UIButton *)btn{

        if (_currentOperatorBtn) { //如果有上个当前操作数
            [_currentOperatorBtn.layer setBorderWidth:BORDER_WIDTH];
        }
        [btn setBackgroundColor:[UIColor colorWithRed:242 / 255.0 green:127 / 255.0 blue:39 / 255.0 alpha:1]];
        [btn.layer setBorderWidth:1.5];
        if(btn.tag == 107){ //如果是等于号 直接恢复边框
            [btn.layer setBorderWidth:BORDER_WIDTH];
        }
}

//更新结果
- (void)updateResult:(NSInteger)resuult{
    [_mainScreen setText:[NSString stringWithFormat:@"%ld",(long)resuult]];
}

//鼠标点住颜色变化
- (void)btnTouched:(UIButton *)btn{
    [btn setBackgroundColor:[UIColor grayColor]];
}

//计算逻辑操作
- (void)calulatorLogic:(NSInteger)tag {
    
    //得到操作数并计算
    if (tag >= 0 && tag <= 9) { //操作数
        _currentOPerationNumber = tag;
        
        _stackOPerationNumber = [self calcuResultOp1:_stackOPerationNumber op2:10 op:106] + _currentOPerationNumber;
        _currentOPerationNumber = _stackOPerationNumber;
      
        [self updateResult:_currentOPerationNumber]; //更新UI
        [(UIButton *)[self.view viewWithTag:100] setTitle:@"C" forState:UIControlStateNormal]; //更新AC
    }
    else{ //操作符
        
            switch (tag) {
            case 100: //AC
                [self initOPerator];//清空操作符和操作数
                [self updateResult:_currentOPerationNumber]; //更新UI
                [(UIButton *)[self.view viewWithTag:100] setTitle:@"AC" forState:UIControlStateNormal];
                break;
            case 104: //+
                //_lastOPerationNumber = _currentOPerationNumber;
                    
                //计算
                if (_lastCurrentOperatorBtn) { //有操作数
                    _stackOPerationNumber = [self calcuResultOp1:_lastOPerationNumber op2:_currentOPerationNumber op:_lastCurrentOperatorBtn.tag];
                    [self updateResult:_stackOPerationNumber]; //更新UI
//                    _stackOPerationNumber = 0 ;
                    return;
                }
                break;
            case 107: //=

                //计算
                if (_lastCurrentOperatorBtn) { //有操作数
                    _stackOPerationNumber = [self calcuResultOp1:_lastOPerationNumber op2:_stackOPerationNumber op:_lastCurrentOperatorBtn.tag];
                    [self updateResult:_stackOPerationNumber]; //更新UI
                    //_lastOPerationNumber = _stackOPerationNumber;
//                    _stackOPerationNumber = 0;
                    _currentOPerationNumber = 0;
                }
                return;
            default:
                break;
        }
        
        //更新操作符
        if(_lastCurrentOperatorBtn){
            _lastCurrentOperatorBtn = nil;
        }
        
        _lastCurrentOperatorBtn = _currentOperatorBtn; //当前操作符赋值给上个操作符
        _lastOPerationNumber = _currentOPerationNumber; //保存操作数
        _stackOPerationNumber = 0; //清空中间变量

    }
}


//计算结果
//op1 操作数1
//op2 操作数2
//op 操作符
- (NSInteger)calcuResultOp1:(NSInteger)op1 op2:(NSInteger)op2 op:(NSInteger)op{
    NSInteger result; //保存结果
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
            case 108: //  /
                result = op1 / op2;
                break;
            default:
                result = _currentOPerationNumber;
                break;
        }
    }
    return result;
}




@end
