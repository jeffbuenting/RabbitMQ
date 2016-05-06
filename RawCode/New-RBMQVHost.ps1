Function New-RBMQVhost {

<#
    .Synopsis
        Creates a new rabbit virtual host.

    .Description
        Create new rabbit virtual host.

    .Parameter APIUrl
        Url of the Rabbit API.  Defaults to http://localhost:15672

    .Parameter Name
        Name of the New virtual host.  

    .Parameter Credential
        Admin credentials to the Rabbit Server

    .Example
        New-RBMQVHost -Name test 

    .Link
        http://hg.rabbitmq.com/rabbitmq-management/raw-file/3646dee55e02/priv/www-api/help.html

    .Note
        Author: Jeff Buenting
        Date: 2015 DEC 14
#>

    [CmdletBinding()]
    Param (
        [String]$APIUrl = 'HTTP://LocalHost:15672',

        [Parameter(Mandatory=$True)]
        [Alias("Cred")]
        [pscredential]$Credential,

        [Parameter(Mandatory=$True)]
        [String]$Name
    )

    Write-Verbose "Createing new virtual host $Name"

    Invoke-RestMethod -Uri "$APIUrl/api/vhosts/$Name" -Method Put  -ContentType "application/json" -Credential $Credential

    Start-sleep -Seconds 5

    Write-Output (Invoke-RestMethod -Uri "$APIUrl/api/vhosts/$Name" -Method Get -Credential $Credential) 

}

New-RBMQVHost -APIUrl 'http://jeffb-rb03:15672' -Name newhost -Verbose