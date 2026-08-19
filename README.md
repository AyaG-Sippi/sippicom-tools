# ???? SIPPICOM IT-Solutions ??? Cloud Suite & Tools Repository

Modern, lightweight, multi-threaded administrative utilities for Windows workstations and servers. All tools are executable directly in memory via PowerShell one-liners (`irm | iex`).

---

## ??? Instant Cloud Execution Hub

Run the unified interactive SIPPICOM Cloud Hub directly from any Windows PowerShell prompt:

```powershell
irm https://raw.githubusercontent.com/Sippicom-IT-SOLUTIONS/tools/main/main.ps1 | iex
```

---

## ??????? Individual Tool One-Liners (`irm | iex`)

### 1. ???? CertRDP (RDP Code Signing & PKI Trust Engine)
Creates SHA-256 self-signed code-signing certificates, installs into `Root` and `TrustedPublisher` stores, injects Terminal Services warning suppression policies, and signs `.rdp` files via native `rdpsign.exe`.

```powershell
irm https://raw.githubusercontent.com/Sippicom-IT-SOLUTIONS/tools/main/tools/certrdp/CertRDP.ps1 | iex
```

---

### 2. ??????? PrinterFix (Multi-Threaded Spooler & Queue Manager)
Resets Print Spooler, purges stuck `.SPL`/`.SHD` print jobs, forces offline queues online, adds TCP/IP network printers, and performs native Windows `.printerExport` migrations (`PrintBrm.exe`).

```powershell
irm https://raw.githubusercontent.com/Sippicom-IT-SOLUTIONS/tools/main/tools/printerfix/PrinterFix.ps1 | iex
```

---

### 3. ???? AutoDeploy Workstation (Interactive)
Installs German Microsoft 365 Office, Adobe Acrobat Reader 64-bit (with automatic update task registration), VLC, and 7-Zip concurrently on parallel worker threads.

```powershell
irm https://raw.githubusercontent.com/Sippicom-IT-SOLUTIONS/tools/main/tools/autodeploy/AutoDeploy.ps1 | iex
```

---

### 4. ??? AutoDeploy Fast (Unattended Silent Setup)
Runs workstation package installs silently in the background with zero user prompts.

```powershell
irm https://raw.githubusercontent.com/Sippicom-IT-SOLUTIONS/tools/main/tools/autodeploy/AutoDeployFast.ps1 | iex
```

---

### 5. ???? CtrlAltPass (Enterprise Credential Utility)
Generates cryptographically secure 16-, 20-, and 24-character passwords and 6-digit PINs with automatic clipboard synchronization.

```powershell
irm https://raw.githubusercontent.com/Sippicom-IT-SOLUTIONS/tools/main/tools/ctrlaltpass/CtrlAltPass.ps1 | iex
```

---

## ???? Repository File Structure

```text
????????? main.ps1                   <-- Central SIPPICOM Cloud Hub
????????? README.md                  <-- Documentation & One-Liners
????????? SippiSign_QRCode.png       <-- ISO/IEC 18004 1:1 QR Code Matrix
????????? tools/
???   ????????? certrdp/
???   ???   ????????? CertRDP.ps1        <-- Cloud RDP Signer
???   ????????? printerfix/
???   ???   ????????? PrinterFix.ps1     <-- Cloud PrinterFix Engine
???   ????????? autodeploy/
???   ???   ????????? AutoDeploy.ps1     <-- Interactive Workstation Deployer
???   ???   ????????? AutoDeployFast.ps1 <-- Unattended Silent Deployer
???   ????????? ctrlaltpass/
???       ????????? CtrlAltPass.ps1    <-- Cloud Credential Generator
????????? bin/                       <-- Compiled 64-bit Standalone Executables
    ????????? CertRDP.exe
    ????????? SippicomPrinterFix.exe
    ????????? SippicomAutoDeploy.exe
    ????????? SippicomAutoDeployFast.exe
    ????????? SippicomCtrlAltPass.exe
```

---

## ???? Standalone Executable Binaries (`bin/`)

For environments with restricted script execution, standalone 64-bit native binaries with zero external runtime dependencies are located in the [`bin/`](./bin/) folder.
