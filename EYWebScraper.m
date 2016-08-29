// erkanyildiz
// 20160829-1555UTC+09
//
// EYWebScraper.m

#import "EYWebScraper.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface EYWebScraper ()
@property (nonatomic, strong) NSString* js;
@property (nonatomic, strong) UIWebView* web;
@property (nonatomic, strong) EYWebScraper* keeper;
@property (nonatomic, copy) void (^completion)(id result, NSError* error);
@end


@implementation EYWebScraper
+ (void)scrape:(NSString*)url usingGist:(NSString*)gist completion:(void (^)(id result, NSError* error))completion
{
    NSString* gistURL = [NSString stringWithFormat:@"https://gist.githubusercontent.com/%@/raw", gist];

    [[NSURLSession.sharedSession dataTaskWithURL:[NSURL URLWithString:gistURL] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
    {
        NSString* js = [NSString.alloc initWithData:data encoding:NSUTF8StringEncoding];

        if(error)
        {
            completion(nil, error);
        }
        else if (!js)
        {
            completion(nil, [NSError errorWithDomain:@"EYWebScraperErrorDomain" code:0 userInfo:@{NSLocalizedDescriptionKey:@"Invalid gist file content"}]);
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [EYWebScraper scrape:url usingJS:js completion:completion];
            });
        }
    }] resume];
}


+ (void)scrape:(NSString*)url usingJS:(NSString*)js completion:(void (^)(id result, NSError* error))completion
{
    EYWebScraper* ws = [EYWebScraper.alloc initWithURL:url JS:js completion:completion];
    ws.keeper = ws;
}


- (instancetype)initWithURL:(NSString*)url JS:(NSString*)js completion:(void (^)(id result, NSError* error))completion
{
    self = [super init];
    if (self)
    {
        self.js = js;
        self.completion = completion;
    
        self.web = [UIWebView.alloc initWithFrame:CGRectZero];
        self.web.delegate = self;
        self.web.hidden = YES;
        [self.web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    }
    
    return self;
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (webView.isLoading)
        return;
    
    NSString* result = [webView stringByEvaluatingJavaScriptFromString:self.js];
    self.completion(result, nil);
    self.keeper = nil;
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    self.completion(nil, error);
    self.keeper = nil;
}
@end