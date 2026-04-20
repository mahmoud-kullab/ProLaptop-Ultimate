# 🛡️ ProLaptop Ultimate v3.0

> **Complete Windows PC Maintenance & Cybersecurity Framework**  
> Built by [Mahmoud Sami Kullab](https://mahmoud-kullab.github.io) — Pro Laptop, Khan Younis, Gaza

---

## 📋 Overview

ProLaptop Ultimate is a professional-grade Windows maintenance and cybersecurity toolkit built with **PowerShell** and **BAT scripting**. It provides **96 tools** across **7 categories** in a single console interface — designed for IT technicians who need fast, reliable, all-in-one PC maintenance.

No installation required. Just right-click and run as Administrator.

---

## ⚡ Quick Start

1. Download both files into the **same folder**:
   - `ProLaptop_Ultimate_v3.ps1`
   - `Start_ProLaptop_v3.bat`

2. **Right-click** `Start_ProLaptop_v3.bat` → **Run as Administrator**

3. Select any tool from the menu (1–96) and press Enter

> ⚠️ **Administrator privileges are required.** The launcher checks automatically.

---

## 🗂️ Categories & Tools

### ⚡ Power & Performance (Tools 1–6)
| # | Tool |
|---|------|
| 1 | Setup All Power Plans |
| 2 | Fix Battery Alerts (20%) |
| 3 | Reset Power Plans to Default |
| 4 | CPU Performance Boost |
| 5 | Battery Health Report |
| 6 | Power Efficiency Report |

### 🧹 System Cleaning (Tools 7–16)
| # | Tool |
|---|------|
| 7 | Deep System Cleaner |
| 8 | Clear All Browser Caches |
| 9 | Clean Windows Update Cache |
| 10 | Remove Windows.old |
| 11 | Empty Recycle Bin + Cache |
| 12 | Clear Windows Event Logs |
| 13 | Disk Cleanup (cleanmgr) |
| 14 | Broken Shortcut Finder & Fixer |
| 15 | Wipe Free Space (Zero Fill) |
| 16 | Remove Orphaned App Data |

### 🔧 System Repair (Tools 17–34)
| # | Tool |
|---|------|
| 17 | SFC VerifyOnly (no changes) |
| 18 | SFC Repair (/scannow) |
| 19 | DISM CheckHealth |
| 20 | DISM ScanHealth |
| 21 | DISM RestoreHealth |
| 22 | DISM ComponentCleanup |
| 23 | Repair Disk (CHKDSK C:) |
| 24 | Fix Windows Update Services |
| 25 | Fix Windows Store & Apps |
| 26 | Fix Windows Search |
| 27 | Fix Windows Audio |
| 28 | Fix Windows Time Sync |
| 29 | Reset Windows Firewall |
| 30 | Rebuild Boot Config (BCD) |
| 31 | Re-register DLL Libraries |
| 32 | Fix Windows Installer (MSI) |
| 33 | Reset Windows Update Policy |
| 34 | Repair WMI Repository |

### 🌐 Network & Internet (Tools 35–47)
| # | Tool |
|---|------|
| 35 | Full Network Reset |
| 36 | Set Google DNS (8.8.8.8) |
| 37 | Set Cloudflare DNS (1.1.1.1) |
| 38 | Reset DNS to Auto (DHCP) |
| 39 | Network Diagnostics |
| 40 | Show Full ipconfig /all |
| 41 | Open Network Connections |
| 42 | Reset Proxy Settings |
| 43 | Show WiFi Profiles |
| 44 | Firewall Manager |
| 45 | Show Open Ports & Connections |
| 46 | Test Internet Speed (Ping) |
| 47 | Export Network Config Backup |

### 🔒 Cyber Security (Tools 48–62)
| # | Tool |
|---|------|
| 48 | Malware Quick Scan |
| 49 | Defender Management (Full Control) |
| 50 | Malware Full Scan |
| 51 | Disable Telemetry & Tracking |
| 52 | Startup Analyzer |
| 53 | Suspicious Process Check |
| 54 | Kill Unsigned Temp Processes |
| 55 | Enable Firewall + Defender |
| 56 | Certificate Manager |
| 57 | Local Security Policy |
| 58 | Driver Verifier |
| 59 | Local Users & Groups |
| 60 | Audit Policy Status |
| 61 | Check for Rootkit Indicators |
| 62 | Hosts File Viewer/Editor |

### 📊 Diagnostics & Info (Tools 63–78)
| # | Tool |
|---|------|
| 63 | Full System Info Report |
| 64 | CPU + Motherboard + RAM |
| 65 | RAM Details (Physical Modules) |
| 66 | Disk Health & SMART |
| 67 | GPU & Driver Details |
| 68 | Driver Error Checker |
| 69 | Windows Activation Status |
| 70 | Uptime & Services Status |
| 71 | Remote Desktop (mstsc) |
| 72 | Group Policy Editor |
| 73 | Windows Apps Folder |
| 74 | Installed Programs List |
| 75 | Running Processes (Top CPU/RAM) |
| 76 | Environment Variables |
| 77 | Windows Error / BSOD Log |
| 78 | Reliability History |

### ⚙️ Advanced (Tools 79–96)
| # | Tool |
|---|------|
| 79 | FULL MAINTENANCE (All Safe) |
| 80 | Create System Restore Point |
| 81 | Defrag HDD (Auto-Skips SSD) |
| 82 | Trim SSD (Auto-Skips HDD) |
| 83 | Optimize All SSDs |
| 84 | Driver Management |
| 85 | Scheduled Task Manager |
| 86 | Disable Startup Programs |
| 87 | Export Registry Backup |
| 88 | Open Log File |
| 89 | Windows Memory Diagnostic |
| 90 | System Configuration (msconfig) |
| 91 | Resource Monitor |
| 92 | Performance Monitor |
| 93 | Event Viewer |
| 94 | Services Manager |
| 95 | Disk Management |
| 96 | Computer Management |

---

## ✨ Key Features

- 🔐 **Admin verification** — checks privileges on launch, refuses to run without them
- 💾 **Auto SSD/HDD detection** — defrag skips SSDs, Trim skips HDDs automatically
- 🛡️ **Restore point creation** — created automatically before any risky operation
- 📋 **Session logging** — every action logged to `ProLaptop_Log.txt`
- ✅ **Confirmation dialogs** — destructive operations ask for Y/N confirmation
- ⚡ **Windows Terminal support** — launches in WT if available, fallback to PowerShell
- 🔄 **Error handling** — full try/catch throughout, no silent failures

---

## 🛠️ Built With

| Technology | Purpose |
|------------|---------|
| PowerShell | Core engine — all 96 tools |
| BAT Script | Launcher — admin check + WT/PS detection |
| Windows API | Registry, WMI, Power management |
| Built-in tools | SFC, DISM, CHKDSK, powercfg, netsh |

---

## ⚙️ Requirements

- Windows 10 / 11
- PowerShell 5.1+
- Administrator privileges
- Both files in the same folder

---

## 👨‍💻 Author

**Mahmoud Sami Kullab**  
ICT Specialist | Cybersecurity Student | Pro Laptop — Khan Younis, Gaza 🇵🇸

- 🌐 Website: [mahmoud-kullab.github.io](https://mahmoud-kullab.github.io)
- 💼 LinkedIn: [linkedin.com/in/m-kullab](https://linkedin.com/in/m-kullab)
- 📧 Email: mahmood.kullab2004@gmail.com
- 📞 Phone: +970 599 548 716

---

## 📄 License

MIT License — feel free to use, modify, and share with attribution.
