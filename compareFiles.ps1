# compareFiles.ps1
# Isaiah Grambo 2019-11-13
##################################################################
# Compare first directory file hashes against the file hashes in any number of other directories
# that match search string. Then list all files that do not have matching hashes -OR- if -markMatches flag is
# specified, list all files that have matching hashes.
# Notes:    
#  1. If array is passed, regex is ignored.
#  2. the $base is passed an index in the list of directories found, that directory will be used
#     as the base reference which all hashes will be checked against
# Known Issues:
#  1. While using the -markMatches flag, only the first non-reference file that matches the 
#     reference file's hash will be listed as matching, however the 'matches found: ' will show the
#     to total number of matching hashes found. Any time that the 'matches found: ' shows more matches 
#     than are listed, it should be assumed that there exist two files with matching implementations within
#     the corresponding non-reference directory.

param(
    [Parameter(ValueFromPipeline=$false)][regex]$regex,
    [Parameter(ValueFromPipeline=$false)][Array]$array, 
    [Parameter()][switch]$markMatches,
    [Parameter(ValueFromPipeline=$false)][int16]$base = 0,
    [Parameter()][switch]$justFiles
    # ,[Parameter()][switch]$startDiff
)

if ($array -ne $null) {
    # if ($justFiles -ne $true) 
    # {
    #     echo $array;
    # }
    $dirArr = $array;
} else {
    $dirArr = @($(ls | where {$_.attributes -eq 'Directory' -and $_.name -match $regex}));
}
$i = 1
if ($dirArr.Length -le $i)
{
    echo "Only one directory provided";
    exit;
}
#use first directory as reference
if ($base -gt 0 -and $base -lt $dirArr.Length) {
    $tmp = $dirArr[0];
    $dirArr[0] = $dirArr[$base];
    $dirArr[$base] = $tmp;
}
$refFiles = [Array] $($dirArr[0] | ls | where { $_.attributes -ne 'Directory' });
$refFilesHashes = [Array] $($refFiles | % {$_|Get-FileHash});

#now compare against other dirs
for ($i; $i -lt $dirArr.Length; $i++)
{
    $matchCount = 0;
    if ($justFiles -ne $true)
    {
        echo $($dirArr[0] | select -ExpandProperty fullname) vs. $($dirArr[$i] | select -ExpandProperty fullname);
    }
    # echo "Files in $(($dirArr[$i]).fullname) without a hash twin in $(($dirArr[0]).fullname):"
    if ($markMatches -and $justFiles -ne $true) 
    {
        echo "Hash twin exists in $(($dirArr[0]).fullname) for:`n";
    } 
    elseif ($justFiles -ne $true)
    {
        echo "No hash twin in $(($dirArr[0]).fullname) for:`n";
    }
    $selectedFilesArr = [Array] $($dirArr[$i] | ls | where { $_.attributes -ne 'Directory' });
    $selectedFileHashesArr = [Array] $($selectedFilesArr | % {$_|Get-FileHash});
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
                $matchCount++;
            }
        }
        if ($found -eq $true -and $markMatches) {
            echo "$(($selectedHashedFile).path)"
        } 
        elseif ($found -eq $false -and $markMatches -ne $true)
        {
            # echo "File: $(($_).path)"
            echo "$(($selectedHashedFile).path)"
        }
    }
    if ($markMatches -and $justFiles -ne $true)
    {
        echo "matches found: $matchCount";
    }
    if ($justFiles -ne $true)
    {
        echo "-------------`n"
    }
}