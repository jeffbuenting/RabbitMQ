Function Get-RBMQUserPermission {

<#
    .Synopsis 
        Gets a Rabbit user Permissions.

    .Description
        Returns the permissions of a Rabbit User.  Or all users.

    .Parameter APIUrl
        Url of the Rabbit API.  Defaults to http://localhost:15672

    .Parameter Name
        Name of the user.  If left blank, all users permissions will be returned.

    .Parameter Credential
        Admin credentials to the Rabbit Server

    .Example
        Get a users permissions.

        Get-RBMQUserPermissions -Name 'jeff' -Credential $Cred

    .Link
        http://hg.rabbitmq.com/rabbitmq-management/raw-file/3646dee55e02/priv/www-api/help.html

    .Link
        Curl

        http://discoposse.com/2012/06/30/powershell-invoke-restmethod-putting-the-curl-in-your-shell/

    .Note
        Author: Jeff Buenting
        Date: 2015 DEC 14
#>

    [CmdletBinding(DefaultParameterSetName='Name')]
    Param (
        [String]$APIUrl = 'HTTP://LocalHost:15672',

        [Parameter(ParameterSetName='UserObject',valueFromPipeline=$True)]
        [PSObject[]]$User,

        [Parameter(ParameterSetName='Name',valueFromPipeline=$True)]
        [String[]]$Name,

        [Parameter(Mandatory=$True)]
        [Alias("Cred")]
        [pscredential]$Credential
    )

    Process {
        Switch ( $PSCmdlet.ParameterSetName ) {
            'Name' {
                Write-Verbose 'Parameter Name'
                if ( $Name ) {
                        Write-Verbose "Getting permissions for users"
                        Foreach ( $N in $Name ) {
                            Write-Verbose "Getting permissions for $N"
                    
                            Write-Output (Invoke-RestMethod -Uri "$APIUrl/api/users/$N/permissions" -Method Get -Credential $Credential)

                        }
                    }
                    else {
                        Write-Verbose "Getting all user permissions"

                        Write-Output (Invoke-RestMethod -Uri "$APIUrl/api/permissions" -Method Get -Credential $Credential)
                }
            }

            'UserObject' {
                Write-Verbose 'Parameter UserObject'
                foreach ( $U in $User ) {
                    Write-Verbose "Getting User permissions for $($U.Name)"
                    Write-Output (Invoke-RestMethod -Uri "$APIUrl/api/users/$($U.Name)/permissions" -Method Get -Credential $Credential)
                }
            }
        }
    }
}

$Cred = Get-Credential


Get-RBMQUser -APIUrl 'http://jeffb-rb03:15672' -Name jeff -Credential $Cred | Get-RBMQUserPermission -APIUrl 'http://jeffb-rb03:15672' -Credential $Cred -Verbose