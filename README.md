# EYWebScaper
An helper for scraping contents of web pages using hardcoded or GitHub gist hosted JavaScript code.

GitHub gist is useful if scraping code needs to be updated due to often layout changes on the target web page. Just updating the gist with the new JavaScript code is enough, no need to send an update to the App Store.

#Usage

- With GitHub gist:  (example gist [erkanyildiz/1b58dc431407093dfd7a2437a9563c68](https://gist.github.com/erkanyildiz/1b58dc431407093dfd7a2437a9563c68))

```
//Specify GitHub gist that contains JavaScript code to be used for scraping in `username/gistid` format.

NSString* gist = @"erkanyildiz/1b58dc431407093dfd7a2437a9563c68";

[EYWebScraper scrape:@"https://example.com" usingGist:gist completion:^(id result, NSError *error)
{
    if(!error)
        NSLog(@"Result: %@",[result description]);
    else
        NSLog(@"Error: %@",[error description]);
}];
    
```
    
- With Hardcoded JavaScript:
```
//Or specify hardcoded JavaScript code

NSString* script = @"function scrape(){return document.getElementsByTagName('a')[0].href;} scrape();";

[EYWebScraper scrape:@"https://www.example.com" usingJS:script completion:^(id result, NSError *error)
{
    if(!error)
        NSLog(@"Result: %@",[result description]);
    else
        NSLog(@"Error: %@",[error description]);
}];
```
