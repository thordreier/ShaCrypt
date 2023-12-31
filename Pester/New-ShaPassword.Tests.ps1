# Invoke-Pester -Path .\Pester\New-ShaPassword.Tests.ps1 -Output Detailed
Describe 'New-ShaPassword' {

    Context TestCasesParams1 {
        $secureString = ConvertTo-SecureString -AsPlainText -Force -String AA
        $psCredential = [pscredential]::new('username', $secureString)
        $testCasesParams1 = @(
            # Why doesn't "Should" have a "BeMatch" parameter!!!!
            @{Params = @{              Salt=12345678; Password='AA'                                                                   } ; OK = $true  ; Output = '$6$12345678$6wsvSxCY9K/GST7DVQbYFCb2S7iw5c.cdXuRSKPB7iBoq/uurCyb8o5v5I4eKEUKd2swqkgRsQ18Nhk.hYw1s1'                    }
            @{Params = @{              Salt=12345678; Password=@(65,65)                                                               } ; OK = $true  ; Output = '$6$12345678$6wsvSxCY9K/GST7DVQbYFCb2S7iw5c.cdXuRSKPB7iBoq/uurCyb8o5v5I4eKEUKd2swqkgRsQ18Nhk.hYw1s1'                    }
            @{Params = @{              Salt=12345678; Password=$secureString                                                          } ; OK = $true  ; Output = '$6$12345678$6wsvSxCY9K/GST7DVQbYFCb2S7iw5c.cdXuRSKPB7iBoq/uurCyb8o5v5I4eKEUKd2swqkgRsQ18Nhk.hYw1s1'                    }
            @{Params = @{              Salt=12345678; Password=$psCredential                                                          } ; OK = $true  ; Output = '$6$12345678$6wsvSxCY9K/GST7DVQbYFCb2S7iw5c.cdXuRSKPB7iBoq/uurCyb8o5v5I4eKEUKd2swqkgRsQ18Nhk.hYw1s1'                    }
            @{Params = @{Password='a';                                                                                                } ; OK = $true  ; Output = '$6$????????????????$??????????????????????????????????????????????????????????????????????????????????????'            }
            @{Params = @{Password='a'; Salt=12345678;                                                                                 } ; OK = $true  ; Output = '$6$????????$??????????????????????????????????????????????????????????????????????????????????????'                    }
            @{Params = @{Password='a';                Rounds=1000;                                                                    } ; OK = $true  ; Output = '$6$rounds=1000$????????????????$??????????????????????????????????????????????????????????????????????????????????????'}
            @{Params = @{Password='a'; Salt=12345678; Rounds=1000;                                                                    } ; OK = $true  ; Output = '$6$rounds=1000$????????$??????????????????????????????????????????????????????????????????????????????????????'        }
            @{Params = @{Password='a';                             Sha512=$true;                                                      } ; OK = $true  ; Output = '$6$????????????????$??????????????????????????????????????????????????????????????????????????????????????'            }
            @{Params = @{Password='a'; Salt=12345678;              Sha512=$true;                                                      } ; OK = $true  ; Output = '$6$????????$??????????????????????????????????????????????????????????????????????????????????????'                    }
            @{Params = @{Password='a';                Rounds=1000; Sha512=$true;                                                      } ; OK = $true  ; Output = '$6$rounds=1000$????????????????$??????????????????????????????????????????????????????????????????????????????????????'}
            @{Params = @{Password='a'; Salt=12345678; Rounds=1000; Sha512=$true;                                                      } ; OK = $true  ; Output = '$6$rounds=1000$????????$??????????????????????????????????????????????????????????????????????????????????????'        }
            @{Params = @{Password='a';                                           Sha256=$true;                                        } ; OK = $true  ; Output = '$5$????????????????$???????????????????????????????????????????'                                                       }
            @{Params = @{Password='a'; Salt=12345678;                            Sha256=$true;                                        } ; OK = $true  ; Output = '$5$????????$???????????????????????????????????????????'                                                               }
            @{Params = @{Password='a';                Rounds=1000;               Sha256=$true;                                        } ; OK = $true  ; Output = '$5$rounds=1000$????????????????$???????????????????????????????????????????'                                           }
            @{Params = @{Password='a'; Salt=12345678; Rounds=1000;               Sha256=$true;                                        } ; OK = $true  ; Output = '$5$rounds=1000$????????$???????????????????????????????????????????'                                                   }
            @{Params = @{Password='a';                                                         OutputAll=$true;                       } ; OK = $true  ; Output = '$6$????????????????$??????????????????????????????????????????????????????????????????????????????????????'            }
            @{Params = @{Password='a'; Salt=12345678;                                          OutputAll=$true;                       } ; OK = $true  ; Output = '$6$????????$??????????????????????????????????????????????????????????????????????????????????????'                    }
            @{Params = @{Password='a';                Rounds=1000;                             OutputAll=$true;                       } ; OK = $true  ; Output = '$6$rounds=1000$????????????????$??????????????????????????????????????????????????????????????????????????????????????'}
            @{Params = @{Password='a'; Salt=12345678; Rounds=1000;                             OutputAll=$true;                       } ; OK = $true  ; Output = '$6$rounds=1000$????????$??????????????????????????????????????????????????????????????????????????????????????'        }
            @{Params = @{Password='a';                             Sha512=$true;               OutputAll=$true;                       } ; OK = $true  ; Output = '$6$????????????????$??????????????????????????????????????????????????????????????????????????????????????'            }
            @{Params = @{Password='a'; Salt=12345678;              Sha512=$true;               OutputAll=$true;                       } ; OK = $true  ; Output = '$6$????????$??????????????????????????????????????????????????????????????????????????????????????'                    }
            @{Params = @{Password='a';                Rounds=1000; Sha512=$true;               OutputAll=$true;                       } ; OK = $true  ; Output = '$6$rounds=1000$????????????????$??????????????????????????????????????????????????????????????????????????????????????'}
            @{Params = @{Password='a'; Salt=12345678; Rounds=1000; Sha512=$true;               OutputAll=$true;                       } ; OK = $true  ; Output = '$6$rounds=1000$????????$??????????????????????????????????????????????????????????????????????????????????????'        }
            @{Params = @{Password='a';                                           Sha256=$true; OutputAll=$true;                       } ; OK = $true  ; Output = '$5$????????????????$???????????????????????????????????????????'                                                       }
            @{Params = @{Password='a'; Salt=12345678;                            Sha256=$true; OutputAll=$true;                       } ; OK = $true  ; Output = '$5$????????$???????????????????????????????????????????'                                                               }
            @{Params = @{Password='a';                Rounds=1000;               Sha256=$true; OutputAll=$true;                       } ; OK = $true  ; Output = '$5$rounds=1000$????????????????$???????????????????????????????????????????'                                           }
            @{Params = @{Password='a'; Salt=12345678; Rounds=1000;               Sha256=$true; OutputAll=$true;                       } ; OK = $true  ; Output = '$5$rounds=1000$????????$???????????????????????????????????????????'                                                   }
            @{Params = @{Password='a';                                                                          OutputHashOnly = $true} ; OK = $true  ; Output = '??????????????????????????????????????????????????????????????????????????????????????'                                }
            @{Params = @{Password='a'; Salt=12345678;                                                           OutputHashOnly = $true} ; OK = $true  ; Output = '??????????????????????????????????????????????????????????????????????????????????????'                                }
            @{Params = @{Password='a';                Rounds=1000;                                              OutputHashOnly = $true} ; OK = $true  ; Output = '??????????????????????????????????????????????????????????????????????????????????????'                                }
            @{Params = @{Password='a'; Salt=12345678; Rounds=1000;                                              OutputHashOnly = $true} ; OK = $true  ; Output = '??????????????????????????????????????????????????????????????????????????????????????'                                }
            @{Params = @{Password='a';                             Sha512=$true;                                OutputHashOnly = $true} ; OK = $true  ; Output = '??????????????????????????????????????????????????????????????????????????????????????'                                }
            @{Params = @{Password='a'; Salt=12345678;              Sha512=$true;                                OutputHashOnly = $true} ; OK = $true  ; Output = '??????????????????????????????????????????????????????????????????????????????????????'                                }
            @{Params = @{Password='a';                Rounds=1000; Sha512=$true;                                OutputHashOnly = $true} ; OK = $true  ; Output = '??????????????????????????????????????????????????????????????????????????????????????'                                }
            @{Params = @{Password='a'; Salt=12345678; Rounds=1000; Sha512=$true;                                OutputHashOnly = $true} ; OK = $true  ; Output = '??????????????????????????????????????????????????????????????????????????????????????'                                }
            @{Params = @{Password='a';                                           Sha256=$true;                  OutputHashOnly = $true} ; OK = $true  ; Output = '???????????????????????????????????????????'                                                                           }
            @{Params = @{Password='a'; Salt=12345678;                            Sha256=$true;                  OutputHashOnly = $true} ; OK = $true  ; Output = '???????????????????????????????????????????'                                                                           }
            @{Params = @{Password='a';                Rounds=1000;               Sha256=$true;                  OutputHashOnly = $true} ; OK = $true  ; Output = '???????????????????????????????????????????'                                                                           }
            @{Params = @{Password='a'; Salt=12345678; Rounds=1000;               Sha256=$true;                  OutputHashOnly = $true} ; OK = $true  ; Output = '???????????????????????????????????????????'                                                                           }
            @{Params = @{Password='a';                             Sha512=$true; Sha256=$true;                                        } ; OK = $false ; Output = 'Parameter set cannot be resolved*'                                                                                     }
            @{Params = @{Password='a';                                                         OutputAll=$true; OutputHashOnly = $true} ; OK = $false ; Output = 'Parameter set cannot be resolved*'                                                                                     }
            @{Params = @{Password='a';                             Sha512=$true;               OutputAll=$true; OutputHashOnly = $true} ; OK = $false ; Output = 'Parameter set cannot be resolved*'                                                                                     }
            @{Params = @{Password='a';                                           Sha256=$true; OutputAll=$true; OutputHashOnly = $true} ; OK = $false ; Output = 'Parameter set cannot be resolved*'                                                                                     }
            @{Params = @{Password='a';                             Sha512=$true; Sha256=$true; OutputAll=$true;                       } ; OK = $false ; Output = 'Parameter set cannot be resolved*'                                                                                     }
            @{Params = @{Password='a';                             Sha512=$true; Sha256=$true;                  OutputHashOnly = $true} ; OK = $false ; Output = 'Parameter set cannot be resolved*'                                                                                     }
            @{Params = @{Password='a'; Salt=12345678; Rounds=1000; Sha512=$true; Sha256=$true; OutputAll=$true; OutputHashOnly = $true} ; OK = $false ; Output = 'Parameter set cannot be resolved*'                                                                                     }
            @{Params = @{Password='a'; NonExistingParameter='Something'                                                               } ; OK = $false ; Output = 'A parameter cannot be found that matches parameter name*'                                                              }
            @{Params = @{Password=''                                                                                                  } ; OK = $false ; Output = 'Length of password*'                                                              }
            @{Params = @{Password=@(65,999)                                                                                           } ; OK = $false ; Output = 'Password must be of type*'                                                              }
        )
        $testCasesParams1 | ForEach-Object -Process {$_['ParamsText'] = ($_.Params | ConvertTo-Json -Compress) -replace '["{}]'}

        It 'New-ShaPassword <ParamsText> == $Output (OK:<OK>)' -TestCases $testCasesParams1 {
            param ($Params, $ParamsText, $OK, $Output)
            if ($OK)
            {
                $r = New-ShaPassword @Params -ErrorAction Stop
                $r | Should -BeOfType 'System.String'
                $r | Should -BeLike $Output
            }
            else
            {
                {New-ShaPassword @Params -ErrorAction Stop} | Should -Throw $Output
            }
        }
    }

    Context TestCasesSalt1 {
        $testCasesSalt1 = @(
            @{Salt = $null             ; OK = $true }
            @{Salt = ''                ; OK = $false}
            @{Salt = 'q' *  1          ; OK = $false}
            @{Salt = 'q' *  7          ; OK = $false}
            @{Salt = 'q' *  8          ; OK = $true }
            @{Salt = 'q' *  9          ; OK = $true }
            @{Salt = 'q' * 15          ; OK = $true }
            @{Salt = 'q' * 16          ; OK = $true }
            @{Salt = 'q' * 17          ; OK = $false}
            @{Salt = 0                 ; OK = $false}
            @{Salt = 1                 ; OK = $false}
            @{Salt = 1234567           ; OK = $false}
            @{Salt = 12345678          ; OK = $true }
            @{Salt = 1234567890123456  ; OK = $true }
            @{Salt = 12345678901234567 ; OK = $false}
            @{Salt = @()               ; OK = $false}
            @{Salt = @(65)  *  1       ; OK = $false}
            @{Salt = @(65)  *  7       ; OK = $false}
            @{Salt = @(65)  *  8       ; OK = $true }
            @{Salt = @(65)  *  9       ; OK = $true }
            @{Salt = @(65)  * 15       ; OK = $true }
            @{Salt = @(65)  * 16       ; OK = $true }
            @{Salt = @(65)  * 17       ; OK = $false}
            @{Salt = @(260) * 10       ; OK = $false}
        )

        It 'New-ShaPassword -Salt <Salt> (OK:<OK>)' -TestCases $testCasesSalt1 {
            param ($Salt, $OK)
            $params = @{
                Password = 'abc'
                Salt     = $Salt
            }
            if ($OK)
            {
                New-ShaPassword @params -ErrorAction Stop | Should -BeOfType 'System.String'
            }
            else
            {
                {New-ShaPassword @params -ErrorAction Stop} | Should -Throw 'Salt*'
            }
        }
    }

    Context TestCasesRounds1 {
        $testCasesRounds1 = @(
            # Why doesn't "Should" have a "BeMatch" parameter!!!!
            @{Rounds = $null ; OK = $true  ; Output = '$5$????????????????$???????????????????????????????????????????'}
            @{Rounds = 0     ; OK = $true  ; Output = '$5$????????????????$???????????????????????????????????????????'}
            @{Rounds = 1     ; OK = $true  ; Output = '$5$rounds=1000$????????????????$???????????????????????????????????????????'}
            @{Rounds = 999   ; OK = $true  ; Output = '$5$rounds=1000$????????????????$???????????????????????????????????????????'}
            @{Rounds = 1000  ; OK = $true  ; Output = '$5$rounds=1000$????????????????$???????????????????????????????????????????'}
            @{Rounds = 5000  ; OK = $true  ; Output = '$5$????????????????$???????????????????????????????????????????'}
            @{Rounds = 5001  ; OK = $true  ; Output = '$5$rounds=5001$????????????????$???????????????????????????????????????????'}
            @{Rounds = ''    ; OK = $true  ; Output = '$5$????????????????$???????????????????????????????????????????'}
            @{Rounds = 'abc' ; OK = $false ; Output = '*Cannot convert value*'}
        )

        It 'New-ShaPassword -Rounds <Rounds> == <Output> (OK:<OK>)' -TestCases $testCasesRounds1 {
            param ($Rounds, $OK, $Output)
            $params = @{
                Sha256   = $true
                Password = 'xxxxxxxx'
                Rounds   = $Rounds
            }
            if ($OK)
            {
                $r = New-ShaPassword @params -ErrorAction Stop
                $r | Should -BeOfType 'System.String'
                $r | Should -BeLike $Output
            }
            else
            {
                {New-ShaPassword @params -ErrorAction Stop} | Should -Throw $Output
            }
        }
    }

    Context Pipe {
        It 'Pipe one password' {
            $r = 'password1' | New-ShaPassword
            $r | Should -BeOfType 'System.String'
            $r | Should -BeLike '$6$????????????????$??????????????????????????????????????????????????????????????????????????????????????'
            $r.Length | Should -Be 106
        }

        It 'Pipe one password with salt' {
            $r = 'P@ssw0rd!' | New-ShaPassword -Salt ZAQ12wsxCDE34rfv
            $r | Should -BeOfType 'System.String'
            $r | Should -BeLike '$6$ZAQ12wsxCDE34rfv$avWN953.SGyyuxAhLXL458Y6vxkSiI6US5f.GUN8XUD6q4IG0hMmFOdueAKnoNXMWSUa4FWGh2RJ8CS4J/8WM/'
        }

        It 'Pipe multiple passwords' {
            $r = @('aaa','bbb','ccc') | New-ShaPassword
            $r.Count | Should -Be 3
            ($r -join '').Length | Should -Be (3 * 106)
        }
    }

    Context TestWithTestData1 {
        $testData1 = Get-Content -Path .\testdata\testdata.csv | ConvertFrom-Csv -Delimiter ';' | ForEach-Object -Begin {$i=1} -Process {
            @{
                Line     = ++$i
                Method   = $_.METHOD -replace '-'
                Salt     = if (-not $_.SALT -and $_.HASH -match '^\$\d(\$rounds=\d+)?\$([^\$]+)') {$Matches[2]} else {$_.SALT}
                Rounds   = [int] $_.ROUNDS
                Password = $_.PASSWORD
                Hash     = $_.HASH -replace 'rounds=5000\$'
            }
        }
        $testData1 = $testData1 | Where-Object -FilterScript {$_.Rounds -lt 10000 -or -not (Get-Random -Maximum 20)}  # Testing takes forever, so we just take 5% of the big ones
        $testData1 = $testData1 | Get-Random -Count 200

        It '<Line>: New-ShaPassword -<Method> -Password <Password> -Salt <Salt> -Rounds <Rounds> == <Hash>' -TestCases $testData1 {
            param ($Line, $Method, $Password, $Salt, $Rounds, $Hash)
            $params = @{
                "$Method" = $true
                Password  = $Password
                Salt      = $Salt
            }
            if ($Rounds) {$params['Rounds'] = $Rounds}
            $r = New-ShaPassword @params -ErrorAction Stop
            $r | Should -BeOfType 'System.String'
            $r | Should -Be $Hash
        }
    }

}
