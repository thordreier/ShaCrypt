$hash = New-ShaPassword -Password Password1       # Hash can be used in /etc/shadow file on Linux

Test-ShaPassword -Password Password1 -Hash $hash  # Returns $true
Test-ShaPassword -Password Password2 -Hash $hash  # Returns $false

# Use SHA-256 instead of SHA-512, custom SALT and custom ROUNDS
$hash = New-ShaPassword -Password Password1 -Sha256 -Salt between8n16chars -Rounds 2000
