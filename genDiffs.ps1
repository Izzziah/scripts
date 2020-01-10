param(
    [Parameter()]$find,
    [Parameter()]$replace,
    [Parameter()]$path,
    [Parameter()]$scrub=$null) 
$diff1 = ".\$($find).diff"
$diff2 = ".\$($replace).diff"

if ($path -notmatch $find)
{
    if ($path -notmatch $replace)
    {
        echo "Error: '$path' does not contain '$find' or '$replace'"
        exit
    }
    echo "(switching -`$find arg with -`$replace arg)"
    $findCpy = $find
    $find = $replace
    $replace = $findCpy
}

$replacePath = $($path -replace $find,$replace)
echo "diff-ing"
echo "$path vs."
echo $replacePath

$($(cat $path) -replace "><",">`n<") > $diff1; $($(cat $replacePath) -replace "><",">`n<") > $diff2

code --diff $diff1 $diff2

#doing this last in case removeStrings.ps1 dne on $env:path
if ($scrub -ne $null) #remove string if one has been supplied
{
    # $(cat $diff1) -replace $scrub, ''  | Out-File $diff1
    # $(cat $diff2) -replace $scrub, ''  | Out-File $diff2
    removeString -remove $scrub -file $diff1 
    removeString -remove $scrub -file $diff2
}