# ShaCrypt

PowerShell module: ShaCrypt.

## Usage

### Examples

```powershell
$hash = New-ShaPassword -Password Password1       # Hash can be used in /etc/shadow file on Linux

Test-ShaPassword -Password Password1 -Hash $hash  # Returns $true
Test-ShaPassword -Password Password2 -Hash $hash  # Returns $false

# Use SHA-256 instead of SHA-512, custom SALT and custom ROUNDS
$hash = New-ShaPassword -Password Password1 -Sha256 -Salt between8n16chars -Rounds 2000

```

Examples are also found in [EXAMPLES.ps1](EXAMPLES.ps1).

### Functions

See [FUNCTIONS.md](FUNCTIONS.md) for documentation of functions in this module.

## Install

### Install module from PowerShell Gallery

```powershell
Install-Module ShaCrypt
```

### Install module from source

```powershell
git clone https://github.com/thordreier/ShaCrypt.git
cd ShaCrypt
git pull
.\Build.ps1 -InstallModule
```
