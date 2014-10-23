//
//  AppDelegate.m
//  LinkMapAnalyzer
//
//  Created by 张超 on 14-10-18.
//  Copyright (c) 2014年 张超. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *linkMapFileField;
@property (weak) IBOutlet NSButton *actionButton;
@property (weak) IBOutlet NSButton *startButton;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;

@property (strong) NSURL *currentLinkMapFileURL;
@property (strong) NSString *linkMapContent;

@property (strong) NSString *errorLog;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)chooseFile:(id)sender
{
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:NO];
    [panel setResolvesAliases:NO];
    [panel setCanChooseFiles:YES];
    
    [panel beginWithCompletionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            NSURL*  theDoc = [[panel URLs] objectAtIndex:0];
            NSLog(@"%@", theDoc);
            _linkMapFileField.stringValue = [theDoc path];
            self.currentLinkMapFileURL = theDoc;
        }
    }];
}

- (IBAction)start:(id)sender
{
    if (!_currentLinkMapFileURL || ![[NSFileManager defaultManager] fileExistsAtPath:[_currentLinkMapFileURL path] isDirectory:nil])
    {
        NSAlert *alert = [NSAlert alertWithMessageText:@"你他妈的在逗我!" defaultButton:@"是的" alternateButton:nil otherButton:nil informativeTextWithFormat:@"没找到LinkMap文件！！！"];
        [alert beginSheetModalForWindow:_window modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        self.linkMapContent = [NSString stringWithContentsOfURL:_currentLinkMapFileURL encoding:NSMacOSRomanStringEncoding error:&error];
        [_progressIndicator incrementBy:5];
        if ([self.linkMapContent rangeOfString:@"# Path:"].length <= 0)
        {
            self.errorLog = @"文件格式不正确!";
            return;
        }
        
        NSRange objsFileTagRange = [self.linkMapContent rangeOfString:@"# Object files:"];
        if (objsFileTagRange.location == NSNotFound)
        {
            self.errorLog = @"文件格式不正确!";
            return;
        }
        [_progressIndicator incrementBy:5];
        NSString *subObjsFileSymbolStr = [self.linkMapContent substringFromIndex:objsFileTagRange.location + objsFileTagRange.length];
        NSRange sectionsRange = [subObjsFileSymbolStr rangeOfString:@"# Sections:"];
        NSString *subObjsFileStr = [subObjsFileSymbolStr substringToIndex:sectionsRange.location];
        
        // 目标文件列表
        NSArray *objsFileLines = [subObjsFileStr componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
        NSRange symbolsRange = [subObjsFileSymbolStr rangeOfString:@"# Symbols:"];
        if (symbolsRange.location == NSNotFound)
        {
            self.errorLog = @"文件格式不正确!";
            return;
        }
        [_progressIndicator incrementBy:5];
        NSString *symbolsStr = [subObjsFileSymbolStr substringFromIndex:symbolsRange.location + symbolsRange.length];
        
        // 符号文件列表
        NSArray *symbolsLines = [symbolsStr componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
        [_progressIndicator incrementBy:5];
        
        for (NSString *objLine in objsFileLines)
        {
            if (objLine.length > 1)
            {
                
            }
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self recoverUI];
        });
    });
    [_actionButton setEnabled:NO];
    [_linkMapFileField setEnabled:NO];
    [_startButton setEnabled:NO];
    
    [_progressIndicator setStyle:NSProgressIndicatorBarStyle];
    [_progressIndicator setMinValue:0.00f];
    [_progressIndicator setMaxValue:100.00f];
    [_progressIndicator setIndeterminate:NO];
    [_progressIndicator setUsesThreadedAnimation:NO];
    
    [_progressIndicator setDoubleValue:0.0f];
    [_progressIndicator displayIfNeeded];
}


- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode == NSAlertFirstButtonReturn)
    {
        ;
    }
}

- (void)recoverUI
{
    [_actionButton setEnabled:YES];
    [_linkMapFileField setEnabled:YES];
    [_startButton setEnabled:YES];
}

@end
