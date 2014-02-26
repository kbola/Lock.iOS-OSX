## Usage

1. Git clone and reference the library in your project

	```bash
	git clone git@github.com:auth0/Auth0.iOS.git
	```

	1. Go to your project 
	2. Right-click in the Frameworks folder and select ___Add Files to "Your Project Name"___
	3. Go to the Auth0.iOS, select the __Auth0Client__ folder, ensure that your project target is selected and press __Add__

2. Instantiate Auth0Client

	```Objective-c
	#import "Auth0Client.h"
	
	// ...
	
	Auth0Client *client = [Auth0Client auth0Client:@"YOUR_AUTH0_DOMAIN" clientId:@"YOUR_CLIENT_ID"];
	```

3. Trigger login (with Widget) 

	```Objective-c
	[client loginAsync:self withCompletionHandler:^(BOOL authenticated) {
	    if (!authenticated) {
	        NSLog(@"Error authenticating");
	    }
	    else{            
	        // * Use client.auth0User to do wonderful things, e.g.:
			// - get user email => [client.auth0User.Profile objectForKey:@"email"]
			// - get facebook/google/twitter/etc access token => [[[client.auth0User.Profile objectForKey:@"identities"] objectAtIndex:0] objectForKey:@"access_token"]
			// - get Windows Azure AD groups => [client.auth0User.Profile objectForKey:@"groups"]
			// - etc.
	    }
	}];
	```

	![](http://puu.sh/4nZfX.png)

Or you can use the connection as a parameter (e.g. here we login with a Windows Azure AD account)

```Objective-c
[client loginAsync:self connection:@"auth0waadtests.onmicrosoft.com" withCompletionHandler:^(BOOL authenticated) { ... }];
```

## Login with User/Password (without WebView)

Only certain providers support this option (Datbaase Connections, AD Connector and ADFS)..

```Objective-c
[client loginAsync:self connection:@"my-db-connection" 
						username:@"username"
						password:@"password"
						withCompletionHandler:^(BOOL authenticated) { ... }];
```

> Optionally you can specify the `scope` parameter. There are two possible values for scope today:
* scope:@"openid" (default) - It will return, not only the access_token, but also an id_token which is a Json Web Token (JWT). The JWT will only contain the user id.
* scope:@"openid profile": If you want the entire user profile to be part of the id_token.

### Delegation Token Request

You can obtain a delegation token specifying the ID of the target client (`targetClientId`) and, optionally, an NSMutableDictionary object (`options`) in order to include custom parameters like scope or id_token:

```Objective-c
NSMutableDictionary *options = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
	@"USER_ID_TOKEN", @"id_token", 	// default: id_token of the authenticated user (client.auth0User.IdToken)
	@"openid profile", @"scope", 	// default: openid
	nil];

[client getDelegationToken:targetClientId options:options withCompletionHandler:^(NSMutableDictionary* delegationResult)
{
	// [delegationResult objectForKey:@"id_token"]
}];
```

---

## What is Auth0?

Auth0 helps you to:

* Add authentication with [multiple authentication sources](https://docs.auth0.com/identityproviders), either social like **Google, Facebook, Microsoft Account, LinkedIn, GitHub, Twitter**, or enterprise identity systems like **Windows Azure AD, Google Apps, AD, ADFS or any SAML Identity Provider**. 
* Add authentication through more traditional **[username/password databases](https://docs.auth0.com/mysql-connection-tutorial)**.
* Add support for **[linking different user accounts](https://docs.auth0.com/link-accounts)** with the same user.
* Support for generating signed [Json Web Tokens](https://docs.auth0.com/jwt) to call your APIs and **flow the user identity** securely.
* Analytics of how, when and where users are logging in.
* Pull data from other sources and add it to the user profile, through [JavaScript rules](https://docs.auth0.com/rules).

## Create a free account in Auth0

1. Go to [Auth0](http://developers.auth0.com) and click Sign Up.
2. Use Google, GitHub or Microsoft Account to login.
