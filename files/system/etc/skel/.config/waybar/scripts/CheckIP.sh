#!/bin/bash

# Function to fetch and parse IP data
# Usage: fetch_ip "API_URL" "JQ_SELECTOR_IP" "JQ_SELECTOR_ISP" "JQ_SELECTOR_CC"
fetch_ip () {
    local url=$1
    local sel_ip=$2
galih@wayblue ~ ➜ cat Dotfiles/waybar/scripts/CheckIP.sh
#!/bin/bash

# Function to fetch and parse IP data
# Usage: fetch_ip "API_URL" "JQ_SELECTOR_IP" "JQ_SELECTOR_ISP" "JQ_SELECTOR_CC"
fetch_ip () {
    local url=$1
    local sel_ip=$2
    local sel_isp=$3
    local sel_cc=$4

    # 1. Run curl with a 5-second max time to ensure quick failover
    ipinfo=$(curl -sm 4 "$url")
    curl_status=$?

    # 2. Check for curl errors
    if [ $curl_status -ne 0 ]; then
        # Return failure (1) so the main loop knows to try the next API
        return 1 
    fi

    # 3. Parse the data using the provided jq selectors
    ip=$(echo "$ipinfo" | jq -r "$sel_ip")
    isp=$(echo "$ipinfo" | jq -r "$sel_isp")
    countryCode=$(echo "$ipinfo" | jq -r "$sel_cc")

    # --- MODIFICATION START ---
    # Check if ISP length is greater than 15
    if [ "${#isp}" -gt 15 ]; then
        # Take the first 15 chars and append "..."
        isp="${isp:0:15}..."
    fi
    # --- MODIFICATION END ---

    # 4. Validate IP format
    if [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        echo "$ip $isp ($countryCode)"
        return 0 # Success
    else
        return 1 # Invalid data, trigger failover
    fi
}

# --- Main Logic ---

# Attempt 1: ip-api.com (Primary - Fast, HTTP)
# Mapping: IP=.query, ISP=.isp OR .org, CC=.countryCode
if fetch_ip "http://ip-api.com/json/" ".query" ".isp // .org" ".countryCode"; then
    exit 0
fi

# Attempt 2: ipapi.co (Backup - HTTPS)
# Mapping: IP=.ip, ISP=.org, CC=.country_code
echo "Primary API failed. Switching to backup (ipapi.co)..." >&2

if fetch_ip "https://ipapi.co/json/" ".ip" ".org" ".country_code"; then
    exit 0
fi

# If we get here, both failed
echo "Error: All IP APIs failed."
exit 1
