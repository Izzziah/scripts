# Author: Isaiah N Grambo
# Accelitec Inc. 2019-07-09

param([Parameter(ValueFromPipeline=$true)]$path = $null)

$gfvVersion = "1.0.2"

$oldPath = $(pwd | select -ExpandProperty Path)
if ($path -eq $null) {
    cd E:\Accelitec.Apps\
} else {
    cd $path
}

write-host "Get File Versions (gfv) version $gfvVersion" -ForegroundColor Magenta -Verbose
write-host "gfv recursivly searches all files under the E:\Accelitec.Apps\ directory unless another location is passed as a parameter" -ForegroundColor DarkYellow -Verbose
write-host "Note: The most recent version of a given dll in its namespace is treated as the most up to date version of the dll" -ForegroundColor DarkYellow -Verbose
write-host "If the format is off consider raiseing screen-buffer size under Defaults and Properties" -ForegroundColor DarkYellow

$fileInfo = @{}
$errorInfo = @{}

ls -r -filter Accelitec.*.dll | Sort-Object | gi | % {
    $file = $_
    
    $key = $file.Name #$($file.Name -replace "\.","-")
    $version = $(select -InputObject $file -ExpandProperty VersionInfo | select -ExpandProperty FileVersion)
    if ($fileInfo[$key]  -eq $null) { # if file dne...
        # add it to array
        $fileInfo.Add($key, @{$($version) = @($file.FullName)})
    } else { # else
        if ($fileInfo[$key][$version] -eq $null) { # if this is a different version...
            # add to list
            $fileInfo[$key].Add($version, @($file.FullName))
        } else { # otherwise -- stuff new version in
            $fileInfo[$key][$version] += $file.FullName;
        }
    }
}

# now we need to generate a report


$fileInfo.Keys | Sort-Object | % { 
    $key = $_; 
    write-host "`n$key" -NoNewline
    $showDll = $false # show Dll path only for versions that are not most recent
    $fileInfo[$key].Keys | Sort-Object -Descending | % {
        $version = $_;
        if ($showDll) {
            write-host "`t`t$version ($($fileInfo[$key][$version].Count))" -ForegroundColor Red
            $fileInfo[$key][$version] | Sort-Object | % {
                $dll = $_
                write-host `t`t`t$dll
            }
        } else { 
            write-host " $version ($($fileInfo[$key][$version].Count) dll's up to date)" -ForegroundColor Green
            $showDll = $true 
            if ($fileInfo[$key].Count -gt 1) {
                write-host "`tDLL's out of date:" -ForegroundColor Red
            }
        }
    }; 
}
cd $oldPath