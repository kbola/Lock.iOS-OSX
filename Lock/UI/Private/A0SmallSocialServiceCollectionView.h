// A0SmallSocialServiceCollectionView.h
//
// Copyright (c) 2015 Auth0 (http://auth0.com)
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

#import <UIKit/UIKit.h>

@class A0SmallSocialServiceCollectionView, A0UserProfile, A0Token, A0LockConfiguration, A0AuthParameters, A0Lock;

@protocol A0SmallSocialServiceCollectionViewDelegate <NSObject>

- (void)socialServiceCollectionView:(A0SmallSocialServiceCollectionView *)collectionView
              presentViewController:(UIViewController *)controller;

- (void)socialServiceCollectionView:(A0SmallSocialServiceCollectionView *)collectionView
     didAuthenticateUserWithProfile:(A0UserProfile *)profile
                              token:(A0Token *)token;

- (void)socialServiceCollectionView:(A0SmallSocialServiceCollectionView *)collectionView
                   didFailWithError:(NSError *)error;

- (void)authenticationDidStartForSocialCollectionView:(A0SmallSocialServiceCollectionView *)collectionView;

- (void)authenticationDidEndForSocialCollectionView:(A0SmallSocialServiceCollectionView *)collectionView;

@end

@interface A0SmallSocialServiceCollectionView : UICollectionView

@property (weak, nonatomic) id<A0SmallSocialServiceCollectionViewDelegate> authenticationDelegate;
@property (strong, nonatomic) A0AuthParameters *parameters;
@property (strong, nonatomic) A0Lock *lock;

- (void)triggerFacebook;

- (void)showSocialServicesForConfiguration:(A0LockConfiguration *)configuration;

@end
