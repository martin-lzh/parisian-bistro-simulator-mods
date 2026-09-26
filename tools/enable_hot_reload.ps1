param(
    [Parameter(Mandatory = $true)]
    [string]$Ue4ssDirectory
)

$ErrorActionPreference = 'Stop'
$directory = (Resolve-Path -LiteralPath $Ue4ssDirectory).Path
$settingsPath = Join-Path $directory 'UE4SS-settings.ini'
$originalBytes = [System.IO.File]::ReadAllBytes($settingsPath)
$hasBom = $originalBytes.Length -ge 3 -and $originalBytes[0] -eq 239 -and
    $originalBytes[1] -eq 187 -and $originalBytes[2] -eq 191
$encoding = New-Object System.Text.UTF8Encoding($hasBom, $true)
$null = $encoding.GetString($originalBytes)
$original = [System.IO.File]::ReadAllText($settingsPath, $encoding)
$parts = [regex]::Split($original, '(\r\n|\n|\r)')
$wanted = @{
    EnableHotReloadSystem = '1'
    HotReloadKey = 'R'
    EnableAutoReloadingLuaMods = '0'
}
$seen = @{}
$inGeneral = $false
$generalCount = 0
for ($index = 0; $index -lt $parts.Length; $index += 2) {
    $line = $parts[$index]
    if ($line -match '^\s*\[([^\]]+)\]\s*(?:[;#].*)?$') {
        $inGeneral = $Matches[1].Trim() -eq 'General'
        if ($inGeneral) { $generalCount++ }
    }
    if (-not $inGeneral) { continue }
    if ($line -match '^(\s*(\w+)\s*=\s*)([^;#]*?)(\s*(?:[;#].*)?)$') {
        $key = $Matches[2]
        if ($wanted.ContainsKey($key)) {
            if ($seen.ContainsKey($key)) { throw "Duplicate General setting: $key" }
            $seen[$key] = $true
            $parts[$index] = $Matches[1] + $wanted[$key] + $Matches[4]
        }
    }
}
if ($generalCount -ne 1 -or $seen.Count -ne $wanted.Count) {
    throw 'Expected one [General] section with all three hot reload settings. Use the required UE4SS experimental loader.'
}
$updated = $parts -join ''
if ($updated -eq $original) {
    Write-Output "Already configured: $settingsPath"
    exit 0
}

# Back up exact bytes; never replace the entire loader configuration with a
# template or change the game process, Mod files, preferences or saves.
$backupPath = $settingsPath + '.before-hot-reload-' + [guid]::NewGuid().ToString('N') + '.bak'
[System.IO.File]::Copy($settingsPath, $backupPath, $false)
[System.IO.File]::WriteAllText($settingsPath, $updated, $encoding)
Write-Output "Configured Ctrl+R: $settingsPath"
Write-Output "Backup: $backupPath"
Write-Output 'Install the reload-aware Mod versions with the game closed, then start the game. Configuration takes effect on the next launch. Automatic file watching is disabled.'
