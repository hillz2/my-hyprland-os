#!/usr/bin/env python3

import requests
import locale
import os
import sys
import fcntl

# === Prevent multiple instances ===
LOCK_FILE = "/tmp/crypto_script.lock"

def acquire_lock():
    lock_file = open(LOCK_FILE, 'w')
    try:
        fcntl.flock(lock_file.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB)
        return lock_file
    except IOError:
        print("Another instance is already running.")
        sys.exit(1)

# === Set Indonesian locale for Rp formatting ===
try:
    locale.setlocale(locale.LC_ALL, 'id_ID.UTF-8')
except locale.Error:
    locale.setlocale(locale.LC_ALL, 'C')  # fallback

lock_file = acquire_lock()
output_strings = []

def format_currency(value):
    return locale.currency(value, grouping=True, symbol=False).split(',')[0]

def format_usd(value):
    return f"${value:,.2f}"

def ada(price):
    buy = 8213 # Total modal 124,885,060 IDR
    pct = round(100 * (price - buy) / buy, 2)
    return f"ADA {format_currency(price)} ({pct}%)"

def coti(price):
    buy = 8117 # Total modal 151,812,052 IDR
    pct = round(100 * (price - buy) / buy, 2)
    return f"COTI {format_currency(price)} ({pct}%)"

def btc(usd):
    return f"BTC {usd}"

# === BEST SOLUTION: Use CoinGecko (fast, reliable, never blocked in Indonesia) ===
try:
    url = "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd"
    resp = requests.get(url, timeout=8)
    resp.raise_for_status()
    btc_usd = resp.json()["bitcoin"]["usd"]
    output_strings.append(btc(format_usd(btc_usd)))
except Exception as e:
    print(f"CoinGecko failed: {e}", file=sys.stderr)
    output_strings.append("BTC Error")

# === Fetch Indodax prices ===
thisdict = {
    "BTC": "https://indodax.com/api/btc_idr/ticker",
    "ADA": "https://indodax.com/api/ada_idr/ticker",
    "COTI": "https://indodax.com/api/coti_idr/ticker"
}

for crypto, url in thisdict.items():
    try:
        r = requests.get(url, timeout=6)
        r.raise_for_status()
        price = int(r.json()["ticker"]["last"])

        if crypto == "ADA":
            output_strings.append(ada(price))
        elif crypto == "COTI":
            output_strings.append(coti(price))
        # BTC/IDR not shown, but you can uncomment next line if needed later
        # elif crypto == "BTC": print(f"BTC/IDR: {format_currency(price)}", file=sys.stderr)

    except Exception as e:
        if crypto in ["ADA", "COTI"]:
            output_strings.append(f"{crypto} Error")
        # else: ignore BTC error since we already have USD price

# === Final output and cleanup ===
try:
    print(" | ".join(output_strings))

finally:
    # === Cleanup ===
    try:
        lock_file.close()
        if os.path.exists(LOCK_FILE):
            os.remove(LOCK_FILE)
    except:
        pass
