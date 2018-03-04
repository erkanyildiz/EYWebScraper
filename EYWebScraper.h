// erkanyildiz
// 20180304-1945+0900
//
// EYWebScraper.h

#import <Foundation/Foundation.h>


extern NSErrorDomain const EYWebScraperErrorDomain;

NS_ENUM(NSInteger)
{
    EYWebScraperErrorInvalidGistContent = 1001,
    EYWebScraperErrorJavaScriptEvaluationEmptyString = 1002
};


@interface EYWebScraper : NSObject <UIWebViewDelegate>

/**
 * Scrapes the target web page on given URL, using JavaScript code in specified GitHub gist, and executes completion block with the result object.
 * @discussion It first fetches latest revision of specified GitHub gist to get JavaScript code to be used for scraping the target web page.
 * This is useful if layout of the target web page changes so often and scraping code needs to be updated due to these layout changes. Just updating the gist with the new JavaScript code for scraping is enough. No need to send an update to the App Store.
 * If gist is not available or its content is invalid, the completion block will be executed with the error object and the result will be nil.
 * If gist is fetched successfully, the target web page will be loaded into a dummy invisible UIWebView, and JavaScript from the gist will be used for scaping when the page loads completely.
 * If the target web page cannot be loaded, the completion block will be executed with the error object and the result will be nil.
 * If everything goes fine, the completion block will be executed with the result object and the error will be nil.
 * @param url URL of the target web page to be scraped
 * @param gist GitHub gist in following format: username/gistid
 * @param completion Completion block to be executed when scraping is completed, either with result object or error.
 */
+ (void)scrape:(NSString *)URL usingGist:(NSString *)gistID completion:(void (^)(NSString* result, NSError* error))completion;


/**
 * Scrapes the target web page on given URL, using given JavaScript code, and executes completion block with the result object.
 * @discussion Target web page will be loaded into a dummy invisible UIWebView, and given JavaScript code will be used for scraping when the page loads completely.
 * If the target web page cannot be loaded, the completion block will be executed with the error object and the result will be nil.
 * If everything goes fine, the completion block will be executed with the result object and the error will be nil.
 * @param url URL of the target web page to be scraped
 * @param js JavaScript code to be used for scraping
 * @param completion Completion block to be executed when scraping is completed, either with result object or error.
 */
+ (void)scrape:(NSString *)URL usingJS:(NSString*)js completion:(void (^)(NSString* result, NSError * error))completion;

@end
