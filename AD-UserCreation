<#
.SYNOPSIS
    Script to create a fictional ActiveDirectory Setup
.DESCRIPTION
    This script will create an Top ou with the same name as the domain name.
    From a csv file of 250 firstnames and lastnames, will the script create 250 users in AD with the same names.
    From the firstname and lastname a samaccountname/username, will also be created.
    Multiple OU's and groups (Administration, IT-afdeling,  Marketing, Salg, Produktion, Udvikling)
.NOTES
    Created by: Kristian, Kevin, crysal and Flemming
    Date: 29-10 2019
#>

# ------------------------------- [Functions] -------------------------------------------- #
function Output # Function to write output to console
{
    param($text, 
    [ValidateSet('Error','Info','Warning')]$type)

    $getdate = Get-date -Format "dd-MM-yyyy HH:mm:ss"
    $fulltext = "$getdate - $text"
    $date = Get-Date -Format "dd-MM-yyyy"
    $LogPath = "C:\Users\Administrator\Documents\Logs\ActiveDirectorySetup-$date.txt"

    switch ($type)
    {
        'Error'{Write-Host "$fulltext" -BackgroundColor Red }
        'Info'{Write-Host "$fulltext" -BackgroundColor Blue }
        'Warning'{Write-Host "$fulltext" -BackgroundColor Yellow}
        default{write-host "$fulltext" -BackgroundColor Blue}
    }
    
    if(!(Test-Path $LogPath))
    {
        New-Item $LogPath -Force
    }
    "$Fulltext" | Out-File $LogPath -Append
}

function NewADUser # Function to create new user in Active Directory
{
    param($Name,
        $FirstName,
        $LastName,
        $SamAccountName,
        $UserPath
        )

    try
    {
        $password = "Kode1234" | ConvertTo-SecureString -AsPlainText -Force
        $User = New-ADUser -Name $Name -GivenName $FirstName -Surname $LastName -SamAccountName $SamAccountName -DisplayName $SamAccountName -Path $UserPath -Enabled:$true -ChangePasswordAtLogon:$true -AccountPassword $password 
        return $User
    }
    catch
    {
        return $error[0]
    }
}

function NewGroup # Function to create new group in Active Directory
{
    param($GroupName, $GroupPath)

    try
    {
        $Group = New-ADGroup -Name $GroupName -Path $GroupPath -GroupCategory Distribution -GroupScope Global
        return $Group
    }
    catch
    {
        return $error[0]
    }
}

function NewOU # Function to create new organizational unit in Active Directory
{
    param($OUName,$OUPath)

    try
    {
        New-ADOrganizationalUnit -Name $OUName -Path $OUPath
        $OU = Get-ADOrganizationalUnit -Filter "name -eq '$OUName'"
        return $OU
    }
    catch
    {
        return $error[0]
    }
    
}

function AddToADGroup # Function to add users or groups to a specific group
{
    param($Source,$Destination)

    try
    {
        $test = Add-ADGroupMember -Identity $Destination -Members $Source
        return $test
    }
    catch
    {
        return $error[0]
    }
}

function MoveADObject # Function to move ad object to new location through Distinguishedname
{
    param($Identity, $Destination)

    try
    {
        $MoveObj = Move-ADObject -Identity $Identity -TargetPath $Destination
        return $MoveObj
    }
    catch
    {
        return $error[0]
    }
}

# ------------------------------ [Variabler] --------------------------------------------- #
$UserFilePath = "C:\Users\Administrator\Documents\BrugereTilNicklasSvenneforløb.csv"

$ADGroupNames = "Administration","IT-Afdeling","Salg","Marketing","Udvikling","Produktion"
$ADOUNames = "Groups","Users"

$DomainSettings = Get-ADDomain

# ------------------------------- [Main script] ------------------------------------------ #
Output "Importing module: ActiveDirectory" -type Info
Import-Module ActiveDirectory

#region Creating Header OU from DomainName
Output "Starting initial OU creator" -type Info
Output "Creating OU: $($DomainSettings.Name)" -type Info
if(!(Get-ADOrganizationalUnit -Filter "name -eq '$($DomainSettings.Name)'"))
{
    $MainOU = NewOU -OUName $DomainSettings.Name -OUPath $DomainSettings.DistinguishedName
    if(!($MainOU))
    {
        Output "Failed to create OU: $($DomainSettings.Name)" -type Error 
        Output "Script will exit in 5 seconds..."
        sleep 5
        exit
    }
}
else
{
    Output "OU: $($DomainSettings.Name) already exists" -type Info
}

#endregion

#region Creating Groups and OU, under header OU.
foreach($ADOUName in $ADOUNames)
{
    Output "Creating OU: $ADOUName - Path: $($MainOU.DistinguishedName)" -type Info
    if(!(Get-ADOrganizationalUnit -Filter "name -eq '$ADOUName'"))
    {
        $UnderOU = NewOU -OUName $ADOUName -OUPath $MainOU.DistinguishedName
        if(!($UnderOU))
        {
            Output "Failed to create OU: $ADOUName - ERROR: $($Error[0])" -type Warning
            Output "Script will exit in 5 sec..."
            sleep 5
            exit
        }
    }
    else
    {
        Output "OU: $ADOUName already exists" -type Info
    }
}
#endregion

#region Creating Groups and OUs with the same name.
Output "Starting intial Group Creator" -type Info
$OUForGroups = Get-ADOrganizationalUnit -Filter "name -eq '$($ADOUNames[0])'"
foreach($ADGroupName in $ADGroupNames)
{
    $GroupExists = Get-ADGroup $ADGroupName
    if(!($GroupExists -eq $null))
    {
        Output "Creating Group - Name: $ADGroupName - Path: $ADGroupPath" -type Info
        $ADGroupObj = NewGroup -GroupName $ADGroupName -GroupPath $OUForGroups.DistinguishedName
    }
    else
    {
        Output "Group: $ADGroupname already exists." -type Info
    }
    Output "Creating OU: $ADGroupName - Path: $($OUForUsers.DistinguishedName)" -type Info
    if(!(Get-ADOrganizationalUnit -Filter "name -eq '$ADGroupname'"))
    {
        $UnderOU = NewOU -OUName $ADGroupName -OUPath $OUForUsers.DistinguishedName
        if(!($UnderOU))
        {
            Output "Failed to create OU: $ADOUName - ERROR: $($Error[0])" -type Warning
            Output "Script will exit in 5 sec..."
            sleep 5
            exit
        }
    }
    else
    {
        Output "OU: $ADOUName already exists" -type Info
    }
}

$ItAfdeling = Get-ADGroup $ADGroupNames[1]
$Administration = Get-ADGroup $ADGroupNames[0]
$MembersExist = Get-ADGroupMember $ADGroupnames[0] | where {$_.name -eq $ADGroupNames[1]}
if($MembersExist -eq $null)
{
    Output "Adding Groupname: $($ADGroupnames[1]) to GroupName: $($ADGroupNames[0])" -type Info
    AddToADGroup -Source $ItAfdeling -Destination $Administration
}
else
{
    Output "$($ADGroupNames[1]) is already a member of $($ADGroupNames[0])"
}
#endregion

#region Creating Users from csv file. (CSV has to have headerrows, with the names Surname,as firstname, and lastname,as lastname.)
Output -text "Importere brugere fra CSVFile: $UserFilePath" -type Info
$OUForUsers = Get-ADOrganizationalUnit -Filter "name -eq '$($ADOUNames[1])'"
$Brugere = Import-Csv $UserFilePath -Delimiter ';'

Foreach($Bruger in $Brugere)
{
    $Fullname = $Bruger.Surname + " " + $bruger.Lastname
    $SamAccountName = $Bruger.Surname.substring(0, [System.Math]::Min(3, $Bruger.Surname.Length)) + "0" + $Bruger.Lastname.Substring(0,2)
    $UserObj = Get-ADUser -Filter {name -eq $Fullname}
    if($UserObj -eq $null)
    {
        Output "Creating User: $SamAccountName at Path: $($OUForUsers.DistinguishedName)" -type Info
        $User = NewADUser -Name $Fullname -FirstName $Bruger.Surname -LastName $Bruger.Lastname -SamAccountName $SamAccountName -UserPath $OUForUsers.DistinguishedName        
    }
    else
    {
        Output "$SamAccountName already exist!" -type Info
    }
}
#endregion

#region Assign Administration users to groups and OU.
$Allusers = Get-ADUser -Filter *
$AdministrationUsers = $Allusers | select -First 4
$AdministrationOU = Get-ADOrganizationalUnit -Filter {name -like "Administration"}
foreach($AdministrationUser in $AdministrationUsers)
{
    Output "Moving $($AdministrationUser.Name) to $($AdministrationOU.DistinguishedName)" -type Info
    if($AdministrationUser.DistinguishedName -eq $AdministrationOU.DistinguishedName)
    {
        Output "$($AdministrationUser.Name) has already been moved to $($AdministrationOU.DistinguishedName)" -type Info
    }
    else
    {
        MoveADObject -Identity $AdministrationUser -Destination $AdministrationOU.DistinguishedName
    }
    Output "Adding $($AdministrationUser.name) to $($Administration.Name)" -type Info
    if((Get-ADGroupMember $Administration).name -like $AdministrationUser.name)
    {
        Output "$($AdministrationUser.name) is already member of $($Administration.Name)" -type Info
    }
    else
    {
        AddToADGroup -Source $AdministrationUser -Destination $Administration
    }
}
#endregion

#region Assign IT-afdeling users to group and OU
$ITAfdelingUsers = $Allusers | select -Skip 4 -First 6
$ITAfdelingOU = Get-ADOrganizationalUnit -Filter {name -like "IT-Afdeling"}
foreach($ITAfdelingUser in $ITAfdelingUsers)
{
    Output "Moving $($ITAfdelingUser.Name) to $($ITAfdelingOU.DistinguishedName)" -type Info
    if($ITAfdelingUser.DistinguishedName -eq $ITAfdelingOU.DistinguishedName)
    {
        Output "$($ITAfdelingUser.Name) has already been moved to $($ITAfdelingOU.DistinguishedName)" -type Info
    }
    else
    {
        MoveADObject -Identity $ITAfdelingUser -Destination $ITAfdelingOU.DistinguishedName
    }
    Output "Adding $($ITAfdelingUser.name) to $($ItAfdeling.Name)" -type Info
    if((Get-ADGroupMember $ItAfdeling).name -like $ITAfdelingUser.name)
    {
        Output "$($ITAfdelingUser.name) is already member of $($ItAfdeling.Name)" -type Info
    }
    else
    {
        AddToADGroup -Source $ITAfdelingUser -Destination $ItAfdeling
    }
}
#endregion

#region Assign Marketing Users to group and OU
$MarketingUsers = $Allusers | select -Skip 10 -First 50
$MarketingOU = Get-ADOrganizationalUnit -Filter {name -like "Marketing"}
$MarketingGRP = Get-ADGroup "Marketing"
foreach($MarketingUser in $MarketingUsers)
{
    Output "Moving $($MarketingUser.Name) to $($MarketingOU.DistinguishedName)" -type Info
    if($MarketingUser.DistinguishedName -eq $MarketingOU.DistinguishedName)
    {
        Output "$($MarketingUser.Name) has already been moved to $($MarketingOU.DistinguishedName)" -type Info
    }
    else
    {
        MoveADObject -Identity $MarketingUser -Destination $MarketingOU.DistinguishedName
    }
    Output "Adding $($MarketingUser.name) to $($MarketingGRP.Name)" -type Info
    if((Get-ADGroupMember $MarketingGRP).name -like $MarketingUser.name)
    {
        Output "$($MarketingUser.name) is already member of $($MarketingGRP.Name)" -type Info
    }
    else
    {
        AddToADGroup -Source $MarketingUser -Destination $MarketingGRP
    }
}
#endregion

#region Assign Produktion users to group and OU
$ProduktionUsers = $Allusers |  select -Skip 60 -First 50
$ProduktionOU = Get-ADOrganizationalUnit -Filter {name -like "Produktion"}
$ProduktionGRP = Get-ADGroup "Produktion"
foreach($ProduktionUser in $ProduktionUsers)
{
    Output "Moving $($ProduktionUser.Name) to $($ProduktionOU.DistinguishedName)" -type Info
    if($ProduktionUser.DistinguishedName -eq $ProduktionOU.DistinguishedName)
    {
        Output "$($ProduktionUser.Name) has already been moved to $($ProduktionOU.DistinguishedName)" -type Info
    }
    else
    {
        MoveADObject -Identity $ProduktionUser -Destination $ProduktionOU.DistinguishedName
    }
    Output "Adding $($ProduktionUser.name) to $($ProduktionGRP.Name)" -type Info
    if((Get-ADGroupMember $ProduktionGRP).name -like $ProduktionUser.name)
    {
        Output "$($ProduktionUser.name) is already member of $($ProduktionGRP.Name)" -type Info
    }
    else
    {
        AddToADGroup -Source $ProduktionUser -Destination $ProduktionGRP
    }
}
#endregion

#region Assign Salg users to group and OU
$SalgUsers = $Allusers | select -Skip 110 -First 50
$SalgOU = Get-ADOrganizationalUnit -Filter {name -like "Salg"}
$SalgGRP = Get-ADGroup "Salg"
foreach($SalgUser in $SalgUsers)
{
    Output "Moving $($SalgUser.Name) to $($SalgOU.DistinguishedName)" -type Info
    if($SalgUser.DistinguishedName -eq $SalgOU.DistinguishedName)
    {
        Output "$($SalgUser.Name) has already been moved to $($SalgOU.DistinguishedName)" -type Info
    }
    else
    {
        MoveADObject -Identity $SalgUser -Destination $SalgOU.DistinguishedName
    }
    Output "Adding $($SalgUser.name) to $($SalgGRP.Name)" -type Info
    if((Get-ADGroupMember $SalgGRP).name -like $SalgUser.name)
    {
        Output "$($SalgUser.name) is already member of $($SalgGRP.Name)" -type Info
    }
    else
    {
        AddToADGroup -Source $SalgUser -Destination $SalgGRP
    }
}
#endregion

#region Assign Udvikling users to group and OU 
$UdviklingUsers = $Allusers | select -Skip 160 -First 50
$UdviklingOU = Get-ADOrganizationalUnit -Filter {name -like "Udvikling"}
$UdviklingGRP = Get-ADGroup "Udvikling"
foreach($UdviklingUser in $UdviklingUsers)
{
    Output "Moving $($UdviklingUser.Name) to $($UdviklingOU.DistinguishedName)" -type Info
    if($UdviklingUser.DistinguishedName -eq $UdviklingOU.DistinguishedName)
    {
        Output "$($UdviklingUser.Name) has already been moved to $($UdviklingOU.DistinguishedName)" -type Info
    }
    else
    {
        MoveADObject -Identity $UdviklingUser -Destination $UdviklingOU.DistinguishedName
    }
    Output "Adding $($UdviklingUser.name) to $($UdviklingGRP.Name)" -type Info
    if((Get-ADGroupMember $UdviklingGRP).name -like $UdviklingUser.name)
    {
        Output "$($UdviklingUser.name) is already member of $($UdviklingGRP.Name)" -type Info
    }
    else
    {
        AddToADGroup -Source $UdviklingUser -Destination $UdviklingGRP
    }
}
#endregion

Output "Script is done!" -type Info
