// erkanyildiz
// 20170523-0015+0900
//
// EYWebScraper.m

#import "EYWebScraper.h"


NSErrorDomain const EYWebScraperErrorDomain = @"EYWebScraperErrorDomain";


@interface EYWebScraper ()

@property (nonatomic, strong) NSString* js;
@property (nonatomic, strong) UIWebView* web;
@property (nonatomic, strong) EYWebScraper* keeper;
@property (nonatomic, copy) void (^completion)(id result, NSError * error);

@end


@implementation EYWebScraper

+ (void)scrape:(NSString *)URL usingGist:(NSString *)gist completion:(void (^)(id result, NSError* error))completion
{
    if(!completion)
        return;

    NSString* gistURL = [NSString stringWithFormat:@"https://gist.githubusercontent.com/%@/raw", gist];

    [[NSURLSession.sharedSession dataTaskWithURL:[NSURL URLWithString:gistURL] completionHandler:^(NSData* data, NSURLResponse* response, NSError* error)
    {
        NSString* js = [NSString.alloc initWithData:data encoding:NSUTF8StringEncoding];

        if(error)
        {
            completion(nil, error);
        }
        else if (!js)
        {
            completion(nil, [EYWebScraper error:EYWebScraperErrorInvalidGistContent]);
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [EYWebScraper scrape:URL usingJS:js completion:completion];
            });
        }
    }] resume];
}


+ (void)scrape:(NSString *)URL usingJS:(NSString *)js completion:(void (^)(id result, NSError * error))completion
{
    if(!completion)
        return;

    EYWebScraper* ws = [EYWebScraper.alloc initWithURL:URL JS:js completion:completion];
    ws.keeper = ws;
}


- (instancetype)initWithURL:(NSString *)URL JS:(NSString *)js completion:(void (^)(id result, NSError * error))completion
{
    self = [super init];
    if (self)
    {
        NSString* wrapped = [NSString stringWithFormat:@"function EYWebScraperWrapperFunction(){%@} EYWebScraperWrapperFunction();", js];
        self.js = wrapped;
        self.completion = completion;
    
        self.web = [UIWebView.alloc initWithFrame:CGRectZero];
        self.web.delegate = self;
        self.web.hidden = YES;
        [self.web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URL]]];
    }
    
    return self;
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
    if(!result.length)
        self.completion(nil, [EYWebScraper error:EYWebScraperErrorJavaScriptEvaluationEmptyString]);
    else
        self.completion(result, nil);

    self.keeper = nil;
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    self.completion(nil, error);
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

    return [NSError errorWithDomain:EYWebScraperErrorDomain code:errorCode userInfo:userInfo];
}


-(void)dealloc
{
    NSLog(@"dealloc %p", self);
}
@end
