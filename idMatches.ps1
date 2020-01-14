# compareFiles.ps1
# Isaiah Grambo 2019-11-13
##################################################################
# Generate list of files that have matching names or implentations comparision made against files within supplied
# list of Source Directories against supplied list of Comparison Directories.
#assumptions: 
# 1. $srcDirs contains dirs with >= files than $cprDirs
# 2. All directories within $srcDirs and $cprDirs have at least 1 .rpl file within (theoretically could work with 
#    different file types: need at least 1 file in each)

param(
    [System.IO.DirectoryInfo[]]$srcDirs,
    [System.IO.DirectoryInfo[]]$cprDirs,
    [regex]$filterString = '.*'
)

#forEach srcDir in srcDirs:
foreach($srcDir in $srcDirs)
{
    #list out srcDir
    $srcDirNamed = $false
    # filter out non rpl files
    [System.IO.FileInfo[]]$srcFiles = $($srcDir.GetFiles() | where {$_.name -match $filterString})
    #forEach srcFile in srcDir:
    foreach ($srcFile in $srcFiles)
    {
        #list out srcFile
        $srcFileNamed = $false
        #forEach cprDir in cprDirs:
        foreach ($cprDir in $($cprDirs | where {$_.GetType() -eq [System.IO.DirectoryInfo]}))
        {

            # need to calculate unique names
            #region Unique Name Calculation #
            $srcPathArr = $srcDir.fullname -split '\\';
            $cprPathArr = $cprDir.fullname -split '\\';
            $srcUniqueName = '';
            $cprUniqueName = '';
        
            $index = 0;
        
            $max = if ($srcPathArr.length -lt $cprPathArr.length) { $srcPathArr.length } else { $cprPathArr.length }
            
            $lastMatch = $null;
            while ($index -lt $max -and $srcPathArr[$index] -eq $cprPathArr[$index])
            {
                $lastMatch = $srcPathArr[$index++]
            }
        
            if ($lastMatch -ne $null)
            {
                # $srcUniqueName = $cprUniqueName = $lastMatch;
                for ($i = $index; $i -lt $srcPathArr.length; $i++)
                {
                    $srcUniqueName += "\$($srcPathArr[$i])"
                }
                for ($i = $index; $i -lt $cprPathArr.length; $i++)
                {
                    $cprUniqueName += "\$($cprPathArr[$i])"
                }
            }
            else
            {
                $srcUniqueName = $srcDir.fullname
                $cprUniqueName = $cprDir.fullname
            }
            #endregion Unique Name Calculation #

            # now that unique names have been calculated, print out unique src names:
            #region Source Directory Labeling
            if ($srcDirNamed -eq $false)
            {
                Write-Output "## Directory: $($srcUniqueName)"
                $srcDirNamed = $true;
            }
            if ($srcFileNamed -eq $false)
            {
                Write-Output "`t###  File: $($srcFile.name)"
                $srcFileNamed = $true
            }
            #endregion Source Directory Labeling

            $addedItem = $false
            $str = "`t`tFor Directory: $($cprUniqueName)`n"

            # filter out non rpl files
            [System.IO.FileInfo[]]$cprFiles = $($cprDir.GetFiles() | where {$_.name -match $filterString})
            #search each cprFile in cprDir for name that matches srcFile.name
            foreach($cprFile in $cprFiles)
            {
                $srcFileHash = (Get-FileHash -path $srcFile.fullname).hash
                $cprFileHash = (Get-FileHash -path $cprFile.fullname).hash
                if (($cprFile.name -eq $srcFile.name))
                {
                    if ($srcFileHash -eq $cprFileHash)
                    {
                        $str += "`t`t`t- $($cprFile.name) [MATCHING]`n"
                        $str += "`t`t`t`t Matching Name`n"
                        $str += "`t`t`t`t Matching Implementation`n"
                    }
                    else
                    {
                        $str += "`t`t`t- $($cprFile.name) [DIFFERENT]`n"
                        $str += "`t`t`t`t Matching Name`n"
                        $str += "`t`t`t`t Different Implementation`n"
                    }
                    $addedItem = $true;
                }
                else
                {
                    if ($srcFileHash -eq $cprFileHash)
                    {
                        $str += "`t`t`t- $($cprFile.name) [MATCHING]`n"
                        $str += "`t`t`t`t Different Name`n"
                        $str += "`t`t`t`t Matching Implementation`n"
                        $addedItem = $true;
                    }
                }
            }
            #
            if ($addedItem)
            {
                $str | Write-Output
            }
        }
        #
    }
    #
}
#
        