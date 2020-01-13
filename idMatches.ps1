param(
    [System.IO.DirectoryInfo[]]$srcDirs,
    [System.IO.DirectoryInfo[]]$cprDirs,
    [regex]$filterString = '.*'
)

#forEach srcDir in srcDirs:
foreach($srcDir in $srcDirs)
{
    #list out srcDir
    Write-Output "## Directory: $($srcDir.name)"
    # filter out non rpl files
    [System.IO.FileInfo[]]$srcFiles = $($srcDir.GetFiles() | where {$_.name -match $filterString})
    #forEach srcFile in srcDir:
    foreach ($srcFile in $srcFiles)
    {
        #list out srcFile
        Write-Output "`t###  File: $($srcFile.name)"
        #forEach cprDir in cprDirs:
        foreach ($cprDir in $($cprDirs | where {$_.GetType() -eq [System.IO.DirectoryInfo]}))
        {
            $addedItem = $false
            $str = "`t`tFor Directory: $($cprDir.name)`n"
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
        