//
//  ViewController.m
//  Bitcoin Notify
//
//  Created by Ryan Detzel on 3/4/14.
//  Copyright (c) 2014 Ryan Detzel. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
-(void)updateCurrentPriceLabel;
@property (nonatomic, strong) UILabel *currentPriceLabel;
@end

@implementation ViewController

@synthesize currentPriceLabel;


- (void)viewDidLoad{
    [super viewDidLoad];
    
    /* Setup a label to display the current price in the app */
    currentPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/2,
                                                                  self.view.frame.size.width, 24)];
    currentPriceLabel.font = [UIFont systemFontOfSize:24];
    currentPriceLabel.textAlignment = NSTextAlignmentCenter;
    currentPriceLabel.text = @"-";
    
    [self fetchBackgroundDataWithCompletionHandler:nil];
    [self.view addSubview:currentPriceLabel];
    
    
    //[self updateCurrentPriceLabel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateCurrentPriceLabel)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateCurrentPriceLabel)
                                                 name:UIApplicationBackgroundRefreshStatusDidChangeNotification
                                               object:nil];
}

-(void)fetchBackgroundDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    //sessionConfiguration.URLCache = nil;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    
    NSURL *url = [[NSURL alloc] initWithString:@"http://dxxd.net/bitcoin.txt"];
    NSLog(@"Fetch background");
    NSURLSessionDataTask *task = [session dataTaskWithURL:url
                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                            NSNumber *price = [NSNumber numberWithFloat:[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] floatValue]];
                                            
                                            NSLog(@"Price: %@", price);
                                            if (error) {
                                                if (completionHandler){
                                                    completionHandler(UIBackgroundFetchResultFailed);
                                                }
                                                return;
                                            }
                                            
                                            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                            NSDate *last_notification = (NSDate *)[defaults objectForKey:@"last_notification"];
                                            NSTimeInterval secondsBetween = 1000;
                                            
                                            if (last_notification != nil){
                                                secondsBetween = [[NSDate date] timeIntervalSinceDate:last_notification];
                                            }
                                            
                                            UILocalNotification *localNotif = [[UILocalNotification alloc] init];
                                            
                                            if (secondsBetween > 60 * 5 && [price floatValue] < 670){
                                                
                                                localNotif.alertBody = [NSString stringWithFormat:@"Price Alert: $%@", price];
                                                localNotif.alertAction = @"View";
                                                localNotif.soundName = UILocalNotificationDefaultSoundName;
                                                [defaults setObject:[NSDate date] forKey:@"last_notification"];
                                            }
                                            
                                            // Keep the icon badge up to date
                                            localNotif.applicationIconBadgeNumber = [price integerValue];
                                            [[UIApplication sharedApplication]presentLocalNotificationNow:localNotif];
                                            
                                            [defaults setObject:price forKey:@"current_price"];
                                            [defaults synchronize];
                                            
                                            //Update the screenshot for background task switching
                                            [self updateCurrentPriceLabel];
                                            if (completionHandler){
                                                completionHandler(UIBackgroundFetchResultNewData);
                                            }
                                        }];
    
    [task resume];
}

-(void)updateCurrentPriceLabel{
    NSString *current_price = [[NSUserDefaults standardUserDefaults] stringForKey:@"current_price"];
    NSLog(@"Update current price lavel");
    
    if (current_price != nil){
        currentPriceLabel.text = current_price;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
