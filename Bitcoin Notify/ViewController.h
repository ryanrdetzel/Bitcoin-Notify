//
//  ViewController.h
//  Bitcoin Notify
//
//  Created by Ryan Detzel on 3/5/14.
//  Copyright (c) 2014 Ryan Detzel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITextFieldDelegate>
@property (nonatomic) IBOutlet UILabel *currentPriceLabel;
@property (nonatomic) IBOutlet UITextField *alertPrice;

-(void)updatePriceWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;
@end
