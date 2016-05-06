Function Set-RBMQUser {

<#
    .Synopsis
        Modifies a Rabbit User.

    .Description
        Modifies a Rabbit User.

    .Parameter APIUrl
        Url of the Rabbit API.  Defaults to http://localhost:15672

    .Parameter Name
        Name of the user to modifyh

    .Parameter Password
        Password of the user

    .Parameter Tags
        Rabbit tags for the user.  If left blank no tags will be assigned

    .Parameter Credential
        Admin credentials to the Rabbit Server

    .Example
        change users password

        New-RBMQUser -Name 'Tom' -Password "Password" -Credential $Cred

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

        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        [String]$Name,

        # ----- Password has to be madatory becuase i
       # [Parameter(Mandatory=$True)}
        #[String]$Password,

        [ValidateSet('administrator','monitoring','policymaker','management')]
        [String]$Tags,

        [Parameter(Mandatory=$True)]
        [Alias("Cred")]
        [pscredential]$Credential
    )

    # ----- Build Body to pass to API
    $Body = @{
        #'password' = $Password
        'tags'= $Tags
    } | ConvertTo-Json

    Invoke-RestMethod -Uri "$APIUrl/api/users/$Name" -Method Put -ContentType "application/json" -Body $Body -Credential $Credential
}


Get-RBMQUser -APIUrl 'http://jeffb-rb03:15672' -name test -Credential $Cred | Set-RBMQUser -APIUrl 'http://jeffb-rb03:15672' -Tags administrator
