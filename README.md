# EYWebScaper
An helper for scraping contents of web pages using hardcoded or GitHub gist hosted JavaScript code.

GitHub gist is useful if scraping code needs to be updated due to often layout changes on the target web page. Just updating the gist with the new JavaScript code is enough, no need to send an update to the App Store.

#Usage

```
//Specify GitHub gist that contains JavaScript code to be used for scraping in `username/gistid` format.

[EYWebScraper scrape:@"https://example.com" usingGist:@"erkanyildiz/1b58dc431407093dfd7a2437a9563c68" completion:^(id result, NSError *error)
{
    if(error)
        NSLog(@"Error: %@",[error description]);
    else
        NSLog(@"Result: %@",[result description]);
}];
    

//Or specify hardcoded JavaScript code

NSString* script = @"function scrape(){return document.getElementsByTagName('a')[0].href;} scrape();";

[EYWebScraper scrape:@"https://www.example.com" usingJS:script completion:^(id result, NSError *error)
{
    if(error)
        NSLog(@"Error: %@",[error description]);
    else
        NSLog(@"Result: %@",[result description]);
}];
```
