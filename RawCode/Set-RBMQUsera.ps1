Function Set-RBMQUser {

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
    
        [String]$Read = '',

        [String]$Password,

        [ValidateSet('administrator','monitoring','policymaker','management')]
        [String]$Tag
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

            $Body =@{}

            # ----- Set password
            if ( $Password ) {
                $Body.Add('password',$Password)
            }

            # ----- Set Tag
            If ( $Tag ) {
                $Body.Add('tags',$Tag)
            }

            $Body = $Body | ConvertTo-Json

            Invoke-RestMethod -Uri "$APIUrl/api/users/$Name" -Method Put -ContentType "application/json" -Body $Body -Credential $Credential
        }
    }
}

$Cred = Get-Credential


Get-RBMQUser -APIUrl 'http://jeffb-rb03:15672' -Name test -Credential $Cred | Set-RBMQUser -APIUrl 'http://jeffb-rb03:15672' -VHost gp_live -Configure '.*' -Write '.*' -Read '.*' -Credential $Cred -Verbose -Tag administrator