Function New-RBMQUser {

<#
    .Synopsis
        Creates new Rabbit User.

    .Description
        Creates new Rabbit User.

    .Parameter APIUrl
        Url of the Rabbit API.  Defaults to http://localhost:15672

    .Parameter Name
        Name of the new user

    .Parameter Password
        Password of the new user

    .Parameter Tags
        Rabbit tags for the new user.  If left blank no tags will be assigned

    .Parameter Credential
        Admin credentials to the Rabbit Server

    .Example
        Create New user.

        New-RBMQUser -Name 'Tom' -Password "Password" -Tags Adminstrator -Credential $Cred

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

        [String]$Name,

        [String]$Password,

        [ValidateSet('administrator','monitoring','policymaker','management')]
        [String]$Tags,

        [Parameter(Mandatory=$True)]
        [Alias("Cred")]
        [pscredential]$Credential
    )

    # ----- Build Body to pass to API
    $Body = @{
        'password' = $Password
        'tags'= $Tags
    } | ConvertTo-Json

    Invoke-RestMethod -Uri "$APIUrl/api/users/$Name" -Method Put -ContentType "application/json" -Body $Body -Credential $Credential

    # ----- Need to take a break to let rabbit catch up: http://stackoverflow.com/questions/29403042/using-powershell-to-create-user-in-rabbitmq-via-api
    Start-Sleep -Seconds 5

    Write-Output (Invoke-RestMethod -Uri "$APIUrl/api/users/$Name" -Method Get -Credential $Credential)
}

$Cred = Get-Credential

New-RBMQUser -APIUrl 'http://jeffb-rb03:15672' -Name "test" -Password "password" -Credential $Cred -verbose
