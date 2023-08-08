function Test-ShaPassword
{
    <#
        .SYNOPSIS
            Test password hash from /etc/shadow agains a password
            Returns $true if password matches hash, otherwise $false

        .DESCRIPTION
            Only works with SHA-256 and SHA-512 hashes
            Just returns $false for other types of hashes (eg. MD5 and blowfish)

        .PARAMETER Password
            Must be of type [String], [SecureString], [PSCredential] or [Byte[]]

        .PARAMETER Hash
            Hash in format found in /etc/shadow

        .EXAMPLE
            Test-ShaPassword -Password Password1 -Hash '$5$UcRBt/.Teh4lvkLA$0xIrONKLF2exeQlUSKiYo8FieagtIzrovD8Ld19FB.4'
    #>

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [object]
        $Password,

        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [System.String]
        $Hash
    )

    Write-Verbose -Message "Begin (ErrorActionPreference: $ErrorActionPreference)"
    $origErrorActionPreference = $ErrorActionPreference
    $origErrorActionPreferenceGlobal = $global:ErrorActionPreference

    try
    {
        # Stop and catch all errors. Local ErrorAction isn't propagate when calling functions in other modules
        $global:ErrorActionPreference = $ErrorActionPreference = 'Stop'

        # Non-boilerplate stuff starts here

        if (
            $Hash -cmatch '^\$(5)(\$rounds=(\d+))?\$([^\$]{8,16})\$([a-zA-Z0-9\.\/]{43})$' -or
            $Hash -cmatch '^\$(6)(\$rounds=(\d+))?\$([^\$]{8,16})\$([a-zA-Z0-9\.\/]{86})$'
        )
        {
            $type = if ($Matches[1] -eq 6) {'Sha512'} else {'Sha256'}
            "Hash is $type" | Write-Verbose

            $params = @{
                "$type"        = $true
                Password       = $Password
                Salt           = $Matches[4]
                OutputHashOnly = $true
            }
            if ($Matches[3]) {$params['Rounds'] = $Matches[3]}
            $expect = $Matches[5]

            # Return
            (New-ShaPassword @params) -ceq $expect
        }
        else
        {
            'Unknown hash type' | Write-Verbose

            # Return
            $false
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

        # Return in case of exception thrown
        $false
    }
    finally
    {
        # Clean up ErrorAction
        $global:ErrorActionPreference = $origErrorActionPreferenceGlobal
    }

    Write-Verbose -Message 'End'
}
