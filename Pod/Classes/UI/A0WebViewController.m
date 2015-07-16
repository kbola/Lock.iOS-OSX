//  A0WebViewController.m
//
// Copyright (c) 2014 Auth0 (http://auth0.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "A0WebViewController.h"
#import "A0Errors.h"
#import "A0Application.h"
#import "A0Strategy.h"
#import "A0APIClient.h"
#import "A0Token.h"
#import "A0WebAuthentication.h"
#import "NSDictionary+A0QueryParameters.h"
#import "A0AuthParameters.h"
#import "A0Lock.h"
#import "NSObject+A0APIClientProvider.h"
#import "A0Stats.h"
#import <libextobjc/EXTScope.h>

@interface A0WebViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIWebView *webview;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (strong, nonatomic) NSURL *authorizeURL;
@property (strong, nonatomic) A0WebAuthentication *authentication;
@property (copy, nonatomic) NSString *connectionName;

- (IBAction)cancel:(id)sender;

@end

@implementation A0WebViewController

AUTH0_DYNAMIC_LOGGER_METHODS

- (instancetype)init {
    return [self initWithNibName:NSStringFromClass(self.class) bundle:[NSBundle bundleForClass:self.class]];
}

- (instancetype)initWithApplication:(A0Application *)application
                     connectionName:(NSString *)connectionName
                         parameters:(A0AuthParameters *)parameters {
    self = [self init];
    if (self) {
        _authentication = [[A0WebAuthentication alloc] initWithClientId:application.identifier connectionName:connectionName];
        NSURLComponents *components = [[NSURLComponents alloc] initWithURL:application.authorizeURL resolvingAgainstBaseURL:NO];
        A0AuthParameters *authorizeParams = [A0AuthParameters newWithDictionary:@{
                                                                                    @"response_type": @"token",
                                                                                    @"client_id": application.identifier,
                                                                                    @"redirect_uri": _authentication.callbackURL.absoluteString,
                                                                                    }];
        if ([A0Stats shouldSendAuth0ClientHeader]) {
            parameters[A0ClientInfoQueryParamName] = [A0Stats stringForAuth0ClientHeader];
        }
        [authorizeParams addValuesFromParameters:parameters];
        authorizeParams[A0ParameterConnection] = connectionName;
        NSDictionary *payload = [authorizeParams asAPIPayload];
        components.query = payload.queryString;
        _authorizeURL = components.URL;
        _connectionName = connectionName;
    }
    return self;
}

- (instancetype)initWithApplication:(A0Application *)application strategy:(A0Strategy *)strategy parameters:(A0AuthParameters *)parameters {
    NSString *connectionName = [strategy.connections.firstObject name];
    return [self initWithApplication:application connectionName:connectionName parameters:parameters];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURLRequest *request = [NSURLRequest requestWithURL:self.authorizeURL];
    [self.webview loadRequest:request];
    [self.cancelButton setTitle:A0LocalizedString(@"CANCEL") forState:UIControlStateNormal];
}

- (void)cancel:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    if (self.onFailure) {
        self.onFailure([A0Errors auth0CancelledForConnectionName:self.connectionName]);
    }
    self.onFailure = nil;
    self.onAuthentication = nil;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    A0LogVerbose(@"About to load URL %@", request);
    BOOL isCallback = [self.authentication validateURL:request.URL];
    if (isCallback) {
        NSError *error;
        A0Token *token = [self.authentication tokenFromURL:request.URL error:&error];
        if (token) {
            void(^success)(A0UserProfile *, A0Token *) = self.onAuthentication;
            @weakify(self);
            A0APIClient *client = [self a0_apiClientFromProvider:self.lock];
            [client fetchUserProfileWithIdToken:token.idToken success:^(A0UserProfile *profile) {
                @strongify(self);
                self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                if (success) {
                    success(profile, token);
                }
            } failure:self.onFailure];
            [self.activityView startAnimating];
            self.activityView.hidden = NO;
        } else {
            if (self.onFailure) {
                self.onFailure(error);
            }
            [self.activityView stopAnimating];
        }
        self.onAuthentication = nil;
        self.onFailure = nil;
    }
    return !isCallback;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    A0LogVerbose(@"Loaded URL %@", webView.request);
    [self.activityView stopAnimating];
}

@end
