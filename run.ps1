# Build and Run Coffee Shop Management System (JavaFX + SQLite)
Set-Location -Path $PSScriptRoot

Write-Host "===================================================" -ForegroundColor Cyan
Write-Host "   Coffee Shop Management System - Khởi chạy" -ForegroundColor Cyan
Write-Host "===================================================" -ForegroundColor Cyan

# Kiem tra javac
if (-not (Get-Command javac -ErrorAction SilentlyContinue)) {
    Write-Host "[LOI] Khong tim thay trinh bien dich Java (javac)!" -ForegroundColor Red
    Write-Host "Vui long cai dat JDK 21+ tai: https://adoptium.net/temurin/releases/?version=21" -ForegroundColor Yellow
    Write-Host "Nho chon [Add to PATH] trong luc cai dat." -ForegroundColor Yellow
    Read-Host "Nhan Enter de thoat..."
    exit 1
}

# 1. Tạo thư mục out nếu chưa có
if (!(Test-Path -Path "out")) {
    New-Item -ItemType Directory -Path "out" | Out-Null
}

# 2. Copy file tài nguyên (.fxml, .css, .properties, hình ảnh) sang out
Write-Host "[1/2] Đang sao chép tài nguyên vào out..." -ForegroundColor Yellow
Copy-Item -Path "src\*" -Destination "out" -Recurse -Exclude "*.java" -Force

# 3. Biên dịch tất cả file .java
Write-Host "[2/2] Đang biên dịch mã nguồn Java (UTF-8)..." -ForegroundColor Yellow
$javaFiles = (Get-ChildItem -Path "src" -Recurse -Filter "*.java").FullName
javac -encoding UTF-8 --module-path lib --add-modules javafx.controls,javafx.fxml,javafx.graphics,javafx.media,javafx.web -cp "lib/*" -d out $javaFiles

if ($LASTEXITCODE -eq 0) {
    Write-Host "-> Bien dich thanh cong! Dang khoi dong ung dung..." -ForegroundColor Green
    java -Dfile.encoding=UTF-8 -Djava.library.path="bin;lib" --module-path lib --add-modules javafx.controls,javafx.fxml,javafx.graphics,javafx.media,javafx.web -cp "out;lib/sqlite-jdbc-3.51.0.0.jar" view.Main
} else {
    Write-Host "-> Loi bien dich. Vui long kiem tra lai thong bao o tren." -ForegroundColor Red
}

