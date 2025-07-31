# Wiki Submission Tool API Reference

This document provides technical details about the MediaWiki API endpoints used by the Wiki Submission Tool and how the tool interacts with them.

## MediaWiki API Overview

The Wiki Submission Tool communicates with MediaWiki-based wikis through their REST API endpoints. All communication is conducted over HTTPS for security.

## API Endpoints Used

### 1. Get Tokens

**Endpoint**: `action=query&meta=tokens`

**Purpose**: Retrieve authentication tokens required for login and editing operations.

**Parameters**:
- `action=query`: Specifies the query action
- `meta=tokens`: Requests token metadata
- `type=login|csrf`: Specifies token types (login for authentication, csrf for editing)
- `format=json`: Requests JSON response format

**Example Request**:
```
POST /api.php HTTP/1.1
Host: wiki.archlinux.org
Content-Type: application/x-www-form-urlencoded

action=query&meta=tokens&type=login&format=json
```

**Example Response**:
```json
{
  "batchcomplete": "",
  "query": {
    "tokens": {
      "logintoken": "abc123+\\"
    }
  }
}
```

### 2. Login

**Endpoint**: `action=login`

**Purpose**: Authenticate user credentials with the wiki.

**Parameters**:
- `action=login`: Specifies the login action
- `lgname=username`: User's login name
- `lgpassword=password`: User's password
- `lgtoken=token`: Login token obtained from the tokens endpoint
- `format=json`: Requests JSON response format

**Example Request**:
```
POST /api.php HTTP/1.1
Host: wiki.archlinux.org
Content-Type: application/x-www-form-urlencoded

action=login&lgname=MyUsername&lgpassword=MyPassword&lgtoken=abc123%2B%5C&format=json
```

**Example Response (Success)**:
```json
{
  "login": {
    "result": "Success",
    "lguserid": 12345,
    "lgusername": "MyUsername"
  }
}
```

**Example Response (Failure)**:
```json
{
  "login": {
    "result": "Failed",
    "reason": "Incorrect username or password"
  }
}
```

### 3. Edit Page

**Endpoint**: `action=edit`

**Purpose**: Create or modify wiki pages.

**Parameters**:
- `action=edit`: Specifies the edit action
- `title=pagename`: Title of the page to edit
- `text=content`: Content to add to the page
- `summary=summary`: Edit summary
- `token=token`: CSRF token for authentication
- `bot=1`: Indicates this is a bot edit (optional)
- `format=json`: Requests JSON response format

**Example Request**:
```
POST /api.php HTTP/1.1
Host: wiki.archlinux.org
Content-Type: application/x-www-form-urlencoded

action=edit&title=My%20Page&text=Page%20content%20here&summary=Adding%20content&token=def456%2B%5C&bot=1&format=json
```

**Example Response (Success)**:
```json
{
  "edit": {
    "result": "Success",
    "pageid": 67890,
    "title": "My Page",
    "contentmodel": "wikitext",
    "oldrevid": 123456,
    "newrevid": 123457,
    "newtimestamp": "2025-07-31T00:00:00Z"
  }
}
```

**Example Response (Failure)**:
```json
{
  "error": {
    "code": "badtoken",
    "info": "Invalid CSRF token"
  }
}
```

## Authentication Flow

The Wiki Submission Tool follows a specific authentication flow:

### Step 1: Get Login Token
1. Send request to `action=query&meta=tokens&type=login`
2. Extract `logintoken` from response

### Step 2: Authenticate
1. Send request to `action=login` with username, password, and login token
2. Verify response indicates successful authentication

### Step 3: Get CSRF Token
1. Send request to `action=query&meta=tokens&type=csrf`
2. Extract `csrftoken` from response

### Step 4: Edit Page
1. Send request to `action=edit` with page content, summary, and CSRF token
2. Verify response indicates successful edit

## Cookie Management

The tool manages cookies to maintain session state:

### Session Cookies
- Stored in temporary files with process ID-based names
- Automatically cleared after script execution
- Used to maintain authentication state between requests

### Cookie Security
- File permissions set to restrict access
- Files stored in `/tmp` directory
- Unique filenames prevent conflicts

## Error Handling

The tool handles various API errors:

### Authentication Errors
- `WrongToken`: Invalid or expired token - automatically retries with fresh token
- `Failed`: Authentication failure - reports error to user
- `Aborted`: Login process interrupted - reports error to user

### Edit Errors
- `badtoken`: Invalid CSRF token - automatically retries with fresh token
- `maxlag`: Wiki server lag - implements exponential backoff
- `spamdetected`: Content flagged as spam - reports error to user
- `abusefilter`: Content blocked by abuse filter - reports error to user

### Network Errors
- Connection timeouts - implements exponential backoff
- SSL certificate errors - reports error to user
- DNS resolution failures - reports error to user

## Rate Limiting

The tool respects wiki rate limits:

### Automatic Delays
- Implements exponential backoff for retry attempts
- Waits before retrying failed requests
- Reduces request frequency during high-load periods

### Retry Logic
1. First retry: 1 second delay
2. Second retry: 2 second delay
3. Third retry: 4 second delay

## Security Considerations

### Credential Protection
- Credentials never stored in files or logs
- Password input hidden during entry
- Memory immediately cleared after use
- Process isolation through temporary files

### Communication Security
- All requests use HTTPS
- SSL certificate validation enabled
- User agent identification provided
- Request timeouts configured

### Data Integrity
- Content URL-encoded to prevent injection
- Response validation to prevent parsing errors
- Error logging without sensitive data
- Atomic operations where possible

## HTTP Headers

The tool sends standard HTTP headers:

### User Agent
```
User-Agent: WikiSecureBot/1.0 (Generic Wiki Submission Tool)
```

### Content Type
```
Content-Type: application/x-www-form-urlencoded
```

### Accept Encoding
```
Accept-Encoding: gzip, deflate
```

## Response Processing

The tool processes API responses:

### JSON Parsing
- Validates JSON structure
- Extracts relevant data fields
- Handles parsing errors gracefully

### Error Detection
- Checks for error objects in responses
- Maps error codes to user-friendly messages
- Implements appropriate recovery actions

## Session Management

The tool manages wiki sessions:

### Login State
- Tracks authentication status
- Maintains session cookies
- Validates session before operations

### Token Validity
- Tracks token expiration
- Refreshes tokens when needed
- Handles token invalidation gracefully

## Supported MediaWiki Versions

The tool is compatible with MediaWiki versions that support:

### Required API Features
- Modern authentication API
- CSRF token system
- Edit action with bot parameter
- JSON response format

### Tested Versions
- MediaWiki 1.35+
- Compatible with latest MediaWiki releases

## Extension Compatibility

The tool works with wikis that have:

### Standard Extensions
- No special extensions required for basic functionality
- Compatible with common MediaWiki extensions
- Handles extension-specific errors gracefully

### Abuse Protection
- Works with AbuseFilter extension
- Compatible with SpamBlacklist extension
- Respects rate limiting extensions

## Internationalization

The tool supports international wikis:

### Character Encoding
- UTF-8 encoding for all content
- Proper URL encoding for special characters
- Unicode support in page titles and content

### Language Support
- Works with wikis in any language
- No hardcoded language dependencies
- Proper handling of localized error messages

## Performance Considerations

The tool optimizes performance:

### Request Efficiency
- Minimizes number of API requests
- Combines operations where possible
- Uses appropriate request timeouts

### Resource Management
- Limits memory usage
- Efficient file handling
- Proper cleanup of temporary resources

## Debugging Features

The tool provides debugging capabilities:

### Logging
- Detailed operation logging
- Error condition recording
- Performance metrics collection

### Verbose Output
- Configurable verbosity levels
- Detailed error reporting
- Operation progress indication

## Compliance

The tool follows MediaWiki API best practices:

### API Usage
- Complies with API terms of service
- Respects rate limits and quotas
- Follows recommended authentication patterns

### Security Standards
- Implements secure credential handling
- Follows secure communication practices
- Complies with privacy regulations