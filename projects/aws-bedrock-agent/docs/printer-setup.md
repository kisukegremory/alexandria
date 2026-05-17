# Printer Setup Guide

TechCorp offices use HP network printers. All printers are shared on the corporate network and require VPN when printing remotely.

## Adding a Network Printer (Windows)

1. Open **Settings → Bluetooth & devices → Printers & scanners**
2. Click **Add device**
3. If your office printer does not appear in the list, click **Add manually**
4. Select **Add a printer using an IP address or hostname**
5. Enter the printer IP for your floor (see table below) and click **Next**
6. Windows will install the driver automatically

### Office Printer IPs

| Location | Printer name | IP address |
|----------|-------------|------------|
| Floor 1 — Reception | HP-FL1-REC | 10.10.1.50 |
| Floor 1 — Open space | HP-FL1-OPEN | 10.10.1.51 |
| Floor 2 — Meeting rooms | HP-FL2-MTG | 10.10.2.50 |
| Floor 2 — Engineering | HP-FL2-ENG | 10.10.2.51 |
| Floor 3 — Finance | HP-FL3-FIN | 10.10.3.50 |

## Adding a Network Printer (macOS)

1. Open **System Settings → Printers & Scanners**
2. Click the **+** button
3. Select the **IP** tab
4. Enter the printer IP, Protocol: **HP Jetdirect — Socket**
5. Set a name (e.g. "HP Floor 2 Engineering") and click **Add**

## Common Printer Issues

### Printer offline
1. Check that the printer has paper and no error lights
2. On Windows: open **Printers & scanners**, click the printer, click **Open queue**, then **Printer menu → Use Printer Online**
3. Restart the print spooler: open Command Prompt as Admin and run:
   ```
   net stop spooler
   net start spooler
   ```

### Print job stuck in queue
1. Open **Printers & scanners → Open queue**
2. Select all jobs and click **Cancel**
3. If jobs remain, restart the print spooler (see above)

### Poor print quality / streaks
- The printer may need new toner. Check the display panel on the printer for toner level.
- Contact the office admin (ext. 200) to order a replacement toner cartridge.
- If streaks persist after new toner, the drum may need cleaning — submit an IT ticket.

### Can't print remotely (from home)
- Connect to TechCorp VPN first — printers are on the internal network
- Confirm the printer IP is reachable: open Command Prompt and run `ping 10.10.X.XX`

## Scanning Documents

All HP printers also function as network scanners.

1. Place document face-down on the scanner glass
2. On the printer display, select **Scan → Network Folder**
3. Select your department folder (mapped to `\\fileserver\scans\<department>`)
4. Press **Start** — the scanned PDF will appear in the shared folder within 30 seconds

Access the scan folder from Windows Explorer: `\\fileserver\scans` or map it as a network drive.
