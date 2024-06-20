@echo off

:: Run as Admin
FSUTIL DIRTY query %SYSTEMDRIVE% >nul || (
    %windir%\System32\WindowsPowershell\v1.0\powershell.exe "Start-Process -FilePath %COMSPEC% -Args '/C CHDIR /D %CD% & "%0"' -Verb RunAs"
    EXIT
)



reg add "HKEY_CLASSES_ROOT\SystemFileAssociations\.png\shell\Imgur single upload" /t REG_SZ /f /v "Icon" /d imageres.dll,-5339"
reg add "HKEY_CLASSES_ROOT\SystemFileAssociations\.png\shell\Imgur single upload\command" /t REG_SZ /f /v "" /d "\"%windir%\System32\WindowsPowershell\v1.0\powershell.exe\" -WindowStyle Hidden -NoProfile -NoLogo -ExecutionPolicy Bypass -File \"%~dp0Imgur-Uploader.ps1\" \"%%V"\""

reg add "HKEY_CLASSES_ROOT\SystemFileAssociations\.jpg\shell\Imgur single upload" /t REG_SZ /f /v "Icon" /d imageres.dll,-5339"
reg add "HKEY_CLASSES_ROOT\SystemFileAssociations\.jpg\shell\Imgur single upload\command" /t REG_SZ /f /v "" /d "\"%windir%\System32\WindowsPowershell\v1.0\powershell.exe\" -WindowStyle Hidden -NoProfile -NoLogo -ExecutionPolicy Bypass -File \"%~dp0Imgur-Uploader.ps1\" \"%%V"\""

reg add "HKEY_CLASSES_ROOT\SystemFileAssociations\.jpeg\shell\Imgur single upload" /t REG_SZ /f /v "Icon" /d imageres.dll,-5339"
reg add "HKEY_CLASSES_ROOT\SystemFileAssociations\.jpeg\shell\Imgur single upload\command" /t REG_SZ /f /v "" /d "\"%windir%\System32\WindowsPowershell\v1.0\powershell.exe\" -WindowStyle Hidden -NoProfile -NoLogo -ExecutionPolicy Bypass -File \"%~dp0Imgur-Uploader.ps1\" \"%%V"\""

reg add "HKEY_CLASSES_ROOT\SystemFileAssociations\.gif\shell\Imgur single upload" /t REG_SZ /f /v "Icon" /d imageres.dll,-5339"
reg add "HKEY_CLASSES_ROOT\SystemFileAssociations\.gif\shell\Imgur single upload\command" /t REG_SZ /f /v "" /d "\"%windir%\System32\WindowsPowershell\v1.0\powershell.exe\" -WindowStyle Hidden -NoProfile -NoLogo -ExecutionPolicy Bypass -File \"%~dp0Imgur-Uploader.ps1\" \"%%V"\""

reg add "HKEY_CLASSES_ROOT\SystemFileAssociations\.apng\shell\Imgur single upload" /t REG_SZ /f /v "Icon" /d imageres.dll,-5339"
reg add "HKEY_CLASSES_ROOT\SystemFileAssociations\.apng\shell\Imgur single upload\command" /t REG_SZ /f /v "" /d "\"%windir%\System32\WindowsPowershell\v1.0\powershell.exe\" -WindowStyle Hidden -NoProfile -NoLogo -ExecutionPolicy Bypass -File \"%~dp0Imgur-Uploader.ps1\" \"%%V"\""

reg add "HKEY_CLASSES_ROOT\SystemFileAssociations\.tiff\shell\Imgur single upload" /t REG_SZ /f /v "Icon" /d imageres.dll,-5339"
reg add "HKEY_CLASSES_ROOT\SystemFileAssociations\.tiff\shell\Imgur single upload\command" /t REG_SZ /f /v "" /d "\"%windir%\System32\WindowsPowershell\v1.0\powershell.exe\" -WindowStyle Hidden -NoProfile -NoLogo -ExecutionPolicy Bypass -File \"%~dp0Imgur-Uploader.ps1\" \"%%V"\""

reg add "HKEY_CLASSES_ROOT\SystemFileAssociations\.tif\shell\Imgur single upload" /t REG_SZ /f /v "Icon" /d imageres.dll,-5339"
reg add "HKEY_CLASSES_ROOT\SystemFileAssociations\.tif\shell\Imgur single upload\command" /t REG_SZ /f /v "" /d "\"%windir%\System32\WindowsPowershell\v1.0\powershell.exe\" -WindowStyle Hidden -NoProfile -NoLogo -ExecutionPolicy Bypass -File \"%~dp0Imgur-Uploader.ps1\" \"%%V"\""

REM reg add "HKEY_CLASSES_ROOT\SystemFileAssociations\.mp4\shell\Imgur single upload" /t REG_SZ /f /v "Icon" /d imageres.dll,-5339"
REM reg add "HKEY_CLASSES_ROOT\SystemFileAssociations\.mp4\shell\Imgur single upload\command" /t REG_SZ /f /v "" /d "\"%windir%\System32\WindowsPowershell\v1.0\powershell.exe\" -WindowStyle Hidden -NoProfile -NoLogo -ExecutionPolicy Bypass -File \"%~dp0Imgur-Uploader.ps1\" \"%%V"\""

REM reg add "HKEY_CLASSES_ROOT\SystemFileAssociations\.avi\shell\Imgur single upload" /t REG_SZ /f /v "Icon" /d imageres.dll,-5339"
REM reg add "HKEY_CLASSES_ROOT\SystemFileAssociations\.avi\shell\Imgur single upload\command" /t REG_SZ /f /v "" /d "\"%windir%\System32\WindowsPowershell\v1.0\powershell.exe\" -WindowStyle Hidden -NoProfile -NoLogo -ExecutionPolicy Bypass -File \"%~dp0Imgur-Uploader.ps1\" \"%%V"\""

REM reg add "HKEY_CLASSES_ROOT\SystemFileAssociations\.mpeg\shell\Imgur single upload" /t REG_SZ /f /v "Icon" /d imageres.dll,-5339"
REM reg add "HKEY_CLASSES_ROOT\SystemFileAssociations\.mpeg\shell\Imgur single upload\command" /t REG_SZ /f /v "" /d "\"%windir%\System32\WindowsPowershell\v1.0\powershell.exe\" -WindowStyle Hidden -NoProfile -NoLogo -ExecutionPolicy Bypass -File \"%~dp0Imgur-Uploader.ps1\" \"%%V"\""

REM reg add "HKEY_CLASSES_ROOT\SystemFileAssociations\.webm\shell\Imgur single upload" /t REG_SZ /f /v "Icon" /d imageres.dll,-5339"
REM reg add "HKEY_CLASSES_ROOT\SystemFileAssociations\.webm\shell\Imgur single upload\command" /t REG_SZ /f /v "" /d "\"%windir%\System32\WindowsPowershell\v1.0\powershell.exe\" -WindowStyle Hidden -NoProfile -NoLogo -ExecutionPolicy Bypass -File \"%~dp0Imgur-Uploader.ps1\" \"%%V"\""


reg add "HKEY_CLASSES_ROOT\DesktopBackground\Shell\Imgur clipboard upload (from link and file)" /t REG_SZ /f /v "Icon" /d imageres.dll,-5339"
reg add "HKEY_CLASSES_ROOT\DesktopBackground\Shell\Imgur clipboard upload (from link and file)\Command" /t REG_SZ /f /v "" /d "\"%windir%\System32\WindowsPowershell\v1.0\powershell.exe\" -WindowStyle Hidden -NoProfile -NoLogo -ExecutionPolicy Bypass -File \"%~dp0Imgur-Uploader.ps1\"
reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\Imgur clipboard upload (from link and file)" /t REG_SZ /f /v "Icon" /d imageres.dll,-5339"
reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\Imgur clipboard upload (from link and file)\command" /t REG_SZ /f /v "" /d "\"%windir%\System32\WindowsPowershell\v1.0\powershell.exe\" -WindowStyle Hidden -NoProfile -NoLogo -ExecutionPolicy Bypass -File \"%~dp0Imgur-Uploader.ps1\"


reg add "HKEY_CLASSES_ROOT\Directory\shell\Imgur album upload" /t REG_SZ /f /v "Icon" /d imageres.dll,-5339"
reg add "HKEY_CLASSES_ROOT\Directory\shell\Imgur album upload\command" /t REG_SZ /f /v "" /d "\"%windir%\System32\WindowsPowershell\v1.0\powershell.exe\" -WindowStyle Hidden -NoProfile -NoLogo -ExecutionPolicy Bypass -File \"%~dp0Imgur-Uploader.ps1\" \"%%V"\""

exit /b
