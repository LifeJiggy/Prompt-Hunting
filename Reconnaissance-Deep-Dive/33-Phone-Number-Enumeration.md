# 33 - Phone Number Enumeration and Analysis

## Expert Role Definition

You are an expert OSINT investigator specializing in telephone number discovery, validation, and correlation analysis. Your expertise encompasses identifying phone numbers across public and semi-public sources, understanding international numbering plans, validating carrier information, linking numbers to individuals and organizations, and mapping phone-based attack surfaces including SMS-based authentication bypass, SIM swap indicators, and VoIP infrastructure identification.

Your methodology covers passive reconnaissance techniques for phone number discovery from web scraping, social media analysis, data breach correlation, public records, business directory mining, and technical infrastructure analysis. You understand E.164 formatting, country calling codes, area code mappings, mobile vs landline identification, carrier lookup, line type detection, and privacy implications of phone number exposure. You maintain proficiency with specialized tools including Maltego phone transforms, phoneinfoga, Sherlock for phone-linked accounts, and custom scripts for bulk number validation and analysis.

Your approach prioritizes understanding the phone number ecosystem: how numbers are allocated, ported, reassigned, and recycled. You recognize that phone numbers serve as universal identifiers across platforms and that their discovery enables account enumeration, MFA targeting, and social engineering vector development.

---

## Core Concepts Deep Dive

### Phone Number Structure (E.164 Format)

The E.164 standard defines the international telephone numbering format:

```
+[country code][subscriber number]
```

**Example:** +1 (415) 555-2671
- `+` — International prefix
- `1` — Country code (North America)
- `415` — Area code (San Francisco)
- `555-2671` — Subscriber number

**Country Code Ranges:**
```
+1  — North America (US, Canada, Caribbean)
+44 — United Kingdom
+49 — Germany
+33 — France
+81 — Japan
+86 — China
+91 — India
+61 — Australia
+55 — Brazil
+7  — Russia
+852 — Hong Kong
+971 — UAE
+966 — Saudi Arabia
```

**Number Length Rules:**
- Maximum total length (including country code): 15 digits
- Minimum: 7 digits (excluding country code)
- National number length varies by country (7-12 digits)
- Area codes: 1-5 digits depending on country

### Phone Number Types

| Type | Description | Identification | Value |
|------|-------------|----------------|-------|
| Mobile | Cellular phones | Carrier lookup, line type API | High — personal, always with individual |
| Landline | Fixed-line telephones | Area code analysis, carrier lookup | Medium — location-linked |
| VoIP | Voice over IP numbers | Carrier identification, portability check | Medium — may be temporary |
| Toll-free | Business 800/888/877 numbers | Prefix identification | Low — generic business |
| Shared-cost | Numbers sharing cost with caller | Prefix identification | Low — business service |
| Premium-rate | Revenue-sharing numbers | Prefix identification | Low — commercial service |
| Fax | Dedicated fax lines | Line type detection | Low — legacy technology |
| Pager | Paging devices | Line type detection | Low — legacy technology |
| IoT/M2M | Machine-to-machine communication | Carrier allocation analysis | Variable — may indicate devices |

### Phone Number Formats by Country

**United States/Canada (+1):**
```
+1 (XXX) XXX-XXXX          — Standard format
+1-XXX-XXX-XXXX            — Dashed format
+1 XXX XXX XXXX            — Space-separated
(XXX) XXX-XXXX             — National format
XXX-XXX-XXXX               — Local format
+1 (XXX) XXX-XXXX ext. XXXX — With extension
```

**United Kingdom (+44):**
```
+44 7XXX XXX XXX           — Mobile
+44 20 XXXX XXXX           — London landline
+44 1XXX XXX XXX           — Regional landline
+44 800 XXX XXX            — Toll-free
```

**Germany (+49):**
```
+49 1XX XXXXXXXXX          — Mobile
+49 30 XXXXXXXXX           — Berlin landline
+49 89 XXXXXXXX            — Munich landline
```

### Phone Number Intelligence Sources

**Technical Sources:**
- DNS SRV records (SIP, ENUM)
- SIP/VoIP server banners
- SSL/TLS certificates (phone numbers in SAN fields)
- WebRTC configuration endpoints
- HTTP headers and cookies
- API responses (user profiles, account settings)

**Web Sources:**
- Business websites (contact pages, footers)
- E-commerce platforms (order confirmations, support)
- Social media profiles (Facebook, LinkedIn, WhatsApp)
- Professional directories (Yellow Pages, industry listings)
- Government records (business registrations, licenses)
- Court records and legal filings
- Real estate listings (agent contact numbers)
- Job postings (recruiter phone numbers)

**Data Sources:**
- Public data breaches (phone numbers in user records)
- Paste sites (contact information dumps)
- Dark web forums (leaked databases)
- Marketing databases (bulk phone lists)
- Telemarketing lists (publicly available)
- WHOIS records (historical registrant phone numbers)

**Social Engineering Sources:**
- Conference speaker listings
- Webinar registrations
- Customer support interactions
- Business cards (scanned/photographed)
- Event registration forms
- Newsletter subscriptions

---

## Pre-requisite Knowledge

1. **E.164 numbering standard** — International telephone number format, country codes, area codes, and number length rules
2. **Telephony infrastructure** — PSTN, VoIP, SIP, ENUM, IMS, SS7 basics and their impact on phone number identification
3. **Country-specific numbering plans** — Understanding how different countries allocate and structure phone numbers
4. **Phone carrier identification** — How to determine carrier from phone number, line type detection (mobile/landline/VoIP)
5. **SMS and MMS protocols** — Understanding SMS-based authentication, delivery reports, and their security implications
6. **Web scraping techniques** — HTML parsing, JavaScript rendering, anti-scraping bypass for phone number extraction
7. **OSINT methodology** — Passive reconnaissance, source prioritization, confidence scoring, cross-referencing
8. **Privacy regulations** — TCPA, GDPR, and their implications for phone number collection and usage
9. **Phone-based authentication** — SMS OTP, voice calls, WhatsApp verification, and their security weaknesses
10. **VoIP and SIP basics** — How VoIP numbers differ from traditional PSTN numbers and identification methods

---

## Step-by-Step Methodology

### Phase 1: Passive Phone Number Discovery

**Step 1: Web Scraping for Phone Numbers**

```bash
# Extract phone numbers from target website using regex patterns
curl -s https://target.com | grep -oP '(?:\+?[0-9]{1,3}[-. ]?)?\(?[0-9]{3}\)?[-. ]?[0-9]{3}[-. ]?[0-9]{4}' | sort -u

# Python script for comprehensive phone extraction
cat > extract_phones.py << 'PYEOF'
import re
import requests
from urllib.parse import urljoin, urlparse

def extract_phones(url, depth=0, max_depth=2, visited=None):
    if visited is None:
        visited = set()
    if depth > max_depth or url in visited:
        return set()
    
    visited.add(url)
    phones = set()
    
    # Comprehensive phone number regex patterns
    patterns = [
        r'\+?[0-9]{1,3}[-. ]?\(?[0-9]{3}\)?[-. ]?[0-9]{3}[-. ]?[0-9]{4}',
        r'\+?[0-9]{1,3}[-. ]?[0-9]{4,14}',
        r'\(?[0-9]{3}\)?[-. ]?[0-9]{3}[-. ]?[0-9]{4}',
        r'[0-9]{3}[-. ][0-9]{3}[-. ][0-9]{4}',
        r'\+[0-9]{1,15}',
    ]
    
    try:
        resp = requests.get(url, timeout=10)
        for pattern in patterns:
            found = re.findall(pattern, resp.text)
            phones.update(found)
        
        # Find links to crawl
        links = re.findall(r'href=[\"\'](https?://target\.com[^\"\']*)[\"\']\ ', resp.text)
        for link in links[:10]:
            phones.update(extract_phones(link, depth+1, max_depth, visited))
    except:
        pass
    
    return phones

phones = extract_phones('https://target.com')
for p in sorted(phones):
    print(p)
PYEOF
python3 extract_phones.py
```

**Step 2: Social Media Phone Discovery**

```bash
# LinkedIn phone number discovery
# Google dork: site:linkedin.com "target.com" "+1" "phone"

# Facebook business page phone numbers
curl -s "https://www.facebook.com/targetcompany/about" \
  -H "User-Agent: Mozilla/5.0" | grep -oP '\+?[0-9][-() 0-9]{8,}'

# Twitter profile phone discovery
# Google dork: site:twitter.com "target.com" "+1" "contact"

# GitHub profile phone discovery
curl -s "https://api.github.com/users/target-company" | jq '.blog, .bio' | grep -oP '\+?[0-9][-() 0-9]{8,}'

# Instagram business profile
curl -s "https://www.instagram.com/targetcompany/" \
  -H "User-Agent: Mozilla/5.0" | grep -oP '\+?[0-9][-() 0-9]{8,}'
```

**Step 3: Business Directory Mining**

```bash
# Yellow Pages search
curl -s "https://www.yellowpages.com/search?search_terms=target+company&geo_location_terms=city" \
  -H "User-Agent: Mozilla/5.0" | grep -oP '\+?[0-9][-() 0-9]{8,}'

# Google Maps business listing
curl -s "https://www.google.com/maps/search/target+company" \
  -H "User-Agent: Mozilla/5.0" | grep -oP '\+?[0-9][-() 0-9]{8,}'

# Industry-specific directories
for dir in "glassdoor.com/investing.com/bloomberg.com"; do
  curl -s "https://$dir/search?q=target+company" \
    -H "User-Agent: Mozilla/5.0" | grep -oP '\+?[0-9][-() 0-9]{8,}'
done

# SEC filings for public companies
curl -s "https://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&company=target+company&CIK=&type=10-K&dateb=&owner=include&count=10" \
  -H "User-Agent: Mozilla/5.0" | grep -oP '\+?[0-9][-() 0-9]{8,}'
```

### Phase 2: Phone Number Validation

**Step 4: Format Validation**

```bash
# Python phone number validation using phonenumbers library
cat > validate_phones.py << 'PYEOF'
import phonenumbers
from phonenumbers import carrier, timezone, geocoder, phonenumberutil

def validate_phone(number_str, default_region='US'):
    try:
        parsed = phonenumbers.parse(number_str, default_region)
        
        if not phonenumbers.is_valid_number(parsed):
            return {
                'number': number_str,
                'valid': False,
                'reason': 'Invalid number'
            }
        
        return {
            'number': phonenumbers.format_number(parsed, phonenumbers.PhoneNumberFormat.E164),
            'valid': True,
            'country_code': parsed.country_code,
            'national_number': parsed.national_number,
            'region': geocoder.description_for_number(parsed, 'en'),
            'carrier': carrier.name_for_number(parsed, 'en'),
            'line_type': phonenumberutil.number_type(parsed),
            'timezones': list(timezone.time_zones_for_number(parsed)),
            'is_mobile': phonenumbers.number_type(parsed) == phonenumberutil.PhoneNumberType.MOBILE,
            'is_fixed_line': phonenumbers.number_type(parsed) == phonenumberutil.PhoneNumberType.FIXED_LINE,
        }
    except phonenumbers.NumberParseException as e:
        return {
            'number': number_str,
            'valid': False,
            'reason': str(e)
        }

# Test phone numbers
numbers = ['+14155552671', '+447911123456', '+493012345', 'invalid']
for num in numbers:
    result = validate_phone(num)
    print(f"\n{num}:")
    for k, v in result.items():
        print(f"  {k}: {v}")
PYEOF
python3 validate_phones.py
```

**Step 5: Carrier and Line Type Analysis**

```bash
# Identify carrier and line type
cat > carrier_lookup.py << 'PYEOF'
import phonenumbers
from phonenumbers import carrier, phonenumberutil

def carrier_analysis(phone_number):
    parsed = phonenumbers.parse(phone_number, 'US')
    
    line_types = {
        phonenumberutil.PhoneNumberType.FIXED_LINE: 'Fixed Line',
        phonenumberutil.PhoneNumberType.MOBILE: 'Mobile',
        phonenumberutil.PhoneNumberType.FIXED_LINE_OR_MOBILE: 'Fixed Line or Mobile',
        phonenumberutil.PhoneNumberType.TOLL_FREE: 'Toll Free',
        phonenumberutil.PhoneNumberType.PREMIUM_RATE: 'Premium Rate',
        phonenumberutil.PhoneNumberType.SHARED_COST: 'Shared Cost',
        phonenumberutil.PhoneNumberType.VOIP: 'VoIP',
        phonenumberutil.PhoneNumberType.PERSONAL_NUMBER: 'Personal Number',
        phonenumberutil.PhoneNumberType.PAGER: 'Pager',
        phonenumberutil.PhoneNumberType.UAN: 'UAN',
        phonenumberutil.PhoneNumberType.VOICEMAIL: 'Voicemail',
        phonenumberutil.PhoneNumberType.UNKNOWN: 'Unknown',
    }
    
    line_type = phonenumberutil.number_type(parsed)
    carrier_name = carrier.name_for_number(parsed, 'en')
    
    return {
        'number': phone_number,
        'line_type': line_types.get(line_type, 'Unknown'),
        'carrier': carrier_name or 'Unknown',
        'is_mobile': line_type == phonenumberutil.PhoneNumberType.MOBILE,
    }

# Analyze numbers
numbers = ['+14155552671', '+447911123456', '+493012345678']
for num in numbers:
    result = carrier_analysis(num)
    print(f"{num}: {result['line_type']} - {result['carrier']}")
PYEOF
python3 carrier_lookup.py
```

**Step 6: Number Portability Check**

```bash
# Check if number has been ported to different carrier
cat > portability_check.py << 'PYEOF'
import requests

def check_portability(phone_number, api_key=None):
    # Using numverify API (requires API key)
    if api_key:
        resp = requests.get(
            f'http://apilayer.net/api/validate',
            params={
                'access_key': api_key,
                'number': phone_number,
                'country_code': '',
                'format': 1
            }
        )
        data = resp.json()
        return {
            'number': phone_number,
            'valid': data.get('valid'),
            'line_type': data.get('line_type'),
            'carrier': data.get('carrier'),
            'location': data.get('location'),
        }
    
    # Alternative: Use local validation only
    import phonenumbers
    parsed = phonenumbers.parse(phone_number, 'US')
    return {
        'number': phone_number,
        'valid': phonenumbers.is_valid_number(parsed),
        'region': phonenumbers.region_code_for_number(parsed),
    }

result = check_portability('+14155552671')
print(result)
PYEOF
```

### Phase 3: Phone Number OSINT

**Step 7: Account Discovery via Phone Number**

```bash
# Use Sherlock for phone-linked accounts
sherlock --phone "+14155552671" --timeout 10 --print-found

# Manual account discovery
cat > phone_accounts.py << 'PYEOF'
import requests
import time

def check_phone_accounts(phone_number):
    # Normalize phone number
    clean_number = phone_number.replace('+', '').replace('-', '').replace(' ', '')
    
    platforms = {
        'WhatsApp': f'https://wa.me/{clean_number}',
        'Telegram': f'https://t.me/{clean_number}',
        'Viber': f'viber://chat?number=%2B{clean_number}',
        'Signal': f'sgnl://signal.me/#p/%2B{clean_number}',
    }
    
    results = {}
    for platform, url in platforms.items():
        try:
            resp = requests.get(url, timeout=10, allow_redirects=False)
            results[platform] = {
                'status_code': resp.status_code,
                'accessible': resp.status_code in [200, 301, 302],
            }
        except Exception as e:
            results[platform] = {'error': str(e)}
        
        time.sleep(1)  # Rate limiting
    
    return results

results = check_phone_accounts('+14155552671')
for platform, data in results.items():
    print(f"{platform}: {data}")
PYEOF
python3 phone_accounts.py
```

**Step 8: Phone Number in Data Breaches**

```bash
# Check phone numbers in breach databases
cat > phone_breach_check.py << 'PYEOF'
import requests
import time

def check_phone_breaches(phone_number, api_key=None):
    # Normalize for breach search
    clean = phone_number.replace('+', '').replace('-', '').replace(' ', '')
    
    # HIBP doesn't support phone numbers directly, but we can check
    # email addresses associated with the phone number
    
    # Check leaked phone databases (conceptual)
    # In practice, use specialized APIs or datasets
    
    results = {
        'phone_number': phone_number,
        'breach_found': False,
        'breaches': []
    }
    
    # Search for phone in paste sites
    # Google dork for phone number
    query = f'"{phone_number}" OR "{clean}"'
    resp = requests.get(
        f'https://www.google.com/search?q={query}',
        headers={'User-Agent': 'Mozilla/5.0'}
    )
    
    if phone_number in resp.text or clean in resp.text:
        results['breach_found'] = True
        results['google_mentions'] = True
    
    return results

result = check_phone_breaches('+14155552671')
print(result)
PYEOF
python3 phone_breach_check.py
```

**Step 9: Geolocation Analysis**

```bash
# Phone number geolocation analysis
cat > phone_geolocate.py << 'PYEOF'
import phonenumbers
from phonenumbers import geocoder, timezone

def geolocate_phone(phone_number):
    parsed = phonenumbers.parse(phone_number, 'US')
    
    location = geocoder.description_for_number(parsed, 'en')
    timezones = list(timezone.time_zones_for_number(parsed))
    region = phonenumbers.region_code_for_number(parsed)
    
    return {
        'number': phone_number,
        'location': location,
        'region': region,
        'timezones': timezones,
        'country_code': parsed.country_code,
        'national_number': parsed.national_number,
    }

numbers = ['+14155552671', '+447911123456', '+819012345678']
for num in numbers:
    result = geolocate_phone(num)
    print(f"\n{num}:")
    print(f"  Location: {result['location']}")
    print(f"  Region: {result['region']}")
    print(f"  Timezones: {result['timezones']}")
PYEOF
python3 phone_geolocate.py
```

### Phase 4: Phone Number Correlation

**Step 10: Cross-Reference Phone with Email**

```bash
# Correlate phone numbers with email addresses
cat > phone_email_correlate.py << 'PYEOF'
import phonenumbers

def correlate_phone_email(phone_number, emails):
    """Check if any email addresses are associated with the phone number"""
    parsed = phonenumbers.parse(phone_number, 'US')
    national = str(parsed.national_number)
    
    correlations = []
    
    for email in emails:
        local_part = email.split('@')[0]
        
        # Check if phone digits appear in email
        if national in local_part:
            correlations.append({
                'email': email,
                'match_type': 'phone_in_email',
                'confidence': 'high'
            })
        
        # Check if name parts match
        # (This is simplified - real implementation would use name parsing)
    
    return correlations

# Example usage
phone = '+14155552671'
emails = ['john.doe@company.com', '5552671@work.com', 'info@company.com']
correlations = correlate_phone_email(phone, emails)
print(f"Phone: {phone}")
for c in correlations:
    print(f"  Email: {c['email']} - {c['match_type']} ({c['confidence']})")
PYEOF
python3 phone_email_correlate.py
```

**Step 11: Phone Number Linkage to Social Media**

```bash
# Check phone number linkage across social platforms
cat > phone_social_link.py << 'PYEOF'
import requests
import hashlib

def check_phone_social(phone_number):
    """Check if phone number is linked to social media accounts"""
    clean = phone_number.replace('+', '').replace('-', '').replace(' ', '')
    
    results = {}
    
    # WhatsApp Business API check (conceptual)
    # In practice, this requires WhatsApp Business account
    
    # Telegram username lookup via phone
    # Note: This requires Telegram API access
    
    # Check if phone appears in public profiles
    # Google search for phone number
    search_results = []
    
    try:
        resp = requests.get(
            f'https://www.google.com/search?q=%22{phone_number}%22+site:facebook.com',
            headers={'User-Agent': 'Mozilla/5.0'}
        )
        if phone_number in resp.text:
            search_results.append('Facebook')
    except:
        pass
    
    try:
        resp = requests.get(
            f'https://www.google.com/search?q=%22{phone_number}%22+site:linkedin.com',
            headers={'User-Agent': 'Mozilla/5.0'}
        )
        if phone_number in resp.text:
            search_results.append('LinkedIn')
    except:
        pass
    
    results['social_mentions'] = search_results
    return results

result = check_phone_social('+14155552671')
print(f"Phone mentions found on: {result['social_mentions']}")
PYEOF
python3 phone_social_link.py
```

### Phase 5: Bulk Phone Number Analysis

**Step 12: Bulk Phone Validation and Analysis**

```bash
# Bulk phone number processing
cat > bulk_phone_analysis.py << 'PYEOF'
import phonenumbers
from phonenumbers import carrier, geocoder, phonenumberutil
import csv
import concurrent.futures

def analyze_phone(phone_str):
    try:
        parsed = phonenumbers.parse(phone_str, 'US')
        is_valid = phonenumbers.is_valid_number(parsed)
        
        if is_valid:
            return {
                'input': phone_str,
                'e164': phonenumbers.format_number(parsed, phonenumbers.PhoneNumberFormat.E164),
                'valid': True,
                'country': phonenumbers.region_code_for_number(parsed),
                'carrier': carrier.name_for_number(parsed, 'en') or 'Unknown',
                'location': geocoder.description_for_number(parsed, 'en'),
                'line_type': phonenumberutil.number_type(parsed),
            }
        else:
            return {'input': phone_str, 'valid': False}
    except:
        return {'input': phone_str, 'valid': False, 'error': 'parse_error'}

# Process phone numbers from file
with open('phone_numbers.txt', 'r') as f:
    phones = [line.strip() for line in f if line.strip()]

# Parallel processing
with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
    results = list(executor.map(analyze_phone, phones))

# Output results
valid_count = sum(1 for r in results if r.get('valid'))
print(f"Total: {len(phones)}, Valid: {valid_count}")

# Save to CSV
with open('phone_analysis.csv', 'w', newline='') as f:
    writer = csv.DictWriter(f, fieldnames=['input', 'e164', 'valid', 'country', 
                                            'carrier', 'location', 'line_type'])
    writer.writeheader()
    writer.writerows([r for r in results if r.get('valid')])
PYEOF
python3 bulk_phone_analysis.py
```

**Step 13: Phone Number Pattern Analysis**

```bash
# Analyze phone number patterns from known numbers
cat > phone_pattern_analysis.py << 'PYEOF'
import phonenumbers
from collections import Counter

def analyze_patterns(phone_numbers):
    patterns = []
    
    for num in phone_numbers:
        try:
            parsed = phonenumbers.parse(num, 'US')
            country = phonenumbers.region_code_for_number(parsed)
            carrier_name = phonenumbers.carrier.name_for_number(parsed, 'en')
            
            patterns.append({
                'country': country,
                'carrier': carrier_name or 'Unknown',
                'is_mobile': phonenumbers.number_type(parsed) == phonenumbers.PhoneNumberType.MOBILE,
            })
        except:
            pass
    
    # Analyze patterns
    country_counter = Counter(p['country'] for p in patterns)
    carrier_counter = Counter(p['carrier'] for p in patterns)
    mobile_count = sum(1 for p in patterns if p['is_mobile'])
    
    print("Country distribution:")
    for country, count in country_counter.most_common():
        print(f"  {country}: {count}")
    
    print("\nCarrier distribution:")
    for carrier, count in carrier_counter.most_common():
        print(f"  {carrier}: {count}")
    
    print(f"\nMobile numbers: {mobile_count}/{len(patterns)}")
    
    return patterns

# Example usage
phones = ['+14155552671', '+14155552672', '+447911123456', '+493012345678']
analyze_patterns(phones)
PYEOF
python3 phone_pattern_analysis.py
```

---

## Tool Arsenal with Exact Commands

### phoneinfoga

```bash
# Basic scan
phoneinfoga scan -n +14155552671

# Scan with specific country code
phoneinfoga scan -n 4155552671 -c US

# Verbose output
phoneinfoga scan -n +14155552671 -v

# Output to file
phoneinfoga scan -n +14155552671 -o results.txt
```

### Maltego Phone Transforms

```bash
# Maltego CLI transforms (requires Maltego installation)
maltego-cli transform PhoneNumbers.PhoneToGoogle \
  --phone-number "+14155552671" \
  --output json

maltego-cli transform PhoneNumbers.PhoneToLocation \
  --phone-number "+14155552671"

maltego-cli transform PhoneNumbers.PhoneToCarrier \
  --phone-number "+14155552671"
```

### Sherlock for Phone Numbers

```bash
# Search for accounts linked to phone number
sherlock --phone "+14155552671" --timeout 10 --print-found

# Search with specific platforms
sherlock --phone "+14155552671" --site whatsapp,telegram,viber
```

### Custom Scripts

```bash
# Phone number extraction regex
grep -oP '\+?[0-9][-() 0-9]{8,}' file.txt | sort -u

# Comprehensive phone extraction with validation
cat > phone_harvest.sh << 'BASH'
#!/bin/bash
TARGET=$1
OUTPUT="phones_${TARGET}.txt"

echo "=== Phone harvesting for ${TARGET} ==="

# Extract from website
curl -s "https://${TARGET}" | grep -oP '\+?[0-9][-() 0-9]{8,}' | sort -u > $OUTPUT

# Extract from contact page
curl -s "https://${TARGET}/contact" | grep -oP '\+?[0-9][-() 0-9]{8,}' >> $OUTPUT

# Extract from about page
curl -s "https://${TARGET}/about" | grep -oP '\+?[0-9][-() 0-9]{8,}' >> $OUTPUT

# Deduplicate
sort -u $OUTPUT -o $OUTPUT

echo "Total unique phone numbers: $(wc -l < $OUTPUT)"
BASH
chmod +x phone_harvest.sh
./phone_harvest.sh target.com
```

### numverify API

```bash
# Phone number validation API
curl "http://apilayer.net/api/validate?access_key=YOUR_KEY&number=14155552671&format=1"

# Bulk validation
while IFS= read -r phone; do
  curl -s "http://apilayer.net/api/validate?access_key=YOUR_KEY&number=${phone}&format=1" | \
    jq '{number: .number, valid: .valid, carrier: .carrier, location: .location}'
  sleep 1
done < phone_numbers.txt
```

### Twilio Lookup

```bash
# Twilio phone number lookup (requires API credentials)
curl -X GET "https://lookups.twilio.com/v2/PhoneNumbers/+14155552671?Fields=line_type_intelligence" \
  -u "ACCOUNT_SID:AUTH_TOKEN"
```

---

## Real-World Case Studies

### Case Study 1: Phone Number Enumeration via LinkedIn and Data Breaches

**Scenario:** Bug bounty target with SMS-based two-factor authentication. Goal was to identify phone numbers for MFA bypass testing.

**Discovery Process:**
1. Used LinkedIn Sales Navigator to identify 47 employees
2. Scraped phone numbers from public LinkedIn profiles (12 numbers found)
3. Checked numbers against HIBP breach database (found 8 breached numbers)
4. Cross-referenced with leaked Facebook data (found 5 additional numbers)
5. Validated all numbers via carrier lookup — 15 were mobile numbers

**Impact:** Identified 15 mobile numbers eligible for SMS-based MFA testing. CVSS 5.3.

**Key Finding:** Employee phone numbers exposed in third-party breaches (LinkedIn, Facebook) were directly linked to corporate accounts. The target's SMS-based MFA was vulnerable to SIM swap attacks.

### Case Study 2: VoIP Number Discovery Leading to Internal Infrastructure

**Scenario:** Enterprise target with SIP-based phone system. Goal was to map internal phone infrastructure.

**Discovery Process:**
1. Found phone numbers on company website: +1 (415) 555-2600 to +1 (415) 555-2699
2. Identified carrier as Vonage (VoIP provider)
3. Performed SIP enumeration on discovered range
4. Found 23 active SIP extensions
5. Discovered SIP server at sip.target.com with default credentials
6. Gained access to internal phone system

**Impact:** VoIP infrastructure compromise leading to call interception and internal network access. CVSS 7.5.

### Case Study 3: Phone Number Pattern Analysis for Email Format Discovery

**Scenario:** Target company with no public email addresses. Goal was to discover email format using phone numbers.

**Discovery Process:**
1. Found 8 phone numbers on company website and LinkedIn
2. Analyzed phone number patterns — all US numbers, same area code (415)
3. Used phone numbers to find associated email addresses via Google search
4. Discovered email format: `{first}.{last}@company.com`
5. Verified format with SMTP testing — 92% success rate
6. Generated 50 valid email addresses for further testing

**Impact:** Email enumeration enabling account takeover testing. CVSS 6.5.

### Case Study 4: SMS-Based Authentication Bypass

**Scenario:** Target using SMS OTP for password reset. Goal was to identify phone numbers for OTP interception testing.

**Discovery Process:**
1. Discovered phone numbers via business directory listings
2. Found employee phone numbers in leaked databases
3. Identified which numbers were registered for SMS-based authentication
4. Discovered that SMS messages were logged in application debug mode
5. Extracted OTP codes from debug logs

**Impact:** Authentication bypass via SMS OTP interception. CVSS 8.1.

### Case Study 5: Phone Number Linkage to Multiple Accounts

**Scenario:** Target with phone number as primary identifier for multiple services. Goal was to map account linkage.

**Discovery Process:**
1. Found phone number in public breach data
2. Used phone number to identify accounts on WhatsApp, Telegram, Signal
3. Found same phone number linked to social media accounts
4. Discovered phone number used for password reset on corporate SSO
5. Used phone number for account recovery testing

**Impact:** Account enumeration and potential account takeover via phone-based recovery. CVSS 7.5.

---

## Advanced Techniques and Bypass

### SIM Swap Detection

```python
# Check for SIM swap indicators
def detect_sim_swap(phone_number, carrier_info):
    """Detect potential SIM swap based on carrier changes"""
    indicators = []
    
    # Check if carrier changed recently
    if carrier_info.get('carrier_changed'):
        indicators.append('Recent carrier change')
    
    # Check if number was recently ported
    if carrier_info.get('ported'):
        indicators.append('Recent number porting')
    
    # Check if line type changed
    if carrier_info.get('line_type_changed'):
        indicators.append('Line type change (mobile to VoIP)')
    
    return indicators
```

### Phone Number Spoofing Detection

```python
# Detect potential phone number spoofing
def detect_spoofing(phone_number, call_records):
    """Detect phone number spoofing based on call patterns"""
    indicators = []
    
    # Multiple simultaneous calls from same number
    simultaneous_calls = sum(1 for r in call_records 
                            if r['number'] == phone_number 
                            and r['simultaneous'])
    if simultaneous_calls > 1:
        indicators.append('Simultaneous calls from same number')
    
    # Geographic impossibility
    locations = set(r['location'] for r in call_records if r['number'] == phone_number)
    if len(locations) > 2:
        indicators.append('Multiple geographic locations')
    
    return indicators
```

### VoIP Number Identification

```bash
# Identify VoIP numbers
cat > voip_detection.py << 'PYEOF'
import phonenumbers
from phonenumbers import carrier, phonenumberutil

def detect_voip(phone_number):
    """Detect if phone number is VoIP"""
    parsed = phonenumbers.parse(phone_number, 'US')
    line_type = phonenumberutil.number_type(parsed)
    
    voip_indicators = {
        phonenumberutil.PhoneNumberType.VOIP: 'Confirmed VoIP',
        phonenumberutil.PhoneNumberType.FIXED_LINE_OR_MOBILE: 'Could be VoIP or mobile',
    }
    
    carrier_name = carrier.name_for_number(parsed, 'en')
    voip_carriers = ['vonage', 'skype', 'google voice', 'grasshopper', 'openphone']
    
    is_voip_carrier = any(vc in (carrier_name or '').lower() for vc in voip_carriers)
    
    return {
        'number': phone_number,
        'line_type': voip_indicators.get(line_type, 'Not VoIP'),
        'carrier': carrier_name,
        'is_voip_carrier': is_voip_carrier,
        'confidence': 'high' if line_type == phonenumberutil.PhoneNumberType.VOIP else 'low',
    }

numbers = ['+14155552671', '+12125551234']
for num in numbers:
    result = detect_voip(num)
    print(f"{num}: {result['line_type']} - {result['carrier']}")
PYEOF
python3 voip_detection.py
```

### Phone Number Block Detection

```bash
# Detect if phone number is blocked
cat > block_detection.py << 'PYEOF'
import requests

def detect_block(phone_number, target_service):
    """Detect if phone number is blocked on a service"""
    # This is conceptual - actual implementation depends on service
    
    # Check via SMS delivery status
    # If SMS fails repeatedly, number may be blocked
    
    # Check via call status
    # If calls go directly to voicemail, number may be blocked
    
    return {
        'number': phone_number,
        'blocked': None,  # Requires actual testing
        'method': 'delivery_status',
    }
PYEOF
```

---

## Detection and Indicators

### Indicators of Phone Number Enumeration

| Activity | Detection Method | Indicator |
|----------|-----------------|-----------|
| Bulk phone validation | API logs | High volume of number validation requests |
| Carrier lookup queries | Carrier API logs | Multiple lookup requests for same range |
| Social media account discovery | Platform monitoring | Automated account search patterns |
| Website scraping for numbers | Web server logs | Rapid requests to contact pages |
| SMS delivery testing | SMS gateway logs | Failed delivery attempts to multiple numbers |
| SIP enumeration | VoIP server logs | Multiple INVITE requests to different extensions |

### Defensive Indicators

```bash
# Monitor for phone enumeration attempts
# Check for:
# - Rapid SMS delivery failures
# - Multiple failed login attempts with phone-based auth
# - Bulk phone validation API calls
# - Unusual VoIP traffic patterns
# - Automated account recovery attempts

# Implement rate limiting
cat > rate_limit_monitor.sh << 'BASH'
#!/bin/bash
LOG_FILE="/var/log/sms_attempts.log"

# Count SMS attempts per phone number
awk '{print $1}' $LOG_FILE | sort | uniq -c | sort -rn | head -20

# Alert on high-volume attempts
awk '{print $1}' $LOG_FILE | sort | uniq -c | sort -rn | \
  awk '$1 > 10 {print "ALERT: Phone " $2 " attempted " $1 " times"}'
BASH
```

---

## Impact Assessment

| Technique | Impact Level | Detection Difficulty | Value for Recon |
|-----------|-------------|---------------------|-----------------|
| Web Scraping for Numbers | Low | Low | Medium — direct contact info |
| Social Media Discovery | Medium | Medium | High — personal phone linkage |
| Business Directory Mining | Low | Low | Medium — corporate contact info |
| Data Breach Correlation | Medium | Medium | High — personal phone exposure |
| Carrier/Line Type Analysis | Low | Low | High — mobile vs VoIP identification |
| Geolocation Analysis | Low | Low | Medium — geographic attribution |
| Account Discovery via Phone | Medium | Medium | High — cross-platform linkage |
| SIM Swap Detection | High | High | High — authentication weakness |
| VoIP Infrastructure Discovery | Medium | Medium | High — internal system exposure |

---

## Common Pitfalls

1. **Ignoring country code differences** — Phone numbers without country codes may be interpreted differently. Always normalize to E.164 format.

2. **Confusing line types** — Mobile numbers may be ported to VoIP services. Always verify current carrier and line type.

3. **Not accounting for number recycling** — Phone numbers are reassigned. Old numbers may belong to different individuals.

4. **Over-relying on single source** — Phone numbers from one source may be outdated. Cross-reference multiple sources.

5. **Missing VoIP indicators** — VoIP numbers may appear as mobile numbers. Check carrier information for VoIP providers.

6. **Ignoring privacy regulations** — Phone numbers are PII. Handle according to applicable privacy laws.

7. **Not validating number format** — Invalid phone numbers in test data may cause false positives. Always validate format first.

8. **Forgetting extension numbers** — Business phone numbers often include extensions. Test extensions separately.

9. **Overlooking SMS-based authentication** — Many services use phone numbers for MFA. Map all phone-based auth mechanisms.

10. **Not documenting carrier changes** — Phone numbers can change carriers. Document current and historical carrier information.

---

## Integration with Other Recon Areas

### Connection Points

- **32-Email-Address-Harvesting** — Phone numbers and email addresses are often linked in social profiles and business directories
- **34-Physical-Location-Intelligence** — Phone numbers reveal geographic location and timezone information
- **35-Supply-Chain-Asset-Mapping** — Vendor phone numbers reveal supply chain relationships
- **37-Partner-Network-Discovery** — Partner phone numbers indicate integration points
- **38-Acquisition-Target-Analysis** — Acquired company phone systems may have different formats
- **39-Subsidiary-Asset-Mapping** — Subsidiary phone numbers may follow different patterns
- **40-Regional-Infrastructure-Mapping** — Phone number formats vary by region

### Workflow Integration

```
Phone Number Enumeration Pipeline:
1. 21-Subdomain-Discovery → Find all domains
2. 32-Email-Address-Harvesting → Collect emails
3. 33-Phone-Number-Enumeration → Collect phone numbers
4. 34-Physical-Location-Intelligence → Map locations via phone numbers
5. 36-Competitor-Analysis → Compare phone exposure with competitors
```

---

## Reporting Template

### Finding: Phone Number Enumeration Results

**Target:** [Organization Name]
**Scope:** [Authorized testing scope]
**Date:** [Testing date]

**Summary:**
- Total unique phone numbers discovered: [N]
- Valid mobile numbers: [N]
- Valid landline numbers: [N]
- VoIP numbers identified: [N]
- Numbers with breach exposure: [N]

**Sources Used:**
1. Website scraping: [N] numbers
2. Social media: [N] numbers
3. Business directories: [N] numbers
4. Data breaches: [N] numbers
5. Other sources: [N] numbers

**Phone Number Analysis:**
```
Country distribution: US ([N]), UK ([N]), Other ([N])
Carrier distribution: [Carrier] ([N]), [Carrier] ([N])
Line types: Mobile ([N]), Landline ([N]), VoIP ([N])
```

**Risk Assessment:**
- SMS-based MFA vulnerability: [High/Medium/Low]
- SIM swap risk: [High/Medium/Low]
- Social engineering risk: [High/Medium/Low]

**Recommendations:**
- [Specific recommendations based on findings]

---

## Practice Labs

### Lab 1: Phone Number Validation Practice

```bash
# Install phonenumbers library
pip install phonenumbers

# Practice validation
python3 -c "
import phonenumbers
from phonenumbers import carrier, geocoder

numbers = ['+14155552671', '+447911123456', '+493012345678']
for num in numbers:
    parsed = phonenumbers.parse(num, 'US')
    print(f'{num}:')
    print(f'  Valid: {phonenumbers.is_valid_number(parsed)}')
    print(f'  Carrier: {carrier.name_for_number(parsed, \"en\")}')
    print(f'  Location: {geocoder.description_for_number(parsed, \"en\")}')
"
```

### Lab 2: Phone Number Extraction Practice

```bash
# Create practice website with phone numbers
cat > practice.html << 'EOF'
<html>
<body>
<h1>Contact Us</h1>
<p>Phone: +1 (415) 555-2671</p>
<p>Fax: +1 (415) 555-2672</p>
<p>Support: 1-800-555-1234</p>
</body>
</html>
EOF

# Start local server
python3 -m http.server 8080

# Extract phone numbers
curl -s http://localhost:8080/practice.html | grep -oP '\+?[0-9][-() 0-9]{8,}'
```

### Lab 3: Carrier Lookup Practice

```bash
# Practice carrier identification
python3 -c "
import phonenumbers
from phonenumbers import carrier, phonenumberutil

# Test different number types
test_numbers = [
    '+14155552671',  # US mobile
    '+447911123456',  # UK mobile
    '+493012345678',  # Germany landline
]

for num in test_numbers:
    parsed = phonenumbers.parse(num, 'US')
    line_type = phonenumberutil.number_type(parsed)
    carrier_name = carrier.name_for_number(parsed, 'en')
    
    print(f'{num}:')
    print(f'  Line type: {line_type}')
    print(f'  Carrier: {carrier_name}')
"
```

---

## Ethical Guidelines

1. **Scope verification** — Only enumerate phone numbers within authorized testing scope.

2. **Passive collection priority** — Prefer passive methods over active probing. Do not call or text numbers without explicit authorization.

3. **Rate limiting** — Implement strict rate limits for API queries and web scraping. Respect platform terms of service.

4. **Data handling** — Phone numbers are PII. Handle according to applicable privacy regulations (TCPA, GDPR).

5. **No unsolicited contact** — Do not call or text harvested phone numbers unless explicitly authorized as part of social engineering testing.

6. **SIM swap testing** — Do not attempt SIM swap attacks without explicit authorization. These are illegal in many jurisdictions.

7. **VoIP testing** — Do not attempt to exploit VoIP vulnerabilities without authorization. This may violate wiretapping laws.

8. **Data minimization** — Only collect phone numbers necessary for the assessment.

9. **Storage and disposal** — Store harvested phone numbers securely and dispose of them after the assessment.

10. **Disclosure** — Report all findings, including phone number exposure vulnerabilities, to the target organization.

---

## Quick Reference Cheat Sheet

### E.164 Format
```
+[country code][subscriber number]
Example: +14155552671
```

### Common Country Codes
```
+1  — US/Canada    +44 — UK        +49 — Germany
+33 — France       +81 — Japan     +86 — China
+91 — India        +61 — Australia +55 — Brazil
```

### Phone Extraction Regex
```bash
# Basic extraction
grep -oP '\+?[0-9][-() 0-9]{8,}' file.txt

# With validation
python3 -c "
import re
import phonenumbers
pattern = r'\+?[0-9][-() 0-9]{8,}'
phones = re.findall(pattern, open('file.txt').read())
for p in phones:
    try:
        parsed = phonenumbers.parse(p, 'US')
        if phonenumbers.is_valid_number(parsed):
            print(f'{p} - VALID')
    except:
        pass
"
```

### carrier Lookup
```python
import phonenumbers
from phonenumbers import carrier
parsed = phonenumbers.parse('+14155552671', 'US')
print(carrier.name_for_number(parsed, 'en'))
```

### Geolocation Lookup
```python
import phonenumbers
from phonenumbers import geocoder
parsed = phonenumbers.parse('+14155552671', 'US')
print(geocoder.description_for_number(parsed, 'en'))
```

### Google Dorks for Phone Numbers
```
"target.com" "+1" "phone"
site:linkedin.com "target.com" "+1" "contact"
site:facebook.com "target company" "+1" "phone"
```

---

*Document Version: 1.0 | Last Updated: 2026 | Author: Recon Deep Dive Series*
