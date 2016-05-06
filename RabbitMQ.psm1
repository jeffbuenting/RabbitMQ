#----------------------------------------------------------------------------------
# Module RabbitMQ.psm1
#
# Cmdlets for RabbitMQ
# http://www.rabbitmq.com/
#----------------------------------------------------------------------------------

#----------------------------------------------------------------------------------
# Rabbit User Cmdlets
#----------------------------------------------------------------------------------

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
                    try {
                            Write-Verbose "Getting all users like $Name"
                            $User = Invoke-RestMethod -Uri "$APIUrl/api/users" -Method Get -Credential $Credential -ErrorAction Stop | where Name -Like $Name 
                        }
                        Catch {
                            Throw "Get-RBMQUser : $($_.Exception.Message)"
                    }
                    Write-Output $User
                }
                Else {
                    #----- Getting list of names specified
                    Foreach ( $N in $Name ) {
                        Write-Verbose "     $N"
                         try {
                                Write-Verbose "Getting all users like $Name"
                                $User = Invoke-RestMethod -Uri "$APIUrl/api/users/$N" -Method Get -Credential $Credential -ErrorAction Stop
                            }
                            Catch {
                                Throw "Get-RBMQUser : $($_.Exception.Message)"
                        }
                        Write-Output $User
                    }
            }
        }
        Else {
            # ----- No Name Specified, get all
            Write-Verbose "Getting all users "
            Write-Output (Invoke-RestMethod -Uri "$APIUrl/api/users" -Method Get -Credential $Credential)
    }
}

#----------------------------------------------------------------------------------

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
    Write-Verbose "Pausing to let Rabbiit Catchup."
    Start-Sleep -Seconds 5

    Write-Output (Invoke-RestMethod -Uri "$APIUrl/api/users/$Name" -Method Get -Credential $Credential)
    #Write-Output (Get-RBMQUser -APIUrl $APIUrl -Name $Name -Credential $Cred )
}

#----------------------------------------------------------------------------------

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

        # ----- Pause to let the Rabbit Server settings catch up
        Start-Sleep -Seconds 5
    }
}

#----------------------------------------------------------------------------------

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
                
                Try {
                        Invoke-RestMethod -Uri "$APIUrl/api/permissions/$VHost/$($U.Name)" -Method Put -ContentType "application/json" -Body $Body -Credential $Credential -ErrorAction Stop
                    }
                    Catch {
                        $Error[0]
                }
            }
        }
    }
}

#----------------------------------------------------------------------------------
# Virtual Host Cmdlets
#----------------------------------------------------------------------------------

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
                    Try {
                            $VirtualHost = Invoke-RestMethod -Uri "$APIUrl/api/vhosts/$V" -Method Get -Credential $Credential -ErrorAction Stop

                        }
                        catch {
                            Throw "Get-RBMQVHost : $($_.Exception.message)"
                    }
                    Write-Output $VirtualHost
                }
            }
            else {
                Write-Verbose "Getting information about all virtual hosts."
                Write-Output (Invoke-RestMethod -Uri "$APIUrl/api/vhosts" -Method Get -Credential $Credential)
                Try {
                        $VirtualHost = Invoke-RestMethod -Uri "$APIUrl/api/vhosts" -Method Get -Credential $Credentiall -ErrorAction Stop
                        
                    }
                    catch {
                        Throw "Get-RBMQVHost : $($_.Exception.message)"
                }
                Write-Output $VirtualHost
        }
        
        
    }
}

#----------------------------------------------------------------------------------

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
   
    Invoke-RestMethod -Uri "$APIUrl/api/vhosts/$Name" -Method Put  -ContentType "application/json" -Credential $Credential -ErrorAction Stop
   
   Start-sleep -Seconds 5

    Write-Output (Invoke-RestMethod -Uri "$APIUrl/api/vhosts/$Name" -Method Get -Credential $Credential) 

}


#----------------------------------------------------------------------------------
#----------------------------------------------------------------------------------
#----------------------------------------------------------------------------------
#----------------------------------------------------------------------------------
#----------------------------------------------------------------------------------