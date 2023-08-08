# Invoke-Pester -Path .\Pester\Test-ShaPassword.Tests.ps1 -Output Detailed
Describe 'Test-ShaPassword' {

    Context TestCasesParams1 {
        $testCasesParams1 = @(
            @{Password = ''          ; Hash = ''                                                                                                           ; Output = $false}
            @{Password = 'Password'  ; Hash = ''                                                                                                           ; Output = $false}
            @{Password = ''          ; Hash = 'HashHash'                                                                                                   ; Output = $false}
            @{Password = ''          ; Hash = '$1$zaqxswcde$zxzxzxzxzxzxzx'                                                                                ; Output = $false}
            @{Password = 'Password1' ; Hash = '$6$1mxztcrEo.gQ3LYM$07Kmg7oZALXgChx9IkitrG7umQG/8BRV0EGBeXnWagNIRFAb6YwdGOQEQ4xOm2iAXN/bU4.xjCP85z3CIQrZw0' ; Output = $true }
            @{Password = 'Password2' ; Hash = '$6$1mxztcrEo.gQ3LYM$07Kmg7oZALXgChx9IkitrG7umQG/8BRV0EGBeXnWagNIRFAb6YwdGOQEQ4xOm2iAXN/bU4.xjCP85z3CIQrZw0' ; Output = $false}
            @{Password = ''          ; Hash = '$6$1mxztcrEo.gQ3LYM$07Kmg7oZALXgChx9IkitrG7umQG/8BRV0EGBeXnWagNIRFAb6YwdGOQEQ4xOm2iAXN/bU4.xjCP85z3CIQrZw0' ; Output = $false}
        )

        It 'Test-ShaPassword -Password <Password> -Hash <Hash> == <Output>)' -TestCases $testCasesParams1 {
            param ($Password, $Hash, $Output)
            $params = @{
                Password = $Password
                Hash     = $Hash
            }
            Test-ShaPassword @params -ErrorAction Stop | Should -Be $Output
        }
    }

    Context TestWithTestData1 {
        $testData1 = Get-Content -Path .\testdata\testdata.csv | ConvertFrom-Csv -Delimiter ';' | ForEach-Object -Begin {$i=1} -Process {
            @{
                Line     = ++$i
                Password = $_.PASSWORD
                Hash     = $_.HASH
            }
        }
        $testData1 = $testData1 | Where-Object -FilterScript {$_.Rounds -lt 10000 -or -not (Get-Random -Maximum 20)}  # Testing takes forever, so we just take 5% of the big ones
        $testData1Success = $testData1 | Get-Random -Count 10
        $testData1Fail = $testData1 | Get-Random -Count 10 | ForEach-Object -Process {
            $_.Password += '.'
            $_
        }

        It '<Line>: Test-ShaPassword -Password <Password> -Hash <Hash> == true' -TestCases $testData1Success {
            param ($Line, $Method, $Password, $Salt, $Rounds, $Hash)
            $params = @{
                Password  = $Password
                Hash      = $Hash
            }
            Test-ShaPassword @params -ErrorAction Stop | Should -Be $true
        }

        It '<Line>: Test-ShaPassword -Password <Password> -Hash <Hash> == false' -TestCases $testData1Fail {
            param ($Line, $Method, $Password, $Salt, $Rounds, $Hash)
            $params = @{
                Password  = $Password
                Hash      = $Hash
            }
            Test-ShaPassword @params -ErrorAction Stop | Should -Be $false
        }
    }

}
