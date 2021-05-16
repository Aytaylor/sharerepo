<###################################################################################################################################
.SYNOPSIS	
Script to extract the compressed UPS invoice CSV and PDF files to designated directories.
Author: Alex Taylor
Updated: 1/30/2017

.DESCRIPTION
The script extracts the .zip files (Manually downloaded from https://www.ups.com/viewbill/invoices?loc=en_US saved into the logged in User's Downloads folder) and places the CSV into "UPS Flat Files".
The PDF is placed into the same Downloads folder. Both CSV and PDF are archived into "UPS Flat Files Archive - (Current Year).zip". The PDF is automatically attached to an email.


.NOTES
This script assumes the user is downloading both UPS files to the local Downloads folder for their user profile
You must edit the $ExtractTargetPDF and $ExtractTargetCSV paths if you intend on downloading the zip files to another
location.

To-Do: Change path variables to actual paths.
Actual Path for invoice CSV: 
Actual Path for archival: 
#> 
####################################################################################################################################

$Updated = "01-30-2017"

#Opens IE to the UPS invoice website and My LJM File Manager.
$OpenTab = 0x1000
$ie = New-Object -ComObject InternetExplorer.Application
$ie.Navigate("https://www.ups.com/viewbill/invoices?loc=en_US")

#$ie.Navigate("http://filemanager.myljm.com/", $OpenTab) 
#MyLJM hasn't worked for a few months. Uncomment The line above (line 28) and delete this comment if it's restored.

Write-host "Last Updated: "$Updated

$ie.Visible = $true
#Read-Host is used because it was the simplest solution to a "wait for input pause" that I could find. 
Read-Host -Prompt "Download the UPS invoice files, then Press Enter to Continue"


#Variables that define target files and destination. This script by default extracts both files to the same location.
#PDF Folder Invoice.zip 
#CSV Folder Invoice.zip
$ExtractTargetPDF = ($home + "\downloads\Invoice.zip")
$ExtractTargetCSV = ($home + "\downloads\Invoice.zip")
$ExtractCSVDest = ("UPS Flat Files")
$ExtractPDFDest = ($home + "\downloads\")
$ZipDest = ("UPS Flat Files Archive - 2017.zip")

#Email Variables
$To = 
$From = 
$BCC = 
$Body = ("The entire invoice PDF is attached. Print at your convenience. Please email ITServices with questions.")
$Subject = ("UPS Invoice Attached")
$PSEmailServer = ("InternalMail") 

#Checks for a valid path to the Zip file then executes cmdlet if True. This step fails if there are multiple UPS CSV's and PDF's 
if (test-path -path $ExtractTargetPDF) 
	{
	#Expand-Archive cmdlet unzips target files and places them into the destination
	Expand-Archive -path $ExtractTargetPDF -dest $ExtractPDFDest -Confirm -Verbose
	} 
Else 
	{
	Write-Host "Invalid File Path for PDF. Make sure the .zip folder location and the variables match. Exiting script..." -foregroundcolor red
	exit
	}
if (test-path -path $ExtractTargetCSV)
	{
	Expand-Archive -path $ExtractTargetCSV -dest $ExtractCSVDest -Confirm -Verbose
	}
Else 
	{
	Write-Host "Invalid File Path for CSV. Make sure the .zip folder location and the variables match. Exiting script..."
    exit
	}

#CSV and PDF Variables
$UpsCSV = "Invoice.csv"
$UpsPDF = ($home + "\downloads\Invoice.pdf")

#Send to Archive. DO NOT allow any file deletions!
if (test-path -path $UpsCSV)
    {
    Compress-Archive -Path $UpsCSV -Update -Dest $ZipDest -Confirm -Verbose
    }
Else
    {
    Write-Host "Invalid Path for CSV file. You may need to complete this step manually. Exiting script..."
    exit
    }
if (test-path -path $UpsPDF)
    {
    Compress-Archive -Path $UpsPDF -Update -Dest $ZipDest -Confirm -Verbose
    
    #Opens folder to show extracted files
    Invoke-item $ExtractCSVDest

    #Emails PDF Invoice to Kurt Goodwin. It's recommended you change the BCC address to your own so you can confirm the email was sent successfully without having to log into the CSG account.
    Send-MailMessage -to $To -Bcc $BCC -from $From -subject $Subject -Body $Body -Attachments $UpsPDF

    Write-Host "Script is done. Check that the files are in the correct locations. You will need to manually upload the CSV to http://filemanager.myljm.com/. It's recommended you delete the downloaded .zip files." -foregroundcolor Green
    }
Else
    {
    Write-Host "Invalid Path for PDF file. You may need to complete this step manually. Exiting script..."
    exit
    }
