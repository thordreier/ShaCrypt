# ShaCrypt

Text in this document is automatically created - don't change it manually

## Index

[New-ShaPassword](#New-ShaPassword)<br>
[Test-ShaPassword](#Test-ShaPassword)<br>

## Functions

<a name="New-ShaPassword"></a>
### New-ShaPassword

```

NAME
    New-ShaPassword
    
SYNOPSIS
    Create SHA password hash for use in Linux /etc/shadow file
    
    
SYNTAX
    New-ShaPassword -Password <Object> [-Salt <PSObject>] [-Rounds <UInt32>] [-Sha512] [-OutputAll] [<CommonParameters>]
    
    New-ShaPassword -Password <Object> [-Salt <PSObject>] [-Rounds <UInt32>] [-Sha512] -OutputHashOnly [<CommonParameters>]
    
    New-ShaPassword -Password <Object> [-Salt <PSObject>] [-Rounds <UInt32>] -Sha256 -OutputHashOnly [<CommonParameters>]
    
    New-ShaPassword -Password <Object> [-Salt <PSObject>] [-Rounds <UInt32>] -Sha256 [-OutputAll] [<CommonParameters>]
    
    
DESCRIPTION
    Hash the password with either sha256crypt or sha512crypt
    

PARAMETERS
    -Password <Object>
        Must be of type [String], [SecureString], [PSCredential] or [Byte[]]
        Must be at least one character long
        
    -Salt <PSObject>
        Must be either [String] or [Byte[]]
        Must be 8 to 16 characters long
        
    -Rounds <UInt32>
        Rounds
        
    -Sha512 [<SwitchParameter>]
        SHA-512 (sha512crypt), this is the default
        
    -Sha256 [<SwitchParameter>]
        SHA-256 (sha256crypt)
        
    -OutputAll [<SwitchParameter>]
        Normal output. Output the string to use in /etc/password
        
    -OutputHashOnly [<SwitchParameter>]
        Just output the hashed password without salt, rounds, version and dollar signs
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (https:/go.microsoft.com/fwlink/?LinkID=113216). 
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>$hash = New-ShaPassword -Password Password1
    
    
    
    
    
    
REMARKS
    To see the examples, type: "get-help New-ShaPassword -examples".
    For more information, type: "get-help New-ShaPassword -detailed".
    For technical information, type: "get-help New-ShaPassword -full".

```

<a name="Test-ShaPassword"></a>
### Test-ShaPassword

```
NAME
    Test-ShaPassword
    
SYNOPSIS
    Test password hash from /etc/shadow agains a password
    Returns $true if password matches hash, otherwise $false
    
    
SYNTAX
    Test-ShaPassword [-Password] <Object> [-Hash] <String> [<CommonParameters>]
    
    
DESCRIPTION
    Only works with SHA-256 and SHA-512 hashes
    Just returns $false for other types of hashes (eg. MD5 and blowfish)
    

PARAMETERS
    -Password <Object>
        Must be of type [String], [SecureString], [PSCredential] or [Byte[]]
        
    -Hash <String>
        Hash in format found in /etc/shadow
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see 
        about_CommonParameters (https:/go.microsoft.com/fwlink/?LinkID=113216). 
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS C:\>Test-ShaPassword -Password Password1 -Hash '$5$UcRBt/.Teh4lvkLA$0xIrONKLF2exeQlUSKiYo8FieagtIzrovD8Ld19FB.4'
    
    
    
    
    
    
REMARKS
    To see the examples, type: "get-help Test-ShaPassword -examples".
    For more information, type: "get-help Test-ShaPassword -detailed".
    For technical information, type: "get-help Test-ShaPassword -full".

```



