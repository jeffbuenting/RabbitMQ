Function Get-RBMQUser {

<#
    .Synopsis
        Get RabbitMQ Users

    .Description
        Retrieves users from the RabbitMQ Server.

    .Parameter APIUrl
        URL to the Rabbit API.  Defaults to HTTP://LocalHost:15672

    .Parameter Name
        Name of user info to retrieve.  If none is specified, all users will be returned.  Wildcards are supported.

    .Parameter Credential
        Credentials to the RabbitMQ Server.

    .Example
        Return all users

        Get-RBMQUser 

    .Example
        Return user information for Jeff

        Get-RBMQUser -Name 'Jeff'

    .Example
        Return user Information for all users who's name begins with 'w'

        Get-RBMQUser -Name 'w*'

    .Link
        http://hg.rabbitmq.com/rabbitmq-management/raw-file/3646dee55e02/priv/www-api/help.html

    .Link
        Curl

        http://discoposse.com/2012/06/30/powershell-invoke-restmethod-putting-the-curl-in-your-shell/

    .Note
        Author: Jeff Buenting
        Date: 2015 DEC 10
#>

    [CmdletBinding()]
    Param (
        [String]$APIUrl = 'HTTP://LocalHost:15672',

        [String[]]$Name,

        [Parameter(Mandatory=$True)]
        [Alias("Cred")]
        [pscredential]$Credential
    )


    If ( $Name ) {
            # ----- If a Name is specified...
            Write-verbose "Getting users"
            if ( $Name[0].contains('*') ) {
                    # ---- Wildcard included
                    Write-Verbose "Getting all users like $Name"
                    Write-Output (Invoke-RestMethod -Uri "$APIUrl/api/users" -Method Get -Credential $Credential | where Name -Like $Name )
                }
                Else {
                    #----- Getting list of names specified
                    Foreach ( $N in $Name ) {
                        Write-Verbose "     $N"
                         Write-Output (Invoke-RestMethod -Uri "$APIUrl/api/users/$N" -Method Get -Credential $Credential)

                    }
            }
        }
        Else {
            # ----- No Name Specified, get all
            Write-Verbose "Getting all users "
            Write-Output (Invoke-RestMethod -Uri "$APIUrl/api/users" -Method Get -Credential $Credential)
    }
}

$cred = Get-Credential
    

Get-RBMQUser -APIUrl 'http://jeffb-rb03:15672' -Name "w*" -Credential $Cred -verbose
