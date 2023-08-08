function Get-ShaCryptHashRaw ($Hasher, $Password, $Salt, $Rounds)
{
    function Hex ($ByteArray)
    {
        ($ByteArray | ForEach-Object -Process {$_.ToString("x2")}) -join ''
    }

    function Repeat ([array] $Array, [uint16] $Count)
    {
        $Array * [System.Math]::Ceiling($Count / $Array.Length) | Select-Object -First $Count
    }

    $password_len = $Password.Length
    $salt_len     = $Salt.Length

    # Digest B
    [byte[]] $b_ctx = $Password + $Salt + $Password
    #Write-Host -Object "Digest B ctx: $(Hex $b_ctx)"
    [byte[]] $db = $Hasher.ComputeHash($b_ctx)
    #Write-Host -Object "Digest B    : $(Hex $db)"

    # Digest A
    [byte[]] $a_ctx = $Password + $Salt + (Repeat $db $password_len)
    $i = $password_len
    while ($i)
    {
        $a_ctx += if ($i -band 1) {$db} else {$Password}
        $i = $i -shr 1
    }
    #Write-Host -Object "Digest A ctx: $(Hex $a_ctx)"
    [byte[]] $da = $Hasher.ComputeHash($a_ctx)
    #Write-Host -Object "Digest A    : $(Hex $da)"

    # Digest P
    [byte[]] $p_ctx = $Password * $password_len
    #Write-Host -Object "Digest P ctx: $(Hex $p_ctx)"
    [byte[]] $dp = $Hasher.ComputeHash($p_ctx)
    #Write-Host -Object "Digest P tmp: $(Hex $dp)"
    $dp = Repeat $dp $password_len
    #Write-Host -Object "Digest P    : $(Hex $dp)"

    # Digest S
    [byte[]] $s_ctx = $Salt * (16 + $da[0])
    #Write-Host -Object "Digest S ctx: $(Hex $s_ctx)"
    [byte[]] $ds = $Hasher.ComputeHash($s_ctx)
    #Write-Host -Object "Digest S tmp: $(Hex $ds)"
    $ds = Repeat $ds $salt_len
    #Write-Host -Object "Digest S    : $(Hex $ds)"

    # Loop
    [byte[]] $dc = $da
    for ($i = 0; $i -lt $Rounds ; $i++)
    {
        [byte[]] $c_ctx = if ($i % 2) {$dp} else {$dc}
        if ($i % 3) {$c_ctx += $ds}
        if ($i % 7) {$c_ctx += $dp}
        $c_ctx += if ($i % 2) {$dc} else {$dp}
        $dc = $Hasher.ComputeHash($c_ctx)
    }
    #Write-Host -Object "Digest C    : $(Hex $dc)"

    # Return
    $dc
}
