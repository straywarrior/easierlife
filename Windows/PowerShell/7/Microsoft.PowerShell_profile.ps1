$Env:PATH = "C:\Program Files\Vim\vim82;$Env:PATH"
$Env:PATH = "C:\Program Files\Git\cmd;$Env:PATH"
oh-my-posh --init --shell pwsh --config ~/.theme.omp.json | Invoke-Expression
Write-Host -NoNewLine "`e[2 q"
