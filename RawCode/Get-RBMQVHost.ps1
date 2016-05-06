Function Get-RBMQVHost {

<#
    .Synopsis
        Retrieves information about a rabbit virtual host.

    .Description
        Retrieves information about a rabbit virtual host.  If none specified, returns info about all hosts.

    .Parameter APIUrl
        Url of the Rabbit API.  Defaults to http://localhost:15672

    .Parameter VHost
        Name of the virtual host.  Default is blank.  Which returns all virtual hosts. 

    .Parameter Credential
        Admin credentials to the Rabbit Server

    .Example
        Get-RBMQVHost -VHost gp_deploy

    .Link
        http://hg.rabbitmq.com/rabbitmq-management/raw-file/3646dee55e02/priv/www-api/help.html

    .Note
        Author: Jeff Buenting
        Data: 2015 DEC 14
 
#>

    [CmdletBinding()]
    Param (
        [String]$APIUrl = 'HTTP://LocalHost:15672',

        [Parameter(Mandatory=$True)]
        [Alias("Cred")]
        [pscredential]$Credential,

        [Parameter(ValueFromPipeline=$True)]
        [String[]]$VHost
    )

    Process {
        if ( $VHost ) {
                Foreach ( $V in $VHost ) {
                    Write-Verbose "Getting $VHost information"
                    Write-Output (Invoke-RestMethod -Uri "$APIUrl/api/vhosts/$V" -Method Get -Credential $Credential)
                }
            }
            else {
                Write-Verbose "Getting information about all virtual hosts."
                Write-Output (Invoke-RestMethod -Uri "$APIUrl/api/vhosts" -Method Get -Credential $Credential)
        }
    }
}

Get-RBMQVHost -APIUrl 'http://jeffb-rb03:15672' -VHost gp_deploy