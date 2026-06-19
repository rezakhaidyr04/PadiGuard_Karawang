# restart_tunnel.ps1
# Jalankan script ini setiap kali tunnel localhost.run mati
# Cara: klik kanan -> Run with PowerShell

Write-Host "=== PadiGuard Tunnel Restart ===" -ForegroundColor Cyan
Write-Host "Memulai tunnel baru..." -ForegroundColor Yellow

# Mulai SSH tunnel di background
$job = Start-Job -ScriptBlock {
    ssh -o StrictHostKeyChecking=no -R 80:localhost:8000 nokey@localhost.run 2>&1
}

# Tunggu URL muncul
$url = ""
$attempts = 0
while ($url -eq "" -and $attempts -lt 20) {
    Start-Sleep -Seconds 2
    $output = Receive-Job $job
    $match = $output | Select-String -Pattern "https://[a-z0-9]+\.lhr\.life"
    if ($match) {
        $url = $match.Matches[0].Value
    }
    $attempts++
}

if ($url -ne "") {
    Write-Host ""
    Write-Host "✅ TUNNEL AKTIF!" -ForegroundColor Green
    Write-Host "URL: $url" -ForegroundColor Green
    Write-Host ""
    
    # Update api_config.dart otomatis
    $configFile = ".\lib\core\config\api_config.dart"
    if (Test-Path $configFile) {
        $content = Get-Content $configFile -Raw
        $newContent = $content -replace "https://[a-z0-9]+\.lhr\.life", $url
        Set-Content $configFile $newContent
        Write-Host "✅ api_config.dart diupdate ke: $url" -ForegroundColor Green
        Write-Host ""
        Write-Host "Langkah selanjutnya:" -ForegroundColor Yellow
        Write-Host "  1. Di VS Code/Android Studio: Hot Restart (Shift+R)" -ForegroundColor White
        Write-Host "  2. Atau Stop & Run ulang Flutter" -ForegroundColor White
    } else {
        Write-Host "⚠️  File api_config.dart tidak ditemukan. Update manual:" -ForegroundColor Yellow
        Write-Host "     return '$url';" -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "Tekan Ctrl+C untuk menghentikan tunnel..." -ForegroundColor Gray
    
    # Keep the job running
    Wait-Job $job
} else {
    Write-Host "❌ Gagal mendapat URL tunnel. Coba lagi." -ForegroundColor Red
    Stop-Job $job
}

Remove-Job $job -Force
