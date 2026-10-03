@echo off
chcp 65001 >nul
setlocal
cd /d "%~dp0"

echo ===================================================
echo   Coffee Shop Management System
echo ===================================================

REM ----------------------------------------------------
REM 1. Kiem tra va tim kiem JDK (javac & java)
REM ----------------------------------------------------
set "JAVAC_CMD="
set "JAVA_CMD="

REM Kiem tra trong PATH
where javac >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    set "JAVAC_CMD=javac"
    set "JAVA_CMD=java"
)

REM Kiem tra JAVA_HOME neu chua co trong PATH
if not defined JAVAC_CMD (
    if defined JAVA_HOME (
        if exist "%JAVA_HOME%\bin\javac.exe" (
            set "JAVAC_CMD=%JAVA_HOME%\bin\javac.exe"
            set "JAVA_CMD=%JAVA_HOME%\bin\java.exe"
        )
    )
)

REM Tim kiem trong cac thu muc cai dat pho bien
if not defined JAVAC_CMD (
    for /d %%D in (
        "C:\Program Files\Eclipse Adoptium\jdk-2*"
        "C:\Program Files\Java\jdk-2*"
        "C:\Program Files\BellSoft\LibericaJDK-2*"
        "C:\Program Files\Amazon Corretto\jdk2*"
        "C:\Program Files\Microsoft\jdk-2*"
        "C:\Program Files\Java\jdk*"
    ) do (
        if not defined JAVAC_CMD (
            if exist "%%~fD\bin\javac.exe" (
                set "JAVAC_CMD=%%~fD\bin\javac.exe"
                set "JAVA_CMD=%%~fD\bin\java.exe"
            )
        )
    )
)

REM Neu van khong tim thay JDK, bao loi chi tiet
if not defined JAVAC_CMD (
    echo.
    echo ===================================================================
    echo [LOI] Khong tim thay trinh bien dich Java (JDK - javac).
    echo ===================================================================
    echo Nguyen nhan pho bien tren may tinh khac:
    echo  1. Laptop chua cai dat JDK (Java Development Kit) 21 tro len.
    echo     (Luu y: May chi co JRE thuong khong co javac de bien dich ma nguon).
    echo  2. Da cai JDK nhung chua tich hop vao bien moi truong PATH.
    echo.
    echo Cach khac phuc:
    echo  - Tai va cai dat JDK 21 mien phi tai:
    echo    https://adoptium.net/temurin/releases/?version=21
    echo  - Trong luc cai dat, hay tich chon [Add to PATH] va [Set JAVA_HOME].
    echo  - Sau khi cai xong, khoi dong lai CMD hoac mo lai file run.bat.
    echo ===================================================================
    echo.
    pause
    exit /b 1
)

echo [OK] Su dung Java tai:
"%JAVA_CMD%" -version
echo.

REM ----------------------------------------------------
REM 2. Tao thu muc out va sao chep tai nguyen
REM ----------------------------------------------------
echo [1/3] Tao thu muc out...
if not exist out mkdir out

echo [2/3] Sao chep tai nguyen (FXML, CSS, anh, properties)...
xcopy /E /Y /I /Q src out >nul
del /S /Q out\*.java >nul 2>&1

REM ----------------------------------------------------
REM 3. Bien dich ma nguon Java
REM ----------------------------------------------------
echo [3/3] Bien dich ma nguon Java (UTF-8)...
dir /s /b src\*.java > "%TEMP%\csms_sources.txt"

"%JAVAC_CMD%" -encoding UTF-8 --module-path lib --add-modules javafx.controls,javafx.fxml,javafx.graphics,javafx.media,javafx.web -cp "lib/*" -d out @"%TEMP%\csms_sources.txt"
set "BUILD_STATUS=%ERRORLEVEL%"
if exist "%TEMP%\csms_sources.txt" del "%TEMP%\csms_sources.txt" >nul 2>&1

if %BUILD_STATUS% EQU 0 (
    echo.
    echo ===================================================
    echo   Bien dich thanh cong! Dang mo ung dung...
    echo ===================================================
    "%JAVA_CMD%" -Dfile.encoding=UTF-8 -Djava.library.path="bin;lib" --module-path lib --add-modules javafx.controls,javafx.fxml,javafx.graphics,javafx.media,javafx.web -cp "out;lib/sqlite-jdbc-3.51.0.0.jar" view.Main
) else (
    echo.
    echo ===================================================
    echo [LOI] Bien dich that bai.
    echo Vui long kiem tra:
    echo  - Phien ban JDK phai tu Java 21 tro len.
    echo  - Toan bo thu muc src va lib da duoc giai nen day du.
    echo ===================================================
)

pause

