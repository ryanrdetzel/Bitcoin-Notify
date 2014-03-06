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
@end


@implementation ViewController

@synthesize currentPriceLabel, alertPrice;

- (void)viewDidLoad{
    [super viewDidLoad];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    currentPriceLabel.text = [defaults stringForKey:@"last_price"];
    alertPrice.text = [defaults stringForKey:@"alert_price"];
    
    [self updatePriceWithCompletionHandler:nil];
    [alertPrice becomeFirstResponder];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateCurrentPriceLabel)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateCurrentPriceLabel)
                                                 name:UIApplicationBackgroundRefreshStatusDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidChange)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:alertPrice];
}

-(void)textFieldDidChange{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setFloat:[alertPrice.text floatValue] forKey:@"alert_price"];
    [defaults synchronize];
    NSLog(@"Saved: %@", alertPrice.text);
}

-(void)updatePriceWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    //sessionConfiguration.URLCache = nil;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    
    NSURL *url = [[NSURL alloc] initWithString:@"http://dxxd.net/bitcoin.txt"];
    NSLog(@"Fetch background");
    NSURLSessionDataTask *task = [session dataTaskWithURL:url
                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                            NSNumber *price = [NSNumber numberWithFloat:[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] floatValue]];
                                            
                                            if (error) {
                                                if (completionHandler){
                                                    completionHandler(UIBackgroundFetchResultFailed);
                                                }
                                                return;
                                            }
                                            
                                            UILocalNotification *localNotif = [[UILocalNotification alloc] init];
                                            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                            NSDate *last_notification = (NSDate *)[defaults objectForKey:@"last_notification"];
                                            NSTimeInterval secondsBetween = 1000;
                                            float alert_price = [defaults floatForKey:@"alert_price"];

                                            if (last_notification != nil){
                                                secondsBetween = [[NSDate date] timeIntervalSinceDate:last_notification];
                                            }
                                            
                                            if (secondsBetween > 60 * 5 && [price floatValue] < alert_price){
                                                localNotif.alertBody = [NSString stringWithFormat:@"Price Alert: $%@", price];
                                                localNotif.alertAction = @"View";
                                                localNotif.soundName = UILocalNotificationDefaultSoundName;
                                                [defaults setObject:[NSDate date] forKey:@"last_notification"];
                                            }
                                            
                                            // Keep the icon badge up to date
                                            localNotif.applicationIconBadgeNumber = [price integerValue];
                                            [[UIApplication sharedApplication]presentLocalNotificationNow:localNotif];
                                            
                                            [defaults setObject:price forKey:@"last_price"];
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
    NSString *last_price = [[NSUserDefaults standardUserDefaults] stringForKey:@"last_price"];
    NSLog(@"Update current price lavel");
    
    if (last_price != nil){
        currentPriceLabel.text = [NSString stringWithFormat:@"$%@", last_price];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
