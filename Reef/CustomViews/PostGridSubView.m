//
//  PostGridSubView.m
//  Reef
//
//  Created by iOSDevStar on 12/25/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import "PostGridSubView.h"
#import "Global.h"

@implementation PostGridSubView

- (void)awakeFromNib {
    self.m_bSelected = false;
}

- (IBAction)actionRefresh:(id)sender {
    [self downloadResourceFromServer];
}

- (void) downloadResourceFromServer
{
    self.m_progressView.hidden = NO;
    self.m_btnRefresh.hidden = YES;
    self.m_btnShowFullScreen.enabled = NO;

    NSURL *URL = [NSURL URLWithString:self.m_strResourceURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *fileName = [URL lastPathComponent];
    self.m_strResourceLocalPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    
    NSData *resourceData = [NSData dataWithContentsOfFile:self.m_strResourceLocalPath];
    if (resourceData)
    {
        self.m_progressView.hidden = YES;
        self.m_btnShowFullScreen.enabled = YES;

        if ([[self.m_strResourceLocalPath lowercaseString] rangeOfString:@"png"].location != NSNotFound || [[self.m_strResourceLocalPath lowercaseString] rangeOfString:@"jpg"].location != NSNotFound)
        {
            self.m_postImageView.image = [UIImage imageWithContentsOfFile:self.m_strResourceLocalPath];
        }
        else
        {
        }
        
        resourceData = nil;
    }
    else
    {
        AFHTTPRequestOperation *downloadRequest = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        [downloadRequest setDownloadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToRead) {
            float progress = totalBytesWritten / (float)totalBytesExpectedToRead * 100.f;
            self.m_progressView.elapsedTime = progress;
        }];
        
        [downloadRequest setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"file downloaded");
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{ // 1
                __block NSData *data = [[NSData alloc] initWithData:responseObject];
                dispatch_async(dispatch_get_main_queue(), ^{ // 2
                    [data writeToFile:self.m_strResourceLocalPath atomically:YES];
                    
                    self.m_progressView.hidden = YES;
                    self.m_btnShowFullScreen.enabled = YES;

                    if ([[self.m_strResourceLocalPath lowercaseString] rangeOfString:@"png"].location != NSNotFound || [[self.m_strResourceLocalPath lowercaseString] rangeOfString:@"jpg"].location != NSNotFound)
                    {
                        self.m_postImageView.image = [UIImage imageWithContentsOfFile:self.m_strResourceLocalPath];
                    }
                    else
                    {
                    }
                    
                    data = nil;
                });
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"file downloading error : %@", [error localizedDescription]);
            self.m_progressView.hidden = YES;
            self.m_btnRefresh.hidden = NO;
        }];
        [downloadRequest start];
    }
}

- (IBAction)actionShowFullScreen:(id)sender {
    self.m_bSelected = !self.m_bSelected;
    
    if (self.delegate)
        [self.delegate actionShowFullScreenInGridView:self withIndex:self.m_nIndex];
}

@end
