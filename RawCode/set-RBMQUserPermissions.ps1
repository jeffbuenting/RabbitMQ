Function Set-RBMQUserPermission {

<#
    .Synopsis 
        Sets a Rabbit user Permissions.

    .Description
        Sets the permissions of a Rabbit User. 

    .Parameter APIUrl
        Url of the Rabbit API.  Defaults to http://localhost:15672

    .Parameter User
        User object retrieved using Get-RBMQUser. 

    .Parameter Credential
        Admin credentials to the Rabbit Server

    .Example
        Set a users permissions.

        Get-RBMQUserPermission -Name 'jeff' -Credential $Cred | Set-RBMQUserPermission -VHost 'gp_live' -Configure '.*' -Write '.*' -Read '.*'

    .Link
        http://hg.rabbitmq.com/rabbitmq-management/raw-file/3646dee55e02/priv/www-api/help.html

    .Link
        Curl

        http://discoposse.com/2012/06/30/powershell-invoke-restmethod-putting-the-curl-in-your-shell/

    .Note
        Author: Jeff Buenting
        Date: 2015 DEC 14
#>

    [CmdletBinding()]
    Param (
        
        [String]$APIUrl = 'HTTP://LocalHost:15672',

        [Parameter(valueFromPipeline=$True)]
        [PSObject[]]$User,

        [Parameter(Mandatory=$True)]
        [Alias("Cred")]
        [pscredential]$Credential,

        [String]$VHost,
      
        [String]$Configure = '',
    
        [String]$Write = '',
    
        [String]$Read = ''
    )

    Process {
        Foreach ( $U in $User ) {
            Write-Verbose "Setting User $($U.Name)"
            
            # ----- Set Permissiosn
            If ( $VHost ) {
                Write-Verbose "Setting Permissions on $VHost"
                $Body = @{
                    'scope'='client'
                    'configure'=$Configure
                    'write'=$Write
                    'read'=$Read
                } | ConvertTo-Json

                Invoke-RestMethod -Uri "$APIUrl/api/permissions/$VHost/$($U.Name)" -Method Put -ContentType "application/json" -Body $Body -Credential $Credential
            }
        }

    }

   
}

$Cred = Get-Credential


$DeployUser = Get-RBMQUser -APIUrl 'http://jeffb-rb03:15672' -Name GP_DeployUser -Credential $Cred 

Set-RBMQUserPermission -APIUrl 'http://jeffb-rb03:15672' -User $DeployUser -VHost GP_DeploymentHost -Configure '.*' -Write '.*' -Read '.*' -Credential $Cred -Verbose 