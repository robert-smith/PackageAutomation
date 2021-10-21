$parent = Split-Path -Path $PSScriptRoot -Parent
$module = Split-Path -Path $parent -Leaf
Remove-Module $module -Force -ErrorAction SilentlyContinue
Import-Module $parent\Src\$module.psd1 -Force

Describe "$module - Send-ResultEmail" {
    InModuleScope PackageAutomation {

        It 'Does not send an email if no matching status is found' {
            Mock Send-MailMessage
            $Script:Results = @{
                Name   = 'Test'
                Phases = @(
                    [PSCustomObject]@{ Description = 'Initialize'; Status = 'OK' },
                    [PSCustomObject]@{ Description = 'GetURL'; Status = 'OK' },
                    [PSCustomObject]@{ Description = 'CheckVersion'; Status = 'OK' },
                    [PSCustomObject]@{ Description = 'Download'; Status = 'OK' },
                    [PSCustomObject]@{ Description = 'MSIProps'; Status = 'OK' },
                    [PSCustomObject]@{ Description = 'CopyFiles'; Status = 'OK' },
                    [PSCustomObject]@{ Description = 'ConnectSCCM'; Status = 'OK' },
                    [PSCustomObject]@{ Description = 'DetectionRules'; Status = 'OK' },
                    [PSCustomObject]@{ Description = 'NewApp'; Status = 'OK' },
                    [PSCustomObject]@{ Description = 'DeploymentType'; Status = 'OK' },
                    [PSCustomObject]@{ Description = 'Supersedence'; Status = 'OK' },
                    [PSCustomObject]@{ Description = 'Dependencies'; Status = 'OK' },
                    [PSCustomObject]@{ Description = 'CreateCollection'; Status = 'OK' },
                    [PSCustomObject]@{ Description = 'Distribute'; Status = 'OK' },
                    [PSCustomObject]@{ Description = 'Deploy'; Status = 'OK' }
                )
            }
            
            Send-ResultEmail -Results $Results -From 'PackageAutomation@contoso.com' -SuccessAddress 'Success@contoso.com' -FailureAddress 'Failed@contoso.com' -SmtpServer 'mail.contoso.com'
            Send-ResultEmail -Results $Results -From 'PackageAutomation@contoso.com' -SuccessAddress 'Success@contoso.com' -FailureAddress 'Failed@contoso.com' -SmtpServer 'mail.contoso.com'
            Assert-MockCalled -CommandName Send-MailMessage -Times 0 -Exactly
        }
        
        It 'Sends success email if there are no failures and at least one success' {
            Mock Send-MailMessage
            $Script:Results = @{
                Name   = 'Test'
                Phases = @(
                    [PSCustomObject]@{ Description = 'Initialize'; Status = 'OK' },
                    [PSCustomObject]@{ Description = 'GetURL'; Status = 'OK' },
                    [PSCustomObject]@{ Description = 'CheckVersion'; Status = 'OK' },
                    [PSCustomObject]@{ Description = 'Download'; Status = 'OK' },
                    [PSCustomObject]@{ Description = 'MSIProps'; Status = 'OK' },
                    [PSCustomObject]@{ Description = 'CopyFiles'; Status = 'OK' },
                    [PSCustomObject]@{ Description = 'ConnectSCCM'; Status = 'OK' },
                    [PSCustomObject]@{ Description = 'DetectionRules'; Status = 'OK' },
                    [PSCustomObject]@{ Description = 'NewApp'; Status = 'OK' },
                    [PSCustomObject]@{ Description = 'DeploymentType'; Status = 'OK' },
                    [PSCustomObject]@{ Description = 'Supersedence'; Status = 'OK' },
                    [PSCustomObject]@{ Description = 'Dependencies'; Status = 'OK' },
                    [PSCustomObject]@{ Description = 'CreateCollection'; Status = 'OK' },
                    [PSCustomObject]@{ Description = 'Distribute'; Status = 'OK' },
                    [PSCustomObject]@{ Description = 'Deploy'; Status = 'Success' }
                )
            }
    
            Send-ResultEmail -Results $Results -From 'PackageAutomation@contoso.com' -SuccessAddress 'Success@contoso.com' -FailureAddress 'Failed@contoso.com' -SmtpServer 'mail.contoso.com'
            Assert-MockCalled -CommandName Send-MailMessage -Times 0 -Exactly -ParameterFilter {$To -eq 'Failed@contoso.com'} -Scope It
            Assert-MockCalled -CommandName Send-MailMessage -Times 1 -Exactly -ParameterFilter {$To -eq 'Success@contoso.com'} -Scope It
        }
        
        It 'Sends failure email if any failures are detected' {
            Mock Send-MailMessage
            $Script:Results = @{
                Name   = 'Test'
                Phases = @(
                    [PSCustomObject]@{ Description = 'Initialize'; Status = 'OK' },
                    [PSCustomObject]@{ Description = 'GetURL'; Status = 'OK' },
                    [PSCustomObject]@{ Description = 'CheckVersion'; Status = 'OK' },
                    [PSCustomObject]@{ Description = 'Download'; Status = 'OK' },
                    [PSCustomObject]@{ Description = 'MSIProps'; Status = 'OK' },
                    [PSCustomObject]@{ Description = 'CopyFiles'; Status = 'OK' },
                    [PSCustomObject]@{ Description = 'ConnectSCCM'; Status = 'OK' },
                    [PSCustomObject]@{ Description = 'DetectionRules'; Status = 'OK' },
                    [PSCustomObject]@{ Description = 'NewApp'; Status = 'Success' },
                    [PSCustomObject]@{ Description = 'DeploymentType'; Status = 'OK' },
                    [PSCustomObject]@{ Description = 'Supersedence'; Status = 'OK' },
                    [PSCustomObject]@{ Description = 'Dependencies'; Status = 'OK' },
                    [PSCustomObject]@{ Description = 'CreateCollection'; Status = 'OK' },
                    [PSCustomObject]@{ Description = 'Distribute'; Status = 'OK' },
                    [PSCustomObject]@{ Description = 'Deploy'; Status = 'Failed' }
                )
            }
    
            Send-ResultEmail -Results $Results -From 'PackageAutomation@contoso.com' -SuccessAddress 'Success@contoso.com' -FailureAddress 'Failed@contoso.com' -SmtpServer 'mail.contoso.com'
            Assert-MockCalled -CommandName Send-MailMessage -Times 1 -Exactly -ParameterFilter {$To -eq 'Failed@contoso.com'} -Scope It
            Assert-MockCalled -CommandName Send-MailMessage -Times 0 -Exactly -ParameterFilter {$To -eq 'Success@contoso.com'} -Scope It
        }

        It 'Sends only successes and failures if Concise it specified' {
            Mock Send-MailMessage
            $Script:Results = @{
                Name   = 'Test'
                Phases = @(
                    [PSCustomObject]@{ Description = 'Initialize'; Status = 'Done' },
                    [PSCustomObject]@{ Description = 'GetURL'; Status = 'Done' },
                    [PSCustomObject]@{ Description = 'CheckVersion'; Status = 'Done' },
                    [PSCustomObject]@{ Description = 'Download'; Status = 'Done' },
                    [PSCustomObject]@{ Description = 'MSIProps'; Status = 'Done' },
                    [PSCustomObject]@{ Description = 'CopyFiles'; Status = 'OK' },
                    [PSCustomObject]@{ Description = 'ConnectSCCM'; Status = 'Done' },
                    [PSCustomObject]@{ Description = 'DetectionRules'; Status = 'Done' },
                    [PSCustomObject]@{ Description = 'NewApp'; Status = 'Success' },
                    [PSCustomObject]@{ Description = 'DeploymentType'; Status = 'Success' },
                    [PSCustomObject]@{ Description = 'Supersedence'; Status = 'OK' },
                    [PSCustomObject]@{ Description = 'Dependencies'; Status = 'OK' },
                    [PSCustomObject]@{ Description = 'CreateCollection'; Status = 'OK' },
                    [PSCustomObject]@{ Description = 'Distribute'; Status = 'Success' },
                    [PSCustomObject]@{ Description = 'Deploy'; Status = 'Success' }
                )
            }
    
            Send-ResultEmail -Results $Results -From 'PackageAutomation@contoso.com' -SuccessAddress 'Success@contoso.com' -FailureAddress 'Failed@contoso.com' -SmtpServer 'mail.contoso.com' -Concise
            Assert-MockCalled -CommandName Send-MailMessage -Times 1 -Exactly -Scope It -ParameterFilter {
                $Body -notmatch '<td>(OK|Done)</td>' -and
                $Body -match '<td id="(Success|Fail)">(Success|Failed)</td>'
            }
        }

        It 'Includes credentials if specified' {
            $Secret = 'secret' | ConvertTo-SecureString -AsPlainText -Force
            $Creds = [pscredential]::new('test.user',$Secret)
            Send-ResultEmail -Results $Results -From 'a@a.a' -SuccessAddress 'b@b.b' -FailureAddress 'c@c.c' -SmtpServer mail@a.com -Credential $Creds
            Assert-MockCalled -CommandName Send-MailMessage -ParameterFilter {$Credential -ne $null -and $Credential.UserName -eq 'test.user'}
        }
        
        It 'Does not includes credentials if missing' {
            Send-ResultEmail -Results $Results -From 'a@a.a' -SuccessAddress 'b@b.b' -FailureAddress 'c@c.c' -SmtpServer mail@a.com
            Assert-MockCalled -CommandName Send-MailMessage -ParameterFilter {$Credential -eq $null}
        }
    }
}