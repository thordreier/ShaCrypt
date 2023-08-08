function New-ShaPassword
{
    <#
        .SYNOPSIS
            Create SHA password hash for use in Linux /etc/shadow file

        .DESCRIPTION
            Hash the password with either sha256crypt or sha512crypt

        .PARAMETER Password
            Must be of type [String], [SecureString], [PSCredential] or [Byte[]]
            Must be at least one character long

        .PARAMETER Salt
            Must be either [String] or [Byte[]]
            Must be 8 to 16 characters long

        .PARAMETER Rounds
            Rounds

        .PARAMETER Sha512
            SHA-512 (sha512crypt), this is the default

        .PARAMETER Sha256
            SHA-256 (sha256crypt)

        .PARAMETER OutputAll
            Normal output. Output the string to use in /etc/password

        .PARAMETER OutputHashOnly
            Just output the hashed password without salt, rounds, version and dollar signs

        .EXAMPLE
            $hash = New-ShaPassword -Password Password1
    #>

    [CmdletBinding(DefaultParameterSetName='Sha512All')]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [object]
        $Password,

        [Parameter()]
        [PSObject]
        $Salt = $null,

        [Parameter()]
        [uint32]
        $Rounds,

        [Parameter(ParameterSetName = 'Sha512All')]
        [Parameter(ParameterSetName = 'Sha512HashOnly')]
        [switch]
        $Sha512,

        [Parameter(ParameterSetName = 'Sha256All',      Mandatory = $true)]
        [Parameter(ParameterSetName = 'Sha256HashOnly', Mandatory = $true)]
        [switch]
        $Sha256,

        [Parameter(ParameterSetName = 'Sha256All')]
        [Parameter(ParameterSetName = 'Sha512All')]
        [switch]
        $OutputAll,

        [Parameter(ParameterSetName = 'Sha256HashOnly', Mandatory = $true)]
        [Parameter(ParameterSetName = 'Sha512HashOnly', Mandatory = $true)]
        [switch]
        $OutputHashOnly
    )

    begin
    {
        Write-Verbose -Message "Begin (ErrorActionPreference: $ErrorActionPreference)"
        $origErrorActionPreference = $ErrorActionPreference
        $origErrorActionPreferenceGlobal = $global:ErrorActionPreference

        # ValidateScript process each element of an array individually, so we put it here instead
        try
        {
            if (
                ($Salt -ne $null -or $Salt -is [array]) -and  # For some reason both  @()-eq$null-and$true  and  @()-ne$null-and$true returns $False!!!!
                (
                    ($Salt -is [array] -and (($sTmp = [byte[]] $Salt) -or $true)) -or
                    (($sTmp = [string] $Salt) -or $true)
                ) -and
                ($sTmp.Length -lt 8 -or $sTmp.Length -gt 16)
            )
            {
                throw
            }
        }
        catch
        {
            throw 'Salt must be string or byte array with length between 8 and 16'
        }

        $defaultRounds = 5000
        $charMapSha = './0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'.ToCharArray()
        $orderMapSha256 = @(
            @(20, 10,  0),
            @(11,  1, 21),
            @( 2, 22, 12),
            @(23, 13,  3),
            @(14,  4, 24),
            @( 5, 25, 15),
            @(26, 16,  6),
            @(17,  7, 27),
            @( 8, 28, 18),
            @(29, 19,  9),
            @(30, 31)
        )
        $orderMapSha512 = @(
            @(42, 21,  0),
            @( 1, 43, 22),
            @(23,  2, 44),
            @(45, 24,  3),
            @( 4, 46, 25),
            @(26,  5, 47),
            @(48, 27,  6),
            @( 7, 49, 28),
            @(29,  8, 50),
            @(51, 30,  9),
            @(10, 52, 31),
            @(32, 11, 53),
            @(54, 33, 12),
            @(13, 55, 34),
            @(35, 14, 56),
            @(57, 36, 15),
            @(16, 58, 37),
            @(38, 17, 59),
            @(60, 39, 18),
            @(19, 61, 40),
            @(41, 20, 62),
            @(63)
        )

        if (-not $Rounds)
        {
            $Rounds = $defaultRounds
        }
        elseif ($Rounds -lt 1000)
        {
            'Rounds is {0} (<1000), changing it to 1000' -f $Rounds | Write-Verbose
            $Rounds = 1000
        }
        elseif ($Rounds -gt 999999999)
        {
            'Rounds is {0} (<999999999), changing it to 999999999' -f $Rounds | Write-Verbose
            $Rounds = 999999999
        }
    }

    process
    {
        Write-Verbose -Message "Process begin (ErrorActionPreference: $ErrorActionPreference)"

        try
        {
            # Stop and catch all errors. Local ErrorAction isn't propagate when calling functions in other modules
            $global:ErrorActionPreference = $ErrorActionPreference = 'Stop'

            # Non-boilerplate stuff starts here

            [byte[]] $passwordA = @()
            if ($Password -is [PSCredential])
            {
                $passwordA = [System.Text.Encoding]::UTF8.GetBytes([string] ($Password.GetNetworkCredential().Password))
            }
            elseif ($Password -is [SecureString])
            {
                $passwordA = [System.Text.Encoding]::UTF8.GetBytes([string] ([pscredential]::new('username', $Password).GetNetworkCredential().Password))
            }
            elseif ($Password -is [array])
            {
                try
                {
                    $passwordA = $Password
                }
                catch
                {
                    throw 'Password must be of type [String], [SecureString], [PSCredential] or [Byte[]]'
                }
            }
            else
            {
                $passwordA = [System.Text.Encoding]::UTF8.GetBytes([string] $Password)
            }

            if (-not $passwordA.Length)
            {
                throw 'Length of password must be at least one character'
            }

            [byte[]] $saltA = @()
            if (-not $Salt)
            {
                # This is not Cryptography Secure Randomness!!
                $saltA = $charMapSha | Get-Random -Count 16
            }
            elseif ($Salt -is [array])
            {
                $saltA = $Salt
            }
            else
            {
                $saltA = [System.Text.Encoding]::UTF8.GetBytes([string] $Salt)
            }

            if ($Sha256)
            {
                $hasher   = [System.Security.Cryptography.SHA256CryptoServiceProvider]::new()
                $orderMap = $orderMapSha256
                $prefix   = '5'
            }
            else
            {
                $hasher   = [System.Security.Cryptography.SHA512CryptoServiceProvider]::new()
                $orderMap = $orderMapSha512
                $prefix   = '6'
            }

            $hashByteArray = Get-ShaCryptHashRaw -Hasher $hasher -Password $passwordA -Salt $saltA -Rounds $Rounds
            $hashString = Convert-ByteArrayToMappedBase64 -ByteArray $hashByteArray -OrderMap $orderMap -CharMap $charMapSha

            if ($OutputHashOnly)
            {
                $hashString
            }
            else
            {
                $roundsString = if ($Rounds -eq $defaultRounds) {''} else {'$rounds=' + $Rounds}
                $saltString = ([char[]] $saltA) -join ''
                '$' + $prefix + $roundsString + '$' + $saltString + '$' + $hashString
            }

            # Non-boilerplate stuff ends here
        }
        catch
        {
            # If error was encountered inside this function then stop processing
            # But still respect the ErrorAction that comes when calling this function
            # And also return the line number where the original error occured
            $msg = $_.ToString() + "`r`n" + $_.InvocationInfo.PositionMessage.ToString()
            Write-Verbose -Message "Encountered an error: $msg"
            Write-Error -ErrorAction $origErrorActionPreference -Exception $_.Exception -Message $msg
        }
        finally
        {
            # Clean up ErrorAction
            $global:ErrorActionPreference = $origErrorActionPreferenceGlobal
        }

        Write-Verbose -Message 'Process end'
    }

    end
    {
        Write-Verbose -Message 'End'
    }
}
