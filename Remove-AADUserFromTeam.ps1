function Remove-AADUserFromTeam {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)]
        [String]$UPN,    
        [Parameter()]
        [Switch]$All,
        [Parameter()]
        [String]$Team
    )

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

    $token = Get-MsalToken -clientid x -tenantid organizations
    $global:header = @{'Authorization' = $token.createauthorizationHeader()}
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

###########################################################################################################

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
$token = Get-MsalToken -clientid x -tenantid organizations
$global:header = @{'Authorization' = $token.createauthorizationHeader()}

If ($UPN -and $All -and !$Team){

    $Teams = Get-AADUserTeams -UPN $UPN | select -expand displayName
    foreach ($Item in $Teams){

        $O365Team = Get-M365Team -Team $Item
        $Uri = "https://graph.microsoft.com/beta/teams/$($O365Team.Id)/members"
        Try{

            $User = Get-AADUser -UPN $UPN
            $Target = (Invoke-RestMethod -Uri $Uri -Headers $Header -Method Get).value | where {$_.displayname -like "*$($User.displayName)*"}
            $RemovalUri = "https://graph.microsoft.com/beta/teams/$($O365Team.id)/members/$($Target.id)"
            Try {

                Write-Host "Removing $UPN from $Item..." -f white
                Invoke-RestMethod -Uri $RemovalUri -Headers $Header -Method Delete | Out-Null
                Write-Host "$UPN removed from $Item." -f green
                Write-Host "============" -f green

            }
            catch {

                $ResponseResult = $_.Exception.Response.GetResponseStream()
                $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                $ResponseBody = $ResponseReader.ReadToEnd()
                $ResponseBody  
        
            }
    

        }
        catch {

            $ResponseResult = $_.Exception.Response.GetResponseStream()
            $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
            $ResponseBody = $ResponseReader.ReadToEnd()
            $ResponseBody  
    
        }

    }


}
elseif ($UPN -and !$All -and $Team){

    $O365Team = Get-M365Team -Team $Team
    $User = Get-AADUser -UPN $UPN
    $Uri = "https://graph.microsoft.com/beta/teams/$($O365Team.Id)/members"
    $Target = (Invoke-RestMethod -Uri $Uri -Headers $Header -Method Get).value | where {$_.displayname -like "*$($User.displayName)*"}
    $RemovalUri = "https://graph.microsoft.com/beta/teams/$($O365Team.id)/members/$($Target.id)"
    Try {
        
        Write-host "Removing $UPN from $Team..." -f white
        Invoke-RestMethod -Uri $RemovalUri -Headers $Header -Method Delete | Out-Null
        Write-Host "$UPN removed from $Team." -f green

    }
    catch {

        $ResponseResult = $_.Exception.Response.GetResponseStream()
        $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
        $ResponseBody = $ResponseReader.ReadToEnd()
        $ResponseBody  
     
    }
    
}
elseif ($UPN -and !$all -and !$Team){

    Write-Host "Please specify all switch or a Team name using -Team." -f red

}
elseif (!$UPN){

    Write-Host "Please specify a UPN using -UPN." -f red

}

}