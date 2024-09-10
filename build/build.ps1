param (
    [string]$platform
)

$requiredPackages = @("dune", "menhir", "llvm", "ppx_deriving")

function Check-OpamEnvLinux {
    $opamEnv = $(opam var root)
    if (-not $opamEnv) {
        Write-Host "Running 'eval $(opam env)' on Linux..."
        eval $(opam env)
    } else {
        Write-Host "'opam env' is already set."
    }
}

function Check-OpamEnvWindows {
    $opamEnv = & opam var root
    if (-not $opamEnv) {
        Write-Host "Running 'opam env' on Windows..."
        (& opam env) -split '\r?\n' | ForEach-Object { Invoke-Expression $_ }
    } else {
        Write-Host "'opam env' is already set."
    }
}

function Ensure-Packages {
    foreach ($package in $requiredPackages) {
        $installed = & opam list --installed $package | Select-String $package
        if (-not $installed) {
            Write-Host "Installing $package..."
            & opam install $package
        } else {
            Write-Host "$package is already installed."
        }
    }
}

function Build-Project {
    Write-Host "Building the project using 'dune build'..."
    & dune build

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Project build successful."
    } else {
        Write-Host "Project build failed."
        exit 1
    }
}

if (-not (Get-Command opam -ErrorAction SilentlyContinue)) {
    Write-Host "Opam is not installed. Please install it before running this script."
    exit 1
}

switch ($platform) {
    "linux" {
        Write-Host "Running on Linux..."
        Check-OpamEnvLinux
        Ensure-Packages
        Build-Project
    }
    "windows" {
        Write-Host "Running on Windows..."
        Check-OpamEnvWindows
        Ensure-Packages
        Build-Project
    }
    default {
        Write-Host "Unknown platform. Use 'linux' or 'windows' as an argument."
        exit 1
    }
}