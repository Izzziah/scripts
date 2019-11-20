# compareFiles.ps1
# Isaiah Grambo 2019-11-13
##################################################################
# Compare first directory file hashes against the file hashes in any number of other directories
# that match search string. Then list all files that have matching hashes and those that do not.
# Note, if array is passed, regex is ignored
param([Parameter(ValueFromPipeline=$false)][regex]$regex,[Parameter(ValueFromPipeline=$true)][Array]$array, [Parameter()][bool]$markMatches=$false)
if ($array -ne $null) {
    echo $array
    $dirArr = $array;
} else {
    $dirArr = @($(ls | where {$_.attributes -eq 'Directory' -and $_.name -match $regex}));
}
$i = 1
if ($dirArr.Length -le $i)
{
    echo "Only one directory provided"
    exit
}
#use first directory as reference
$refFiles = [Array] $($dirArr[0] | ls | where { $_.attributes -ne 'Directory' });
$refFilesHashes = [Array] $($refFiles | % {$_|Get-FileHash})

#now compare against other dirs
for ($i; $i -lt $dirArr.Length; $i++)
{
    echo $($dirArr[0] | select -ExpandProperty fullname) vs. $($dirArr[$i] | select -ExpandProperty fullname);
    # echo "Files in $(($dirArr[$i]).fullname) without a hash twin in $(($dirArr[0]).fullname):"
    echo "No hash twin in $(($dirArr[0]).fullname) for:`n"
    $selectedFilesArr = [Array] $($dirArr[$i] | ls | where { $_.attributes -ne 'Directory' })
    $selectedFileHashesArr = [Array] $($selectedFilesArr | % {$_|Get-FileHash})
    $selectedFileHashesArr | % { # for each Hash of currently selected Dir...
        # $_ is Hash Object
        $selectedHashedFile = $_;
        $found = $false; 
        $selectedHash = ($_).hash;
        $refFilesHashes | % { #see if hash exists in reference Dir...
            # $_ is Hash Object
            $refHash = $($_).hash
            if ($selectedHash -eq $refHash)
            {
                # echo "$(($selectedHashedFile).path)`n$(($_).path)"
                $found = $true;
            }
        }
        if ($found -eq $false -and $markMatches -eq $false)
        {
            # echo "File: $(($_).path)"
            echo "$(($selectedHashedFile).path)"
        }
        if ($found -eq $true -and $markMatches -eq $true) {
            echo "$(($selectedHashedFile).path)"
        }
    }
    echo "-------------`n"
}