# --- CONFIGURAcÕES ---
$URL_GITHUB = "https://github.com/Heulles/webposto/raw/refs/heads/main/qrcode.zip" 
$PASTA_DESTINO = "C:\Quality\Interface"
$EXE_NOME = "GeradorQR.exe"
$ATALHO_NOME = "Gerador de QrCode.lnk"

# 1. Garantir Privilégios de Administrador
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Solicitando permissao de administrador..." -ForegroundColor Yellow
    Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "--- INICIANDO INSTALAcaO QUALITY PAY ---" -ForegroundColor Cyan
Write-Host "----------------------------------------"

# 2. Criar e Limpar o Diretório de Destino
if (!(Test-Path $PASTA_DESTINO)) {
    New-Item -ItemType Directory -Force -Path $PASTA_DESTINO | Out-Null
    Write-Host "[+] Pasta $PASTA_DESTINO criada." -ForegroundColor Gray
} else {
    Write-Host "[!] Pasta ja existente. Atualizando arquivos..." -ForegroundColor Gray
}

# 3. Download do Pacote
$zipPath = Join-Path $PASTA_DESTINO "temp_qrcode.zip"
Write-Host "[-] Baixando arquivos do GitHub..." -ForegroundColor Yellow
try {
    # Forca o uso de TLS 1.2 para evitar erros de conexao em maquinas antigas
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $URL_GITHUB -OutFile $zipPath -ErrorAction Stop
} catch {
    Write-Host "[X] ERRO AO BAIXAR: $($_.Exception.Message)" -ForegroundColor Red
    pause; exit
}

# 4. Extracao dos Arquivos
Write-Host "[-] Extraindo arquivos..." -ForegroundColor Yellow
try {
    # Extrai e sobrescreve arquivos existentes (-Force)
    Expand-Archive -Path $zipPath -DestinationPath $PASTA_DESTINO -Force
    Remove-Item $zipPath -Force 
} catch {
    Write-Host "[X] ERRO NA EXTRACAO: Verifique se o GeradorQR.exe esta aberto." -ForegroundColor Red
    pause; exit
}

# 5. Criacao do Atalho na Area de Trabalho
Write-Host "[-] Criando atalho no Desktop..." -ForegroundColor Yellow
try {
    $DesktopPath = [System.IO.Path]::Combine([Environment]::GetFolderPath("Desktop"), $ATALHO_NOME)
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($DesktopPath)
    $Shortcut.TargetPath = Join-Path $PASTA_DESTINO $EXE_NOME
    $Shortcut.WorkingDirectory = $PASTA_DESTINO
    $Shortcut.Description = "Sistema de Geracao de QR Code - Quality Pay"
    $Shortcut.Save()
    Write-Host "[V] ATALHO CRIADO COM SUCESSO!" -ForegroundColor Green
} catch {
    Write-Host "[!] Nao foi possivel criar o atalho automaticamente." -ForegroundColor Yellow
}

Write-Host "----------------------------------------"
Write-Host "INSTALACAO CONCLUIDA!" -ForegroundColor Green
Write-Host "O programa abrira em 3 segundos..."
sleep 3

# Inicia o programa automaticamente apos instalar
Start-Process (Join-Path $PASTA_DESTINO $EXE_NOME)