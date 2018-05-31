#'===================================================================
#' Specify the your environment specific settings
#'===================================================================
$domain   = "YOURDOMAIN"
$domAdmin = "YOURDOMAIN\Administrator"
$domPass  = "!Password!"
$csvFile  = "C:\Users\Joe\BulkData.csv"
 
#'===================================================================
#' This function creates the user
#'===================================================================
function CreateUser ($data)
{

#'===================================================================
#' Construct the ADsPath
#'===================================================================
$adspath  = "LDAP://" + $domain + "/" + $data."Container/OU".ToString()
    
  #'===================================================================
#' Bind to the container
#'===================================================================
$oContainer = new-object System.DirectoryServices.DirectoryEntry $adspath, $domAdmin, $domPass
$oContainer.RefreshCache()
Write-Host "Creating user: >> " $data."Common Name".ToString()
    
$cnStr    = ("CN=" + $data."Common Name".ToString())
$firstStr = $data."First Name".ToString()
$lastStr  = $data."Last Name".ToString()
$samStr   = $data."NT Name".ToString()
$passStr  = $data."Password".ToString()
            
#'===================================================================
#' Create a User object and populate the following attributes:
#' givenName, sn, samAccountName, 
#'===================================================================
$oUser = $oContainer.Children.Add($cnStr, "user")
$retval = $oUser.Properties["givenname"].Add($firstStr)
$retval = $oUser.Properties["sn"].Add($lastStr)
$retval = $oUser.Properties["samAccountName"].Add($samStr)
$oUser.CommitChanges()
 
#'===================================================================
#' Set the initial password 
#'===================================================================        
$oUser.SetPassword($passStr)
 
$oldUAC = $oUser.userAccountControl
$newUAC = $oldUAC.Value -band (-bnot 2)
    
#'===================================================================
#' Enable the user
#'===================================================================        
$oUser.userAccountControl = $newUAC
$oUser.CommitChanges()
 }
  
#'===================================================================
#' Read the CSV File
#'===================================================================
$csvData = Import-Csv $csvFile
 
#'===================================================================
#' Process each item and send it to the CreateUser function
#'===================================================================
$csvData | % {CreateUser($_)}