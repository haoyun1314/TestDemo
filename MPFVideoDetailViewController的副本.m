//
//  MPFVideoDetailViewController.m
//  MiaoPai
//
//  Created by 蔡勋 on 2017/6/21.
//  Copyright © 2017年 Jeakin. All rights reserved.
//


#import "MPFVideoDetailViewController.h"
#import "MPTCategory.h"
#import <EXTScope.h>
#import <Masonry/Masonry.h>
#import "MPTHttpClient.h"
#import "MPTCommentDataSource.h"
#import "UIScrollView+YXPullToRefresh.h"
#import "MPTFootRefreshView.h"
#import "YXRefresh.h"
#import <EXTScope.h>
#import "MPTCommentCell.h"
#import "MPTValidObject.h"
#import "MPTTool.h"
#import "MPTLikedUsersDataSource.h"
#import "MPTDetailLikeCell.h"
#import "MPTCommentInputView.h"
#import "MPTLoginApp.h"
#import "JLRoutes.h"
#import "MPTPlayer.h"
#import "MPTTips.h"
#import "MPTRotateLoadingView.h"
#import "MPFUserHomeVC.h"
#import "MPTLogger.h"
#import "MPFSharePlan.h"
#import "MPTVideoPlayer.h"
#import "UIImageView+WebCache.h"
#import "MPUmeng.h"
#import "UINavigationBar+MPTBackground.h"
#import "MPTShareManager.h"
#import "MPTWaterFallContainer.h"
#import "MPTUnloginEvent.h"
#import <AVKit/AVKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MPFFullScreenSharePlanView.h"
#import "MPTCourseofStudyView.h"
#import "MPFVideoDetailViewController+Share.h"
#import "MPTPlayer+PlayerSubMethod.h"
#import "MPTVideoCDN.h"
#import "MPTReachability.h"
#import "MPTHVideoDownloadManager.h"
#import "MPSAppStatisticsSingle.h"
#import "MPFDetailHeadView.h"
#import "MPFVideoRelationCell.h"
#import "MPFVDRelationHeadView.h"
#import "MPFVideoRelationDataSource.h"
#import "MPFVideoDetailActionView.h"
#import "MPTHVideoCacheManager.h"
#import "UIView+MPTShowADInScreen.h"
#import "MPFSDKADRequest.h"
#import "MPFVideoDetailInputView.h"
#import "MPTAtViewController.h"
#import <MPTCustomUILibrary/MPCPageLoadingView.h>
#import "MPFDetailPushManager.h"
#import "MPFVideoDetailCommentTwoView.h"
#import "MPFVDOneFloorCommentCell.h"
#import "MPFVideoDeailCommentReq.h"
#import "MPFVideoDeailSendCommentReq.h"
#import "MPFVideoCommentModel.h"
#import "MPFVideoContentModel.h"
#import "MPFVideoDetailBindPhoneNumberView.h"
#import "MPFBindIPhoneReq.h"
#import "MPTRefreshAutoFooter.h"
#import "MPCAlertView.h"

static NSString *kVideoRelationCellID = @"kVideoRelationCellID";


typedef void(^MPHReloadVideoInfoCallBack)(void);


@interface MPFVideoDetailViewController ()
<
UITableViewDataSource,
UITableViewDelegate,UIGestureRecognizerDelegate,
UIActionSheetDelegate,
MPCAlertViewDelegate,
MPDMPFVDOneFloorCommentCellDelegate,
MPTLikesBarDelegate,MPTVideoPlayerDelegate,
MPTDetailLikeCellDelegate,
MPTPlayerDelegate,
MPDVideoDetailActionViewDelegate,
MPFDetailHeadViewDelgate
>
{
    BOOL isAppear;
    BOOL isKeyWindowRecord;
    NSString *_pvID;
    NSInteger inputLocation;
    NSString *_currentImageURl;
    
    MPTRotateLoadingView *_rotateLoadingView;
    PageType _pageType;
}

//
@property (nonatomic, strong) UITableView *tableView;
//
@property (nonatomic, strong) UIView *bacView;

@property (nonatomic, strong) NSIndexPath *lastDeleteIndexPath;
@property (nonatomic, assign) NSInteger detailType;

@property (nonatomic, assign) BOOL isRequestAgain;
@property (nonatomic, assign) BOOL haveAction;
@property (nonatomic, assign) BOOL hadSelected;
@property (nonatomic, assign) BOOL isJustHandelLike;

// 从上层传递进来的模型,不会随着更新具体信息而修改,指向的是上层模型的地址
@property (nonatomic, strong) MPTChannelModel *originalModel;
@property (nonatomic, strong) MPFVideoRelationDataSource *relationDataSource;

@property (nonatomic, strong) MPFVideoDetailInputControlView *enputView;

@property (nonatomic, assign) NSInteger commentNumber;

@property (nonatomic, strong) UILabel *commentNumberLabel;

@property (nonatomic, assign) BOOL NotshowNoNetworkTip;
@property (nonatomic, assign) BOOL isAllScreenNeed;

@property (nonatomic, strong) UIButton *backButtonItem;
@property (nonatomic, strong) UIButton *moreButtonItem;
@property (nonatomic, strong) MPTUnloginEvent *unlogin;

@property (nonatomic, weak) MPTCourseofStudyView *courseView;

//
@property (nonatomic, strong) UIView *viewFooterInSection;

@property (nonatomic, strong) MPFSDKADRequest *request;
//
@property (nonatomic, strong) UIView *containter;

/// 输入框
@property (nonatomic, strong) MPFVideoDetailInputView *inputView;

// 请求视频信息是否完成
@property (nonatomic, assign) BOOL boolReqVideoInfoOver;
// 请求相关视频是否完成
@property (nonatomic, assign) BOOL boolReqRelationOver;
// 请求评论是否完成
@property (nonatomic, assign) BOOL boolReqCommentOver;
// 首页首次请求是否成功
@property (nonatomic, assign) BOOL isReqSuccessForVideoInfo;

// 页面的加载状态占位显示的view
@property (nonatomic, strong) MPCPageLoadingView *viewPageState;
// 页面加载错误的提示view
@property (nonatomic, strong) MPCPageLoadingView *viewLoadError;
// 页面加载中的view
@property (nonatomic, strong) MPCPageLoadingView *viewCustomLoading;

@property (nonatomic, assign) BOOL isReloadingAllData;

/// 二级评论页面
@property (nonatomic, strong) MPFVideoDetailCommentTwoView *viewCommentTwo;

/// 评论信息获取
@property (nonatomic, strong) MPFVideoDeailCommentReq *reqComment;

/// 请求的评论信息是否失败
@property (nonatomic, assign)  BOOL isError;

/// 评论的页数
@property (nonatomic, assign) NSInteger intPage;;

/// 评论的数据
@property (nonatomic, strong) NSMutableArray *commentArray;

/// 发评论的请求
@property (nonatomic, strong) MPFVideoDeailSendCommentReq *reqPingLun;

/// 更新绑定手机号状态
@property (nonatomic, strong) MPFBindIPhoneReq *reqBindIPhone;

@property (nonatomic, assign) BOOL twoFlowerisShow;

@end


@implementation MPFVideoDetailViewController


#pragma mark - ********************** View Lifecycle **********************

- (void)dealloc
{
    // 一定要关注这个函数是否被执行了！！！
    [self.inputView removeFromSuperview];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 初始化变量
    [self initVariable];
    
    // 初始化界面
    [self initViews];
    
    // 注册消息
    [self regNotification];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    
    //不要删
    MPFVideoPlayerManagerInstance.superVideoPlayer.overlayView.viewHomeContent.hidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationNone];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent
                                                animated:YES];
    [MPFVideoPlayerManagerInstance.superVideoPlayer  toRecoveryNormalScreen];//不要删我，爱你哦～！
    MPFVideoPlayerManagerInstance.superVideoPlayer.isDetailPage = YES;
    //只有详情小屏有滑动手势
    [MPFVideoPlayerManagerInstance.superVideoPlayer.overlayView.gestureView
     addGestureRecognizer:MPFVideoPlayerManagerInstance.superVideoPlayer.overlayView.playerViewpanGesture1];
    [MPFVideoPlayerManagerInstance.superVideoPlayer.overlayView.middlePlayControlView
     addGestureRecognizer:MPFVideoPlayerManagerInstance.superVideoPlayer.overlayView.playerViewpanGesture];
    MPFVideoPlayerManagerInstance.superVideoPlayer.currentPlayPage = MPTPlayerDetailPage;
    if (!self.isAddPlayer)
    {
        [self cusviewWillAppear];
    }
    
    [MPFVideoPlayerManagerInstance.superVideoPlayer refreshBeforeStartPlayFrame];
    MPFVideoPlayerManagerInstance.superVideoPlayer.viewCommented = 1; //播放参数投递
    [self regNotificationWhenViewAppear];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationNone];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent
                                                animated:YES];

    [self initBlock];
    [self.playerView addSubview:self.player];
    [self.player mas_remakeConstraints:^(MASConstraintMaker *make) {
         make.edges.equalTo(self.playerView);
     }];
    self.player.delegate = self;
    
    
    [MPFVideoPlayerManagerInstance.superVideoPlayer refreshBeforeStartPlayFrame];

    if (self.showKeyboard)
    {
        [self.inputView.textViewInput becomeFirstResponder];
    }
    
    [MPTTool setPresentingPageWithoutReportStatics:_pageType];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.enputView.enableLike = YES;
    });
    
    isAppear = YES;
    
    [MPFVideoPlayerManagerInstance.superVideoPlayer syncLikeState:(self.channelModel.selfmark == 6)];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    isAppear = NO;
    [[MPTHVideoDownloadManager shareInstance] cancleAllDownloadTaskForDeleteTask:YES];
    self.originalModel.stat_ccnt = self.commentNumber;
    
    [self removeNotificationWhenViewDisAppear];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];


    MPFVideoPlayerManagerInstance.superVideoPlayer.isDetailPage = NO;
    //只有详情小屏有滑动手势
    [MPFVideoPlayerManagerInstance.superVideoPlayer.overlayView.gestureView
     removeGestureRecognizer:MPFVideoPlayerManagerInstance.superVideoPlayer.overlayView.playerViewpanGesture1];
    [MPFVideoPlayerManagerInstance.superVideoPlayer.overlayView.middlePlayControlView
     removeGestureRecognizer:MPFVideoPlayerManagerInstance.superVideoPlayer.overlayView.playerViewpanGesture];
    [MPFVideoPlayerManagerInstance.superVideoPlayer counDownTitle];
    [MPFVideoPlayerManagerInstance.superVideoPlayer cancel_PlayNextVideo];
    [MPFVideoPlayerManagerInstance.superVideoPlayer.overlayView.middlePlayControlView hidePreviousAndNextBtn:YES];

    self.showKeyboard = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:UIStatusBarAnimationFade];

    if (MPFVideoPlayerManagerInstance.superVideoPlayer.isContinuePlay == NO && MPFVideoPlayerManagerInstance.superVideoPlayer.isSmallPlay == NO)
    {
        MPFVideoPlayerManagerInstance.superVideoPlayer.channelSingleRowCell = nil;
        MPFVideoPlayerManagerInstance.superVideoPlayer.meSingCell = nil;
        MPFVideoPlayerManagerInstance.superVideoPlayer.attentionCell = nil;
    
        
        
        MPFVideoPlayerManagerInstance.superVideoPlayer.isAfterBufferPlayStatus = NO;
        [MPFVideoPlayerManagerInstance.superVideoPlayer removeFromSuperview];
//        MPFVideoPlayerManagerInstance.superVideoPlayer.viewCommented = 1; //播放参数投递
        [self.player shangBaoStopOutSide];
        if (MPFVideoPlayerManagerInstance.superVideoPlayer.isScreen == NO)
        {
            MPFVideoPlayerManagerInstance.superVideoPlayer.currentPlayPage = MPTPlayerUnknownPage;
        }
        [MPFVideoPlayerManagerInstance.superVideoPlayer progressViewHide:YES];

    }
    
    self.showFullScreen = NO;
    self.playerStatus = ispause;
    
    if (self.isAllScreenNeed)
    {
        self.isAllScreenNeed = NO;
    }
    else
    {
        
    }
    
    if (self.detailType == DetailVideoType_sameCityVote)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kMPTSameCityVoteViewWillAppear" object:nil];
    }
    
    [self.inputView resign];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - ********************** init and config **********************

/**
 TODO: 初始化变量，例如：分页的page可以在该函数中赋初值
 */
- (void)initVariable
{
    /// 更新绑定手机号逻辑
    _reqBindIPhone = [[MPFBindIPhoneReq alloc] init];
    [_reqBindIPhone netWorkWithsuccess:nil failed:nil cached:nil];
    
    _intPage = 1;
    _pageType = kPageType_ShiPinBoFangXiangQing;
    if (MPFAppStatisticsSingleInstance.isFromPush)
    {
        MPFAppStatisticsSingleInstance.isFromPush = NO;
        _pageType = kPageType_PushTuiSongYe;
    }
    else if (MPFAppStatisticsSingleInstance.isFromScheme)
    {
        MPFAppStatisticsSingleInstance.isFromScheme = NO;
        _pageType = kPageType_SchemeToVieoDetail;
    }
    
   _pvID = [MPTTool setPresentingPage:_pageType];

    self.boolReqVideoInfoOver = NO;
    self.boolReqRelationOver = NO;
    self.boolReqCommentOver = NO;
    self.isReqSuccessForVideoInfo = NO;
    [MPFVideoPlayerManagerInstance.superVideoPlayer initDetailVideoArray];
    
    /// pop执行时回调
    self.mp_willPopBlock = ^(UINavigationController *nav)
    {
        MPFVideoPlayerManagerInstance.superVideoPlayer.isDetailPage = NO;
        if (MPFVideoPlayerManagerInstance.superVideoPlayer.currentPlayItemDuration > 0 &&
            [MPFVideoPlayerManagerInstance.superVideoPlayer getCurrentItemForVideoPlayer] != nil &&
            MPFVideoPlayerManagerInstance.superVideoPlayer.isPlayEndShow == NO )
        {
            MPFVideoPlayerManagerInstance.superVideoPlayer.currentPlayPage = MPTPlayOtherDidExistence;
            if (MPFVideoPlayerManagerInstance.superVideoPlayer.feedAddVideoPlayerEvent)
            {
                if (isValidValue(MPFVideoPlayerManagerInstance.superVideoPlayer.channelSingleRowCell))
                {
                MPFVideoPlayerManagerInstance.superVideoPlayer.feedAddVideoPlayerEvent(MPFVideoPlayerManagerInstance.superVideoPlayer.channelSingleRowCell, YES);
                }
                if (isValidValue(MPFVideoPlayerManagerInstance.superVideoPlayer.attentionCell))
                {
                    MPFVideoPlayerManagerInstance.superVideoPlayer.feedAddVideoPlayerEvent(MPFVideoPlayerManagerInstance.superVideoPlayer.attentionCell, YES);
                }
            }
            if (isValidValue(MPFVideoPlayerManagerInstance.superVideoPlayer.meFeedViewAddPlayerBlock))
            {
                if (isValidValue(MPFVideoPlayerManagerInstance.superVideoPlayer.meSingCell)) {
                    MPFVideoPlayerManagerInstance.superVideoPlayer.meFeedViewAddPlayerBlock(MPFVideoPlayerManagerInstance.superVideoPlayer.meSingCell, YES);
                }
            }
        }
    };
}

- (void)initViews
{
    // 创建相关子view
    [self initMainViews];
    
    // 初始化Nav导航栏
    [self initNavView];
}

/**
 TODO: 初始化Nav导航栏
 */
- (void)initNavView
{
    self.zf_prefersNavigationBarHidden = YES;
    [self.view addSubview:self.backButtonItem];
    [self.view addSubview:self.moreButtonItem];
    //----------不要删-----------
    self.moreButtonItem.hidden = YES;
}

/**
 TODO: 创建相关子view
 */
- (void)initMainViews
{
    [super viewDidLoad];
    
    if (MPFVideoPlayerManagerInstance.superVideoPlayer.isA == YES) {
        /// 添加改变播放器大小的手势
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
        pan.delegate = self;
        [self.view addGestureRecognizer:pan];
    }

    
    // 用于神策统计相关的
    MPFVideoPlayerManagerInstance.superVideoPlayer.isAfterBufferPlayStatus = YES;
    
    [self unLoginLikeStatue];
    [self initialLayoutView];
    [self initialSomeData];
    [self initFollowedStatue];
    [self initPlayerBackGroundImageView];
    self.isRewardVideo = NO;
    MPFVideoPlayerManagerInstance.superVideoPlayer.viewCommented = 1; //播放参数投递
    MPFVideoPlayerManagerInstance.superVideoPlayer.watchType = 1;

    [self.view addSubview:self.inputView];
    [self.inputView setHidden:YES];
}

-(void)initBlock
{
    MPFVideoPlayerManagerInstance.superVideoPlayer.detailAddVideoPlayEventBlock = ^(UIView *aView, BOOL isContinue) {
        MPFVideoPlayerManagerInstance.superVideoPlayer.watchType = 1;
        MPFVideoPlayerManagerInstance.superVideoPlayer.isContinuePlay = isContinue;
        if(MPFVideoPlayerManagerInstance.superVideoPlayer.isContinuePlay == YES &&
           isValidValue(MPFVideoPlayerManagerInstance.superVideoPlayer.detailContinueView))
        {
            [aView addSubview:MPFVideoPlayerManagerInstance.superVideoPlayer];
            [aView bringSubviewToFront:MPFVideoPlayerManagerInstance.superVideoPlayer];
            [MPFVideoPlayerManagerInstance.superVideoPlayer mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(aView);
            }];
            
            [self.view setNeedsUpdateConstraints];
            [self.view layoutIfNeeded];
            [MPFVideoPlayerManagerInstance.superVideoPlayer refreshBeforeStartPlayFrame];
            MPFVideoPlayerManagerInstance.superVideoPlayer.detailContinueView = nil;
        }
        else
        {
            MPFVideoPlayerManagerInstance.superVideoPlayer.isContinuePlay = NO;
            [MPFVideoPlayerManagerInstance.superVideoPlayer removeFromSuperview];
            [MPFVideoPlayerManagerInstance.superVideoPlayer shangBaoOutSide];
        }
        
    };
    
    __weak typeof(self) weakSelf = self;
    
    MPFVideoPlayerManagerInstance.superVideoPlayer.nextVideoBlock = ^(MPFVideoRelationModel *model)
    {
        /// 回收二级评论面板
        [weakSelf.viewCommentTwo hiden];
        /// 切换下一个时候回收键盘清晨记忆
        weakSelf.inputView.textViewInput.text = @"";
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UITextViewTextDidChangeNotification" object:weakSelf.inputView.textViewInput];
        [weakSelf.inputView resign];
        MPFVideoPlayerManagerInstance.superVideoPlayer.channelSingleRowCell = nil;
        MPFVideoPlayerManagerInstance.superVideoPlayer.meSingCell = nil;
        MPFVideoPlayerManagerInstance.superVideoPlayer.attentionCell = nil;
        weakSelf.scid = model.scid;
        weakSelf.url = model.play_url;
//        weakSelf.duration = model.
        if (isValidNSString(model.title)) {
            MPFVideoPlayerManagerInstance.superVideoPlayer.overlayView.mptRecommandTooView.titleLabel.text = model.title;
        }
        else
        {
          MPFVideoPlayerManagerInstance.superVideoPlayer.overlayView.mptRecommandTooView.titleLabel.text = @"";
        }
        if (isValidNSString(model.pic))
        {
            self->_currentImageURl = model.pic;
        }
        if (MPFVideoPlayerManagerInstance.superVideoPlayer.isScreen == YES)
        {
            [MPFVideoPlayerManagerInstance.superVideoPlayer setAlphaForVideoPlayer:1];
        }
        [weakSelf reloadAllData];
        [weakSelf.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
    };
    
    MPFVideoPlayerManagerInstance.superVideoPlayer.previousVideoBlock = ^(MPTChannelModel *model)
    {
        /// 回收二级评论面板
        [weakSelf.viewCommentTwo hiden];
        /// 切换上一个时候回收键盘清晨记忆
        weakSelf.inputView.textViewInput.text = @"";
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UITextViewTextDidChangeNotification" object:weakSelf.inputView.textViewInput];
        [weakSelf.inputView resign];
        //1.加载上一个视频
        //2.请求相关视频
        //3.数组擅长当前视频信息

        
        weakSelf.scid = model.scid;
        if (isValidNSString(model.videoImage))
        {
            self->_currentImageURl = model.videoImage;
        }
        if (MPFVideoPlayerManagerInstance.superVideoPlayer.isScreen == YES)
        {
            [MPFVideoPlayerManagerInstance.superVideoPlayer setAlphaForVideoPlayer:1];
        }
        if (isValidNSString(model.ext_title))
        {
            MPFVideoPlayerManagerInstance.superVideoPlayer.overlayView.mptRecommandTooView.titleLabel.text = model.ext_title;
        }
        else
        {
            MPFVideoPlayerManagerInstance.superVideoPlayer.overlayView.mptRecommandTooView.titleLabel.text = @"";
        }
        
        MPFVideoPlayerManagerInstance.superVideoPlayer.backgroundColor = [UIColor blackColor];
        if (isValidNSArray(MPFVideoPlayerManagerInstance.superVideoPlayer.detailAlreadyPlayVideoModelArray))
        {
            [MPFVideoPlayerManagerInstance.superVideoPlayer.detailAlreadyPlayVideoModelArray removeLastObject];
            [MPFVideoPlayerManagerInstance.superVideoPlayer reloadDetailPreviousAndNextVideoBtn];
        }
        NSLog(@"self.detailAlreadyPlayVideoModelArray = %@",MPFVideoPlayerManagerInstance.superVideoPlayer.detailAlreadyPlayVideoModelArray);
        [weakSelf reloadAllData];
        [weakSelf.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
    };
}

/**
 TODO: 注册通知
 */
- (void)regNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActiveDo:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyWindowChanged)
                                                 name:UIWindowDidBecomeKeyNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(LoginSuccess:)
                                                 name:@"kLoginSuccess"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationHasChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)regNotificationWhenViewAppear
{
    // 注册键盘显示和隐藏事件
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)removeNotificationWhenViewDisAppear
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


#pragma mark - ******************************************* 对外方法 *********************************

- (id)initWithVideoType:(DetailVideoType)type
           channelModel:(MPTChannelModel *)model
                   data:(NSString *)dataId
{
    self = [super init];
    
    if (self)
    {
        self.channelModel = model;
        self.originalModel = model;
        MPFVideoPlayerManagerInstance.superVideoPlayer.feedOrignModel = model;
        self.detailType = type;
        if (self.detailType == DetailVideoType_UserTopic ||
            self.detailType  == DetailVideoType_Location)
        {
            self.detailType = DetailVideoType_User;
        }
        
        self.scid = model.scid;
        self.hidesBottomBarWhenPushed = YES;
    }
    
    return self;
}

- (id)initWithVideoScid:(NSString *)scid
{
    self = [super init];
    
    if(self)
    {
        self.detailType = DetailVideoType_User;
        self.scid = scid;
        self.hidesBottomBarWhenPushed = YES;
    }
    
    return self;
}

- (void)cusviewWillAppear
{
    self.isAddPlayer = NO;
    if (MPFVideoPlayerManagerInstance.superVideoPlayer.forwardVideo == NO)
    {
        if (MPFVideoPlayerManagerInstance.superVideoPlayer.isContinuePlay == NO)
        {
            [self addMPTPlayerView];
//            MPFVideoPlayerManagerInstance.superVideoPlayer.viewCommented = 1;
            MPFVideoPlayerManagerInstance.superVideoPlayer.watchType = 1;
        }
        else
        {
            
            if (MPFVideoPlayerManagerInstance.superVideoPlayer.isPlayEndShow == NO) {
                [MPFVideoPlayerManagerInstance.superVideoPlayer.overlayView.middlePlayControlView hidePreviousAndNextBtn:NO];
            }
            MPFVideoPlayerManagerInstance.superVideoPlayer.isContinuePlay  = NO;
        }
        
        if (isValidValue(self.player) && [self.playerView.subviews containsObject:MPFVideoPlayerManagerInstance.superVideoPlayer])
        {
            [self.player mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.playerView);
            }];
        }
      
        if ( isValidValue(self.player)
            && [self.playerView.subviews containsObject:MPFVideoPlayerManagerInstance.superVideoPlayer]
            &&  self.relationDataSource.dataArray.count > 0)
        {
            MPFVideoPlayerManagerInstance.superVideoPlayer.detailRelationModelArray = self.relationDataSource.dataArray;
        }
        self.player.delegate = self;
    }
    
    isKeyWindowRecord = YES;
    if (self.detailType == DetailVideoType_sameCityVote)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kMPTSameCityVoteViewWillDisappear"
                                                            object:nil];
    }
}

- (void)__like
{
    [MPUmeng event:@"detail_good_total"];
    
    self.likeFromDoubleTap = NO;
    
    if (![MPTLoginApp isLogin])
    {
        self.enputView.likeButton.enabled = YES;
        self.detailHeadView.viewDetailAction.btnLike.enabled = YES;
        //先判断是否已赞过  已赞过 - 是否取消     没有 ->判断是不是第20次  否则累加点赞次数
        if (![_unlogin.totalLoveVideoScids containsObject:self.channelModel.scid] )
        {
            if (_unlogin.totalLoves == 20)
            {
                //   -----------addByDong----------
                if (self.player)
                {
                    [self.player syncLikeState:NO];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"moreZanNotification" object:nil userInfo:nil];
                
                UIAlertView *loginInfoAlert =[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Tips", nil) message:NSLocalizedString(@"unloginAdmireInfo",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) otherButtonTitles:NSLocalizedString(@"Logon",nil), nil];
                loginInfoAlert.tag = 31;
                [loginInfoAlert show];
            }
            else
            {
                [self.enputView updateLikeStatus:YES andPraisedNumber:self.channelModel.stat_lcnt animate:YES];
                [self.detailHeadView.viewDetailAction.btnLike setLikeInDetailPage:YES animate:YES];
                
                //累加赞的个数 + 点赞效果
                if (self.player)
                {
                    //----------------addBydong--------------
                    [self.player syncLikeState:YES];
                }
                [_unlogin addLoveVideoScid:self.channelModel.scid];
                [_unlogin incLoves];
                self.channelModel.selfmark = 6;
                self.channelModel.stat_lcnt ++;
                self.originalModel.selfmark = self.channelModel.selfmark;
                self.originalModel.stat_lcnt = self.channelModel.stat_lcnt;
                [self originalModelChanged:nil];
                [self.enputView updateLikeStatus:YES andPraisedNumber:self.channelModel.stat_lcnt animate:NO];
                [self.detailHeadView.viewDetailAction.btnLike setLikeInDetailPage:YES animate:NO];
                [self.detailHeadView.viewDetailAction.btnLike setTitle:self.enputView.likeBtnLbl.text forState:UIControlStateNormal];
                [self postLikeNotification];
                [self postChannalModelLikeStateChangeNotification];
                NSLog(@"未登录关注的 = %@",[_unlogin totalLoveVideoScids]);
            }
        }
        else
        {
            NSLog(@"取消赞");
        }
    }
    else
    {
        [self.enputView updateLikeStatus:YES andPraisedNumber:self.channelModel.stat_lcnt animate:YES];
        [self.detailHeadView.viewDetailAction.btnLike setLikeInDetailPage:YES animate:YES];
        
        if (self.channelModel.stat_lcnt<1)
        {
            //处理只有自己一个赞的情况
            [self likeHandleSingle:YES];

            __weak typeof(self) weakSelf = self;
            MPTHttpClient *httpClient = [MPTHttpClient sharedMPHTTPClient];
            
            [httpClient updateVideoLikeScid:self.scid
                                  contentID:self.channelModel.contentId
                               impressionID:self.channelModel.impressionId
                                    success:^(NSURLSessionDataTask *task, NSDictionary *responseObject)
            {
                __strong typeof(weakSelf)strongSelf = weakSelf;
                if (strongSelf)
                {
                    strongSelf.enputView.likeButton.enabled = YES;
                    strongSelf.detailHeadView.viewDetailAction.btnLike.enabled = YES;
                }
            }
                                    failure:^(NSURLSessionDataTask *task, NSError *error)
            {
                __strong typeof(weakSelf)strongSelf = weakSelf;
                strongSelf.enputView.likeButton.enabled = YES;
                strongSelf.detailHeadView.viewDetailAction.btnLike.enabled = YES;
                [strongSelf.detailHeadView.viewDetailAction.btnLike setTitle:strongSelf.enputView.likeBtnLbl.text forState:UIControlStateNormal];
                NSLog(@"返回的相关错误信息 = %@",error.userInfo);
                //a拉黑b b若对a进行操作返回401错误码   406是相反操作
                if ([error.userInfo[@"status"] integerValue] == 401)
                {
                    [self unlikeHandleSingle:YES];
                    [MPTTips showTips:NSLocalizedString(@"reasonAboutCannotHaveRelation",nil) duration:1.0f];
                }
                else if([error.userInfo[@"status"]integerValue] == 406)
                {
                    [self unlikeHandleSingle:YES];
                    [MPTTips showTips:NSLocalizedString(@"peopleAlreadyExit",nil) duration:1.0f];
                }
                else
                {
                
                }
            }];
        }
        else
        {
            [self likeHandleSingle:NO];
            
            __weak typeof(self) weakSelf = self;
            MPTHttpClient *httpClient = [MPTHttpClient sharedMPHTTPClient];
            
            [httpClient updateVideoLikeScid:self.scid
                                  contentID:self.channelModel.contentId
                               impressionID:self.channelModel.impressionId
                                    success:^(NSURLSessionDataTask *task, NSDictionary *responseObject)
            {
                __strong typeof(weakSelf)strongSelf = weakSelf;
                if (strongSelf)
                {
                    if([responseObject[@"status"] integerValue] == 200)
                    {

                    }
                }
            }
                                    failure:^(NSURLSessionDataTask *task, NSError *error)
            {
                __strong typeof(weakSelf)strongSelf = weakSelf;
                strongSelf.enputView.likeButton.enabled = YES;
                strongSelf.detailHeadView.viewDetailAction.btnLike.enabled = YES;
            
                [strongSelf.detailHeadView.viewDetailAction.btnLike setTitle:strongSelf.enputView.likeBtnLbl.text forState:UIControlStateNormal];
                NSLog(@"返回的相关错误信息 = %@",error.userInfo);
                //a拉黑b b若对a进行操作返回401错误码   406是相反操作
                if ([error.userInfo[@"status"] integerValue] == 401)
                {
                    [self unlikeHandleSingle:NO];

                    [strongSelf.enputView updateLikeStatus:NO andPraisedNumber:strongSelf.channelModel.stat_lcnt animate:NO];
                    [strongSelf.detailHeadView.viewDetailAction.btnLike setLikeInDetailPage:NO animate:NO];
                    [MPTTips showTips:NSLocalizedString(@"reasonAboutCannotHaveRelation",nil) duration:1.0f];
                }
                else if([error.userInfo[@"status"]integerValue] == 406)
                {
                    [self unlikeHandleSingle:NO];

                    [strongSelf.enputView updateLikeStatus:NO andPraisedNumber:strongSelf.channelModel.stat_lcnt animate:NO];
                    [strongSelf.detailHeadView.viewDetailAction.btnLike setLikeInDetailPage:NO animate:NO];
                    [MPTTips showTips:NSLocalizedString(@"peopleAlreadyExit",nil) duration:1.0f];
                }
                else
                {
                    
                }
            }];
        }
    }
}

- (void)__unlike
{
    [self.enputView updateLikeStatus:NO andPraisedNumber:self.channelModel.stat_lcnt animate:YES];
    [self.detailHeadView.viewDetailAction.btnLike setTitle:self.enputView.likeBtnLbl.text forState:UIControlStateNormal];
    [self.detailHeadView.viewDetailAction.btnLike setLikeInDetailPage:NO animate:YES];
    
    if (![MPTLoginApp isLogin])
    {
        //先判断是否已经赞过
        self.enputView.likeButton.enabled = YES;
        self.detailHeadView.viewDetailAction.btnLike.enabled = YES;
        if ([_unlogin.totalLoveVideoScids containsObject:self.channelModel.scid])
        {
            //取消赞
            [_unlogin removeLoveVideoScid:self.channelModel.scid];
            [_unlogin removeLoves];
            
            if (self.player)
            {
                //----addByDong
                [self.player syncLikeState:NO];
            }
            self.channelModel.stat_lcnt --;
            self.channelModel.selfmark = 0;
            self.originalModel.stat_lcnt = self.channelModel.stat_lcnt;
            self.originalModel.selfmark = self.channelModel.selfmark;
            [self originalModelChanged:nil];
            [self.enputView updateLikeStatus:NO andPraisedNumber:self.channelModel.stat_lcnt animate:NO];
            [self.detailHeadView.viewDetailAction.btnLike setTitle:self.enputView.likeBtnLbl.text forState:UIControlStateNormal];
            [self.detailHeadView.viewDetailAction.btnLike setLikeInDetailPage:NO animate:NO];
            [self postChannalModelLikeStateChangeNotification];
            [self postUnlikeNotification];
        }
        else
        {
            NSLog(@"要赞");
        }
    }
    else
    {
        self.hadAdmired = NO;
        self.hadOverAdmired = NO;

        [self unlikeHandleSingle:NO];
        
        __weak typeof(self) weakSelf = self;
        MPTHttpClient *httpClient = [MPTHttpClient sharedMPHTTPClient];
        [httpClient updateDeleteVideoLikeScid:self.scid
                                    contentID:self.channelModel.contentId
                                 impressionID:self.channelModel.impressionId
                                      success:^(NSURLSessionDataTask *task, NSDictionary *responseObject)
         {
            __strong typeof(weakSelf)strongSelf = weakSelf;
            if (strongSelf)
            {
                if([responseObject[@"status"] integerValue] == 200)
                {
                    
                }
            }
        }
                                      failure:^(NSURLSessionDataTask *task, NSError *error)
        {
            
        }];
    }
}


#pragma mark - ******************************************* 基类方法(一般发生在重写函数) ****************


#pragma mark - ******************************************* Touch Event ***********************

/// 滑动区域计算
- (void)panGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint curPoint = [gestureRecognizer translationInView:self.view];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        [self changeSelfViewFrameWithy:curPoint.y gestureRecognizer:gestureRecognizer];
        [gestureRecognizer setTranslation:CGPointZero inView:self.view];
    }
    else /// 停止滑动
    {
        [self stopSelfViewFrameWithPanGensture:gestureRecognizer];
    }
}

/**
 TODO: 返回按钮点击事件的响应函数

 @param sender 被点击的按钮
 */
- (void)btnClickBack:(UIButton *)aSender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)playerPlayOrPause:(UITapGestureRecognizer *)tap
{
    
}

- (void)doubletap:(UITapGestureRecognizer *)tap
{
    NSLog(@"************需要双击点赞************");
}

- (void)goToBack
{
    MPFVideoPlayerManagerInstance.superVideoPlayer.isDetailPage = NO;
    // 还原视频大小
    [self.playerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(MPT_ScreenW*9/16.0f);
    }];
    [self.contentView layoutIfNeeded];
    
    // 还原视频位置
    [MPFDetailPushManager restoreAnimationWithdetailViewController:self];
    if (self.navigationController &&
        [self.navigationController.viewControllers indexOfObject:self]==0)
    {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        BOOL animation = self.animationParaDic && self.animationParaDic[@"animation"] && self.animationParaDic[@"imageView"];
        
        [self.navigationController popViewControllerAnimated:!animation];
    }
}

-(void)reportVideo
{
    [self stopTimeDown];
    [MPSAppStatisticsSingle shareButtonClick:self.channelModel.scid contentType:@"1"
                                    uniqueID:self.channelModel.contentId
                                impressionID:self.channelModel.impressionId];
    [self.view endEditing:YES];
    
    if (self.courseView)
    {
        [self.courseView removeFromSuperview];
    }
    
    if (!self.channelModel)
    {
        return;
    }
    if (self.player && self.player.vmplayer.player.player.status == AVPlayerStatusReadyToPlay)
    {
//        [self.player pause];
    }
    MPFVideoPlayerManagerInstance.superVideoPlayer.isAfterBufferPlayStatus = NO;
    // 展示举报面板
    [self shareWithReportOrDelete];
}


#pragma mark - ******************************************* 私有方法 **********************************

/// 手势改变self坐标
- (void)changeSelfViewFrameWithy:(CGFloat)y gestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer
{
    _tableView.scrollEnabled = NO;
    CGFloat fltY = y + self.playerView.height;
    CGPoint velocity = [gestureRecognizer velocityInView:gestureRecognizer.view];

    if (fltY < (MPT_ScreenW*9/16.0f) && self.playerView.y <=0)
    {
        return;
    }
    
    if (self.channelModel &&
        self.channelModel.ext_h >0 &&
        self.channelModel.ext_w >0 &&
        (self.channelModel.ext_w /self.channelModel.ext_h > 1.77))
    {
        [self.playerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo((MPT_ScreenW*9/16.0f));
        }];
        [self.contentView layoutIfNeeded];
        return;
    }
    
    if (self.playerView.y > 0  && velocity.y <0)
    {
        [self.playerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(MPT_ScreenW);
        }];
    }
    else
    {
        [self.playerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(fltY);
        }];
    }

    if (self.playerView.height >= MPT_ScreenW && velocity.y >0)
    {
        _tableView.scrollEnabled = NO;
        [self.playerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(MPT_ScreenW);
        }];
    }
    else if(self.playerView.height <(MPT_ScreenW*9/16.0f) && velocity.y <0)
    {
        _tableView.scrollEnabled = YES;
        [self.playerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo((MPT_ScreenW*9/16.0f));
        }];
    }
    else
    {

    }
    [self.contentView layoutIfNeeded];

}
/// 手势结束，恢复self坐标
- (void)stopSelfViewFrameWithPanGensture:(UIPanGestureRecognizer *)pan
{
    CGPoint velocity = [pan velocityInView:pan.view];
    

    if (velocity.y <1)
    {
        _tableView.scrollEnabled = YES;

        [self.playerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.height.mas_equalTo((MPT_ScreenW*9/16.0f));
        }];

    }
    else
    {
        CGFloat fltH = MPT_ScreenW;
        if (self.channelModel &&
            self.channelModel.ext_h >0 &&
            self.channelModel.ext_w >0 &&
            (self.channelModel.ext_w /self.channelModel.ext_h) > 1.77)
        {
            fltH = (MPT_ScreenW*9/16.0f);
        }
        _tableView.scrollEnabled = NO;
        [self.playerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.height.mas_equalTo(fltH);
        }];
    }
    
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         [self.contentView layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         
                     }];
}

- (void)unlikeHandleSingle:(BOOL)single
{
    if (single)
    {
        //改变3处赞状态
        if (self.player)
        {
            //-------------------------addByDong---------
            [self.player syncLikeState:YES];
        }
        
        self.isJustHandelLike = YES;
        self.NotshowNoNetworkTip = YES;
        self.channelModel.stat_lcnt = 1;
        self.channelModel.selfmark = 6;
        self.channelModel.likeList = @[[MPTLoginApp loginUser]];
        self.hadAdmired = YES;
        //赞操作成功之后同步赞状态
        self.channelModel.selfmark = 6;
        self.originalModel.stat_lcnt = 1;
        self.originalModel.selfmark = 6;
        [self postChannalModelLikeStateChangeNotification];
        [self postLikeNotification];
        
        [self.enputView updateLikeStatus:YES andPraisedNumber:self.channelModel.stat_lcnt animate:NO];
        [self.detailHeadView.viewDetailAction.btnLike setLikeInDetailPage:YES animate:NO];
    }
    else
    {
        if (self.player)
        {
            // -----------------addByDong-------
            [self.player syncLikeState:NO];
        }
        
        //取消赞成功之后的赞同步
        MPFVideoPlayerManagerInstance.superVideoPlayer.favorited = 2;
        self.channelModel.selfmark = 0;
        self.channelModel.stat_lcnt --;
        self.originalModel.stat_lcnt = self.channelModel.stat_lcnt;
        self.originalModel.selfmark = self.channelModel.selfmark;
        [self postUnlikeNotification];
        [self postChannalModelLikeStateChangeNotification];
        self.enputView.likeButton.enabled = YES;
        self.detailHeadView.viewDetailAction.btnLike.enabled = YES;
        [self.enputView updateLikeStatus:NO andPraisedNumber:self.channelModel.stat_lcnt animate:NO];
        [self.detailHeadView.viewDetailAction.btnLike setTitle:self.enputView.likeBtnLbl.text forState:UIControlStateNormal];
        [self.detailHeadView.viewDetailAction.btnLike setLikeInDetailPage:NO animate:NO];
    }
    
    [self originalModelChanged:nil];
}

- (void)likeHandleSingle:(BOOL)single
{
    if (single)
    {
        //改变3处赞状态
        if (self.player)
        {
            //-------------------------addByDong---------
            [self.player syncLikeState:YES];
        }
        
        self.isJustHandelLike = YES;
        self.NotshowNoNetworkTip = YES;
        self.channelModel.stat_lcnt = 1;
        self.channelModel.selfmark = 6;
        self.channelModel.likeList = @[[MPTLoginApp loginUser]];
        self.hadAdmired = YES;
        //赞操作成功之后同步赞状态
        self.channelModel.selfmark = 6;
        self.originalModel.stat_lcnt = 1;
        self.originalModel.selfmark = 6;
        [self postChannalModelLikeStateChangeNotification];
        [self postLikeNotification];
        [self.enputView updateLikeStatus:YES andPraisedNumber:self.channelModel.stat_lcnt animate:NO];
        [self.detailHeadView.viewDetailAction.btnLike setLikeInDetailPage:YES animate:NO];
        [self.detailHeadView.viewDetailAction.btnLike setTitle:self.enputView.likeBtnLbl.text forState:UIControlStateNormal];
        
    }
    else
    {
        if (self.player)
        {
            [self.player syncLikeState:YES];
        }
        
        MPFVideoPlayerManagerInstance.superVideoPlayer.favorited = 1;
        self.channelModel.stat_lcnt ++;
        //赞操作成功之后同步赞状态
        self.channelModel.selfmark = 6;
        self.originalModel.stat_lcnt = self.channelModel.stat_lcnt;
        self.originalModel.selfmark = 6;
        [self postChannalModelLikeStateChangeNotification];
        [self postLikeNotification];
        [self.enputView updateLikeStatus:YES andPraisedNumber:self.channelModel.stat_lcnt animate:NO];
        [self.detailHeadView.viewDetailAction.btnLike setLikeInDetailPage:YES animate:NO];
        self.enputView.likeButton.enabled = YES;
        self.detailHeadView.viewDetailAction.btnLike.enabled = YES;
        [self.detailHeadView.viewDetailAction.btnLike setTitle:self.enputView.likeBtnLbl.text forState:UIControlStateNormal];
    }
    
    [self originalModelChanged:nil];
}

- (void)isReqOverForVideoInfo_Comment_Relation
{
    if(self.boolReqRelationOver &&
       self.boolReqCommentOver &&
       self.boolReqVideoInfoOver)
    {
        // 请求全部完成
        [self loadingViewHidden:YES fail:!self.isReqSuccessForVideoInfo];
        
        if(!self.isFromComment)
        {
            return ;
        }
        
        [self changeTableViewOffset];
    }
}

- (void)changeTableViewOffset
{
    if (_commentArray.count > 0)
    {
        NSIndexPath * dayOne = [NSIndexPath indexPathForRow:0 inSection:1];
        [self.tableView scrollToRowAtIndexPath:dayOne atScrollPosition:UITableViewScrollPositionTop animated:NO];
        
        if (self.relationDataSource.dataArray.count != 0)
        {
            [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y - 80) animated:NO];
        }
        else
        {
            [self.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
        }
    }
}

//TODO:未登录的时候的点赞状态
-(void)unLoginLikeStatue
{
    _unlogin = [MPTUnloginEvent sharedInstance];
    
    if (![MPTLoginApp isLogin])
    {
        if ([[MPTUnloginEvent sharedInstance].totalLoveVideoScids containsObject:self.channelModel.scid])
        {
            [self.enputView updateLikeStatus:YES
                            andPraisedNumber:(self.channelModel.stat_lcnt +1) animate:YES];
        }
    }
    
    self.isJustHandelLike = NO;
    self.isAllScreenNeed = NO;
}

//TODO:关注按钮的状态
-(void)initFollowedStatue
{
    if (self.channelModel)
    {
        [self.detailHeadView loadWithModel:self.channelModel
                             playSuperView:self.playerView
                             withTableView:self.tableView superV:self];
    }
    
    self.isJustHandelLike = NO;
    self.isAllScreenNeed = NO;
}

//TODO:originalModel的回调
- (void)originalModelChanged:(id)userInfo
{
    if (self.originalModel && [self.originalModel isKindOfClass:[MPTChannelModel class]])
    {
        if (self.channelModel && ![self.channelModel.scid isEqualToString:self.originalModel.scid])
        {
            return;
        }
        
        if (self.isReloadingAllData)
        {
            return;
        }
        
        if (self.originalModel.propertyDidBeModified)
        {
            self.originalModel.propertyDidBeModified(nil, nil);
        }
    }
}

-(void)initPlayerBackGroundImageView
{
    if (self.channelModel && self.thumb)
    {
        [self.thumb sd_setImageWithURL:[NSURL URLWithString:self.channelModel.videoImage]
                      placeholderImage:[UIImage imageNamed:@"detailVideoDefautimage"]];
    }
}

- (void)initialSomeData
{
    self.view.backgroundColor = [UIColor MPTForwardBackgroundColor];
    self.likeFromDoubleTap = NO;
    
    if (_isComment)
    {
        if (self.player) [self.player toggleViewStyle:1];
    }
    else
    {
        if (self.player)
        {
            [self.player toggleViewStyle:0];
        }
    }
    
    self.commentArray = [@[] mutableCopy];
    [self loadingViewHidden:NO fail:NO];
    self.enputView.hidden = NO;
    [self loadChannelInfoWithScid:self.scid withReloadSuccess:nil];
    [self reolationData];
}

- (void)reloadAllData
{
    self.isReloadingAllData = YES;
    self.containter = nil;
    self.viewFooterInSection = nil;
    _intPage = 1;
    [self.detailHeadView setVideoDescHidden:YES];
    
    [self loadingViewHidden:NO fail:NO];
    self.enputView.hidden = NO;
    self.hadAdmired = NO;
    self.boolReqVideoInfoOver = NO;
    self.boolReqRelationOver = NO;
    self.boolReqCommentOver = NO;
    self.isReqSuccessForVideoInfo = NO;
    
    self.isFromComment = NO;
    
    self.commentArray = [@[] mutableCopy];
    self.commentNumber = 0;
    
    if (isValidNSString(_currentImageURl))
    {
        [self.thumb sd_setImageWithURL:[NSURL URLWithString:_currentImageURl]];
        _currentImageURl = nil;
    }
    
    @weakify(self);
    [self loadChannelInfoWithScid:self.scid withReloadSuccess:^{
        @strongify(self);
        [self addPlayDetail];
        
//        MPFVideoPlayerManagerInstance.superVideoPlayer.viewCommented = 1;
    }];
    
    [self reolationData];
}

- (void)fectchNewestCommentData
{
//    //本地失败的评论
//    NSArray *array = [self getLocalCommentWitScid:self.channelModel.scid];
//    addValidArrayForArray(self.localCommentArray, array);
//    [self.dataSource fectchNewestData];
}

- (void)requestMoreComments
{
    _intPage++;
    [self commentData];
}

- (void)loadChannelInfoSuccess:(id)data
{
    if ([data[@"status"] integerValue]==200)
    {
        if (self.isReplyComment)
        {
            self.isReplyComment = NO;
        }
        
        NSError *error = nil;
        MPTChannelModel *channel = [MPTChannelModel fromJSONDictionary:data[@"result"] error:&error];
        if (self.originalModel)
        {
            channel.sevtid = self.originalModel.sevtid;
            channel.personalPageChannelType = self.originalModel.personalPageChannelType;
        }
        
        self.channelModel = channel;
        MPFVideoPlayerManagerInstance.superVideoPlayer.detailRelationCurrentModel = channel;
        [MPFVideoPlayerManagerInstance.superVideoPlayer.overlayView updateShowWindowConstraints:self.channelModel];
        MPFVideoPlayerManagerInstance.superVideoPlayer.playChannelModel = channel;
        channel.owener.relation = channel.relation;
        
        if (self.isShare)
        {
            self.isShare = NO;
            
            if (self.isRewardVideo&&[self.channelModel.reward_info[@"status"] integerValue]==0)
            {
                MPTRewardShareModel *shareModel = [MPTRewardShareModel new];
                shareModel.srwid = self.channelModel.reward_info[@"srwid"];
                shareModel.publisherSuid = self.channelModel.rewardOwner.suid;
                shareModel.shareSuid = [MPTLoginApp loginUser].suid;
                shareModel.money = self.channelModel.reward_info[@"price"];
                shareModel.nick = self.channelModel.rewardOwner.nick;
                shareModel.desc = self.channelModel.ext_t;
                shareModel.videoOwnerNick = self.channelModel.owener.nick;
                shareModel.videoOwnerSuid = self.channelModel.owener.suid;
                shareModel.videoCnt = self.channelModel.reward_info[@"channelCnt"];
                shareModel.videoUrl = [NSString stringWithFormat:@"http://www.miaopai.com/show/%@.html",self.channelModel.scid];
                shareModel.thumbImage = self.channelModel.videoImage;
                shareModel.scid = self.scid;
                shareModel.topics = self.channelModel.topicinfo;
                shareModel.desForVideoReward = [MPFSharePlan shareTitleForFT:self.channelModel.ext_ft t:self.channelModel.ext_t];
                MPFSharePlan *plan = [[MPFSharePlan alloc] initWithReward:shareModel];
                plan.delegate = self;
                [plan showShareViewOnKeyWindow];
            }
            else if (self.channelModel)
            {
                MPFSharePlan *plan = [[MPFSharePlan alloc] initWithChannel:self.channelModel];
                plan.delegate = self;
                [plan showShareViewOnKeyWindow];
            }
        }
        
        //更新player的数据
        MPTPlayerVideoModel *model = [MPTPlayerVideoModel new];
        model.scid = channel.scid;
        model.videoType = self.channelModel.liveStatus;
        model.createTime = self.channelModel.ext2_createTime.integerValue;
        model.duration = self.channelModel.ext_length.floatValue;
        model.live_ucnt = self.channelModel.stat_ucnt;
        model.live_length = self.channelModel.ext2_length;
        if (self.channelModel)
        {
            model.videoType = self.channelModel.liveStatus;
            model.createTime = self.channelModel.ext2_createTime.integerValue;
            model.duration = self.channelModel.ext_length.floatValue;
            
            if (isValidNSString(self.channelModel.adVideoURL))
            {
                model.advertisingVideoURL = [NSURL URLWithString:self.channelModel.adVideoURL];
            }
        }
        
        //神策统计 -->
        self.player.superPageID = _pvID;
        self.player.playerViewMode = self.playerMode;
        [self commentData];
        if (MPFVideoPlayerManagerInstance.superVideoPlayer.isA == YES)
        {
            if (self.channelModel &&
                self.channelModel.ext_h >0 &&
                self.channelModel.ext_w >0 &&
                self.channelModel.ext_h >= self.channelModel.ext_w)
            {
                self.tableView.scrollEnabled = NO;
                /// 更新播放器大小
                [self.playerView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(MPT_ScreenW);
                }];
            }
            else
            {
                self.tableView.scrollEnabled = NO;
                CGFloat fltH = (MPT_ScreenW*9/16.0f);
                if (self.channelModel&&
                    self.channelModel.ext_h >0 &&
                    self.channelModel.ext_w >0
                    )
                {
                    fltH = (MPT_ScreenW / self.channelModel.ext_w *self.channelModel.ext_h);
                }
                
                if ((MPT_ScreenW*9/16.0f) > fltH)
                {
                    self.tableView.scrollEnabled = YES;
                    fltH = (MPT_ScreenW*9/16.0f);
                }
                /// 更新播放器大小
                [self.playerView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(fltH);
                }];
            }
            [self.contentView layoutIfNeeded];
        }
        
        /// 检查一次是不是消息盒子过来的
        [self goToCommentTwoViewDetailIsFromeXiaoXiHeZi];
        
        
        self.isRewardVideo = isValidNSString(channel.reward_info[@"srwid"]);
        
        if (!error)
        {
            if (![MPTLoginApp isLogin])
            {
                if ([[MPTUnloginEvent sharedInstance].totalLoveVideoScids containsObject:self.channelModel.scid])
                {
                    channel.stat_lcnt++;
                    [self.enputView updateLikeStatus_NoAnimation:YES andPraisedNumber:channel.stat_lcnt];
                }
                else
                {
                    [self.enputView updateLikeStatus_NoAnimation:NO andPraisedNumber:self.channelModel.stat_lcnt];
                }
            }
            else
            {
                [self.enputView updateLikeStatus_NoAnimation:self.channelModel.selfmark == 6 andPraisedNumber:self.channelModel.stat_lcnt];
            }
            
            self.channelModel = channel;
            [MPFVideoPlayerManagerInstance.superVideoPlayer.overlayView updateShowWindowConstraints:self.channelModel];
            
            [self.detailHeadView loadWithModel:channel playSuperView:self.playerView  withTableView:self.tableView superV:self];
            if (channel.selfmark==6)
            {
                self.hadAdmired = YES;
                if (self.player)
                {
                    [self.player syncLikeState:YES];
                }
            }
            else{
                if (self.player)
                {
                    [self.player syncLikeState:NO];
                }
            }
            
            if (self.isJustHandelLike)
            {
                self.isJustHandelLike = NO;
                
                return;
            }
            
            if (self.thumb &&
                isValidNSString(data[@"result"][@"pic"][@"base"]) &&
                isValidNSString(data[@"result"][@"pic"][@"m"]))
            {
                [self.thumb sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",data[@"result"][@"pic"][@"base"],data[@"result"][@"pic"][@"m"]]] placeholderImage:[UIImage imageNamed:@"detailVideoDefautimage"]];
            }
            
            self.channelModel.owener.relation = channel.relation;
            if (self.channelModel.ext_status == -10)
            {
                if (isAppear)
                {
                    [self.navigationController popViewControllerAnimated:YES];
                    showAlert(NSLocalizedString(@"TheVideoDoesNotExist",nil));
                }
                else
                {
                    double delayInSeconds = 0.5;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds*NSEC_PER_SEC);
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        [MPTTips showTips:NSLocalizedString(@"TheVideoDoesNotExist",nil) duration:1.0];
                        
                        [self goToBack];
                    });
                }
            }
        }
    }
}

#pragma mark -

- (void)fetchDataFailure:(NSError *)error
{
    // 网络请求错误
}

- (void)removeHintView
{
    if (self.bacView)
    {
        [self.bacView removeFromSuperview];
        self.bacView = nil;
    }
}

//评论发表完跳到最上边
- (void)pullComment
{
    
}

- (void)requestField:(NSError *)error
{
    
}

-(void)addMPTPlayerView
{
    self.player = MPFVideoPlayerManagerInstance.superVideoPlayer;
    self.player.playChannelModel = self.originalModel;
    MPTPlayerVideoModel *model = [MPTPlayerVideoModel new];
    self.player.delegate = self;
    model.scid = self.scid;
    self.player.detailPlayVideoModel = model;
    self.player.playChannelModel = self.channelModel;
    self.player.frameView = self.playerView;
    if (isValidValue(self.channelModel))
    {
        NSString *identity = self.channelModel.scid;
        NSString *url = isValidNSString(self.channelModel.stream_base) ? self.channelModel.stream_base : @"";
        CGFloat d = [self.channelModel.ext_length floatValue];
        NSString * sign = self.channelModel.stream_sign;
        
        [_player refreshUI];
        self.player.videoInfo =
        @{
          @"identity": identity,
          @"url": url,
          @"duration": @(d),
          @"isShowSuggess": @(1),
          @"disablePlayEndNotifation":@"yes",
          @"sign":sign
          
          };
        
        [MPFVideoPlayerManagerInstance.superVideoPlayer  refreshBeforeStartPlayFrame];

        if (![self.player needManualClick] && [MPFVideoPlayerManagerInstance.superVideoPlayer isNewWorkSatusPlay])
        {
            MPFVideoPlayerManagerInstance.superVideoPlayer.isAfterBufferPlayStatus = YES;
            [self.player autoPlayWithIdentity:identity andURL:url andDuration:d];
            [MPFVideoPlayerManagerInstance.superVideoPlayer.overlayView updateShowWindowConstraints:self.channelModel];

        }
        else
        {
            [MPFVideoPlayerManagerInstance.superVideoPlayer playHide:NO];
            [MPFVideoPlayerManagerInstance.superVideoPlayer stopOutside];
            MPFVideoPlayerManagerInstance.superVideoPlayer.overlayView.middlePlayControlView.hidden = NO;
            MPFVideoPlayerManagerInstance.superVideoPlayer.overlayView.middlePlayControlView.btnPlay.selected = NO;
            _player.overlayView.playButton.hidden = NO;
            _player.overlayView.playButton.selected = NO;
            [_player.overlayView stopLoadingAnimation:YES];
            [_player.smallPlayerControlView isSmallStopLoadingAnimation:YES];
        }
    }
    else
    {
        self.player.videoInfo =
        @{@"identity": self.scid,
          @"disablePlayEndNotifation":@"yes",
          };
        [MPFVideoPlayerManagerInstance.superVideoPlayer  refreshBeforeStartPlayFrame];

        if (![self.player needManualClick] &&  [MPFVideoPlayerManagerInstance.superVideoPlayer isNewWorkSatusPlay])
        {
            MPFVideoPlayerManagerInstance.superVideoPlayer.isAfterBufferPlayStatus = YES;
            [self.player autoPlayWithIdentity:self.scid   andURL:nil andDuration:self.videoDuration];
            [MPFVideoPlayerManagerInstance.superVideoPlayer.overlayView updateShowWindowConstraints:self.channelModel];
        }
        else
        {
            [MPFVideoPlayerManagerInstance.superVideoPlayer playHide:NO];
            [MPFVideoPlayerManagerInstance.superVideoPlayer stopOutside];
            MPFVideoPlayerManagerInstance.superVideoPlayer.overlayView.middlePlayControlView.hidden = NO;
            MPFVideoPlayerManagerInstance.superVideoPlayer.overlayView.middlePlayControlView.btnPlay.selected = NO;
            _player.overlayView.playButton.hidden = NO;
            _player.overlayView.playButton.selected = NO;
            [_player.overlayView stopLoadingAnimation:YES];
            [_player.smallPlayerControlView isSmallStopLoadingAnimation:YES];
        }
    }
    
    [_player updateConstraints];
    [_player setNeedsUpdateConstraints];
    [_player updateConstraintsIfNeeded];
    [_player layoutIfNeeded];
    self.player.overlayView.playerEndView.model = model;
    [self.player.overlayView.playerEndView getSuggesst];
    [self.playerView addSubview:self.player];
    [self.contentView addSubview:self.enputView];
}

-(void)faillAddPlayDetail
{
    self.player = MPFVideoPlayerManagerInstance.superVideoPlayer;
    self.player.delegate = self;
    [_player refreshUI];
    MPFVideoPlayerManagerInstance.superVideoPlayer.isAfterBufferPlayStatus = YES;
    self.player.videoInfo =
    @{
      @"identity":TP_Str_Protect(self.scid),
      @"isShowSuggess": @(1),
      @"disablePlayEndNotifation":@"yes",
      };
    [MPFVideoPlayerManagerInstance.superVideoPlayer  refreshBeforeStartPlayFrame];

    [self.player autoPlayWithIdentity:self.scid   andURL:nil andDuration:self.videoDuration];
    [MPFVideoPlayerManagerInstance.superVideoPlayer.overlayView updateShowWindowConstraints:self.channelModel];
    [self.player.overlayView.playerEndView getSuggesst];
    [self.contentView addSubview:self.enputView];
}

-(void)addPlayDetail
{
    self.player = MPFVideoPlayerManagerInstance.superVideoPlayer;
    if (MPFVideoPlayerManagerInstance.superVideoPlayer.isScreen == NO)
    {
        self.player.backgroundColor = [UIColor clearColor];
    }
    
    self.player.playChannelModel = self.originalModel;
    MPTPlayerVideoModel *model = [MPTPlayerVideoModel new];
    self.player.delegate = self;
    model.scid = self.scid;
    self.player.detailPlayVideoModel = model;
    self.player.playChannelModel = self.channelModel;
    self.player.frameView = self.playerView;
    if (isValidValue(self.channelModel))
    {
        NSString *identity = self.channelModel.scid;
        NSString *url = isValidNSString(self.channelModel.stream_base) ? self.channelModel.stream_base : @"";
        CGFloat d = [self.channelModel.ext_length floatValue];
        NSString * sign = self.channelModel.stream_sign;
        [_player refreshUI];
        self.player.videoInfo =
        @{
          @"identity": identity,
          @"url": url,
          @"duration": @(d),
          @"isShowSuggess": @(1),
          @"disablePlayEndNotifation":@"yes",
          @"sign":sign
          
          };
        MPFVideoPlayerManagerInstance.superVideoPlayer.isAfterBufferPlayStatus = YES;
        [MPFVideoPlayerManagerInstance.superVideoPlayer  refreshBeforeStartPlayFrame];

        if ([MPFVideoPlayerManagerInstance.superVideoPlayer isNewWorkSatusPlay])
        {
            [self.player autoPlayWithIdentity:identity andURL:url andDuration:d];

        }else
        {
            [MPFVideoPlayerManagerInstance.superVideoPlayer stopOutside];
            [MPFVideoPlayerManagerInstance.superVideoPlayer playHide:NO];
            if (MPFVideoPlayerManagerInstance.superVideoPlayer.isScreen == YES)
            {
                MPFVideoPlayerManagerInstance.superVideoPlayer.overlayView.mptRecommandTooView.titleLabel.hidden = NO;
            }else
            {
                MPFVideoPlayerManagerInstance.superVideoPlayer.overlayView.mptRecommandTooView.titleLabel.hidden = YES;
            }
        }
        
        [MPFVideoPlayerManagerInstance.superVideoPlayer.overlayView updateShowWindowConstraints:self.channelModel];
    }
    else
    {
        self.player.videoInfo =
        @{@"identity": self.scid,
          @"disablePlayEndNotifation":@"yes",
          };
        
        [MPFVideoPlayerManagerInstance.superVideoPlayer  refreshBeforeStartPlayFrame];

        if (![self.player needManualClick]&& [MPFVideoPlayerManagerInstance.superVideoPlayer isNewWorkSatusPlay])
        {
            
            MPFVideoPlayerManagerInstance.superVideoPlayer.isAfterBufferPlayStatus = YES;
            [self.player autoPlayWithIdentity:self.scid   andURL:nil andDuration:self.videoDuration];
            [MPFVideoPlayerManagerInstance.superVideoPlayer.overlayView updateShowWindowConstraints:self.channelModel];
        }
        else
        {
            [MPFVideoPlayerManagerInstance.superVideoPlayer playHide:NO];
            [MPFVideoPlayerManagerInstance.superVideoPlayer stopOutside];
            if (MPFVideoPlayerManagerInstance.superVideoPlayer.isScreen == YES) {
                MPFVideoPlayerManagerInstance.superVideoPlayer.overlayView.mptRecommandTooView.titleLabel.hidden = NO;
            }else
            {
                MPFVideoPlayerManagerInstance.superVideoPlayer.overlayView.mptRecommandTooView.titleLabel.hidden = YES;
            }
            MPFVideoPlayerManagerInstance.superVideoPlayer.overlayView.middlePlayControlView.hidden = NO;
            MPFVideoPlayerManagerInstance.superVideoPlayer.overlayView.middlePlayControlView.btnPlay.selected = NO;
            _player.overlayView.playButton.hidden = NO;
            _player.overlayView.playButton.selected = NO;
            [_player.overlayView stopLoadingAnimation:YES];
            [_player.smallPlayerControlView isSmallStopLoadingAnimation:YES];
        }
    }
    self.player.overlayView.playerEndView.model = model;
    [self.player.overlayView.playerEndView getSuggesst];
    [self.contentView addSubview:self.enputView];
}

- (void)addLoadingView
{
    @weakify(self);
    
    self.viewCustomLoading.backgroundColor = [UIColor whiteColor];
    [self.viewCustomLoading showLoadingViewWithImageName:@"mp_loading" shineImageName:@"mp_loading_dark"];
    [self.contentView insertSubview:self.viewCustomLoading aboveSubview:self.enputView];
    
    // 加载失败
    [self.viewLoadError showNonNetViewWithImageName:@"mp_net_error" hintTitle:@"加载失败" buttonTitle:@"加载失败" action:^{
        @strongify(self);
        [self reloadAction];
    }];
    [self.contentView addSubview:self.viewLoadError];
    [self.viewLoadError mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.and.right.and.bottom.equalTo(self.contentView);
        make.top.equalTo(self.playerView.mas_bottom);
    }];
    
    
    [self.viewCustomLoading mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.and.right.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-self.enputView.height);
        make.top.equalTo(self.playerView.mas_bottom);
    }];
}

#pragma mark - handle views

- (void)initialLayoutView
{
    UIView *statusView = [UIView new];
    statusView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:statusView];
    
    [self.view addSubview:self.contentView];
    
    [self.contentView addSubview:self.tableView];
    [self.contentView addSubview:self.playerView];
    
    [self addLoadingView];
    [MPFVideoPlayerManagerInstance.superVideoPlayer refreshUI];
    self.player = MPFVideoPlayerManagerInstance.superVideoPlayer;
    MPTPlayerVideoModel *model = [MPTPlayerVideoModel new];
    model.scid = self.scid;
    self.player.overlayView.playerEndView.model = model;
    [self.player.overlayView.playerEndView getSuggesst];
    
    if (isValidValue(self.channelModel))
    {
        NSString *identity = self.channelModel.scid;
        NSString *url = isValidNSString(self.channelModel.stream_base) ? self.channelModel.stream_base : @"";
        CGFloat d = [self.channelModel.ext_length floatValue];
        NSString * sign = self.channelModel.stream_sign;
        self.player.videoInfo =
        @{@"identity": identity,
          @"url": url,
          @"duration": @(d),
          @"isShowSuggess": @(1),
          @"disablePlayEndNotifation":@"yes",
          @"sign":sign
          };
    }
    else
    {
        self.player.videoInfo =
        @{@"identity": self.scid,
          @"disablePlayEndNotifation":@"yes",
          };
    }
    
    self.player.delegate = self;
    [self.playerView addSubview:self.player];
    [self.contentView addSubview:self.enputView];
    
    [statusView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
        make.height.mas_equalTo(20);
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
        make.height.mas_equalTo(self.view.height);
    }];
    
    if (MPFVideoPlayerManagerInstance.superVideoPlayer.isA == YES) {
        if (self.channelModel &&
            self.channelModel.ext_h >0 &&
            self.channelModel.ext_w >0 &&
            self.channelModel.ext_h >= self.channelModel.ext_w)
        {
            self.tableView.scrollEnabled = NO;
            CGFloat fltH = MPT_ScreenW / self.channelModel.ext_w *self.channelModel.ext_h;
            if (fltH > MPT_ScreenW)
            {
                fltH = MPT_ScreenW;
            }
            
            /// 更新播放器大小
            [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.contentView.mas_top);
                make.centerX.equalTo(self.view);
                make.width.mas_equalTo(MPT_ScreenW);
                make.height.mas_equalTo(fltH);
                make.height.lessThanOrEqualTo(@(MPT_ScreenW));
                make.height.greaterThanOrEqualTo(@(MPT_ScreenW*9/16.0f));
            }];
        }
        else
        {
            self.tableView.scrollEnabled = YES;
            CGFloat fltH = (MPT_ScreenW*9/16.0f);
            if (self.channelModel &&
                self.channelModel.ext_h >0 &&
                self.channelModel.ext_w >0 &&
                (MPT_ScreenW /self.channelModel.ext_w *self.channelModel.ext_h)> fltH)
            {
                self.tableView.scrollEnabled = NO;
                fltH = (MPT_ScreenW / self.channelModel.ext_w *self.channelModel.ext_h);
            }
            /// 更新播放器大小
            [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.contentView.mas_top);
                make.centerX.equalTo(self.view);
                make.width.mas_equalTo(MPT_ScreenW);
                make.height.mas_equalTo(fltH);
                make.height.lessThanOrEqualTo(@(MPT_ScreenW*9/16.0f));
                make.height.greaterThanOrEqualTo(@(MPT_ScreenW*9/16.0f));
            }];
        }
    }
    else
    {
        /// 更新播放器大小
        [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top);
            make.centerX.equalTo(self.view);
            make.width.mas_equalTo(MPT_ScreenW);
            make.height.mas_equalTo(MPT_ScreenW*9/16.0f);
        }];
    }
    
    [self.player mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(self.playerView);
    }];
    
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.playerView.mas_bottom);
        make.leading.equalTo(self.contentView.mas_leading);
        make.trailing.equalTo(self.contentView.mas_trailing);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-50);
    }];
    
    [self.enputView mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
        make.height.mas_equalTo(50);
    }];

    MPFVideoPlayerManagerInstance.superVideoPlayer.contentOffSetY  = self.tableView.contentOffset.y;
    [self.view setNeedsUpdateConstraints];
    [self.view layoutIfNeeded];
}

- (void)setCommentNumber:(NSInteger)commentNumber
{
    _commentNumber = commentNumber;
    
    [self.enputView  updateVideoComment:self.commentNumber];

    if (self.originalModel)
    {
        self.originalModel.stat_ccnt = commentNumber;
    }
    
    [self originalModelChanged:nil];
}

- (void)resignenputView
{
    [self.inputView resign];
}

#pragma mark -

-(void)submitComment:(NSString *)msg
{
    [self.inputView resign];

    /// 判断是否登录
    if (![MPTLoginApp isLogin])
    {
        [JLRoutes routeURL:[NSURL URLWithString:@"/login"]];
        return;
    }
    
    /// 判断是否绑定了手机号
    if (![self judgeHasBindPhoneNumber])
    {
        MPFVideoDetailBindPhoneNumberView *viewPhone = [[MPFVideoDetailBindPhoneNumberView alloc] init];
        [viewPhone show];
        return;
    }
    
    if (!self.channelModel)
    {
        return;
    }
    if(msg.length > 0)
    {
        [self localPublicationCommentWith:msg];
    }
}

#pragma mark -  @ 输入框

- (void)atFriends
{
    logEvent(NSStringFromClass([self class]),@"atFriends",@"");
    
    if (![MPTLoginApp isLogin])
    {
        return;
    }
    
    NSString *string = self.inputView.textViewInput.text;
    self.inputView.textViewInput.text = [NSString stringWithFormat:@"%@@",string];
    inputLocation = [self.inputView.textViewInput selectedRange].location;
    
    [self.inputView resign];
    
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Capture" bundle: nil];
    MPTAtViewController *atView = [board instantiateViewControllerWithIdentifier: @"AtViewController"];
    [atView setValue:self forKey:@"delegate"];
    [self presentViewController:atView animated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}

- (void)selectedFriends:(NSArray *)friends
{
    logEvent(NSStringFromClass([self class]),@"selectedFriends:",@"");
    
    if (friends.count <= 0)
    {
        return;
    }
    
    NSMutableArray *tmp = [NSMutableArray array];
    for (MPTUser *friend in friends)
    {
        [tmp addObject:friend.nick];
    }
    
    NSString *insetText = [NSString stringWithFormat:@"%@ ",[tmp componentsJoinedByString:@" @"]];
    
    NSString *string = self.inputView.textViewInput.text;
    if (inputLocation > string.length)
    {
        self.inputView.textViewInput.text = [NSString
                                        stringWithFormat:@"%@%@", string,
                                        insetText];
    }
    else
    {
        self.inputView.textViewInput.text = [NSString
                                        stringWithFormat:@"%@%@%@", [string substringToIndex:inputLocation],
                                        insetText, [string substringFromIndex:inputLocation]];
    }
    self.inputView.textViewInput.selectedRange = NSMakeRange(self.inputView.textViewInput.text.length, 0);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UITextViewTextDidChangeNotification" object:self.inputView.textViewInput];
    [self.inputView activeIsFormeErJiPinglun:NO];
}

#pragma mark - 本地评论

- (void)localPublicationCommentWith:(NSString *)msg
{
    logEvent(NSStringFromClass([self class]),@"localPublicationCommentWith:",@"");
    
    if (![MPTLoginApp isLogin])
    {
        [JLRoutes routeURL:[NSURL URLWithString:@"/login"]];
        
        return;
    }
    
    self.inputView.textViewInput.text = @"";
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UITextViewTextDidChangeNotification" object:self.inputView.textViewInput];

    /// 个人评论的数据模型
    MPFVideoCommentModel *model = [[MPFVideoCommentModel alloc] init];
    MPFVideoContentModel *modelContent = [[MPFVideoContentModel alloc] init];
    modelContent.scmtId = @"";
    modelContent.content = msg;
    NSDate *dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval time = [dat timeIntervalSince1970]*1000;
    modelContent.createTime = time;
    modelContent.liked = NO;
    modelContent.likeCount = 0;
    modelContent.replyCount = 0;
    modelContent.toUser = [@{} mutableCopy];
    MPTLoginUser *myModel = [MPTLoginApp loginUser];
    MPTUser *user = [[MPTUser alloc] init];
    user.nick = myModel.nick;
    user.org_v = [myModel.org_v integerValue];
    user.v = [myModel.v integerValue];
    user.icon = [NSURL URLWithString:myModel.icon];
    user.suid = myModel.suid;
    user.talent_v = myModel.talent_v;
    modelContent.fromUser = [NSMutableDictionary dictionaryWithDictionary:user.dictionaryValue];
    model.content = modelContent;
    model.replyContent = [NSMutableArray array];
    model.isSendingComment = YES;
    model.isFailComment = NO;
    if ([MPTReachability isNotReachable])
    {
        model.isFailComment = YES;
    }
    // 用户新发表的评论插到最新评论的最上方
    [self.commentArray insertObject:model atIndex:0];
    [self.tableView reloadData];
    
    [self changeTableViewOffset];
    
    [self updateVideoCommentWithScid:self.channelModel.scid andComment:model];
    
    [self.enputView  updateVideoComment:self.commentNumber];
}

- (void)updateCommentNumber
{
    if (self.commentNumberLabel)
    {
        self.commentNumberLabel.text = self.commentNumber>0?[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Message_comment_text",nil),[MPTTool getNumWith:self.commentNumber]]:NSLocalizedString(@"Message_comment_text",nil);
    }
}

//删除本地失败的评论
- (void)deleteLocalCommentWith:(MPFVideoCommentModel *)comment
{
    logEvent(NSStringFromClass([self class]),@"deleteLocalCommentWith:",@"");
    
    if (![MPTLoginApp isLogin])
    {
        return;
    }
}

- (NSArray*)getLocalFriends
{
    NSString *hash = [[NSString stringWithFormat:@"%@%@", [MPTLoginApp loginUser].suid,@"HadAtFriendList"] MD5String];
    NSString *path = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@.data",hash];
    
    return [NSKeyedUnarchiver unarchiveObjectWithFile:path];
}

#pragma mark - commentCellDelegate

- (void)handIconClick:(UIButton *)btn
{
    logEvent(NSStringFromClass([self class]),@"handIconClick:",@"");
#pragma mark - 点击头像的跳转
}

- (void)deleteCommentOperationCommentModel:(MPFVideoCommentModel *)commentItem
{
    NSInteger count = 0;
    self.hadSelected = NO;
    
    for (NSInteger i = 0; i < self.commentArray.count; i++)
    {
        MPFVideoCommentModel* item = self.commentArray[i];
        if (isValidObject(item, [MPFVideoCommentModel class]))
        {
            //如果删除的是发送失败的评论没有scmtid所以需要单独的判断
            if (commentItem.isFailComment)
            {
                [self.commentArray removeObject:commentItem];
                break;
            }
            
            //删除的是已经发送成功的评论,则根据评论的id进行判断
            if ([item.content.scmtId isEqualToString:commentItem.content.scmtId])
            {
                [self.commentArray removeObject:item];
                
                count ++;
                if (count == 2)
                {
                    break;
                }
            }
        }
    }
}


/**
 删除评论请求成功之后移除本地的数据
 
 @param response 删除的网络请求之后的返回 :成功的话是个字典 失败了是nil
 @param brow 评论的行数
 */
- (void)deleteCommentComplete:(NSDictionary *)response indexPath:(NSInteger)brow
{
    //有菊花的话再次隐藏
    [self removeRowByIndexPath:[NSIndexPath indexPathForRow:brow inSection:0]];
}

- (void)removeRowByIndexPath:(NSIndexPath *)indexPath
{
    logEvent(NSStringFromClass([self class]),@"removeRowByIndexPath:",@"");
    @try{
        if (indexPath.row < self.commentArray.count)
        {
            [self deleteCommentOperationCommentModel:getValidObjectFromArray(self.commentArray, indexPath.row)];
            [self.tableView reloadData];
        }
    }
    @catch (NSException *exception) {
        [MPTTips showTips:NSLocalizedString(@"DeleteCommentsFailed",nil) duration:1.0];
    }
    @finally {
        
    }
}


#pragma mark - fullScreenPlayerViewController

- (void)presentAVPlayerViewController:(NSURL *)videoURL player:(AVPlayer *)avplayer
{
    AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc]init];
    if (avplayer)
    {
        playerViewController.player = avplayer;
    }
    else
    {
        return;
    }
    
    [playerViewController.player play];
    @weakify(playerViewController)
    [self presentViewController:playerViewController animated:YES completion:^{
        @strongify(playerViewController)
        [playerViewController.player play];
    }];
}

-(void)postUnlikeNotification
{
    if (self.originalModel)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"unLikeStateChange"
                                                            object:self
                                                          userInfo:@{@"kMPTChannalModelLikeStateChangedUserInfoKey":
                                                                         self.originalModel}];
    }
}

-(void)postLikeNotification
{
    NSDictionary *userInfo = nil;
    if (self.originalModel != nil)
    {
        userInfo = @{@"kMPTChannalModelLikeStateChangedUserInfoKey":
                         self.originalModel};
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"likeStateChange"
                                                        object:self
                                                      userInfo:userInfo];
}

// 喜欢状态改变,发布通知让首页的赞的数量改变
- (void)postChannalModelLikeStateChangeNotification
{
    NSDictionary *userInfo = nil;
    if (self.originalModel != nil)
    {
        userInfo = @{@"kMPTChannalModelLikeStateChangedUserInfoKey":
                         self.originalModel};
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kMPTChannalModelLikeStateChaged
                                                        object:nil
                                                      userInfo:userInfo];
}

- (void)videoDetailOpen
{
    [self stopTimeDown];
}

/// 暂停倒计时功能
- (void)stopTimeDown
{
    // 暂停播放器的倒计时功能
    if(MPFVideoPlayerManagerInstance.superVideoPlayer.isCountDown)
    {
        [MPFVideoPlayerManagerInstance.superVideoPlayer cancelCountDownPlayNextVideo];
    }
}

#pragma mark- 评论输入条的各个事件的处理

- (void)commentInptBarShareAction
{
    [self stopTimeDown];

    [MPSAppStatisticsSingle shareButtonClick:self.channelModel.scid
                                 contentType:@"1"
                                    uniqueID:self.channelModel.contentId
                                impressionID:self.channelModel.impressionId];
    if (self.isRewardVideo&&[self.channelModel.reward_info[@"status"] integerValue]==0)
    {
        MPTRewardShareModel *shareModel = [MPTRewardShareModel new];
        shareModel.srwid = self.channelModel.reward_info[@"srwid"];
        shareModel.publisherSuid = self.channelModel.rewardOwner.suid;
        shareModel.shareSuid = [MPTLoginApp loginUser].suid;
        shareModel.money = self.channelModel.reward_info[@"price"];
        shareModel.nick = self.channelModel.rewardOwner.nick;
        shareModel.desc = self.channelModel.ext_t;
        shareModel.videoOwnerNick = self.channelModel.owener.nick;
        shareModel.videoOwnerSuid = self.channelModel.owener.suid;
        shareModel.videoCnt = self.channelModel.reward_info[@"channelCnt"];
        shareModel.videoUrl = [NSString stringWithFormat:@"http://www.miaopai.com/show/%@.html",self.channelModel.scid];
        shareModel.thumbImage = self.channelModel.videoImage;
        shareModel.scid = self.scid;
        shareModel.topics = self.channelModel.topicinfo;
        shareModel.desForVideoReward = [MPFSharePlan shareTitleForFT:self.channelModel.ext_ft t:self.channelModel.ext_t];
        MPFSharePlan *plan = [[MPFSharePlan alloc] initWithReward:shareModel];
        plan.delegate = self;
        [plan showShareViewOnKeyWindow];
    }
    else if (self.channelModel)
    {
        MPFSharePlan *plan = [[MPFSharePlan alloc] initWithChannel:self.channelModel];
        plan.delegate = self;
        [plan showShareViewOnKeyWindow];
    }
}

- (void)commentInputBarLikeAction:(BOOL)like
{
    [self stopTimeDown];
    //双击点赞的提示
    if (like)
    {
        [self __like];
        if (![MPTTool guide_black_single_row_like_has_shown])
        {
            [MPTTool set_guide_black_singe_row_like_shown:YES];
            [MPTTool screen_guide_with_imageName:@"common_toast_n_doubleclick" didDismiss:nil];
        }
        [MPUmeng event:@"detail_good" attributes:@{@"type":@"bottom"}];
    }
    else
    {
        [self __unlike];
    }
}

- (void)reloadAction
{
    [self reloadAllData];
}

- (void)loadingViewHidden:(BOOL)hidden fail:(BOOL)fail
{
    if (fail)
    {
        self.viewLoadError.hidden = !fail;
        self.viewCustomLoading.hidden = fail;
        self.enputView.hidden = fail;
    }
    else
    {
        if (hidden)
        {
            self.viewCustomLoading.hidden = hidden;
            self.viewLoadError.hidden = hidden;
            self.enputView.hidden = !hidden;
            
            [_rotateLoadingView stopAnimating];
        }
        else
        {
            self.viewCustomLoading.hidden = hidden;
            self.viewLoadError.hidden = !hidden;
            self.enputView.hidden = !hidden;
            
            [_rotateLoadingView startAnimating];
        }
    }
    
    self.enputView.userInteractionEnabled = hidden;
}

- (BOOL)judgeHasBindPhoneNumber
{
    /// 绑定手机号逻辑
    MPTLoginUser *loginUser = [MPTLoginApp loginUser];
    if (MPT_Str_Not_Valid(loginUser.phone))
    {
        return NO;
    }
    
    return YES;
}

#pragma mark - ******************************************* Net Connection Event ********************

#pragma mark - 请求 加载视频详情基本信息接口

- (void)loadChannelInfoWithScid:(NSString *)scid withReloadSuccess:(MPHReloadVideoInfoCallBack)reloadSuccess
{
    @weakify(self)
    [[MPTHttpClient sharedMPHTTPClient] getVideoInfoByScid:scid
                                           needPraisedList:NO
                                                   success:^(NSURLSessionDataTask *task, NSDictionary *responseObject)
     {
         @strongify(self)
         self.isReloadingAllData = NO;
         [self loadChannelInfoSuccess:responseObject];
         
         if(!self.boolReqVideoInfoOver)
         {
             self.isReqSuccessForVideoInfo = YES;
             self.boolReqVideoInfoOver = YES;
             [self isReqOverForVideoInfo_Comment_Relation];
         }
         
         if(reloadSuccess)
         {
             reloadSuccess();
         }
     }
                                                   failure:^(NSURLSessionDataTask *task, NSError *error)
     {
         @strongify(self)
         self.isReloadingAllData = NO;
         
         if(error.code == -1009)
         {
             @weakify(self)
             [self.viewLoadError showNonNetViewWithImageName:@"mp_net_error" hintTitle:@"网络连接不可用，请刷新重试" buttonTitle:@"点击重试" action:^{
                 @strongify(self)
                 [self reloadAction];
             }];
         }
         else
         {
             @weakify(self)
             [self.viewLoadError showNonNetViewWithImageName:@"mp_net_error" hintTitle:@"加载失败" buttonTitle:@"加载失败" action:^{
                 @strongify(self);
                 [self reloadAction];
             }];
         }
         
         [self loadingViewHidden:YES fail:YES];
         
         if (self.NotshowNoNetworkTip)
         {
             self.NotshowNoNetworkTip = NO;
         }
         else
         {
             [MPTTool showNetworkProblemTip];
         }
         
         if(!self.boolReqVideoInfoOver)
         {
             self.isReqSuccessForVideoInfo = NO;
             self.boolReqVideoInfoOver = YES;
             [self isReqOverForVideoInfo_Comment_Relation];
         }
         //失败继续加载下一个视频
         [self faillAddPlayDetail];
         MPFVideoPlayerManagerInstance.superVideoPlayer.viewCommented = 1;
     }
                                                    cached:^(NSDictionary *cachedObject)
     {
         @strongify(self)
         if(!self.boolReqVideoInfoOver)
         {
             self.isReqSuccessForVideoInfo = NO;
             self.boolReqVideoInfoOver = YES;
             [self isReqOverForVideoInfo_Comment_Relation];
         }
         [self loadChannelInfoSuccess:cachedObject];
     }];
}

- (void)reolationData
{
    self.relationDataSource = [[MPFVideoRelationDataSource alloc] initWithScid:self.scid];
    [self.relationDataSource fectchNewestData];
    
    @weakify(self);
    self.relationDataSource.fetchDataCompleted = ^(MPTDataSource *dataSource, BOOL isCached) {
        @strongify(self);
        
        [self.tableView reloadData];
        
        if(!self.boolReqRelationOver)
        {
            self.boolReqRelationOver = YES;
            [self isReqOverForVideoInfo_Comment_Relation];
        }
        
        MPFVideoPlayerManagerInstance.superVideoPlayer.detailRelationModelArray = self.relationDataSource.dataArray;
        //更新下一个视频的btn状态
        [MPFVideoPlayerManagerInstance.superVideoPlayer reloadDetailPreviousAndNextVideoBtn];
    };
    
//    self.dataSource.fetchDataFailured = ^(MPTDataSource *dataSource, NSError *error) {
//        @strongify(self);
//
//        if(!self.boolReqRelationOver)
//        {
//            self.boolReqRelationOver = YES;
//            [self isReqOverForVideoInfo_Comment_Relation];
//        }
//    };
}

- (void)commentData
{
    _reqComment = [[MPFVideoDeailCommentReq alloc] init];
    _reqComment.per = @"10";
    _reqComment.intPage = _intPage;
    _reqComment.strScid = self.channelModel.scid;
    _reqComment.strToCommentId = @"0";
    __weak MPFVideoDetailViewController *weakSelf = self;
    [_reqComment netWorkWithsuccess:^(MPBNetWorking *netWork, MPURLSessionTask *operation)
    {
        weakSelf.isError = NO;
        weakSelf.commentNumber = weakSelf.reqComment.totalNum;
        [weakSelf.enputView updateVideoComment:weakSelf.commentNumber];
        
        if (weakSelf.intPage == 1)
        {
            weakSelf.commentArray = [NSMutableArray arrayWithArray:weakSelf.reqComment.maryData];
        }
        else
        {
            [weakSelf.commentArray addObjectsFromArray:weakSelf.reqComment.maryData];
        }
        
        [weakSelf.tableView reloadData];
        
        if (weakSelf.reqComment.maryData.count <=0)
        {
            [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
        }
        else
        {
            [weakSelf.tableView.mj_footer endRefreshing];
        }
        
        if(!weakSelf.boolReqCommentOver)
        {
            weakSelf.boolReqCommentOver = YES;
            [weakSelf isReqOverForVideoInfo_Comment_Relation];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(weakSelf.intPage == 1 && weakSelf.commentArray.count > 0)
            {
                weakSelf.tableView.mj_footer = nil;
                MPTRefreshAutoFooter* footer = [MPTRefreshAutoFooter footerWithRefreshingTarget:weakSelf refreshingAction:@selector(requestMoreComments)];
                [footer setTitle:@"已显示全部评论" forState:MJRefreshStateNoMoreData];
                weakSelf.tableView.mj_footer = footer;
            }
            else if (weakSelf.commentArray.count == 0)
            {
                weakSelf.tableView.mj_footer = nil;
            }
        });
        
    }
                             failed:^(MPBNetWorking *netWork, MPURLSessionTask *operation)
    {
        weakSelf.isError = YES;
        weakSelf.tableView.mj_footer = nil;
        if(!weakSelf.boolReqCommentOver)
        {
            weakSelf.boolReqCommentOver = YES;
            [weakSelf isReqOverForVideoInfo_Comment_Relation];
        }
        
        if (weakSelf.reqComment.maryData.count <=0)
        {
            [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
        }
        else
        {
            [weakSelf.tableView.mj_footer endRefreshing];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
        });
    } cached:^(NSDictionary *cachedObject) {
        
    }];
    

}

//举报视频
-(void)reportVideoWithScid:(NSString *)scid
{
    logEvent(NSStringFromClass([self class]),@"reportVideoWithScid:",[NSString stringWithFormat:@"%@",scid]);
    
    if (![MPTLoginApp loginUser])
    {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    
    MPTHttpClient *httpClient = [MPTHttpClient sharedMPHTTPClient];
    
    [httpClient reportVideoScid:scid
                        success:^(NSURLSessionDataTask *task, NSDictionary *responseObject)
     {
         __strong typeof(weakSelf)strongSelf = weakSelf;
         if (strongSelf)
         {
             if([responseObject[@"status"] integerValue] == 200)
             {
                 [MPTTips showTips:NSLocalizedString(@"ReportSuccessfully", nil) duration:1.0];
             }
         }
     }
                        failure:^(NSURLSessionDataTask *task, NSError *error)
     {
         __strong typeof(weakSelf)strongSelf = weakSelf;
         if (strongSelf)
         {
             [strongSelf fetchDataFailure:error];
         }
     }];
}

//删除视频 -- 分为删除转发和删除自己发布的视频
- (void)deleteVideoWithScid:(NSString *)scid
{
    NSString *typeString = [NSString stringWithFormat:@"%@", self.channelModel.personalPageChannelType];
    
    if ([typeString isEqualToString:@"forward"] && isValidNSString(self.channelModel.sevtid))
    {
        [[MPTHttpClient sharedMPHTTPClient] deleteForwardContent:self.channelModel.sevtid
                                                         success:^(NSURLSessionDataTask *task, NSDictionary *responseObject) {
                                                             [MPTTips showTips:NSLocalizedString(@"CancelThisForwardSuccessfully", nil) duration:1.0f];
                                                             if (responseObject[@"delete"])
                                                             {
                                                                 [[NSNotificationCenter defaultCenter] postNotificationName:@"KDeleteForward" object:responseObject[@"delete"]];
                                                             }
                                                             else
                                                             {
                                                                 [[NSNotificationCenter defaultCenter] postNotificationName:@"KDeleteForward" object:nil];
                                                             }
                                                         }
                                                         failure:^(NSURLSessionDataTask *task, NSError *error) {
                                                             [MPTTips showTips:NSLocalizedString(@"FailedToCancelThisForward", nil) duration:1.0f];
                                                         }];
    }
    else
    {
        logEvent(NSStringFromClass([self class]),@"deleteVideoWithScid:",[NSString stringWithFormat:@"%@",scid]);
        
        if (!scid)
        {
            return;
        }
        
        //转菊花
        UIView *mainView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
        self.bacView = [[UIView alloc] init];
        self.bacView.frame = mainView.bounds;
        [mainView addSubview:self.bacView];
        self.bacView.backgroundColor = [UIColor YXRGBAColorWithSameNum:0 a:0.5];
        
        MPTRotateLoadingView *rotateLoadingview = [[MPTRotateLoadingView alloc] initWithFrame:CGRectMake(0.0f, 0.0, 50.0f, 50.0f)];
        [rotateLoadingview startAnimating];
        MBProgressHUD *HUD  = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.center = CGPointMake(self.bacView.center.x, self.bacView.center.y);
        HUD.customView = rotateLoadingview;
        HUD.mode = MBProgressHUDModeCustomView;
        [self.bacView addSubview:HUD];
        
        __weak typeof(self) weakSelf = self;
        MPTHttpClient *httpClient = [MPTHttpClient sharedMPHTTPClient];
        
        [httpClient deleteVideoScid:scid success:^(NSURLSessionDataTask *task, NSDictionary *responseObject) {
            __strong typeof(weakSelf)strongSelf = weakSelf;
            if (strongSelf)
            {
                if([responseObject[@"status"] integerValue] == 200)
                {
                    [strongSelf removeHintView];
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Remove_video_success",nil) message:@"" delegate:strongSelf cancelButtonTitle:NSLocalizedString(@"Action_ok",nil) otherButtonTitles:nil, nil];
                    alert.tag = 10001;
                    
                    [alert show];
                }
                else
                {
                    [MPTTips showTips:NSLocalizedString(@"Remove_video_fails",nil) duration:1.0f];
                    [strongSelf removeHintView];
                }
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            __strong typeof(weakSelf)strongSelf = weakSelf;
            if (strongSelf)
            {
                [strongSelf removeHintView];
            }
        }];
    }
}

#pragma mark - 获取评论列表
//发表评论
- (void)updateVideoCommentWithScid:(NSString *)scid andComment:(MPFVideoCommentModel *)commentModel
{
    logEvent(NSStringFromClass([self class]),@"updateVideoCommentWithScid:",[NSString stringWithFormat:@"%@",scid]);
    
    _reqPingLun = [[MPFVideoDeailSendCommentReq alloc] init];
    _reqPingLun.strScid = self.channelModel.scid;
    _reqPingLun.strComment = commentModel.content.content;
    _reqPingLun.uniqueID = commentModel;
    _reqPingLun.strToSuid = self.channelModel.owener.suid;
    _reqPingLun.strToCommentId = @"0";
    _reqPingLun.contentID = MPT_Str_Is_Valid(self.channelModel.contentId)?self.channelModel.contentId:self.originalModel.contentId;
    _reqPingLun.impressionID = MPT_Str_Is_Valid(self.channelModel.impressionId)?self.channelModel.impressionId:self.originalModel.impressionId;
    
    __weak MPFVideoDetailViewController *weakSelf = self;
    [_reqPingLun netWorkWithsuccess:^(MPBNetWorking *netWork, MPURLSessionTask *operation) {
        
        /// 这是真正的成功
        if ([weakSelf.reqPingLun.mdictData[@"publish"] integerValue] == 1)
        {
            weakSelf.commentNumber++;
            MPFVideoDeailSendCommentReq *reqTemp = (MPFVideoDeailSendCommentReq *)netWork;
            NSInteger index = [weakSelf.commentArray indexOfObject:reqTemp.uniqueID];
            ((MPFVideoCommentModel *)reqTemp.uniqueID).content.scmtId = reqTemp.mdictData[@"scmtId"];
            ((MPFVideoCommentModel *)reqTemp.uniqueID).isFailComment = NO;
            ((MPFVideoCommentModel *)reqTemp.uniqueID).isSendingComment = NO;
            [weakSelf.commentArray replaceObjectAtIndex:index withObject:(MPFVideoCommentModel *)reqTemp.uniqueID];
            weakSelf.lastDeleteIndexPath = nil;
            [weakSelf.tableView reloadData];
            
#pragma mark - 评论数没处理
            [weakSelf updateCommentNumber];
            weakSelf.channelModel.stat_ccnt = weakSelf.commentNumber;
            MPFVideoPlayerManagerInstance.superVideoPlayer.commented = 1;//投递参数
            [weakSelf pullComment];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"KDetailCommentVideo" object:weakSelf.channelModel];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"BlackVideo" object:weakSelf.channelModel];
            
            [weakSelf changeTableViewOffset];
            [MPTTips showTips:NSLocalizedString(@"Share_post_comment",@"发表成功") duration:1.0f];
            
        }
        else
        {
            [MPTTips showTips:weakSelf.reqPingLun.mdictData[@"content"] duration:1.0f];

            MPFVideoDeailSendCommentReq *reqTemp = (MPFVideoDeailSendCommentReq *)netWork;
            NSInteger index = [weakSelf.commentArray indexOfObject:reqTemp.uniqueID];
            ((MPFVideoCommentModel *)reqTemp.uniqueID).isFailComment = YES;
            ((MPFVideoCommentModel *)reqTemp.uniqueID).isSendingComment = NO;
            [weakSelf.commentArray replaceObjectAtIndex:index withObject:(MPFVideoCommentModel *)reqTemp.uniqueID];
            weakSelf.lastDeleteIndexPath = nil;
            [weakSelf pullComment];
            [weakSelf.tableView reloadData];
            
            MPFVideoPlayerManagerInstance.superVideoPlayer.commented = 0;//投递参数
            [weakSelf changeTableViewOffset];

        }
       
    } failed:^(MPBNetWorking *netWork, MPURLSessionTask *operation) {
        
        if ([operation.resaultState integerValue] == 401)
        {
            //被人添加到黑名单
            [MPTTips showTips:NSLocalizedString(@"reasonAboutCannotHaveRelation",nil) duration:1.0f];
        }
        else if([operation.resaultState integerValue] == 406)
        {
            //将该人添加到黑名单
            [MPTTips showTips:NSLocalizedString(@"peopleAlreadyExit",nil) duration:1.0f];
        }
        
        MPFVideoDeailSendCommentReq *reqTemp = (MPFVideoDeailSendCommentReq *)netWork;
        NSInteger index = [weakSelf.commentArray indexOfObject:reqTemp.uniqueID];
        ((MPFVideoCommentModel *)reqTemp.uniqueID).isFailComment = YES;
        ((MPFVideoCommentModel *)reqTemp.uniqueID).isSendingComment = NO;
        [weakSelf.commentArray replaceObjectAtIndex:index withObject:(MPFVideoCommentModel *)reqTemp.uniqueID];
        weakSelf.lastDeleteIndexPath = nil;
        [weakSelf pullComment];
        [weakSelf.tableView reloadData];
        [weakSelf changeTableViewOffset];
        MPFVideoPlayerManagerInstance.superVideoPlayer.commented = 0;//投递参数

    } cached:^(NSDictionary *cachedObject) {
       
    }];
}

//删除某一行
- (void)deleteCommentByIndexPath:(NSIndexPath *)indexPath
{
    logEvent(NSStringFromClass([self class]),@"deleteCommentByIndexPath:",@"");
    @try {
        MPFVideoCommentModel *commentModel = getValidObjectFromArray(self.commentArray, indexPath.row);
        //删除评论
        NSInteger brow = indexPath.row;
        
        /// 应该减的数量
        NSInteger intCount = commentModel.content.replyCount + 1;
        if (commentModel.isFailComment)
        {
            [self removeRowByIndexPath:[NSIndexPath indexPathForRow:brow inSection:0]];
            [self updateCommentNumber];
            
        }
        else
        {
            //可在此转菊花
            __weak typeof(self) weakSelf = self;
            MPTHttpClient *httpClient = [MPTHttpClient sharedMPHTTPClient];
            
            [httpClient deleteCommentByScmtid:commentModel.content.scmtId success:^(NSURLSessionDataTask *task, NSDictionary *responseObject) {
                
                __strong typeof(weakSelf)strongSelf = weakSelf;
                if (strongSelf) {
                    if([responseObject[@"status"] integerValue] == 200){
                        MPFVideoPlayerManagerInstance.superVideoPlayer.commented = 2;
                        //更新评论数
                        strongSelf.commentNumber = strongSelf.commentNumber - intCount;
                        
                        if (strongSelf.commentNumber<0)
                        {
                            strongSelf.commentNumber = 0;
                        }
                        
                        [strongSelf updateCommentNumber];
                        [strongSelf deleteCommentComplete:responseObject indexPath:brow];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"KDetailCommentVideo" object:strongSelf.channelModel];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"BlackVideo" object:strongSelf.channelModel];
                    }
                    else
                    {
                        
                    }
                }
                
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                
                __strong typeof(weakSelf)strongSelf = weakSelf;
                
                MPFVideoPlayerManagerInstance.superVideoPlayer.commented = 1;
                
                [strongSelf deleteCommentComplete:nil indexPath:brow];
                [MPTTips showTips:NSLocalizedString(@"DeleteCommentsFailed",nil) duration:1.0];
            }];
        }
        self.lastDeleteIndexPath = nil;
    }
    @catch (NSException *exception) {
        [MPTTips showTips:NSLocalizedString(@"DeleteCommentsFailed",nil) duration:1.0];
    }
    @finally {
        
    }
}


#pragma mark - ******************************************* Delegate Event **************************
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (otherGestureRecognizer == self.navigationController.mpPopGesture)
    {
        return YES;
    }
    
    if (_tableView.contentOffset.y == 0)
    {
        return NO;
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
    {
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint point = [pan translationInView:gestureRecognizer.view];
        UIGestureRecognizerState state = pan.state;
        UIScrollView *scllor = (UIScrollView *)otherGestureRecognizer.view;
        if ([scllor isKindOfClass:[UIScrollView class]])
        {
            if (UIGestureRecognizerStateBegan == state || UIGestureRecognizerStatePossible == state)
            {
                if (point.y > 0 && scllor.contentOffset.y <= 0)
                {
                    if (point.y >= 0) {
                        CGFloat y = fabs(point.y);
                        CGFloat x = fabs(point.x);
                        CGFloat af = 30.0f/180.0f * M_PI;
                        
                        CGFloat tf = tanf(af);
                        if ((y/x) >= tf)
                        {
                            return YES;
                        }
                    }
                    
                }
            }
        }
    }
    
    return NO;
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

#pragma mark - MPTDetailLikeCellDelegate

- (void)loadMoreButtonClicked
{
    
}

#pragma mark - MPTLikesBarDelegate

- (void)likeStatusDidChange:(BOOL)like
{
    like = !self.enputView.likeButton.tag;
    if (like)
    {
        MPFVideoPlayerManagerInstance.superVideoPlayer.favorited = 1;
        
        [self __like];
    }
    else
    {
        MPFVideoPlayerManagerInstance.superVideoPlayer.favorited = 2;
        
        [self __unlike];
    }
    
    [MPUmeng event:@"detail_good" attributes:@{@"type":@"middle"}];
}

#pragma mark- MPDMPFVDOneFloorCommentCellDelegate

- (void)mpdRetryComment_MPDMPFVDOneFloorCommentCellDelegate:(MPFVideoCommentModel*)model isSanChu:(BOOL)isSanChu indexP:(NSIndexPath *)indexP
{
    logEvent(NSStringFromClass([self class]),@"handleCommentForComment:",@"");
    self.lastDeleteIndexPath = indexP;
    NSString *osuid = [MPTLoginApp loginUser].suid;
    NSString *csuid = model.content.fromUser[@"suid"];
    self.haveAction = NO;
    if (!self.haveAction)
    {
        /// 点击重发
        if (model.isFailComment && !isSanChu)
        {
            UIActionSheet *as;
            as = [[UIActionSheet alloc] initWithTitle:nil delegate:self
                                    cancelButtonTitle:NSLocalizedString(@"Action_cancel",nil)
                               destructiveButtonTitle:nil
                                    otherButtonTitles:NSLocalizedString(@"Chongxinfabu",nil),NSLocalizedString(@"Theme_action_delete",nil), nil];
            as.tag = 2004;
            [as showInView:[UIApplication sharedApplication].keyWindow];
        }
        else
        {
            /// 点击删除
            if ([csuid isEqualToString:osuid])
            {
                // 自己的评论
                // 删除 取消
                MPCAlertView *alent = [[MPCAlertView alloc] initWithTitle:@"" message:@"确认要删除这条评论吗？" delegate:self cancelButtonTitle:NSLocalizedString(@"Action_cancel",nil) otherButtonTitles:NSLocalizedString(@"Theme_action_delete",nil), nil];
                alent.tag = 2002;
                [alent show];
            }
        }
        self.haveAction = YES;
    }
}

#pragma mark- UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 9999)
    {
        if(buttonIndex == 1)
        {
            [self.navigationController popToRootViewControllerAnimated:NO];
            [JLRoutes routeURL:[NSURL URLWithString:@"/tabbar/0"]];
        }
        else if (buttonIndex == 0)
        {
            showAlertChoiceWithDelegate(NSLocalizedString(@"AreYouSureToReportThisVideo", nil), self, 101);
        }
        
        return;
    }
    if (actionSheet.tag == 100001)
    {
        if(buttonIndex == 1)
        {
            if (![MPTLoginApp isLogin])
            {
                [JLRoutes routeURL:[NSURL URLWithString:@"/login"]];
                
                return;
            }
            
            if([self.channelModel.owener.suid  isEqualToString:[MPTLoginApp loginUser].suid])
            {
                
            }
        }
        else if (buttonIndex == 0)
        {
            [self.navigationController popToRootViewControllerAnimated:NO];
            [JLRoutes routeURL:[NSURL URLWithString:@"/tabbar/0"]];
        }
        else if (buttonIndex == 2)
        {
            if (![MPTLoginApp isLogin])
            {
                [JLRoutes routeURL:[NSURL URLWithString:@"/login"]];
                
                return;
            }
            
            if (isValidNSDictionary(self.channelModel.reward_info) &&
                (([[NSDate date] timeIntervalSince1970]*1000 - self.channelModel.finishTime.doubleValue)<1000*60*60*24*7))
            {
                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"VideosParticipatingInActivitiesCannotBeDeletedDuringActivitiesAndWithin1WeekAfterTheyAreOver",nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"Action_ok",nil) otherButtonTitles:nil, nil] show];
            }
            else
            {
                if([self.channelModel.owener.suid isEqualToString:[MPTLoginApp loginUser].suid])
                {
                    showAlertChoiceWithDelegate(NSLocalizedString(@"Confirm_del_video",nil), self, 102);
                }
            }
        }
        
        return;
    }
    
    self.haveAction = NO;
    self.hadSelected = NO;
    
    
    // 详情页面评论相关代码逻辑
    MPFVideoCommentModel *model = getValidObjectFromArray(self.commentArray, self.lastDeleteIndexPath.row);
    if (actionSheet.tag == 2004)
    {
        if (buttonIndex == 0)
        {
            //重新发
            [self.commentArray removeObjectAtIndex:self.lastDeleteIndexPath.row];

            model.isFailComment = NO;
            model.isSendingComment = YES;
            if ([MPTReachability isNotReachable])
            {
                model.isFailComment = YES;
            }
            NSDate *dat = [NSDate dateWithTimeIntervalSinceNow:0];
            NSTimeInterval time = [dat timeIntervalSince1970]*1000;
            model.content.createTime = time;
            self.isRequestAgain = YES;
            [self.commentArray insertObject:model atIndex:0];
            [self.tableView reloadData];
            [self updateVideoCommentWithScid:self.channelModel.scid andComment:model];
        }
        else if (buttonIndex == 1)
        {
            //删除
            [self deleteLocalCommentWith:model];
            [self deleteCommentByIndexPath:self.lastDeleteIndexPath];
        }
        else
        {
            self.lastDeleteIndexPath = nil;
        }
    }
}

- (void)alertView:(MPCAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[NSNotificationCenter defaultCenter]postNotificationName:MPFAlertViewDismissNotificationName object:nil];
    //31 未登录赞大于20个视频
    if (alertView.tag == 31)
    {
        if (buttonIndex == 0 )
        {
            NSLog(@"不登录");
        }
        else
        {
            [JLRoutes routeURL:[NSURL URLWithString:@"/login"]];
        }
    }
    
    /// 删除自己的评论
    if (alertView.tag == 2002)
    {
        // 详情页面评论相关代码逻辑
        if (buttonIndex == 0)
        {
            self.lastDeleteIndexPath = nil;
        }
        else if (buttonIndex == 1)
        {
            [self deleteCommentByIndexPath:self.lastDeleteIndexPath];
        }
        else
        {
            self.lastDeleteIndexPath = nil;
        }
        
        return;
    }
   
}

#pragma mark- MPDVideoDetailActionViewDelegate

- (void)mpdRequiedVideoDetailActionViewLikeAction:(UIView*)view like:(BOOL)isLike
{
    [self stopTimeDown];
    [self likeStatusDidChange:isLike];
}

- (void)mpdRequiedVideoDetailActionViewCommentAction:(UIView*)view
{
    [self changeTableViewOffset];
}

- (void)mpdRequiedVideoDetailActionViewShareAction:(UIView*)view
{
    [self commentInptBarShareAction];
}

- (void)mpdRequiedVideoDetailActionViewCacheAction:(UIView*)view
{
    [self stopTimeDown];
    [[MPTHVideoCacheManager shareInstance]tryAddCacheVideo:self.channelModel];
}

#pragma mark - uiscrollview delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"scrollview.contentOffSet n= %f",scrollView.contentOffset.y);
    MPFVideoPlayerManagerInstance.superVideoPlayer.contentOffSetY = scrollView.contentOffset.y;
    
    // 只要是有滚动就停止播放器的倒计时功能
    if(MPFVideoPlayerManagerInstance.superVideoPlayer.isCountDown)
    {
        [MPFVideoPlayerManagerInstance.superVideoPlayer cancelCountDownPlayNextVideo];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 10001)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"KDeleteUserVideo" object:self.channelModel];
        [_player.overlayView.playerProgressView.fullScreenButton setImage:[UIImage imageNamed:@"player_btn_FullScreen_n"] forState:UIControlStateNormal];
        
        if (MPFVideoPlayerManagerInstance.superVideoPlayer.isScreen)
        {
            [_player.delegate clickOnScreen];
            
        }
        
        self.player.isScreen = NO;
        [self.player pause];
        [self.player shangBaoStopOutSide];
        [self.player removeFromSuperview];
        
        [self goToBack];
    }
    else
    {
        if (alertView.tag == 101)
        {
            if (buttonIndex == 1)
            {
                [self reportVideoWithScid:self.channelModel.scid];
            }
        }
        else if (alertView.tag == 102)
        {
            if (buttonIndex == 1)
            {
                [self deleteVideoWithScid:self.channelModel.scid];
            }
        }
    }
}

#pragma mark - MPTSharePlanDelegate

- (void)sharePlanDidDismiss:(UIView*)view
{
    MPFVideoPlayerManagerInstance.superVideoPlayer.isAfterBufferPlayStatus = YES;
}

#pragma mark - 代理 MPTVideoPlayerDelegate

- (BOOL)shouldShowLikeAnimation
{
    BOOL showAnimation = NO;
    
    if (![MPTConfig isLogin])
    {
        showAnimation = YES;
    }
    else
    {
        showAnimation = YES;
    }
    
    return showAnimation;
}

- (void)likeAnimationDidComplete
{
    self.likeFromDoubleTap = YES;
    if (![MPTLoginApp isLogin])
    {
        self.likeFromDoubleTap = YES;
        
        [self __like];
        
        [MPUmeng event:@"detail_good" attributes:@{@"type":@"double"}];
    }
    else
    {
        //判断是否已经在右下角点过赞 没点过双击点赞就成立   点过 双击点赞无效
        if (!self.hadAdmired)
        {
            self.hadAdmired = YES;
            self.hadOverAdmired = YES;
            if (self.channelModel.selfmark != 6)
            {
                [self __like];
            }
            
            [MPUmeng event:@"detail_good" attributes:@{@"type":@"double"}];
        }
        else
        {
            self.hadOverAdmired = YES;
            //判断时候是结束页的点赞
        }
        
        if (self.hadOverAdmired)
        {
            NSLog(@"安安静静的改改bug，别着急");
        }
        else
        {
            if (self.player)
            {
                [self.player syncLikeState:YES];
            }
            
            [self.enputView updateLikeStatus:YES andPraisedNumber:self.channelModel.stat_lcnt animate:YES];
            if (self.channelModel.selfmark != 6)
            {
                [self __like];
            }
        }
    }
}

#pragma mark - 代理 MPTPlayerDelegate

-(void)startPlayerCountDownAnimationModel:(MPFVideoRelationModel *)model
{
    if (isValidNSString(model.title))
    {
        MPFVideoPlayerManagerInstance.superVideoPlayer.overlayView.mptRecommandTooView.titleLabel.text = model.title;
    }
    else
    {
        MPFVideoPlayerManagerInstance.superVideoPlayer.overlayView.mptRecommandTooView.titleLabel.text = @"上传视频";
    }
    
    if (isValidNSString(model.pic))
    {
        [MPFVideoPlayerManagerInstance.superVideoPlayer setAlphaForVideoPlayer:0];
        [self.thumb sd_setImageWithURL:[NSURL URLWithString:model.pic]];
        [self.thumb sd_setImageWithURL:[NSURL URLWithString:model.pic]
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
         {
             if (MPFVideoPlayerManagerInstance.superVideoPlayer.isScreen == NO)
             {
                 MPFVideoPlayerManagerInstance.superVideoPlayer.backgroundColor = [UIColor clearColor];
                 
             }
         }];
    }
}

-(void)mpdDetailMoreBtnHide:(BOOL)isHide
{
    if(isHide)
    {
        self.moreButtonItem.hidden = YES;
    }
    else
    {
        self.moreButtonItem.hidden = NO;
    }
}

#pragma mark - UITableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return self.relationDataSource.dataArray.count;
    }
    
    if([self.commentArray count] == 0)
    {
        return 1;
    }
    else
    {
        return self.commentArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return [self tableViewForVideos:tableView cellForRowAtIndexPath:indexPath];
    }
    else
    {
        return [self tableViewForComment:tableView cellForRowAtIndexPath:indexPath];
    }
}

- (UITableViewCell *)tableViewForVideos:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MPFVideoRelationCell *cell = [tableView dequeueReusableCellWithIdentifier:kVideoRelationCellID];
    
    [cell loadViewWithModel:getValidObjectFromArray(self.relationDataSource.dataArray, indexPath.row)];
    
    return cell;
}

- (UITableViewCell *)tableViewForComment:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.commentArray count] == 0)
    {
        static  NSString *CellIdentifier = @"ErrorNothingCell";
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell =  [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        __weak MPFVideoDetailViewController *weakSelf = self;
        
        if(self.isError == YES)
        {
            // 走请求错误的流程
            [self.viewPageState showFailViewWithHintTitle:@"评论加载失败" buttonTitle:@"点击重试" action:^{
                [weakSelf.viewPageState showHudWithImageName:@"common_comments_loading" title:@"加载中"];
                [weakSelf commentData];
            }];
        }
        else if (self.commentArray.count<=0)
        {
            [self.viewPageState showNotDataViewWithImageName:@"MPFVideoDetail_NoComment" hintTitle:@"写评论抢沙发" action:^{
                [weakSelf.inputView activeIsFormeErJiPinglun:NO];
                [weakSelf stopTimeDown];
            }];
        }
        
        if(self.viewPageState.superview == nil)
        {
            [cell.contentView addSubview:self.viewPageState];
            
            [self.viewPageState mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(cell.contentView);
            }];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    
    [self.viewPageState removePageLoadingView];
    
    MPFVDOneFloorCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell"];
    if(!cell)
    {
        cell = [[MPFVDOneFloorCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"commentCell"];
        cell.delegate = self;
    }

    __weak MPFVideoDetailViewController *weakSelf = self;
    
    /// 点击cell上的回复文字
    [cell setMPFVideoDetailCommentHuiFuCellHuiFuBlcok:^(NSIndexPath *index, MPFVideoCommentModel *model) {
        [weakSelf goToCommentTwoView:index model:model isClickedHuioFu:YES];
    }];
    
    /// 负值顺序别动
    cell.indexP = indexPath;
    MPFVideoCommentModel *model = _commentArray[indexPath.row];
    [cell isShipinZuoZheSuid:self.channelModel.owener.suid];
    [cell setCellContent:model];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0)
    {
        return [MPFVideoRelationCell getCellHeight];
    }
    
    if ([self.commentArray count] == 0)
    {
        return 120.0f+90.0f;
    }
    
    return [MPFVDOneFloorCommentCell getCellHeight:_commentArray[indexPath.row]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        // 相关视频部分的section
        if(self.relationDataSource.dataArray.count == 0)
        {
            return 0.01;
        }
        
        return 0.5 +6;
    }
    
    if(self.commentNumber==0)
    {
        return 32;
    }
    else
    {
        return 39;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(section == 0)
    {
        if(self.relationDataSource.dataArray.count == 0)
        {
            return 0.5;
        }
        
        // 加载更多相关视频的footerview
        if([self.relationDataSource hasMoreData])
        {
            return [MPFVDRelationHeadView getViewHeight]+0.5;
        }
        else
        {
            return 0.5 + 6;
        }
    }
    
    return 0.5;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        if(self.relationDataSource.dataArray.count == 0)
        {
            return nil;
        }
        else
        {
            UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MPT_ScreenW, 6.5)];
            headView.backgroundColor = [UIColor whiteColor];
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MPT_ScreenW, 0.5)];
            view.backgroundColor = [UIColor YXColorWithHexCode:@"#ededed"];
            [headView addSubview:view];
            return headView;
        }
    }
    
    if (self.containter == nil)
    {
        self.containter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 39)];
        self.containter.backgroundColor = [UIColor whiteColor];
        UILabel *lb = [UILabel new];
        lb.textColor = [UIColor YXColorWithHexCode:@"#23232b"];
        lb.font = [UIFont YXRegularFontOdSize:15];
        
        [self.containter addSubview:lb];
        self.commentNumberLabel = lb;
        [lb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.containter.mas_left).with.offset(15);
            make.top.equalTo(self.containter.mas_top).with.offset(18);
            make.width.mas_equalTo(200);
            make.height.mas_equalTo(15);
        }];
    }
    
    NSString *strTemp = @"";
    if(self.commentNumber>0)
    {
        NSString *str = [MPTTool getNumWith:self.commentNumber];
        strTemp = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Message_comment_text",nil),str];
    }
    else
    {
        strTemp = [NSString stringWithFormat:@"%@ ",NSLocalizedString(@"Message_comment_text",nil)];
    }
    
    self.commentNumberLabel.text = strTemp;
    self.commentNumberLabel.font = [UIFont YXRegularFontOdSize:15];
    
    return self.containter;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0)
    {
        if(self.relationDataSource.dataArray.count == 0)
        {
            return nil;
        }
        
        if(![self.relationDataSource hasMoreData])
        {
            UIView *view = [[UIView  alloc] initWithFrame:CGRectMake(0, 0, MPT_ScreenW, 6.5)];
            view.backgroundColor = [UIColor whiteColor];
            
            UIView *viewline = [[UIView alloc] initWithFrame:CGRectMake(0, 6, MPT_ScreenW, 0.5)];
            viewline.backgroundColor = [UIColor YXColorWithHexCode:@"#ededed"];
            [view addSubview:viewline];
            return view;
        }
        
        if(self.viewFooterInSection)
        {
            return self.viewFooterInSection;
        }
        
        @weakify(self);
        self.viewFooterInSection = [MPFVDRelationHeadView relationiIsHead:NO callBack:^(BOOL isAuto) {
            @strongify(self);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showAnimation_MPFVDRelationHeadView" object:nil];
            
            @weakify(self);
            self.relationDataSource.fetchDataCompleted = ^(MPTDataSource *dataSource, BOOL isCached) {
                @strongify(self);
                
                [self.tableView reloadData];
                
                if([self.relationDataSource hasMoreData])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"hiddenAnimation_MPFVDRelationHeadView"
                                                                            object:nil];
                    });
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"hiddenAnimation_MPFVDRelationHeadView"
                                                                            object:nil];
                    });
                }
            };
            
            self.relationDataSource.fetchDataFailured = ^(MPTDataSource *dataSource, NSError *error) {
                @strongify(self);
                [self.tableView reloadData];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MPTTips showSingleTips:NSLocalizedString(@"SomethingWrongWithNetworkPleaseRefresh", nil) duration:1.0f];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"hiddenAnimation_MPFVDRelationHeadView"
                                                                        object:nil];
                });
            };
            
            
            [self.relationDataSource fectchMoreData];
        }];
        
        return self.viewFooterInSection;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
 
    if(tableView == self.tableView)
    {
        if(indexPath.section == 0 )
        {
            if (isValidNSArray(self.relationDataSource.dataArray ))
            {
                MPFVideoPlayerManagerInstance.superVideoPlayer.channelSingleRowCell = nil;
                MPFVideoPlayerManagerInstance.superVideoPlayer.attentionCell = nil;
                MPFVideoPlayerManagerInstance.superVideoPlayer.meSingCell = nil;
                
                MPFVideoRelationModel *modelRelation = [self.relationDataSource.dataArray objectAtIndex:indexPath.row];
                [MPFVideoPlayerManagerInstance.superVideoPlayer addDetailAlreadyPlayModel];
                _currentImageURl = modelRelation.pic;
                self.scid = modelRelation.scid;
                if (isValidNSString(modelRelation.title))
                {
                    MPFVideoPlayerManagerInstance.superVideoPlayer.overlayView.mptRecommandTooView.titleLabel.text = modelRelation.title;
                }
                else
                {
                   MPFVideoPlayerManagerInstance.superVideoPlayer.overlayView.mptRecommandTooView.titleLabel.text =  @"上传视频";
                }
                [MPFVideoPlayerManagerInstance.superVideoPlayer cancelCountDownPlayNextVideo];
                [MPFVideoPlayerManagerInstance.superVideoPlayer shangBaoStopOutSide];
                MPFVideoPlayerManagerInstance.superVideoPlayer.playType =2;
                MPFVideoPlayerManagerInstance.superVideoPlayer.overlayView.middlePlayControlView.willPlayContentLabel.hidden = YES;
                
                _pageType = kPageType_XiangGuanShiPin;
                [MPTTool setPresentingPage:_pageType];
                
                NSIndexPath * dayOne = [NSIndexPath indexPathForRow:0 inSection:0];
                [self.tableView scrollToRowAtIndexPath:dayOne atScrollPosition:UITableViewScrollPositionTop animated:NO];
                [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
                [self reloadAllData];

            }
        }
        else
        {
            if (self.hadSelected || [self.commentArray count]==0)
            {
                self.hadSelected = NO;
                
                return;
            }
            
            MPFVideoCommentModel  *model = _commentArray[indexPath.row];
            /// 失败的
            if (model.isFailComment)
            {
                self.haveAction = NO;
                [self mpdRetryComment_MPDMPFVDOneFloorCommentCellDelegate:model isSanChu:NO indexP:indexPath];
            }
            else
            {
                [self goToCommentTwoView:indexPath model:model isClickedHuioFu:NO];
            }
        }
    }
}

/// 跳转到二级评论的方法 来自消息盒子使用
- (void)goToCommentTwoViewDetailIsFromeXiaoXiHeZi
{
    if (self.isXiaoXiHeZi)
    {
            
            [self.inputView.textViewInput resignFirstResponder];
            
            self.twoFlowerisShow = YES;
            
            if (!_viewCommentTwo)
            {
                _viewCommentTwo = [[MPFVideoDetailCommentTwoView alloc] initWithTopY:CGRectGetMaxY(_playerView.frame)];
                @weakify(self)
                _viewCommentTwo.MPFVideoDetailViewShowOrHidenBlock = ^(BOOL isShow)
                {
                    @strongify(self)
                    
                    self.twoFlowerisShow = isShow;
                    if (isShow)
                    {
                        [self.inputView removeAllNotifationCenter];
                    }
                    else
                    {
                        [self.inputView regNotification];
                    }
                };
                
                __weak MPFVideoDetailViewController *weakSelf = self;
                /// 更新详情数据的通知
                [_viewCommentTwo setMPFVideoDetailCommentTwoViewBlock:^(MPFVideoCommentModel *model, NSIndexPath *indexp, BOOL isAdd)
                 {
                     if (isAdd)
                     {
                         weakSelf.commentNumber++;
                     }
                     else
                     {
                         weakSelf.commentNumber--;
                     }
                     [weakSelf.commentArray replaceObjectAtIndex:indexp.row withObject:model];
                     [weakSelf.tableView reloadData];
                     [weakSelf updateCommentNumber];
                     weakSelf.channelModel.stat_ccnt = weakSelf.commentNumber;
                     [weakSelf.enputView  updateVideoComment:weakSelf.commentNumber];
                 }];
                
                _viewCommentTwo.isClickedHuioFu = YES;
                _viewCommentTwo.indexPXiangQing = nil;
                _viewCommentTwo.commentModelXiaoXi = _commentModelXiaoXi;
                _viewCommentTwo.channelModel = self.channelModel;
                _viewCommentTwo.originalModel = self.originalModel;
                _viewCommentTwo.strScid = self.channelModel.scid;
                [self.view addSubview:_viewCommentTwo];
                [_viewCommentTwo show];
            }
            else
            {
                _viewCommentTwo.isClickedHuioFu = YES;
                _viewCommentTwo.indexPXiangQing = nil;
                _viewCommentTwo.commentModelXiaoXi = _commentModelXiaoXi;
                _viewCommentTwo.channelModel = self.channelModel;
                _viewCommentTwo.originalModel = self.originalModel;
                _viewCommentTwo.strScid = self.channelModel.scid;
                [_viewCommentTwo show];
            }
            
            self.isXiaoXiHeZi = NO;
            self.commentModelXiaoXi = nil;
    }
}

/// 跳转到二级评论的方法
- (void)goToCommentTwoView:(NSIndexPath *)indexPath model:(MPFVideoCommentModel *)model isClickedHuioFu:(BOOL)isClickedHuioFu
{
    [self.inputView.textViewInput resignFirstResponder];
    
    self.twoFlowerisShow = YES;
    
    if (!_viewCommentTwo)
    {
        _viewCommentTwo = [[MPFVideoDetailCommentTwoView alloc] initWithTopY:CGRectGetMaxY(_playerView.frame)];
        @weakify(self)
        _viewCommentTwo.MPFVideoDetailViewShowOrHidenBlock = ^(BOOL isShow)
        {
            @strongify(self)
            
            self.twoFlowerisShow = isShow;
            if (isShow)
            {
                [self.inputView removeAllNotifationCenter];
            }
            else
            {
                [self.inputView regNotification];
            }
        };
        
        __weak MPFVideoDetailViewController *weakSelf = self;
        /// 更新详情数据的通知
        [_viewCommentTwo setMPFVideoDetailCommentTwoViewBlock:^(MPFVideoCommentModel *model, NSIndexPath *indexp, BOOL isAdd)
         {
             if (isAdd)
             {
                 weakSelf.commentNumber++;
             }
             else
             {
                 weakSelf.commentNumber--;
             }
             [weakSelf.commentArray replaceObjectAtIndex:indexp.row withObject:model];
             [weakSelf.tableView reloadData];
             [weakSelf updateCommentNumber];
             weakSelf.channelModel.stat_ccnt = weakSelf.commentNumber;
             [weakSelf.enputView  updateVideoComment:weakSelf.commentNumber];
         }];
        
        _viewCommentTwo.isClickedHuioFu = isClickedHuioFu;
        _viewCommentTwo.indexPXiangQing = indexPath;
        _viewCommentTwo.model = model;
        _viewCommentTwo.channelModel = self.channelModel;
        _viewCommentTwo.originalModel = self.originalModel;
        _viewCommentTwo.strScid = self.channelModel.scid;
        [self.view addSubview:_viewCommentTwo];
        [_viewCommentTwo show];
    }
    else
    {
        _viewCommentTwo.isClickedHuioFu = isClickedHuioFu;
        _viewCommentTwo.indexPXiangQing = indexPath;
        _viewCommentTwo.model = model;
        _viewCommentTwo.channelModel = self.channelModel;
        _viewCommentTwo.originalModel = self.originalModel;
        _viewCommentTwo.strScid = self.channelModel.scid;
        [_viewCommentTwo show];
    }
}
#pragma mark - 播放器相关delegate

-(void)commonPlayEndViewShareClick
{
    if (MPFVideoPlayerManagerInstance.superVideoPlayer.isScreen)
    {
        [self.player.overlayView.playerProgressView.playOrStopButton setImage:[UIImage imageNamed:@"MPTPlay－normal"]
                                                                     forState:UIControlStateNormal];
        [self.player pause];
        
        [self topicFeedViewFulleScreenPlayerMoreButtonClick:nil
                                          playerOrientation:MPFVideoPlayerManagerInstance.superVideoPlayer.playerOriention
                                            andChannelModel:self.channelModel];
    }
    else
    {
        if (self.channelModel)
        {
            [self reportVideo];
        }
    }
}

- (void)clickOnScreen
{
    [MPFVideoPlayerManagerInstance.superVideoPlayer playerFullScreenControlMothed:self.playerView
                                       sameHeightAndWidthView:self.thumb
                                                      channel:self.channelModel];
    //正常播放zhuangt
    if (!MPFVideoPlayerManagerInstance.superVideoPlayer.isScreen)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    }
}

-(void)autorotationFullScreen
{
    MPFVideoPlayerManagerInstance.superVideoPlayer.playSuperView = self.playerView;
    MPFVideoPlayerManagerInstance.superVideoPlayer.frameView = self.thumb;
    MPFVideoPlayerManagerInstance.superVideoPlayer.playChannelModel = self.channelModel;
}

- (void)closeScreenBtnClick
{
    [self clickOnScreen];
}

- (void)moreViewBtnClick
{
    [self.player.overlayView.playerProgressView.playOrStopButton setImage:[UIImage imageNamed:@"MPTPlay－normal"]
                                                                 forState:UIControlStateNormal];
    [self.player pause];
    
    [self topicFeedViewFulleScreenPlayerMoreButtonClick:nil
                                      playerOrientation:MPFVideoPlayerManagerInstance.superVideoPlayer.playerOriention
                                        andChannelModel:self.channelModel];
}

-(void)playAlpah
{
    
}


#pragma mark - ******************************************* Notification Event **********************

#pragma mark - 通知 demo

- (void)keyboardWillShow:(NSNotification *)notification
{
    self.zf_interactivePopDisabled = YES;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.zf_interactivePopDisabled = NO;
}

- (void)notification_demo:(NSNotification *)aNotification
{
    
}

- (void)applicationDidBecomeActiveDo:(NSNotification *)tification
{
    
}

- (void)LoginSuccess:(NSNotification *)notification
{
    
}

-(void)autoOrientiationHasChanage:(NSNotification *)notification
{
    [MPFVideoPlayerManagerInstance.superVideoPlayer orientationHasChange:notification];
}

- (void)keyWindowChanged
{
    if (self.view.window.isKeyWindow)
    {
        isKeyWindowRecord = YES;
    }
    else
    {
        if (isKeyWindowRecord==YES)
        {
            if ([MPFVideoPlayerManagerInstance.superVideoPlayer isPlayingForVideoPlayer] == YES) {
                [MPFVideoPlayerManagerInstance.superVideoPlayer pause];
            }
            isKeyWindowRecord = NO;
        }
    }
}

- (void)orientationHasChange:(NSNotification *)notification
{
    UIDevice *device = (UIDevice *)notification.object;
    if(device.orientation == UIInterfaceOrientationLandscapeLeft ||
       device.orientation == UIInterfaceOrientationLandscapeRight)
    {
        BOOL isscreen = MPFVideoPlayerManagerInstance.superVideoPlayer.isScreen;
        if (isscreen)
        {
            [self resignenputView];
            [self.viewCommentTwo resign];
        }
    }
}


#pragma mark - ******************************************* 属性变量的 Set 和 Get 方法 *****************

- (MPCPageLoadingView *)viewPageState
{
    if (!_viewPageState)
    {
        _viewPageState = [[MPCPageLoadingView alloc] init];
        _viewPageState.centerY = YES;
    }
    
    return _viewPageState;
}

- (MPCPageLoadingView *)viewLoadError
{
    if (!_viewLoadError)
    {
        _viewLoadError = [[MPCPageLoadingView alloc] init];
        _viewPageState.centerY = YES;
    }
    
    return _viewLoadError;
}

- (MPCPageLoadingView *)viewCustomLoading
{
    if (!_viewCustomLoading)
    {
        _viewCustomLoading = [[MPCPageLoadingView alloc] init];
        _viewPageState.centerY = YES;
    }
    
    return _viewCustomLoading;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (MPFDetailHeadView *)detailHeadView
{
    if (!_detailHeadView)
    {
        _detailHeadView = [[MPFDetailHeadView alloc]init];
        _detailHeadView.backgroundColor = [UIColor whiteColor];
        _detailHeadView.delegate = self;
    }
    
    return _detailHeadView;
}

- (UIView *)contentView
{
    if (!_contentView)
    {
        _contentView = [[UIView alloc]init];
        _contentView.backgroundColor = [UIColor whiteColor];
    }
    
    return _contentView;
}

- (UIButton *)backButtonItem
{
    if (!_backButtonItem)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.exclusiveTouch = YES;
//        button.backgroundColor = [UIColor redColor];
        button.frame = CGRectMake(0, 0, 44, 44);
        [button setImageEdgeInsets:UIEdgeInsetsMake(1, -7, 0, 0)];
        [button setImage:[UIImage imageNamed:@"common_Player_btn_Return_n"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"common_Player_btn_Return_p"] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(goToBack) forControlEvents:UIControlEventTouchUpInside];
        _backButtonItem = button;
    }
    
    return _backButtonItem;
}

- (UIButton *)moreButtonItem
{
    if (!_moreButtonItem)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(MPT_ScreenW-44, 0, 44, 44);
        [button setImageEdgeInsets:UIEdgeInsetsMake(1, 0, 0, -4)];
        [button setImage:[UIImage imageNamed:@"common_Player_btn_more_n"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"common_Player_btn_more_p"] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(reportVideo) forControlEvents:UIControlEventTouchDown];
        _moreButtonItem = button;
    }
    
    return _moreButtonItem;
}

- (UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.bounces = NO;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.scrollsToTop = YES;
        [_tableView registerClass:[MPFVideoRelationCell class] forCellReuseIdentifier:kVideoRelationCellID];
    }
    
    return _tableView;
}

- (MPFVideoDetailInputView *)inputView
{
    if (!_inputView)
    {
        _inputView = [[MPFVideoDetailInputView alloc] initWithFrame:CGRectMake(0, 0, MPT_ScreenW, MPT_ScreenH)];
        
        @weakify(self)
        
        __weak MPFVideoDetailViewController *weakSelf = self;
        
        _inputView.atFriendButtonDidClicked = ^{
            @strongify(self)
            [self atFriends];
        };
        
        _inputView.sendButtonDidClicked = ^(NSString *msg){
            @strongify(self)
            [self submitComment:msg];
            
            [MPUmeng event:@"detail_comment_send_click"];
        };
        
        _inputView.keyBoardWillShow = ^(CGFloat keyboardHeight){
            
            // 暂停播放器的倒计时功能
            if(MPFVideoPlayerManagerInstance.superVideoPlayer.isCountDown)
            {
                [MPFVideoPlayerManagerInstance.superVideoPlayer cancelCountDownPlayNextVideo];
            }
            
            //
            PageType showingPageType = [MPTTool prestingPage];
            if(showingPageType >= 0)
            {
                NSString *source = [MPSAppStatisticsSingle videoPlayStatisticSourcePage];
                
                NSString *strVideoId = weakSelf.originalModel.scid;
                if(MPT_Str_Not_Valid(strVideoId))
                {
                    strVideoId = weakSelf.channelModel.scid;
                }
                NSString *strContentId = weakSelf.originalModel.contentId;
                if(MPT_Str_Not_Valid(strContentId))
                {
                    strContentId = weakSelf.channelModel.contentId;
                }
                NSString *strImpressionId = weakSelf.originalModel.impressionId;
                if(MPT_Str_Not_Valid(strImpressionId))
                {
                    strImpressionId = weakSelf.channelModel.impressionId;
                }
                NSDictionary *dicTemp = @{
                                          @"source":MPT_Str_Protect(source),
                                          @"channelId":MPT_Str_Protect([MPSAppStatisticsSingle channelID]),
                                          @"videoId":MPT_Str_Protect(strVideoId),
                                          @"contentId":MPT_Str_Protect(strContentId),
                                          @"impressionId":MPT_Str_Protect(strImpressionId),
                                          };
                [MPFAppStatisticsSingleInstance delayStatisticMethod:dicTemp withEvevtName:@"comment_show"];
            }
            
            @strongify(self)
            self.enputView.shareButton.hidden = YES;
            self.enputView.likeButton.hidden = YES;
            [self.contentView bringSubviewToFront:self.enputView];
        };
        
        _inputView.keyBoardWillHide = ^{
            @strongify(self)
            self.enputView.shareButton.hidden = NO;
            self.enputView.likeButton.hidden = NO;
            
            if (self.showKeyboard)
            {
                self.showKeyboard = NO;
            }
        };
    }
    
    return _inputView;
}

- (UIView *)playerView
{
    if (!_playerView)
    {
        _playerView = [UIView new];
        self.thumb = [UIImageView new];
        self.thumb.contentMode = UIViewContentModeScaleAspectFill;
        self.thumb.backgroundColor = [UIColor blackColor];
        self.thumb.image = [UIImage imageNamed:@"detailVideoDefautimage"];
        self.thumb.clipsToBounds = YES;
        [_playerView addSubview:self.thumb];
        [self.thumb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_playerView);
        }];
        _playerView.tag = 1000000;
    }
    
    return _playerView;
}

- (MPFVideoDetailInputControlView *)enputView
{
    if (!_enputView)
    {
        _enputView = [MPFVideoDetailInputControlView new];
        
        [_enputView updateLikeStatus_NoAnimation:NO andPraisedNumber:0];
        
        @weakify(self)
        
        _enputView.shareButtonDidClicked = ^{
            @strongify(self)
            [self commentInptBarShareAction];
            return;
        };
        
        _enputView.likeButtonDidClicked = ^(BOOL like){
            @strongify(self)
            [self commentInputBarLikeAction:like];
        };
        
        /// 点击了键盘
        [_enputView setMPHKeyWordClickedBlock:^{
            @strongify(self)
            if (self.twoFlowerisShow == NO)
            {
                [self.inputView activeIsFormeErJiPinglun:NO];
                [self stopTimeDown];
            }
        }];
        
        // 点击评论
        _enputView.commentButtonDidClicked = ^{
            @strongify(self)
            /// 更新播放器大小
            [self.playerView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo((MPT_ScreenW*9/16.0f));
            }];
            [self.contentView layoutIfNeeded];
            
            [self changeTableViewOffset];
            [self stopTimeDown];
            return;
        };
    }
    
    return _enputView;
}


@end
