
###############################################################
#     ____  _______    ____  ____  __    ____     _      __   #
#    / __ \/  _/   |  / __ )/ __ \/ /   / __ \   (_)____/ /_  #
#   / / / // // /| | / __  / / / / /   / / / /  / / ___/ __/  #
#  / /_/ // // ___ |/ /_/ / /_/ / /___/ /_/ /  / / /__/ /__   #
# /_____/___/_/  |_/_____/\____/_____/\____/  /_/\___/\__(_)  #
#                 Script by: Ramon Bergevoet                  #
#                    Datum: 11-5-2020                         #
###############################################################
# Diabolo Menu                                                #
# Version: Alpha 0.1                                          #
# Last Edit Date: 02-03-2020 (SJA)                            #
# Created By: Ramon Bergevoet - ramon.bergevoet@diabolo.nl    #
###############################################################

# Self-elevate the script
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
 if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
  $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
  Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
  Exit
 }
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


Function Create-AKJ-Account {
    if ($env:COMPUTERNAME -ne "AKJEXCH01"){
        cls
        return Write-Host "`r`nError - Script wordt niet uitgevoerd op AKJEXCH01!`r`n" -ForegroundColor Red
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