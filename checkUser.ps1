#$file.path= C:\classes\2018\user.csv
Import-Csv  C:\Users\jmagill.ECC\Desktop\barrett.csv | Foreach-Object{

    $user = ([ADSISEARCHER]"(samaccountname=$($_.user))").FindOne()

    if($user)
    {
        
        #check for disabled
        if($user.GetDirectoryEntry().InvokeGet('AccountDisabled') )
        {
            "enabling account $_.user "
            Enable-ADAccount -Identity $_.user
            Set-ADUser -Identity $_.user -ChangePasswordAtLogon $True
            set-ADAccountPassword  -Identity $_.user -reset -NewPassword (ConvertTo-SecureString  -AsPlainText "Reiver2018" -force)
            Set-ADUser -Identity $_.user -ChangePasswordAtLogon  $True
        }
        else
        {
             "$_.user is all ready enabled "
        }
  

    }
    else
    {
    # add new user
            Write-Warning "adding account for '$($_.user)'"
            $fullName = $_.fname + " " + $_.lname
             New-ADUser -Name $fullName -GivenName $_.fname -Surname $_.lname `
            -SamAccountName  $_.user -UserPrincipalName $_.upn `
            -Path 'ou=student,dc=ecc,dc=iwcc,dc=edu' `
            -AccountPassword  (ConvertTo-SecureString  -AsPlainText "Reiver2018" -force) `
            -PassThru | Enable-ADAccount 
            Add-ADGroupMember -Identity Students -Members $_.user
            Set-ADUser -Identity $_.user -ChangePasswordAtLogon  $True
            
    }
}