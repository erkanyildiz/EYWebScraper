// erkanyildiz
// 20160829-1555UTC+09
//
// EYWebScraper.h

#import <Foundation/Foundation.h>

@interface EYWebScraper : NSObject <UIWebViewDelegate>

/**
 * Scrapes contents of the target web page on given url, using JavaScript code in specified GitHub gist, and executes completion block with result object.
 * @discussion First fetches contents of specified GitHub gist's latest revision, to get JavaScript code to be used for scraping the target web page.
 * This is useful if layout of the target web page changes so often. When scraping code needs to be updated due to layout changes on the target web page, just updating the gist with the new JavaScript code is enough. No need to send an update to the App Store.
 * If gist is not available or its content is invalid, the completion block will be executed with the error object and result will be nil.
 * If gist is fetched successfully, target web page will be loaded into a dummy UIWebView, and JavaScript from the gist will be used for scaping when page loads completely.
 * If target web page cannot be loaded, the completion block will be executed with the error object and result will be nil.
 * If everything goes fine, the completion block will be executed with the result object and error will be nil.
 * @param url URL of the target web page to be scraped
 * @param gist GitHub gist in following format: username/gistid
 * @param completion Completion block to be executed when scraping is completed, either with result object or error.
 */
+ (void)scrape:(NSString*)url usingGist:(NSString*)gist completion:(void (^)(id result, NSError* error))completion;

/**
 * Scrapes contents of the target web page on given url using given JavaScript code, and executes completion block with result object.
 * @discussion Target web page will be loaded into a dummy UIWebView, and given JavaScript code will be used for scaping when page loads completely.
 * If target web page cannot be loaded, the completion block will be executed with the error object and result will be nil.
 * If everything goes fine, the completion block will be executed with the result object and error will be nil.
 * @param url URL of the target web page to be scraped
 * @param js JavaScript code to be used for scraping
 * @param completion Completion block to be executed when scraping is completed, either with result object or error.
 */
+ (void)scrape:(NSString*)url usingJS:(NSString*)js completion:(void (^)(id result, NSError* error))completion;
@end
