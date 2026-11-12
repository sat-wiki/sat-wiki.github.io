param(
    [string]$Message = ""
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

$git = "C:\Program Files\Git\cmd\git.exe"
if (-not (Test-Path -LiteralPath $git)) { $git = "git" }

$hugo = (Get-Command hugo -ErrorAction SilentlyContinue).Source
if (-not $hugo) {
    $hugo = Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Packages\Hugo.Hugo.Extended_Microsoft.Winget.Source_8wekyb3d8bbwe\hugo.exe"
}
if (-not (Test-Path -LiteralPath $hugo)) {
    throw "hugo not found. Install Hugo Extended 0.162+ (winget install Hugo.Hugo.Extended)."
}

$build = Join-Path $root ".build"
$manifest = Join-Path $root ".publish-manifest.txt"
$reserved = @("src", ".git", ".build", ".gitignore", ".gitmodules", ".nojekyll", ".publish-manifest.txt", "deploy.ps1", "README.md")

if (Test-Path -LiteralPath $build) { Remove-Item -LiteralPath $build -Recurse -Force }

Write-Host "Building with $hugo"
& $hugo --gc --minify --source (Join-Path $root "src") --destination $build
if ($LASTEXITCODE -ne 0) { throw "hugo build failed" }

# Remove files that were published by a previous build but no longer exist.
if (Test-Path -LiteralPath $manifest) {
    $old = Get-Content -LiteralPath $manifest
    foreach ($rel in $old) {
        if ([string]::IsNullOrWhiteSpace($rel)) { continue }
        $top = ($rel -split "/")[0]
        if ($reserved -contains $top) { continue }
        $full = Join-Path $root $rel
        $inNew = Test-Path -LiteralPath (Join-Path $build $rel)
        if (-not $inNew -and (Test-Path -LiteralPath $full)) {
            Remove-Item -LiteralPath $full -Force
            Write-Host "removed stale $rel"
        }
    }
}

# Publish.
Get-ChildItem -LiteralPath $build -Force | ForEach-Object {
    Copy-Item -LiteralPath $_.FullName -Destination $root -Recurse -Force
}
Set-Content -LiteralPath (Join-Path $root ".nojekyll") -Value "" -NoNewline

$rels = Get-ChildItem -LiteralPath $build -Recurse -File | ForEach-Object {
    $_.FullName.Substring($build.Length + 1) -replace "\\", "/"
}
Set-Content -LiteralPath $manifest -Value $rels -Encoding utf8

# Verify that subresource-integrity hashes in the published HTML still match the
# published files. Any line-ending rewrite between build and publish breaks them
# and browsers then silently refuse to apply CSS/JS.
$bad = @()
$sha = [Security.Cryptography.SHA512]::Create()
Get-ChildItem -LiteralPath $root -Recurse -File -Filter "*.html" |
    Where-Object { $_.FullName -notlike "*\.git\*" -and $_.FullName -notlike "*\.build\*" } |
    ForEach-Object {
        $html = Get-Content -LiteralPath $_.FullName -Raw
        foreach ($m in [regex]::Matches($html, '<(?:script|link)[^>]*integrity="sha512-([^"]+)"[^>]*>')) {
            $tag = $m.Value
            $pathMatch = [regex]::Match($tag, '(?:src|href)="?([^ ">]+)')
            if (-not $pathMatch.Success) { continue }
            $asset = $pathMatch.Groups[1].Value.Trim('"')
            if ($asset -notmatch '^(/css/|/js/|/lib/)') { continue }
            $file = Join-Path $root ($asset.TrimStart('/') -replace '/', '\')
            if (-not (Test-Path -LiteralPath $file)) { $bad += "missing $asset"; continue }
            $actual = [Convert]::ToBase64String($sha.ComputeHash([IO.File]::ReadAllBytes($file)))
            if ($actual -ne $m.Groups[1].Value) { $bad += "hash mismatch $asset" }
        }
    }
if ($bad.Count -gt 0) {
    throw ("Subresource integrity check failed: " + ($bad -join "; ") + ". Check .gitattributes and core.autocrlf.")
}
Write-Host "Integrity check passed."

# Commit and push.
& $git add -A
$status = & $git status --porcelain
if (-not $status) {
    Write-Host "No changes to publish."
    exit 0
}
if ([string]::IsNullOrWhiteSpace($Message)) {
    $Message = "build: publish site $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
}
& $git commit -m $Message
if ($LASTEXITCODE -ne 0) { throw "git commit failed" }
& $git push origin main
if ($LASTEXITCODE -ne 0) { throw "git push failed" }
Write-Host "Published."
