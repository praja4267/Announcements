//
//  LandingPageViewController.m
//  lymo
//
//  Created by Active Mac06 on 02/11/15.
//  Copyright © 2015 techActive. All rights reserved.
//

#import "LandingPageViewController.h"
#import "SliderViewController.h"
#import "Constants.h"
//#import <GoogleMapsM4B/GoogleMaps.h>
#import <GoogleMaps/GoogleMaps.h>
#import "AFNHelper.h"
#import "AppDelegate.h"
#import "CarTypeDataModal.h"
#import "lymoSingleton.h"
#import "UIImageView+Download.h"
#import "FavouriteListVC.h"
#import "PulsingHaloLayer.h"
#import "REFrostedViewController.h"
#import "FareEstimateViewController.h"
#import "RideCompleteVC.h"
#import "CancelTableViewCell.h"
#import <sys/utsname.h>
#import "CardListViewController.h"
#import "OutStandingPaymentsViewController.h"
#import "RideCancelledPaymentViewController.h"

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiansToDegrees(x) (x * 180.0 / M_PI)


static dispatch_once_t onceToken;
static dispatch_once_t onceTokenForBack;

@interface LandingPageViewController ()<UIPageViewControllerDataSource,SliderViewControllerDelegate,UISearchBarDelegate,GMSMapViewDelegate,UIGestureRecognizerDelegate, FavouriteListVCDelegate, FareEstimateViewControllerDelegate, CardListViewControllerDelegate> {
    UIPageControl *currentPageControl;
    UIView *myView1,*viewForPicker,*expandView,*startRideExpandView;
    int heightForView;
    UIDatePicker *datePicker;
    UIToolbar *datePickerToolbar;
    GMSMapView *mapView_;
    GMSMarker *client_marker,*driver_marker,*markerOwnerDest,*markerOwner;
    NSString *strProviderPhone,*strTime,*strDistance,*strForDestLat,*strForDestLong,*strForProviderLat,*strForProviderLong,*strForLongitude,*strForLatitude,*strForCurLatitude,*strForCurLongitude,*strForRequestID,*strForCurrentPage,*strForDestinationLongitude,*strForDestinationLatitude,*strForWalkerPhone,*strForAddFavText,*strForAddFavLat,*strForAddFavLong,*strForRideLaterDate,*strForZoneID, *strForCurFavLatitude, *strForCurFavLongitude, *strForDesFavtLat, *strForDestFavLong, *LandingPageSearchingTextField;
    NSDate *recentlySelectedDate;
    NSMutableArray *arrForInformation,*arrForApplicationType,*arrForAddress,*arrDriver,*arrType,*arrCarTypeCount,*arrForApplicationTypeId,*cancelReasonID,*cancelReasonText,*arrPath,*arrForApplicationTypeCarIcon,*arrPathTemp, *arrFavLat, *arrFavLong;
    CLLocationManager *locationManager;
    BOOL isCarType,startRideEnable,navigationBarView,promoApplied,navBackPressedBool,isProvoider, isDriverResponseLocationArrayEmpty, isFirstTime;
    NSMutableDictionary *rateCardForIdDist,*rateCardForIdTime;
    NSTimer *timerForCheckReqStatus;
    UIButton *locationButton;
    
    //String for Start Ride
    NSString *strForSourceAddress,*strForDestinationAddress,*lastWalkerId;
    
    //String for Ride complete
    NSString *rideCompleteTripID,*rideCompleteCarCatorgery,*rideCompleteDate,*rideCompleteTime,*rideCompletePayment,*rideCompletePrice,*rideCompleteMessage,*rideCompleteDriveIcon,*rideCompleteDriverName,*rideCompleteDriverCarCategory,*rideCompleteDriverCarNumber, *rideCompleteRequestId;
    
    //String for Cancel ride
    NSString *strForCancelReasonID,*strForCancelReasonText;
    
    float zoom;
    
    CLLocationCoordinate2D favDestinationCoordinate, oldCoordinateforBearing, ongoingRideSourceLatLong;
    NSString *enableLocationAccessMessage;
    double oldBearing;
    NSString *newIdString;
    NSUserDefaults *pref;
    UIColor *rideNowAndLaterActiveColor;
    UIColor *rideNowAndLaterDisabledColor;
    NSIndexPath *cancelTVCellSelectedIndexpath;
    BOOL move, is_secondary_type, isActivityControllershown, isRideLaterEnabled, firstLocationUpdate_, isLater, reloadAllCategories, changeOriginText, callrequestPath;
    NSString *rideNowCardImageUrl, *rideNowPaymentId, *rideNowLastFour, *rideNowCardName;
    NSString *oldLattitide, *oldLongitude;
    NSString *carNameString;
    UIImage *driverCarIcon;
    UIView *noInternetView;
    float animationTime, getRequestCallTime;
}
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property NSUInteger pageIndex;

//pulse
@property (nonatomic, weak) PulsingHaloLayer *halo;

//@property (strong, nonatomic) NSArray *pageTitles;

@end

@implementation LandingPageViewController

-(void)loadView{
    [super loadView];
    [self updateLocationManagerr];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    pref=[NSUserDefaults standardUserDefaults];
    [self resetLandingPageUserDefaults];
    _mapPinWidthConstraint.constant=27 ; //actual 34
    _mapPin.image= [UIImage imageNamed:@"mapPin"];
    carNameString= @"Executive";
//    [GMSMarker markerImageWithColor:[UIColor redColor]];
    _originTextFiled.text=@"";
    _destinationTextFiled.text=@"";
    strForLatitude=@"";
    strForCurLatitude=@"";
    strForCurFavLatitude=@"";
    strForCurFavLongitude=@"";
    strForDesFavtLat=@"";
    strForDestFavLong=@"";
    move=NO;
    isActivityControllershown=NO;
    callrequestPath=NO;
    isRideLaterEnabled=NO;
    firstLocationUpdate_=NO;
    reloadAllCategories=YES;
    strForLongitude=@"";
    strForCurLongitude=@"";
    oldBearing=0.0;
    strForCurLatitude = @"12.9507684";
    strForCurLongitude = @"77.5757981";
    
    animationTime=0.2;
    if ([[pref valueForKey:PREF_SETTING_GET_REQUEST_TIMER] floatValue]) {
        getRequestCallTime = [[pref valueForKey:PREF_SETTING_GET_REQUEST_TIMER] floatValue];
    }else{
        getRequestCallTime=10.0;
    }
    
    rideNowAndLaterActiveColor=[UIColor orbitYellowColor];
    rideNowAndLaterDisabledColor=[UIColor orbitYellowColor];
    _viewForSideMenuOnMapView.backgroundColor=[UIColor clearColor];
    _viewForSideMenuOnMapView.userInteractionEnabled=YES;
    self.frostedViewController.panGestureEnabled=YES;
    recentlySelectedDate = [NSDate date];
    [pref setBool:NO forKey:PREF_IS_FAV];
    isFirstTime=YES;
    isLater=NO;
    [_bookRideNowBtn setExclusiveTouch:YES];
    [_bookRideLaterBtn setExclusiveTouch:YES];
    
    cancelTVCellSelectedIndexpath=nil;
    enableLocationAccessMessage = [NSString stringWithFormat:@"Please Enable location access from Setting -> %@ -> Privacy -> Location services", [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey]];

    mapView_.settings.allowScrollGesturesDuringRotateOrZoom = NO;
//    mapView_.settings.scrollGestures=NO;
    #pragma mark - stop rotating the map
    mapView_.settings.rotateGestures = NO;
    mapView_.settings.tiltGestures = NO;
    _pageControl.userInteractionEnabled=NO;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREF_FARE_DESTINATIONTEXT];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREF_ADD_FAV_TEXT];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    //MapView
//    self.mapView.delegate = self;
//    self.mapView.mapType = MKMapTypeStandard;
//    self.mapView.showsUserLocation = YES;
//    _mapView.showsBuildings = YES;
//    _mapView.showsPointsOfInterest=YES;
    
    //String for notify current page
    strForCurrentPage=@"booking";
    
    //Search bar textfield
    _originTextFiled.delegate=self;
    _destinationTextFiled.delegate=self;
    _originTextFiled.enabled=NO;
    _destinationTextFiled.userInteractionEnabled=NO;
    _promoCodeTxt.delegate=self;
    _destinationView.userInteractionEnabled=YES;
    _originTextFieldHolder.userInteractionEnabled=YES;
    //_pageTitles = @[@"Premium", @"Business Class", @"First Class", @"Diamond"];
    arrPath=[[NSMutableArray alloc]init];
    arrPathTemp = [[NSMutableArray alloc]init];
    arrForApplicationType=[[NSMutableArray alloc]init];
    arrForApplicationTypeCarIcon=[[NSMutableArray alloc]init];
    arrForApplicationTypeId=[[NSMutableArray alloc]init];
    arrCarTypeCount=[[NSMutableArray alloc]init];
    rateCardForIdDist=[[NSMutableDictionary alloc]init];
    rateCardForIdTime=[[NSMutableDictionary alloc]init];
    arrDriver=[[NSMutableArray alloc]init];
    cancelReasonID=[[NSMutableArray alloc]init];
    cancelReasonText=[[NSMutableArray alloc]init];
    arrFavLat=[[NSMutableArray alloc]init];
    arrFavLong=[[NSMutableArray alloc]init];
    _bookLocationBtn.hidden=YES;
    isDriverResponseLocationArrayEmpty = YES;
    changeOriginText=YES;
//    _promocodeContainerView.backgroundColor = [UIColor redColor];
    //self.pageViewController.view.backgroundColor= [[UIColor blackColor] colorWithAlphaComponent:0.3];
    
    //    UIView *myView1 = [[UIView alloc] initWithFrame: CGRectMake(0, self.view.frame.size.height-370, self.view.frame.size.width, 180)];
    //    myView1.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    //    [_mapView addSubview:myView1];
    
    /* myView1 = [[UIView alloc] initWithFrame: CGRectMake(0, self.view.frame.size.height-370, self.view.frame.size.width, 180)];
     myView1.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
     [_mapView addSubview:myView1];
     
     [self addChildViewController:_pageViewController];
     [myView1 addSubview:_pageViewController.view];
     [self.pageViewController didMoveToParentViewController:nil];
     
     [myView1 bringSubviewToFront:self.pageControl];*/
    
    
    
    //Rate Card hidden
    _rateCardView.hidden=YES;
    
    _rateCardSubView.layer.borderColor = [UIColor colorWithRed:0.831 green:0.831 blue:0.831 alpha:1].CGColor;
    _rateCardSubView.layer.borderWidth = 0.5f;
    _rateCardSubView.layer.cornerRadius = 2;
    _rateCardSubView.clipsToBounds=YES;
    
    //RideLater hidden
    _rideLaterBigView.hidden=YES;
    _navBackView.hidden=YES;
    _rideLaterPopupBigView.hidden=YES;
    
    //RideLater pop up view
    _rideLaterPopupView.layer.borderColor = [UIColor colorWithRed:0.831 green:0.831 blue:0.831 alpha:1].CGColor;
    _rideLaterPopupView.layer.borderWidth = 0.5f;
    _rideLaterPopupView.layer.cornerRadius = 2;
    _rideLaterPopupView.clipsToBounds=YES;
    
    //RideNow hiddenF
    _rideNowBigView.hidden=YES;
    _confromRideLbl.hidden=YES;
    _promoCodeBigView.hidden=YES;
    
    //promo code call view
    _promoCodeView.layer.borderColor = [UIColor colorWithRed:0.831 green:0.831 blue:0.831 alpha:1].CGColor;
    _promoCodeView.layer.borderWidth = 0.5f;
    _promoCodeView.layer.cornerRadius = 2;
    _promoCodeView.clipsToBounds=YES;
    
    _promoCodeTxt.layer.borderColor = [UIColor colorWithRed:0.831 green:0.831 blue:0.831 alpha:1].CGColor;
    _promoCodeTxt.layer.borderWidth = 0.5f;
    _promoCodeTxt.layer.cornerRadius = 2;
    _promoCodeTxt.clipsToBounds=YES;
    
    //Destination View hidden
    _destinationView.hidden=YES;
    
    //Start ride view hidden
    _startRideDetailBigView.hidden=YES;
    _startRideLocationBtn.hidden=YES;
    _startRideView.hidden=YES;
    _lymoArrivingLbl.hidden=YES;
    _cancelAlertBigView.hidden=YES;
    _driverCallBigView.hidden=YES;
    
    //Surge pop up view
    _surgeBigView.hidden=YES;
    
    //no cars available Alert Message
    _noCarsAvailableHolderView.hidden=YES;
    
    //Map pin
    _mapPin.hidden=NO; //chnaged on17062016;
    
    //Driver call view
    _driverCallView.layer.borderColor = [UIColor colorWithRed:0.831 green:0.831 blue:0.831 alpha:1].CGColor;
    _driverCallView.layer.borderWidth = 0.5f;
    _driverCallView.layer.cornerRadius = 2;
    _driverCallView.clipsToBounds=YES;
    
    //start ride cornor radius
    _startRideView.layer.borderColor = [UIColor colorWithRed:0.831 green:0.831 blue:0.831 alpha:1].CGColor;
    _startRideView.layer.borderWidth = 0.5f;
    _startRideView.layer.cornerRadius = 2;
    _startRideView.clipsToBounds=YES;
    
    _startRideDetailBigView.layer.borderColor = [UIColor colorWithRed:0.831 green:0.831 blue:0.831 alpha:1].CGColor;
    _startRideDetailBigView.layer.borderWidth = 0.5f;
    _startRideDetailBigView.layer.cornerRadius = 2;
    _startRideDetailBigView.clipsToBounds=YES;
    
    _startRideDetailIcon.layer.cornerRadius = 2;
    _startRideDetailIcon.clipsToBounds=YES;
    
    _startRideIcon.layer.cornerRadius = 2;
    _startRideIcon.clipsToBounds=YES;
    
    //Ride now corner radius
    _RideNowView.layer.borderColor = [UIColor colorWithRed:0.831 green:0.831 blue:0.831 alpha:1].CGColor;
    _RideNowView.layer.borderWidth = 0.5f;
    _RideNowView.layer.cornerRadius = 2;
    _RideNowView.clipsToBounds=YES;
    
    //Ride Later corner radius
    _RideLaterView.layer.borderColor = [UIColor colorWithRed:0.831 green:0.831 blue:0.831 alpha:1].CGColor;
    _RideLaterView.layer.borderWidth = 0.5f;
    _RideLaterView.layer.cornerRadius = 2;
    _RideLaterView.clipsToBounds=YES;
    
    //Surge popup corner radius
    _surgeView.layer.borderColor = [UIColor colorWithRed:0.831 green:0.831 blue:0.831 alpha:1].CGColor;
    _surgeView.layer.borderWidth = 0.5f;
    _surgeView.layer.cornerRadius = 2;
    _surgeView.clipsToBounds=YES;
    
        ALog(@"first time lattitide = %@",strForCurLatitude);
        ALog(@"first time Longitude = %@",strForCurLongitude);
        strForLatitude=strForCurLatitude;
        strForLongitude=strForCurLongitude;
        [_navOriginFavBtn setImage:[UIImage imageNamed:@"Fav_btn"] forState:UIControlStateNormal];
        [_destinationFavBtn setImage:[UIImage imageNamed:@"Fav_btn"] forState:UIControlStateNormal];
    
    expandView = [[UIView alloc] initWithFrame: CGRectMake(0, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    expandView.backgroundColor = [UIColor clearColor];
//    expandView.backgroundColor = [UIColor cyanColor];
    startRideExpandView = [[UIView alloc] initWithFrame: CGRectMake(0, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    startRideExpandView.backgroundColor = [UIColor clearColor];
//    startRideExpandView.backgroundColor = [UIColor redColor];
    
    
    //Enable Gesture action for Rate cards
    UITapGestureRecognizer *rateCardViewtapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rateCardViewGesture:)];
    _rateCardView.userInteractionEnabled = YES;
    [_rateCardView setExclusiveTouch:YES];
    [_rateCardView addGestureRecognizer:rateCardViewtapRecognizer];
    
    //Enable Gesture action for ride now promo code
    UITapGestureRecognizer *promoCodeViewtapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(promoCodeViewGesture:)];
    _rideNowPromoView.userInteractionEnabled = YES;
    [_rideNowPromoView setExclusiveTouch:YES];
    [_rideNowPromoView addGestureRecognizer:promoCodeViewtapRecognizer];
    
    //Enable Gesture action for ride now Fare Estimate
    UITapGestureRecognizer *rideNowFareEstimateViewtapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rideNowFareEstimateViewGesture:)];
    _rideNowFareEstimateView.userInteractionEnabled = YES;
    [_rideNowFareEstimateView setExclusiveTouch:YES];
    [_rideNowFareEstimateView addGestureRecognizer:rideNowFareEstimateViewtapRecognizer];
    
    //Enable Gesture action for ride now  Payment
    UITapGestureRecognizer *rideNowPaymentViewtapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rideNowPaymentViewGesture:)];
    _rideNowPaymentView.userInteractionEnabled = YES;
    [_rideNowPaymentView setExclusiveTouch:YES];
    [_rideNowPaymentView addGestureRecognizer:rideNowPaymentViewtapRecognizer];
    
    //Enable Gesture action for NavBackButton
    UITapGestureRecognizer *navBackViewtapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navBackViewGesture:)];
    _navBackView.userInteractionEnabled = YES;
    [_navBackView setExclusiveTouch:YES];
    [_navBackView addGestureRecognizer:navBackViewtapRecognizer];
    
    //Enable Gesture action for rideLaterDateLabel
    UITapGestureRecognizer *rideLaterDateLabeltapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rideLaterDateLabelGesture:)];
    _rideLaterDateLabel.userInteractionEnabled = YES;
    [_rideLaterDateLabel setExclusiveTouch:YES];
    [_rideLaterDateLabel addGestureRecognizer:rideLaterDateLabeltapRecognizer];
    
    UITapGestureRecognizer *rideLaterPickupLabeltapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rideLaterDateLabelGesture:)];
    _rideLaterPickupAtLabel.userInteractionEnabled = YES;
    [_rideLaterPickupAtLabel setExclusiveTouch:YES];
    [_rideLaterPickupAtLabel addGestureRecognizer:rideLaterPickupLabeltapRecognizer];
    
    //Enable Gesture action for ride Later promo code
    UITapGestureRecognizer *promoCodeRideLaterViewtapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(promoCodeViewGesture:)];
    _rideLaterPromoView.userInteractionEnabled = YES;
     [_rideLaterPromoView setExclusiveTouch:YES];
    [_rideLaterPromoView addGestureRecognizer:promoCodeRideLaterViewtapRecognizer];
    
    
    //Enable Gesture action for ride Later Fare Estimate
    UITapGestureRecognizer *rideLaterFareEstimateViewtapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rideNowFareEstimateViewGesture:)];
    _rideLaterFareEstimateView.userInteractionEnabled = YES;
    [_rideLaterFareEstimateView addGestureRecognizer:rideLaterFareEstimateViewtapRecognizer];
    
    //Enable Gesture action for ride Later  Payment
    UITapGestureRecognizer *rideLaterPaymentViewtapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rideNowPaymentViewGesture:)];
    _rideLaterPaymentView.userInteractionEnabled = YES;
    [_rideLaterPaymentView setExclusiveTouch:YES];
    [_rideLaterPaymentView addGestureRecognizer:rideLaterPaymentViewtapRecognizer];
    
    //Enable Gesture action for Start ride page walker details
    UITapGestureRecognizer *startRideDetailsViewtapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectStartRideWalkerGesture:)];
    _startRideView.userInteractionEnabled = YES;
    [_startRideView setExclusiveTouch:YES];
    [_startRideView addGestureRecognizer:startRideDetailsViewtapRecognizer];
    
    UITapGestureRecognizer *startRideViewtapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectStartRideWalkerDetailsGesture:)];
    _startRideDetailView.userInteractionEnabled = YES;
     [_startRideDetailView setExclusiveTouch:YES];
    [_startRideDetailView addGestureRecognizer:startRideViewtapRecognizer];
    
    UITapGestureRecognizer *startRideDetailsNumbertapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectStartRideDetailsNumberGesture:)];
    _startRideDetailCallDriverView.userInteractionEnabled = YES;
     [_startRideDetailCallDriverView setExclusiveTouch:YES];
    [_startRideDetailCallDriverView addGestureRecognizer:startRideDetailsNumbertapRecognizer];
    
    UITapGestureRecognizer *startRideDetailsCanceltapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectStartRideDetailsCancelGesture:)];
    _startRideDetailCancelView.userInteractionEnabled = YES;
     [_startRideDetailCancelView setExclusiveTouch:YES];
    [_startRideDetailCancelView addGestureRecognizer:startRideDetailsCanceltapRecognizer];
    
    UITapGestureRecognizer *searchGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openOriginSearchBarController:)];
    [_originTextFieldHolder addGestureRecognizer: searchGesture];
    _originTextFieldHolder.userInteractionEnabled = YES;
     [_originTextFieldHolder setExclusiveTouch:YES];
    UITapGestureRecognizer *searchDestinationGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openDestinationSearchController:)];
    [_destinationTextFieldHolder addGestureRecognizer: searchDestinationGesture];
    _destinationTextFieldHolder.userInteractionEnabled = YES;
     [_destinationTextFieldHolder setExclusiveTouch:YES];
    UITapGestureRecognizer *startRideDetailsSharetapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectStartRideDetailsShareGesture:)];
    _startRideDetailShareView.userInteractionEnabled = YES;
     [_startRideDetailShareView setExclusiveTouch:YES];
    [_startRideDetailShareView addGestureRecognizer:startRideDetailsSharetapRecognizer];
    
    UITapGestureRecognizer *promocodeMovingGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidePromocodeKeyboard:)];
    _promocodeContainerView.userInteractionEnabled = YES;
     [_promocodeContainerView setExclusiveTouch:YES];
    [_promocodeContainerView addGestureRecognizer:promocodeMovingGesture];

    _cancelTableView.tableFooterView = [UIView new];
    
    _pulseView.hidden=YES;
    
    //  Pulse
    PulsingHaloLayer *layer = [PulsingHaloLayer layer];
    self.halo = layer;
    [self.pulseView.layer insertSublayer:self.halo below:nil];
    [self setupInitialValues];
    
    //Alert view
    customAlertView = [[CustomIOSAlertView alloc] init];
    [customAlertView setButtonTitles:[NSMutableArray arrayWithObjects:@"OK", nil]];
    [customAlertView setDelegate:self];
    [customAlertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        ALog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertView tag]);
        [alertView close];
    }];
    [customAlertView setUseMotionEffects:true];
    [pref setBool:NO forKey:PREF_SHOW_BOARDING_SCREEN];
    
    UILongPressGestureRecognizer * rec = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longpressed:)];
    [rec setNumberOfTapsRequired:1];
    rec.minimumPressDuration=1.0;
    mapView_.gestureRecognizers=@[rec];
    [mapView_ addGestureRecognizer:rec];
    mapView_.settings.consumesGesturesInView=NO;
    
    // for getting current locatoion using gms mapview following data kvc is used.
    
    [mapView_ addObserver:self
               forKeyPath:@"myLocation"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    // Ask for My Location data after the map has already been added to the UI.
    dispatch_async(dispatch_get_main_queue(), ^{
        mapView_.myLocationEnabled = YES;
    });
    noInternetView = [[UIView alloc] initWithFrame:CGRectMake(0, 67, self.view.frame.size.width, self.view.frame.size.height)];
    noInternetView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:noInternetView];
    noInternetView.hidden=YES;
    [APPDELEGATE startLoader:self.view giveSpaceFornavigationBar:NO];
    
    UITapGestureRecognizer *noInternetGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkForInternet:)];
    noInternetView.userInteractionEnabled = YES;
    [noInternetView setExclusiveTouch:YES];
    [noInternetView addGestureRecognizer:noInternetGesture];
    _surgeDescriptionLabel.text=SURGE_DESCRIPTION;
}



- (void)checkForInternet:(UITapGestureRecognizer*)sender
{
    if ([APPDELEGATE connected]) {
        noInternetView.hidden=YES;
        if (callrequestPath) {
            [self requestPath];
        }
    }else{
        noInternetView.hidden=NO;
        [customAlertView setContainerView:[APPDELEGATE createDemoView:NO_INTERNET view:self.view]];
        [customAlertView show];
    }

}

- (void)longpressed:(UILongPressGestureRecognizer*)gesture
{
    if ( gesture.state == UIGestureRecognizerStateBegan ) {
        
        ALog(@"long press starteds");
    }
    if ( gesture.state == UIGestureRecognizerStateEnded ) {
        
         ALog(@"long press ended");
    }
}
- (void) makeExclusiveTouchForViews:(NSArray*)views {
    for (UIView * view in views) {
        [self makeExclusiveTouch:view];
    }
}

- (void) makeExclusiveTouch :(UIView * )view {
    ALog(@"exclusive touch setting for view %@", view);
    view.multipleTouchEnabled = NO;
    view.exclusiveTouch = YES;
    [self makeExclusiveTouchForViews:view.subviews];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    ALog(@"view did appear is called");
//    strForLatitude=strForCurLatitude;
//    strForLongitude=strForCurLongitude;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    
}

-(void)dealloc
{
    mapView_=nil;
    _originTextFiled.text=@"";
    _destinationTextFiled.text=@"";
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"dataFromSearch" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"fareEstimation" object:nil];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.halo.position = self.view.center;
    // [self.viewGoogleScrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    isActivityControllershown=YES;
    markerOwnerDest =nil;
    markerOwner=nil;
    [pref removeObjectForKey:PREF_CATEGORY_TYPE_ID];
    ALog(@"landing page view will appear");
//    [mapView_ clear];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"dataFromSearch" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"fareEstimation" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchPageNotification:) name:@"dataFromSearch" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fareEstimateViewNotification:) name:@"fareEstimation" object:nil];
    
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    _bookRideLaterBtn.enabled=NO;
    _bookRideNowBtn.enabled=NO;
    [_bookRideNowBtn setTitleColor:rideNowAndLaterDisabledColor forState:UIControlStateNormal];
    [_bookRideLaterBtn setTitleColor:rideNowAndLaterDisabledColor forState:UIControlStateNormal];

    if ([[NSUserDefaults standardUserDefaults] objectForKey:PREF_FAV_COUNT]) {
        ALog(@"favouritres count key is available ----> )");
        ALog(@"the favoutrites count is %@",[[NSUserDefaults standardUserDefaults] objectForKey:PREF_FAV_COUNT]);
        if ([[NSUserDefaults standardUserDefaults] boolForKey:PREF_FAV_COUNT] == NO) {
                ALog(@"favouritres count is zero so dont select any favourite places------------>    ;)");
                [_navOriginFavBtn setImage:[UIImage imageNamed:@"Fav_btn"] forState:UIControlStateNormal];
                [_destinationFavBtn setImage:[UIImage imageNamed:@"Fav_btn"] forState:UIControlStateNormal];
        }
    }

    SliderViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SliderViewController"];
    pageContentViewController.sliderDelegate=self;
    if(heightForView == 155){
        pageContentViewController.viewStatus=NO;
    }else if(heightForView == 235){
        pageContentViewController.viewStatus=YES;
    }
    self.pageViewController.dataSource = self;
    
    NSObject * object = [pref objectForKey:PREF_PAYMENT_OPT];   // 0 -> card payment , 1 -> cash paymnet
    NSString *stringID=@"0";   // card payment
    if([object isEqual: stringID] && [[pref valueForKey:PREF_SETTING_CARD_PAYMENT] boolValue]){
        
        _rideNowPaymentCardName.text = [pref objectForKey:PREF_PAYMENT_CARD_NAME];
        _rideLaterPaymentCardName.text = [pref objectForKey:PREF_PAYMENT_CARD_NAME];
       
        [_rideNowPaymentCardIcon downloadFromURL:[pref objectForKey:PREF_PAYMENT_CARD_ICON] withPlaceholder:nil];
        [_rideLaterPaymentCardIcon downloadFromURL:[pref objectForKey:PREF_PAYMENT_CARD_ICON] withPlaceholder:nil];
        [self paymentToggle];
    } else {  // cash paymnet
        [pref setValue:@"Cash" forKey:PREF_PAYMENT_CARD_NAME];
        [pref setValue:@"Cash_Money" forKey:PREF_PAYMENT_CARD_ICON];
        [pref synchronize];
        _rideNowPaymentCardName.text = [pref objectForKey:PREF_PAYMENT_CARD_NAME];
        _rideLaterPaymentCardName.text = [pref objectForKey:PREF_PAYMENT_CARD_NAME];
        _rideNowPaymentCardIcon.image=[UIImage imageNamed:[pref objectForKey:PREF_PAYMENT_CARD_ICON]];
        _rideLaterPaymentCardIcon.image=[UIImage imageNamed:[pref objectForKey:PREF_PAYMENT_CARD_ICON]];
        [self paymentToggle];
    }
//    _noCarsAvailableHolderView.hidden=YES;
    onceToken=0;
    onceTokenForBack=0;

    
    if (_lymoArrivingLbl.hidden == NO) {
        _destinationView.userInteractionEnabled=NO;
        _originTextFieldHolder.userInteractionEnabled=NO;
    }else if (_confromRideLbl.hidden == NO){
        _destinationView.userInteractionEnabled=YES;
        _originTextFieldHolder.userInteractionEnabled=NO;
    }else{
        _destinationView.userInteractionEnabled=YES;
        _originTextFieldHolder.userInteractionEnabled=YES;
    }

//    [self setFavouriteButtonColor];
}
- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"dataFromSearch" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"fareEstimation" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//    self.pageViewController.dataSource = nil;
    [customAlertView close];
    [customAlertViewForLocation close];
    isActivityControllershown=YES;
//    driver_marker.map = nil;
//    driver_marker=nil;
//    NSUInteger currentIndex = [_modelArray indexOfObject:[contentVc model]];
//    _vcIndex = currentIndex;

}


#pragma mark - getCurrentLocation using gms mapview

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (!firstLocationUpdate_) {
        // If the first location update has not yet been recieved, then jump to that
        // location.
        firstLocationUpdate_ = YES;
        CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
        ALog(@"first location update = %f, %f", location.coordinate.latitude, location.coordinate.longitude);
        mapView_.camera = [GMSCameraPosition cameraWithTarget:location.coordinate
                                                         zoom:16];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    ALog(@"memory warning in landingpageview controller");
    // Dispose of any resources that can be recreated.
}

#pragma mark - initiate page view controller

-(void)initiatePageViewController {
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    
    SliderViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0,0, self.view.frame.size.width, 360);
    
    UIScrollView* pageView = nil;
    UIPageControl* pageControl = nil;
    
    UIView* selfView = self.pageViewController.view;
    NSArray* subviews = selfView.subviews;
    for( NSInteger i = 0 ; i < subviews.count && ( pageView == nil || pageControl == nil ) ; i++ )
    {
        UIView* t = subviews[i];
        if( [t isKindOfClass:[UIScrollView class]] )
        {
            pageView = (UIScrollView*)t;
        }
        else if( [t isKindOfClass:[UIPageControl class]] )
        {
            currentPageControl = (UIPageControl*)t;
        }
    }
    
    if( pageView != nil && currentPageControl != nil )
    {
        
        [pageView setClipsToBounds:NO];
        
    }
    // _pageTitles=arrForApplicationType;
    [self.pageControl setNumberOfPages:[arrForApplicationType count]];
    [self changeHeight:155 viewPosition:225];
    
}


-(void) removePageViewControllerInLandingPage {
        //Here no cars are available so remove the slider view and display service not available message
        if(navigationBarView){
            [self changeHeight:155 viewPosition:225];
            _navigationView.hidden=NO;
            _noCarsAvailableHolderView.hidden=NO;
            navigationBarView=NO;
        }
        [myView1 removeFromSuperview];
        [locationButton removeFromSuperview];
        [expandView removeFromSuperview];
        
        [mapView_ clear];
        _pageControl.hidden=YES;
        if (_pulseView.hidden) {
            _noCarsAvailableHolderView.hidden=NO;
        }
        
        _bookLocationBtn.hidden=NO;
        
        _bookRideLaterBtn.enabled=NO;
        _bookRideNowBtn.enabled=NO;
        [_bookRideNowBtn setTitleColor:rideNowAndLaterDisabledColor forState:UIControlStateNormal];
        [_bookRideLaterBtn setTitleColor:rideNowAndLaterDisabledColor forState:UIControlStateNormal];
}

-(void)changeHeight:(int)height viewPosition:(int)position{
    [myView1 removeFromSuperview];
    [locationButton removeFromSuperview];
    [expandView removeFromSuperview];
    locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [locationButton addTarget:self
                       action:@selector(bookLocationBtn:)
             forControlEvents:UIControlEventTouchUpInside];
    [locationButton setImage:[UIImage imageNamed:@"location"] forState:UIControlStateNormal];
    locationButton.frame = CGRectMake(self.view.frame.size.width-(14+40),self.view.frame.size.height-position-(8+40), 40, 40);
    if(height == 155){
        [expandView removeFromSuperview];
        [_viewGoogleMap addSubview:locationButton];
        //_mapPin.hidden=NO;
        //        CGPoint offset=CGPointMake(0, 0);
        //        [self.viewGoogleScrollView setContentOffset:offset animated:YES];
    }else{
        [_viewGoogleMap addSubview:expandView];
        [locationButton removeFromSuperview];
        //_viewGoogleMap.frame = CGRectMake(_viewGoogleMap.frame.origin.x, self.view.frame.origin.y-200, _viewGoogleMap.frame.size.width, _viewGoogleMap.frame.size.height);
        //         CGPoint offset=CGPointMake(0, 220);
        //        [self.viewGoogleScrollView setContentOffset:offset animated:YES];
        // _mapPin.hidden=YES;
    }
    
    locationButton.hidden=NO;
    myView1 = [[UIView alloc] initWithFrame: CGRectMake(0, self.view.frame.size.height-position, self.view.frame.size.width, 1*height)];
    // myView1.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    [_viewGoogleMap addSubview:myView1];
    heightForView = height;
    self.pageViewController.dataSource=self;
    [self addChildViewController:_pageViewController];
    [myView1 addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:nil];
    [myView1 bringSubviewToFront:self.pageControl];
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//    ALog(@"qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq");
    
    UITouch *touch = [[event touchesForView:expandView] anyObject];
    if(touch){
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"refreshCarDetailsView"
         object:self];
    }
    
    UITouch *startRide = [[event touchesForView:startRideExpandView] anyObject];
    if(startRide){
        [self selectStartRideWalkerDetailsGesture:nil];
    }
}


-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *destinationSearchTouch = [[event touchesForView:_originTextFieldHolder] anyObject];
    if (destinationSearchTouch) {
        ALog(@"This is destination search textfeld ");
        return;
    }
    if (!_destinationTextFiled.isUserInteractionEnabled) {
        if (destinationSearchTouch) {
             ALog(@"This is destination search textfeld ");
            return;
        }
    }

}
- (SliderViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([arrForApplicationType count] == 0) || (index >= [arrForApplicationType count])) {
        [self.pageControl setCurrentPage:[currentPageControl currentPage]+1];
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    SliderViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SliderViewController"];
    pageContentViewController.sliderDelegate=self;
    if(heightForView == 155){
        pageContentViewController.viewStatus=NO;
    }else if(heightForView == 235){
        pageContentViewController.viewStatus=YES;
    }
    pageContentViewController.pageIndex = index;
    _pageIndex = index;
    pageContentViewController.titleText = arrForApplicationType[index];
    pageContentViewController.carIcon=arrForApplicationTypeCarIcon[index];
    
    if (_pageControl) {
        [self.pageControl setCurrentPage:[currentPageControl currentPage]];
        ALog(@"------------>     current page index = %ld  and viewcntlAtIndex = %lu<------------", (long)[currentPageControl currentPage], (unsigned long)index);
    }
    
    return pageContentViewController;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((SliderViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        [self.pageControl setCurrentPage:[currentPageControl currentPage]+1];
        return [self viewControllerAtIndex:[arrForApplicationType count]-1];
    }
    SliderViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SliderViewController"];
    if(heightForView == 155){
        pageContentViewController.viewStatus=NO;
    }else if(heightForView == 235){
        pageContentViewController.viewStatus=YES;
    }
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((SliderViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [arrForApplicationType count]) {
        [self.pageControl setCurrentPage:[currentPageControl currentPage]+1];
        return [self viewControllerAtIndex:0];
    }
    SliderViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SliderViewController"];
    if(heightForView == 155){
        pageContentViewController.viewStatus=NO;
    }else if(heightForView == 235){
        pageContentViewController.viewStatus=YES;
    }
    
    return [self viewControllerAtIndex:index];
}

//- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers
//{
//    SliderViewController *pageContentView = (SliderViewController*) [self.storyboard instantiateViewControllerWithIdentifier:@"SliderViewController"];
//    self.pageControl.currentPage = pageContentView.pageIndex;
//}


- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [arrForApplicationType count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

//984482



#pragma mark Slider page Delegate methods

-(void)SliderViewControllerDelegateMethod:(SliderViewController *)sender viewHeight:(int)height viewPosition:(int)position navigationBarHidden:(BOOL)hidden {
    self.pageViewController.dataSource=nil;
    [self changeHeight:height viewPosition:position];
    navigationBarView=hidden;
    if(hidden){
        self.view.userInteractionEnabled=NO;
        [UIView transitionWithView:mapView_
                          duration:0.0
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [self animateViewHeight:_navigationView withAnimationType:kCATransitionFromTop hidden:hidden];
                            self.view.userInteractionEnabled=YES;
                        }
                        completion:nil];
        _noCarsAvailableHolderView.hidden=YES;
    }else {
        self.view.userInteractionEnabled=NO;
        [UIView transitionWithView:mapView_
                          duration:0.0
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [self animateViewHeight:_navigationView withAnimationType:kCATransitionFromBottom show:YES];
                            self.view.userInteractionEnabled=YES;
                        }
                        completion:nil];
        //_noCarsAvailableHolderView.hidden=NO;
    }
}

-(void)bringRateCardView:(SliderViewController *)sender idString:(NSString *)idString index:(NSUInteger)index typeString:(NSString *)typeString{
    // _rateCardView.hidden=NO;
    
    _rateCardFirstCurrency.text=[NSString stringWithFormat:@"First %@ %@\n ",[self isInteger:[[rateCardForIdDist objectForKey:idString]objectAtIndex:1]], [pref valueForKey:PREF_SETTING_UNIT_SET]];
    _rateCardSecondCurrency.text=[NSString stringWithFormat:@"After %@ %@\n ", [self isInteger:[[rateCardForIdDist objectForKey:idString]objectAtIndex:1]], [pref valueForKey:PREF_SETTING_UNIT_SET]];
    _rateCardThirdCurrency.text=[NSString stringWithFormat:@"Ride Time Rate \nAfter %@ mins", [self isInteger:[[rateCardForIdTime objectForKey:idString]objectAtIndex:1]]];
    
    ALog(@"currency symbol = %@", [pref objectForKey:PREF_SETTING_CURRENCY_TEXT]);
    
    
    _rateCardFirstPrice.text=[NSString stringWithFormat:@"%@ %@",[pref objectForKey:PREF_SETTING_CURRENCY_TEXT], [self isInteger:[[rateCardForIdDist objectForKey:idString]objectAtIndex:0]]];
    _rateCardSecondPrice.text=[NSString stringWithFormat:@"%@ %@/%@",[pref objectForKey:PREF_SETTING_CURRENCY_TEXT], [self isInteger:[[rateCardForIdDist objectForKey:idString]objectAtIndex:2]], [pref valueForKey:PREF_SETTING_UNIT_SET]];
    _rateCardThirdPrice.text=[NSString stringWithFormat:@"%@ %@/min",[pref objectForKey:PREF_SETTING_CURRENCY_TEXT], [self isInteger:[[rateCardForIdTime objectForKey:idString]objectAtIndex:0]]];
    
    if ([[pref objectForKey:PREF_CATEGORY_BASE_FARE] isEqualToString:@"0.00"]) {
//        _baseFareViewHeightConstraint.constant=0;
        _baseFareViewHeightConstraint.constant=29;
        _baseFareLabel.text=@"NO BASE FARE";
        
    } else {
        _baseFareViewHeightConstraint.constant=29;
        _baseFareLabel.text=[NSString stringWithFormat:@"Base Fare = %@ %@", [pref objectForKey:PREF_SETTING_CURRENCY_TEXT], [pref objectForKey:PREF_CATEGORY_BASE_FARE]];
        
    }
    if ([[pref objectForKey:PREF_CATEGORY_MIN_FARE] isEqualToString:@"0.00"]) {
        _minimumFareViewHeightConstraint.constant=0;
    }else{
         _minimumFareViewHeightConstraint.constant=29;
        _minimumFareLabel.text=[NSString stringWithFormat:@"Minimum Fare = %@ %@", [pref objectForKey:PREF_SETTING_CURRENCY_TEXT], [pref objectForKey:PREF_CATEGORY_MIN_FARE]];
    }
    _surChargeLabel.text=@"NO SURCHARGES";
    
//    _rateCardSecondKMS.text=[NSString stringWithFormat:@"per %@", ];
//    _rateCardThirdKMS.text=@"per minute";
    _rateCardCarCatLbl.text=[arrForApplicationType objectAtIndex:index];
    //}
    _rateCardCarTypes.text=[NSString stringWithFormat:@"%@",typeString];
    self.view.userInteractionEnabled=NO;
    [UIView transitionWithView:nil
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:NULL
                    completion:^(BOOL finished){
                        [self.view bringSubviewToFront:_rateCardView];
                        [self animateViewHeight:_rateCardView withAnimationType:kCATransitionFade show:YES];
                        self.view.userInteractionEnabled=YES;
                    }];
}


-(void)checkCarsAvailabilityWithidString : (NSString*)idString {
    _bookRideNowBtn.enabled=NO;
    [_bookRideNowBtn setTitleColor:rideNowAndLaterDisabledColor forState:UIControlStateNormal];
    _bookRideLaterBtn.enabled=NO;
    [_bookRideLaterBtn setTitleColor:rideNowAndLaterDisabledColor forState:UIControlStateNormal];
    
    ALog(@"the category id = %@ and base fare = %@ and origin address is = %@ ", idString,[pref objectForKey:PREF_CATEGORY_BASE_FARE], _originTextFiled.text);
    if([strForCurrentPage isEqualToString:@"booking"]  && idString){
        if([APPDELEGATE connected])
        {
            [APPDELEGATE stopLoader:self.view];
            noInternetView.hidden=YES;
            [APPDELEGATE startLoader:self.view giveSpaceFornavigationBar:NO];
            NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
            [dictParam setValue:[pref objectForKey:PREF_USER_ID] forKey:PARAM_ID];
            [dictParam setValue:[pref objectForKey:PREF_USER_TOKEN] forKey:PARAM_TOKEN];
            [dictParam setValue:[pref objectForKey:PREF_LYMO_DEVICE_ID] forKey:PARAM_LYMO_DEVICE_ID];
            [dictParam setValue:idString forKey:PARAM_TYPE];
            [dictParam setValue:strForLatitude forKey:PARAM_USER_LATITUDE];
            [dictParam setValue:strForLongitude forKey:PARAM_USER_LONGITUDE];
            ALog(@"check cars availability with id string Provider Dictionary... %@",dictParam);
            
            AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
            [afn getDataFromPath:FILE_GET_PROVIDERS withParamData:dictParam withBlock:^(id response, NSError *error)
             {
                 //                 ALog(@"Response to Get Provider= %@",response);
                 if (response == Nil){
                      [APPDELEGATE stopLoader:self.view];
                     if (error.code == -1005) {
                         [self checkCarsAvailabilityWithidString:idString];
                         
                     }else {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [APPDELEGATE showAlertOnTopMostControllerWithText:UNABLE_TO_REACH];
                         });
//                         [customAlertView setContainerView:[APPDELEGATE createDemoView:UNABLE_TO_REACH view:self.view]];
//                         [customAlertView show];
                     }
                 }else if (response)
                 {
                     if([[response valueForKey:@"success"]boolValue]){
                         //[APPDELEGATE showToastMessage:[response valueForKey:@"message"]];
                         [[NSNotificationCenter defaultCenter]
                          postNotificationName:@"dataForArrivalTime"
                          object:[response valueForKey:@"arrival_time"]];
                         [pref setObject:[response valueForKey:@"arrival_time"] forKey:PREF_CATEGORY_TIME];
                         arrDriver=[response valueForKey:@"walker_list"];
                         
                         if([[pref valueForKey:PREF_SETTING_MENU_BOOK_RIDE] boolValue]) {
                             _noCarsAvailableHolderView.hidden=YES;
                             
                             if([[pref valueForKey:PREF_SETTING_RIDE_NOW] boolValue]){
                                 _bookRideNowBtn.enabled=YES;
                                 [_bookRideNowBtn setTitleColor:rideNowAndLaterActiveColor forState:UIControlStateNormal];
                             }else{
                                 _bookRideNowBtn.enabled=NO;
                                 [_bookRideNowBtn setTitleColor:rideNowAndLaterDisabledColor forState:UIControlStateNormal];
                             }
                             if([[pref valueForKey:PREF_SETTING_RIDE_LATER] boolValue]){
                                 if (isRideLaterEnabled) {
                                     _bookRideLaterBtn.enabled=YES;
                                     [_bookRideLaterBtn setTitleColor:rideNowAndLaterActiveColor forState:UIControlStateNormal];
                                 }
                                 if ([_originTextFiled.text isEqualToString:@"Please select proper location"]) {
                                     [self disableBothRideNowAndRideLater];
                                 }
                             }else{
                                 _bookRideLaterBtn.enabled=NO;
                                 [_bookRideLaterBtn setTitleColor:rideNowAndLaterDisabledColor forState:UIControlStateNormal];
                             }
                             [self showProvider];
                             
                         }else{
                             [myView1 removeFromSuperview];
                             [locationButton removeFromSuperview];
                             [expandView removeFromSuperview];
                             if (_pulseView.hidden) {
                                 _noCarsAvailableHolderView.hidden=NO;
                             }
                             
                             _noCarsAvailableLabel.text=@"Bookings are currently not available. Please try later";
                             
                             _pageControl.hidden=YES;
                             _bookLocationBtn.hidden=NO;
                             _navOriginFavBtn.enabled=NO;
                             _bookRideLaterBtn.enabled=NO;
                             _bookRideNowBtn.enabled=NO;
                             _navOriginFavBtn.enabled=NO;
                             
                             [_bookRideNowBtn setTitleColor:rideNowAndLaterDisabledColor forState:UIControlStateNormal];
                             [_bookRideLaterBtn setTitleColor:rideNowAndLaterDisabledColor forState:UIControlStateNormal];
                         }
                     }else {
                         [mapView_ clear];
                         //[APPDELEGATE showToastMessage:[response valueForKey:@"error"]];
                         [[NSNotificationCenter defaultCenter]
                          postNotificationName:@"dataForArrivalTime"
                          object:[response valueForKey:@"arrival_time"]];
                         
                         
                         if([[pref valueForKey:PREF_SETTING_MENU_BOOK_RIDE] boolValue]) {
                             _bookRideNowBtn.enabled=NO;
                             [_bookRideNowBtn setTitleColor:rideNowAndLaterDisabledColor forState:UIControlStateNormal];
                             if([[pref valueForKey:PREF_SETTING_RIDE_LATER] boolValue]){
                                 if (isRideLaterEnabled) {
                                     _bookRideLaterBtn.enabled=YES;
                                     [_bookRideLaterBtn setTitleColor:rideNowAndLaterActiveColor forState:UIControlStateNormal];
                                 }
                             }else{
                                 _bookRideLaterBtn.enabled=NO;
                                 [_bookRideLaterBtn setTitleColor:rideNowAndLaterDisabledColor forState:UIControlStateNormal];
                             }
                             if ([_originTextFiled.text isEqualToString:@"Please select proper location"]) {
                                 [self disableBothRideNowAndRideLater];
                             }
                         }else{
                             [myView1 removeFromSuperview];
                             [locationButton removeFromSuperview];
                             [expandView removeFromSuperview];
                             if (_pulseView.hidden) {
                                 _noCarsAvailableHolderView.hidden=NO;
                             }
                             _noCarsAvailableLabel.text=@"Bookings are currently not available. Please try later";
                             
                             _pageControl.hidden=YES;
                             _bookLocationBtn.hidden=NO;
                             
                             _bookRideLaterBtn.enabled=NO;
                             _bookRideNowBtn.enabled=NO;
                             _navOriginFavBtn.enabled=NO;
                             
                             [_bookRideNowBtn setTitleColor:rideNowAndLaterDisabledColor forState:UIControlStateNormal];
                             [_bookRideLaterBtn setTitleColor:rideNowAndLaterDisabledColor forState:UIControlStateNormal];
                         }
                         
                         //                         _bookRideLaterBtn.enabled=YES;
                         //                         _bookRideNowBtn.enabled=NO;
                         //                         [_bookRideNowBtn setTitleColor:[UIColor colorWithRed:0.529 green:0.816 blue:0.953 alpha:1] forState:UIControlStateNormal];
                         //                         [_bookRideLaterBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                         
                         
                         if(!navigationBarView){
                             /*  after checking cars available ot not. if cars are not available this error message is shown */
                             ALog(@"_No cars available alertMessageText.text is = %@", [response valueForKey:@"error"]);
                             [mapView_ clear];
                             _noCarsAvailableLabel.text=[response valueForKey:@"error"];
                             self.view.userInteractionEnabled=NO;
                             [UIView transitionWithView:mapView_
                                               duration:0.2
                                                options:UIViewAnimationOptionTransitionCrossDissolve
                                             animations:NULL
                                             completion:^(BOOL finished){
                                                 if (_noCarsAvailableHolderView.hidden) {
                                                     [self animateViewHeight:_noCarsAvailableHolderView withAnimationType:kCATransitionFromBottom show:YES];
                                                 }
                                                 self.view.userInteractionEnabled=YES;
                                             }];
                             if ([_originTextFiled.text isEqualToString:@"Please select proper location"]) {
                                 [self disableBothRideNowAndRideLater];
                             }
                             
                         }else{
                             _noCarsAvailableHolderView.hidden=YES;
                         }
                     }
                     [APPDELEGATE customerSetting:[response valueForKey:@"customer_setting"] ShowRideComplete:YES ShowCancelPayment:YES FromViewController:self];;
                     if ([[[response valueForKey:@"customer_setting"] valueForKey:@"card_payment"] boolValue]) {
                         [pref setObject:[[response valueForKey:@"customer_setting"] valueForKey:@"payment_id"] forKey:PREF_PAYMENT_ID];
                         [pref setObject:[[response valueForKey:@"customer_setting"] valueForKey:@"card_type"] forKey:PREF_PAYMENT_CARD_NAME];
                         [pref setObject:[[response valueForKey:@"customer_setting"] valueForKey:@"payment_mode"] forKey:PREF_PAYMENT_OPT];
                         if ([[[response valueForKey:@"customer_setting"] valueForKey:@"payment_mode"] boolValue]) {
                             [pref setObject:[[response valueForKey:@"customer_setting"] valueForKey:@"cash_url"] forKey:PREF_PAYMENT_CARD_ICON];
                         }else{
                             [pref setObject:[[response valueForKey:@"customer_setting"] valueForKey:@"card_url"] forKey:PREF_PAYMENT_CARD_ICON];
                         }
                     }else{
                         [pref setObject:@"" forKey:PREF_PAYMENT_ID];
                         [pref setObject:@"Cash" forKey:PREF_PAYMENT_CARD_NAME];
                         [pref setObject:@"1" forKey:PREF_PAYMENT_OPT];
                             [pref setObject:[[response valueForKey:@"customer_setting"] valueForKey:@"cash_url"] forKey:PREF_PAYMENT_CARD_ICON];
                     }
                 }
                 else
                 {
                     arrDriver=[[NSMutableArray alloc] init];
                 }
                 
                 [APPDELEGATE stopLoader:self.view];
             }];
           
        }
        else{
            [APPDELEGATE stopLoader:self.view];
            noInternetView.hidden=NO;
            [customAlertView setContainerView:[APPDELEGATE createDemoView:NO_INTERNET view:self.view]];
            [customAlertView show];
        }
    }
}

-(void)getProviders:(SliderViewController *)sender idString:(NSString *)idString{
    newIdString = idString;
    [self checkCarsAvailabilityWithidString:idString];
}

-(void)disableRideNowAndRideLaterButton{
    if([strForCurrentPage isEqualToString:@"booking"]){
        [mapView_ clear];
        _bookRideLaterBtn.enabled=NO;
        _bookRideNowBtn.enabled=NO;
        [_bookRideNowBtn setTitleColor:rideNowAndLaterDisabledColor forState:UIControlStateNormal];
        [_bookRideLaterBtn setTitleColor:rideNowAndLaterDisabledColor forState:UIControlStateNormal];
    }
}
-(void)showProvider
{
    [mapView_ clear];
//    [CATransaction begin];
    ALog(@"the number of cars available are %d", arrDriver.count);
    for (int i=0; i<arrDriver.count; i++)
    {
        NSDictionary *dict=[arrDriver objectAtIndex:i];
        ALog(@"the car details are %@", dict);
        driver_marker = [[GMSMarker alloc] init];
        if ([[dict valueForKey:@"ios_icon"] length] >1) {
            NSURL *imageURL = [NSURL URLWithString:[dict valueForKey:@"ios_icon"]];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                dispatch_async(dispatch_get_main_queue(), ^{
                    driverCarIcon=[UIImage imageWithData:imageData];
                    driver_marker.icon = driverCarIcon;
                    driver_marker.map = mapView_;
                    
                });
            });
        }else {
                driverCarIcon=[UIImage imageNamed:carNameString];
                 driver_marker.icon=driverCarIcon;
                driver_marker.map = mapView_;
         
//            [UIImage imageNamed:@"pin_driver"];
//                                        [UIImage imageNamed:@"pin_driver"];
//                                        [UIImage imageNamed:@"Mini"];
//                                        [UIImage imageNamed:@"Saloon"];
//                                            [UIImage imageNamed:@"Executive"]
        }
        
        driver_marker.position = CLLocationCoordinate2DMake([[dict valueForKey:@"latitude"]doubleValue],[[dict valueForKey:@"longitude"]doubleValue]);
//        driver_marker.rotation = [[dict valueForKey:@"bearing"]doubleValue];
    }
//    [CATransaction commit];
}



#pragma mark search page Delegate methods

- (void) searchPageNotification:(NSNotification *)notification{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:PREF_IS_FAV];
    [_destinationFavBtn setImage:[UIImage imageNamed:@"Fav_btn"] forState:UIControlStateNormal];
    if([strForCurrentPage isEqualToString:@"booking"]){
        if([[notification object]isEqualToString:@"currentLocation"]){
            [self getMyLocationIsPressed];
        }else{
//            _originTextFiled.text=[notification object];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:PREF_IS_FAV];
            [_destinationFavBtn setImage:[UIImage imageNamed:@"Fav_btn"] forState:UIControlStateNormal];
            [self getLocationFromAddressString:[notification object]];
            
            
        }
    }else if([strForCurrentPage isEqualToString:@"ridenow"] || [strForCurrentPage isEqualToString:@"ridelater"]){
        if([[notification object]isEqualToString:@"currentLocation"]){
            [self getMyLocationIsPressed];
        }else{
            if ( [[notification object]  isEqual: @""]) {
                if (isLater && [[pref valueForKey:PREF_SETTING_RIDE_LATER_DESTINATION] boolValue]) {
                    ALog(@"Ride later is mandatory but given empty address ======================");
                    return;
                }else if (!isLater && [[pref valueForKey:PREF_SETTING_RIDE_NOW_DESTINATION] boolValue]){
                    ALog(@"Ride now is mandatory but given empty address==========================");
                    return;
                }else{
                    markerOwnerDest=nil;
                     _destinationTextFiled.text=@"";
                    strForDestinationLatitude=@"";
                    strForDestinationLongitude=@"";
                    markerOwner.map=nil;
                     markerOwner=nil;
                    markerOwnerDest.map=nil;
                    markerOwnerDest=nil;
//                    [mapView_ clear];
                }
            } else {
                [self getLocationFromAddressString:[notification object]];
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:PREF_IS_FAV];
                [_destinationFavBtn setImage:[UIImage imageNamed:@"Fav_btn"] forState:UIControlStateNormal];
            }
            
        }
        
    }else if([strForCurrentPage isEqualToString:@"startride"]){
        if([[notification object]isEqualToString:@"currentLocation"]){
            [self getMyLocationIsPressed];
        }else{
            if ( [[notification object]  isEqual: @""]) {
                if (isLater && [[pref valueForKey:PREF_SETTING_RIDE_LATER_DESTINATION] boolValue]) {
                    ALog(@"Ride later is mandatory but given empty address ======================");
                    return;
                }else if (!isLater && [[pref valueForKey:PREF_SETTING_RIDE_NOW_DESTINATION] boolValue]){
                    ALog(@"Ride now is mandatory but given empty address==========================");
                    return;
                }else{
                    _destinationTextFiled.text=@"";
                    strForDestinationLatitude=@"";
                    strForDestinationLongitude=@"";
                    markerOwnerDest.map=nil;
                    markerOwner.map=nil;
                    [self startRideDestinationChangeWithLat:strForDestinationLatitude andLong:strForDestinationLongitude andAddress:@""];
                }
            }else {
                
                [self getLocationFromAddressString:[notification object]];
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:PREF_IS_FAV];
                [_destinationFavBtn setImage:[UIImage imageNamed:@"Fav_btn"] forState:UIControlStateNormal];
            }
            
        }
        [_destinationFavBtn setImage:[UIImage imageNamed:@"Fav_btn"] forState:UIControlStateNormal];
    }
}

#pragma mark  Notification Actions

- (void) fareEstimateViewNotification:(NSNotification *)notification{
    if ([APPDELEGATE connected]) {
        [self performSegueWithIdentifier:STRING_SEGUE_BOOKING_TO_FARE sender:self];
    }else {
        [customAlertView setContainerView:[APPDELEGATE createDemoView:NO_INTERNET view:self.view]];
        [customAlertView show];
    }
    
}

#pragma mark  Booking Page Button Actions

- (void)rateCardViewGesture:(UITapGestureRecognizer*)sender {
    self.view.userInteractionEnabled=NO;
    [UIView transitionWithView:nil
                      duration:0.1
                       options:UIViewAnimationOptionTransitionNone
                    animations:NULL
                    completion:^(BOOL finished){
                        [self animateViewHeight:_rateCardView withAnimationType:kCATransitionFade hidden:YES];
                        self.view.userInteractionEnabled=YES;
                    }];
    [UIView commitAnimations];
}

- (IBAction)navMenuBtn:(id)sender {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    [self.frostedViewController presentMenuViewController];
}

- (IBAction)bookRideLaterBtn:(id)sender {
    if ([APPDELEGATE connected]) {
        
        [self rideLAterDatePickerView];
        [pref removeObjectForKey:PREF_FAV_TEXT];
        [pref setBool:NO forKey:PREF_IS_FAV];
        [pref removeObjectForKey:PREF_FAV_LAT];
        [pref removeObjectForKey:PREF_FAV_LONG];
        self.frostedViewController.panGestureEnabled=NO;
        isLater=YES;
        _rideLaterCouponLbl.text=@"No Coupon";
    } else {
        [customAlertView setContainerView:[APPDELEGATE createDemoView:NO_INTERNET view:self.view]];
        [customAlertView show];
    }
}

- (IBAction)bookRideNowBtn:(id)sender {
    if ([APPDELEGATE connected]) {
        
//        [self readDataFromFile];
        isLater=NO;
        //Booking page Assets hidden
        _navMenuBtn.hidden=YES;
        _rideNowLaterBtnView.hidden=YES;
        _pageControl.hidden=YES;
        [expandView removeFromSuperview];
        myView1.hidden=YES;
        _confromRideLbl.hidden=NO;
        _navigationView.hidden=NO;
        _lymo_Logo.hidden=YES;
        _navOriginFavBtn.hidden=YES;
        _navOriginSearchBtn.hidden=YES;
        _originTextFiled.enabled=NO;
        _originTextFieldHolder.userInteractionEnabled=NO;
        _destinationTextFieldHolder.userInteractionEnabled=YES;
        _destinationTextFiled.text=@"";
        self.frostedViewController.panGestureEnabled=NO;
        _destinationView.hidden=NO;
        //    if([[pref valueForKey:PREF_SETTING_RIDE_NOW_DESTINATION] boolValue]){
        //        _destinationView.hidden=NO;
        //    } else {
        //        _destinationView.hidden=YES;
        //    }
        _destinationFavBtn.hidden=NO;
        _destinationSearchBtn.hidden=NO;
        _destinationTextFiled.userInteractionEnabled=NO;
        _noCarsAvailableHolderView.hidden=YES;
        
        //Start ride view hidden
        _startRideDetailBigView.hidden=YES;
        _startRideLocationBtn.hidden=YES;
        _startRideView.hidden=YES;
        _lymoArrivingLbl.hidden=YES;
        
        //RideLater hidden
        _rideNowBigView.hidden=NO;
        _RideNowBtnView.hidden=NO;
        _RideNowView.hidden=NO;
        _navBackView.hidden=NO;
        strForCurrentPage=@"ridenow";
        locationButton.hidden=YES;
        
        _rideNowCouponLbl.text=@"No Coupon";
        if ([[pref objectForKey:PREF_CAR_NAME]  isEqual: @""]) {
            _rideNowCarCat.text=[pref objectForKey:PREF_CATEGORY_NAME];
        }else {
            _rideNowCarCat.text=[pref objectForKey:PREF_CAR_NAME];
        }
        
        if ([[pref objectForKey:PREF_CATEGORY_BASE_FARE] isEqualToString:@"0.00"]) {
            if ([[pref objectForKey:PREF_CATEGORY_MIN_FARE] isEqualToString:@"0.00"]) {
                _rideNowFare.text=@"";
            }else {
                _rideNowFare.text=[NSString stringWithFormat:@"Minimum Fare %@ %@",[pref valueForKey:PREF_SETTING_CURRENCY_TEXT], [pref objectForKey:PREF_CATEGORY_MIN_FARE]];
            }
            
        }else {
            _rideNowFare.text=[NSString stringWithFormat:@"Base Fare %@ %@",[pref valueForKey:PREF_SETTING_CURRENCY_TEXT], [pref objectForKey:PREF_CATEGORY_BASE_FARE]];
        }
        
        
        ALog(@"Base Fare %@ %@ and min fare = %@ %@",[pref valueForKey:PREF_SETTING_CURRENCY_TEXT], [pref objectForKey:PREF_CATEGORY_BASE_FARE],[pref valueForKey:PREF_SETTING_CURRENCY_TEXT], [pref objectForKey:PREF_CATEGORY_MIN_FARE]);
        _rideNowTime.text=[pref objectForKey:PREF_CATEGORY_TIME];
        [pref setObject:@"" forKey:PREF_PROMO];
        
        NSObject *RideNowobject = [pref objectForKey:PREF_PAYMENT_OPT];
        NSString *stringID=@"0";
        if([RideNowobject isEqual: stringID] && [[pref valueForKey:PREF_SETTING_CARD_PAYMENT] boolValue]){
            _rideNowPaymentCardName.text = [pref objectForKey:PREF_PAYMENT_CARD_NAME];
            [ _rideNowPaymentCardIcon downloadFromURL:[pref objectForKey:PREF_PAYMENT_CARD_ICON] withPlaceholder:nil];
            [self paymentToggle];
        } else {
            if ([[pref valueForKey:PREF_SETTING_CARD_PAYMENT] boolValue]) {
                [pref setValue:@"Cash" forKey:PREF_PAYMENT_CARD_NAME];
                [pref setValue:@"Cash_Money" forKey:PREF_PAYMENT_CARD_ICON];
                [pref synchronize];
                _rideNowPaymentCardName.text = [pref objectForKey:PREF_PAYMENT_CARD_NAME];
                _rideNowPaymentCardIcon.image=[UIImage imageNamed:[pref objectForKey:PREF_PAYMENT_CARD_ICON]];
                [self paymentToggle];
            }
        }
        onceTokenForBack=0;
        
        // Favourite
        [pref removeObjectForKey:PREF_FAV_TEXT];
        [pref setBool:NO forKey:PREF_IS_FAV];
        [pref removeObjectForKey:PREF_FAV_LAT];
        [pref removeObjectForKey:PREF_FAV_LONG];
    } else {
        [customAlertView setContainerView:[APPDELEGATE createDemoView:NO_INTERNET view:self.view]];
        [customAlertView show];
    }
}

-(void)rideLAterDatePickerView{
    //Increment 1 Hour to picker
    if ([APPDELEGATE connected]) {
        NSDate *date = [NSDate date];
        int minsToAdd = [[pref objectForKey:PREF_SETTING_RIDE_LATER_MINIMUM_TIME] integerValue];
        int hoursToAdd = 0;
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *components = [[NSDateComponents alloc] init];
        [components setMinute:minsToAdd];
        [components setHour:hoursToAdd];
        NSDate *minDate= [calendar dateByAddingComponents:components toDate:date options:0];
        [components setMinute:[[pref objectForKey:PREF_SETTING_RIDE_LATER_TIME] integerValue]];
        NSDate *maxDate= [calendar dateByAddingComponents:components toDate:date options:0];
        
        
        /*Dummy view*/
        viewForPicker = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        viewForPicker.backgroundColor=[UIColor clearColor];
        
        UIView *pickerBackView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-250, self.view.frame.size.width,300)];
        pickerBackView.backgroundColor=[UIColor clearColor];
        
        /*Picker View for date and time*/
        datePicker =[[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-250, self.view.frame.size.width,250)];
        [datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
        [datePicker setBackgroundColor:[UIColor whiteColor]];
        datePicker.minimumDate=minDate;
        datePicker.maximumDate=maxDate;
        //[datePicker addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
        
        datePickerToolbar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,self.view.frame.size.height-294,self.view.frame.size.width,44)];
        [datePickerToolbar setBackgroundColor:[UIColor whiteColor]];
        datePickerToolbar.barStyle = UIBarStyleDefault;
        UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(pickerDone)];
        UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(pickerCancel)];
        [doneButton setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [UIColor blackColor], NSForegroundColorAttributeName,nil]
                                  forState:UIControlStateNormal];
        [cancelButton setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [UIColor blackColor], NSForegroundColorAttributeName,nil]
                                    forState:UIControlStateNormal];
        
        [datePickerToolbar setItems:[NSArray arrayWithObjects:cancelButton,flexibleSpaceLeft, doneButton, nil]];
        datePickerToolbar.userInteractionEnabled = true;
        
        
        [viewForPicker addSubview:datePickerToolbar];
        [viewForPicker addSubview:pickerBackView];
        [viewForPicker addSubview:datePicker];
        [pickerBackView bringSubviewToFront:datePicker];
        [self.view addSubview:viewForPicker];

    } else {
        [customAlertView setContainerView:[APPDELEGATE createDemoView:NO_INTERNET view:self.view]];
        [customAlertView show];
    }
    
}

- (void)navBackViewGesture:(UITapGestureRecognizer*)sender {
    
    //Booking page Assets hidden
    markerOwner.map=nil;
    markerOwner=nil;    // added these two lines to hide the marker while arriving arrived tripstarted -> clickon backbutton -> showing 2 pins for fraction of seconds and after loadng it will show one pin
    callrequestPath=NO;
    if(startRideExpandView.superview!=nil)
    [startRideExpandView removeFromSuperview];
    navBackPressedBool=NO;
    self.frostedViewController.panGestureEnabled=YES;
     _startRideLocationBtn.hidden=YES;
     ALog(@"-----------------------------pangesture enabled --------------------------------");
    dispatch_once(&onceTokenForBack, ^{
        [timerForCheckReqStatus invalidate];
        timerForCheckReqStatus=nil;
        [APPDELEGATE stopLoader:self.view];
        [pref setBool:NO forKey:PREF_IS_FAV];
        strForCurrentPage=@"booking";
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshCarDetailsView" object:self];
        
        //Booking page Assets hidden
        /* to move the navigation view up with animation uncomment the below animation code.*/
        
//        [UIView transitionWithView:mapView_
//                          duration:0.0
//                           options:UIViewAnimationOptionTransitionCrossDissolve
//                        animations:^{
//                            [self animateViewHeight:_navigationView withAnimationType:kCATransitionFromTop hidden:YES];
//                            self.view.userInteractionEnabled=YES;
//                        }
//                        completion:nil];
    
        _navigationView.hidden=YES;  //
        _destinationView.hidden=YES;
        _destinationTextFiled.text=@"";
        [_navOriginFavBtn setImage:[UIImage imageNamed:@"Fav_btn"] forState:UIControlStateNormal];
        [_destinationFavBtn setImage:[UIImage imageNamed:@"Fav_btn"] forState:UIControlStateNormal];
        _navMenuBtn.hidden=NO;
        _rideNowLaterBtnView.hidden=NO;
        _pageControl.hidden=NO;
        myView1.hidden=NO;
        _confromRideLbl.hidden=YES;
        _lymo_Logo.hidden=NO;
        _navOriginFavBtn.hidden=NO;
        _navOriginSearchBtn.hidden=NO;
        _destinationFavBtn.hidden=NO;
        _destinationSearchBtn.hidden=NO;
        _originTextFiled.enabled=YES;
        _originTextFieldHolder.userInteractionEnabled=YES;
        _destinationTextFieldHolder.userInteractionEnabled=YES;
        
        //Start ride view hidden
        _startRideDetailBigView.hidden=YES;
        _startRideLocationBtn.hidden=YES;
        _startRideView.hidden=YES;
        _lymoArrivingLbl.hidden=YES;
        _pulseView.hidden=YES;
        //RideLater hidden
        _rideLaterBigView.hidden=YES;
        _navBackView.hidden=YES;
        
        //RideNow hidden
        _rideNowBigView.hidden=YES;
        _navBackView.hidden=YES;
        
        promoApplied=NO;
        
        locationButton.hidden=NO;
         _mapPin.hidden=NO; //chnaged on17062016;  //_mapPin.hidden=YES;  //
        [pref removeObjectForKey:PREF_FARE_DESTINATIONTEXT];
        [pref removeObjectForKey:PREF_FROM_DESTINATION];
        [pref removeObjectForKey:PREF_SEARCH_EDIT_ADDRESS];
    });
}

- (IBAction)navOriginFavBtn:(id)sender {
    if([CLLocationManager locationServicesEnabled]&&
       [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied)
    {
        if ([APPDELEGATE connected]) {
            [pref setObject:_originTextFiled.text forKey:PREF_ADD_FAV_TEXT];
            [pref setObject:strForLatitude forKey:PREF_ADD_FAV_LAT];
            [pref setObject:strForLongitude forKey:PREF_ADD_FAV_LONG];
            [pref setObject:@"yes" forKey:PREF_ADD_FAV_VIEW];
            [pref setObject:@"fav_origin" forKey:@"selectedTextField"];
            [self performSegueWithIdentifier:STRING_SEGUE_TO_FAVORITES sender:self];
        }else {
            [customAlertView setContainerView:[APPDELEGATE createDemoView:NO_INTERNET view:self.view]];
            [customAlertView show];
        }
    }else{
        UIAlertView* LocationStatus=[[UIAlertView alloc] initWithTitle:@"This app does not have access to Location services" message:@"Please allow Orbit to use location services .Turn it on from settings" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Settings", nil];
        [LocationStatus show];
    }
}

- (IBAction)destinationFavBtn:(id)sender {
    if ([APPDELEGATE connected]) {
        [pref setObject:_destinationTextFiled.text forKey:PREF_ADD_FAV_TEXT];
        [pref setObject:strForDestinationLatitude forKey:PREF_ADD_FAV_LAT];
        [pref setObject:strForDestinationLongitude forKey:PREF_ADD_FAV_LONG];
        if ([_destinationTextFiled.text isEqualToString:@""]) {
            [pref setObject:@"no" forKey:PREF_ADD_FAV_VIEW];
        }else{
            [pref setObject:@"yes" forKey:PREF_ADD_FAV_VIEW];
            strForAddFavLat = strForDestinationLatitude;
            strForAddFavLong = strForDestinationLongitude;
        }
        [pref setObject:@"fav_dest" forKey:@"selectedTextField"];
        [self performSegueWithIdentifier:STRING_SEGUE_TO_FAVORITES sender:self];
    }else {
        [customAlertView setContainerView:[APPDELEGATE createDemoView:NO_INTERNET view:self.view]];
        [customAlertView show];
    }
}

- (IBAction)bookLocationBtn:(id)sender {
    if([CLLocationManager locationServicesEnabled]&&
       [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied)
    {
        CLLocationCoordinate2D coor;
        ALog(@"lattitude = %f",[strForCurLatitude doubleValue]);
        ALog(@"longitude -= %f",[strForCurLongitude doubleValue]);
        coor.latitude=[strForCurLatitude doubleValue];
        coor.longitude=[strForCurLongitude doubleValue];
        CGPoint point = [mapView_.projection pointForCoordinate:coor];
        ALog(@"The current zoom value is = %f", zoom);
        zoom=16.0;  //  when clicked on my loaction button the map wiil be zoomed to 15.0 to remove this comment
        GMSCameraUpdate *camera =
        [GMSCameraUpdate setTarget:[mapView_.projection coordinateForPoint:point] zoom:zoom];
        [mapView_ animateWithCameraUpdate:camera];
    }else{
        UIAlertView* LocationStatus=[[UIAlertView alloc] initWithTitle:@"This app does not have access to Location services" message:@"Please allow Orbit to use location services .Turn it on from settings" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Settings", nil];
        [LocationStatus show];
    }
}

#pragma mark -Delegate animate bottom to top


- (void)animateViewHeight:(UIView*)animateView withAnimationType:(NSString*)animType hidden:(BOOL)hidden animationDuration :(CFTimeInterval) duration {
    if (!animateView.hidden) {
        CATransition *animation = [CATransition animation];
        [animation setType:kCATransitionPush];
        [animation setSubtype:animType];
        [animation setDuration:duration];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
        [[animateView layer] addAnimation:animation forKey:kCATransition];
        animateView.hidden = YES;
    }

}


- (void)animateViewHeight:(UIView*)animateView withAnimationType:(NSString*)animType show:(BOOL)shown animationDuration :(CFTimeInterval) duration {
    if (animateView.hidden) {
        CATransition *animation = [CATransition animation];
        [animation setType:kCATransitionPush];
        [animation setSubtype:animType];
        [animation setDuration:duration];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
        [[animateView layer] addAnimation:animation forKey:kCATransition];
        animateView.hidden = NO;
    }

}

//
- (void)animateViewHeight:(UIView*)animateView withAnimationType:(NSString*)animType hidden:(BOOL)hidden {
    if (!animateView.hidden) {
        CATransition *animation = [CATransition animation];
        [animation setType:kCATransitionPush];
        [animation setSubtype:animType];
        [animation setDuration:0.3];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
        [[animateView layer] addAnimation:animation forKey:kCATransition];
        animateView.hidden = hidden;
    }

}

- (void)animateViewHeight:(UIView*)animateView withAnimationType:(NSString*)animType show:(BOOL)shown {
    if (animateView.hidden) {
        CATransition *animation = [CATransition animation];
        [animation setType:kCATransitionPush];
        [animation setSubtype:animType];
        [animation setDuration:0.3];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
        [[animateView layer] addAnimation:animation forKey:kCATransition];
        animateView.hidden = NO;
    }

}

//- (void)setView:(UIView*)view hidden:(BOOL)hidden {
//    CATransition *transition = [CATransition animation];
//    transition.type =kCATransitionFade;
//    transition.duration = 0.5f;
//    transition.delegate = self;
//    [view.layer addAnimation:transition forKey:nil];
//    view.hidden=hidden;
//}

- (void)setView:(UIView*)view hidden:(BOOL)hidden {
    CATransition *transition = [CATransition animation];
    transition.type =kCATransitionFromTop;
    transition.duration = 0.0f;
    transition.delegate = self;
    [view.layer addAnimation:transition forKey:nil];
    view.hidden=hidden;
}


#pragma mark -RideLater Button Actions

- (IBAction)RideLaterBtn:(id)sender{    // Advanced booking button
    if ([APPDELEGATE connected]) {
        _bookRideLaterBtn.enabled=NO;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSTimeZone *timeZone = [NSTimeZone localTimeZone];
        [dateFormatter setTimeZone:timeZone];
        [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
        NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
        NSDate* date1 =  [dateFormatter dateFromString:strForRideLaterDate];
        NSDate* date2 =  [dateFormatter dateFromString:dateString];
        if ([self dateComparision:date1 andDate2:date2]) {
            if([APPDELEGATE connected])  {
                NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
                [dictParam setValue:[pref objectForKey:PREF_USER_TOKEN] forKey:PARAM_TOKEN];
                [dictParam setValue:[pref objectForKey:PREF_LYMO_DEVICE_ID] forKey:PARAM_LYMO_DEVICE_ID];
                [dictParam setValue:[pref objectForKey:PREF_USER_ID] forKey:PARAM_ID];
                [dictParam setValue:[pref objectForKey:PREF_CATEGORY_TYPE_ID] forKey:PARAM_TYPE];
                [dictParam setValue:strForLatitude forKey:PARAM_LATITUDE];
                [dictParam setValue:strForLongitude  forKey:PARAM_LONGITUDE];
                [dictParam setValue:_originTextFiled.text  forKey:PARAM_SOURCE_ADDRESS];
                if([[pref valueForKey:PREF_SETTING_RIDE_LATER_DESTINATION] boolValue] || ![_destinationTextFiled.text isEqualToString:@""]){
                    [dictParam setValue:strForDestinationLatitude  forKey:PARAM_D_LATITUDE];
                    [dictParam setValue:strForDestinationLongitude  forKey:PARAM_D_LONGITUDE];
                    [dictParam setValue:_destinationTextFiled.text  forKey:PARAM_DESTINATION_ADDRESS];
                    
                }
                [dictParam setValue:strForRideLaterDate forKey:PARAM_DATETIME];
                NSObject * object = [pref objectForKey:PREF_PAYMENT_OPT];
                if(object != nil){
                    [dictParam setValue:[pref objectForKey:PREF_PAYMENT_OPT] forKey:PARAM_PAYMENT_OPT];
                }else{
                    [pref setValue:@"1" forKey:PREF_PAYMENT_OPT];
                    [pref synchronize];
                    [dictParam setValue:[pref objectForKey:PREF_PAYMENT_OPT] forKey:PARAM_PAYMENT_OPT];
                }
                [dictParam setValue:[pref valueForKey:PREF_PROMO] forKey:PARAM_PROMO_CODE];
                [dictParam setValue:[pref objectForKey:PREF_PAYMENT_ID] forKey:PARAM_PAYMENT_ID];
                ALog(@"RideLater Server Dictionary..%@",dictParam);
                [APPDELEGATE startLoader:self.view giveSpaceFornavigationBar:YES];
                AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
                [afn getDataFromPath:FILE_CREATE_REQUEST_LATER withParamData:dictParam withBlock:^(id response, NSError *error)
                 {
                     ALog(@"RideLater Response ---> %@",response);
                     if (response == Nil){
                         if (error.code == -1005) {
                             [APPDELEGATE stopLoader:self.view];
                             [self RideLaterBtn:sender];
                             
                         }else {
                             _bookRideLaterBtn.enabled=YES;
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 [APPDELEGATE stopLoader:self.view];
                                 [APPDELEGATE showAlertOnTopMostControllerWithText:UNABLE_TO_REACH];
                             });
//                             [customAlertView setContainerView:[APPDELEGATE createDemoView:UNABLE_TO_REACH view:self.view]];
//                             [customAlertView show];
                         }
                     }else if (response)
                     {
                         if ([APPDELEGATE settingsStatus:[response valueForKey:@"customer_setting"]]) {
                             if([[response valueForKey:@"success"]boolValue])
                             {
                                 _rideLaterPopupBigView.hidden=NO;
                                 _rideLaterPopupContent.text = [response valueForKey:@"message"];
                                 [pref removeObjectForKey:PREF_FARE_DESTINATIONTEXT];
                             } else{
                                 _rideLaterPopupBigView.hidden=YES;
                                 [customAlertView setContainerView:[APPDELEGATE createDemoView:[response valueForKey:@"error"] view:self.view]];
                                 [customAlertView show];
                             }
                             
                         }
                         [APPDELEGATE customerSetting:[response valueForKey:@"customer_setting"] ShowRideComplete:YES ShowCancelPayment:YES FromViewController:self];;
                         
                         //   [pref removeObjectForKey:PREF_FARE_DESTINATIONTEXT];
                         _bookRideLaterBtn.enabled=YES;
                         
                     }
                     [APPDELEGATE stopLoader:self.view];
                 }];
            }else{
                [customAlertView setContainerView:[APPDELEGATE createDemoView:NO_INTERNET view:self.view]];
                [customAlertView show];
                _bookRideLaterBtn.enabled=YES;
            }
        } else {
            _rideLaterPopupBigView.hidden=YES;
            _bookRideLaterBtn.enabled=YES;
            [self bookRideLaterBtn:self];
        }
    } else {
        [customAlertView setContainerView:[APPDELEGATE createDemoView:NO_INTERNET view:self.view]];
        [customAlertView show];
    }
    if ([_destinationTextFiled.text isEqualToString:@""]){
        strForDestinationLatitude=@"";
        strForDestinationLongitude=@"";
    }
}

- (IBAction)rideLaterPopupOKBtn:(id)sender {
    _rideLaterPopupBigView.hidden=YES;
    _rideLaterCouponLbl.text=@"No Coupon";
    [pref setObject:@"" forKey:PREF_PROMO];
    promoApplied=NO;
    [self navBackViewGesture:nil];
}

- (void)rideLaterDateLabelGesture:(UITapGestureRecognizer*)sender {
    //   [self rideLAterDatePickerView];
    
    //Increment 1 Hour to picker
    NSDate *date = [NSDate date];
    int hoursToAdd=0;
    int minsToAdd =[[pref objectForKey:PREF_SETTING_RIDE_LATER_MINIMUM_TIME] integerValue];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setMinute:minsToAdd];
    [components setHour:hoursToAdd];
    NSDate *minDate= [calendar dateByAddingComponents:components toDate:date options:0];
    [components setMinute:[[pref objectForKey:PREF_SETTING_RIDE_LATER_TIME] integerValue]];
    NSDate *maxDate= [calendar dateByAddingComponents:components toDate:date options:0];
    
//    NSDate *selectedDate = datePicker.date;
    NSDate *selectedDate = minDate;
    ALog(@"Server Date..%@",selectedDate);
    
    /*Dummy view*/
    viewForPicker = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    viewForPicker.backgroundColor=[UIColor clearColor];
    
    UIView *pickerBackView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-250, self.view.frame.size.width,300)];
    pickerBackView.backgroundColor=[UIColor whiteColor];
    
    /*Picker View for date and time*/
    datePicker =[[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-250, self.view.frame.size.width,250)];
    [datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
    [datePicker setBackgroundColor:[UIColor whiteColor]];
    datePicker.minimumDate=minDate;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    NSString *dateString = [dateFormatter stringFromDate:selectedDate];
    NSDate* date1 =  [dateFormatter dateFromString:strForRideLaterDate];
    NSDate* date2 =  [dateFormatter dateFromString:dateString];
    if ([self dateComparision:date1 andDate2:date2]) {
        [datePicker setDate:date1];
    }else {
        [datePicker setDate:date2];
    }
    
    datePicker.maximumDate=maxDate;
    //[datePicker addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
    
    datePickerToolbar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,self.view.frame.size.height-294,self.view.frame.size.width,44)];
    [datePickerToolbar setBackgroundColor:[UIColor whiteColor]];
    datePickerToolbar.barStyle = UIBarStyleDefault;
    UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(pickerDone)];
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(pickerCancel)];
    [doneButton setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor blackColor], NSForegroundColorAttributeName,nil]
                              forState:UIControlStateNormal];
    [cancelButton setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor blackColor], NSForegroundColorAttributeName,nil]
                                forState:UIControlStateNormal];
    
    [datePickerToolbar setItems:[NSArray arrayWithObjects:cancelButton,flexibleSpaceLeft, doneButton, nil]];
    datePickerToolbar.userInteractionEnabled = true;
    
    
    [viewForPicker addSubview:datePickerToolbar];
    [viewForPicker addSubview:pickerBackView];
    [viewForPicker addSubview:datePicker];
    [pickerBackView bringSubviewToFront:datePicker];
    [self.view addSubview:viewForPicker];
    
    
}

#pragma mark -RideNow Button Actions

- (IBAction)RideNowBtn:(id)sender{
    if([APPDELEGATE connected])  {
//        _confromRideLbl.hidden=YES;
        _navBackView.hidden=YES;
        NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
        [dictParam setValue:[pref objectForKey:PREF_USER_TOKEN] forKey:PARAM_TOKEN];
        [dictParam setValue:[pref objectForKey:PREF_LYMO_DEVICE_ID] forKey:PARAM_LYMO_DEVICE_ID];
        [dictParam setValue:[pref objectForKey:PREF_USER_ID] forKey:PARAM_ID];
        [dictParam setValue:[pref objectForKey:PREF_CATEGORY_TYPE_ID] forKey:PARAM_TYPE];
        [dictParam setValue:_originTextFiled.text  forKey:PARAM_SOURCE_ADDRESS];
        if([[pref valueForKey:PREF_SETTING_RIDE_NOW_DESTINATION] boolValue] && [_destinationTextFiled.text isEqualToString:@""]){
            [dictParam setValue:_destinationTextFiled.text  forKey:PARAM_DESTINATION_ADDRESS];
        }else {
            [dictParam setValue:_destinationTextFiled.text  forKey:PARAM_DESTINATION_ADDRESS];
        }
        ALog(@"ridenow parameters are %@", dictParam);
        [APPDELEGATE startLoader:self.view giveSpaceFornavigationBar:YES];
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [afn getDataFromPath:FILE_PEAK_TIME_TEST withParamData:dictParam withBlock:^(id response, NSError *error)
         {
             ALog(@"RideNow Response ---> %@",response);
             if (response == Nil){
                 if (error.code == -1005) {
                     [APPDELEGATE stopLoader:self.view];
                     [self RideNowBtn:sender];
                 }else {
                     _pulseView.hidden=YES;
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [APPDELEGATE stopLoader:self.view];
                         [APPDELEGATE showAlertOnTopMostControllerWithText:UNABLE_TO_REACH];
                     });
//                 [customAlertView setContainerView:[APPDELEGATE createDemoView:UNABLE_TO_REACH view:self.view]];
//                 [customAlertView show];
                 }
             }else if (response)
             {
                 if([[response valueForKey:@"success"] integerValue] == 2)
                 {
                     _surgeBigView.hidden=YES;
                     _navBackView.hidden=NO;
                     [customAlertView setContainerView:[APPDELEGATE createDemoView:[response valueForKey:@"error"] view:self.view]];
                     [customAlertView show];
                     
                 }else if([[response valueForKey:@"success"] integerValue] == 1)
                 {
                     _surgeBigView.hidden=NO;
                     _surgeLbl.text=[response valueForKey:@"value"];
                     _surgeDescriptionLabel.text=SURGE_DESCRIPTION;
                     [pref removeObjectForKey:PREF_FARE_DESTINATIONTEXT];
                 }
                 else{
                     _surgeBigView.hidden=YES;
                     [self createRequestForRideNow];  // actual api call for confirming driver is available or not
                 }
                 //  [pref removeObjectForKey:PREF_FARE_DESTINATIONTEXT];
                  [APPDELEGATE customerSetting:[response valueForKey:@"customer_setting"] ShowRideComplete:YES ShowCancelPayment:YES FromViewController:self];;
             }
             [APPDELEGATE stopLoader:self.view];
         }];
    }else{
//        [self navBackViewGesture:nil];
        [customAlertView setContainerView:[APPDELEGATE createDemoView:NO_INTERNET view:self.view]];
        [customAlertView show];
    }
}



-(void)setTimerToCheckDriverStatus
{
    if (timerForCheckReqStatus) {
        [timerForCheckReqStatus invalidate];
        timerForCheckReqStatus = nil;
    }
    ALog(@"timer is activated and the time from settings = %f",getRequestCallTime );
    timerForCheckReqStatus = [NSTimer scheduledTimerWithTimeInterval:getRequestCallTime target:self selector:@selector(checkForRequestStatus) userInfo:nil repeats:YES];
//    timerForCheckReqStatus = [NSTimer scheduledTimerWithTimeInterval:getRequestCallTime target:self selector:@selector(checkForDummyRequestStatus) userInfo:nil repeats:YES];
}

-(void)checkForRequestStatus
{
    if([APPDELEGATE connected]) {
        noInternetView.hidden=YES;
        NSString *strReqId=[pref objectForKey:PREF_REQ_ID];
        NSString *strForUrl=[NSString stringWithFormat:@"%@?%@=%@&%@=%@&%@=%@&%@=%@&%@=%@",FILE_GET_REQUEST,PARAM_ID,[pref objectForKey:PREF_USER_ID],PARAM_TOKEN,[pref objectForKey:PREF_USER_TOKEN],PARAM_REQUEST_ID,strReqId,PARAM_LAST_WALKER_ID,lastWalkerId,PARAM_LYMO_DEVICE_ID,[pref objectForKey:PREF_LYMO_DEVICE_ID]];
        ALog(@"The checkForRequestStatus url in landing page is = %@", strForUrl);
        // NSString *strForUrl=[NSString stringWithFormat:@"%@?%@=%@&%@=%@&%@=%@",FILE_GET_REQUEST,PARAM_ID,@"222",PARAM_TOKEN,@"2y10a5RMW0Z3TuJkScXEh0QdokzroiO4cTW6L9lLYsYV9BFe28DJ6lS",PARAM_REQUEST_ID,strReqId];
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [afn getDataFromPath:strForUrl withParamData:nil withBlock:^(id response, NSError *error){
            if(navBackPressedBool){
                if (response == Nil){
//                    [customAlertView setContainerView:[APPDELEGATE createDemoView:UNABLE_TO_REACH view:self.view]];
//                    [customAlertView show];
                }else if (response){
                    if([[response valueForKey:@"success"]boolValue] && [[response valueForKey:@"status"] intValue]) {
                        ALog(@"GET REQ in LandingPage--->%@",response);
                        NSMutableDictionary *dictWalker=[response valueForKey:@"walker"];
                        
                        if([[response valueForKey:@"status"] intValue]==1){
                            
                            if([[response valueForKey:@"is_completed"] intValue]!=0){
                                [timerForCheckReqStatus invalidate];
                                timerForCheckReqStatus = nil;
                                _lymoArrivingLbl.text=@"Trip Ended";
                                _startRideDetailCancelView.userInteractionEnabled = NO;
                                _startRideCancelLbl.textColor=[UIColor lightGrayColor];
                                _startRideCancelIcon.image=[UIImage imageNamed:@"Cancel_gray"];
                                _cancelAlertBigView.hidden=YES;
                                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:PREF_IS_FAV];
                                dispatch_once(&onceToken, ^{
                                    rideCompleteTripID=[response valueForKey:@"trip_id"];
                                    rideCompleteDate=[response valueForKey:@"request_end_date"];
                                    rideCompleteCarCatorgery=[dictWalker valueForKey:@"type_name"];
                                    rideCompleteTime=[response valueForKey:@"request_end_time"];
                                    rideCompletePayment=[response valueForKey:@"payment_type_content"];
                                    rideCompletePrice=[response valueForKey:@"total"];
                                    rideCompleteMessage=[response valueForKey:@"payment_description"];
                                    rideCompleteDriveIcon=[dictWalker valueForKey:@"picture"];
                                    if ([[dictWalker valueForKey:@"sec_car_model"] length] > 1) {
                                        rideCompleteDriverCarCategory=[dictWalker valueForKey:@"sec_car_model"];
                                    }else{
                                       rideCompleteDriverCarCategory=[dictWalker valueForKey:@"car_model"];
                                    }
                                    rideCompleteDriverCarNumber=[dictWalker valueForKey:@"car_number"];
                                    rideCompleteRequestId=strReqId;
                                    rideCompleteDriverName=_startRideDetailName.text;
                                    [pref removeObjectForKey:PREF_ADD_FAV_TEXT];
                                    [pref removeObjectForKey:PREF_ADD_FAV_LAT];
                                    [pref removeObjectForKey:PREF_ADD_FAV_LONG];
                                    zoom=16.0;
                                    [_destinationFavBtn setImage:[UIImage imageNamed:@"Fav_btn"] forState:UIControlStateNormal];
                                    [pref removeObjectForKey:PREF_FAV_TEXT];
                                    [pref setBool:NO forKey:PREF_SETTING_REQUEST_ID_STATUS]; // pushed view controller and after rating create new landing page view controller
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        _originTextFiled.text=@"";
                                        _destinationTextFiled.text=@"";
                                    [self performSegueWithIdentifier:STRING_SEGUE_RIDE_COMPLETE sender:self];
                                    });
                                });
                                // _webView.hidden=NO;
                                // ALog(@"%@",[response objectForKey:@"content"]);
                                //[_webView loadHTMLString:[NSString stringWithFormat:@"%@",[response objectForKey:@"content"]] baseURL:nil];
                                
                            }else{
                                _mapPin.hidden=YES;
                                _noCarsAvailableHolderView.hidden=YES;
                                _pulseView.hidden=YES;
                                //Booking page Assets hidden
                                _navMenuBtn.hidden=YES;
                                _rideNowLaterBtnView.hidden=YES;
                                _pageControl.hidden=YES;
                                myView1.hidden=YES;
                                _confromRideLbl.hidden=YES;
                                _lymo_Logo.hidden=YES;
                                _navOriginFavBtn.hidden=YES;
                                _navOriginSearchBtn.hidden=YES;
                                _destinationFavBtn.hidden=YES;
                                _destinationSearchBtn.hidden=YES;
                                _originTextFiled.enabled=NO;
                                _originTextFieldHolder.userInteractionEnabled=NO;
                                _destinationTextFiled.enabled=NO;
                                _destinationTextFieldHolder.userInteractionEnabled=YES;
                                
                                //Cancel ride button
                                _startRideDetailCancelView.userInteractionEnabled = YES;
                                _startRideCancelLbl.textColor=[UIColor blackColor];
                                _startRideCancelIcon.image=[UIImage imageNamed:@"Cancel_icon"];
                                
                                //Start ride view hidden
                                if(startRideEnable){
                                    _startRideDetailBigView.hidden=NO;
                                    _startRideLocationBtn.hidden=YES;
                                    _startRideView.hidden=YES;
                                    _navigationView.hidden=YES;
                                    _destinationView.hidden=YES;
                                }else{
                                    _startRideDetailBigView.hidden=YES;
                                    _startRideLocationBtn.hidden=NO;
                                    _startRideView.hidden=NO;
                                    _navigationView.hidden=NO;
                                    _destinationView.hidden=NO;
//                                    if([[pref valueForKey:PREF_SETTING_RIDE_NOW_DESTINATION] boolValue]){
//                                        _destinationView.hidden=NO;
//                                    }else{
//                                        _destinationView.hidden=YES;
//                                    }
                                }
                                _lymoArrivingLbl.hidden=NO;
                                
                                //RideLater hidden
                                _rideNowBigView.hidden=YES;
                                _navBackView.hidden=NO;
                                _startRideName.text=[NSString stringWithFormat:@"%@ %@",[dictWalker objectForKey:@"first_name"],[dictWalker objectForKey:@"last_name"]];
                                _startRideDetailName.text=[NSString stringWithFormat:@"%@ %@",[dictWalker objectForKey:@"first_name"],[dictWalker objectForKey:@"last_name"]];
                                
                                [_startRideIcon downloadFromURL:[dictWalker objectForKey:@"picture"] withOutLoader:nil];
                                [_startRideDetailIcon downloadFromURL:[dictWalker objectForKey:@"picture"] withOutLoader:nil];
                                if ([[dictWalker valueForKey:@"sec_car_model"] length] > 1) {
                                    _startRideDetailCarType.text=[dictWalker objectForKey:@"sec_car_model"];
                                    _startRideCarType.text=[dictWalker objectForKey:@"sec_car_model"];
                                }else{
                                    _startRideDetailCarType.text=[dictWalker objectForKey:@"car_model"];
                                    _startRideCarType.text=[dictWalker objectForKey:@"car_model"];
                                }
                                
                                _startRideCarNumber.text=[dictWalker objectForKey:@"car_number"];
                                _startRideDetailCarNumber.text=[dictWalker objectForKey:@"car_number"];
                                
                                
                                self.startRideRatingView.delegate = self;
                                self.startRideRatingView.emptySelectedImage = [UIImage imageNamed:@"StarEmpty"];
                                self.startRideRatingView.fullSelectedImage = [UIImage imageNamed:@"StarFull"];
                                self.startRideRatingView.contentMode = UIViewContentModeScaleAspectFill;
                                self.startRideRatingView.maxRating = 5;
                                self.startRideRatingView.minRating = 0;
                                self.startRideRatingView.rating = [[dictWalker objectForKey:@"rating"] floatValue];
                                self.startRideRatingView.editable = NO;
                                self.startRideRatingView.halfRatings = NO;
                                self.startRideRatingView.floatRatings = YES;
                                _startRideRating.text=[dictWalker objectForKey:@"rating"];
                                
                                self.startRideDetailRatingView.delegate = self;
                                self.startRideDetailRatingView.emptySelectedImage = [UIImage imageNamed:@"StarEmpty"];
                                self.startRideDetailRatingView.fullSelectedImage = [UIImage imageNamed:@"StarFull"];
                                self.startRideDetailRatingView.contentMode = UIViewContentModeScaleAspectFill;
                                self.startRideDetailRatingView.maxRating = 5;
                                self.startRideDetailRatingView.minRating = 0;
                                self.startRideDetailRatingView.rating = [[dictWalker objectForKey:@"rating"] floatValue];
                                self.startRideDetailRatingView.editable = NO;
                                self.startRideDetailRatingView.halfRatings = NO;
                                self.startRideDetailRatingView.floatRatings = YES;
                                _startRideDetailRating.text=[dictWalker objectForKey:@"rating"];
                                
                                strForWalkerPhone=[dictWalker objectForKey:@"phone"];
                                
                                strForCurrentPage=@"startride";
                                strForSourceAddress = [response valueForKey:@"source_address"];
                                strForDestinationAddress = [response valueForKey:@"destination_address"];
                                
//                                [mapView_ clear];  // commneted for testing purpose  // uncommenting on 30/05/2019
// once trip is accepted clear all cars and markers (i.e clear map) and show only the current car(initialize the car only once by checking condition last walker id zero
                                if ([lastWalkerId isEqualToString:@"0"]) {
                                    [mapView_ clear];
                                    markerOwner.map=nil;
                                    markerOwner=nil;
                                    markerOwnerDest.map=nil;
                                    markerOwnerDest=nil;
                                    [self deleteTheFileNamed:@"yourFile.txt"];
                                    [self deleteTheFileNamed:@"myfile.txt"];
                                    if(![[response valueForKey:@"latitude"] isEqualToString:@""] && ![[response valueForKey:@"longitude"] isEqualToString:@""]){
                                        
                                        CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake([[response valueForKey:@"latitude"] doubleValue], [[response valueForKey:@"longitude"] doubleValue]);
                                        ongoingRideSourceLatLong = coordinates;
                                        
                                        //                                    double bearing = [[dictWalker valueForKey:@"bearing"]doubleValue];
                                            markerOwner = [GMSMarker markerWithPosition:coordinates];
                                            //                                        markerOwner.icon=[GMSMarker markerImageWithColor:[UIColor redColor]]; // commented on 18072016
                                            markerOwner.icon=[UIImage imageNamed:@"mapPin"];
                                            //                                        [UIImage imageNamed:@"mapPin"];
                                            markerOwner.map = mapView_;
                                            isActivityControllershown=NO;
                                        markerOwner.position = coordinates;
                                    }
                                    
                                    if((![[response valueForKey:@"dest_latitude"] isEqualToString:@""] && ![[response valueForKey:@"dest_longitude"] isEqualToString:@""]) && (![[response valueForKey:@"dest_latitude"] isEqualToString:@"0"] && ![[response valueForKey:@"dest_longitude"] isEqualToString:@"0"])){
                                        
                                        CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake([[response valueForKey:@"dest_latitude"] doubleValue], [[response valueForKey:@"dest_longitude"] doubleValue]);
                                            isActivityControllershown=NO;
                                            markerOwnerDest = [GMSMarker markerWithPosition:coordinates];
                                            markerOwnerDest.icon=[UIImage imageNamed:@"mapPindest"];
                                            markerOwnerDest.map = mapView_;
                                            markerOwnerDest.position = coordinates;
                                        _destinationTextFiled.text= [response valueForKey:@"destination_address"];
                                    }else {
                                        markerOwnerDest.map = nil;
                                        markerOwnerDest = nil;
                                        ALog(@"destination is cleared");
                                    }
                                }else{
                                    
                                    if(![[response valueForKey:@"latitude"] isEqualToString:@""] && ![[response valueForKey:@"longitude"] isEqualToString:@""]){
                                        
                                        CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake([[response valueForKey:@"latitude"] doubleValue], [[response valueForKey:@"longitude"] doubleValue]);
                                        ongoingRideSourceLatLong = coordinates;
                                        if (markerOwner == nil) {
                                            markerOwner = [GMSMarker markerWithPosition:coordinates];
                                            markerOwner.icon=[UIImage imageNamed:@"mapPin"];
                                        }
                                        markerOwner.map = mapView_;
                                        isActivityControllershown=NO;
                                        markerOwner.position = coordinates;
                                    }

                                    if((![[response valueForKey:@"dest_latitude"] isEqualToString:@""] && ![[response valueForKey:@"dest_longitude"] isEqualToString:@""]) && (![[response valueForKey:@"dest_latitude"] isEqualToString:@"0"] && ![[response valueForKey:@"dest_longitude"] isEqualToString:@"0"])){
                                        
                                        CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake([[response valueForKey:@"dest_latitude"] doubleValue], [[response valueForKey:@"dest_longitude"] doubleValue]);
                                        isActivityControllershown=NO;
                                        if (markerOwnerDest == nil) {
                                            markerOwnerDest = [GMSMarker markerWithPosition:coordinates];
                                            markerOwnerDest.icon=[UIImage imageNamed:@"mapPindest"];
                                        }
                                        
                                        markerOwnerDest.map = mapView_;
                                        markerOwnerDest.position = coordinates;
                                        _destinationTextFiled.text= [response valueForKey:@"destination_address"];
                                    }else {
                                        markerOwnerDest.map = nil;
                                        markerOwnerDest = nil;
                                        ALog(@"destination is cleared");
                                    }

                                }
                                
                                if ([[response valueForKey:@"is_cancelled"] intValue]!=0) {
                                    [timerForCheckReqStatus invalidate];
                                    timerForCheckReqStatus = nil;
                                    callrequestPath=NO;
                                    _pulseView.hidden=YES;
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [customAlertView setContainerView:[APPDELEGATE createDemoView:RIDE_IS_CANCELLED_200 view:self.view]];
                                        customAlertView.tag=101;
                                        [customAlertView show];
                                    });
                                }else {
                                    if([[response valueForKey:@"is_walker_started"] intValue]!=0){
                                        _lymoArrivingLbl.text=@"Orbit Arriving";
                                        _destinationView.userInteractionEnabled=YES;
                                        _originTextFieldHolder.userInteractionEnabled=NO;
                                        if([[response valueForKey:@"is_secondary_type"] intValue]!=0){
                                            if (is_secondary_type) {
                                                is_secondary_type=NO;
                                                [customAlertView setContainerView:[APPDELEGATE createDemoView:[response valueForKey:@"secondary_message"] view:self.view]];
                                                [customAlertView show];
                                            }
                                            _lymoArrivingLbl.text=@"Orbit Arriving";
                                            _destinationView.userInteractionEnabled=YES;
                                            _originTextFieldHolder.userInteractionEnabled=NO;
                                        }
                                    }
                                    
                                    if([[response valueForKey:@"is_walker_arrived"] intValue]!=0){
                                        _lymoArrivingLbl.text=@"Orbit Arrived";
                                        _destinationView.userInteractionEnabled=YES;
                                        _originTextFieldHolder.userInteractionEnabled=NO;
                                    }
                                    
                                    if([[response valueForKey:@"is_walk_started"] intValue]!=0){
                                        _lymoArrivingLbl.text=@"Trip Started";
                                        //                                    [mapView_ clear];  // commneted on 06062016
                                        //                                    driver_marker = nil;
                                        _startRideDetailCancelView.userInteractionEnabled = NO;
                                        _startRideCancelLbl.textColor=[UIColor lightGrayColor];
                                        _startRideCancelIcon.image=[UIImage imageNamed:@"Cancel_gray"];
                                        _cancelAlertBigView.hidden=YES;
                                        _pulseView.hidden=YES;
                                        
                                        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:PREF_IS_FAV];
                                        //                                    [arrPath removeAllObjects];
                                        //                                    arrPath=[[response valueForKey:@"locationdata"] mutableCopy];
                                        [arrPath addObjectsFromArray:[[response valueForKey:@"locationdata"] mutableCopy]];
                                        
                                        if ([arrPath count]) {
                                            animationTime=getRequestCallTime/arrPath.count;
                                            [timerForCheckReqStatus invalidate];
                                            timerForCheckReqStatus = nil;
                                            lastWalkerId=[[arrPath lastObject] valueForKey:@"id"];
                                            [self drawPath];
                                            /*************/
                                        } else {
                                            if (timerForCheckReqStatus == nil) {
                                                [self setTimerToCheckDriverStatus];
                                            }
                                        }
                                        
                                        if ((([[response valueForKey:@"is_walker_started"] intValue]!=0) || ([[response valueForKey:@"is_walker_arrived"] intValue]!=0) || ([[response valueForKey:@"is_walk_started"] intValue]!=0)) && ([[response valueForKey:@"is_completed"] intValue]==0)) {
                                            onceToken=0;
                                        }
                                        
                                    } else {
                                        //mapView
                                        //                                    [mapView_ clear];   // uncommenting on 30/05/2019
                                        CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake([[dictWalker valueForKey:@"latitude"]doubleValue],[[dictWalker valueForKey:@"longitude"]doubleValue]);                                    double bearing = [[dictWalker valueForKey:@"bearing"]doubleValue];
                                        if (driver_marker == nil) {
                                            driver_marker = [GMSMarker markerWithPosition:coordinates];
                                            driver_marker.icon=driverCarIcon;
                                            
                                        }
                                        driver_marker.map = mapView_;
                                        [CATransaction begin];
                                        [CATransaction setAnimationDuration:2.0];
                                        driver_marker.position = coordinates;
                                        driver_marker.rotation = bearing;
                                        [CATransaction commit];
                                    }
                                }
                            }
                        }else if([[response valueForKey:@"status"] intValue]==2){
                            [timerForCheckReqStatus invalidate];
                            timerForCheckReqStatus=nil;
                            [customAlertView setContainerView:[APPDELEGATE createDemoView:[response valueForKey:@"error"] view:self.view]];
                            [customAlertView show];
                            
                            _pulseView.hidden=YES;
                            _RideNowBtnView.hidden=NO;
                            _RideNowView.hidden=NO;
                            _destinationView.hidden=NO;
                            _navigationView.hidden=NO;
                            
                            _cancelAlertBigView.hidden=YES;
                            startRideEnable=NO;
                            strForCancelReasonText=@"";
                            strForCancelReasonID=@"";
                            [pref removeObjectForKey:PARAM_REQUEST_ID];
                            [self navBackViewGesture:nil];
//                            [APPDELEGATE showToastMessage:NSLocalizedString(@"REQUEST_CANCEL", nil)];
                        }
                    }else {
                        ALog(@"ge request response is not success the response =  %@", response);
                        if ([[response valueForKey:@"is_cancelled"] boolValue]) {
                            [timerForCheckReqStatus invalidate];
                            timerForCheckReqStatus = nil;
                            callrequestPath=NO;
                            _pulseView.hidden=YES;
                            [self navBackViewGesture:nil];
                            [APPDELEGATE showAlertOnTopMostControllerWithText:RIDE_IS_CANCELLED_100];
                        }
                        
                    }
                        [APPDELEGATE customerSetting:[response valueForKey:@"customer_setting"] ShowRideComplete:NO ShowCancelPayment:NO FromViewController:self];;
                }
            } else {
                ALog(@"++++++ +++++++++++++++++++++++++++++++++++++    navigation bool is false so cannot go inside");
            }
        }];
    } else {
        [timerForCheckReqStatus invalidate];
        timerForCheckReqStatus = nil;
        noInternetView.hidden=NO;
        callrequestPath=YES;
        [customAlertView setContainerView:[APPDELEGATE createDemoView:NO_INTERNET view:self.view]];
//        [self navBackViewGesture:nil];
        _pulseView.hidden=YES;
        [customAlertView show];
    }
}


-(void) zoomOutTheMapWithSourceLatLong : (CLLocationCoordinate2D)source AndDestinationLatlong: (CLLocationCoordinate2D)destination {
    GMSCoordinateBounds *bounds =
    [[GMSCoordinateBounds alloc] initWithCoordinate:ongoingRideSourceLatLong coordinate:destination];
    GMSCameraPosition *camera = [mapView_ cameraForBounds:bounds insets:UIEdgeInsetsZero];
    mapView_.camera = camera;
    
}


-(void) zoomOutTheCameraWithSourceLatLong : (CLLocationCoordinate2D)source AndDestinationLatlong: (CLLocationCoordinate2D)destination {
    GMSCoordinateBounds *bounds =
    [[GMSCoordinateBounds alloc] initWithCoordinate:destination coordinate:destination];
    [bounds includingCoordinate:source];
    //    GMSCameraPosition *camera = [mapView_ cameraForBounds:bounds insets:UIEdgeInsetsZero];
    [mapView_ animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:15.0f]];
}

-(void) checkForDummyRequestStatus {
    if([APPDELEGATE connected]){
//         NSString *strReqId=[pref objectForKey:PREF_REQ_ID];
        NSString *strReqId= @"11933";   //@"4225";  //@"4173"  //@"4174" // @"3583"// 4314  //@"4798" //@"5607" //@"5609" //6208 // @"6222"  // "6661"
        //6208 -> newlatlong, newBearing ->
        //622
//        NSString * dummyUrl = @"getrequest?id=659&token=2y10BJwp3BsjlWIQa55UNtoCCugjBvkjG4ovwqs3MluHuv2E1oS59NcS&request_id=7318&last_walk_id=206779&lymo_device_id=860";
        /*
         reverse trip anhishek
        NSString * strForUrl = [NSString stringWithFormat:@"%@?%@=%@&%@=%@&%@=%@&%@=%@&%@=%@",@"getdummyrequest",PARAM_ID,@"323",PARAM_TOKEN,@"2y10iiPuuU1O4fm5L5C3VEZCU6cXaBaEV8FXufbt2hEqVtIhJdH6nN2",PARAM_REQUEST_ID,@"7458",PARAM_LAST_WALKER_ID,lastWalkerId,PARAM_LYMO_DEVICE_ID,@"835"];
        
         */
//        NSString * dummyUrl = @"http://taxi.active.agency/user/getdummyrequest?id=659&token=2y102uoV6S2IZlE00oQZDEhKS2Vh2mJFBbPssEu6lf3bky62fZ9YMHp&request_id=7050&last_walk_id=178490&lymo_device_id=835";
        
        NSString *strForUrl=[NSString stringWithFormat:@"%@?%@=%@&%@=%@&%@=%@&%@=%@&%@=%@",@"getdummyrequest",PARAM_ID,[pref objectForKey:PREF_USER_ID],PARAM_TOKEN,[pref objectForKey:PREF_USER_TOKEN],PARAM_REQUEST_ID,strReqId,PARAM_LAST_WALKER_ID,lastWalkerId,PARAM_LYMO_DEVICE_ID,[pref objectForKey:PREF_LYMO_DEVICE_ID]];
//        ALog(@"The checkForRequestStatus url is = %@", strForUrl);
        // NSString *strForUrl=[NSString stringWithFormat:@"%@?%@=%@&%@=%@&%@=%@",FILE_GET_REQUEST,PARAM_ID,@"222",PARAM_TOKEN,@"2y10a5RMW0Z3TuJkScXEh0QdokzroiO4cTW6L9lLYsYV9BFe28DJ6lS",PARAM_REQUEST_ID,strReqId];
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:strForUrl withParamData:nil withBlock:^(id response, NSError *error){
            if(navBackPressedBool){
                if (response == Nil){
//                    [customAlertView setContainerView:[APPDELEGATE createDemoView:UNABLE_TO_REACH view:self.view]];
//                    [customAlertView show];
                }else if (response){
                    if([[response valueForKey:@"success"]boolValue] && [[response valueForKey:@"status"] intValue]) {
                        //ALog(@"GET REQ--->%@",response);
                        NSMutableDictionary *dictWalker=[response valueForKey:@"walker"];
                        if([[response valueForKey:@"status"] intValue]==1){
                            if([[response valueForKey:@"is_completed"] intValue]!=0){
                                [timerForCheckReqStatus invalidate];
                                timerForCheckReqStatus = nil;
                                _lymoArrivingLbl.text=@"Trip Ended";
                                dispatch_once(&onceToken, ^{
                                    rideCompleteTripID=[response valueForKey:@"trip_id"];
                                    rideCompleteDate=[response valueForKey:@"request_end_date"];
                                    rideCompleteCarCatorgery=[dictWalker valueForKey:@"type_name"];
                                    rideCompleteTime=[response valueForKey:@"request_end_time"];
                                    rideCompletePayment=[response valueForKey:@"payment_type_content"];
                                    rideCompletePrice=[response valueForKey:@"total"];
                                    rideCompleteMessage=[response valueForKey:@"payment_description"];
                                    rideCompleteDriveIcon=[dictWalker valueForKey:@"picture"];
                                    rideCompleteDriverCarCategory=[dictWalker valueForKey:@"car_model"];
                                    rideCompleteDriverCarNumber=[dictWalker valueForKey:@"car_number"];
                                    rideCompleteDriverName=_startRideDetailName.text;
                                    lastWalkerId = @"0";
//                                    [self performSegueWithIdentifier:STRING_SEGUE_RIDE_COMPLETE sender:self];
                                });
                                // _webView.hidden=NO;
                                // ALog(@"%@",[response objectForKey:@"content"]);
                                //[_webView loadHTMLString:[NSString stringWithFormat:@"%@",[response objectForKey:@"content"]] baseURL:nil];
                                
                            }else{
                                _mapPin.hidden=YES;
                                _noCarsAvailableHolderView.hidden=YES;
                                _pulseView.hidden=YES;
                                //Booking page Assets hidden
                                _navMenuBtn.hidden=YES;
                                _rideNowLaterBtnView.hidden=YES;
                                _pageControl.hidden=YES;
                                myView1.hidden=YES;
                                _confromRideLbl.hidden=YES;
                                _lymo_Logo.hidden=YES;
                                _navOriginFavBtn.hidden=YES;
                                _navOriginSearchBtn.hidden=YES;
                                _destinationFavBtn.hidden=YES;
                                _destinationSearchBtn.hidden=YES;
                                _originTextFiled.enabled=NO;
                                _originTextFieldHolder.userInteractionEnabled=NO;
                                _destinationTextFiled.enabled=NO;
                                _destinationTextFieldHolder.userInteractionEnabled=YES;
                                
                                //Cancel ride button
                                _startRideDetailCancelView.userInteractionEnabled = YES;
                                _startRideCancelLbl.textColor=[UIColor blackColor];
                                _startRideCancelIcon.image=[UIImage imageNamed:@"Cancel_icon"];
                                
                                //Start ride view hidden
                                if(startRideEnable){
                                    _startRideDetailBigView.hidden=NO;
                                    _startRideLocationBtn.hidden=YES;
                                    _startRideView.hidden=YES;
                                    _navigationView.hidden=YES;
                                    _destinationView.hidden=YES;
                                }else{
                                    _startRideDetailBigView.hidden=YES;
                                    _startRideLocationBtn.hidden=NO;
                                    _startRideView.hidden=NO;
                                    _navigationView.hidden=NO;
                                    _destinationView.hidden=NO;
//                                    if([[pref valueForKey:PREF_SETTING_RIDE_NOW_DESTINATION] boolValue]){
//                                        _destinationView.hidden=NO;
//                                    }else{
//                                        _destinationView.hidden=YES;
//                                    }
                                }
                                _lymoArrivingLbl.hidden=NO;
                                
                                //RideLater hidden
                                _rideNowBigView.hidden=YES;
                                _navBackView.hidden=NO;
                                
                                _startRideName.text=[NSString stringWithFormat:@"%@ %@",[dictWalker objectForKey:@"first_name"],[dictWalker objectForKey:@"last_name"]];
                                _startRideDetailName.text=[NSString stringWithFormat:@"%@ %@",[dictWalker objectForKey:@"first_name"],[dictWalker objectForKey:@"last_name"]];
                                
                                [_startRideIcon downloadFromURL:[dictWalker objectForKey:@"picture"] withOutLoader:nil];
                                [_startRideDetailIcon downloadFromURL:[dictWalker objectForKey:@"picture"] withOutLoader:nil];
                                _startRideDetailCarType.text=[dictWalker objectForKey:@"car_model"];
                                _startRideCarType.text=[dictWalker objectForKey:@"car_model"];
                                _startRideCarNumber.text=[dictWalker objectForKey:@"car_number"];
                                _startRideDetailCarNumber.text=[dictWalker objectForKey:@"car_number"];
                                
                                
                                self.startRideRatingView.delegate = self;
                                self.startRideRatingView.emptySelectedImage = [UIImage imageNamed:@"StarEmpty"];
                                self.startRideRatingView.fullSelectedImage = [UIImage imageNamed:@"StarFull"];
                                self.startRideRatingView.contentMode = UIViewContentModeScaleAspectFill;
                                self.startRideRatingView.maxRating = 5;
                                self.startRideRatingView.minRating = 0;
                                self.startRideRatingView.rating = [[dictWalker objectForKey:@"rating"] floatValue];
                                self.startRideRatingView.editable = NO;
                                self.startRideRatingView.halfRatings = NO;
                                self.startRideRatingView.floatRatings = YES;
                                _startRideRating.text=[dictWalker objectForKey:@"rating"];
                                
                                self.startRideDetailRatingView.delegate = self;
                                self.startRideDetailRatingView.emptySelectedImage = [UIImage imageNamed:@"StarEmpty"];
                                self.startRideDetailRatingView.fullSelectedImage = [UIImage imageNamed:@"StarFull"];
                                self.startRideDetailRatingView.contentMode = UIViewContentModeScaleAspectFill;
                                self.startRideDetailRatingView.maxRating = 5;
                                self.startRideDetailRatingView.minRating = 0;
                                self.startRideDetailRatingView.rating = [[dictWalker objectForKey:@"rating"] floatValue];
                                self.startRideDetailRatingView.editable = NO;
                                self.startRideDetailRatingView.halfRatings = NO;
                                self.startRideDetailRatingView.floatRatings = YES;
                                _startRideDetailRating.text=[dictWalker objectForKey:@"rating"];
                                
                                strForWalkerPhone=[dictWalker objectForKey:@"phone"];
                                
                                strForCurrentPage=@"startride";
                                if ([lastWalkerId isEqualToString:@"0"]) {
                                    [mapView_ clear];
                                    markerOwner.map=nil;
                                    markerOwner=nil;
                                    markerOwnerDest.map=nil;
                                    markerOwnerDest=nil;
                                    [self deleteTheFileNamed:@"yourFile.txt"];
                                    [self deleteTheFileNamed:@"myfile.txt"];
                                    if(![[response valueForKey:@"latitude"] isEqualToString:@""] && ![[response valueForKey:@"longitude"] isEqualToString:@""]){
                                        
                                        CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake([[response valueForKey:@"latitude"] doubleValue], [[response valueForKey:@"longitude"] doubleValue]);
                                        ongoingRideSourceLatLong = coordinates;
                                        
                                        //                                    double bearing = [[dictWalker valueForKey:@"bearing"]doubleValue];
                                        markerOwner = [GMSMarker markerWithPosition:coordinates];
                                        //                                        markerOwner.icon=[GMSMarker markerImageWithColor:[UIColor redColor]]; // commented on 18072016
                                        markerOwner.icon=[UIImage imageNamed:@"mapPin"];
                                        //                                        [UIImage imageNamed:@"mapPin"];
                                        markerOwner.map = mapView_;
                                        isActivityControllershown=NO;
                                        markerOwner.position = coordinates;
                                    }
                                    
                                    if((![[response valueForKey:@"dest_latitude"] isEqualToString:@""] && ![[response valueForKey:@"dest_longitude"] isEqualToString:@""]) && (![[response valueForKey:@"dest_latitude"] isEqualToString:@"0"] && ![[response valueForKey:@"dest_longitude"] isEqualToString:@"0"])){
                                        
                                        CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake([[response valueForKey:@"dest_latitude"] doubleValue], [[response valueForKey:@"dest_longitude"] doubleValue]);
                                        isActivityControllershown=NO;
                                        markerOwnerDest = [GMSMarker markerWithPosition:coordinates];
                                        markerOwnerDest.icon=[UIImage imageNamed:@"mapPindest"];
                                        markerOwnerDest.map = mapView_;
                                        markerOwnerDest.position = coordinates;
                                        _destinationTextFiled.text= [response valueForKey:@"destination_address"];
                                    }else {
                                        markerOwnerDest.map = nil;
                                        markerOwnerDest = nil;
                                        ALog(@"destination is cleared");
                                    }
                                }
//                                 [mapView_ clear];  // commneted for testing purpose   // uncommenting on 30/05/2019
                                if([[response valueForKey:@"is_walker_started"] intValue]!=0){
                                    _lymoArrivingLbl.text=@"Orbit Arriving";
                                    _destinationView.userInteractionEnabled=YES;
                                    _originTextFieldHolder.userInteractionEnabled=NO;
                                }
                                
                                if([[response valueForKey:@"is_walker_arrived"] intValue]!=0){
                                    _lymoArrivingLbl.text=@"Orbit Arrived";
                                    _destinationView.userInteractionEnabled=YES;
                                    _originTextFieldHolder.userInteractionEnabled=NO;
                                }
                                
                                if([[response valueForKey:@"is_walk_started"] intValue]!=0){
                                    _lymoArrivingLbl.text=@"Trip Started";
                                    //                                    [mapView_ clear];  // commneted on 06062016
                                    //                                    driver_marker = nil;
                                    _startRideDetailCancelView.userInteractionEnabled = NO;
                                    _startRideCancelLbl.textColor=[UIColor lightGrayColor];
                                    _startRideCancelIcon.image=[UIImage imageNamed:@"Cancel_gray"];
                                    _cancelAlertBigView.hidden=YES;
                                    _pulseView.hidden=YES;
                                    
                                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:PREF_IS_FAV];
                                    //                                    [arrPath removeAllObjects];
                                    //                                    arrPath=[[response valueForKey:@"locationdata"] mutableCopy];
                                    [arrPath addObjectsFromArray:[[response valueForKey:@"locationdata"] mutableCopy]];
                                    
                                    if ([arrPath count] > 1) {
                                        
                                        if (arrPath.count>1) {
                                            animationTime=getRequestCallTime/arrPath.count;
                                        }else{
                                            animationTime=0.2;
                                        }
                                        // settimer to check drivestatus time = 5.0
                                        [timerForCheckReqStatus invalidate];
                                        timerForCheckReqStatus = nil;
                                        [self drawPath];
                                        lastWalkerId=[[arrPath lastObject] valueForKey:@"id"];
                                        /*************/
                                    } else {
                                        [timerForCheckReqStatus invalidate];
                                        timerForCheckReqStatus = nil;
                                        [self performSelector:@selector(setTimerToCheckDriverStatus) withObject:nil afterDelay:getRequestCallTime];
                                    }
                                    
                                    if ((([[response valueForKey:@"is_walker_started"] intValue]!=0) || ([[response valueForKey:@"is_walker_arrived"] intValue]!=0) || ([[response valueForKey:@"is_walk_started"] intValue]!=0)) && ([[response valueForKey:@"is_completed"] intValue]==0)) {
                                        onceToken=0;
                                    }
                                    
                                }else{
                                    //mapView
//                                    [mapView_ clear];   // uncommenting on 30/05/2019
                                    CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake([[dictWalker valueForKey:@"latitude"]doubleValue],[[dictWalker valueForKey:@"longitude"]doubleValue]);                                    double bearing = [[dictWalker valueForKey:@"bearing"]doubleValue];
                                    if (driver_marker == nil) {
                                        driver_marker = [GMSMarker markerWithPosition:coordinates];
                                        driver_marker.icon=driverCarIcon;
                                        
                                    }
                                        driver_marker.map = mapView_;
                                        [CATransaction begin];
                                        [CATransaction setAnimationDuration:2.0];
                                        driver_marker.position = coordinates;
                                        driver_marker.rotation = bearing;
                                        [CATransaction commit];
                                }
                            }
                        }else if([[response valueForKey:@"status"] intValue]==2){
                            [timerForCheckReqStatus invalidate];
                            timerForCheckReqStatus=nil;
                            [customAlertView setContainerView:[APPDELEGATE createDemoView:[response valueForKey:@"error"] view:self.view]];
                            [customAlertView show];
                            
                            _pulseView.hidden=YES;
                            _RideNowBtnView.hidden=NO;
                            _RideNowView.hidden=NO;
                            _destinationView.hidden=NO;
                            _navigationView.hidden=NO;
                            
                            _cancelAlertBigView.hidden=YES;
                            startRideEnable=NO;
                            strForCancelReasonText=@"";
                            strForCancelReasonID=@"";
                            [pref removeObjectForKey:PARAM_REQUEST_ID];
                            [self navBackViewGesture:nil];
//                            [APPDELEGATE showToastMessage:NSLocalizedString(@"REQUEST_CANCEL", nil)];
                        }
                    }
//                       [APPDELEGATE customerSetting:[response valueForKey:@"customer_setting"] ShowRideComplete:YES ShowCancelPayment:YES];;
                }
            }
        }];
    }
    else
    {
        [timerForCheckReqStatus invalidate];
        timerForCheckReqStatus = nil;
        [customAlertView setContainerView:[APPDELEGATE createDemoView:NO_INTERNET view:self.view]];
        [customAlertView show];
    }
}


-(NSArray*)getLatLongFromSnapToRoadApi: (NSArray*)latLongArray {
    
    NSArray* newArray = latLongArray;
    return newArray;
}

-(void)readDataFromFile{
    //get the path of our apps Document Directory(NSDocumentDirectory)
    //Yes - expand tilde if applicable
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //the path is stored in the first element
    NSString *documentDir = [paths objectAtIndex:0];
    
    //append the name of our file to the path:  /path/to/text.txt
    NSString * myFilePath = [documentDir stringByAppendingPathComponent:@"myfile.txt"];
      NSString * yourFilePath = [documentDir stringByAppendingPathComponent:@"yourFile.txt"];
    //store any errors
    NSError *error;
    
    //READ NSString FROM FILE
    if ([[NSFileManager defaultManager] fileExistsAtPath:myFilePath]){
        NSString *text = [NSString stringWithContentsOfFile:myFilePath encoding:NSUTF8StringEncoding error:&error];
        ALog(@"The file after overrirting = \n%@",text);
        
    }else {
        ALog(@"The path for yourfile.txt not found = %@", myFilePath);
    }
        
    if ([[NSFileManager defaultManager] fileExistsAtPath:yourFilePath]) {
        NSString *text1 = [NSString stringWithContentsOfFile:yourFilePath encoding:NSUTF8StringEncoding error:&error];
        ALog(@"The file without overrirting = \n%@",text1);
        if(text1){
            ALog(@"Success");
        }else{
            ALog(@"Error: %@",[error localizedDescription]);
        }
    } else {
        ALog(@"The path for yourfile.txt not found = %@", yourFilePath);
    }

}
-(void)storeWithOutOverRidewithString: (NSString *)latLongString {
    
    // Here you get access to the file in Documents directory of your application bundle.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [paths objectAtIndex:0];
    NSString *documentFile = [documentDir stringByAppendingPathComponent:@"yourFile.txt"];
    
    // Here you read current existing text from that file
    NSString *textFromFile = @"";
    if ([[NSFileManager defaultManager] fileExistsAtPath:documentFile]) {
         textFromFile = [NSString stringWithContentsOfFile:documentFile encoding:NSUTF8StringEncoding error:nil];
    }
    
    // Here you append new text to the existing one
    NSString *textToFile = [textFromFile stringByAppendingString:latLongString];
    // Here you save the updated text to that file
    [textToFile writeToFile:documentFile atomically:YES encoding:NSUTF8StringEncoding error:nil];
}


- (void)deleteTheFileNamed:(NSString *)filename
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:filename];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if (success) {
//        UIAlertView *removedSuccessFullyAlert = [[UIAlertView alloc] initWithTitle:@"Congratulations:" message:@"Successfully removed" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
//        [removedSuccessFullyAlert show];
        ALog(@"removed the file named %@", filename);
    }
    else
    {
        ALog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
}

#pragma mark - Draw Route Methods

-(void)drawPath
{
    ALog(@"total number of coordinates are %lu", (unsigned long)arrPath.count);
    if ([arrPath count]) {
        [self moveCarWithAnimationToTheCoordinateWithBearing:[arrPath firstObject]];
    } else {
        [self checkForRequestStatus];
//        [self checkForDummyRequestStatus];
    }
}


-(void)moveCarWithAnimationToTheCoordinateWithBearing: (NSDictionary*) newCoordinate {
    
//    NSString* latLongString = [NSString stringWithFormat:@"%0.15f,   %0.15f, bearing: %0.15f \n",[[newCoordinate valueForKey:@"latitude"]doubleValue], [[newCoordinate valueForKey:@"longitude"]doubleValue], [[newCoordinate valueForKey:@"bearing"]doubleValue]];
//    [self storeWithOutOverRidewithString:latLongString];
    CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake([[newCoordinate valueForKey:@"latitude"]doubleValue],[[newCoordinate valueForKey:@"longitude"]doubleValue]);
    double bearing = [[newCoordinate valueForKey:@"bearing"]doubleValue];
    if (!oldCoordinateforBearing.longitude) {
        oldCoordinateforBearing = CLLocationCoordinate2DMake([strForCurLatitude doubleValue],[strForCurLongitude doubleValue]);
    }
    ALog(@"Bearing is = %f, coordinates = %f, %f", bearing, coordinates.latitude, coordinates.longitude);
    if (oldLattitide) {
        
        if ([oldLattitide isEqualToString:[newCoordinate valueForKey:@"latitude"]] && [oldLongitude isEqualToString:[newCoordinate valueForKey:@"longitude"]] ) {
            ALog(@"both old latlong and new latlong are same");
            [self RemoveFirstObjectCallDrawPathAgain:newCoordinate];
        }else {
            if (driver_marker == nil) {
                driver_marker = [GMSMarker markerWithPosition:coordinates];
                driver_marker.icon=driverCarIcon;
                oldBearing=0.0;
            }
            driver_marker.map = mapView_;
            [CATransaction begin];
            if (!animationTime) {
                animationTime=0.2f;
            }
            [CATransaction setValue:[NSNumber numberWithFloat: animationTime] forKey:kCATransactionAnimationDuration];
            [CATransaction setCompletionBlock:^{
                [self RemoveFirstObjectCallDrawPathAgain:newCoordinate];
            }];
            driver_marker.position = coordinates;
            
            if (round(bearing) != 0) {
                driver_marker.rotation = bearing;
            }
            [self focusOnCoordinate:coordinates];
            [CATransaction commit];
        }
    }else {
        oldLattitide=strForCurLatitude;
        oldLongitude=strForCurLongitude;
        
        if (driver_marker == nil) {

            driver_marker = [GMSMarker markerWithPosition:coordinates];
            driver_marker.icon=driverCarIcon;
            
            oldBearing=0.0;
        }
        driver_marker.map = mapView_;
        [CATransaction begin];
        [CATransaction setValue:[NSNumber numberWithFloat: 0.1f] forKey:kCATransactionAnimationDuration];
        [CATransaction setCompletionBlock:^{
            [self RemoveFirstObjectCallDrawPathAgain:newCoordinate];
        }];
        driver_marker.position = coordinates;
        double bearing = [[newCoordinate valueForKey:@"bearing"]doubleValue];
        ALog(@"Bearing is = %f, coordinates = %f, %f", bearing, coordinates.latitude, coordinates.longitude);
        if (round(bearing) != 0) {
            driver_marker.rotation = bearing;
        }
        [self focusOnCoordinate:coordinates];
        ALog(@"the current location %f, %f and bearinf = %f", coordinates.latitude, coordinates.longitude,[[newCoordinate valueForKey:@"bearing"]doubleValue]);
        [CATransaction commit];

    }
}

- (void)focusOnCoordinate:(CLLocationCoordinate2D) coordinate {
    [mapView_ animateToLocation:coordinate];
//    [mapView_ animateToBearing:0];
    [mapView_ animateToViewingAngle:0];
//    [mapView_ animateToZoom:zoom];
    [mapView_ animateToZoom:16.0];
}

-(void)RemoveFirstObjectCallDrawPathAgain: (NSDictionary*) newCoordinate  {
    if ([arrPath count]) {
        oldLattitide= [newCoordinate valueForKey:@"latitude"];
        oldLongitude=[newCoordinate valueForKey:@"longitude"];
        oldCoordinateforBearing = CLLocationCoordinate2DMake([[newCoordinate valueForKey:@"latitude"]doubleValue],[[newCoordinate valueForKey:@"longitude"]doubleValue]);
        [arrPath removeObjectAtIndex:0];
//            [arrPath removeObjectsInRange:NSMakeRange(0, MIN(5, arrPath.count))];
    }
    [self drawPath];
}


#pragma mark - Promo code view

- (void)promoCodeViewGesture:(UITapGestureRecognizer*)sender {
    if([APPDELEGATE connected])  {
        _promoCodeBigView.hidden=NO;
        if(promoApplied){
            [_promoCodeTxt resignFirstResponder];
            _promoCodeTxt.enabled=NO;
            if([strForCurrentPage isEqualToString:@"ridenow"]){
                _promoCodeTxt.text=_rideNowCouponLbl.text;
            }else{
                _promoCodeTxt.text=_rideLaterCouponLbl.text;
            }
            [_promoCodeApplyBtn setTitle:@"REMOVE" forState:UIControlStateNormal];
        }else{
            _promoCodeTxt.enabled=YES;
            _promoCodeTxt.text=@"";
            [_promoCodeApplyBtn setTitle:@"APPLY" forState:UIControlStateNormal];
            [_promoCodeTxt becomeFirstResponder];
        }
    }else{
        [customAlertView setContainerView:[APPDELEGATE createDemoView:NO_INTERNET view:self.view]];
        [customAlertView show];
    }
    
}

- (IBAction)promoCodeCancelBtn:(id)sender {
    [self.view endEditing:YES];
    _promoCodeBigView.hidden=YES;
}

- (IBAction)promoCodeApplyBtn:(id)sender {
    [_promoCodeTxt resignFirstResponder];
    if(promoApplied){
        if([strForCurrentPage isEqualToString:@"ridenow"]){
            _rideNowCouponLbl.text=@"No Coupon";
        }else{
            _rideLaterCouponLbl.text=@"No Coupon";
        }
        _promoCodeBigView.hidden=YES;
        [pref setObject:@"" forKey:PREF_PROMO];
        promoApplied=NO;
    }else{
        if([APPDELEGATE connected])  {
            if(_promoCodeTxt.text.length<1){
                [customAlertView setContainerView:[APPDELEGATE createDemoView:PLEASE_ENTER_PROMO_CODE view:self.view]];
                [customAlertView show];
            } else {
                NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
                [dictParam setValue:[pref objectForKey:PREF_USER_TOKEN] forKey:PARAM_TOKEN];
                [dictParam setValue:[pref objectForKey:PREF_LYMO_DEVICE_ID] forKey:PARAM_LYMO_DEVICE_ID];
                [dictParam setValue:[pref objectForKey:PREF_USER_ID] forKey:PARAM_ID];
                NSString *val = [_promoCodeTxt.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [dictParam setValue:val forKey:PARAM_PROMO_CODE];
                if([strForCurrentPage isEqualToString:@"ridenow"]){
                    [dictParam setValue:@"0" forKey:PARAM_RIDE_NOW_LATER];
                }else{
                    [dictParam setValue:@"1" forKey:PARAM_RIDE_NOW_LATER];
                }
                NSObject * object = [pref objectForKey:PREF_PAYMENT_OPT];
                if(object != nil){
                    [dictParam setValue:[pref objectForKey:PREF_PAYMENT_OPT] forKey:PARAM_PAYMENT_OPT];
                }else{
                    [pref setValue:@"1" forKey:PREF_PAYMENT_OPT];
                    [pref synchronize];
                    [dictParam setValue:[pref objectForKey:PREF_PAYMENT_OPT] forKey:PARAM_PAYMENT_OPT];
                }
                
                [dictParam setValue:[pref objectForKey:PREF_CATEGORY_TYPE_ID] forKey:PARAM_TYPE];
                [APPDELEGATE startLoader:self.view giveSpaceFornavigationBar:NO];
                [APPDELEGATE changeLoaderBackgroundColorwithAlpha:[UIColor clearColor]];
                ALog(@"promocode dictionary = %@", dictParam);
                AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
                [afn getDataFromPath:FILE_PROMOCODE withParamData:dictParam withBlock:^(id response, NSError *error)
                 {
                     ALog(@"PromoCode Response ---> %@",response);
                     if (response == Nil){
                         if (error.code == -1005) {
                             [APPDELEGATE stopLoader:self.view];
                             [self promoCodeApplyBtn:sender];
                             
                         }else {
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 [APPDELEGATE stopLoader:self.view];
                                 [APPDELEGATE showAlertOnTopMostControllerWithText:UNABLE_TO_REACH];
                             });
                         }
                     }else if (response)
                     {
                         if([[response valueForKey:@"success"]boolValue])
                         {
                             [pref setObject:_promoCodeTxt.text forKey:PREF_PROMO];
                             if([strForCurrentPage isEqualToString:@"ridenow"]){
                                 _rideNowCouponLbl.text=_promoCodeTxt.text;
                             }else{
                                 _rideLaterCouponLbl.text=_promoCodeTxt.text;
                             }
                             _promoCodeBigView.hidden=YES;
                             promoApplied=YES;
                             [pref setValue:@"" forKey:@"Paymentselected"];
                             [customAlertView setContainerView:[APPDELEGATE createDemoView:[response valueForKey:@"message"] view:self.view]];
                             [customAlertView show];
                         }
                         else{
                             promoApplied=NO;
                             [customAlertView setContainerView:[APPDELEGATE createDemoView:[response valueForKey:@"error"] view:self.view]];
                             [customAlertView show];
                         }
                          [APPDELEGATE customerSetting:[response valueForKey:@"customer_setting"] ShowRideComplete:YES ShowCancelPayment:YES FromViewController:self];;
                         
                     }
                     [APPDELEGATE stopLoader:self.view];
                 }];
            }
        }else{
            [customAlertView setContainerView:[APPDELEGATE createDemoView:NO_INTERNET view:self.view]];
            [customAlertView show];
        }
    }
}

#pragma mark - Fare Estimate View

- (void)rideNowFareEstimateViewGesture:(UITapGestureRecognizer*)sender {
    if ([APPDELEGATE connected]) {
        [self performSegueWithIdentifier:STRING_SEGUE_BOOKING_TO_FARE sender:self];
    }else {
        [customAlertView setContainerView:[APPDELEGATE createDemoView:NO_INTERNET view:self.view]];
        [customAlertView show];
    }
    
}


#pragma mark - Payment View

- (void)rideNowPaymentViewGesture:(UITapGestureRecognizer*)sender {
    if ([APPDELEGATE connected]) {
        if ([[pref valueForKey:PREF_SETTING_CARD_PAYMENT] boolValue]) {
             [self performSegueWithIdentifier:STRING_SEGUE_CARD_LIST sender:self];
        }
    }else {
        [customAlertView setContainerView:[APPDELEGATE createDemoView:NO_INTERNET view:self.view]];
        [customAlertView show];
    }
    
}

#pragma mark - cardListViewController Delegate

-(void)selectedCardDetailsDictionaryis:(NSDictionary *)cardDetailsDict{
    rideNowCardImageUrl = [cardDetailsDict valueForKey:@"image"];
    rideNowPaymentId = [NSString stringWithFormat:@"%@", [cardDetailsDict valueForKey:@"id"]];
    rideNowLastFour = [NSString stringWithFormat:@"**** %@",[cardDetailsDict valueForKey:@"last_four"]];
    ALog(@"card list is responded through delegate details are %@", cardDetailsDict);
}

-(void) paymentToggle {
    ALog(@"Payment toggle value....%@",[pref valueForKey:@"Paymentselected"]);
    if ([[pref valueForKey:@"Paymentselected"] isEqualToString:@"isPromoChange"]) {
        if([strForCurrentPage isEqualToString:@"ridenow"]){
            _rideNowCouponLbl.text=@"No Coupon";
        }else{
            _rideLaterCouponLbl.text=@"No Coupon";
        }
        [pref setObject:@"" forKey:PREF_PROMO];
        ALog(@"Promo toggled");
        promoApplied=NO;
    }else{
        //  promoApplied=YES;
        ALog(@"Promo same");
    }
}

#pragma mark - Pulse view

- (void)setupInitialValues {
    
    self.halo.haloLayerNumber = 4;
    self.halo.radius =200;
    self.halo.animationDuration =4.0;
//    UIColor *color = rideNowAndLaterActiveColor;
    UIColor *color = [UIColor blackColor];
    [self.halo setBackgroundColor:color.CGColor];
}

- (IBAction)pulseViewCancelBtn:(id)sender {
    if([APPDELEGATE connected]){
        [pref removeObjectForKey:PARAM_REQUEST_ID];
        NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
        [dictParam setValue:[pref objectForKey:PREF_USER_ID] forKey:PARAM_ID];
        [dictParam setValue:[pref objectForKey:PREF_USER_TOKEN] forKey:PARAM_TOKEN];
        [dictParam setValue:[pref objectForKey:PREF_LYMO_DEVICE_ID] forKey:PARAM_LYMO_DEVICE_ID];
        [dictParam setValue:[pref stringForKey:PREF_REQ_ID] forKey:PARAM_REQUEST_ID];
        [dictParam setValue:@"cancel" forKey:PARAM_TYPE];
        ALog(@"pulseview cancel button dictionary = %@", dictParam);
        [APPDELEGATE startLoader:self.view giveSpaceFornavigationBar:NO];
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [afn getDataFromPath:FILE_CANCEL_REQUEST withParamData:dictParam withBlock:^(id response, NSError *error)
         {
             if (response == Nil){
                 if (error.code == -1005 ) {
                     [APPDELEGATE stopLoader:self.view];
                     [self pulseViewCancelBtn:sender];
                     
                 }else {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [APPDELEGATE stopLoader:self.view];
                         [APPDELEGATE showAlertOnTopMostControllerWithText:UNABLE_TO_REACH];
                     });
                 }
             }else if (response)
             {
                 if([[response valueForKey:@"success"]boolValue])
                 {
                     _pulseView.hidden=YES;
                     _RideNowBtnView.hidden=NO;
                     _RideNowView.hidden=NO;
                     _destinationView.hidden=NO;
                     _navigationView.hidden=NO;
                     
                     [timerForCheckReqStatus invalidate];
                     timerForCheckReqStatus=nil;
                     _cancelAlertBigView.hidden=YES;
                     startRideEnable=NO;
                     strForCancelReasonText=@"";
                     strForCancelReasonID=@"";
                     [pref removeObjectForKey:PARAM_REQUEST_ID];
                     [self navBackViewGesture:nil];
                     //                     [APPDELEGATE showToastMessage:NSLocalizedString(@"REQUEST_CANCEL", nil)];
                 }
                 else
                 {
                     ALog(@"could not cancel because no request id is generated so still requesting  ---> %@",response);
                 }
                  [APPDELEGATE customerSetting:[response valueForKey:@"customer_setting"] ShowRideComplete:YES ShowCancelPayment:YES FromViewController:self];;
             }
             [APPDELEGATE stopLoader:self.view];
         }];
    }
    else
    {
        [customAlertView setContainerView:[APPDELEGATE createDemoView:NO_INTERNET view:self.view]];
        [customAlertView show];
    }
}


#pragma mark - Start Ride Gesture actions


- (void)selectStartRideWalkerGesture:(UITapGestureRecognizer*)sender {
    [self setView:_startRideDetailBigView hidden:NO];
    _startRideLocationBtn.hidden=YES;
    _startRideView.hidden=YES;
    self.view.userInteractionEnabled=NO;
    [UIView transitionWithView:mapView_
                      duration:0.2
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:NULL
                    completion:^(BOOL finished){
                        [self animateViewHeight:_navigationView withAnimationType:kCATransitionFromTop hidden:YES animationDuration:0.3];
                        [self animateViewHeight:_destinationView withAnimationType:kCATransitionFromTop hidden:YES animationDuration:0.2];
                        self.view.userInteractionEnabled=YES;
                    }];
    startRideEnable=YES;
    [_viewGoogleMap addSubview:startRideExpandView];
}

- (void)selectStartRideWalkerDetailsGesture:(UITapGestureRecognizer*)sender {
    _startRideDetailBigView.hidden=YES;
    _startRideLocationBtn.hidden=NO;
    [self setView:_startRideView hidden:NO];
    [UIView transitionWithView:mapView_
                      duration:0.2
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [self animateViewHeight:_navigationView withAnimationType:kCATransitionFromBottom show:YES animationDuration:0.3];
                        
                    }
                    completion:^(BOOL finished){
                        [self animateViewHeight:_destinationView withAnimationType:kCATransitionFromBottom show:YES animationDuration:0.1];
                        self.view.userInteractionEnabled=YES;
                    }];
    startRideEnable=NO;
    [startRideExpandView removeFromSuperview];
}

- (void)selectStartRideDetailsNumberGesture:(UITapGestureRecognizer*)sender {
    _driverCallPhoneLbl.text=[NSString stringWithFormat:@"%@",strForWalkerPhone];
    _driverCallBigView.hidden=NO;
}

- (void)selectStartRideDetailsCancelGesture:(UITapGestureRecognizer*)sender {
    if([APPDELEGATE connected])  {
        NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
        [dictParam setValue:[pref objectForKey:PREF_USER_TOKEN] forKey:PARAM_TOKEN];
        [dictParam setValue:[pref objectForKey:PREF_LYMO_DEVICE_ID] forKey:PARAM_LYMO_DEVICE_ID];
        [dictParam setValue:[pref objectForKey:PREF_USER_ID] forKey:PARAM_ID];
        [dictParam setValue:@"reason" forKey:PARAM_TYPE];
        [dictParam setValue:[pref stringForKey:PREF_REQ_ID] forKey:PARAM_REQUEST_ID];
        [APPDELEGATE startLoader:self.view giveSpaceFornavigationBar:NO];
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [afn getDataFromPath:FILE_CANCEL_REQUEST withParamData:dictParam withBlock:^(id response, NSError *error)
         {
             ALog(@"REFERAL Response ---> %@",response);
             if (response == Nil){
                 if (error.code == -1005) {
                     [APPDELEGATE stopLoader:self.view];
                     [self selectStartRideDetailsCancelGesture:sender];
                 }else {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [APPDELEGATE stopLoader:self.view];
                         [APPDELEGATE showAlertOnTopMostControllerWithText:UNABLE_TO_REACH];
                     });
                 }
             }else if (response)
             {
                 if([[response valueForKey:@"success"]boolValue])
                 {
                     [cancelReasonText removeAllObjects];
                     [cancelReasonID removeAllObjects];
                     _cancelAlertBigView.hidden=NO;
                     _cancelAlertYesBtn.enabled=NO;
                     [_cancelAlertYesBtn setTitleColor:[UIColor colorWithRed:0.831 green:0.831 blue:0.831 alpha:1] forState:UIControlStateNormal];
                     NSMutableArray *reasons = [response valueForKey:@"reason"];
                     for(NSMutableDictionary *reasonContent in reasons){
                         [cancelReasonID addObject:[reasonContent valueForKey:@"id"]];
                         [cancelReasonText addObject:[reasonContent valueForKey:@"reason"]];
                     }
                 }
                 else{
                     [customAlertView setContainerView:[APPDELEGATE createDemoView:[response valueForKey:@"error"] view:self.view]];
                     [customAlertView show];
                 }
                  [APPDELEGATE customerSetting:[response valueForKey:@"customer_setting"] ShowRideComplete:YES ShowCancelPayment:YES FromViewController:self];;
                 
             }
             [_cancelTableView reloadData];
             [APPDELEGATE stopLoader:self.view];
         }];
    }else{
        [customAlertView setContainerView:[APPDELEGATE createDemoView:NO_INTERNET view:self.view]];
        [customAlertView show];
    }
    
}

-(void)openOriginSearchBarController:(UITapGestureRecognizer*)sender{
    LandingPageSearchingTextField=@"origin";
    [_originTextFiled resignFirstResponder];
    if([CLLocationManager locationServicesEnabled]&&
       [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied)
    {
        if ([APPDELEGATE connected]) {
            [pref setObject:_originTextFiled.text forKey:PREF_SEARCH_EDIT_ADDRESS];
            ALog(@"origin searchTextfiled default address is %@", _originTextFiled.text);
            [self performSegueWithIdentifier:STRING_SEGUE_SEARCH_PAGE sender:self];
        }else {
            [customAlertView setContainerView:[APPDELEGATE createDemoView:NO_INTERNET view:self.view]];
            [customAlertView show];
        }
        
    }else{
        UIAlertView* LocationStatus=[[UIAlertView alloc] initWithTitle:@"This app does not have access to Location services" message:@"Please allow Orbit to use location services .Turn it on from settings" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Settings", nil];
        [LocationStatus show];
    }
}

-(void)openDestinationSearchController:(UITapGestureRecognizer*)sender{
    LandingPageSearchingTextField=@"destination";
    [_destinationTextFiled resignFirstResponder];
    if([CLLocationManager locationServicesEnabled]&&
       [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied)
    {
        if ([APPDELEGATE connected]) {
            ALog(@"destination searchTextfiled default address before checkong is %@.", _destinationTextFiled.text);
            if (![_destinationTextFiled.text isEqualToString:@""]) {
                
                [pref setObject:@"destination" forKey:PREF_FROM_DESTINATION];
                [pref setObject:_destinationTextFiled.text forKey:PREF_SEARCH_EDIT_ADDRESS];
                ALog(@"destination searchTextfiled default address is %@", _destinationTextFiled.text);
            }else {
                [pref setObject:@"destination" forKey:PREF_FROM_DESTINATION];
                [pref setObject:@"" forKey:PREF_SEARCH_EDIT_ADDRESS];
            }
            //        [pref setBool:NO forKey:PREF_IS_FAV];
            [self performSegueWithIdentifier:STRING_SEGUE_SEARCH_PAGE sender:self];
        }else {
            [customAlertView setContainerView:[APPDELEGATE createDemoView:NO_INTERNET view:self.view]];
            [customAlertView show];
        }

    }else{
        UIAlertView* LocationStatus=[[UIAlertView alloc] initWithTitle:@"This app does not have access to Location services" message:@"Please allow Orbit to use location services .Turn it on from settings" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Settings", nil];
        [LocationStatus show];
    }
    
}

- (void)selectStartRideDetailsShareGesture:(UITapGestureRecognizer*)sender {
    if([[pref valueForKey:PREF_SETTING_RIDE_NOW_DESTINATION] boolValue] || _destinationTextFiled.text.length > 1){
        ALog(@"while sharing source = %@ and destination = %@ .", strForSourceAddress, strForDestinationAddress);
        [self shareText:[NSString stringWithFormat:@"Hey there !! I'm travelling in Orbit Car %@ with Driver %@ from %@ to %@",_startRideDetailCarNumber.text,_startRideDetailName.text,strForSourceAddress,strForDestinationAddress] andImage:nil andUrl:nil];
    }else{
        [self shareText:[NSString stringWithFormat:@"Hey there !! I'm travelling in Orbit Car %@ with Driver %@ from %@",_startRideDetailCarNumber.text,_startRideDetailName.text,strForSourceAddress] andImage:nil andUrl:nil];
    }
}

-(void)hidePromocodeKeyboard:(UITapGestureRecognizer* )sender {
    ALog(@"Innner view is called so hide keyboard");
    [_promoCodeTxt resignFirstResponder];
}
#pragma mark -start ride Cancel button Actions


- (IBAction)cancelAlertYesBtn:(id)sender {
    //    navBackPressedBool=NO;
    cancelTVCellSelectedIndexpath=nil;
    if([strForCancelReasonID isEqualToString:@""]){
        
    }
    if([CLLocationManager locationServicesEnabled])
    {
        if([APPDELEGATE connected]){
            [timerForCheckReqStatus invalidate];
            timerForCheckReqStatus=nil;
            NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
            [dictParam setValue:[pref objectForKey:PREF_USER_ID] forKey:PARAM_ID];
            [dictParam setValue:[pref objectForKey:PREF_USER_TOKEN] forKey:PARAM_TOKEN];
            [dictParam setValue:[pref objectForKey:PREF_LYMO_DEVICE_ID] forKey:PARAM_LYMO_DEVICE_ID];
            [dictParam setValue:[pref objectForKey:PREF_REQ_ID] forKey:PARAM_REQUEST_ID];
            [dictParam setValue:strForCancelReasonID forKey:PARAM_REASON_ID];
            [dictParam setValue:strForCancelReasonText forKey:PARAM_REASON];
            [dictParam setValue:@"trip_cancel" forKey:PARAM_TYPE];
            [dictParam addEntriesFromDictionary:[APPDELEGATE deviceInfo]];
            ALog(@"cancel_ride in current rides = %@", dictParam);
            [APPDELEGATE startLoader:self.view giveSpaceFornavigationBar:NO];
            [APPDELEGATE changeLoaderBackgroundColorwithAlpha :[UIColor colorWithRed:0 green:0 blue:0 alpha:0.0]];
            AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
            [afn getDataFromPath:FILE_CANCEL_REQUEST withParamData:dictParam withBlock:^(id response, NSError *error)
             {
                 ALog(@"the cancel requestresponse = %@", response);
                 if (response == Nil){
                     if (error.code == -1005 ) {
                         [APPDELEGATE stopLoader:self.view];
                         [self cancelAlertYesBtn:sender];
                         
                     }else {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [APPDELEGATE stopLoader:self.view];
                             [APPDELEGATE showAlertOnTopMostControllerWithText:UNABLE_TO_REACH];
                         });
                     }
                 } else if (response)
                 {
                     strForCancelReasonID=@"";
                     strForCancelReasonText=@"";
                     
                     ALog(@"the cancel requestresponse = %@", response);
                     if([[response valueForKey:@"success"]boolValue])
                     {
                         _mapPin.hidden=NO;
                         navBackPressedBool=NO;
                         [timerForCheckReqStatus invalidate];
                         timerForCheckReqStatus=nil;
                         _cancelAlertBigView.hidden=YES;
                         startRideEnable=NO;
                         strForCancelReasonText=@"";
                         strForCancelReasonID=@"";
                         strForCurrentPage=@"booking";
                         markerOwnerDest =nil;
                         markerOwner=nil;
                         _destinationTextFiled.enabled=YES;
                         _destinationTextFieldHolder.userInteractionEnabled=YES;
                         [self getMyLocationIsPressed];
                         
                         [pref removeObjectForKey:PARAM_REQUEST_ID];
                         [self navBackViewGesture:nil];
                         
                         
                         if (([[response valueForKey:@"cancel_amount_status"] boolValue]) && ([[response valueForKey:@"cancel_amount"] doubleValue] > 0))
                         {
                             // unpaid amount is there so show outstanding payment screen
                             ALog(@"Showing payment screen in booking page because ride complete is not available and old balance is %@ .", [response valueForKey:@"cancel_amount"]);
                             
                             NSMutableDictionary* outStandingDitc = [[NSMutableDictionary alloc] init];
                             [outStandingDitc setValue:[pref stringForKey:PREF_REQ_ID] forKey:@"requestId"];
                             [outStandingDitc setObject:[NSNumber numberWithBool:NO] forKey:@"isPushed"];
                             [outStandingDitc setValue:rideNowPaymentId forKey:@"cancel_payment_id"];
                             [outStandingDitc setValue:[response valueForKey:@"cancel_amount"] forKey:@"outStandingAmount"];
                             [outStandingDitc setValue:rideNowCardImageUrl forKey:@"cardImageUrl"];
                             [outStandingDitc setValue:rideNowLastFour forKey:@"cardLastFourString"];
                             [outStandingDitc setObject:[NSNumber numberWithBool:NO] forKey:@"isPresentedFromBookingPage"];
                             
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 [self showoutStandingPaymnetScreen:outStandingDitc];
                             });
                             
                             
                         } else {
                             // the cancelled amount is paid (amount deducted from card automatically or other means) so show ride cancelled screen
                             ALog(@"Showing cancel payment screen because ride is cancelled and amount paid from cancelled ride =  %@ .", [response valueForKey:@"cancel_amount"]);
                             NSMutableDictionary *cancelledDict = [[NSMutableDictionary alloc] init];
                             [cancelledDict setValue:[response valueForKey:@"cancel_amount"] forKey:@"strRideCompletePrice"];
                             [cancelledDict setObject:[[response valueForKey:@"request_data"] valueForKey:@"trip_id"] forKey:@"strRideCompleteTripID"];
                             
                             if ([response valueForKey:@"walker_data"]) {
                                 [cancelledDict setObject:[NSNumber numberWithBool:YES] forKey:@"isWalkerDetailsAvailable"];
                                 NSMutableDictionary *walkerDict=[response valueForKey:@"walker_data"];
                                 
                                 [cancelledDict setValue:[[response valueForKey:@"request_data"] valueForKey:@"cancellation_date"] forKey:@"strRideCompleteDate"];
                                 [cancelledDict setValue:[walkerDict valueForKey:@"car_model"] forKey:@"strRideCompleteCarCatorgery"];
                                 [cancelledDict setValue:[[response valueForKey:@"request_data"] valueForKey:@"cancellation_time"] forKey:@"strRideCompleteTime"];
                                 
                                 [cancelledDict setValue:[[response valueForKey:@"request_data"] valueForKey:@"payment_type"] forKey:@"strRideCompletePayment"];
                                 if ([response valueForKey:@"payment_description"]) {
                                     [cancelledDict setObject:[response valueForKey:@"payment_description"] forKey:@"strRideCompleteMessage"];
                                 }else{
                                     [cancelledDict setObject:@"" forKey:@"strRideCompleteMessage"];
                                 }
                                 [cancelledDict setObject:[walkerDict valueForKey:@"picture"] forKey:@"strRideCompleteDriveIcon"];
                                 
                                 if ([[walkerDict valueForKey:@"sec_car_model"] length] > 1) {
                                     [cancelledDict setObject:[walkerDict valueForKey:@"sec_car_model"] forKey:@"strRideCompleteDriverCarCategory"];
                                 }else {
                                     [cancelledDict setObject:[walkerDict valueForKey:@"car_model"] forKey:@"strRideCompleteDriverCarCategory"];
                                 }
                                 [cancelledDict setObject:[walkerDict valueForKey:@"car_number"] forKey:@"strRideCompleteDriverCarNumber"];
                                 [cancelledDict setObject:[NSString stringWithFormat:@"%@ %@",[walkerDict objectForKey:@"first_name"],[walkerDict objectForKey:@"last_name"]] forKey:@"strRideCompleteDriverName"];
                             } else {
                                 [cancelledDict setObject:[NSNumber numberWithBool:NO] forKey:@"isWalkerDetailsAvailable"];
                             }
                             
                             [cancelledDict setObject:[response valueForKey:@"cancel_amount"] forKey:@"strRideCompletePrice"];
                             [cancelledDict setObject:[response valueForKey:@"request_data"] forKey:@"trip_id"];
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 [self showcancelledPaidScreen:cancelledDict];
                             });
                         }
                     }
                     else
                     {
                         navBackPressedBool=YES;
                         _cancelAlertBigView.hidden=YES;
                         [self setTimerToCheckDriverStatus];
                         if ([response valueForKey:@"error"]) {
                             [customAlertView setContainerView:[APPDELEGATE createDemoView:[response valueForKey:@"error"] view:self.view]];
                             [customAlertView show];
                         }
                     }
                     [APPDELEGATE customerSetting:[response valueForKey:@"customer_setting"] ShowRideComplete:YES ShowCancelPayment:NO FromViewController:self];
                     
                 }
                 
                 [APPDELEGATE stopLoader:self.view];
             }];
        }
        else
        {
            [customAlertView setContainerView:[APPDELEGATE createDemoView:NO_INTERNET view:self.view]];
            [customAlertView show];
        }
    }
    else
    {
        [customAlertView setContainerView:[APPDELEGATE createDemoView:PLEASE_ENABLE_LOCATION_SERVICES view:self.view]];
        [customAlertView show];
    }
}

- (IBAction)cancelAlertNoBtn:(id)sender {
    _cancelAlertBigView.hidden=YES;
    strForCancelReasonText=@"";
    strForCancelReasonID=@"";
    cancelTVCellSelectedIndexpath=nil;
}


-(void)sendCancelledRequestAmountPaidEmailWithId: (NSString*)requestId{
    ALog(@"request id in cancel email = %@", requestId);
    if (![requestId  isEqual: @""]) {
        NSString *strForUrl=[NSString stringWithFormat:@"%@?%@=%@",FILE_SEND_CANCEL_EMAIL,PARAM_REQUEST_ID,requestId];
        ALog(@"The cancel email url in landing page is = %@", strForUrl);
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:strForUrl withParamData:nil withBlock:^(id response, NSError *error){
            ALog(@"response in cencel email = %@", response);
        }];
    }
}


-(void)showoutStandingPaymnetScreen: (NSDictionary*)cancelledDataDict {
    OutStandingPaymentsViewController *paymentVC = [[OutStandingPaymentsViewController alloc] initWithNibName:@"OutStandingPaymentsViewController" bundle:nil];
    paymentVC.isPushed=[[cancelledDataDict valueForKey:@"isPushed"] boolValue];
    paymentVC.request_id=[cancelledDataDict valueForKey:@"requestId"];
    paymentVC.cancel_payment_id=[cancelledDataDict valueForKey:@"cancel_payment_id"];
    paymentVC.outStandingAmount = [cancelledDataDict valueForKey:@"outStandingAmount"];
    paymentVC.cardImageUrl=[cancelledDataDict valueForKey:@"cardImageUrl"];
    paymentVC.cardLastFourString=[cancelledDataDict valueForKey:@"cardLastFourString"];
    paymentVC.isPresentedFromBookingPage=[[cancelledDataDict valueForKey:@"isPresentedFromBookingPage"] boolValue];
    UINavigationController * navCntl = [[UINavigationController alloc] initWithRootViewController :paymentVC];
    [self presentViewController:navCntl animated:YES completion:nil];
}

-(void)showcancelledPaidScreen: (NSDictionary*)cancelledDict{
    
    RideCancelledPaymentViewController *rideCancelledVC = [[RideCancelledPaymentViewController alloc] initWithNibName:@"RideCancelledPaymentViewController" bundle:nil];
    rideCancelledVC.strRideCompletePrice=[cancelledDict valueForKey:@"strRideCompletePrice"];
    rideCancelledVC.strRideCompleteTripID=[cancelledDict valueForKey:@"strRideCompleteTripID"];
    if ([[cancelledDict valueForKey:@"isWalkerDetailsAvailable"] boolValue]) {
        rideCancelledVC.isWalkerDetailsAvailable=[[cancelledDict valueForKey:@"isWalkerDetailsAvailable"] boolValue];
        rideCancelledVC.strRideCompleteDate=[cancelledDict valueForKey:@"strRideCompleteDate"];
        rideCancelledVC.strRideCompleteCarCatorgery=[cancelledDict valueForKey:@"strRideCompleteCarCatorgery"];
        rideCancelledVC.strRideCompleteTime=[cancelledDict valueForKey:@"strRideCompleteTime"];
        rideCancelledVC.strRideCompletePayment=[cancelledDict valueForKey:@"strRideCompletePayment"];
        rideCancelledVC.strRideCompleteMessage=[cancelledDict valueForKey:@"strRideCompleteMessage"];
        rideCancelledVC.strRideCompleteDriveIcon=[cancelledDict valueForKey:@"strRideCompleteDriveIcon"];
        rideCancelledVC.strRideCompleteDriverCarCategory=[cancelledDict valueForKey:@"strRideCompleteDriverCarCategory"];
        rideCancelledVC.strRideCompleteDriverCarNumber=[cancelledDict valueForKey:@"strRideCompleteDriverCarNumber"];
        rideCancelledVC.strRideCompleteDriverName=[cancelledDict valueForKey:@"strRideCompleteDriverName"];
    } else {
        rideCancelledVC.isWalkerDetailsAvailable=NO;
    }
    [self presentViewController:rideCancelledVC animated:YES completion:^{
        [self sendCancelledRequestAmountPaidEmailWithId:[pref objectForKey:PREF_REQ_ID]];
    }];
    rideCancelledVC.strRideCompletePrice=[cancelledDict valueForKey:@"strRideCompletePrice"];
    rideCancelledVC.strRideCompleteTripID=[cancelledDict valueForKey:@"trip_id"];
}
#pragma mark - TableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return cancelReasonID.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell...
    CancelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cancelCell" forIndexPath:indexPath];
    if (cell == nil) {
        cell=[[CancelTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cancelCell"];
    }
    cell.cancelReasonCell.textColor = [UIColor blackColor];
    cell.cancelReasonCell.highlightedTextColor = [UIColor whiteColor];
    cell.cancelBGImgView.image=nil;
    if(cancelReasonText.count > 0){
        cell.cancelReasonCell.text=[cancelReasonText objectAtIndex:indexPath.row];
        if (cancelTVCellSelectedIndexpath) {
            if (indexPath.row == cancelTVCellSelectedIndexpath.row) {
                cell.cancelBGImgView.image=[UIImage imageNamed:@"TVCell_selecetd"];
            }
        }
        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.separatorInset = UIEdgeInsetsZero;
    if(IS_OS_8_OR_LATER>8.0){
        cell.preservesSuperviewLayoutMargins = false;
    }
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


# pragma -mark TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    strForCancelReasonID=[cancelReasonID objectAtIndex:indexPath.row];
    strForCancelReasonText=[cancelReasonText objectAtIndex:indexPath.row];
    _cancelAlertYesBtn.enabled=YES;
    [_cancelAlertYesBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    cancelTVCellSelectedIndexpath=indexPath;
    [_cancelTableView reloadData];
}


#pragma mark -start ride driver call button Actions

- (IBAction)driverCallBtn:(id)sender {
    if(![strForWalkerPhone isEqualToString:@""]){
        NSString *urlstring=[NSString stringWithFormat:@"tel:%@",strForWalkerPhone];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlstring]];
    }
    _driverCallBigView.hidden=YES;
}

- (IBAction)driverCallCancelBtn:(id)sender {
    _driverCallBigView.hidden=YES;
}


#pragma mark - Surge Pop up

- (IBAction)surgeCancelBtn:(id)sender {
    _surgeBigView.hidden=YES;
    _navBackView.hidden=NO;
}

- (IBAction)surgeConfirmBtn:(id)sender {
    if ([APPDELEGATE connected]) {
        _surgeBigView.hidden=YES;
        [self createRequestForRideNow];
    } else {
    [customAlertView setContainerView:[APPDELEGATE createDemoView:NO_INTERNET view:self.view]];
    [customAlertView show];
}
    
}

#pragma mark -PickerView Actions

-(void)pickerDone{
    [viewForPicker removeFromSuperview];
    
    ALog(@"selected date = %@",[self getUTCFormateDate:datePicker.date]);
    _rideLaterDateLabel.text=[self getUTCFormateDate:datePicker.date];
    
    strForRideLaterDate = [self getUTCFormateDateToServer:datePicker.date];
    ALog(@"RIDE LATYER date = %@", strForRideLaterDate);
    recentlySelectedDate = datePicker.date;
    ALog(@"recently selected date = %@", recentlySelectedDate);
    //Booking page Assets hidden
    _navMenuBtn.hidden=YES;
    _rideNowLaterBtnView.hidden=YES;
    _pageControl.hidden=YES;
    myView1.hidden=YES;
    _navigationView.hidden=NO;
    _destinationView.hidden=NO;
//    if(![[pref valueForKey:PREF_SETTING_RIDE_LATER_DESTINATION] boolValue]){
//        _destinationView.hidden=NO;
//    }else{
//        _destinationView.hidden=YES;
//    }
    _confromRideLbl.hidden=NO;
    _lymo_Logo.hidden=YES;
    _navOriginFavBtn.hidden=YES;
    _navOriginSearchBtn.hidden=YES;
    _originTextFiled.enabled=NO;
    _originTextFieldHolder.userInteractionEnabled=NO;
    _destinationTextFieldHolder.userInteractionEnabled=YES;
    _noCarsAvailableHolderView.hidden=YES;
    
    //Start ride view hidden
    _startRideDetailBigView.hidden=YES;
    _startRideLocationBtn.hidden=YES;
    _startRideView.hidden=YES;
    _lymoArrivingLbl.hidden=YES;
    
    //RideLater hidden
    _rideLaterBigView.hidden=NO;
    _navBackView.hidden=NO;
    locationButton.hidden=YES;
    _noCarsAvailableHolderView.hidden=YES;
    strForCurrentPage=@"ridelater";
    
//    _rideLaterCouponLbl.text=@"No Coupon";
    
    
    if ([[pref objectForKey:PREF_CAR_NAME]  isEqual: @""]) {
        _rideLaterCarCat.text=[pref objectForKey:PREF_CATEGORY_NAME];
    }else {
        _rideLaterCarCat.text=[pref objectForKey:PREF_CAR_NAME];
    }
   
    [pref setObject:@"" forKey:PREF_PROMO];
    
    
    if ([[pref objectForKey:PREF_CATEGORY_BASE_FARE] isEqualToString:@"0.00"]) {
        if ([[pref objectForKey:PREF_CATEGORY_MIN_FARE] isEqualToString:@"0.00"]) {
             _rideLaterFare.text=@"";
        }else {
             _rideLaterFare.text=[NSString stringWithFormat:@"Minimum Fare %@ %@",[pref valueForKey:PREF_SETTING_CURRENCY_TEXT], [pref objectForKey:PREF_CATEGORY_MIN_FARE]];
        }
        
    }else {
         _rideLaterFare.text=[NSString stringWithFormat:@"Base Fare %@ %@",[pref valueForKey:PREF_SETTING_CURRENCY_TEXT], [pref objectForKey:PREF_CATEGORY_BASE_FARE]];
    }

    
    // Payment Mode Selection
    NSObject * RideLaterobject = [pref objectForKey:PREF_PAYMENT_OPT];
    NSString *stringID=@"0";
    if([RideLaterobject isEqual: stringID] && [[pref valueForKey:PREF_SETTING_CARD_PAYMENT] boolValue]){
        _rideLaterPaymentCardName.text = [pref objectForKey:PREF_PAYMENT_CARD_NAME];
        [ _rideLaterPaymentCardIcon downloadFromURL:[pref objectForKey:PREF_PAYMENT_CARD_ICON] withPlaceholder:nil];
        [self paymentToggle];
    }else {
        [pref setValue:@"Cash" forKey:PREF_PAYMENT_CARD_NAME];
        [pref setValue:@"Cash_Money" forKey:PREF_PAYMENT_CARD_ICON];
        [pref synchronize];
        _rideLaterPaymentCardName.text = [pref objectForKey:PREF_PAYMENT_CARD_NAME];
        _rideLaterPaymentCardIcon.image=[UIImage imageNamed:[pref objectForKey:PREF_PAYMENT_CARD_ICON]];
        [self paymentToggle];
    }
    onceTokenForBack=0;
}

-(void)pickerCancel{
    [datePicker setDate:recentlySelectedDate];
    [viewForPicker removeFromSuperview];
}

#pragma mark - Date Picker and Formator

-(NSString *)getUTCFormateDate:(NSDate *)localDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"dd-MMM-YYYY hh:mm a"];
    NSString *dateString = [dateFormatter stringFromDate:localDate];
    return dateString;
}

-(NSString *)getUTCFormateDateToServer:(NSDate *)localDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    NSString *dateString = [dateFormatter stringFromDate:localDate];
    return dateString;
}
-(BOOL)dateComparision:(NSDate*)date1 andDate2:(NSDate*)date2{
    
    BOOL isTokonValid;
    
    if ([date1 compare:date2] == NSOrderedDescending) {
        //"date1 is later than date2
        isTokonValid = YES;
    } else if ([date1 compare:date2] == NSOrderedAscending) {
        //date1 is earlier than date2
        isTokonValid = NO;
    } else {
        //dates are the same
        isTokonValid = NO;
        
    }
    
    return isTokonValid;
}


#pragma mark - TextView Delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(textField==_promoCodeTxt){
        _promocodeKeyBoardAvoidingScrollView.scrollEnabled=NO;
        //[_promoCodeTxt resignFirstResponder];
    }
//    else if([CLLocationManager locationServicesEnabled]&&
//             [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied){
//        [textField resignFirstResponder];
//        [self performSegueWithIdentifier:STRING_SEGUE_SEARCH_PAGE sender:self];
//    }else{
//        UIAlertView *LocationStatus=[[UIAlertView alloc] initWithTitle:@"This app does not have access to Location services" message:@"Please allow Orbit to use location services .Turn it on from settings" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Settings", nil];
//        [LocationStatus show];
//    }
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    // Not found, so remove keyboard.
    [textField resignFirstResponder];
    _promocodeKeyBoardAvoidingScrollView.scrollEnabled=YES;
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if(textField==_promoCodeTxt){
        if ([string isEqualToString:@" "]) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - Segue Actions
-(void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender {
    if([segue.identifier isEqualToString:STRING_SEGUE_TO_FAVORITES]){
        FavouriteListVC *favController = (FavouriteListVC *)segue.destinationViewController;
        favController.addFavLat=strForCurFavLatitude;
        favController.addFavLong=strForCurFavLongitude;
        ALog(@"lat long sending to favourutes are =%@, %@ ", strForCurFavLatitude, strForCurFavLongitude);
        favController.isDisplayAddFav=YES;
        if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"selectedTextField"]  isEqual: @"fav_origin"]) {
            favController.searchingTextField=@"fav_origin";
            favController.addFavText= _originTextFiled.text;
        }else if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"selectedTextField"]  isEqual: @"fav_dest"]){
            favController.searchingTextField=@"fav_dest";
            favController.addFavText= _destinationTextFiled.text;
            favController.addFavLat=strForDestinationLatitude;
            favController.addFavLong=strForDestinationLongitude;
        }
        favController.favouritesDelegate=self;
    }else if([segue.identifier isEqualToString:STRING_SEGUE_BOOKING_TO_FARE]){
        FareEstimateViewController *fareController = (FareEstimateViewController *)segue.destinationViewController;
        fareController.OriginLatitude=strForLatitude;
        fareController.OriginLongitude=strForLongitude;
        fareController.OriginText=_originTextFiled.text;
        fareController.screenStatus=strForCurrentPage;
        fareController.fareEstDelegate=self;
        ALog(@"cur_lat= %@ and cur_longitude =%@ and latlong to fare est are = %@, %@",strForCurLatitude, strForCurLongitude, strForLatitude,strForLongitude);
        fareController.strForCurrentLatitude=strForCurLatitude;
        fareController.strForCurrentLongitude=strForCurLongitude;
        
        if ([_navOriginFavBtn.imageView.image isEqual:[UIImage imageNamed:@"Fav_fill"]] && ![_originTextFiled.text isEqualToString:@""])
        {
                fareController.favButtonOriginImage=[UIImage imageNamed:@"Fav_fill"];
            [pref setObject:[pref valueForKey:PREF_FAV_ORIG_ADDRESS_ID] forKey:PREF_FAREEST_ORIG_ADDRESS_ID];
            ALog(@"origin filled");
        } else {
             fareController.favButtonOriginImage=[UIImage imageNamed:@"Fav_btn"];
            _navOriginFavBtn.imageView.image = [UIImage imageNamed:@"Fav_btn"];
            ALog(@"origin empty");
        }
        if ([_destinationFavBtn.imageView.image isEqual:[UIImage imageNamed:@"Fav_fill"]] && ![_destinationTextFiled.text isEqualToString:@""] )
        {
            fareController.favButtonDestinationImage=[UIImage imageNamed:@"Fav_fill"];
            fareController.DestinationText=_destinationTextFiled.text;
            [pref setObject:[pref valueForKey:PREF_FAV_DEST_ADDRESS_ID] forKey:PREF_FAREEST_DEST_ADDRESS_ID];
             ALog(@"destination filled");
        } else {
            fareController.favButtonDestinationImage=[UIImage imageNamed:@"Fav_btn"];
            _destinationFavBtn.imageView.image = [UIImage imageNamed:@"Fav_btn"];
            ALog(@"destination empty");
        }
        if (![_destinationTextFiled.text isEqualToString:@""] )  {
            fareController.DestinationLatitude=strForDestinationLatitude;
            fareController.DestinationLongitude=strForDestinationLongitude;
            fareController.DestinationText=_destinationTextFiled.text;
        }
    }else if([segue.identifier isEqualToString:STRING_SEGUE_RIDE_COMPLETE]){
        RideCompleteVC *rideController = (RideCompleteVC *)segue.destinationViewController;
        rideController.strRideCompleteTripID=rideCompleteTripID;
        rideController.strRideCompleteTime=rideCompleteTime;
        rideController.strRideCompleteDate=rideCompleteDate;
        rideController.strRideCompleteCarCatorgery=rideCompleteCarCatorgery;
        rideController.strRideCompletePayment=rideCompletePayment;
        rideController.strRideCompletePrice=rideCompletePrice;
        rideController.strRideCompleteMessage=rideCompleteMessage;
        rideController.strRideCompleteDriverName=rideCompleteDriverName;
        rideController.strRideCompleteDriverCarCategory=rideCompleteDriverCarCategory;
        rideController.strRideCompleteDriveIcon=rideCompleteDriveIcon;
        rideController.strRideCompleteDriverCarNumber=rideCompleteDriverCarNumber;
        rideController.lastWalkId=lastWalkerId;
        rideController.strRideCompleteRequestId=[NSString stringWithFormat:@"%@", rideCompleteRequestId];
        rideController.isFromBookingPage=YES;
    }else if ([segue.identifier isEqualToString:STRING_SEGUE_CARD_LIST]){
        CardListViewController* cntl = (CardListViewController*)segue.destinationViewController;
        cntl.shouldShowCash=YES;
        cntl.cardListDelegate=self;
        cntl.isfromBookingPage=YES;
    }else if ([segue.identifier isEqualToString:STRING_SEGUE_SEARCH_PAGE]){
        SearchViewController* cntl = (SearchViewController*)segue.destinationViewController;
        cntl.originOrDestination=LandingPageSearchingTextField;
    }
        
}

//#pragma mark - Mapview Delegate
//
//-(void)mapView:(GMSMapView *)mapView didUpdateUserLocation:(GMSMapView *)userLocation {
//
//    MKMapCamera *camera = [MKMapCamera cameraLookingAtCenterCoordinate:userLocation fromEyeCoordinate:CLLocationCoordinate2DMake(userLocation.latitude, userLocation.longitude) eyeAltitude:10000];
//    [_mapView setCamera:camera animated:YES];
//
//    MKCoordinateRegion mapRegion;
//    mapRegion.center = _mapView.userLocation.coordinate;
//    mapRegion.span.latitudeDelta = 0.009;
//    mapRegion.span.longitudeDelta = 0.009;
//    [_mapView setRegion:mapRegion animated: YES];
//}

#pragma mark- Google Map Delegate

-(void)mapView:(GMSMapView *)mapView didTapOverlay:(GMSOverlay *)overlay {
     ALog(@"map view tapped overlay-------- ***** ------- ");
}

-(void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture{
//    [self moveTopAndBottomViewsOut];
//    ALog(@"map view will move now -------- ***** ------- ");
    [self disableRideNowAndRideLaterButton];
    move=YES;
}
- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position
{
    zoom= mapView.camera.zoom;
    strForLatitude=[NSString stringWithFormat:@"%f",position.target.latitude];
    strForLongitude=[NSString stringWithFormat:@"%f",position.target.longitude];
    if([strForCurrentPage isEqualToString:@"booking"]){
        _bookRideNowBtn.enabled=NO;
        [_bookRideNowBtn setTitleColor:rideNowAndLaterDisabledColor forState:UIControlStateNormal];
        [self disableBothRideNowAndRideLater];
        
    }
}

- (void) mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position
{
//    ALog(@"mapview idle at camera position  %f, %f", position.target.latitude, position.target.longitude);
    
    if([CLLocationManager locationServicesEnabled]&&
       [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied)
    {
        if([pref boolForKey:PREF_IS_FAV]){
            [_navOriginFavBtn setImage:[UIImage imageNamed:@"Fav_fill"] forState:UIControlStateNormal];
        }else{
            [_navOriginFavBtn setImage:[UIImage imageNamed:@"Fav_btn"] forState:UIControlStateNormal];
        }
        
//        [self setFavouriteButtonColor];
        //ALog(@"hello");
        
        if([strForCurrentPage isEqualToString:@"booking"]){
            _bookRideNowBtn.enabled=NO;
            [_bookRideNowBtn setTitleColor:rideNowAndLaterDisabledColor forState:UIControlStateNormal];
            strForCurFavLatitude = [NSString stringWithFormat:@"%f", position.target.latitude];
            strForCurFavLongitude= [NSString stringWithFormat:@"%f", position.target.longitude];
            if([APPDELEGATE connected])
            {
                noInternetView.hidden=YES;
                [self getAddressFromLatLongUsingGeocode];
                [self getAllApplicationTypeWithLattitude:strForCurFavLatitude longitude:strForCurFavLongitude completion:^{
                    if(![[pref objectForKey:PREF_CATEGORY_TYPE_ID] isEqualToString:@"0"]){
                        [self checkCarsAvailabilityWithidString:[pref objectForKey:PREF_CATEGORY_TYPE_ID]];
                        ALog(@"The category id in mapview idle at camera  = %@", [pref objectForKey:PREF_CATEGORY_TYPE_ID]);
                    }
                }];
                
                
                if ([_originTextFiled.text isEqualToString:@"Please select proper location"]) {
                    [self disableBothRideNowAndRideLater];
                }

                
            } else {
                [APPDELEGATE stopLoader:self.view];
                noInternetView.hidden=NO;
                [customAlertView setContainerView:[APPDELEGATE createDemoView:NO_INTERNET view:self.view]];
                [customAlertView show];
            }
            //            if (move) {
//                [self moveTopAndBottomViewsIn];
//                move=NO;
//            }
            
        }
    }
    else if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied ){
        _bookRideNowBtn.enabled=NO;
        _bookRideLaterBtn.enabled=NO;
    }
}

//- (void) mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate{
//    CLLocationCoordinate2D coor;
//    coor.latitude=[strForCurLatitude doubleValue];
//    coor.longitude=[strForCurLongitude doubleValue];
//    CGPoint point = [mapView_.projection pointForCoordinate:coor];
//    GMSCameraUpdate *camera =
//    [GMSCameraUpdate setTarget:[mapView_.projection coordinateForPoint:point] zoom:18];
//    [mapView_ animateWithCameraUpdate:camera];
//}

//- (void)mapView:(GMSMapView *)mapView didTapOverlay:(GMSOverlay *)overlay{
//    CLLocationCoordinate2D coor;
//    coor.latitude=[strForCurLatitude doubleValue];
//    coor.longitude=[strForCurLongitude doubleValue];
//    CGPoint point = [mapView_.projection pointForCoordinate:coor];
//    GMSCameraUpdate *camera =
//    [GMSCameraUpdate setTarget:[mapView_.projection coordinateForPoint:point] zoom:18];
//    [mapView_ animateWithCameraUpdate:camera];
//}

-(void)moveTopAndBottomViewsOut{
    [UIView animateWithDuration:0.5 delay:0.1 options:UIViewAnimationOptionCurveLinear animations:^{
        CGPoint newnavCenter=CGPointMake(_navigationView.center.x, _navigationView.center.y - _navigationView.frame.size.height);
        _navigationView.center=newnavCenter;
        _noCarsAvailableHolderView.hidden=YES;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            CGPoint newPageViewCenter = CGPointMake(myView1.center.x, myView1.center.y + myView1.frame.size.height + 100);
            myView1.center = newPageViewCenter;
        } completion:nil];
    }];
}

-(void)moveTopAndBottomViewsIn{
    [UIView animateWithDuration:0.4 delay:0.1 options:UIViewAnimationOptionCurveLinear animations:^{
        CGPoint newnavCenter=CGPointMake(_navigationView.center.x, _navigationView.center.y + _navigationView.frame.size.height);
        _navigationView.center=newnavCenter;
            [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
                CGPoint newPageViewCenter = CGPointMake(myView1.center.x, myView1.center.y - myView1.frame.size.height - 100);
                myView1.center = newPageViewCenter;
            } completion:nil];
    } completion:nil];
}

-(void)getAddressFromLatLongUsingGeocode
{
    if([APPDELEGATE connected]) {
        /*    http://maps.google.com/maps/api/geocode/json?latlng=    &sensor=false   */
        
        NSString *url = [NSString stringWithFormat:@"https://maps.google.com/maps/api/geocode/json?latlng=%@,%@&sensor=false&key=%@",strForLatitude, strForLongitude, GOOGLE_KEY];
        ALog(@"Geocode addres from latlong = %@", url);
        NSURL *URL = [NSURL URLWithString:url];
        NSData *data = [NSData dataWithContentsOfURL:URL];
        if (data) {
            NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData: data
                                                                 options: NSJSONReadingMutableContainers
                                                                   error: nil];
            
            NSArray *results = [JSON valueForKey:@"results"];
            
            if (results.count!=0)
            {
                NSDictionary *address = [results firstObject];
                if([strForCurrentPage isEqualToString:@"booking"]){
                    if([address valueForKey:@"formatted_address"]){
                        if (changeOriginText) {
                            _originTextFiled.text=[address valueForKey:@"formatted_address"];
                        }
                        changeOriginText=YES;
                        strForAddFavText=_originTextFiled.text;
                        strForLatitude= [NSString stringWithFormat:@"%@",[[[address valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lat"]];
                        strForLongitude= [NSString stringWithFormat:@"%@",[[[address valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lng"]];
                    } else {
                        _originTextFiled.text=@"Please select proper location";
                    }
                }else if([strForCurrentPage isEqualToString:@"ridenow"] || [strForCurrentPage isEqualToString:@"ridelater"]){
                    if([address valueForKey:@"formatted_address"]){
                        _destinationTextFiled.text = [address valueForKey:@"formatted_address"];
                        strForAddFavText=_destinationTextFiled.text;
                        strForDestinationLatitude=[NSString stringWithFormat:@"%@",[[[address valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lat"]];
                        strForDestinationLongitude=[NSString stringWithFormat:@"%@",[[[address valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lng"]];
                    }else {
                        _originTextFiled.text=@"Please select proper location";
                    }
                }else if([strForCurrentPage isEqualToString:@"startride"]){
                   if([address valueForKey:@"formatted_address"]){
                        _destinationTextFiled.text=[address valueForKey:@"formatted_address"];
                        strForDestinationLatitude=[NSString stringWithFormat:@"%@",[[[address valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lat"]];
                        strForDestinationLongitude=[NSString stringWithFormat:@"%@",[[[address valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lng"]];
                        [self startRideDestinationChangeWithLat:strForDestinationLatitude andLong:strForDestinationLongitude andAddress:[address valueForKey:@"formatted_address"]];
                    }else {
                        _originTextFiled.text=@"Please select proper location";
                    }
                }
            }else{
                if([strForCurrentPage isEqualToString:@"booking"]){
                    _originTextFiled.text=@"Please select proper location";
                }
            }
            //            [self setFavouriteButtonColor];
        } else {
            [APPDELEGATE stopLoader:self.view];
            [customAlertView setContainerView:[APPDELEGATE createDemoView:NO_INTERNET view:self.view]];
            [customAlertView show];
            return ;
        }
        //        NSString *str = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:nil];
        //
        //        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData: [str dataUsingEncoding:NSUTF8StringEncoding]
        //                                                             options: NSJSONReadingMutableContainers
        //                                                               error: nil];
    }else{
        [APPDELEGATE stopLoader:self.view];
        [customAlertView setContainerView:[APPDELEGATE createDemoView:NO_INTERNET view:self.view]];
        [customAlertView show];
    }
}

-(void)getAddressFromLatLongUsingGeocodeForDestinationWithLattitude: (NSString *)lattitude andLongitude: (NSString*)longitude andAddress: (NSString*)addressString{
    if([APPDELEGATE connected]) {
        NSString *url = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?latlng=%@,%@&sensor=false",lattitude, longitude];
        ALog(@"Geocode addres from latlong = %@", url);
        NSURL *URL = [NSURL URLWithString:url];
        NSData *data = [NSData dataWithContentsOfURL:URL];
        if (data) {
            NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData: data
                                                                 options: NSJSONReadingMutableContainers
                                                                   error: nil];
            
            NSArray *results = [JSON valueForKey:@"results"];
            
            if (results.count!=0)
            {
                NSDictionary *address = [results firstObject];
                if([strForCurrentPage isEqualToString:@"booking"]){
                    if([address valueForKey:@"formatted_address"]){
                        if (addressString && addressString.length > 3) {
                            _originTextFiled.text=addressString;
                        }else {
                            _originTextFiled.text=[address valueForKey:@"formatted_address"];
                        }
                        
                        strForAddFavText=_originTextFiled.text;
                        strForLatitude= [NSString stringWithFormat:@"%@",[[[address valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lat"]];
                        strForLongitude= [NSString stringWithFormat:@"%@",[[[address valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lng"]];
                    }else {
                        _originTextFiled.text=@"Please select proper location";
                    }
                }else if([strForCurrentPage isEqualToString:@"ridenow"] || [strForCurrentPage isEqualToString:@"ridelater"]){
                    if([address valueForKey:@"formatted_address"]){
                        if (addressString && addressString.length > 3) {
                            _destinationTextFiled.text=addressString;
                        }else {
                           _destinationTextFiled.text = [address valueForKey:@"formatted_address"];
                        }
                        
                        strForAddFavText=_destinationTextFiled.text;
                        strForDestinationLatitude=[NSString stringWithFormat:@"%@",[[[address valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lat"]];
                        strForDestinationLongitude=[NSString stringWithFormat:@"%@",[[[address valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lng"]];
                        
                        [self callTypesTwoApiToCheckDestinationServicesWithLattitude:strForDestinationLatitude AndLongitude:strForDestinationLongitude onCompletion:^(NSDictionary *dict) {
                            ALog(@"dictionary in types two = %@", dict);
                            if (![[dict valueForKey:@"status"] boolValue])
                            {
                                
                                strForDestinationLatitude=@"";
                                strForDestinationLongitude=@"";
                                [customAlertView setContainerView:[APPDELEGATE createDemoView:[dict valueForKey:@"message"] view:self.view]];
                                customAlertView.tag = 1234;
                                [customAlertView show];
                            }
                        }];
                    }else {
                        _originTextFiled.text=@"Please select proper location";
                    }
                }else if([strForCurrentPage isEqualToString:@"startride"]){
                    if([address valueForKey:@"formatted_address"]){
                        if (addressString && addressString.length > 3) {
                            _destinationTextFiled.text=addressString;
                        }else {
                            _destinationTextFiled.text = [address valueForKey:@"formatted_address"];
                        }
                        strForDestinationLatitude=[NSString stringWithFormat:@"%@",[[[address valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lat"]];
                        strForDestinationLongitude=[NSString stringWithFormat:@"%@",[[[address valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lng"]];
                        [self callTypesTwoApiToCheckDestinationServicesWithLattitude:strForDestinationLatitude AndLongitude:strForDestinationLongitude onCompletion:^(NSDictionary *dict) {
                            if (![[dict valueForKey:@"status"] boolValue]) {
                                
                                
                                if (isLater && [[pref valueForKey:PREF_SETTING_RIDE_LATER_DESTINATION] boolValue]) {
                                    ALog(@"Ride later is mandatory but given empty address ======================");
                                    [customAlertView setContainerView:[APPDELEGATE createDemoView:[dict valueForKey:@"message"] view:self.view]];
                                    customAlertView.tag = 1234;
                                    [customAlertView show];
                                    return;
                                }else if (!isLater && [[pref valueForKey:PREF_SETTING_RIDE_NOW_DESTINATION] boolValue]){
                                    ALog(@"Ride now is mandatory but given empty address==========================");
                                    [customAlertView setContainerView:[APPDELEGATE createDemoView:[dict valueForKey:@"message"] view:self.view]];
                                    customAlertView.tag = 1234;
                                    [customAlertView show];
                                    return;
                                }else{
                                    markerOwnerDest=nil;
                                    markerOwnerDest.map=nil;
                                    _destinationTextFiled.text=@"";
                                    strForDestinationLatitude=@"";
                                    strForDestinationLongitude=@"";
                                    [self startRideDestinationChangeWithLat:@"" andLong:@"" andAddress:@""];
                                    [customAlertView setContainerView:[APPDELEGATE createDemoView:[dict valueForKey:@"message"] view:self.view]];
                                    customAlertView.tag = 1234;
                                    [customAlertView show];
                                }
                            } else {
                                ALog(@"destination lattitide, long before calling = %@, %@", strForDestinationLatitude, strForDestinationLongitude);
                                if (addressString && addressString.length > 3) {
                                    _destinationTextFiled.text=addressString;
                                    [self startRideDestinationChangeWithLat:strForDestinationLatitude andLong:strForDestinationLongitude andAddress:addressString];
                                }else {
                                    _destinationTextFiled.text = [address valueForKey:@"formatted_address"];
                                    [self startRideDestinationChangeWithLat:strForDestinationLatitude andLong:strForDestinationLongitude andAddress:[address valueForKey:@"formatted_address"]];
                                }
                                
                            }
                            
                        }];
                    }else {
                        _originTextFiled.text=@"Please select proper location";
                    }
                }
            }else{
                if([strForCurrentPage isEqualToString:@"booking"]){
                    _originTextFiled.text=@"Please select proper location";
                }
            }
            //            [self setFavouriteButtonColor];
        } else {
            [APPDELEGATE stopLoader:self.view];
            [customAlertView setContainerView:[APPDELEGATE createDemoView:NO_INTERNET view:self.view]];
            [customAlertView show];
            return ;
        }
        //        NSString *str = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:nil];
        //
        //        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData: [str dataUsingEncoding:NSUTF8StringEncoding]
        //                                                             options: NSJSONReadingMutableContainers
        //                                                               error: nil];
    }else{
        [APPDELEGATE stopLoader:self.view];
        [customAlertView setContainerView:[APPDELEGATE createDemoView:NO_INTERNET view:self.view]];
        [customAlertView show];
    }
}

- (void) didPan:(UIPanGestureRecognizer*) gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        mapView_.settings.scrollGestures = true;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (gestureRecognizer.numberOfTouches > 1)
    {
        mapView_.settings.scrollGestures = false;
    }
    else
    {
        mapView_.settings.scrollGestures = true;
    }
    return true;
}


#pragma mark - Location Delegate

-(CLLocationCoordinate2D) getLocation
{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    //[locationManager startUpdatingLocation];
    CLLocation *location = [locationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    ALog(@"coordinates in get location are %f, %f", coordinate.latitude, coordinate.longitude);
    return coordinate;
}

-(void)updateLocationManagerr
{
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter=kCLDistanceFilterNone;
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
        NSUInteger code = [CLLocationManager authorizationStatus];
        if (code == kCLAuthorizationStatusNotDetermined && ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)] || [locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])) {
            // choose one request according to your business.
            if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"]){
                [locationManager requestAlwaysAuthorization];
            } else if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]) {
                [locationManager  requestWhenInUseAuthorization];
            } else {
                ALog(@"Info.plist does not contain NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription");
            }
        }
    }
    [locationManager startUpdatingLocation];
//    if([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]){
//        [locationManager requestWhenInUseAuthorization];
//    }else{
//        [locationManager startUpdatingLocation];
//    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    ALog(@"location manager didUpdateLocations  is called %@",[locations lastObject] );
    // CLLoclocation manager ation *currentLocation = [locations objectAtIndex:0];
    
    if (isFirstTime) {
        isFirstTime = NO;
        [pref setBool:NO forKey:@"locationStatus"];
        CLLocation *location = [locations lastObject];
        CLLocationCoordinate2D coordinate = [location coordinate];
        ALog(@"test location = %f, %f ",[location coordinate].latitude, [location coordinate].longitude);
        strForCurLatitude = [NSString stringWithFormat:@"%f", coordinate.latitude];
        strForCurLongitude= [NSString stringWithFormat:@"%f", coordinate.longitude];
        
//        [self getAllApplicationType:strForCurLatitude longitude:strForCurLongitude completion:^{
//            ALog(@"COMPLETED ALL APPLICATIONS IN LOCATION MANAGER DID UPDATE LOCATIONS ");
//        }];
//        [self getAddress];
//        [self getAddressFromGeoCoder];
//        [self getAddressFromLatLongUsingGeocode];
        
        if([[pref valueForKey:PREF_SETTING_MENU_BOOK_RIDE] boolValue]) {
            if (isRideLaterEnabled) {
                _bookRideLaterBtn.enabled=YES;
                [_bookRideLaterBtn setTitleColor:rideNowAndLaterActiveColor forState:UIControlStateNormal];
            }
            
            if([[pref valueForKey:PREF_SETTING_RIDE_NOW] boolValue]){
                _bookRideNowBtn.enabled=YES;
                [_bookRideNowBtn setTitleColor:rideNowAndLaterActiveColor forState:UIControlStateNormal];
                if ([_originTextFiled.text isEqualToString:@"Please select proper location"]) {
                    [self disableBothRideNowAndRideLater];
                }
            } else {
                _bookRideNowBtn.enabled=NO;
                [_bookRideNowBtn setTitleColor:rideNowAndLaterDisabledColor forState:UIControlStateNormal];
            }
        }else{
            [myView1 removeFromSuperview];
            [locationButton removeFromSuperview];
            [expandView removeFromSuperview];
            
            if (_pulseView.hidden) {
                _noCarsAvailableHolderView.hidden=NO;
            }
            _noCarsAvailableLabel.text=@"Bookings are currently not available. Please try later";
            _pageControl.hidden=YES;
            _bookLocationBtn.hidden=NO;
            _bookRideLaterBtn.enabled=NO;
            _bookRideNowBtn.enabled=NO;
            _navOriginFavBtn.enabled=NO;
            
            [_bookRideNowBtn setTitleColor:rideNowAndLaterDisabledColor forState:UIControlStateNormal];
            [_bookRideLaterBtn setTitleColor:rideNowAndLaterDisabledColor forState:UIControlStateNormal];
        }
        //        _bookRideLaterBtn.enabled=YES;
        //        _bookRideNowBtn.enabled=YES;
        //        [_bookRideNowBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        //        [_bookRideLaterBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[strForCurLatitude doubleValue] longitude:[strForCurLongitude doubleValue] zoom:16.0];
        //mapView_ = [GMSMapView mapWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) camera:camera];
        mapView_ = [GMSMapView mapWithFrame:self.viewGoogleMap.bounds camera:camera];
        mapView_.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        mapView_.myLocationEnabled =  YES;
        mapView_.settings.myLocationButton =  NO;
        mapView_.settings.scrollGestures=NO;
        [mapView_.settings setRotateGestures:NO];
        [mapView_.settings setTiltGestures:NO];
        [mapView_ setMinZoom:5 maxZoom:19];
        mapView_.delegate=self;
        mapView_.settings.allowScrollGesturesDuringRotateOrZoom = NO;
        [self.viewGoogleMap addSubview:mapView_];
        
        [locationManager stopUpdatingLocation];
    } else {
        [locationManager stopUpdatingLocation];
    }
    
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    ALog(@"didFailWithError: %@", error);
    
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusDenied) {
        [myView1 removeFromSuperview];
        [locationButton removeFromSuperview];
        [expandView removeFromSuperview];
        reloadAllCategories=YES;
        _pageControl.hidden=YES;
        _pageControl.hidden=YES;
        if (_pulseView.hidden) {
            _noCarsAvailableHolderView.hidden=NO;
        }
        _noCarsAvailableLabel.text=@"Please enable location access";
        _bookLocationBtn.hidden=NO;
        
        _bookRideLaterBtn.enabled=NO;
        _bookRideNowBtn.enabled=NO;
        [_bookRideNowBtn setTitleColor:rideNowAndLaterDisabledColor forState:UIControlStateNormal];
        [_bookRideLaterBtn setTitleColor:rideNowAndLaterDisabledColor forState:UIControlStateNormal];
        
        [pref setObject:@"0" forKey:PREF_CATEGORY_TYPE_ID];
        [pref synchronize];
        
        [pref setBool:YES forKey:@"locationStatus"];
        UIAlertView* LocationStatus=[[UIAlertView alloc] initWithTitle:@"This app does not have access to Location services" message:@"Please allow Orbit to use location services .Turn it on from settings" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Settings", nil];
        [LocationStatus show];
        
        //    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }else{
        
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        //code for opening settings app in iOS 8
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

-(void)getMyLocationIsPressed {
    if ([CLLocationManager locationServicesEnabled])
    {
        CLLocationCoordinate2D coor;
        coor.latitude=[strForCurLatitude doubleValue];
        coor.longitude=[strForCurLongitude doubleValue];
        GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:coor zoom:zoom];
        [mapView_ animateWithCameraUpdate:updatedCamera];
        strForLatitude=strForCurLatitude;
        strForLongitude=strForCurLongitude;
//        [self getAddress];
//        [self getAddressFromGeoCoder];
        [self getAddressFromLatLongUsingGeocode];
    }
    else
    {
        UIAlertView* LocationStatus=[[UIAlertView alloc] initWithTitle:@"This app does not have access to Location services" message:@"Please allow Orbit to use location services .Turn it on from settings" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Settings", nil];
        [LocationStatus show];
    }
}

- (void) getLocationFromAddressString:(NSString *)address
{
    if (!(address.length > 3)) {
        _destinationTextFiled.text = @"";
      [self startRideDestinationChangeWithLat:@"" andLong:@"" andAddress:@""];
        ALog(@"address = %@",address);
    } else {
        double latitude = 0, longitude = 0;
//        NSString *esc_addr =  [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                        NULL,
                                                                                                        (CFStringRef)address,
                                                                                                        NULL,
                                                                                                        (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                        kCFStringEncodingUTF8 ));
        
        //    NSString *req = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?sensor=false&address=%@", esc_addr];
        NSString *req = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/textsearch/json?query=%@&key=%@", encodedString, GOOGLE_KEY];
    https://maps.googleapis.com/maps/api/place/textsearch/json?query=techactive&key=AIzaSyAqyxlGbbU3mt4-6O7Loc9DL5pWTKk0T-c
        ALog(@"url = %@", req);
        
        NSURL *URL = [NSURL URLWithString:req];
        NSData *data = [NSData dataWithContentsOfURL:URL];
        if (data) {
            NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData: data
                                                                 options: NSJSONReadingMutableContainers
                                                                   error: nil];
            ALog(@"Json result = %@", JSON);
            NSArray *results = [JSON valueForKey:@"results"];
            if ([results count] >0) {
                NSDictionary *addressDict = [results firstObject];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if([strForCurrentPage isEqualToString:@"booking"]){
                        _originTextFiled.text=address;
                        
                        CLLocationCoordinate2D coor ;
                        coor.latitude=[[[[addressDict valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lat"] doubleValue];
                        coor.longitude=[[[[addressDict valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lng"] doubleValue];
                        
                        GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:coor zoom:16.0f];
                        changeOriginText=NO;
                        [mapView_ animateWithCameraUpdate:updatedCamera];
                        // [self getProviders];
                    }else if ([strForCurrentPage isEqualToString:@"ridenow"]  || [strForCurrentPage isEqualToString:@"ridelater"]){
                        // _destinationTextFiled.text=[[arrAddress objectAtIndex:0] valueForKey:@"formatted_address"];
                        _destinationTextFiled.text = address;
                        strForDestinationLatitude= [NSString stringWithFormat:@"%@",[[[addressDict valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lat"]];
                        strForDestinationLongitude=[NSString stringWithFormat:@"%@",[[[addressDict valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lng"]];
                        [self getAddressFromLatLongUsingGeocodeForDestinationWithLattitude:strForDestinationLatitude andLongitude:strForDestinationLongitude andAddress:address];
                    }else if ([strForCurrentPage isEqualToString:@"startride"]){
                        //                     _destinationTextFiled.text=[[arrAddress objectAtIndex:0] valueForKey:@"formatted_address"];
                        _destinationTextFiled.text=address;
                        
                        strForDestinationLatitude=[NSString stringWithFormat:@"%@",[[[addressDict valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lat"]];
                        strForDestinationLongitude=[NSString stringWithFormat:@"%@",[[[addressDict valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lng"]];
                        [self getAddressFromLatLongUsingGeocodeForDestinationWithLattitude:strForDestinationLatitude andLongitude:strForDestinationLongitude andAddress:address];
                        
                    }
                });
                
            } else {
                if ([JSON valueForKey:@"error_message"]){
                    [customAlertView setContainerView:[APPDELEGATE createDemoView:[JSON valueForKey:@"error_message"] view:self.view]];
                    [customAlertView show];
                }
            }
        }
        ALog(@"new lattitude = %f, longitude =- %f and address = %@", latitude, longitude, address);
    }
    
}

#pragma mark - RateCard View

-(void) fillRateCardView:(NSString*)index{
    _rateCardFirstCurrency.text=[NSString stringWithFormat:@"First %@ %@\n ",[[rateCardForIdDist objectForKey:index]objectAtIndex:1], [self isInteger:[pref valueForKey:PREF_SETTING_UNIT_SET]]];
    _rateCardSecondCurrency.text=[NSString stringWithFormat:@"After %@ %@\n ",[[rateCardForIdDist objectForKey:index]objectAtIndex:1], [self isInteger:[pref valueForKey:PREF_SETTING_UNIT_SET]]];
    _rateCardThirdCurrency.text=[NSString stringWithFormat:@"Ride Time Rate \nAfter %@ mins", [self isInteger:[[rateCardForIdTime objectForKey:index]objectAtIndex:1]]];
    
    ALog(@"currency symbol = %@", [pref objectForKey:PREF_SETTING_CURRENCY_TEXT]);
    
    _rateCardFirstPrice.text=[NSString stringWithFormat:@"%@ %@",[pref objectForKey:PREF_SETTING_CURRENCY_TEXT], [self isInteger:[[rateCardForIdDist objectForKey:index]objectAtIndex:0]]];
    _rateCardSecondPrice.text=[NSString stringWithFormat:@"%@ %@/%@",[pref objectForKey:PREF_SETTING_CURRENCY_TEXT], [self isInteger:[[rateCardForIdDist objectForKey:index]objectAtIndex:2]], [pref valueForKey:PREF_SETTING_UNIT_SET]];
    _rateCardThirdPrice.text=[NSString stringWithFormat:@"%@ %@/min",[pref objectForKey:PREF_SETTING_CURRENCY_TEXT], [self isInteger:[[rateCardForIdTime objectForKey:index]objectAtIndex:0]]];
    
//    _rateCardSecondKMS.text=[NSString stringWithFormat:@"per %@", ];
//    _rateCardThirdKMS.text=@"per minute";

    if ([[pref objectForKey:PREF_CATEGORY_BASE_FARE] isEqualToString:@"0.00"]) {
//        _baseFareViewHeightConstraint.constant=0;
        _baseFareViewHeightConstraint.constant=29;
        _baseFareLabel.text=@"NO BASE FARE";
    } else {
        _baseFareViewHeightConstraint.constant=29;
        _baseFareLabel.text=[NSString stringWithFormat:@"Base Fare = %@ %@", [pref objectForKey:PREF_SETTING_CURRENCY_TEXT], [pref objectForKey:PREF_CATEGORY_BASE_FARE]];
        
    }
    if ([[pref objectForKey:PREF_CATEGORY_MIN_FARE] isEqualToString:@"0.00"]) {
         _minimumFareViewHeightConstraint.constant=0;
    }else{
         _minimumFareViewHeightConstraint.constant=29;
        _minimumFareLabel.text=[NSString stringWithFormat:@"Minimum Fare = %@ %@", [pref objectForKey:PREF_SETTING_CURRENCY_TEXT], [pref objectForKey:PREF_CATEGORY_MIN_FARE]];
    }
    
    _surChargeLabel.text=@"NO SURCHARGES";
}

-(NSString*) isInteger:(NSString*)currentvalue {
    ALog(@"the value is %f", [currentvalue doubleValue]);
    if ([currentvalue doubleValue] - [currentvalue intValue]) {
        return currentvalue;
    }else{
        return [NSString stringWithFormat:@"%d",[currentvalue intValue] ];
    }
    
}


#pragma mark - share actions

- (void)shareText:(NSString *)text andImage:(UIImage *)image andUrl:(NSURL *)url
{
    NSMutableArray *sharingItems = [NSMutableArray new];
    
    if (text) {
        [sharingItems addObject:text];
    }
    if (image) {
        [sharingItems addObject:image];
    }
    if (url) {
        [sharingItems addObject:url];
    }
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
}

#pragma mark - Rating delegate

- (void)floatRatingView:(TPFloatRatingView *)ratingView ratingDidChange:(CGFloat)rating
{
    ALog(@"float rating = %f",rating);
}

#pragma mark - Custom WS Methods

//-(void)getAllApplicationType:(NSString*)latitude longitude:(NSString*)longitude completionBlock :(void (^)(void))completion{
//    
//}

-(void)getAllApplicationTypeWithLattitude:(NSString*)latitude longitude:(NSString*)longitude completion:(void (^ __nullable)(void))completion
{
    [pref removeObjectForKey:PREF_FAV_TEXT];
    [pref setBool:NO forKey:PREF_IS_FAV];
    [pref removeObjectForKey:PREF_FAV_LAT];
    [pref removeObjectForKey:PREF_FAV_LONG];
    [mapView_ clear];  // uncommenting on 30/05/2019
    
    if ([_originTextFiled.text isEqualToString:@"Please select proper location"]) {
        [self disableBothRideNowAndRideLater];
    }
    if([APPDELEGATE connected])
    {
        noInternetView.hidden=YES;
        NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
        
        [dictParam setValue:[pref objectForKey:PREF_USER_ID] forKey:PARAM_ID];
        [dictParam setValue:[pref objectForKey:PREF_USER_TOKEN] forKey:PARAM_TOKEN];
        [dictParam setValue:[pref objectForKey:PREF_LYMO_DEVICE_ID] forKey:PARAM_LYMO_DEVICE_ID];
        [dictParam setValue:latitude forKey:PARAM_USER_LATITUDE];
        [dictParam setValue:longitude forKey:PARAM_USER_LONGITUDE];
        ALog(@"get all Types parameters = %@",dictParam);
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:FILE_APPLICATION_TYPE withParamData:dictParam withBlock:^(id response, NSError *error)
         {
             if (response == Nil){
                 if (error.code == -1005 ) {
                     [self getAllApplicationTypeWithLattitude:latitude longitude:longitude completion:^{
                          ALog(@"GOT ERROR NETWORK CONNECTION LOST SO  AGIAIN CALLING GETALLAPPLICATION TYPE ");
                     }];
                 }else {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [APPDELEGATE stopLoader:self.view];
                         [APPDELEGATE showAlertOnTopMostControllerWithText:UNABLE_TO_REACH];
                     });
                 }
             }else if (response)
             {
                 ALog(@"all application Types Response---- %@",response);
                  [APPDELEGATE customerSetting:[response valueForKey:@"customer_setting"] ShowRideComplete:YES ShowCancelPayment:YES FromViewController:self];;
                 if([[response valueForKey:@"success"]boolValue])
                 {
                     if ([[response valueForKey:@"category_stautus"]boolValue]) {
                         if(![[response valueForKey:@"zone_id"]isEqualToString:strForZoneID] || ![[response valueForKey:@"count"]isEqualToString:[NSString stringWithFormat:@"%lu",(unsigned long)[arrForApplicationType count]]]){
                             if (arrForApplicationType.count != [[response valueForKey:@"count"] intValue]) {
                                    [self removePageViewControllerInLandingPage];
                                 reloadAllCategories=YES;
                                 self.pageViewController.dataSource = nil;
                                 _pageIndex=0;
                             }
                             strForZoneID=[response valueForKey:@"zone_id"];
                             _noCarsAvailableHolderView.hidden=YES;
                             _bookLocationBtn.hidden=YES;
                             NSMutableArray *arrCat=[[NSMutableArray alloc]init];
                             [arrCat addObjectsFromArray:[response valueForKey:@"types"]];
                             
                             [[lymoSingleton sharedInstance].globaldictionary removeAllObjects];
                             [[lymoSingleton sharedInstance].arrCarDetails removeAllObjects];
                             [rateCardForIdDist removeAllObjects];
                             [rateCardForIdTime removeAllObjects];
                             
                             [[lymoSingleton sharedInstance].arrCarTypeCount removeAllObjects];
                             [[lymoSingleton sharedInstance].arrCarCatID removeAllObjects];
                             [arrForApplicationType removeAllObjects];
                             [arrForApplicationTypeCarIcon removeAllObjects];
                             
                             [[lymoSingleton sharedInstance].arrCarTypeDetails removeAllObjects];
                             for(NSMutableDictionary *dictCat in arrCat){
                                 [[lymoSingleton sharedInstance].arrCarTypeCount addObject:[dictCat valueForKey:@"count"]];
                                 [[lymoSingleton sharedInstance].arrCarCatID addObject:[dictCat valueForKey:@"id"]];
                                 [arrForApplicationType addObject:[dictCat valueForKey:@"name"]];
                                 [arrForApplicationTypeCarIcon addObject:[dictCat valueForKey:@"ios_car_icon"]];
//                                 [arrForApplicationTypeCarIcon addObject:[dictCat valueForKey:@"android_car_icon"]];
                                 
                                 if ([[dictCat valueForKey:@"count"] intValue]<=1) {
                                     NSMutableArray *arrCatType=[[NSMutableArray alloc]init];
                                     [arrCatType addObjectsFromArray:[dictCat valueForKey:@"type"]];
                                     [[lymoSingleton sharedInstance].globaldictionary setObject:arrCatType forKey:[dictCat valueForKey:@"id"]];
                                     for(NSMutableDictionary *dictCatType in arrCatType){
                                         CarTypeDataModal *obj=[[CarTypeDataModal alloc]init];
                                         obj.id_=[dictCatType valueForKey:@"id"];
                                         obj.baseFare=[dictCatType valueForKey:@"base_fare"];
                                         obj.min_fare=[dictCatType valueForKey:@"min_fare"];
                                         obj.seating=[dictCatType valueForKey:@"max_size"];
                                         obj.icon=[dictCatType valueForKey:@"icon"];
                                         obj.map_icon=[dictCatType valueForKey:@"map_icon"];
                                         ALog(@"base fare = %@", [dictCatType valueForKey:@"base_fare"]);
                                         
                                         if([[dictCatType valueForKey:@"distance_status"]boolValue]){
                                             NSMutableArray *arrCatTypeDis=[[NSMutableArray alloc]init];
                                             [arrCatTypeDis addObjectsFromArray:[dictCatType valueForKey:@"distance_fare"]];
                                             NSMutableDictionary *dictCatTypeDisFirst = [[NSMutableDictionary alloc]init];
                                             dictCatTypeDisFirst=[arrCatTypeDis objectAtIndex:0];
                                             obj.basePrice=[dictCatTypeDisFirst valueForKey:@"price"];
                                             obj.baseKM=[dictCatTypeDisFirst valueForKey:@"to"];

                                             NSMutableDictionary *dictCatTypeDisLast = [[NSMutableDictionary alloc]init];
                                             
                                             if (arrCatTypeDis.count > 1) {
                                                 dictCatTypeDisLast=[arrCatTypeDis objectAtIndex:1];
                                             }else {
                                                 dictCatTypeDisLast=[arrCatTypeDis lastObject];
                                             }

                                             obj.baseAfterPrice=[dictCatTypeDisFirst valueForKey:@"price"];
                                             [rateCardForIdDist setObject:@[[dictCatTypeDisFirst valueForKey:@"price"],[dictCatTypeDisFirst valueForKey:@"to"],[dictCatTypeDisLast valueForKey:@"price"]] forKey:[dictCatType valueForKey:@"id"]];
                                         }else{
                                             
                                         }
                                         if([[dictCatType valueForKey:@"time_status"]boolValue]){
                                             NSMutableArray *arrCatTypeFare=[[NSMutableArray alloc]init];
                                             [arrCatTypeFare addObjectsFromArray:[dictCatType valueForKey:@"time_fare"]];
                                             NSMutableDictionary *dictCatTypeFareFirst = [[NSMutableDictionary alloc]init];
                                             dictCatTypeFareFirst=[arrCatTypeFare objectAtIndex:0];
                                             obj.price_per_unit_time=[dictCatTypeFareFirst valueForKey:@"price"];
                                             obj.TimeKM=[dictCatTypeFareFirst valueForKey:@"from"];
                                             [rateCardForIdTime setObject:@[[dictCatTypeFareFirst valueForKey:@"price"], [dictCatTypeFareFirst valueForKey:@"from"]] forKey:[dictCatType valueForKey:@"id"]];
                                         }else{
                                             
                                         }
                                         
                                         [[lymoSingleton sharedInstance].arrCarDetails addObject:obj];
                                     }
                                 }else {
                                     NSMutableArray *arrCatType=[[NSMutableArray alloc]init];
                                     [arrCatType addObjectsFromArray:[dictCat valueForKey:@"type"]];
                                     [[lymoSingleton sharedInstance].arrCarTypeDetails removeAllObjects];
                                     [[lymoSingleton sharedInstance].globaldictionary setObject:arrCatType forKey:[dictCat valueForKey:@"id"]];
                                     for(NSMutableDictionary *dictCatType in arrCatType){
                                         
                                         CarTypeDataModal *obj=[[CarTypeDataModal alloc]init];
                                         obj.id_=[dictCatType valueForKey:@"id"];
                                         obj.baseFare=[dictCatType valueForKey:@"base_fare"];
                                         obj.min_fare=[dictCatType valueForKey:@"min_fare"];
                                         obj.seating=[dictCatType valueForKey:@"max_size"];
                                         obj.icon=[dictCatType valueForKey:@"icon"];
                                         obj.map_icon=[dictCatType valueForKey:@"map_icon"];
                                         obj.catTypeName = [dictCatType valueForKey:@"name"];
                                         if([[dictCatType valueForKey:@"distance_status"]boolValue]){
                                             NSMutableArray *arrCatTypeDis=[[NSMutableArray alloc]init];
                                             [arrCatTypeDis addObjectsFromArray:[dictCatType valueForKey:@"distance_fare"]];
                                             NSMutableDictionary *dictCatTypeDisFirst = [[NSMutableDictionary alloc]init];
                                             dictCatTypeDisFirst=[arrCatTypeDis objectAtIndex:0];
                                             obj.basePrice=[dictCatTypeDisFirst valueForKey:@"price"];
                                             obj.baseKM=[dictCatTypeDisFirst valueForKey:@"to"];
                                             NSMutableDictionary *dictCatTypeDisLast = [[NSMutableDictionary alloc]init];
                                             if (arrCatTypeDis.count > 1) {
                                                 dictCatTypeDisLast=[arrCatTypeDis objectAtIndex:1];
                                             }else {
                                                dictCatTypeDisLast=[arrCatTypeDis lastObject];
                                             }

                                             obj.baseAfterPrice=[dictCatTypeDisLast valueForKey:@"price"];
                                             [rateCardForIdDist setObject:@[[dictCatTypeDisFirst valueForKey:@"price"],[dictCatTypeDisFirst valueForKey:@"to"],[dictCatTypeDisLast valueForKey:@"price"]] forKey:[dictCatType valueForKey:@"id"]];
                                         }else{
                                             
                                         }
                                         if([[dictCatType valueForKey:@"time_status"]boolValue]){
                                             NSMutableArray *arrCatTypeFare=[[NSMutableArray alloc]init];
                                             [arrCatTypeFare addObjectsFromArray:[dictCatType valueForKey:@"time_fare"]];
                                             NSMutableDictionary *dictCatTypeFareFirst = [[NSMutableDictionary alloc]init];
                                             dictCatTypeFareFirst=[arrCatTypeFare objectAtIndex:0];
                                             //ALog(@"TimePrice%@",[dictCatTypeFareFirst valueForKey:@"price"]);
                                             obj.price_per_unit_time=[dictCatTypeFareFirst valueForKey:@"price"];
                                             obj.TimeKM=[dictCatTypeFareFirst valueForKey:@"from"];
                                             [rateCardForIdTime setObject:@[[dictCatTypeFareFirst valueForKey:@"price"], [dictCatTypeFareFirst valueForKey:@"from"]] forKey:[dictCatType valueForKey:@"id"]];
                                         }else{
                                             
                                         }
                                         [[lymoSingleton sharedInstance].arrCarDetails addObject:obj];
                                         [[lymoSingleton sharedInstance].arrCarTypeDetails addObject:obj];
                                     }
                                 }
                             }
                             
                             if([[pref valueForKey:PREF_SETTING_MENU_BOOK_RIDE] boolValue]) {
                                 _pageControl.hidden=NO;
                                 if (reloadAllCategories) {
                                     [self initiatePageViewController];
                                     if (_pageControl) {
                                         [self.pageControl setCurrentPage:0];
                                         ALog(@"------------>     current page index in allapplication types = %ld  and viewcntlAtIndex = %lu<------------", (long)[currentPageControl currentPage], (unsigned long)index);
                                     }
                                     reloadAllCategories=NO;
                                 }
                                 
                                 if([[pref valueForKey:PREF_SETTING_RIDE_LATER] boolValue]){
                                     isRideLaterEnabled=YES;
                                     _bookRideLaterBtn.enabled=YES;
                                     [_bookRideLaterBtn setTitleColor:rideNowAndLaterActiveColor forState:UIControlStateNormal];
                                     if ([_originTextFiled.text isEqualToString:@"Please select proper location"]) {
                                         [self disableBothRideNowAndRideLater];
                                     }
                                 }else{
                                     isRideLaterEnabled=NO;
                                     _bookRideLaterBtn.enabled=NO;
                                     [_bookRideLaterBtn setTitleColor:rideNowAndLaterDisabledColor forState:UIControlStateNormal];
                                 }
                                 
                                 if([[pref valueForKey:PREF_SETTING_RIDE_NOW] boolValue]){
                                     _bookRideNowBtn.enabled=YES;
                                     [_bookRideNowBtn setTitleColor:rideNowAndLaterActiveColor forState:UIControlStateNormal];
                                     if ([_originTextFiled.text isEqualToString:@"Please select proper location"]) {
                                         [self disableBothRideNowAndRideLater];
                                     }
                                 } else {
                                     _bookRideNowBtn.enabled=NO;
                                     [_bookRideNowBtn setTitleColor:rideNowAndLaterDisabledColor forState:UIControlStateNormal];
                                 }
                                 
                                 
                             }else{
                                 [myView1 removeFromSuperview];
                                 reloadAllCategories=YES;
                                 [locationButton removeFromSuperview];
                                 [expandView removeFromSuperview];
                                 if (_pulseView.hidden) {
                                     _noCarsAvailableHolderView.hidden=NO;
                                 }
                                 _noCarsAvailableLabel.text=@"Bookings are currently not available. Please try later";
                                 
                                 _pageControl.hidden=YES;
                                 _bookLocationBtn.hidden=NO;
                                 _navOriginFavBtn.enabled=NO;
                                 _bookRideLaterBtn.enabled=NO;
                                 _bookRideNowBtn.enabled=NO;
                                 
                                 [_bookRideNowBtn setTitleColor:rideNowAndLaterDisabledColor forState:UIControlStateNormal];
                                 [_bookRideLaterBtn setTitleColor:rideNowAndLaterDisabledColor forState:UIControlStateNormal];
                             }
                         }
                         completion();
                     } else {
                         //Here no cars are available so remove the slider view and display service not available message
                         if(navigationBarView){
                             [self changeHeight:155 viewPosition:225];
                             _navigationView.hidden=NO;
                             _noCarsAvailableHolderView.hidden=NO;
                             navigationBarView=NO;
                         }
                         [myView1 removeFromSuperview];
                         [locationButton removeFromSuperview];
                         [expandView removeFromSuperview];
                         reloadAllCategories=YES;
                          self.pageViewController.dataSource = nil;
                         _pageIndex=0;
                         [mapView_ clear];
                         _pageControl.hidden=YES;
                         if (_pulseView.hidden) {
                             _noCarsAvailableHolderView.hidden=NO;
                         }
                         _noCarsAvailableLabel.text=[response valueForKey:@"message"];
                         
                         _bookLocationBtn.hidden=NO;
                         
                         _bookRideLaterBtn.enabled=NO;
                         _bookRideNowBtn.enabled=NO;
                         [_bookRideNowBtn setTitleColor:rideNowAndLaterDisabledColor forState:UIControlStateNormal];
                         [_bookRideLaterBtn setTitleColor:rideNowAndLaterDisabledColor forState:UIControlStateNormal];
                         
                         strForZoneID=@"";
                         [pref setObject:@"0" forKey:PREF_CATEGORY_TYPE_ID];
                         [pref synchronize];
                     }
                 }
                 else{
                     
                 }
             }
             [APPDELEGATE stopLoader:self.view];
             
         }];
    }
    else
    {
        noInternetView.hidden=NO;
        [APPDELEGATE stopLoader:self.view];
        [customAlertView setContainerView:[APPDELEGATE createDemoView:NO_INTERNET view:self.view]];
        [customAlertView show];
    }
    
}


-(void)callTypesTwoApiToCheckDestinationServicesWithLattitude: (NSString*)lattitude AndLongitude: (NSString*) longitude onCompletion: (void (^)(NSDictionary *dict)) completed {
    
    if([APPDELEGATE connected]){
        [APPDELEGATE startLoader:self.view giveSpaceFornavigationBar:NO];
        NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
        
        [dictParam setValue:[pref objectForKey:PREF_USER_ID] forKey:PARAM_ID];
        [dictParam setValue:[pref objectForKey:PREF_USER_TOKEN] forKey:PARAM_TOKEN];
        [dictParam setValue:[pref objectForKey:PREF_LYMO_DEVICE_ID] forKey:PARAM_LYMO_DEVICE_ID];
        [dictParam setValue:lattitude forKey:PARAM_USER_LATITUDE];
        [dictParam setValue:longitude forKey:PARAM_USER_LONGITUDE];
        ALog(@"types 2  parameters = %@",dictParam);
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:FILE_APPLICATION_TYPES_TWO withParamData:dictParam withBlock:^(id response, NSError *error)
         {
             if (response == Nil){
                 if (error.code == -1005 ) {
                     [APPDELEGATE stopLoader:self.view];
                     [self callTypesTwoApiToCheckDestinationServicesWithLattitude:lattitude AndLongitude:longitude onCompletion:^(NSDictionary* completed) {
                         ALog(@"error so calling again types two api");
                     }];
                 }else {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [APPDELEGATE stopLoader:self.view];
                         [APPDELEGATE showAlertOnTopMostControllerWithText:UNABLE_TO_REACH];
                     });
                 }
             }else if (response){
                 ALog(@"types two response at line-4419 is %@", response);
                 [APPDELEGATE stopLoader:self.view];
                 completed(response);
             }
         }];
    } else{
        [customAlertView setContainerView:[APPDELEGATE createDemoView:NO_INTERNET view:self.view]];
        [customAlertView show];
    }
}

-(void)refreshCarDetailsViewOnCompletion:(void (^)(void))completion {
    
}

-(void)createRequestForRideNow {
    _pulseView.hidden=NO;
    _RideNowBtnView.hidden=YES;
    _RideNowView.hidden=YES;
    _destinationView.hidden=YES;
    _navigationView.hidden=YES;
    _pulseView_cancelButton.hidden=YES;
    _noCarsAvailableHolderView.hidden=YES;
    isActivityControllershown=NO;
    if ([_destinationTextFiled.text isEqualToString:@""]){
        strForDestinationLatitude=@"";
        strForDestinationLongitude=@"";
    }
    
    if([CLLocationManager locationServicesEnabled]){
        if ([pref objectForKey:PREF_CATEGORY_TYPE_ID]==nil||[[pref objectForKey:PREF_CATEGORY_TYPE_ID]isEqualToString:@""]){
            [pref setObject:@"1" forKey:PREF_CATEGORY_TYPE_ID];
        }
        if(![[pref objectForKey:PREF_CATEGORY_TYPE_ID] isEqualToString:@"0"]){
            if(((strForLatitude==nil)&&(strForLongitude==nil))
               ||(([strForLongitude doubleValue]==0.00)&&([strForLatitude doubleValue]==0.00))){
                //                [APPDELEGATE showToastMessage:NSLocalizedString(@"NOT_VALID_LOCATION", nil)];
            }else{
                if([APPDELEGATE connected]){
                    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
                    [dictParam setValue:strForLatitude forKey:PARAM_LATITUDE];
                    [dictParam setValue:strForLongitude  forKey:PARAM_LONGITUDE];
                    [dictParam setValue:_originTextFiled.text  forKey:PARAM_SOURCE_ADDRESS];
                    
                    if([[pref valueForKey:PREF_SETTING_RIDE_NOW_DESTINATION] boolValue] || ![_destinationTextFiled.text isEqualToString:@""]){
                        [dictParam setValue:strForDestinationLatitude  forKey:PARAM_D_LATITUDE];
                        [dictParam setValue:strForDestinationLongitude  forKey:PARAM_D_LONGITUDE];
                        [dictParam setValue:_destinationTextFiled.text  forKey:PARAM_DESTINATION_ADDRESS];
                    }
                    [dictParam setValue:@"1" forKey:PARAM_DISTANCE];
                    [dictParam setValue:[pref objectForKey:PREF_USER_ID] forKey:PARAM_ID];
                    [dictParam setValue:[pref objectForKey:PREF_USER_TOKEN] forKey:PARAM_TOKEN];
                    [dictParam setValue:[pref objectForKey:PREF_LYMO_DEVICE_ID] forKey:PARAM_LYMO_DEVICE_ID];
                    
                    [dictParam setValue:[pref objectForKey:PREF_CATEGORY_TYPE_ID] forKey:PARAM_TYPE];
                    NSObject * object = [pref objectForKey:PREF_PAYMENT_OPT];
                    if(object != nil){
                        [dictParam setValue:[pref objectForKey:PREF_PAYMENT_OPT] forKey:PARAM_PAYMENT_OPT];
                    }else{
                        [pref setValue:@"1" forKey:PREF_PAYMENT_OPT];
                        [pref synchronize];
                        [dictParam setValue:[pref objectForKey:PREF_PAYMENT_OPT] forKey:PARAM_PAYMENT_OPT];
                    }
                    [dictParam setValue:[pref objectForKey:PREF_PAYMENT_ID] forKey:PARAM_PAYMENT_ID];
                    [dictParam setValue:[pref valueForKey:PREF_PROMO] forKey:PARAM_PROMO_CODE];
                    ALog(@"RideNow Server Dictionary ..%@", dictParam);
                    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
                    [afn getDataFromPath:FILE_CREATE_REQUEST withParamData:dictParam withBlock:^(id response, NSError *error){
                        if (response == Nil){
                            if (error.code == -1005 ) {
                                [self createRequestForRideNow];
                                
                            }
                            else if (error.code == -1001 ){
                                
                                [timerForCheckReqStatus invalidate];
                                timerForCheckReqStatus=nil;
                                _pulseView.hidden=YES;
                                _RideNowBtnView.hidden=NO;
                                _RideNowView.hidden=NO;
                                _destinationView.hidden=NO;
                                _navigationView.hidden=NO;
                                
                                _cancelAlertBigView.hidden=YES;
                                startRideEnable=NO;
                                strForCancelReasonText=@"";
                                strForCancelReasonID=@"";
                                [pref removeObjectForKey:PARAM_REQUEST_ID];
                                [self navBackViewGesture:nil];
                                
                            }else {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [APPDELEGATE showAlertOnTopMostControllerWithText:UNABLE_TO_REACH];
                                });
                            }
                        }else if (response){
                            ALog(@"Ride now response at line-4023 is %@", response);
                            if([[response valueForKey:@"success"]boolValue]){
                                ALog(@"pick up......%@",response);
                                _pulseView_cancelButton.hidden=NO;
                                strForRequestID=[response valueForKey:@"request_id"];
                                [pref setObject:strForRequestID forKey:PREF_REQ_ID];
                                navBackPressedBool=YES;
                                lastWalkerId = @"0";
                                //                                    [mapView_ clear];
                                is_secondary_type=YES;
                                [self setTimerToCheckDriverStatus];
                            }
                            else{
                                [timerForCheckReqStatus invalidate];
                                timerForCheckReqStatus=nil;
                                [customAlertView setContainerView:[APPDELEGATE createDemoView:[response valueForKey:@"error"] view:self.view]];
                                [customAlertView show];
                                
                                _pulseView.hidden=YES;
                                _RideNowBtnView.hidden=NO;
                                _RideNowView.hidden=NO;
                                _destinationView.hidden=NO;
                                _navigationView.hidden=NO;
                                
                                _cancelAlertBigView.hidden=YES;
                                startRideEnable=NO;
                                strForCancelReasonText=@"";
                                strForCancelReasonID=@"";
                                [pref removeObjectForKey:PARAM_REQUEST_ID];
                                [self navBackViewGesture:nil];
                                //                                [APPDELEGATE showToastMessage:NSLocalizedString(@"REQUEST_CANCEL", nil)];
                            }
                            [APPDELEGATE customerSetting:[response valueForKey:@"customer_setting"] ShowRideComplete:YES ShowCancelPayment:YES FromViewController:self];;
                            //                            
                        }
                    }];
                } else {
                    [customAlertView setContainerView:[APPDELEGATE createDemoView:NO_INTERNET view:self.view]];
                    [customAlertView show];
                }
            }
            
        }
        //        else
        //            [APPDELEGATE showToastMessage:NSLocalizedString(@"SELECT_TYPE", nil)];
    }
    else
    {
        [customAlertView setContainerView:[APPDELEGATE createDemoView:PLEASE_ENABLE_LOCATION_SERVICES view:self.view]];
        [customAlertView show];
    }
}

-(void) startRideDestinationChangeWithLat: (NSString*)lattitide andLong: (NSString*)longitude andAddress: (NSString*)address {
    if([APPDELEGATE connected]){
        [APPDELEGATE startLoader:self.view giveSpaceFornavigationBar:NO];
        NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
        [dictParam setValue:[pref objectForKey:PREF_USER_ID] forKey:PARAM_ID];
        [dictParam setValue:[pref objectForKey:PREF_USER_TOKEN] forKey:PARAM_TOKEN];
        [dictParam setValue:[pref objectForKey:PREF_LYMO_DEVICE_ID] forKey:PARAM_LYMO_DEVICE_ID];
        [dictParam setValue:address  forKey:PARAM_DESTINATION_ADDRESS];
        
        if ([lattitide isEqualToString:@""] || [longitude isEqualToString:@""]) {
            [dictParam setValue:@"0"  forKey:PARAM_D_LATITUDE];
            [dictParam setValue:@"0"  forKey:PARAM_D_LONGITUDE];
        }else {
            [dictParam setValue:lattitide  forKey:PARAM_D_LATITUDE];
            [dictParam setValue:longitude  forKey:PARAM_D_LONGITUDE];
        }
        [dictParam setValue:[pref stringForKey:PREF_REQ_ID] forKey:PARAM_REQUEST_ID];
        ALog(@"destination change params are = %@", dictParam);
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [afn getDataFromPath:FILE_SET_DESTINATION withParamData:dictParam withBlock:^(id response, NSError *error){
            if (response == Nil){
                [APPDELEGATE stopLoader:self.view];
                if (error.code == -1005 ) {
                    [self startRideDestinationChangeWithLat:lattitide andLong:longitude andAddress:address];
                }else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [APPDELEGATE stopLoader:self.view];
                        [APPDELEGATE showAlertOnTopMostControllerWithText:UNABLE_TO_REACH];
                    });
                }
                
            }else if (response){
                [APPDELEGATE stopLoader:self.view];
                ALog(@"destination address change response =  %@", response);
                if([[response valueForKey:@"success"]boolValue]){
                }
            }
        }];
    } else {
        [customAlertView setContainerView:[APPDELEGATE createDemoView:NO_INTERNET view:self.view]];
        [customAlertView show];
    }
}

-(void)moveTheCurrentLocationToCenter {
    if([CLLocationManager locationServicesEnabled]&&
       [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied)
    {
        CLLocationCoordinate2D coor;
        ALog(@"current lattitide = %f",[strForCurLatitude doubleValue]);
        ALog(@"current longitude = %f",[strForCurLongitude doubleValue]);
        coor.latitude=[strForCurLatitude doubleValue];
        coor.longitude=[strForCurLongitude doubleValue];
        CGPoint point = [mapView_.projection pointForCoordinate:coor];
        GMSCameraUpdate *camera =
        [GMSCameraUpdate setTarget:[mapView_.projection coordinateForPoint:point] zoom:zoom];
        [mapView_ animateWithCameraUpdate:camera];
    }else{
        UIAlertView* LocationStatus=[[UIAlertView alloc] initWithTitle:@"This app does not have access to Location services" message:@"Please allow Orbit to use location services .Turn it on from settings" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Settings", nil];
        [LocationStatus show];
    }
}

/*

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    CGPoint point = [mapView.projection pointForCoordinate:marker.position];
    point.y = point.y - 100;
    GMSCameraUpdate *camera =
    [GMSCameraUpdate setTarget:[mapView.projection coordinateForPoint:point]];
    [mapView animateWithCameraUpdate:camera];
    
    mapView.selectedMarker = marker;
    return YES;
}

 */


-(void)updateLocationoordinates :(CLLocationCoordinate2D) coordinates andbearing : (double)bearing
{
    if (driver_marker == nil) {
        driver_marker = [GMSMarker markerWithPosition:coordinates];
        driver_marker.icon= driverCarIcon;
        
    }
    driver_marker.map = mapView_;
    [CATransaction begin];
    [CATransaction setAnimationDuration:2.0];
    driver_marker.position = coordinates;
    driver_marker.rotation = bearing;
    [CATransaction commit];
}

-(void)disableBothRideNowAndRideLater{
    if ([_originTextFiled.text isEqualToString:@"Please select proper location"]  && [strForCurrentPage isEqual:@"booking"]) {
        _bookRideLaterBtn.enabled=NO;
        _bookRideNowBtn.enabled=NO;
        [_bookRideNowBtn setTitleColor:rideNowAndLaterDisabledColor forState:UIControlStateNormal];
        [_bookRideLaterBtn setTitleColor:rideNowAndLaterDisabledColor forState:UIControlStateNormal];
    }
}
- (void)resetLandingPageUserDefaults {
    [pref removeObjectForKey:PREF_CATEGORY_TYPE_ID];
    [pref removeObjectForKey:PREF_FAV_TEXT];
    [pref removeObjectForKey:PREF_ADD_FAV_TEXT];
    [pref removeObjectForKey:PREF_ADD_FAV_LAT];
    [pref removeObjectForKey:PREF_ADD_FAV_LONG];
    [pref removeObjectForKey:PREF_FAV_ORIG_ADDRESS_ID];
    [pref removeObjectForKey:PREF_FAV_DEST_ADDRESS_ID];
    [pref removeObjectForKey:PREF_FAREEST_ORIG_ADDRESS_ID];
    [pref removeObjectForKey:PREF_FAREEST_DEST_ADDRESS_ID];
    [pref removeObjectForKey:PREF_FARE_DESTINATIONTEXT];
    [pref removeObjectForKey:PARAM_USER_LATITUDE];
    [pref removeObjectForKey:PARAM_LATITUDE];
    [pref removeObjectForKey:PARAM_LONGITUDE];
    [pref removeObjectForKey:PREF_SEARCH_EDIT_ADDRESS];
    [pref removeObjectForKey:@"Paymentselected"];
    [pref synchronize];
}

#pragma mark - Favourites list vc  Delegate method

-(void)selectedAddressDictionary:(NSDictionary *)addressDict sender:(id)sender {
    
    ALog(@"***************** protocols and delegaets is working address data = %@ *******************", addressDict);
    if ([[addressDict valueForKey:@"searchingField"] isEqualToString:@"fav_dest"]) {
        strForDesFavtLat=[addressDict valueForKey:@"selectedLat"];
        strForDestFavLong=[addressDict valueForKey:@"selectedLong"];
        _destinationTextFiled.text=[addressDict valueForKey:@"selectedAddress"];
        [self callTypesTwoApiToCheckDestinationServicesWithLattitude:strForDesFavtLat AndLongitude:strForDestFavLong onCompletion:^(NSDictionary *dict) {
            ALog(@"dictionary in types two = %@", dict);
            if (![[dict valueForKey:@"status"] boolValue])
            {
                if([strForCurrentPage isEqualToString:@"ridenow"] || [strForCurrentPage isEqualToString:@"ridelater"]){
                    strForDestinationLatitude=@"";
                    strForDestinationLongitude=@"";
                    [_destinationFavBtn setImage:[UIImage imageNamed:@"Fav_btn"] forState:UIControlStateNormal];
                    [customAlertView setContainerView:[APPDELEGATE createDemoView:[dict valueForKey:@"message"] view:self.view]];
                    customAlertView.tag = 1234;
                    [customAlertView show];
                    
                } else if ([strForCurrentPage isEqualToString:@"startride"]){
                    if (isLater && [[pref valueForKey:PREF_SETTING_RIDE_LATER_DESTINATION] boolValue]) {
                        ALog(@"Ride later is mandatory but given empty address ======================");
                        return;
                    }else if (!isLater && [[pref valueForKey:PREF_SETTING_RIDE_NOW_DESTINATION] boolValue]){
                        ALog(@"Ride now is mandatory but given empty address==========================");
                        return;
                    }else{
                        markerOwnerDest.map=nil;
                        markerOwnerDest=nil;
                        _destinationTextFiled.text=@"";
                        strForDestinationLatitude=@"";
                        strForDestinationLongitude=@"";
                        [customAlertView setContainerView:[APPDELEGATE createDemoView:[dict valueForKey:@"message"] view:self.view]];
                        customAlertView.tag = 1234;
                        [customAlertView show];
                        [_destinationFavBtn setImage:[UIImage imageNamed:@"Fav_btn"] forState:UIControlStateNormal];
                        [self startRideDestinationChangeWithLat:@"" andLong:@"" andAddress:@""];
                    }
                }
                
            } else {
                _destinationTextFiled.text=[addressDict valueForKey:@"selectedAddress"];
                strForDestinationLatitude=strForDesFavtLat;
                strForDestinationLongitude=strForDestFavLong;
                [_destinationFavBtn setImage:[UIImage imageNamed:@"Fav_fill"] forState:UIControlStateNormal];
                if ([strForCurrentPage isEqualToString:@"startride"]){
                    [self startRideDestinationChangeWithLat:strForDestinationLatitude andLong:strForDestinationLongitude andAddress:[addressDict valueForKey:@"selectedAddress"]];
                }
            }
        }];
    } else if ([[addressDict valueForKey:@"searchingField"] isEqualToString:@"fav_origin"]) {
        changeOriginText=NO;
        _originTextFiled.text=[addressDict valueForKey:@"selectedAddress"];
        strForLatitude=[addressDict valueForKey:@"selectedLat"];
        strForLongitude=[addressDict valueForKey:@"selectedLong"];
        if([strForCurrentPage isEqualToString:@"booking"]){
            CLLocationCoordinate2D coor;
            coor.latitude=[strForLatitude doubleValue];
            coor.longitude=[strForLongitude doubleValue];
            // mapview will move to current location so make shure that all values are updated
            GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:coor zoom:zoom];
            [mapView_ animateWithCameraUpdate:updatedCamera];
            [pref setBool:YES forKey:PREF_IS_FAV];
        }
        [_navOriginFavBtn setImage:[UIImage imageNamed:@"Fav_fill"] forState:UIControlStateNormal];
    }
}

-(void)deselectOriginButton {
    [_navOriginFavBtn setImage:[UIImage imageNamed:@"Fav_btn"] forState:UIControlStateNormal];
}

-(void)deselectDestinationButton {
    [_destinationFavBtn setImage:[UIImage imageNamed:@"Fav_btn"] forState:UIControlStateNormal];
}

-(void)reloadTheDataOfNewLocationWithLattitude:(NSString *)lattitude andLongitude:(NSString *)longitude {
    [self getAllApplicationTypeWithLattitude:lattitude longitude:longitude completion:^{
        if(![[pref objectForKey:PREF_CATEGORY_TYPE_ID] isEqualToString:@"0"]){
            [self checkCarsAvailabilityWithidString:[pref objectForKey:PREF_CATEGORY_TYPE_ID]];
            ALog(@"The category id in reload data from favourites = %@", [pref objectForKey:PREF_CATEGORY_TYPE_ID]);
        }
    }];
}


-(void) deselectOriginFromFareEstimate {
//  [_navOriginFavBtn setImage:[UIImage imageNamed:@"Fav_btn"] forState:UIControlStateNormal];
}

-(void) deselectDestimationFromFareEstimate {
//    [_destinationFavBtn setImage:[UIImage imageNamed:@"Fav_btn"] forState:UIControlStateNormal];
}

-(void)resetTheBookingScreen{
//    [self resetToBookingPage];
}

-(void)requestPath
{
    if ([pref objectForKey:PREF_USER_ID]) {
        NSString *strForUserId=[pref objectForKey:PREF_USER_ID];
        NSString *strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
        NSString *strReqId=[pref objectForKey:PREF_REQ_ID];
        
        if ([APPDELEGATE connected]) {
            [APPDELEGATE startLoader:self.view giveSpaceFornavigationBar:NO];
            NSMutableString *pageUrl=[NSMutableString stringWithFormat:@"%@?%@=%@&%@=%@&%@=%@&%@=%@",FILE_REQUEST_PATH,PARAM_ID,strForUserId,PARAM_TOKEN,strForUserToken,PARAM_REQUEST_ID,strReqId,PARAM_LYMO_DEVICE_ID,[pref objectForKey:PREF_LYMO_DEVICE_ID]];
            AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
            [afn getDataFromPath:pageUrl withParamData:nil withBlock:^(id response, NSError *error)
             {
                 ALog(@"completed path  Data= %@",response);
                 if (response == Nil){
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [APPDELEGATE stopLoader:self.view];
                         [APPDELEGATE showAlertOnTopMostControllerWithText:UNABLE_TO_REACH];
                     });
                 }else if (response)
                 {
                     NSMutableDictionary *dictWalker = [[NSMutableDictionary alloc] init];
                     dictWalker=[response valueForKey:@"walker"];
                     if([[response valueForKey:@"is_walker_started"] intValue]!=0){
                         _lymoArrivingLbl.text=@"Orbit Arriving";
                     }
                     
                     if([[response valueForKey:@"is_walker_arrived"] intValue]!=0){
                         _lymoArrivingLbl.text=@"Orbit Arrived";
                     }
                     
                     if([[response valueForKey:@"is_walk_started"] intValue]!=0){
                         _lymoArrivingLbl.text=@"Trip Started";
                         _startRideDetailCancelView.userInteractionEnabled = NO;
                         _startRideCancelLbl.textColor=[UIColor lightGrayColor];
                         _startRideCancelIcon.image=[UIImage imageNamed:@"Cancel_gray"];
                         _cancelAlertBigView.hidden=YES;
                     }
                     if ([[response valueForKey:@"ios_icon"] length] >4) {
                         NSURL *imageURL = [NSURL URLWithString:[response valueForKey:@"ios_icon"]];
                         
                         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                             NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 driverCarIcon=[UIImage imageWithData:imageData];
                                 driver_marker.icon = driverCarIcon;
                                 driver_marker.map = mapView_;
                                 
                             });
                         });
                     }else {
                         driverCarIcon=[UIImage imageNamed:@"Executive"];
                         driver_marker.icon=driverCarIcon;
                         driver_marker.map = mapView_;
                         //            [UIImage imageNamed:@"pin_driver"];
                         //                                        [UIImage imageNamed:@"pin_driver"];
                         //                                        [UIImage imageNamed:@"Mini"];
                         //                                        [UIImage imageNamed:@"Saloon"];
                         //                                            [UIImage imageNamed:@"Executive"]
                     }
                     
                     strForWalkerPhone=[dictWalker objectForKey:@"phone"];
                     
                     if([[response valueForKey:@"success"] intValue]==1)
                     {
                         
                         [arrPath removeAllObjects];
                         if ([[[response valueForKey:@"locationdata"] lastObject] valueForKey:@"id"]) {
                             ALog(@"last walk id = %@", [[[response valueForKey:@"locationdata"] lastObject] valueForKey:@"id"]);
                             lastWalkerId=[[[response valueForKey:@"locationdata"] lastObject] valueForKey:@"id"];
                         }
                         //                 arrPath=[[response valueForKey:@"locationdata"] mutableCopy];
                         //                 [self drawCompletedPath];
                         [APPDELEGATE stopLoader:self.view];
                         [self setTimerToCheckDriverStatus];
                     } else {
                         [APPDELEGATE stopLoader:self.view];
                         [self setTimerToCheckDriverStatus];
                     }
                 }
             }];
        } else {
            [customAlertView setContainerView:[APPDELEGATE createDemoView:NO_INTERNET view:self.view]];
            [customAlertView show];
        }

    }else {
        [timerForCheckReqStatus invalidate];
        timerForCheckReqStatus = nil;
        noInternetView.hidden=NO;
        callrequestPath=NO;
        [self navBackViewGesture:nil];
    }
}

#pragma mark - Custom Popup Delegate

- (void)customIOS7dialogButtonTouchUpInside: (CustomIOSAlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    ALog(@"Delegate: Button at position %d is clicked on alertView %d.", (int)buttonIndex, (int)[alertView tag]);
    if (alertView.tag == 1234) {
         _destinationTextFiled.text = @"";
        customAlertView.tag=1;
    }else if (alertView.tag == 101){
        [self navBackViewGesture:nil];
        customAlertView.tag=1;
    }
    [alertView close];
}
@end
