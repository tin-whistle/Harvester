# Harvester

A Swift interface to the Harvest time tracking API

## Harvest API

See the [Harvest API V2 Documentation](https://help.getharvest.com/api-v2/) to learn how the Harvest REST API is structured.

## Using Harvester

### Integration

Harvester is distributed as a [Swift package](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app). The repository URL is https://github.com/tin-whistle/Harvester.git

### Authentication

[Authentication](https://help.getharvest.com/api-v2/authentication-api/authentication/authentication/) is done using either the [OAuth 2 standard](https://tools.ietf.org/html/rfc6749) or a Personal Access Token. Requests to the Harvest API must include an access token from one of these sources. The Harvester example project uses the Personal Access Token scheme, but you may choose to use an OAuth library or write your own implementation. The only requirement is that your implementation must conform to the [AuthorizationProvider](Sources/Harvester/Authorization/AuthorizationProvider.swift) protocol which supports authorization, deauthorization, and provides an access token.

#### OAuth

Any app which wishes to use OAuth with the Harvest API must first be [registered](https://id.getharvest.com/developers) with Harvest (requires a Harvest account).
1. Once logged in, chose [Create New OAuth2 Application](https://id.getharvest.com/oauth2/clients/new).
2. Fill in the app **Name**.
3. Fill in the **Redirect URL**.
    - Harvest API only supports standard HTTP or HTTPS redirect URLs. Therefore, your app must support [Universal Links using an associated domain](https://developer.apple.com/library/archive/documentation/General/Conceptual/AppSearch/UniversalLinks.html).
4. Set **Multi Account** to **_I need access to one account_**.
5. Set **Products** to **_I want access to Harvest_**.
6. Choose **Create Application**.
7. Use the **Client ID** and **Client Secret** values generated on this page with your OAuth library or custom implementation.

#### Personal Access Token

Personal access tokens can be generated on the [Harvest developers web page](https://id.getharvest.com/developers). (requires a Harvest account).
1. Once logged in, chose [Create New Personal Access Token](https://id.getharvest.com/oauth2/access_tokens/new).
2. Fill in the access token **Name**.
3. Choose **Create Personal Access Token**.
7. Use the **Your Token** value generated on this page to authorize all requests to the Harvest API. This will only work for requests to your own account.

### Configuration

[HarvestAPI](Sources/Harvester/HarvestAPI.swift) is the main point of contact with the Harvester library. It is initialized with a [HarvestAPIConfiguration](Sources/Harvester/HarvestAPIConfiguration.swift) containing the following properties:
1. **appName** - The name of your app. This is sent to Harvest as part of a user agent string. It is used to identify which app a request came from.
2. **contactEmail** - The email address which Harvest should use to contact you with questions or comments. This is sent to Harvest as part of a user agent string.
3. **authorizationProvider** - Your AuthorizationProvider implementation (see Authentication section above).
