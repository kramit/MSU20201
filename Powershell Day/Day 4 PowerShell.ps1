# Microsoft University
# at Glasspaper

# Week 1 :: POWERSHELL DAY
# by Paul Wojcicki-Jarocki
#     (paul@dash.training)
#               2020-08-14


break # This just makes sure you don't accidentally run the whole file top-to-bottom if you hit F5

# You can run individual lines if you load the file in the ISE or Visual Studio Code, click on a line, and hit F8

$PSVersionTable # NOTE: During the demos, I was using PowerShell 5.1.
                # At this time, the latest version is 7.0.3 and 
                # the below commands should work in any recent version.


# FINDING COMMANDS
dir 
ls 
Get-Alias dir   # PowerShell has many aliases defined to make it easier for you to move from bash or cmd.

VERB-NOUN       # General syntax for most PowerShell cmdlets.
Get-Verb        # You can see which verbs are available.

Get-Command     # Lists commands.
Get-Command *service 
Get-Command -noun service 


# GETTING HELP
Get-Help        # Retrieves documentation for commands...
Update-Help     # ...providing help has been downloaded.

Get-Help dir    # Look at the SYNTAX section, which is a nice summary of how to run a command.

# An example of using parameters
dir             # Get-ChildItem can run without any parameters as they're all optional.
dir c:\         # Same as the next line below, but harder to read.
Get-ChildItem -Path c:\ 
dir c:\ -Recurse # This parameter is a switch. Doesn't require any value.

# Ways of getting more help.
Get-Help dir -Detailed 
Get-Help dir -Full 
Get-Help dir -ShowWindow # should be same content as -Full
Get-Help dir -Online

Get-Help about_* # Help on general PowerShell topics, not cmdlet-specific.


# MODULES
# Modules extend PowerShell's functionality
Get-Module                      # What's currently in memory
Get-SmbShare
Get-Module                      # Previous command loaded the SmbShare module that is now in memory
Get-Module -ListAvailable       # All the modules available to be loaded
Get-Command -Module SmbShare    # Commands from a chosen module

# Starting version 5 (but accessible in 3 and 4) we have a package manager
Find-Module *salesforce*                        # Search online repository for things related to SalesForce
Install-Module SalesforceCmdlets                # Found one! Let's install it.
Install-Module SalesforceCmdlets -AllowClobber  # It complained about overriding an existing command, let's have it install anyway
Get-Command -Module SalesforceCmdlets           # Commands from new module are ready for us to use


#region LAB Exercise 1
# NOTE: I used the #region ... #endregion markup to make this part of the code collapsible.
#       Notice the [-] that appears to the left in tools like the ISE or Visual Studio Code.

Get-Command -Name *Resolve* 
Resolve-DnsName portal.azure.com 

Get-Command -Name *suspend*
Suspend-PrintJob #...

Get-Command -Name *eventlog* 
Get-EventLog
# Yes, you have to include the mandatory LogName parameter for Get-EventLog to work.

Get-Help Set-Service -Examples 
Set-Service -Name spooler -StartupType Automatic 

# Digression... Common Parameters
Get-Help about_CommonParameters
Set-Service -Name spooler -StartupType Automatic -Confirm 
Set-Service -Name spooler -StartupType Manual -WhatIf

Get-NetFirewallRule 
Get-Help Get-NetFirewallRule 
Get-Help Get-NetFirewallRule -Parameter Enabled # Way of getting help on just the one parameter.
Get-NetFirewallRule -Enabled True

Get-Command *edition* 
Get-WindowsEdition -? # Way of quickly getting the basic help.
Get-WindowsEdition -Online

#endregion


# THE PIPELINE
Get-Help dir -full | more                       # Piping is available in other shells but uses just text
                                                # We use OBJECTS, which have PROPERTIES that describe them.

dir | Get-Member                                # See what properties are in the returned object.
dir | Measure-Object                            # Pipe from DIR to MeasureObject to get some statistics.
dir | Measure-Object -Average                   # Average of what?
dir | Measure-Object -Average -Property Size    # Nope. Not the right property name. Check again with Get-Member
dir | Measure-Object -Average -Property Length  # That's the right property name!

# Scenario: find processes consuming a lot of memory.
Get-Process 
Get-Process | Get-Member 
Get-Process | Sort-Object 
Get-Process | Sort-Object -Property WS 
Get-Process | Sort-Object -Property WS -Descending 
Get-Process | Sort-Object -Property WS -Descending | Select-Object -First 3 


# FILTERING
Get-Service                    # Shows all services 
Get-Service -DisplayName Xbox* # Can filter by things like the Display Name.
Get-Service -?                 # Can we filter by the Status?
                               # Nope! We'll have to use another cmdlet for that.

# Digression... Comparisons (we need this to filter)
2 > 3                          # That's NOT the way!
Get-Help about_Comparison_Operators -ShowWindow 
2 -gt 3                        # That's better
5 -lt 100 
'hello' -eq 'HELLO' 
'hello' -Ceq 'HELLO'           # Case sensitive
(2 -gt 3) -or (5 -lt 100)      # Multiple clauses. Find out more with Get-Help about_Logical_Operators
'hello' -like '*LL*'           # Yes
'hello' -like '*LLL*'          # No
'hello' -like '*LL?'           # Yes
'hello' -like '*LL??'          # No

# Now, let's filter.
# The BASIC syntax of Where-Object:
# ... | Where-Object PROPERTY -OPERATOR VALUE 

# Finding services that are currently running
Get-Service | Where-Object Status -eq 'Running' 

# Finding files in current directory that are greater than 1 Megabyte
dir | Where-Object Length -gt 1MB 


# POWERSHELL DRIVES - not just the File System
Set-Location HKLM:        # Oooh, we're in the Registry!
Get-ChildItem 
cd .\SOFTWARE\Microsoft\Windows\CurrentVersion\ 

Get-PSProvider # Lists available providers
Get-PSDrive    # Lists the drives they expose
# Do explore more on your own. Remember that when you switch drives, you use the colon ":"


# FORMATTING
dir | Format-List                               # Display in list format with default properties...
dir | Format-List -Property Name, CreationTime  # ...or choose exactly which properties to show...
dir | Format-List -Property *                   # ...or show all the object's properties.
dir | Format-Wide -AutoSize
dir | Format-Table                              # Display in table format...
dir | Format-Table -AutoSize -Wrap              # ...that can be further modified.
dir | Format-Table -Property Name, Mode

# Remember that the FORMAT commands go near the end of a pipeline
dir | Format-Table -Property Name, Mode | Where-Object Name -Like P*        # This will not work
dir | Where-Object Name -Like P* | Format-Table -Property Name,Mode         # This will


# REDIRECTING OUTPUT
dir | Out-File 'dir.txt'         # Send formatted output to a plain text file
notepad dir.txt

dir | Export-Csv dir.csv         # Export to a Comma Separated Values file
notepad dir.csv 
Invoke-Item dir.csv              # Open the CSV with its associated application
Import-Csv dir.csv               # Import back in... it looks different...
Import-Csv dir.csv | Get-Member  # ...here's why.

dir | export-clixml dir.xml      # Export to a Command Line Interface XML file
notepad dir.xml
Import-Clixml dir.xml            # Import back in. Looks almost like the "original" objects.
Import-Clixml dir.xml | gm       # Inspect it with this Alias of Get-Member


#region LAB Exercise 2

Get-EventLog -LogName Security -InstanceId 4624 -Newest 10                              # Good
Get-EventLog -LogName Security | Where-Object InstanceId -eq 4616 | select -First 10    # Works, but more work and slower
Measure-Command { <PUT COMMAND HERE> }    # Use this to measure the speed of execution and see for yourself.
Get-EventLog -LogName Security -InstanceId 4624 -Newest 10 | Export-Clixml -Path EventsSecurity4624.xml

cd Cert: 
Get-ChildItem -Recurse 
Get-ChildItem -Recurse | gm      # Inspect the 3 returned types and notice the X509Certificate2 has a HasPrivateKey property
Get-ChildItem -Recurse | Where-Object HasPrivateKey -eq $true 
mmc # Explore the certificates graphically by running the Microsoft Management Console and loading the Certificates Snap-in.

#endregion


# Up to this point, commands in this file was exported by running:
Get-History | Format-Table -Property CommandLine -Wrap | Out-File 'Day 4 PowerShell.ps1'


# SCRIPT BASICS
ISE
# I ran the ISE (Integrated Scripting Environment) as it is built into your Windows systems
# although it's better to start using Visual Studio Code as it supports newer versions of PowerShell.

# For the below examples to work, let's first write out a simple script:
"Write-Host -BackgroundColor Blue -ForegroundColor White 'Azure Rulez!'" | Out-File -FilePath MyFirstScript.ps1

MyFirstScript                     # Calling it like this won't work.
.\MyFirstScript.ps1               # You need (at least a relative) path and the extension.
# You may still not be able to run the script if the Execution Policy restricts it.
Get-ExecutionPolicy -List         # See the execution policies set.
Set-ExecutionPolicy Unrestricted  # This may not work on a company-owned computer.

# If you need to sign a script, you will need to have a code-signing certificate.
# Do a web search for how to generate a self-signed certificate.
# If you already have one, you can:
$MyCert = Get-ChildItem Cert:\CurrentUser -Recurse -CodeSigningCert
Set-AuthenticodeSignature -FilePath .\MyFirstScript.ps1 -Certificate $MyCert
.\MyFirstScript.ps1


# The password-generating script went like this, using a lot of variables:
$Password = ''
for ($i = 1; $i -lt 9; $i++) { 
  $number = Get-Random -Minimum 65 -Maximum 122
  $letter = [char]($number)
  $Password += $letter
}
$Password


# WORKING WITH AZURE

# CONNECTING
# Make sure you have the right modules:
Install-Module Az
# To connect:
# You will find your TenantID in the Azure Portal under the AzureAD service
Connect-AzAccount -Tenant "abcdefghijklmnopqrstuvwxyz"
# Verify you connected to the right Subscription
Get-AzContext | Format-Table Account, Name

# CREATING A VM
# A much better example (than mine) can be found in the Microsoft Azure Documentation here:
# https://docs.microsoft.com/en-us/azure/virtual-machines/scripts/virtual-machines-windows-powershell-sample-create-vm

# My example assumed I already had a Resource Group, Virtual Network, and Subnet created.
# It used a strange construct called a hash table and a technique called 'splatting'
$vmParams = @{
  ResourceGroupName = 'Demo'
  Name = 'Demo-A0-Win-3'
  Location = 'westeurope'
  Size = 'Basic_A0'
  ImageName = 'Win2016Datacenter'
  Credential = (Get-Credential) # should be different than Tenant credentials
  VirtualNetworkName = 'Demo-vnet'
  SubnetName = 'FrontEnd'
  OpenPorts = 3389
}
$vm = New-AzVM @vmParams

# You can read more about 'splatting' here:
Get-Help about_Splatting

# ...and there are so many other things to explore!
# ENJOY!
