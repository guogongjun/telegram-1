//
//  TGPasslockModalView.m
//  Telegram
//
//  Created by keepcoder on 23.02.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGPasslockModalView.h"
#import "TGPasslock.h"

@interface TGPasslockModalView ()
@property (nonatomic,strong) TMAvatarImageView *avatar;
@property (nonatomic,strong) NSSecureTextField *secureField;

@property (nonatomic,strong) TMNameTextField *descriptionField;
@property (nonatomic,strong) BTRButton *closeButton;

@property (nonatomic,assign) int state;

@property (nonatomic,strong) NSMutableArray *md5Hashs;
@end

@implementation TGPasslockModalView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        _md5Hashs = [[NSMutableArray alloc] init];
        
        self.wantsLayer = YES;
        self.layer.backgroundColor = NSColorFromRGB(0xffffff).CGColor;
        
        self.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        
        
        self.avatar = [TMAvatarImageView standartUserInfoAvatar];
        [self.avatar setFrameSize:NSMakeSize(100, 100)];
        
        [self.avatar setAutoresizesSubviews:NSViewMinXMargin | NSViewMinYMargin | NSViewMaxXMargin | NSViewMinYMargin];
        
        
        [self.avatar setCenterByView:self];
        
        [self.avatar setFrameOrigin:NSMakePoint(NSMinX(self.avatar.frame), NSMinY(self.avatar.frame) + 50)];
        
        [self addSubview:self.avatar];
        
        
        [self.avatar setUser:[UsersManager currentUser]];
        
        
        self.secureField = [[BTRSecureTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 30)];
        
        
        NSMutableAttributedString *attrs = [[NSMutableAttributedString alloc] init];
        
        [attrs appendString:NSLocalizedString(@"Passcode.EnterPlaceholder", nil) withColor:NSColorFromRGB(0xc8c8c8)];
        
        [attrs setAttributes:@{NSFontAttributeName:[NSFont fontWithName:@"HelveticaNeue" size:12]} range:attrs.range];
        
        [self.secureField setPlaceholderAttributedString:attrs];
        
        [attrs setAlignment:NSCenterTextAlignment range:attrs.range];
        
       // [[self.secureField cell] setPlaceholderAttributedString:attrs];
        
        [self.secureField setAlignment:NSLeftTextAlignment];
        
        [self.secureField setCenterByView:self];
        
        [self.secureField setBordered:NO];
        [self.secureField setDrawsBackground:YES];
        
        [self.secureField setBackgroundColor:NSColorFromRGB(0xF1F1F1)];
        
        [self.secureField setFocusRingType:NSFocusRingTypeNone];
        
        [self.secureField setBezeled:NO];
        
        
        self.secureField.wantsLayer = YES;
        self.secureField.layer.cornerRadius = 4;
        
      //  self.secureField.layer.masksToBounds = YES;
        
        
        [self.secureField setAction:@selector(checkPassword)];
        [self.secureField setTarget:self];
        
        [self.secureField setFont:[NSFont fontWithName:@"HelveticaNeue" size:16]];
        [self.secureField setTextColor:NSColorFromRGB(0xc8c8c8)];
        
        [self.secureField setFrameOrigin:NSMakePoint(NSMinX(self.secureField.frame), NSMinY(self.avatar.frame) - 100)];
        
        
        [self addSubview:self.secureField];
        
        
        self.descriptionField = [[TMNameTextField alloc] initWithFrame:NSZeroRect];
        
        
        [self.descriptionField setSelector:@selector(profileTitle)];
        [self.descriptionField setUser:[UsersManager currentUser]];
        
        [self.descriptionField setFont:[NSFont fontWithName:@"HelveticaNeue" size:14]];
        
        [self.descriptionField setTextColor:DARK_BLACK];
        

        
        
        [self.descriptionField sizeToFit];
        
        [self.descriptionField setCenterByView:self];
        
        [self.descriptionField setFrameOrigin:NSMakePoint(NSMinX(self.descriptionField.frame), NSMinY(self.avatar.frame) - 40)];
        
        [self addSubview:self.descriptionField];
        
        self.closeButton = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, image_ClosePopupDialog().size.width, image_ClosePopupDialog().size.height)];
        
        [self.closeButton setImage:image_ClosePopupDialog() forControlState:BTRControlStateNormal];
        
        
        [self.closeButton setFrameOrigin:NSMakePoint(NSWidth(self.frame) - NSWidth(self.closeButton.frame) - 20, NSHeight(self.frame) - NSHeight(self.closeButton.frame) - 20)];
        
        
        weak();
        
        [self.closeButton addBlock:^(BTRControlEvents events) {
            
            
            [weakSelf closeAndNotify:nil success:NO];
            
            
        } forControlEvents:BTRControlEventClick];
        
        [self addSubview:self.closeButton];
        
      //  [self updateDescription];
        
    }
    
    return self;
}

-(void)updateDescription {
    NSDictionary *d = @{@(TGPassLockViewCreateType):@[NSLocalizedString(@"Passcode.EnterYourNewPasscode", nil),NSLocalizedString(@"Passcode.ReEnterYourPasscode", nil)],
                        @(TGPassLockViewChangeType):@[NSLocalizedString(@"Passcode.EnterYourOldPasscode", nil),NSLocalizedString(@"Passcode.EnterYourNewPasscode", nil),NSLocalizedString(@"Passcode.ReEnterYourPasscode", nil)],
                        @(TGPassLockViewConfirmType):@[NSLocalizedString(@"Passcode.EnterYourPasscode", nil)]};
    
   
    
    NSMutableAttributedString *attrs = [[NSMutableAttributedString alloc] init];
    
    [attrs appendString:d[@(_type)][_state] withColor:NSColorFromRGB(0xc8c8c8)];
    
    [attrs setAttributes:@{NSFontAttributeName:[NSFont fontWithName:@"HelveticaNeue" size:14]} range:attrs.range];
    
    [attrs setAlignment:NSLeftTextAlignment range:attrs.range];
    
    [[self.secureField cell] setPlaceholderAttributedString:attrs];
}

-(void)checkPassword {
    
    NSString *hash = [self.secureField.stringValue md5];
    
    if(_type == TGPassLockViewConfirmType) {
        
        if([TGPasslock checkHash:hash]) {
            [self closeAndNotify:hash success:YES];
        } else {
            NSBeep();
        }
        
        return;
        
    } else if(_type == TGPassLockViewCreateType) {
        
        if(_state == 1) {
            if([_md5Hashs[_state - 1] isEqualToString:hash]) {
                 [self closeAndNotify:hash success:YES];
            } else {
                NSBeep();
            }
            
            return;
        }
        
        
        
    } else if(_type == TGPassLockViewChangeType) {
        
        if(_state == 0) {
            
            if(![TGPasslock checkHash:hash]) {
                [self showError];
                NSBeep();
                return;
            }
            
        } else if(_state == 2) {
            if([_md5Hashs[_state - 1] isEqualToString:hash]) {
                
                [self closeAndNotify:hash success:YES];
            } else {
                NSBeep();
            }
            
            return;
        }
    }
    
    [_secureField setStringValue:@""];
    
    _md5Hashs[_state] = hash;
    
    _state++;
    
    [self updateDescription];
    
    
    
}

-(void)closeAndNotify:(NSString *)hash success:(BOOL)success {
    if(_passlockResult) {
        _passlockResult(success, hash);
    }

    
    [TMViewController hidePasslock];
}

-(void)showError {
    
}

-(void)setType:(TGPassLockViewType)type {
    _type = type;
    _state = 0;
    [_md5Hashs removeAllObjects];
    [self updateDescription];
    _closable = YES;
}

-(void)setClosable:(BOOL)closable {
    _closable = closable;
    
    [self.closeButton setHidden:!closable];
}

-(BOOL)becomeFirstResponder
{
    return [self.secureField becomeFirstResponder];
}


-(void)mouseDown:(NSEvent *)theEvent {
    
}

-(void)scrollWheel:(NSEvent *)theEvent {
    
}

-(void)mouseEntered:(NSEvent *)theEvent {
    
}

-(void)mouseExited:(NSEvent *)theEvent {
    
}

-(void)mouseMoved:(NSEvent *)theEvent {
    
}

-(void)keyDown:(NSEvent *)theEvent {
    
}

-(void)keyUp:(NSEvent *)theEvent {
    
}

@end