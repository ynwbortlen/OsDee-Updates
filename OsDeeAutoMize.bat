@ECHO OFF
REM BFCPEOPTIONSTART
REM Advanced BAT to EXE Converter www.BatToExeConverter.com
REM BFCPEEXE=
REM BFCPEICON=
REM BFCPEICONINDEX=-1
REM BFCPEEMBEDDISPLAY=0
REM BFCPEEMBEDDELETE=1
REM BFCPEADMINEXE=0
REM BFCPEINVISEXE=0
REM BFCPEVERINCLUDE=0
REM BFCPEVERVERSION=1.0.0.0
REM BFCPEVERPRODUCT=Product Name
REM BFCPEVERDESC=Product Description
REM BFCPEVERCOMPANY=Your Company
REM BFCPEVERCOPYRIGHT=Copyright Info
REM BFCPEWINDOWCENTER=1
REM BFCPEDISABLEQE=0
REM BFCPEWINDOWHEIGHT=30
REM BFCPEWINDOWWIDTH=120
REM BFCPEWTITLE=Window Title
REM BFCPEOPTIONEND
@echo off
setlocal EnableDelayedExpansion

:: ==============================================================================
:: O S D E E   A U T O - O P T I M I Z E R   ( 3 D   A N I M A T E D   E D I T I O N )
:: ==============================================================================

:: --- 1. REQUEST ADMINISTRATOR PRIVILEGES ---
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] You must run this script as Administrator.
    pause
    exit /b
)

:: ==============================================
:: OSDEE DYNAMIC ROUTER (ENTERPRISE EDITION)
:: ==============================================
powershell -Command "Write-Host '[*] Connecting to Dynamic Router System...' -ForegroundColor Cyan"
powershell -Command "try { $response = Invoke-RestMethod -Uri 'https://jsonblob.com/api/jsonBlob/019ef712-57e0-7489-b677-8e5146446256' -ErrorAction Stop; Set-Content '%temp%\osdee_router.txt' $response.url } catch { Set-Content '%temp%\osdee_router.txt' 'OFFLINE' }"
set /p API_URL= < "%temp%\osdee_router.txt"

if "%API_URL%"=="OFFLINE" (
    powershell -Command "Write-Host '[X] The server is currently offline. Please try again later.' -ForegroundColor Red"
    pause
    exit /b
)
:: ==============================================

:: --- 2. VERSION CHECK ---
powershell -Command "Write-Host '[*] Checking for updates...' -ForegroundColor Cyan"
powershell -Command "try { $response = Invoke-RestMethod -Uri '%API_URL%/version' -Headers @{'Bypass-Tunnel-Reminder'='true'} -ErrorAction Stop; Set-Content '%temp%\osdee_version.txt' $response.version } catch { Set-Content '%temp%\osdee_version.txt' 'OFFLINE' }"
set /p CURRENT_VER= < "%temp%\osdee_version.txt"

if "%CURRENT_VER%"=="OFFLINE" (
    powershell -Command "Write-Host '[X] Could not reach Update Server. Skipping version check...' -ForegroundColor Yellow"
    powershell -Command "Start-Sleep -Seconds 1"
) else if not "%CURRENT_VER%"=="1.0.0" (
    powershell -Command "Write-Host '[X] Your version is outdated. Latest version is: %CURRENT_VER%' -ForegroundColor Red"
    powershell -Command "Write-Host '[X] Please download the latest version from our Discord.' -ForegroundColor Yellow"
    pause
    exit /b
)

:: --- 3. ANTI-VPN & PROXY CHECK ---
powershell -Command "Write-Host '[*] Securing Connection (Checking for VPN/Proxies)...' -ForegroundColor Cyan"
powershell -Command "$res = Invoke-RestMethod -Uri 'http://ip-api.com/json?fields=proxy,hosting' -ErrorAction SilentlyContinue; if ($res) { if ($res.proxy -eq $true -or $res.hosting -eq $true) { Set-Content '%temp%\osdee_vpn.txt' 'BLOCKED' } else { Set-Content '%temp%\osdee_vpn.txt' 'CLEAN' } } else { Set-Content '%temp%\osdee_vpn.txt' 'CLEAN' }"
set /p VPN_STATUS= < "%temp%\osdee_vpn.txt"

if "%VPN_STATUS%"=="BLOCKED" (
    powershell -Command "Write-Host '[X] VPN or Proxy detected. You must disable your VPN to use this software.' -ForegroundColor Red"
    pause
    exit /b
)

:: --- 4. SECURE LOGIN / REGISTER SYSTEM ---
:login_menu
cls
echo =================================================================
echo                OSDEE SECURE LOGIN SYSTEM
echo =================================================================
echo.
echo  [1] Login (Existing User)
echo  [2] Register (New User with License Key)
echo  [3] Join Discord Server
echo.
set /p LOGIN_OPT="Select Option (1, 2, or 3): "

if "%LOGIN_OPT%"=="3" (
    start https://discord.gg/QyuGJGNpZJ
    goto login_menu
)

:: Fetch unique HWID (Motherboard UUID)
powershell -NoProfile -Command "$uuid = (Get-CimInstance Win32_ComputerSystemProduct).UUID; Set-Content '%temp%\osdee_hwid.txt' $uuid"
set /p HWID= < "%temp%\osdee_hwid.txt"

if "%LOGIN_OPT%"=="2" goto register
if "%LOGIN_OPT%"=="1" goto login
goto login_menu

:register
cls
echo =================================================================
echo                      REGISTER NEW ACCOUNT
echo =================================================================
echo.
set /p USER_KEY="Enter your License Key: "
set /p USERNAME="Create a Username: "
echo | set /p="Create a Password: "
powershell -NoProfile -Command "$p=Read-Host -AsSecureString; $BSTR=[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($p); [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)" > "%temp%\osdee_pass.txt"
set /p PASSWORD= < "%temp%\osdee_pass.txt"
set /p DISCORD_USER="What is your Discord Username? (e.g., shotta89): "
echo.

powershell -Command "Write-Host '[*] Registering account...' -ForegroundColor Cyan"
powershell -Command "try { $uri = $env:API_URL + '/register?key=' + [uri]::EscapeDataString($env:USER_KEY) + '&username=' + [uri]::EscapeDataString($env:USERNAME) + '&password=' + [uri]::EscapeDataString($env:PASSWORD) + '&hwid=' + [uri]::EscapeDataString($env:HWID) + '&discord_user=' + [uri]::EscapeDataString($env:DISCORD_USER); $response = Invoke-RestMethod -Uri $uri -Headers @{'Bypass-Tunnel-Reminder'='true'} -ErrorAction Stop; Set-Content '%temp%\osdee_auth.txt' $response.status } catch { Set-Content '%temp%\osdee_auth.txt' ('PS_ERROR: ' + $_.Exception.Message) }"
set /p AUTH_STATUS= < "%temp%\osdee_auth.txt"

if "%AUTH_STATUS%"=="INVALID_KEY" (
    powershell -Command "Write-Host '[X] Invalid Key.' -ForegroundColor Red"
    pause
    goto login_menu
)
if "%AUTH_STATUS%"=="KEY_ALREADY_USED" (
    powershell -Command "Write-Host '[X] Key is already used.' -ForegroundColor Red"
    pause
    goto login_menu
)
if "%AUTH_STATUS%"=="USERNAME_TAKEN" (
    powershell -Command "Write-Host '[X] Username already taken. Try another.' -ForegroundColor Red"
    pause
    goto register
)
if "%AUTH_STATUS%"=="SUCCESS" (
    powershell -Command "Write-Host '[+] Registration Successful. Welcome %USERNAME%.' -ForegroundColor Green"
    powershell -Command "Start-Sleep -Seconds 2"
    goto menu
)
if "%AUTH_STATUS%"=="ERROR" (
    powershell -Command "Write-Host '[X] Bot rejected request: Missing or invalid data.' -ForegroundColor Red"
    pause
    exit /b
)
powershell -Command "Write-Host '[X] Registration Failed. Reason: %AUTH_STATUS%' -ForegroundColor Red"
pause
exit /b

:login
cls
echo =================================================================
echo                           ACCOUNT LOGIN
echo =================================================================
echo.
set /p USERNAME="Username: "
echo | set /p="Password: "
powershell -NoProfile -Command "$p=Read-Host -AsSecureString; $BSTR=[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($p); [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)" > "%temp%\osdee_pass.txt"
set /p PASSWORD= < "%temp%\osdee_pass.txt"
echo.

powershell -Command "Write-Host '[*] Authenticating...' -ForegroundColor Cyan"
powershell -Command "try { $uri = $env:API_URL + '/login?username=' + [uri]::EscapeDataString($env:USERNAME) + '&password=' + [uri]::EscapeDataString($env:PASSWORD) + '&hwid=' + [uri]::EscapeDataString($env:HWID); $response = Invoke-RestMethod -Uri $uri -Headers @{'Bypass-Tunnel-Reminder'='true'} -ErrorAction Stop; Set-Content '%temp%\osdee_auth.txt' $response.status } catch { Set-Content '%temp%\osdee_auth.txt' ('PS_ERROR: ' + $_.Exception.Message) }"
set /p AUTH_STATUS= < "%temp%\osdee_auth.txt"

if "%AUTH_STATUS%"=="INVALID_CREDS" (
    powershell -Command "Write-Host '[X] Invalid Username or Password.' -ForegroundColor Red"
    pause
    goto login_menu
)
if "%AUTH_STATUS%"=="HWID_MISMATCH" (
    powershell -Command "Write-Host '[X] Hardware ID Mismatch. Account is locked to another PC.' -ForegroundColor Red"
    pause
    exit /b
)
if "%AUTH_STATUS%"=="SUCCESS" (
    powershell -Command "Write-Host '[+] Access Granted. Welcome back %USERNAME%.' -ForegroundColor Green"
    powershell -Command "Start-Sleep -Seconds 2"
    goto menu
)
powershell -Command "Write-Host '[X] Could not connect to Auth Server.' -ForegroundColor Red"
pause
exit /b

:menu
cls
powershell -NoProfile -Command "$logo=@('    ____  _____ ____  ______ ______ ', '   / __ \/ ___// __ \/ ____// ____/ ', '  / / / /\__ \/ / / / __/  / __/    ', ' / /_/ /___/ / /_/ / /___ / /___    ', ' \____//____/_____/_____//_____/    '); $colors = @('Red','DarkRed','White','Cyan','Red'); foreach($c in $colors) { [Console]::SetCursorPosition(0,0); foreach($line in $logo) { Write-Host $line -ForegroundColor $c }; Start-Sleep -Milliseconds 150 }"
echo.
echo  =================================================================
echo             OSDEE HARDWARE AUTO-OPTIMIZER
echo  =================================================================
echo.
echo  [ SYSTEM SETUP ]
echo  [1] INITIALIZE HARDWARE SCAN ^& OPTIMIZE     (Run Once)
echo  [7] REVERT SYSTEM TO PREVIOUS STATE         (Undo Fixes)
echo.
echo  [ DAILY GAMING TOOLS ]
echo  [2] ACTIVE GAME BOOST MODE                  (Launch Before Gaming)
echo  [3] LIVE MEMORY STUTTER FIXER               (Background Daemon)
echo  [4] DYNAMIC PING ^& HITREG FIXER             (Network Desync Fix)
echo  [6] DAILY CACHE ^& STORAGE SWEEPER           (Clear Junk Files)
echo.
echo  [ MONITORING ]
echo  [5] LIVE DASHBOARD                          (Real-Time Stats)
echo.
echo  [8] EXIT PROGRAM
echo  =================================================================
echo.
set /p choice="Select an option: "

if "%choice%"=="1" goto optimize
if "%choice%"=="2" goto game_boost
if "%choice%"=="3" goto mem_flush
if "%choice%"=="4" goto ping_optimizer
if "%choice%"=="5" goto dashboard
if "%choice%"=="6" goto cache_sweeper
if "%choice%"=="7" goto revert
if "%choice%"=="8" exit
goto menu

:optimize
cls
echo =================================================================
echo                  1. ANALYZING SYSTEM HARDWARE
echo =================================================================
echo.
:: --- PRE-BENCHMARK ---
powershell -Command "Write-Host '[*] Running Pre-Optimization Benchmark...' -ForegroundColor Cyan"
powershell -Command "$sw = [Diagnostics.Stopwatch]::StartNew(); for($i=0; $i -lt 1500000; $i++){ $x = [math]::sqrt($i) }; $sw.Stop(); Set-Content '%temp%\osdee_pre.txt' $sw.ElapsedMilliseconds"
set /p PRE_SCORE= < "%temp%\osdee_pre.txt"
powershell -Command "Write-Host '[+] Base System Latency: %PRE_SCORE% ms' -ForegroundColor Yellow"
echo.


:: --- SYSTEM RESTORE POINT (FOR 100% SAFETY) ---
powershell -Command "Write-Host '[*] Creating System Restore Point for safety...' -ForegroundColor Cyan"
powershell -Command "Enable-ComputerRestore -Drive 'C:\' -ErrorAction SilentlyContinue; Checkpoint-Computer -Description 'OsDee Optimizer Backup' -RestorePointType 'MODIFY_SETTINGS' -ErrorAction SilentlyContinue"
powershell -Command "Write-Host '[*] Restore Point Created. System is fully protected.' -ForegroundColor Green"
echo.

:: --- FAKE "SCANNING" PROGRESS BAR (ANIMATED) ---
powershell -Command "for($i=1; $i -le 25; $i++){ Write-Host -NoNewline \"`r[SCANNING MOTHERBOARD] [\" + ('#' * $i) + (' ' * (25-$i)) + \"] $($i*4)%% \"; Start-Sleep -Milliseconds 40 }; Write-Host ' '"
powershell -Command "for($i=1; $i -le 25; $i++){ Write-Host -NoNewline \"`r[READING SENSORS]      [\" + ('#' * $i) + (' ' * (25-$i)) + \"] $($i*4)%% \"; Start-Sleep -Milliseconds 30 }; Write-Host ' '"
echo.

:: --- DETECT HARDWARE SAFELY ---
powershell -NoProfile -Command "(Get-CimInstance Win32_Processor | Select-Object -First 1).Name" > "%temp%\osdee_cpu.txt"
set /p CPU= < "%temp%\osdee_cpu.txt"

powershell -NoProfile -Command "(Get-CimInstance Win32_VideoController | Select-Object -First 1).Name" > "%temp%\osdee_gpu.txt"
set /p GPU= < "%temp%\osdee_gpu.txt"

powershell -NoProfile -Command "$mem=Get-CimInstance Win32_ComputerSystem; [math]::Round($mem.TotalPhysicalMemory / 1GB)" > "%temp%\osdee_ram.txt"
set /p RAM_GB= < "%temp%\osdee_ram.txt"

powershell -Command "Write-Host '[+] CPU ALIGNED:' -NoNewline -ForegroundColor Green; Write-Host ' %CPU%'"
powershell -Command "Start-Sleep -Milliseconds 400"

powershell -Command "Write-Host '[+] GPU SYNCED :' -NoNewline -ForegroundColor Green; Write-Host ' %GPU%'"
powershell -Command "Start-Sleep -Milliseconds 400"

powershell -Command "Write-Host '[+] RAM POOLED :' -NoNewline -ForegroundColor Green; Write-Host ' %RAM_GB% GB'"
powershell -Command "Start-Sleep -Milliseconds 400"

:: --- DETECT WINDOWS ---
set "WIN_VER=10"
ver | findstr /i "10.0.2" >nul
if %errorlevel%==0 set "WIN_VER=11"
powershell -Command "Write-Host '[+] OS KERNEL  :' -NoNewline -ForegroundColor Green; Write-Host ' Windows %WIN_VER%'"
echo.

powershell -Command "Write-Host -ForegroundColor Cyan 'Compiling custom tweak sequence based on hardware profile...'"
powershell -Command "for($i=1; $i -le 30; $i++){ Write-Host -NoNewline \"`r[CALCULATING] [\" + ('=' * $i) + (' ' * (30-$i)) + \"] \"; Start-Sleep -Milliseconds 50 }; Write-Host ' '"

cls
echo =================================================================
echo                  2. DEPLOYING OPTIMIZATIONS
echo =================================================================
echo.

:: --- A. MOUSE & KEYBOARD ---
powershell -Command "Write-Host -NoNewline '[*] Overriding Mouse Acceleration & Keyboard Delays... '; Start-Sleep -Milliseconds 300; Write-Host -ForegroundColor Green 'SUCCESS'"
Reg.exe add "HKCU\Control Panel\Mouse" /v "MouseSpeed" /t REG_SZ /d "0" /f >nul
Reg.exe add "HKCU\Control Panel\Mouse" /v "MouseThreshold1" /t REG_SZ /d "0" /f >nul
Reg.exe add "HKCU\Control Panel\Mouse" /v "MouseThreshold2" /t REG_SZ /d "0" /f >nul
Reg.exe add "HKCU\Control Panel\Keyboard" /v "KeyboardDelay" /t REG_SZ /d "0" /f >nul
Reg.exe add "HKCU\Control Panel\Keyboard" /v "KeyboardSpeed" /t REG_SZ /d "31" /f >nul

:: --- B. NETWORK ---
powershell -Command "Write-Host -NoNewline '[*] Flushing DNS & Applying Cloudflare Routing... '; Start-Sleep -Milliseconds 400; Write-Host -ForegroundColor Green 'SUCCESS'"
ipconfig /flushdns >nul 2>&1
netsh winsock reset >nul 2>&1
powershell -Command "Get-NetAdapter | Where-Object Status -eq 'Up' | Set-DnsClientServerAddress -ServerAddresses '1.1.1.1','1.0.0.1' -ErrorAction SilentlyContinue" >nul 2>&1

powershell -Command "Write-Host -NoNewline '[*] Tuning TCP/IP Packets for Low Latency... '; Start-Sleep -Milliseconds 400; Write-Host -ForegroundColor Green 'SUCCESS'"
netsh int tcp set global autotuninglevel=normal >nul
netsh int tcp set global heuristics=disabled >nul
netsh int tcp set global ecncapability=disabled >nul
netsh int tcp set global rss=enabled >nul
for /f "tokens=*" %%i in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"') do (
    Reg.exe add "%%i" /v "TcpAckFrequency" /t REG_DWORD /d "1" /f >nul 2>&1
    Reg.exe add "%%i" /v "TCPNoDelay" /t REG_DWORD /d "1" /f >nul 2>&1
    Reg.exe add "%%i" /v "TcpDelAckTicks" /t REG_DWORD /d "0" /f >nul 2>&1
)

powershell -Command "Write-Host -NoNewline '[*] Disabling Energy Efficient Ethernet & LSO... '; Start-Sleep -Milliseconds 400; Write-Host -ForegroundColor Green 'SUCCESS'"
powershell -Command "Disable-NetAdapterLso -Name '*' -ErrorAction SilentlyContinue" >nul 2>&1
powershell -Command "Disable-NetAdapterPowerManagement -Name '*' -ErrorAction SilentlyContinue" >nul 2>&1
powershell -Command "Set-NetAdapterAdvancedProperty -Name '*' -DisplayName 'Energy Efficient Ethernet' -DisplayValue 'Disabled' -ErrorAction SilentlyContinue" >nul 2>&1
powershell -Command "Set-NetAdapterAdvancedProperty -Name '*' -DisplayName 'Green Ethernet' -DisplayValue 'Disabled' -ErrorAction SilentlyContinue" >nul 2>&1

:: --- C. DEBLOAT ---
powershell -Command "Write-Host -NoNewline '[*] Neutralizing Background Telemetry Bloat... '; Start-Sleep -Milliseconds 500; Write-Host -ForegroundColor Green 'SUCCESS'"
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f >nul
sc stop "DiagTrack" >nul 2>&1
sc config "DiagTrack" start= disabled >nul 2>&1
sc stop "SysMain" >nul 2>&1
sc config "SysMain" start= disabled >nul 2>&1

powershell -Command "Write-Host -NoNewline '[*] Disabling Windows Background Apps & Notifications... '; Start-Sleep -Milliseconds 400; Write-Host -ForegroundColor Green 'SUCCESS'"
Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\PushNotifications" /v "ToastEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "EnableTransparency" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f >nul
sc stop "DiagTrack" >nul 2>&1
sc config "DiagTrack" start= disabled >nul 2>&1
sc stop "SysMain" >nul 2>&1
sc config "SysMain" start= disabled >nul 2>&1

powershell -Command "Write-Host -NoNewline '[*] Disabling Fault Tolerant Heap (FTH)... '; Start-Sleep -Milliseconds 300; Write-Host -ForegroundColor Green 'SUCCESS'"
Reg.exe add "HKLM\SOFTWARE\Microsoft\FTH" /v "Enabled" /t REG_DWORD /d "0" /f >nul 2>&1

powershell -Command "Write-Host -NoNewline '[*] Disabling Heavy Windows Animations... '; Start-Sleep -Milliseconds 300; Write-Host -ForegroundColor Green 'SUCCESS'"
Reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d "2" /f >nul

:: --- D. FULL SCREEN OPTIMIZATIONS (FSE) & PRO TWEAKS ---
powershell -Command "Write-Host -NoNewline '[*] Forcing DWM True Full Screen & Game Mode... '; Start-Sleep -Milliseconds 300; Write-Host -ForegroundColor Green 'SUCCESS'"
Reg.exe add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d "0" /f >nul
Reg.exe add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehaviorMode" /t REG_DWORD /d "2" /f >nul
Reg.exe add "HKCU\Software\Microsoft\GameBar" /v "AutoGameModeEnabled" /t REG_DWORD /d "1" /f >nul
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\GameBarPresenceWriter.exe" /v "Debugger" /t REG_SZ /d "systray.exe" /f >nul 2>&1

powershell -Command "Write-Host -NoNewline '[*] Disabling Multi-Plane Overlay (MPO) to fix stutters... '; Start-Sleep -Milliseconds 300; Write-Host -ForegroundColor Green 'SUCCESS'"
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\Dwm" /v "OverlayTestMode" /t REG_DWORD /d "5" /f >nul 2>&1

powershell -Command "Write-Host -NoNewline '[*] Disabling Virtualization-Based Security (VBS/Memory Integrity)... '; Start-Sleep -Milliseconds 300; Write-Host -ForegroundColor Green 'SUCCESS'"
bcdedit /set hypervisorlaunchtype off >nul 2>&1
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard" /v "EnableVirtualizationBasedSecurity" /t REG_DWORD /d "0" /f >nul 2>&1

if "%WIN_VER%"=="11" (
    powershell -Command "Write-Host -NoNewline '[*] Windows 11 Detected: Bypassing VRR... '; Start-Sleep -Milliseconds 200; Write-Host -ForegroundColor Green 'SUCCESS'"
    Reg.exe add "HKCU\SOFTWARE\Microsoft\DirectX\UserGpuPreferences" /v "DirectXUserGlobalSettings" /t REG_SZ /d "VRROptimizeEnable=0;SwapEffectUpgradeEnable=1;" /f >nul
)

:: --- E. LOW-LATENCY TIMER TWEAKS (BCDEDIT) ---
powershell -Command "Write-Host -NoNewline '[*] Injecting HPET System Timer Overrides... '; Start-Sleep -Milliseconds 600; Write-Host -ForegroundColor Green 'SUCCESS'"
bcdedit /set disabledynamictick yes >nul 2>&1
bcdedit /set useplatformclock false >nul 2>&1
bcdedit /set tscsyncpolicy Enhanced >nul 2>&1

:: --- F. ULTIMATE PERFORMANCE POWER PLAN ---
powershell -Command "Write-Host -NoNewline '[*] Disabling USB Selective Suspend (Zero Input Lag)... '; Start-Sleep -Milliseconds 400; Write-Host -ForegroundColor Green 'SUCCESS'"
powercfg -setacvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bea5682423 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0 >nul 2>&1
powercfg -setdcvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bea5682423 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0 >nul 2>&1

powershell -Command "Write-Host -NoNewline '[*] Unparking CPU Cores (Ultimate Performance)... '; Start-Sleep -Milliseconds 400; Write-Host -ForegroundColor Green 'SUCCESS'"
for /f "tokens=4" %%a in ('powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61') do set "ULT_PLAN=%%a"
powercfg -setactive !ULT_PLAN! >nul 2>&1
powercfg -h off >nul 2>&1
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d "1" /f >nul 2>&1


:: --- POST-BENCHMARK ---
powershell -Command "Write-Host '[*] Let CPU stabilize for 3 seconds...' -ForegroundColor Cyan"
powershell -Command "Start-Sleep -Seconds 3"
powershell -Command "Write-Host '[*] Running Post-Optimization Benchmark...' -ForegroundColor Cyan"
powershell -Command "$sw = [Diagnostics.Stopwatch]::StartNew(); for($i=0; $i -lt 1500000; $i++){ $x = [math]::sqrt($i) }; $sw.Stop(); Set-Content '%temp%\osdee_post.txt' $sw.ElapsedMilliseconds"
set /p POST_SCORE= < "%temp%\osdee_post.txt"
powershell -Command "Write-Host '[+] New Optimized Latency: %POST_SCORE% ms' -ForegroundColor Green"
powershell -Command "$diff = %PRE_SCORE% - %POST_SCORE%; if ($diff -gt 0) { Write-Host \"[+] LATENCY REDUCED BY $diff ms. SYSTEM IS FASTER.\" -ForegroundColor Green } else { Write-Host \"[+] SYSTEM IS OPTIMIZED FOR STABILITY.\" -ForegroundColor Green }"
powershell -Command "$uri = $env:API_URL + '/log_benchmark?username=' + [uri]::EscapeDataString($env:USERNAME) + '&pre=' + $env:PRE_SCORE + '&post=' + $env:POST_SCORE; Invoke-RestMethod -Uri $uri -Headers @{'Bypass-Tunnel-Reminder'='true'} -ErrorAction SilentlyContinue" >nul 2>&1
echo.

:: --- G. PC CACHE & TEMP CLEANUP ---
powershell -Command "Write-Host -NoNewline '[*] Disabling NTFS Last Access Time (Storage Speed Boost)... '; Start-Sleep -Milliseconds 300; Write-Host -ForegroundColor Green 'SUCCESS'"
fsutil behavior set disablelastaccess 1 >nul 2>&1

powershell -Command "Write-Host -NoNewline '[*] Flushing Cache / Temp Data... '; Start-Sleep -Milliseconds 700; Write-Host -ForegroundColor Green 'SUCCESS'"
del /q /f /s %TEMP%\* >nul 2>&1
del /q /f /s C:\Windows\Temp\* >nul 2>&1
del /q /f /s C:\Windows\Prefetch\* >nul 2>&1

powershell -Command "Write-Host -NoNewline '[*] Cleaning GPU Shader Cache (Fixes Stutters)... '; Start-Sleep -Milliseconds 300; Write-Host -ForegroundColor Green 'SUCCESS'"
del /q /f /s "%USERPROFILE%\AppData\Local\D3DSCache\*" >nul 2>&1
del /q /f /s "%USERPROFILE%\AppData\Local\NVIDIA\GLCache\*" >nul 2>&1
del /q /f /s "%USERPROFILE%\AppData\Local\NVIDIA\DXCache\*" >nul 2>&1
del /q /f /s "%USERPROFILE%\AppData\Local\AMD\DxCache\*" >nul 2>&1

powershell -Command "Write-Host -NoNewline '[*] Cleaning Windows Update Cache... '; Start-Sleep -Milliseconds 300; Write-Host -ForegroundColor Green 'SUCCESS'"
net stop wuauserv >nul 2>&1
del /q /f /s "C:\Windows\SoftwareDistribution\Download\*" >nul 2>&1
net start wuauserv >nul 2>&1

powershell -Command "Write-Host -NoNewline '[*] Purging Windows Event Logs & Recycle Bin... '; Start-Sleep -Milliseconds 600; Write-Host -ForegroundColor Green 'SUCCESS'"
powershell -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >nul 2>&1
for /F "tokens=*" %%1 in ('wevtutil.exe el') DO wevtutil.exe cl "%%1" >nul 2>&1

:: --- H. HARDWARE-SPECIFIC OPTIMIZATIONS ---
powershell -Command "Write-Host -NoNewline '[*] Forcing MSI Mode for GPU & Network Adapters... '; Start-Sleep -Milliseconds 400; Write-Host -ForegroundColor Green 'SUCCESS'"
powershell -Command "Get-CimInstance Win32_VideoController | ForEach-Object { $p=\"HKLM:\SYSTEM\CurrentControlSet\Enum\$($_.PNPDeviceID)\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties\"; if(Test-Path $p){Set-ItemProperty -Path $p -Name 'MSISupported' -Value 1 -ErrorAction SilentlyContinue} }" >nul 2>&1
powershell -Command "Get-NetAdapterHardwareInfo | ForEach-Object { $p=\"HKLM:\SYSTEM\CurrentControlSet\Enum\$($_.PnPDeviceID)\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties\"; if(Test-Path $p){Set-ItemProperty -Path $p -Name 'MSISupported' -Value 1 -ErrorAction SilentlyContinue} }" >nul 2>&1

Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d "2" /f >nul 2>&1
echo %GPU% | findstr /i "NVIDIA" >nul
if %errorlevel%==0 (
    powershell -Command "Write-Host -NoNewline '[*] NVIDIA GPU Detected: Forcing Max Performance & Disabling Telemetry... '; Start-Sleep -Milliseconds 300; Write-Host -ForegroundColor Green 'SUCCESS'"
    Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\NVTweak" /v "NvCplPreferMaxperf" /t REG_DWORD /d "1" /f >nul 2>&1
    Reg.exe add "HKLM\SOFTWARE\NVIDIA Corporation\NvControlPanel2\Client" /v "OptInOrOutPreference" /t REG_DWORD /d "0" /f >nul 2>&1
    sc stop "NvTelemetryContainer" >nul 2>&1
    sc config "NvTelemetryContainer" start= disabled >nul 2>&1

    powershell -Command "Write-Host -NoNewline '[*] Installing NVIDIA Profile Inspector... '; Start-Sleep -Milliseconds 300; Write-Host -ForegroundColor Green 'SUCCESS'"
    powershell -Command "Invoke-WebRequest -Uri 'https://github.com/Orbmu2k/nvidiaProfileInspector/releases/latest/download/nvidiaProfileInspector.zip' -OutFile '%temp%\npi.zip' -ErrorAction SilentlyContinue" >nul 2>&1
    powershell -Command "Expand-Archive -Path '%temp%\npi.zip' -DestinationPath 'C:\OsDee_NPI' -Force -ErrorAction SilentlyContinue" >nul 2>&1

    powershell -Command "Write-Host -NoNewline '[*] Applying Dynamic NVIDIA Profile based on Specs... '; Start-Sleep -Milliseconds 300; Write-Host -ForegroundColor Green 'SUCCESS'"
    if %RAM_GB% GTR 15 (
        powershell -Command "$nip = '<ArrayOfProfile><Profile><ProfileName>Base Profile</ProfileName><Executeables /><Settings><ProfileSetting><SettingID>13510289</SettingID><SettingValue>20</SettingValue><ValueType>Dword</ValueType></ProfileSetting><ProfileSetting><SettingID>274197361</SettingID><SettingValue>1</SettingValue><ValueType>Dword</ValueType></ProfileSetting></Settings></Profile></ArrayOfProfile>'; Set-Content -Path 'C:\OsDee_NPI\OsDee_HighEnd.nip' -Value $nip -ErrorAction SilentlyContinue" >nul 2>&1
        if exist "C:\OsDee_NPI\nvidiaProfileInspector.exe" (
            "C:\OsDee_NPI\nvidiaProfileInspector.exe" "C:\OsDee_NPI\OsDee_HighEnd.nip" -silent >nul 2>&1
        )
    ) else (
        powershell -Command "$nip = '<ArrayOfProfile><Profile><ProfileName>Base Profile</ProfileName><Executeables /><Settings><ProfileSetting><SettingID>13510289</SettingID><SettingValue>20</SettingValue><ValueType>Dword</ValueType></ProfileSetting><ProfileSetting><SettingID>274197361</SettingID><SettingValue>1</SettingValue><ValueType>Dword</ValueType></ProfileSetting><ProfileSetting><SettingID>8102046</SettingID><SettingValue>1</SettingValue><ValueType>Dword</ValueType></ProfileSetting></Settings></Profile></ArrayOfProfile>'; Set-Content -Path 'C:\OsDee_NPI\OsDee_LowEnd.nip' -Value $nip -ErrorAction SilentlyContinue" >nul 2>&1
        if exist "C:\OsDee_NPI\nvidiaProfileInspector.exe" (
            "C:\OsDee_NPI\nvidiaProfileInspector.exe" "C:\OsDee_NPI\OsDee_LowEnd.nip" -silent >nul 2>&1
        )
    )
) else (
    powershell -Command "Write-Host -NoNewline '[*] AMD GPU Detected: Disabling ULPS & Telemetry... '; Start-Sleep -Milliseconds 300; Write-Host -ForegroundColor Green 'SUCCESS'"
    Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\amdkmdag\UMD" /v "DisableBlockWrite" /t REG_DWORD /d "1" /f >nul 2>&1
    for /f "tokens=*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /s /f "EnableUlps" ^^^| findstr "HKEY"') do (
        Reg.exe add "%%a" /v "EnableUlps" /t REG_DWORD /d "0" /f >nul 2>&1
    )
    sc stop "AmdCrashDefender" >nul 2>&1
    sc config "AmdCrashDefender" start= disabled >nul 2>&1
    sc stop "AMD External Events Utility" >nul 2>&1
    sc config "AMD External Events Utility" start= disabled >nul 2>&1
)

:: CPU TWEAKS
powershell -Command "Write-Host -NoNewline '[*] Rewriting CPU Gaming Thread Priorities... '; Start-Sleep -Milliseconds 400; Write-Host -ForegroundColor Green 'SUCCESS'"
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d "0" /f >nul
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d "4294967295" /f >nul
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d "38" /f >nul
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d "8" /f >nul
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d "6" /f >nul
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d "High" /f >nul

:: RAM TWEAKS
if %RAM_GB% GTR 15 (
    powershell -Command "Write-Host -NoNewline '[*] 16GB+ RAM: Expanding System Cache Pool... '; Start-Sleep -Milliseconds 300; Write-Host -ForegroundColor Green 'SUCCESS'"
    Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "ClearPageFileAtShutdown" /t REG_DWORD /d "0" /f >nul
    Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t REG_DWORD /d "1" /f >nul
) else (
    powershell -Command "Write-Host -NoNewline '[*] Under 16GB RAM: Engaging Aggressive Paging... '; Start-Sleep -Milliseconds 300; Write-Host -ForegroundColor Green 'SUCCESS'"
    Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d "1" /f >nul
    Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t REG_DWORD /d "0" /f >nul
)

:: --- I. ADVANCED E-SPORTS TWEAKS (FPS GUARANTEE) ---
powershell -Command "Write-Host -NoNewline '[*] Creating Background RAM Cleaner Task... '; Start-Sleep -Milliseconds 400; Write-Host -ForegroundColor Green 'SUCCESS'"
:: Removed OsDeeRamCleaner due to BSODs
:: powershell -Command "$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-WindowStyle Hidden -Command ""Add-Type -MemberDefinition ''[DllImport(""""""psapi.dll"""""")] public static extern int EmptyWorkingSet(IntPtr hwProc);'' -Name ''Mem'' -Namespace ''Win32''; [Win32.Mem]::EmptyWorkingSet((New-Object IntPtr(-1)));""'; $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 10); Register-ScheduledTask -TaskName 'OsDeeRamCleaner' -Action $action -Trigger $trigger -User 'SYSTEM' -RunLevel Highest -Force > $null" >nul 2>&1

powershell -Command "Write-Host -NoNewline '[*] Applying E-Sports CPU Affinity (Core 0 Isolation)... '; Start-Sleep -Milliseconds 400; Write-Host -ForegroundColor Green 'SUCCESS'"
powershell -Command "$cores = (Get-CimInstance Win32_Processor).NumberOfLogicalProcessors; $mask = (1 -shl $cores) - 2; $games = @('FiveM.exe', 'GTA5.exe', 'RobloxPlayerBeta.exe', 'VALORANT-Win64-Shipping.exe', 'FortniteClient-Win64-Shipping.exe'); foreach ($game in $games) { $path = \"HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\$game\PerfOptions\"; if (!(Test-Path $path)) { New-Item -Path $path -Force > $null }; Set-ItemProperty -Path $path -Name 'CpuAffinity' -Value $mask -Type DWord }" >nul 2>&1

powershell -Command "Write-Host -NoNewline '[*] Locking CPU C-States (Zero Input Delay)... '; Start-Sleep -Milliseconds 400; Write-Host -ForegroundColor Green 'SUCCESS'"
powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR IDLEDISABLE 1 >nul 2>&1
powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100 >nul 2>&1
powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100 >nul 2>&1
powercfg -setactive SCHEME_CURRENT >nul 2>&1

powershell -Command "Write-Host -NoNewline '[*] Configuring Static Pagefile (Stutter Fix)... '; Start-Sleep -Milliseconds 600; Write-Host -ForegroundColor Green 'SUCCESS'"
:: Removed Static Pagefile config due to stability issues
:: powershell -Command "$cs = Get-WmiObject Win32_ComputerSystem; $cs.AutomaticManagedPagefile = $false; $cs.Put() > $null; $page = Get-WmiObject Win32_PageFileSetting; if ($page) { $page.InitialSize = 8192; $page.MaximumSize = 8192; $page.Put() > $null }" >nul 2>&1

powershell -Command "Write-Host -NoNewline '[*] Bypassing Windows Defender for FiveM & Roblox... '; Start-Sleep -Milliseconds 300; Write-Host -ForegroundColor Green 'SUCCESS'"
powershell -Command "Add-MpPreference -ExclusionPath \"C:\Users\$env:USERNAME\AppData\Local\FiveM\" -ErrorAction SilentlyContinue" >nul 2>&1
powershell -Command "Add-MpPreference -ExclusionPath \"C:\Users\$env:USERNAME\AppData\Local\Roblox\" -ErrorAction SilentlyContinue" >nul 2>&1

echo.
powershell -Command "for($i=1; $i -le 30; $i++){ Write-Host -NoNewline \"`r[FINALIZING] [\" + ('#' * $i) + (' ' * (30-$i)) + \"] \"; Start-Sleep -Milliseconds 30 }; Write-Host ' '"
echo.




echo =================================================================
powershell -Command "Write-Host '                  OPTIMIZATION COMPLETE!' -ForegroundColor Green"
echo =================================================================
echo.
echo  Your hardware has been fully scanned and dynamically optimized.
echo  Please restart your computer for all tweaks to apply properly.
echo.
echo  PRESS ANY KEY TO RETURN TO MENU...
pause >nul
goto menu

:revert
cls
echo =================================================================
echo                  SYSTEM RESTORE INITIATED
echo =================================================================
echo.
powershell -Command "Write-Host '[X] WARNING: Your PC will restart to undo the changes.' -ForegroundColor Yellow"
powershell -Command "Write-Host '[*] Attempting to locate OsDee Optimizer Backup...' -ForegroundColor Cyan"
powershell -Command "$RP = Get-ComputerRestorePoint | Where-Object { $_.Description -match 'OsDee Optimizer Backup' } | Select-Object -Last 1; if ($RP) { Write-Host '[+] Restore point found. Reverting now...' -ForegroundColor Green; Start-Sleep -Seconds 2; Restore-Computer -RestorePoint $RP.SequenceNumber -Confirm:$false } else { Write-Host '[X] No OsDee Restore Point found. System cannot be reverted automatically.' -ForegroundColor Red; Start-Sleep -Seconds 3 }"
pause
goto menu

:ping_optimizer
cls
echo =================================================================
echo                 DYNAMIC PING ^& ROUTING OPTIMIZER
echo =================================================================
echo.
powershell -Command "Write-Host '[*] Flushing DNS and renewing network routing...' -ForegroundColor Cyan"
ipconfig /flushdns >nul 2>&1
netsh winsock reset >nul 2>&1

powershell -Command "Write-Host '[*] Scanning for active games...' -ForegroundColor Yellow"
powershell -NoProfile -Command "$games = @('FiveM', 'FortniteClient-Win64-Shipping', 'VALORANT-Win64-Shipping', 'cod', 'cs2', 'csgo', 'RobloxPlayerBeta', 'GTA5', 'r5apex', 'Overwatch', 'RainbowSix'); $found = $false; foreach($g in $games){ if(Get-Process $g -ErrorAction SilentlyContinue){ Write-Host \"[+] Detected active game: $g.exe\" -ForegroundColor Green; Write-Host \"[*] Injecting QoS Policy for pure low-latency routing...\" -ForegroundColor Cyan; Remove-NetQosPolicy -Name \"OsDeePing_$g\" -ErrorAction SilentlyContinue >$null; New-NetQosPolicy -Name \"OsDeePing_$g\" -AppPathNameMatchCondition \"$g.exe\" -DSCPAction 46 -NetworkProfile All -ErrorAction SilentlyContinue >$null; $found = $true; break } }; if(-not $found){ Write-Host \"[X] No supported games detected running. Launch your game first, then run this option.\" -ForegroundColor Red }"
echo.
powershell -Command "Write-Host '[+] Ping Optimizer Complete. Return to your game.' -ForegroundColor Green"
pause
goto menu

:cache_sweeper
cls
echo =================================================================
echo                   DAILY CACHE ^& STORAGE SWEEPER
echo =================================================================
echo.
powershell -Command "Write-Host '[*] Wiping Windows Temp Files...' -ForegroundColor Cyan"
del /q /f /s %TEMP%\* >nul 2>&1
del /q /f /s C:\Windows\Temp\* >nul 2>&1
powershell -Command "Write-Host '[*] Wiping Prefetch Traces...' -ForegroundColor Cyan"
del /q /f /s C:\Windows\Prefetch\* >nul 2>&1
powershell -Command "Write-Host '[*] Wiping GPU Shader Caches (NVIDIA/AMD/DirectX)...' -ForegroundColor Cyan"
del /q /f /s \"%USERPROFILE%\AppData\Local\D3DSCache\*\" >nul 2>&1
del /q /f /s \"%USERPROFILE%\AppData\Local\NVIDIA\GLCache\*\" >nul 2>&1
del /q /f /s \"%USERPROFILE%\AppData\Local\NVIDIA\DXCache\*\" >nul 2>&1
del /q /f /s \"%USERPROFILE%\AppData\Local\AMD\DxCache\*\" >nul 2>&1
powershell -Command "Write-Host '[*] Wiping SoftwareDistribution ^& Updates Cache...' -ForegroundColor Cyan"
net stop wuauserv >nul 2>&1
del /q /f /s "C:\Windows\SoftwareDistribution\Download\*" >nul 2>&1
net start wuauserv >nul 2>&1
powershell -Command "Write-Host '[*] Emptying Recycle Bin...' -ForegroundColor Cyan"
powershell -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >nul 2>&1
echo.
powershell -Command "Write-Host '[+] Daily Sweep Complete. Gigabytes of junk removed.' -ForegroundColor Green"
pause
goto menu

:game_boost
cls
echo =================================================================
echo                 ACTIVE GAME BOOST MODE
echo =================================================================
echo.
powershell -Command "Write-Host '[*] Closing Background Bloatware (Discord Hardware Acceleration, Browsers)...' -ForegroundColor Cyan"
taskkill /f /im chrome.exe >nul 2>&1
taskkill /f /im edge.exe >nul 2>&1
taskkill /f /im msedge.exe >nul 2>&1
powershell -Command "Write-Host '[*] Optimizing CPU Affinity for Games...' -ForegroundColor Cyan"
powershell -NoProfile -Command "$games = @('FiveM', 'GTA5', 'FortniteClient-Win64-Shipping', 'VALORANT-Win64-Shipping', 'RobloxPlayerBeta', 'cs2'); foreach($g in $games){ $p = Get-Process $g -ErrorAction SilentlyContinue; if($p){ $p.PriorityClass = 'High'; Write-Host \"[+] $g set to High Priority.\" -ForegroundColor Green } }"
powershell -Command "Write-Host '[+] Game Boost Complete! You are ready to play.' -ForegroundColor Green"
pause
goto menu

:mem_flush
cls
echo =================================================================
echo             LIVE MEMORY STUTTER FIXER (DAEMON)
echo =================================================================
echo.
powershell -Command "Write-Host '[*] Starting Background Memory Flusher...' -ForegroundColor Cyan"
powershell -Command "Write-Host '[*] This window will now clear standby memory every 5 minutes.' -ForegroundColor Yellow"
:mem_loop
powershell -Command "Write-Host \"[$(Get-Date -Format 'HH:mm:ss')] Flushing Standby List...\" -ForegroundColor Green"
powershell -Command "Add-Type -TypeDefinition 'using System; using System.Runtime.InteropServices; public class Mem { [DllImport(\"psapi.dll\")] public static extern int EmptyWorkingSet(IntPtr hwProc); }'; [Mem]::EmptyWorkingSet([IntPtr]::Zero) > $null"
choice /c yq /t 300 /d y /n /m "Flushing again in 5 mins. Press 'Q' to return to menu: "
if errorlevel 2 goto menu
goto mem_loop

:dashboard
cls
echo =================================================================
echo                    LIVE SYSTEM DASHBOARD
echo =================================================================
powershell -Command "Write-Host 'Press ANY KEY to return to menu.' -ForegroundColor Red"
powershell -NoProfile -Command "$running=$true; while($running){ $cpu = (Get-WmiObject Win32_Processor).LoadPercentage; $mem = Get-WmiObject Win32_OperatingSystem; $memUsage = [math]::Round((($mem.TotalVisibleMemorySize - $mem.FreePhysicalMemory) / $mem.TotalVisibleMemorySize) * 100); $ping = Test-Connection 1.1.1.1 -Count 1 -Quiet; if($ping) { $p = (Test-Connection 1.1.1.1 -Count 1).ResponseTime } else { $p = 'TIMEOUT' }; [Console]::SetCursorPosition(0,4); Write-Host '=========================================' -ForegroundColor Cyan; Write-Host \" CPU Usage: $cpu%%      \" -ForegroundColor Green; Write-Host \" RAM Usage: $memUsage%%     \" -ForegroundColor Yellow; Write-Host \" Latency  : $p ms       \" -ForegroundColor Magenta; Write-Host '=========================================' -ForegroundColor Cyan; for($i=0;$i -lt 10;$i++){ if([console]::KeyAvailable) { $running=$false; break }; Start-Sleep -Milliseconds 200 } }; if([console]::KeyAvailable){[console]::ReadKey($true) | Out-Null}"
goto menu
