# VPN Troubleshooting Guide

## Symptoms
- VPN client fails to connect
- Connection drops after a few minutes
- "Authentication failed" error
- Slow speeds after connecting

## Step-by-Step Resolution

### 1. Check your internet connection
Before blaming the VPN, verify you have internet access without it. Open a browser and navigate to an external site.

### 2. Restart the VPN client
Close the VPN application completely (check the system tray), wait 10 seconds, and reopen it.

### 3. Try a different VPN server
TechCorp has VPN endpoints in three regions: `vpn-us.techcorp.internal`, `vpn-eu.techcorp.internal`, and `vpn-sa.techcorp.internal`. Switch to a different server in the client settings.

### 4. Check your credentials
- Ensure Caps Lock is off.
- Your VPN password may differ from your Windows password. Reset it at `https://identity.techcorp.internal`.
- If MFA is enabled, make sure your authenticator app is synced (time drift causes MFA failures).

### 5. Flush DNS and renew IP
Open Command Prompt as Administrator and run:
```
ipconfig /flushdns
ipconfig /release
ipconfig /renew
```

### 6. Reinstall the VPN client
Download the latest installer from the IT portal at `https://it.techcorp.internal/downloads`. Uninstall the current version first, then install fresh.

### 7. Check firewall / antivirus
Some antivirus tools block VPN protocols. Temporarily disable your firewall, attempt to connect, then re-enable.

## Still not working?
If none of the above resolves the issue, open a support ticket with:
- Your employee ID
- The exact error message
- Operating system and VPN client version
- Which VPN server you tried
