
###############################################################
#     ____  _______    ____  ____  __    ____     _      __   #
#    / __ \/  _/   |  / __ )/ __ \/ /   / __ \   (_)____/ /_  #
#   / / / // // /| | / __  / / / / /   / / / /  / / ___/ __/  #
#  / /_/ // // ___ |/ /_/ / /_/ / /___/ /_/ /  / / /__/ /__   #
# /_____/___/_/  |_/_____/\____/_____/\____/  /_/\___/\__(_)  #
#                 Script by: Sven Jansen                      #
#                    Datum: 07-11-2019                        #
###############################################################
# Diabolo Menu                                                #
# Version: Alpha 0.1                                          #
# Last Edit Date: 25-02-2020 (RBE)                            #
# Created By: Sven Jansen - sven.jansen@diabolo.nl			  		#
###############################################################


# Self-elevate the script
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
 if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
  $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
  Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
  Exit
 }
}

###############################################
# FUNCTIONS
###############################################


Function Write-Color
{
<#
  .SYNOPSIS
    Enables support to write multiple color text on a single line
  .DESCRIPTION
    Users color codes to enable support to write multiple color text on a single line
    ################################################
    # Write-Color Color Codes
    ################################################
    # ^cn = Normal Output Color
    # ^ck = Black
    # ^cb = Blue
    # ^cc = Cyan
    # ^ce = Gray
    # ^cg = Green
    # ^cm = Magenta
    # ^cr = Red
    # ^cw = White
    # ^cy = Yellow
    # ^cB = DarkBlue
    # ^cC = DarkCyan
    # ^cE = DarkGray
    # ^cG = DarkGreen
    # ^cM = DarkMagenta
    # ^cR = DarkRed
    # ^cY = DarkYellow
    ################################################
  .PARAMETER text
    Mandatory. Line of text to write
  .INPUTS
    [string]$text
  .OUTPUTS
    None
  .NOTES
    Version:        1.0
    Author:         Sven Jansen
    Creation Date:  01/11/2019
    Purpose/Change: Initial function development
    Version:        1.1
    Author:         Sven Jansen
    Creation Date:  01/11/2019
    Purpose/Change: Fix Gray / Code Format Fixes
  .EXAMPLE
    Write-Color "Hey look ^crThis is red ^cgAnd this is green!"
#>
 
  [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)][string]$text
    )
     
    ### If $text contains no color codes just write-host as normal
    if (-not $text.Contains("^c"))
    {
        Write-Host "$($text)"
        return
    }
 
 
    ### Set to true if the beginning of $text is a color code. The reason for this is that
    ### the generated array will have an empty/null value for the first element in the array
    ### if this is the case.
    ### Since we also assume that the first character of a split string is a color code we
    ### also need to know if it is, in fact, a color code or if it is a legitimate character.
    $blnStartsWithColor = $false
    if ($text.StartsWith("^c")) {
        $blnStartsWithColor = $true
    }
 
    ### Split the array based on our color code delimeter
    $strArray = $text -split "\^c"
    ### Loop Counter so we can generate a new empty line on the last element of the loop
    $count = 1
 
    ### Loop through the array
    $strArray | % {
        if ($count -eq 1 -and $blnStartsWithColor -eq $false)
        {
            Write-Host $_ -NoNewline
            $count++
        }
        elseif ($_.Length -eq 0)
        {
            $count++
        }
        else
        {
 
            $char = $_.Substring(0,1)
            $color = ""
            switch -CaseSensitive ($char) {
                "b" { $color = "Blue" }
                "B" { $color = "DarkBlue" }
                "c" { $color = "Cyan" }
                "C" { $color = "DarkCyan" }
                "e" { $color = "Gray" }
                "E" { $color = "DarkGray" }
                "g" { $color = "Green" }
                "G" { $color = "DarkGreen" }
                "k" { $color = "Black" }
                "m" { $color = "Magenta" }
                "M" { $color = "DarkMagenta" }
                "r" { $color = "Red" }
                "R" { $color = "DarkRed" }
                "w" { $color = "White" }
                "y" { $color = "Yellow" }
                "Y" { $color = "DarkYellow" }
            }
 
            ### If $color is empty write a Normal line without ForgroundColor Option
            ### else write our colored line without a new line.
            if ($color -eq "")
            {
                Write-Host $_.Substring(1) -NoNewline
            }
            else
            {
                Write-Host $_.Substring(1) -NoNewline -ForegroundColor $color
            }
            ### Last element in the array writes a blank line.
            if ($count -eq $strArray.Count)
            {
                Write-Host ""
            }
            $count++
        }
    }
}

Function New-MenuItem
{
<#
  .SYNOPSIS
    Creates a Menu Item used with New-Menu
  .DESCRIPTION
    Use this in conjunction with New-Menu and Show-Menu
    to generate a menu system for your scripts
  .PARAMETER Name
    Mandatory. Text that shows up in the menu for this menu item.
  .PARAMETER Command
    Mandatory. Command the menu item executes when selected
    Important Note: Define your command in single quotes '' and not double quotes ""
  .INPUTS
    [string]$Name
    [string]$Command
  .OUTPUTS
    [PSObject] Name, Command
  .NOTES
    Version:        1.0
    Author:         Sven Jansen
    Creation Date:  01/11/2019
    Purpose/Change: Initial function development
  .EXAMPLE
    $item = New-MenuItem -Name "List All Services" -Command 'Get-Service'
    $item_end = New-MenuItem -Name "Exit Menu" -Command 'End-Menu'
    $item_switch_menu = New-MenuItem -Name "View Menu 2" -Command 'Show-Menu $menu2'
#>
[CmdletBinding()]
    Param ([Parameter(Mandatory=$true)][string]$Name,
           [Parameter(Mandatory=$true)]$Command)

    ### The first whole word should be the cmdlet.
    $cmd_array = $Command.Split(" ")
    $cmd = $cmd_array[0]

    ### Ensure cmdlet/function is defined if so create and return the menu item
    if ($cmd -eq "End-Menu" -or (Get-Command $cmd -ErrorAction SilentlyContinue))
    {
        $menu_item = New-Object -TypeName PSObject | Select Name, Command
        $menu_item.Name = $Name
        $menu_item.Command = $Command
        return $menu_item
    }
    else
    {
        Write-Error -Message "The command $($Command) does not exist!" -Category ObjectNotFound
        return $null
    }
}

Function New-Menu
{
<#
  .SYNOPSIS
    Creates a looping menu system
  .DESCRIPTION
    Use this in conjunction with New-MenuItem and Show-Menu
    to generate a menu system for your scripts
  .PARAMETER Name
    Mandatory. Text that shows up as the menu title in the menu screen
  .PARAMETER MenuItems[]
    Mandatory. Array of Menu Items created via the New-MenuItem cmdlet
  .INPUTS
    [string]$Name
    [PSObject]$MenuItems[]
  .OUTPUTS
    [PSObject] Name, MenuItems[]
  .NOTES
    Version:        1.0
    Author:         Sven Jansen
    Creation Date:  01/11/2019
    Purpose/Change: Initial function development
  .EXAMPLE
    $main_menu = New-Menu -Name 'Main Menu' -MenuItems @(
        (New-MenuItem -Name 'Get Services' -Command 'Get-Service'),
        (New-MenuItem -Name 'Get ChildItems' -Command 'Get-ChildItem'),
        (New-MenuItem -Name 'GoTo Sub Menu' -Command 'Show-Menu -Menu $sub_menu'),
        (New-MenuItem -Name 'Exit' -Command "End-Menu")
    )
#>
[CmdletBinding()]
    Param ([Parameter(Mandatory=$true)][string]$Name,
           [Parameter(Mandatory=$true)][PSObject[]]$MenuItems)

    ### Create Menu PSObject
    $menu = New-Object -TypeName PSObject | Select Name, MenuItems
    $menu.Name = $Name
    $menu.MenuItems = @()

    ### Loop through each MenuItem and verify they have the correct Properties
    ### and verify that there is a way to exit the menu or open a different menu
    $blnFoundMenuExit = $false
    $blnMenuExitsToMenu = $false
    for ($i = 0; $i -lt $MenuItems.Length; $i++)
    {
        if ((-not $MenuItems[$i].PSObject.Properties['Name']) -or 
            (-not $MenuItems[$i].PSObject.Properties['Command']))
        {
            Write-Error "One or more passed Menu Items were not created with New-MenuItem!" -Category InvalidType
            return
        }
        if ($MenuItems[$i].Command -eq "End-Menu") { $blnFoundMenuExit = $true }
        if ($MenuItems[$i].Command.Contains("Show-Menu")) {$blnMenuExitsToMenu = $true }
        $menu_item = New-Object -TypeName PSObject | Select Number, Name, Command
        $menu_item.Number = $i
        $menu_item.Name = $MenuItems[$i].Name
        $menu_item.Command = $MenuItems[$i].Command
        $menu.MenuItems += @($menu_item)
    }
    if ($blnFoundMenuExit -eq $false -and $blnMenuExitsToMenu -eq $false)
    {
        Write-Error "This menu does not contain an End-Menu or Show-Menu MenuItem and would loop forever!" -Category SyntaxError
        return
    }
    return $menu

}

Function Show-Menu
{
<#
  .SYNOPSIS
    Starts the menu display/selection loop for a menu created with New-Menu
  .DESCRIPTION
    Use this in conjunction with New-Menu and New-MenuItem
    to generate a menu system for your scripts
  .PARAMETER Menu
    Mandatory. A menu created with the New-Menu cmdlet
  .INPUTS
    [PSObject]$Menu
  .OUTPUTS
    Starts the Menu Display Loop
    This function returns nothing
  .NOTES
    Version:        1.0
    Author:         Sven Jansen
    Creation Date:  01/11/2019
    Purpose/Change: Initial function development
  .EXAMPLE
    Show-Menu $MyMenu
#>
[CmdletBinding()]
    Param ([Parameter(Mandatory=$true)][PSObject]$Menu)

    ### Verify $Menu has the right properties
    if ((-not $Menu.PSObject.Properties['Name']) -or 
        (-not $Menu.PSObject.Properties['MenuItems']))
    {
        Write-Error -Message "The passed object is not a Menu created with New-Menu!" -Category InvalidType
        return
    }

    ### Display the Menu via a Do Loop
    $blnMenuExit = $false
    $choice = -1
    Do
    {
	    Write-Host "`r`n===================================================================================================="
        Write-Host "$($Menu.Name)" -ForegroundColor Green
        Write-Host "----------------------------------------------------------------------------------------------------"
        for ($i = 1; $i -lt $Menu.MenuItems.Length+1; $i++)
        {
            Write-Color " ^cg$($i)^cn) ^cn$($Menu.MenuItems[$i-1].Name)^cn"
        }
        Write-Host "`r`n====================================================================================================`r`n"
        Write-Host "Selecteer een item (1-$($Menu.MenuItems.Length)) : " -ForegroundColor Yellow -NoNewline
        $choice = Read-Host
        $choice = ($choice-1 -as [int])
        if ($choice.GetType() -ne [int])
        {
            Write-Host "`r`nError - Ongeldige keuze!`r`n" -ForegroundColor Red
        }
        elseif ($choice -lt 0 -or $choice -ge $Menu.MenuItems.Length)
        {
            Write-Host "`r`nError - Kies een waarde tussen 1 en $($Menu.MenuItems.Length)!`r`n" -ForegroundColor Red
        }
        else
        {
            if ($Menu.MenuItems[$choice].Command -eq "End-Menu" -or
                $Menu.MenuItems[$choice].Command.Contains("Show-Menu"))
            {
                $blnMenuExit = $true
            }
            else
            {
                Invoke-Expression -Command $Menu.MenuItems[$choice].Command
            }
        }
    } Until ($blnMenuExit -eq $true)

    if ($Menu.MenuItems[$choice].Command.Contains("Show-Menu"))
    {
        cls
        Invoke-Expression -Command $Menu.MenuItems[$choice].Command
    }
}

#######################################
# EXCHANGE CONNECTIE
#######################################

Function Exchange-connection {
        # Get current user
	    	$CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
        # Set Credential
        $UserCredential = Get-Credential -UserName $CurrentUser -Message "Voer je credentials in voor Exchange"
        # Connect to EMS
        $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://akjexch01.akj.local/PowerShell/ -Authentication Kerberos -Credential $UserCredential
        Import-PSSession $Session -DisableNameChecking
        
        Enable-Mailbox -Identity $samaccountname
}

#######################################
# KOPIEER FOLDER/APPLICATIE RECHTEN
#######################################

Function Copy-group {
        if (-not ([string]::IsNullOrEmpty($copyfrom)))
        {
      	  $CopyFromUser = Get-ADUser $copyfrom -prop MemberOf
					$CopyToUser = Get-ADUser $samaccountname -prop MemberOf
					$CopyFromUser.MemberOf | Where{$CopyToUser.MemberOf -notcontains $_} |  Add-ADGroupMember -Member $CopyToUser
        }
}

#######################################
# KOPIEER MAILBOX RECHTEN
#######################################

Function Copy-mailbox {
        $mailboxes = Get-Mailbox | Get-MailboxPermission -User $copyfrom | get-mailbox
				foreach($mailbox in $mailboxes) {Add-MailboxPermission -Identity $mailbox.Name -User $logonname -AccessRights FullAccess -InheritanceType All -AutoMapping $false}
        foreach($mailbox in $mailboxes) {Get-Mailbox $mailbox.Name | Add-ADPermission -User $logonname -ExtendedRights "Send As"}
}

#######################################
# AKJ ACCOUNT CREATIE
#######################################

Function Create-AKJ-Account {
    if ($env:COMPUTERNAME -ne "AKJAD01"){
        cls
        return Write-Host "`r`nError - Script wordt niet uitgevoerd op AKJAD01!`r`n" -ForegroundColor Red
    } else {
        Do {
					$firstname = Read-Host 'Voornaam invoeren'
				} Until ($firstname)
        Do {
					$lastname = Read-Host 'Achternaam invoeren'
				} Until ($lastname)
        Do {
					$locatie = Read-Host 'Locatie invoeren (Utrecht, Amsterdam, Deventer, Den Haag)'
				} Until ($locatie)
        Do {
					$functie = Read-Host 'Functie invoeren'
				} Until ($functie)
        Do {
					$telephone = Read-Host '06 invoeren'
				} Until ($telephone)
        Do {
					$description = Read-Host 'Werkdagen invoeren (ma/di/wo/do/vr)'
				} Until ($description)
				$copyfrom = Read-Host 'Rechten en postvakken overnemen van (username)'
        $displayname = $firstname + ' ' + $lastname
        $logonname = $firstname.SubString(0,1) + '.' + $lastname.Trim() + '@akj.local'
        $samaccountname = $firstname.SubString(0,1) + $lastname.SubString(0,3)
        
        if ($locatie -eq 'Utrecht'){
        $straat = "Atoomweg 50"
        $postcode = "3542 AB"
        }
				elseif ($locatie -eq 'Amsterdam'){
        $straat = "IJsbaanpad 9-11"
        $postcode = "1076 CV"
        }
        elseif ($locatie -eq 'Deventer'){
        $straat = "Bergstraat 23"
        $postcode = "7411 ER"
        }
        elseif ($locatie -eq 'Den Haag'){
        $straat = "Koninginnegracht 8-9"
        $postcode = "2514 AAB"
        }

        New-ADUser -Name $displayname -GivenName $firstname -Surname $lastname -SamAccountName $samaccountname -UserPrincipalName $logonname -Path "OU=User Accounts,OU=AKJ Jeugdzorg,DC=AKJ,DC=local" -AccountPassword(Read-Host -AsSecureString "Input Password") -Description $Description -StreetAddress $straat -City $locatie -PostalCode $PostCode -Title $functie -MobilePhone $telephone -Enabled $true -DisplayName $displayname
        
        if (-not ([string]::IsNullOrEmpty($copyfrom)))
        {
      	  $CopyFromUser = Get-ADUser $copyfrom -prop MemberOf
					$CopyToUser = Get-ADUser $samaccountname -prop MemberOf
					$CopyFromUser.MemberOf | Where{$CopyToUser.MemberOf -notcontains $_} |  Add-ADGroupMember -Member $CopyToUser
        }
        
        ForEach ($MBXDB in $MBXDbs) {
        # Get current mailboxes sizes by summing the size of all mailboxes and "Deleted Items" in the database
            $TotalItemSize = Get-MailboxStatistics -Database $MBXDB | %{$_.TotalItemSize.Value.ToMB()} | Measure-Object -sum
            $TotalDeletedItemSize = Get-MailboxStatistics -Database $MBXDB.DistinguishedName | %{$_.TotalDeletedItemSize.Value.ToMB()} | Measure-Object -sum
            #Get-MailboxDatabase and the DatabaseSize property was not used since it does not return a value in some environments  as of 2010 SP2
             
            $TotalDBSize = $TotalItemSize.Sum + $TotalDeletedItemSize.Sum
            # Compare the sizes to find the smallest DB
            If (($TotalDBSize -lt $SmallestDBsize) -or ($SmallestDBsize -eq $null))
                {
                $SmallestDBsize = $TotalDBSize
                $SmallestDB = $MBXDB
                }
        }

        Enable-Mailbox -Identity $samaccountname -Database $SmallestDB
        
        $mailboxes = Get-Mailbox | Get-MailboxPermission -User $copyfrom | get-mailbox
				foreach($mailbox in $mailboxes) {Add-MailboxPermission -Identity $mailbox.Name -User $logonname -AccessRights FullAccess -InheritanceType All -AutoMapping $false}
        foreach($mailbox in $mailboxes) {Get-Mailbox $mailbox.Name | Add-ADPermission -User $logonname -ExtendedRights "Send As"}

              
        return Write-Host "Account aangemaakt" -ForegroundColor Green

    }
}

#######################################
# HGO ACCOUNT CREATIE
#######################################

Function Create-HGO-Account {
    if ($env:COMPUTERNAME -ne "HGOAD01"){
        cls
        return Write-Host "`r`nError - Script wordt niet uitgevoerd op HGOAD01!`r`n" -ForegroundColor Red
    } else {
        Do {
					$firstname = Read-Host 'Voornaam invoeren'
				} Until ($firstname)
        Do {
					$lastname = Read-Host 'Achternaam invoeren'
				} Until ($lastname)
        Do {
					$functie = Read-Host 'Functie invoeren'
				} Until ($functie)
				$copyfrom = Read-Host 'Rechten en postvakken overnemen van (username)'
        $displayname = $firstname + " " + $lastname
        $logonname = $firstname + '@hgo.local'
        $samaccountname = $firstname
              
        
        New-ADUser -Name $displayname -GivenName $firstname -Surname $lastname -SamAccountName $samaccountname -UserPrincipalName $logonname -Path "OU=User Accounts,OU=Het Gelders Orkest,DC=hgo,DC=local" -AccountPassword(Read-Host -AsSecureString "Input Password") -Title $functie -Enabled $true -DisplayName $displayname
        
        if (-not ([string]::IsNullOrEmpty($copyfrom)))
        {
      	  $CopyFromUser = Get-ADUser $copyfrom -prop MemberOf
					$CopyToUser = Get-ADUser $samaccountname -prop MemberOf
					$CopyFromUser.MemberOf | Where{$CopyToUser.MemberOf -notcontains $_} |  Add-ADGroupMember -Member $CopyToUser
        }
        
        # Get current user
	    	$CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
        # Set Credential
        $UserCredential = Get-Credential -UserName $CurrentUser -Message "Voer je credentials in voor Exchange"
        # Connect to EMS
        $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://hgoexch01.hgo.local/PowerShell/ -Authentication Kerberos -Credential $UserCredential
        Import-PSSession $Session -DisableNameChecking

        ForEach ($MBXDB in $MBXDbs) {
        # Get current mailboxes sizes by summing the size of all mailboxes and "Deleted Items" in the database
            $TotalItemSize = Get-MailboxStatistics -Database $MBXDB | %{$_.TotalItemSize.Value.ToMB()} | Measure-Object -sum
            $TotalDeletedItemSize = Get-MailboxStatistics -Database $MBXDB.DistinguishedName | %{$_.TotalDeletedItemSize.Value.ToMB()} | Measure-Object -sum
            #Get-MailboxDatabase and the DatabaseSize property was not used since it does not return a value in some environments  as of 2010 SP2
             
            $TotalDBSize = $TotalItemSize.Sum + $TotalDeletedItemSize.Sum
            # Compare the sizes to find the smallest DB
            If (($TotalDBSize -lt $SmallestDBsize) -or ($SmallestDBsize -eq $null))
                {
                $SmallestDBsize = $TotalDBSize
                $SmallestDB = $MBXDB
                }
        }

        Enable-Mailbox -Identity $samaccountname -Database $SmallestDB
        
        $mailboxes = Get-Mailbox | Get-MailboxPermission -User $copyfrom | get-mailbox
				foreach($mailbox in $mailboxes) {Add-MailboxPermission -Identity $mailbox.Name -User $logonname -AccessRights FullAccess -InheritanceType All -AutoMapping $false}
        foreach($mailbox in $mailboxes) {Get-Mailbox $mailbox.Name | Add-ADPermission -User $logonname -ExtendedRights "Send As"}
        
        return Write-Host "Account aangemaakt.`r`nNadat de gebruiker is aangemaakt dient er contact opgenomen te worden met Sigmax zodat er een contact aangemaakt kan worden voor deze gebruiker in de omgeving van OVHO.`r`nMaak de gebruiker ook aan in CRM." -ForegroundColor Green

    }
}

#######################################
# Burgers Zoo ACCOUNT CREATIE
#######################################

Function Create-BZO-Account {
    if ($env:COMPUTERNAME -ne "BZOAD01"){
        cls
        return Write-Host "`r`nError - Script wordt niet uitgevoerd op BZOAD01!`r`n" -ForegroundColor Red
    } else {
        Do {
					$firstname = Read-Host 'Voornaam invoeren'
				} Until ($firstname)
        Do {
					$lastname = Read-Host 'Achternaam invoeren'
				} Until ($lastname)
        Do {
					$functie = Read-Host 'Functie invoeren'
				} Until ($functie)
				$copyfrom = Read-Host 'Rechten en postvakken overnemen van (username)'
        $displayname = $firstname + ' ' + $lastname
        $logonname = $firstname.SubString(0,1) + '.' + $lastname.Trim() + '@burgerszoo.nl'
        $samaccountname = $lastname.SubString(0,5) + $firstname.SubString(0,3)               
        
        New-ADUser -Name $displayname -GivenName $firstname -Surname $lastname -SamAccountName $samaccountname -UserPrincipalName $logonname -Path "OU=User Accounts,OU=Burgers Zoo,DC=BZ,DC=LOCAL" -AccountPassword(Read-Host -AsSecureString "Input Password") -Title $functie -Enabled $true -DisplayName $displayname
        
        if (-not ([string]::IsNullOrEmpty($copyfrom)))
        {
      	  $CopyFromUser = Get-ADUser $copyfrom -prop MemberOf
					$CopyToUser = Get-ADUser $samaccountname -prop MemberOf
					$CopyFromUser.MemberOf | Where{$CopyToUser.MemberOf -notcontains $_} |  Add-ADGroupMember -Member $CopyToUser
        }
        
        # Get current user
	    	$CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
        # Set Credential
        $UserCredential = Get-Credential -UserName $CurrentUser -Message "Voer je credentials in voor Exchange"
        # Connect to EMS
        $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://bzoexch01.bz.local/PowerShell/ -Authentication Kerberos -Credential $UserCredential
        Import-PSSession $Session -DisableNameChecking

        ForEach ($MBXDB in $MBXDbs) {
        # Get current mailboxes sizes by summing the size of all mailboxes and "Deleted Items" in the database
            $TotalItemSize = Get-MailboxStatistics -Database $MBXDB | %{$_.TotalItemSize.Value.ToMB()} | Measure-Object -sum
            $TotalDeletedItemSize = Get-MailboxStatistics -Database $MBXDB.DistinguishedName | %{$_.TotalDeletedItemSize.Value.ToMB()} | Measure-Object -sum
            #Get-MailboxDatabase and the DatabaseSize property was not used since it does not return a value in some environments  as of 2010 SP2
             
            $TotalDBSize = $TotalItemSize.Sum + $TotalDeletedItemSize.Sum
            # Compare the sizes to find the smallest DB
            If (($TotalDBSize -lt $SmallestDBsize) -or ($SmallestDBsize -eq $null))
                {
                $SmallestDBsize = $TotalDBSize
                $SmallestDB = $MBXDB
                }
        }

        Enable-Mailbox -Identity $samaccountname -Database $SmallestDB
        
        $mailboxes = Get-Mailbox | Get-MailboxPermission -User $copyfrom | get-mailbox
				foreach($mailbox in $mailboxes) {Add-MailboxPermission -Identity $mailbox.Name -User $logonname -AccessRights FullAccess -InheritanceType All -AutoMapping $false}
        foreach($mailbox in $mailboxes) {Get-Mailbox $mailbox.Name | Add-ADPermission -User $logonname -ExtendedRights "Send As"}
        
        return Write-Host "Account aangemaakt" -ForegroundColor Green

    }
}

#######################################
# COMPANEN ACCOUNT CREATIE
#######################################

Function Create-COM-Account {
    if ($env:COMPUTERNAME -ne "COMAD02"){
        cls
        return Write-Host "`r`nError - Script wordt niet uitgevoerd op COMAD02!`r`n" -ForegroundColor Red
    } else {
        Do {
					$firstname = Read-Host 'Voornaam invoeren'
				} Until ($firstname)
        Do {
					$lastname = Read-Host 'Achternaam invoeren'
				} Until ($lastname)
        Do {
					$telephone = Read-Host '06 invoeren conform standaard (+31 6 12345678)'
				} Until ($telephone)
				$copyfrom = Read-Host 'Rechten en postvakken overnemen van (username)'
        $displayname = $firstname + ' ' + $lastname + '(Companen)'
        $logonname = $lastname + '@companen.nl'
        $samaccountname = $firstname
        $agenda = $logonname + '@companen.nl:\Agenda'
        
        New-ADUser -Name $displayname -GivenName $firstname -Surname $lastname -SamAccountName $samaccountname -UserPrincipalName $logonname -Path "OU=User Accounts,OU=Companen,DC=companen,DC=local" -AccountPassword(Read-Host -AsSecureString "Input Password") -MobilePhone $telephone -Enabled $true -DisplayName $displayname    
        
        if (-not ([string]::IsNullOrEmpty($copyfrom)))
        {
      	  $CopyFromUser = Get-ADUser $copyfrom -prop MemberOf
					$CopyToUser = Get-ADUser $samaccountname -prop MemberOf
					$CopyFromUser.MemberOf | Where{$CopyToUser.MemberOf -notcontains $_} |  Add-ADGroupMember -Member $CopyToUser
        }
        
        # Get current user
	    	$CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
        # Set Credential
        $UserCredential = Get-Credential -UserName $CurrentUser -Message "Voer je credentials in voor Exchange"
        # Connect to EMS
        $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://comexch02.companen.local/PowerShell/ -Authentication Kerberos -Credential $UserCredential
        Import-PSSession $Session -DisableNameChecking

        ForEach ($MBXDB in $MBXDbs) {
        # Get current mailboxes sizes by summing the size of all mailboxes and "Deleted Items" in the database
            $TotalItemSize = Get-MailboxStatistics -Database $MBXDB | %{$_.TotalItemSize.Value.ToMB()} | Measure-Object -sum
            $TotalDeletedItemSize = Get-MailboxStatistics -Database $MBXDB.DistinguishedName | %{$_.TotalDeletedItemSize.Value.ToMB()} | Measure-Object -sum
            #Get-MailboxDatabase and the DatabaseSize property was not used since it does not return a value in some environments  as of 2010 SP2
             
            $TotalDBSize = $TotalItemSize.Sum + $TotalDeletedItemSize.Sum
            # Compare the sizes to find the smallest DB
            If (($TotalDBSize -lt $SmallestDBsize) -or ($SmallestDBsize -eq $null))
                {
                $SmallestDBsize = $TotalDBSize
                $SmallestDB = $MBXDB
                }
        }

        Enable-Mailbox -Identity $samaccountname -Database $SmallestDB
        
        $mailboxes = Get-Mailbox | Get-MailboxPermission -User $copyfrom | get-mailbox
				foreach($mailbox in $mailboxes) {Add-MailboxPermission -Identity $mailbox.Name -User $logonname -AccessRights FullAccess -InheritanceType All -AutoMapping $false}
        foreach($mailbox in $mailboxes) {Get-Mailbox $mailbox.Name | Add-ADPermission -User $logonname -ExtendedRights "Send As"}
        
        Add-MailboxPermission -Identity $samaccountname -User 'GG-Beheer' -AccessRight FullAccess -InheritanceType All -Automapping $false
        Add-MailboxPermission -Identity $samaccountname -User 'GG-Secretariaat' -AccessRight FullAccess -InheritanceType All -Automapping $false 
        
        Write-Host "Log nu in met het account en start outlook op.`r`nLog vervolgens uit en druk op enter." -ForegroundColor Green
        pause
        
        set-MailboxFolderPermission $agenda -User default -accessrights Author
        
        return Write-Host "Account aangemaakt`r`nMaak de gebruiker ook aan in CRM." -ForegroundColor Green

    }
}


#######################################
# DONATUS ACCOUNT CREATIE
#######################################

Function Create-DON-Account {
    if ($env:COMPUTERNAME -ne "DONAD01"){
        cls
        return Write-Host "`r`nError - Script wordt niet uitgevoerd op DONAD01!`r`n" -ForegroundColor Red
    } else {
        Do {
                    $firstname = Read-Host 'Voornaam invoeren'
                } Until ($firstname)
        Do {
                    $lastname = Read-Host 'Achternaam invoeren'
                } Until ($lastname)
        Do {
                    $functie = Read-Host 'Functie invoeren'
                } Until ($functie)
        Do {
                    $telephone = Read-Host 'Telefoonnummer invoeren conform standaard (073 522 17 00)'
                } Until ($telephone)
        Do {
                    $description = Read-Host 'Titel (indien van toepassing) + voorletters + voornaam + achternaam invoeren'
                } Until ($description)
        Do {
                    $manager = Read-Host 'Manager/Leidinggevende invoeren (username)'
                } Until ($manager)
                $copyfrom = Read-Host 'Rechten en postvakken overnemen van (username)'
        $displayname = $firstname + ' ' + $lastname
        $logonname = $firstname + $lastname.SubString(0,1) + '@donatus.nl'
        $samaccountname = $firstname + $lastname.SubString(0,1)
        
        New-ADUser -Name $displayname -GivenName $firstname -Surname $lastname -SamAccountName $samaccountname -UserPrincipalName $logonname -Path "OU=User Accounts,OU=Donatus,DC=DONATUS,DC=LOCAL" -AccountPassword(Read-Host -AsSecureString "Input Password") -Description $Description -Title $functie -OfficePhone $telephone -Enabled $true -DisplayName $displayname -Manager $manager 
        
        if (-not ([string]::IsNullOrEmpty($copyfrom)))
        {
          $CopyFromUser = Get-ADUser $copyfrom -prop MemberOf
                    $CopyToUser = Get-ADUser $samaccountname -prop MemberOf
                    $CopyFromUser.MemberOf | Where{$CopyToUser.MemberOf -notcontains $_} |  Add-ADGroupMember -Member $CopyToUser
        }
        
        # Get current user
            $CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
        # Set Credential
        $UserCredential = Get-Credential -UserName $CurrentUser -Message "Voer je credentials in voor Exchange"
        # Connect to EMS
        $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://DONEXCH02.DONATUS.LOCAL/PowerShell/ -Authentication Kerberos -Credential $UserCredential
        Import-PSSession $Session -DisableNameChecking

        ForEach ($MBXDB in $MBXDbs) {
        # Get current mailboxes sizes by summing the size of all mailboxes and "Deleted Items" in the database
            $TotalItemSize = Get-MailboxStatistics -Database $MBXDB | %{$_.TotalItemSize.Value.ToMB()} | Measure-Object -sum
            $TotalDeletedItemSize = Get-MailboxStatistics -Database $MBXDB.DistinguishedName | %{$_.TotalDeletedItemSize.Value.ToMB()} | Measure-Object -sum
            #Get-MailboxDatabase and the DatabaseSize property was not used since it does not return a value in some environments  as of 2010 SP2
             
            $TotalDBSize = $TotalItemSize.Sum + $TotalDeletedItemSize.Sum
            # Compare the sizes to find the smallest DB
            If (($TotalDBSize -lt $SmallestDBsize) -or ($SmallestDBsize -eq $null))
                {
                $SmallestDBsize = $TotalDBSize
                $SmallestDB = $MBXDB
                }
        }

        Enable-Mailbox -Identity $samaccountname -Database $SmallestDB
        
        $mailboxes = Get-Mailbox | Get-MailboxPermission -User $copyfrom | get-mailbox
                foreach($mailbox in $mailboxes) {Add-MailboxPermission -Identity $mailbox.Name -User $logonname -AccessRights FullAccess -InheritanceType All -AutoMapping $false}
        foreach($mailbox in $mailboxes) {Get-Mailbox $mailbox.Name | Add-ADPermission -User $logonname -ExtendedRights "Send As"}
        
        return Write-Host "Account aangemaakt" -ForegroundColor Green

    }
}

#######################################
# TOTAALBED ACCOUNT CREATIE 
#######################################

Function Create-TOT-Account {
    if ($env:COMPUTERNAME -ne "TOTAD01"){
        cls
        return Write-Host "`r`nError - Script wordt niet uitgevoerd op TOTAD01!`r`n" -ForegroundColor Red
    } else {
        Do {
                    $firstname = Read-Host 'Voornaam invoeren'
                } Until ($firstname)
        Do {
                    $lastname = Read-Host 'Achternaam invoeren'
                } Until ($lastname)
        Do {
                    $functie = Read-Host 'Functie invoeren'
                } Until ($functie)
         Do {
                    $company = Read-Host 'Company invoeren'
                } Until ($company)        


        $department = read-host 'Afdeling invoeren indien van toepassing'
        $copyfrom = Read-Host 'Rechten en postvakken overnemen van (username)'
        $displayname = $firstname + ' ' + $lastname
        $logonname = $firstname.SubString(0,1) + '.' + $lastname + '@totaalbed.nl'
        $samaccountname = $firstname.SubString(0,1) + '.' + $lastname
        
        $locatie = 'Zwolle'
        $straat = "Siegenstraat 5"
        $postcode = "8028 PT"       
        
        New-ADUser -Name $displayname -GivenName $firstname -Surname $lastname -SamAccountName $samaccountname -UserPrincipalName $logonname -Path "OU=User Accounts,OU=Totaalbed,DC=TOTAALBED,DC=LOCAL" -AccountPassword(Read-Host -AsSecureString "Input Password") -Description $Description -StreetAddress $straat -City $locatie -PostalCode $PostCode -Title $functie -Enabled $true -DisplayName $displayname -Department $department -Company $company
        
        if (-not ([string]::IsNullOrEmpty($copyfrom)))
        {
          $CopyFromUser = Get-ADUser $copyfrom -prop MemberOf
                    $CopyToUser = Get-ADUser $samaccountname -prop MemberOf
                    $CopyFromUser.MemberOf | Where{$CopyToUser.MemberOf -notcontains $_} |  Add-ADGroupMember -Member $CopyToUser
        }
        
        # Get current user
            $CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
        # Set Credential
        $UserCredential = Get-Credential -UserName $CurrentUser -Message "Voer je credentials in voor Exchange"
        # Connect to EMS
        $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://totexch01.totaalbed.local/PowerShell/ -Authentication Kerberos -Credential $UserCredential
        Import-PSSession $Session -DisableNameChecking

        Enable-Mailbox -Identity $samaccountname
        
        $mailboxes = Get-Mailbox | Get-MailboxPermission -User $copyfrom | get-mailbox
        foreach($mailbox in $mailboxes) {Add-MailboxPermission -Identity $mailbox -User $logonname -AccessRights FullAccess -InheritanceType All -AutoMapping $false}
        foreach($mailbox in $mailboxes) {Get-Mailbox $mailbox | Add-ADPermission -User $logonname -ExtendedRights "Send As"}
        
        return Write-Host "Account aangemaakt" -ForegroundColor Green

    }
}

#######################################
# WIJN & STAEL ACCOUNT CREATIE
#######################################

Function Create-WES-Account {
    if ($env:COMPUTERNAME -ne "WESAD01"){
        cls
        return Write-Host "`r`nError - Script wordt niet uitgevoerd op WESAD01!`r`n" -ForegroundColor Red
    } else {
        Do {
                    $firstname = Read-Host 'Voornaam invoeren'
                } Until ($firstname)
        Do {
                    $lastname = Read-Host 'Achternaam invoeren'
                } Until ($lastname)
        Do {
                    $functie = Read-Host 'Functie invoeren'
                } Until ($functie)
        Do {
                    $telephone = Read-Host 'Telefoonnummer invoeren'
                } Until ($telephone)
                $copyfrom = Read-Host 'Rechten en postvakken overnemen van (username)'
        $displayname = $firstname + ' ' + $lastname
        $logonname = $firstname.SubString(0,1) + '.' + $lastname + '@wijnenstael.nl'
        $samaccountname = $firstname.SubString(0,1) + $lastname
        $agenda = $logonname + '@companen.nl:\Agenda'
        
        New-ADUser -Name $displayname -GivenName $firstname -Surname $lastname -SamAccountName $samaccountname -UserPrincipalName $logonname -Path "OU=User Accounts,OU=Wijn en Stael,DC=wes,DC=local" -AccountPassword(Read-Host -AsSecureString "Input Password") -Title $functie -OfficePhone $telephone -Enabled $true -DisplayName $displayname
        
        if (-not ([string]::IsNullOrEmpty($copyfrom)))
        {
          $CopyFromUser = Get-ADUser $copyfrom -prop MemberOf
                    $CopyToUser = Get-ADUser $samaccountname -prop MemberOf
                    $CopyFromUser.MemberOf | Where{$CopyToUser.MemberOf -notcontains $_} |  Add-ADGroupMember -Member $CopyToUser
        }
        
        # Get current user
            $CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
        # Set Credential
        $UserCredential = Get-Credential -UserName $CurrentUser -Message "Voer je credentials in voor Exchange"
        # Connect to EMS
        $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://wesexch01.wes.local/PowerShell/ -Authentication Kerberos -Credential $UserCredential
        Import-PSSession $Session -DisableNameChecking

        $MBXDbs = Get-MailboxDatabase
 
        # Loop through each of the MBXDbs
 
        ForEach ($MBXDB in $MBXDbs) {
        # Get current mailboxes sizes by summing the size of all mailboxes and "Deleted Items" in the database
            $TotalItemSize = Get-MailboxStatistics -Database $MBXDB | %{$_.TotalItemSize.Value.ToMB()} | Measure-Object -sum
            $TotalDeletedItemSize = Get-MailboxStatistics -Database $MBXDB.DistinguishedName | %{$_.TotalDeletedItemSize.Value.ToMB()} | Measure-Object -sum
            #Get-MailboxDatabase and the DatabaseSize property was not used since it does not return a value in some environments  as of 2010 SP2
             
            $TotalDBSize = $TotalItemSize.Sum + $TotalDeletedItemSize.Sum
            # Compare the sizes to find the smallest DB
            If (($TotalDBSize -lt $SmallestDBsize) -or ($SmallestDBsize -eq $null))
                {
                $SmallestDBsize = $TotalDBSize
                $SmallestDB = $MBXDB
                }
        }

        Enable-Mailbox -Identity $samaccountname -Database $SmallestDB
        
        $mailboxes = Get-Mailbox | Get-MailboxPermission -User $copyfrom | get-mailbox
                foreach($mailbox in $mailboxes) {Add-MailboxPermission -Identity $mailbox.Name -User $logonname -AccessRights FullAccess -InheritanceType All -AutoMapping $false}
        foreach($mailbox in $mailboxes) {Get-Mailbox $mailbox.Name | Add-ADPermission -User $logonname -ExtendedRights "Send As"}

        Write-Host "Log nu in met het account en start outlook op.`r`nLog vervolgens uit en druk op enter." -ForegroundColor Green
        pause
        
        set-MailboxFolderPermission $agenda -User default -accessrights LimitedDetails
        if ($functie = 'Advocaat'){
        Add-MailboxFolderPermission $agenda -User SecretatiaatMailboxPermissiesAdvocaten@wijnenstael.nl -AccessRights PublishingEditor
        }

        return Write-Host "Account aangemaakt" -ForegroundColor Green

    }
}



#######################################
# Drain Server Tool
#######################################

Function Server-Drain-Tool {
cls
    $SDT_ComputerName = Read-Host "Wat is de FQDN van de RD Connection Broker"
    $SDT_Collections = Get-RDSessionCollection -ConnectionBroker $SDT_ComputerName -ErrorVariable SBT_Collection_Error -ErrorAction SilentlyContinue
    if ($SDT_Collection_Error -like "*A Remote Desktop Services deployment does not exist on*"){
        cls
        return Write-Host "`r`nError - Script wordt niet uitgevoerd op de RD Connection Broker!`r`n" -ForegroundColor Red
    } elseif ($SDT_Collection_Error) {
        cls
        return Write-Host "`r`nError - Onbekende foutmelding!`r`n" -ForegroundColor Red
    } else {
        #DESIGNED BY SJ, Diabolo ICT - 13-8-2019
            Add-Type -AssemblyName System.Windows.Forms
            Add-Type -AssemblyName System.Drawing

            $form = New-Object System.Windows.Forms.Form
            $form.Text = 'Collection Selection'
            $form.Size = New-Object System.Drawing.Size(300,200)
            $form.StartPosition = 'CenterScreen'

            $OKButton = New-Object System.Windows.Forms.Button
            $OKButton.Location = New-Object System.Drawing.Point(75,120)
            $OKButton.Size = New-Object System.Drawing.Size(75,23)
            $OKButton.Text = 'OK'
            $OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
            $form.AcceptButton = $OKButton
            $form.Controls.Add($OKButton)

            $CancelButton = New-Object System.Windows.Forms.Button
            $CancelButton.Location = New-Object System.Drawing.Point(150,120)
            $CancelButton.Size = New-Object System.Drawing.Size(75,23)
            $CancelButton.Text = 'Cancel'
            $CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
            $form.CancelButton = $CancelButton
            $form.Controls.Add($CancelButton)

            $label = New-Object System.Windows.Forms.Label
            $label.Location = New-Object System.Drawing.Point(10,20)
            $label.Size = New-Object System.Drawing.Size(280,20)
            $label.Text = 'Please select a terminal collection below:'
            $form.Controls.Add($label)

            $listBox = New-Object System.Windows.Forms.Listbox
            $listBox.Location = New-Object System.Drawing.Point(10,40)
            $listBox.Size = New-Object System.Drawing.Size(260,20)

            $listBox.SelectionMode = 'One'

            $Collections = Get-RDSessionCollection -ConnectionBroker $SDT_ComputerName

            foreach ($collection in $Collections) {

            [void] $listBox.Items.Add($collection.CollectionName)

            }

            $listBox.Height = 70
            $form.Controls.Add($listBox)
            $form.Topmost = $true

            $result = $form.ShowDialog()

            if ($result -eq [System.Windows.Forms.DialogResult]::OK)
            {
                $CollectionResult = $listBox.SelectedItems
                $RDSHosts = Get-RDSessionHost $CollectionResult -ConnectionBroker $SDT_ComputerName | Sort-Object -Property SessionHost

                #Hosts part
                    Add-Type -AssemblyName System.Windows.Forms
                    Add-Type -AssemblyName System.Drawing

                    $form = New-Object System.Windows.Forms.Form
                    $form.Text = 'Select Multiple Host'
                    $form.Size = New-Object System.Drawing.Size(300,400)
                    $form.StartPosition = 'CenterScreen'

                    $OKButton = New-Object System.Windows.Forms.Button
                    $OKButton.Location = New-Object System.Drawing.Point(75,320)
                    $OKButton.Size = New-Object System.Drawing.Size(75,23)
                    $OKButton.Text = 'OK'
                    $OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
                    $form.AcceptButton = $OKButton
                    $form.Controls.Add($OKButton)

                    $CancelButton = New-Object System.Windows.Forms.Button
                    $CancelButton.Location = New-Object System.Drawing.Point(150,320)
                    $CancelButton.Size = New-Object System.Drawing.Size(75,23)
                    $CancelButton.Text = 'Cancel'
                    $CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
                    $form.CancelButton = $CancelButton
                    $form.Controls.Add($CancelButton)

                    $label = New-Object System.Windows.Forms.Label
                    $label.Location = New-Object System.Drawing.Point(10,10)
                    $label.Size = New-Object System.Drawing.Size(280,20)
                    $label.Text = 'Select Hosts which should be edited:'
                    $form.Controls.Add($label)

                    $listBox = New-Object System.Windows.Forms.ListBox
                    $listBox.Location = New-Object System.Drawing.Point(10,30)
                    $listBox.Size = New-Object System.Drawing.Size(260,20)
                    $listBox.Height = 280

                    $listBox.SelectionMode = 'MultiExtended'

                    foreach ($RDSHost in $RDSHosts) {
                        [void] $listBox.Items.Add($RDSHost.SessionHost)
                    }

                    $form.Controls.Add($listBox)
                    $form.Topmost = $true
                    $result = $form.ShowDialog()

                    if ($result -eq [System.Windows.Forms.DialogResult]::OK)
                    {
                        $RDSHostsResult = $listBox.SelectedItems

                        Add-Type -AssemblyName System.Windows.Forms
                        Add-Type -AssemblyName System.Drawing

                        $form = New-Object System.Windows.Forms.Form
                        $form.Text = 'Drain Mode Selection'
                        $form.Size = New-Object System.Drawing.Size(300,200)
                        $form.StartPosition = 'CenterScreen'

                        $OKButton = New-Object System.Windows.Forms.Button
                        $OKButton.Location = New-Object System.Drawing.Point(75,120)
                        $OKButton.Size = New-Object System.Drawing.Size(75,23)
                        $OKButton.Text = 'OK'
                        $OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
                        $form.AcceptButton = $OKButton
                        $form.Controls.Add($OKButton)

                        $CancelButton = New-Object System.Windows.Forms.Button
                        $CancelButton.Location = New-Object System.Drawing.Point(150,120)
                        $CancelButton.Size = New-Object System.Drawing.Size(75,23)
                        $CancelButton.Text = 'Cancel'
                        $CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
                        $form.CancelButton = $CancelButton
                        $form.Controls.Add($CancelButton)

                        $label = New-Object System.Windows.Forms.Label
                        $label.Location = New-Object System.Drawing.Point(10,20)
                        $label.Size = New-Object System.Drawing.Size(280,20)
                        $label.Text = 'Please select the desired drain below:'
                        $form.Controls.Add($label)

                        $listBox = New-Object System.Windows.Forms.Listbox
                        $listBox.Location = New-Object System.Drawing.Point(10,40)
                        $listBox.Size = New-Object System.Drawing.Size(260,20)
                        $listBox.Height = 80

                        $listBox.SelectionMode = 'One'
            
                        [void] $listBox.Items.Add('Remove from Drain')
                        [void] $listBox.Items.Add('Drain until restart')
                        [void] $listBox.Items.Add('Normal Drain')

                        $form.Controls.Add($listBox)
                        $form.Topmost = $true
                        $result = $form.ShowDialog()

                        if ($result -eq [System.Windows.Forms.DialogResult]::OK)
                        {
                           $DrainLevelItem = $listBox.SelectedItem
                            if ($DrainLevelItem -eq 'Remove from Drain') {
                                $DrainLevel = 0
                            } elseif ($DrainLevelItem -eq 'Drain until restart') {
                                $DrainLevel = 1
                            } else {
                                $DrainLevel = 2
                            }
               
                           foreach ($RDSServer in $RDSHostsResult){
                                $WMIHandle = Get-WmiObject -Class "Win32_TerminalServiceSetting" -Namespace "root\CIMV2\terminalservices" -ComputerName $RDSServer -Authentication PacketPrivacy -Impersonation Impersonate
                                Write-Host "Current drain Level of $RDSServer is" $WMIHandle.SessionBrokerDrainMode

                                $FQDN_RDSServer = $RDSServer
    
                                #OLD HANDELING
                                #$WMIHandle.SessionBrokerDrainMode=$DrainLevel
                                #$WMIHandle.put() > $null

                                if ($DrainLevel -eq $WMIHandle.SessionBrokerDrainMode){
                                    Write-Host -ForegroundColor Cyan "$RDSServer is already in the requested drain level"
                                } else {
                                    if ($DrainLevel -eq 0) {
                                        Set-RDSessionHost -SessionHost $FQDN_RDSServer -NewConnectionAllowed Yes
                                        Write-Host -ForegroundColor Green "Drain Level of $RDSServer is set to $DrainLevel > NOT IN DRAIN"
                                    } elseif ($DrainLevel -eq 1) { 
                                        Set-RDSessionHost -SessionHost $FQDN_RDSServer -NewConnectionAllowed NotUntilReboot
                                        Write-Host -ForegroundColor Yellow "Drain Level of $RDSServer is set to $DrainLevel > DRAIN UNTIL REBOOT"
                                    } else {
                                        Set-RDSessionHost -SessionHost $FQDN_RDSServer -NewConnectionAllowed No
                                        Write-Host -ForegroundColor Yellow "Drain Level of $RDSServer is set to $DrainLevel > DRAIN"
                                    }
                                }
                                Write-Host "---"
                                }
                        }
                    }
            }
        cls
        return Write-Host "Success" -ForegroundColor Green
    }
}


########################################
# MENU SAMPLE
########################################

### Setup Window for best fit of menu
$Host.UI.RawUI.BackgroundColor = ""
$HOST.UI.RawUI.ForegroundColor = "White"
$Host.UI.RawUI.WindowTitle = "Menu System Sample"
$pshost = Get-Host
$pswindow = $pshost.ui.rawui
$newsize = $pswindow.buffersize
$newsize.height = 3000
$newsize.width = 100
$pswindow.buffersize = $newsize
$newsize = $pswindow.windowsize
$newsize.height = 50
$newsize.width = 100
$pswindow.windowsize = $newsize
[System.Console]::Clear();

$main_menu = New-Menu -Name 'Startmenu' -MenuItems @(
    (New-MenuItem -Name 'Account creatie menu' -Command 'Show-Menu -Menu $account_menu_create'),
    (New-MenuItem -Name 'Tools menu' -Command 'Show-Menu -Menu $tools_menu'),
    (New-MenuItem -Name 'Sluit menu' -Command "End-Menu")
)
$account_menu_create = New-Menu -Name 'Account creatie' -MenuItems @(
    (New-MenuItem -Name 'SaaS Account aanmaken' -Command 'Show-Menu -Menu $account_menu_create_saas'),
    (New-MenuItem -Name 'On Premise account aanmaken' -Command 'Show-Menu -Menu $account_menu_create_local'),
    (New-MenuItem -Name '< Terug naar startmenu' -Command 'Show-Menu -Menu $main_menu')
)

$account_menu_create_saas = New-Menu -Name 'SaaS Account creatie' -MenuItems @(
    (New-MenuItem -Name 'AKJ Account aanmaken' -Command 'Create-AKJ-Account')
    (New-MenuItem -Name 'BZO Account aanmaken' -Command 'Create-BZO-Account')
    (New-MenuItem -Name 'COM Account aanmaken' -Command 'Create-COM-Account')
    (New-MenuItem -Name 'DON Account aanmaken' -Command 'Create-DON-Account')
    (New-MenuItem -Name 'HGO Account aanmaken' -Command 'Create-HGO-Account')
    (New-MenuItem -Name 'TOT Account aanmaken' -Command 'Create-WES-Account')
    (New-MenuItem -Name 'WES Account aanmaken' -Command 'Create-WES-Account')
    (New-MenuItem -Name '< Terug naar account creatie menu' -Command 'Show-Menu -Menu $account_menu_create')
)

$account_menu_create_local = New-Menu -Name 'On Premise Account creatie' -MenuItems @(
    (New-MenuItem -Name '< Terug naar account creatie menu' -Command 'Show-Menu -Menu $account_menu_create')
)

$tools_menu = New-Menu -Name 'Tools menu' -MenuItems @(
    (New-MenuItem -Name 'Server Drain Tool' -Command 'Server-Drain-Tool')
    (New-MenuItem -Name '< Terug naar account creatie menu' -Command 'Show-Menu -Menu $account_menu_create')
)
clear
Show-Menu -Menu $main_menu
