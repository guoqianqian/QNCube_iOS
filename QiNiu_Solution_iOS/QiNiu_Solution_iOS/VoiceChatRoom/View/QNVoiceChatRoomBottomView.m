//
//  QNVoiceChatRoomBottomView.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/1/10.
//

#import "QNVoiceChatRoomBottomView.h"

@interface QNVoiceChatRoomBottomView ()

@property (nonatomic,strong)UIButton *leaveButton;

@property (nonatomic,strong)UIButton *onMicButton;

@property (nonatomic,strong)UIButton *voiceButton;

@end

@implementation QNVoiceChatRoomBottomView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self leaveButton];
        [self onMicButton];
        [self voiceButton];
    }
    return self;
}

-(UIButton *)leaveButton {
    if (!_leaveButton) {
        _leaveButton = [[UIButton alloc]init];
        [_leaveButton setTitle:@" 离开房间 " forState:UIControlStateNormal];
        [_leaveButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        _leaveButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_leaveButton setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
        _leaveButton.clipsToBounds = YES;
        _leaveButton.layer.cornerRadius = 20;
        [self addSubview:_leaveButton];
        [_leaveButton addTarget:self action:@selector(leaveRoom) forControlEvents:UIControlEventTouchUpInside];
        
        [_leaveButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(15);
            make.bottom.equalTo(self.mas_bottom).offset(-30);
            make.height.mas_equalTo(40);
            make.width.mas_equalTo(150);
        }];
    }
    return _leaveButton;
}

-(UIButton *)onMicButton {
    if (!_onMicButton) {
        _onMicButton = [[UIButton alloc]init];
        [_onMicButton setImage:[UIImage imageNamed:@"icon_hands_up"] forState:UIControlStateNormal];
        [self addSubview:_onMicButton];
        [_onMicButton addTarget:self action:@selector(onMic) forControlEvents:UIControlEventTouchUpInside];
        
        [_onMicButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.voiceButton.mas_left).offset(-15);
            make.centerY.equalTo(self.leaveButton);
            make.height.width.mas_equalTo(25);
        }];
    }
    return _onMicButton;
}

-(UIButton *)voiceButton {
    if (!_voiceButton) {
        _voiceButton = [[UIButton alloc]init];
        [_voiceButton setImage:[UIImage imageNamed:@"icon_mic_on"] forState:UIControlStateNormal];
        [_voiceButton setImage:[UIImage imageNamed:@"icon_mic_off"] forState:UIControlStateSelected];
        [self addSubview:_voiceButton];
        [_voiceButton addTarget:self action:@selector(voicebuttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [_voiceButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-15);
            make.centerY.equalTo(self.leaveButton);
            make.height.width.mas_equalTo(25);
        }];
    }
    return _voiceButton;
}

- (void)leaveRoom {
    if (self.buttonClickBlock) {
        self.buttonClickBlock(QNVoiceChatRoomClickTypeLeave);
    }
}

- (void)onMic {
    if (self.buttonClickBlock) {
        self.buttonClickBlock(QNVoiceChatRoomClickTypeOnMic);
    }
}

- (void)voicebuttonClicked:(UIButton *)button {
    button.selected = !button.selected;
    if (self.buttonClickBlock) {
        self.buttonClickBlock(QNVoiceChatRoomClickTypeVoice);
    }
}


@end
