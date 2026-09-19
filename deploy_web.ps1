param(
    [switch]$Test
)

$ErrorActionPreference = "Stop"

$pubspecPath = Join-Path $PSScriptRoot "pubspec.yaml"
$versionJsonPath = Join-Path $PSScriptRoot "build\web\version.json"

# Se placer automatiquement a la racine du projet.
Set-Location $PSScriptRoot

# Lecture de la version actuelle.
$content = Get-Content $pubspecPath -Raw

if ($content -notmatch '(?m)^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$') {
    throw "Impossible de trouver le numero de version dans pubspec.yaml."
}

$major = [int]$Matches[1]
$minor = [int]$Matches[2]
$patch = [int]$Matches[3]
$build = [int]$Matches[4]

$newBuild = $build + 1

$currentVersion = "$major.$minor.$patch+$build"
$newVersion = "$major.$minor.$patch+$newBuild"

Write-Host ""
Write-Host "CourtManager - Deploiement Web"
Write-Host "--------------------------------"
Write-Host "Version actuelle  : $currentVersion"
Write-Host "Prochaine version : $newVersion"

# Mode de simulation.
if ($Test) {
    Write-Host ""
    Write-Host "MODE TEST"
    Write-Host "Aucun numero de version ne sera modifie."
    Write-Host "Aucun build ne sera effectue."
    Write-Host "Aucun deploiement Firebase ne sera effectue."
    Write-Host ""
    Write-Host "TEST OK"
    exit 0
}

# Permet de restaurer exactement le pubspec d'origine
# en cas d'echec avant le deploiement.
$originalContent = $content
$versionModified = $false
$deploymentStarted = $false

try {
    Write-Host ""
    Write-Host "Mise a jour de pubspec.yaml..."

    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)

    $newContent = [regex]::Replace(
        $content,
        '(?m)^version:[^\r\n]*',
        "version: $newVersion"
    )

    [System.IO.File]::WriteAllText(
        $pubspecPath,
        $newContent,
        $utf8NoBom
    )

    $versionModified = $true

    Write-Host "Version positionnee : $newVersion"

    Write-Host ""
    Write-Host "Mise a jour des dependances..."

    flutter pub get

    if ($LASTEXITCODE -ne 0) {
        throw "flutter pub get a echoue."
    }

    Write-Host ""
    Write-Host "Analyse Flutter..."

    flutter analyze

    if ($LASTEXITCODE -ne 0) {
        throw "flutter analyze a echoue."
    }

    Write-Host ""
    Write-Host "Build Web..."

    flutter build web

    if ($LASTEXITCODE -ne 0) {
        throw "flutter build web a echoue."
    }

    if (-not (Test-Path $versionJsonPath)) {
        throw "build\web\version.json introuvable."
    }

    $versionInfo = Get-Content $versionJsonPath -Raw |
        ConvertFrom-Json

    $builtVersion =
        "$($versionInfo.version)+$($versionInfo.build_number)"

    Write-Host ""
    Write-Host "Version generee : $builtVersion"

    if ($builtVersion -ne $newVersion) {
        throw "La version generee ($builtVersion) ne correspond pas a la version attendue ($newVersion)."
    }

    Write-Host ""
    Write-Host "Tous les controles sont OK."
    Write-Host "Deploiement Firebase Hosting..."

    # A partir d'ici, on ne restaure plus automatiquement
    # le numero de version : Firebase peut avoir commence
    # a publier certains fichiers.
    $deploymentStarted = $true

    firebase deploy --only hosting:tcodon

    if ($LASTEXITCODE -ne 0) {
        throw "Le deploiement Firebase a echoue."
    }

    Write-Host ""
    Write-Host "--------------------------------"
    Write-Host "DEPLOIEMENT TERMINE"
    Write-Host "CourtManager Web : $newVersion"
    Write-Host "--------------------------------"
}
catch {
    Write-Host ""
    Write-Host "ERREUR : $($_.Exception.Message)"

    if ($versionModified -and -not $deploymentStarted) {
        Write-Host ""
        Write-Host "Restauration de pubspec.yaml..."

        $utf8NoBom = New-Object System.Text.UTF8Encoding($false)

        [System.IO.File]::WriteAllText(
            $pubspecPath,
            $originalContent,
            $utf8NoBom
        )

        Write-Host "Version restauree : $currentVersion"

        # pubspec.lock peut avoir ete adapte par flutter pub get.
        # On resynchronise les dependances avec la version restauree.
        flutter pub get | Out-Null
    }

    exit 1
}
