# Email Setup Guide

TechCorp uses Microsoft 365 (Exchange Online) for corporate email.

## Webmail (No Setup Required)

Access your email from any browser at `https://mail.techcorp.com`. Log in with your TechCorp credentials.

## Outlook Desktop (Windows)

1. Open Outlook
2. Click **File → Add Account**
3. Enter your TechCorp email address (e.g. `joao.silva@techcorp.com`)
4. Click **Connect** — Outlook auto-discovers TechCorp Exchange settings
5. Enter your password and approve the MFA prompt
6. Click **Done** — your mailbox will sync within a few minutes

## Outlook Mobile (iOS / Android)

1. Install **Microsoft Outlook** from the App Store or Google Play
2. Tap **Add Account**
3. Enter your TechCorp email address and tap **Continue**
4. Enter your password and approve MFA
5. Allow notifications when prompted

## Apple Mail (macOS)

1. Open **System Settings → Internet Accounts → Add Account**
2. Choose **Microsoft Exchange**
3. Enter your name, TechCorp email, and password
4. macOS will auto-discover server settings

## Common Issues

### "Cannot connect to server"
- Confirm you are on the TechCorp VPN (required when working remotely)
- Check your internet connection
- Verify your password is not expired at `https://identity.techcorp.internal`

### Email not syncing / missing messages
- Check your mailbox quota at `https://mail.techcorp.com → Settings → Storage`
- Quota limit is 50 GB. Delete old attachments or archive to reduce usage.

### Signature not showing
- Corporate signature template: download from `https://it.techcorp.internal/email-signature`
- In Outlook: File → Options → Mail → Signatures → New

### Shared mailbox access
Request shared mailbox access via `https://it.techcorp.internal/access-request`. Approval from the mailbox owner required.

## SMTP/IMAP Settings (Third-party clients)

| Setting | Value |
|---------|-------|
| IMAP server | `outlook.office365.com` |
| IMAP port | 993 (SSL) |
| SMTP server | `smtp.office365.com` |
| SMTP port | 587 (STARTTLS) |
| Username | Full email address |

Note: Modern Authentication (OAuth2) is required — basic auth is disabled.
