#import "BannerView.h"

#if __has_include(<React/RCTBridgeModule.h>)
#import <React/RCTBridgeModule.h>
#import <React/UIView+React.h>
#import <React/RCTLog.h>
#else
#import "RCTBridgeModule.h"
#import "UIView+React.h"
#import "RCTLog.h"
#endif

@implementation BannerView {
    GADBannerView  *_bannerView;
}

- (void)insertReactSubview:(UIView *)view atIndex:(NSInteger)atIndex
{
    [super insertReactSubview:view atIndex:atIndex];
    RCTLogError(@"AdMob Banner cannot have any subviews");
    return;
}

- (void)removeReactSubview:(UIView *)subview
{
    [super removeReactSubview:subview];
    RCTLogError(@"AdMob Banner cannot have any subviews");
    return;
}

- (GADAdSize)getAdSizeFromString:(NSString *)bannerSize
{
    if ([bannerSize isEqualToString:@"banner"]) {
        return kGADAdSizeBanner;
    } else if ([bannerSize isEqualToString:@"largeBanner"]) {
        return kGADAdSizeLargeBanner;
    } else if ([bannerSize isEqualToString:@"mediumRectangle"]) {
        return kGADAdSizeMediumRectangle;
    } else if ([bannerSize isEqualToString:@"fullBanner"]) {
        return kGADAdSizeFullBanner;
    } else if ([bannerSize isEqualToString:@"leaderboard"]) {
        return kGADAdSizeLeaderboard;
    } else if ([bannerSize isEqualToString:@"smartBannerPortrait"]) {
        return kGADAdSizeSmartBannerPortrait;
    } else if ([bannerSize isEqualToString:@"smartBannerLandscape"]) {
        return kGADAdSizeSmartBannerLandscape;
    } else if ([bannerSize isEqualToString:@"customBanner"]) {
        GADAdSize size = GADAdSizeFromCGSize(CGSizeMake(_width, _height));
        return size;
    } else {
        return kGADAdSizeBanner;
    }
}

-(void)loadBanner
{
    if (_adUnitID && _bannerSize) {
        if ([_bannerSize isEqualToString:@"customBanner"] && (!_width || !_height)) {
            return;
        }
        if (_bannerView) {
            [_bannerView removeFromSuperview];
        }
        GADAdSize size = [self getAdSizeFromString:_bannerSize];
        _bannerView = [[GADBannerView alloc] initWithAdSize:size];
        if(!CGRectEqualToRect(self.bounds, _bannerView.bounds)) {
            if (self.onSizeChange) {
                self.onSizeChange(@{
                                    @"width": [NSNumber numberWithFloat: _bannerView.bounds.size.width],
                                    @"height": [NSNumber numberWithFloat: _bannerView.bounds.size.height]
                                    });
            }
        }
        _bannerView.delegate = self;
        _bannerView.adUnitID = _adUnitID;
        _bannerView.rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
        GADRequest *request = [GADRequest request];
        if(_testDeviceID) {
            if([_testDeviceID isEqualToString:@"EMULATOR"]) {
                request.testDevices = @[kGADSimulatorID];
            } else {
                request.testDevices = @[_testDeviceID];
            }
        }
        [_bannerView loadRequest:request];
        [self addSubview:_bannerView];
    }
}

- (void)setBannerSize:(NSString *)bannerSize
{
    if(![bannerSize isEqual:_bannerSize]) {
        _bannerSize = bannerSize;
        [self loadBanner];
    }
}

- (void)setWidth:(float)width
{
    if(width != _width) {
        _width = width;
        [self loadBanner];
    }
}

- (void)setHeight:(float)height
{
    if(height != _height) {
        _height = height;
        [self loadBanner];
    }
}

- (void)setAdUnitID:(NSString *)adUnitID
{
    if(![adUnitID isEqual:_adUnitID]) {
        _adUnitID = adUnitID;
        [self loadBanner];
    }
}

- (void)setTestDeviceID:(NSString *)testDeviceID
{
    if(![testDeviceID isEqual:_testDeviceID]) {
        _testDeviceID = testDeviceID;
        [self loadBanner];
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.frame = CGRectMake(
                            self.bounds.origin.x,
                            self.bounds.origin.x,
                            _bannerView.frame.size.width,
                            _bannerView.frame.size.height);
}

/// Tells the delegate an ad request loaded an ad.
- (void)adViewDidReceiveAd:(GADBannerView *)adView {
    if (self.onAdViewDidReceiveAd) {
        self.onAdViewDidReceiveAd(@{});
    }
}

/// Tells the delegate an ad request failed.
- (void)adView:(GADBannerView *)adView
didFailToReceiveAdWithError:(GADRequestError *)error {
    if (self.onDidFailToReceiveAdWithError) {
        self.onDidFailToReceiveAdWithError(@{@"error": [error localizedDescription]});
    }
}

/// Tells the delegate that a full screen view will be presented in response
/// to the user clicking on an ad.
- (void)adViewWillPresentScreen:(GADBannerView *)adView {
    if (self.onAdViewWillPresentScreen) {
        self.onAdViewWillPresentScreen(@{});
    }
}

/// Tells the delegate that the full screen view will be dismissed.
- (void)adViewWillDismissScreen:(GADBannerView *)adView {
    if (self.onAdViewWillDismissScreen) {
        self.onAdViewWillDismissScreen(@{});
    }
}

/// Tells the delegate that the full screen view has been dismissed.
- (void)adViewDidDismissScreen:(GADBannerView *)adView {
    if (self.onAdViewDidDismissScreen) {
        self.onAdViewDidDismissScreen(@{});
    }
}

/// Tells the delegate that a user click will open another app (such as
/// the App Store), backgrounding the current app.
- (void)adViewWillLeaveApplication:(GADBannerView *)adView {
    if (self.onAdViewWillLeaveApplication) {
        self.onAdViewWillLeaveApplication(@{});
    }
}

@end
