// erkanyildiz
// 20180304-1945+0900
//
// EYWebScraper.m

#import "EYWebScraper.h"


NSErrorDomain const EYWebScraperErrorDomain = @"EYWebScraperErrorDomain";


@interface EYWebScraper ()

@property (nonatomic, copy) NSString* js;
@property (nonatomic, copy) UIWebView* web;
@property (nonatomic, copy) void (^completion)(NSString* result, NSError* error);
@property (nonatomic, strong) EYWebScraper* keeper;

@end


@implementation EYWebScraper

+ (void)scrape:(NSString *)URL usingGist:(NSString *)gist completion:(void (^)(NSString* result, NSError* error))completion
{
    if (!URL.length || !gist.length || !completion)
        return;

    NSString* gistURL = [NSString stringWithFormat:@"https://gist.githubusercontent.com/%@/raw", gist];

    [[NSURLSession.sharedSession dataTaskWithURL:[NSURL URLWithString:gistURL] completionHandler:^(NSData* data, NSURLResponse* response, NSError* error)
    {
        NSString* js = [NSString.alloc initWithData:data encoding:NSUTF8StringEncoding];

        onMainThread(^
        {
            if (error)
                completion(nil, error);
            else if (!js)
                completion(nil, [EYWebScraper error:EYWebScraperErrorInvalidGistContent]);
            else
                [EYWebScraper scrape:URL usingJS:js completion:completion];
        });
    }] resume];
}


+ (void)scrape:(NSString *)URL usingJS:(NSString *)js completion:(void (^)(NSString* result, NSError* error))completion
{
    if (!URL.length || !js.length || !completion)
        return;

    EYWebScraper* ws = EYWebScraper.new;
    NSString* wrapped = [NSString stringWithFormat:@"function EYWebScraperWrapperFunction(){%@} EYWebScraperWrapperFunction();", js];
    ws.js = wrapped;
    ws.completion = completion;

    ws.web = [UIWebView.alloc initWithFrame:CGRectZero];
    ws.web.hidden = YES;
    ws.web.delegate = ws;
    [ws.web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URL]]];

    ws.keeper = ws;
}

#pragma mark -


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (webView.isLoading)
        return;
    
    NSString* result = [webView stringByEvaluatingJavaScriptFromString:self.js];
    onMainThread(^
    {
        if (!result.length)
            self.completion(nil, [EYWebScraper error:EYWebScraperErrorJavaScriptEvaluationEmptyString]);
        else
            self.completion(result, nil);
    });

    self.keeper = nil;
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    onMainThread(^
    {
        self.completion(nil, error);
    });

    self.keeper = nil;
}


#pragma mark -


+ (NSError *)error:(NSInteger)errorCode
{
    NSMutableDictionary* userInfo = NSMutableDictionary.new;
    NSString* const kEYWebScraperErrorDescriptionKey = @"description";

    switch (errorCode)
    {
        case EYWebScraperErrorInvalidGistContent:
        {
            userInfo[kEYWebScraperErrorDescriptionKey] = @"Gist content is invalid.";
        }break;

        case EYWebScraperErrorJavaScriptEvaluationEmptyString:
        {
            userInfo[kEYWebScraperErrorDescriptionKey] = @"JavaScript evaluation result is empty string.";
        }break;
        
        default:
            userInfo = nil;
        break;
    }

    return [NSError errorWithDomain:EYWebScraperErrorDomain code:errorCode userInfo:userInfo.copy];
}


void onMainThread(void (^block)(void))
{
    dispatch_async(dispatch_get_main_queue(), block);
}

@end
