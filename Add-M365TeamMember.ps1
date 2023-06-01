function Add-M365TeamMember{

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)]
        [String]$UPN,
        [Parameter()]
        [String]$Team,
        [Parameter(Mandatory = $True)]
        [ValidateSet('Owner','Member')]
        [String]$Role,
        [Parameter()]
        [String]$File,
        [Parameter()]
        [Switch]$Multi
    )

    function Get-AADUser {

        [cmdletbinding()]
        param(
    
            [Parameter()]
            [Switch]$All,
            [Parameter()]
            [String]$UPN
    
        )
        
        <#
            IMPORTANT:
            ===========================================================================
            This script is provided 'as is' without any warranty. Any issues stemming 
            from use is on the user.
            ===========================================================================
            .DESCRIPTION
            Gets an Azure AD User
            ===========================================================================
            .PARAMETER All
            Lists all AAD users by displayName.
            .PARAMETER Name
            The displayName of the user to get.
            ===========================================================================
            .EXAMPLE
            Get-AADUser -All <--- This will return all AzureAD users
            Get-AADUser -UPN bjameson@example.com <--- This will return the user bjameson@example.com
        #>

    
        If ($All) {
     
            $uri = "https://graph.microsoft.com/beta/users"
            $Users = While (!$NoMoreUsers) {
    
                $GetUsers = Invoke-RestMethod -uri $uri -headers $header -method GET
                $getUsers.value
                If ($getUsers."@odata.nextlink") {
    
                    $uri = $getUsers."@odata.nextlink"
    
                }
                Else {
                
                    $NoMoreUsers = $True
    
                }
            }
            $NoMoreUsers = $False
            $Users| select displayName | sort displayName
    
        }
        elseif ($UPN -ne $Null) {
    
            $Uri = "https://graph.microsoft.com/beta/users/$UPN"
            Try {
            
                Invoke-RestMethod -Uri $Uri -Headers $header -Method Get
    
            }
            catch{
                $ResponseResult = $_.Exception.Response.GetResponseStream()
                $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                $ResponseBody = $ResponseReader.ReadToEnd()
                $ResponseBody    
            }
                
    
        }
        else {
    
            Write-Host "Please specify individual user or use All switch."
    
        }
    
    }

###########################################################################################################
    function Get-M365Team {

        [CmdletBinding()]
        param (
            [Parameter()]
            [String]$Team,
            [Parameter()]
            [Switch]$All    
            )


            function Get-AADUserTeams {

                [CmdletBinding()]
                param (
                    [Parameter(Mandatory = $True)]
                    [String]$UPN
                )
            
                function Get-AADUser {
            
                    [cmdletbinding()]
                    param(
                
                        [Parameter()]
                        [Switch]$All,
                        [Parameter()]
                        [String]$UPN
                
                    )
                    
                    <#
                        IMPORTANT:
                        ===========================================================================
                        This script is provided 'as is' without any warranty. Any issues stemming 
                        from use is on the user.
                        ===========================================================================
                        .DESCRIPTION
                        Gets an Azure AD User
                        ===========================================================================
                        .PARAMETER All
                        Lists all AAD users by displayName.
                        .PARAMETER Name
                        The displayName of the user to get.
                        ===========================================================================
                        .EXAMPLE
                        Get-AADUser -All <--- This will return all AzureAD users
                        Get-AADUser -UPN bjameson@example.com <--- This will return the user bjameson@example.com
                    #>
                
                    
                
                    If ($All) {
                
                        $uri = "https://graph.microsoft.com/beta/users"
                        $Users = While (!$NoMoreUsers) {
                
                            $GetUsers = Invoke-RestMethod -uri $uri -headers $header -method GET
                            $getUsers.value
                            If ($getUsers."@odata.nextlink") {
                
                                $uri = $getUsers."@odata.nextlink"
                
                            }
                            Else {
                            
                                $NoMoreUsers = $True
                
                            }
                        }
                        $NoMoreUsers = $False
                        $Users| select displayName | sort displayName
                
                    }
                    elseif ($UPN -ne $Null) {
                
                        $Uri = "https://graph.microsoft.com/beta/users/$UPN"
                        Try {
                        
                            Invoke-RestMethod -Uri $Uri -Headers $header -Method Get
                
                        }
                        catch{
                            $ResponseResult = $_.Exception.Response.GetResponseStream()
                            $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                            $ResponseBody = $ResponseReader.ReadToEnd()
                            $ResponseBody    
                        }
                            
                
                    }
                    else {
                
                        Write-Host "Please specify individual user or use All switch."
                
                    }
                
                }
            
            #######################################################
            
            
            $User = Get-AADUser -UPN $UPN
            $uri = "https://graph.microsoft.com/beta/users/$UPN/joinedTeams"
            Try {
            
                (Invoke-RestMethod -Uri $URI -Headers $Header -Method Get).value | select displayname,description,id
                
            }
            catch {
            
                $ResponseResult = $_.Exception.Response.GetResponseStream()
                $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                $ResponseBody = $ResponseReader.ReadToEnd()
                $ResponseBody  
            
            }
            
            }

    ###########################################################


    If ($All){

        $Uri = "https://graph.microsoft.com/beta/groups?`$select=id,resourceProvisioningOptions,displayName"
        Try {

            (Invoke-RestMethod -uri $Uri -Headers $Header -Method Get).value | where {$_.resourceProvisioningOptions -ne $Null}  | select displayname | sort displayname

        }
        catch {

            $ResponseResult = $_.Exception.Response.GetResponseStream()
            $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
            $ResponseBody = $ResponseReader.ReadToEnd()
            $ResponseBody  

        }
        

    }
    elseif (!$All -and $Team) {

        $Uri = "https://graph.microsoft.com/beta/groups?`$filter=startswith(displayName,'$Team')"
        Try{

            (Invoke-RestMethod -Uri $Uri -Headers $Header -Method Get).value | select displayName,description,Id,mail

        }
        catch {

            $ResponseResult = $_.Exception.Response.GetResponseStream()
            $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
            $ResponseBody = $ResponseReader.ReadToEnd()
            $ResponseBody  

        }


    }
    elseif (!$all -and !$Team){

        Write-Host 'Please select either the all switch or specify a Team.' -f red

    }

    }

###########################################################################################################
$token = Get-MsalToken -clientid x -tenantid organizations
$global:header = @{'Authorization' = $token.createauthorizationHeader()}

If (!$File -and !$Multi){

    $UserId = Get-AADUser -UPN $UPN | select -expand Id
    $O365TeamId = Get-M365Team -Team $Team | select -expand Id

    $Uri = "https://graph.microsoft.com/beta/teams/$O365TeamId/members"
    $Body = @{
        "@odata.type" = "#microsoft.graph.aadUserConversationMember"
        "roles" = @($Role)
        "user@odata.bind" = "https://graph.microsoft.com/beta/users('$UserId')"
    }
    $JSON = $Body | ConvertTo-Json
    try {
        
        Write-Host "Adding $UPN to $Team..." -f White
        Invoke-RestMethod -Uri $Uri -Body $JSON -ContentType 'application/json' -Headers $Header -Method Post | out-null
        Write-Host "$UPN added to $Team." -f Green

    }
    catch {

        $ResponseResult = $_.Exception.Response.GetResponseStream()
        $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
        $ResponseBody = $ResponseReader.ReadToEnd()
        $ResponseBody  

    }

}
elseif (!$File -and $Multi){

    Write-host "Multi switch selected but no file specified. Please specify file or remove Multi switch." -f red

}
elseif ($File -and !$Multi){

    Write-Host "File specified but Multi switch not used. Please use Multi switch or remove File parameter." -f red

}
else{

    $TeamsToAdd = Get-Content $File
			foreach ($T in $TeamsToAdd)
			{
				
				Try {

					$UserToAdd = Get-AADUser -UPN $UPN | select -expand Id
					$AddTo = Get-M365Team -Team $T | select -expand Id
					$AddtoUri = "https://graph.microsoft.com/beta/teams/$AddTo/members"
					$Body = @{
                        "@odata.type" = "#microsoft.graph.aadUserConversationMember"
                        "roles" = @($Role)
                        "user@odata.bind" = "https://graph.microsoft.com/beta/users('$UserToAdd')"
                    } 
                    $JSON = $Body | ConvertTo-Json
                    Write-Host "Adding $UPN to $T..." -f white
					Invoke-RestMethod -Uri $AddtoUri -Headers $Header -Method "Post" -ContentType "application/json" -Body $JSON
                    Write-Host "$UPN added to $T." -f green
                    Write-Host "============" -f green

				}
				catch{
                    $ResponseResult = $_.Exception.Response.GetResponseStream()
                    $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                    $ResponseBody = $ResponseReader.ReadToEnd()
                    $ResponseBody
                }
				
			}

}


}