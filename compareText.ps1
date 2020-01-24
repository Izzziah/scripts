param(
    [switch]$orderMatters,
    [switch]$byName,
    [switch]$unique
)
$path = '.\full_stored_proc_reference_parameter_report.report.md';
$objectRegex = 'StoredProcedure:\s.+\n.*(?=\s+StoredProcedure|###|\sQuery)';
$objectNameRegex = "(?<=StoredProcedure:\s)\S+(?=\s*\n\s+')";
$paramRegex = '\{.+\}';
$rawText = cat $path -Raw;
$objectArray = @(@($rawText | sls $objectRegex -AllMatches).Matches.Value);
# $byName = $true;
# $unique = $true;
# $orderMatters = $false;

#Notes:
# 1. Order of parameters does not matter by default
# 1. setting $byName parameter to $true results in duplicate listings of storedProcs

# TODO: Record line number for each object

$referenceArray = @($objectArray | sort -Unique)

if ($unique -and $byName) {
    $objectArray = $referenceArray.Clone();
} elseif ($unique) {
    throw "the -unique may only be used in combination with the -byName flag";
}

foreach ($referenceObject in $referenceArray) 
{
    $referenceObject = ($referenceObject -replace
        '\[','\[' -replace 
        '\]','\]' -replace 
        # '\{','\{' -replace 
        # '\}','\}' -replace
        '\.','\.' -replace
        '\+','\');

    $referenceObjectName = ($referenceObject | sls -Pattern $objectNameRegex).Matches.Value;
    $referenceObjectName = ($referenceObjectName -replace 
        '\s','' -replace 
        '\[','\[' -replace 
        '\]','\]' -replace 
        # '\{','\{' -replace 
        # '\}','\}' -replace
        '\.','\.' -replace
        '\\+','\'
    );
    $referenceParamArr = ($referenceObject | where { 
        $_ -match $paramRegex } | sls -Pattern $paramRegex).Matches.Value;
    # echo $referenceObject
    # echo '--'
    # echo "### Reference: $referenceObject"
    # echo '--'
    # echo "For: $referenceObjectName"
    if ($byName) {
        $matchArr = @($objectArray | where { 
            $_ -match "\s+$referenceObjectName\s+" });

        echo "## $($referenceObjectName -replace '\\','')";
        echo "  Count: $($matchArr.Count)"

        $matchArr | % {
            echo "`t$($_ -replace "`n","`n`t")" 
        }
        continue; # skip mismatch logic
    }

    $mismatchArr = @($objectArray | where { 
        $_ -match "\s+$referenceObjectName\s+" -and $_ -ne $referenceObject });
    
    # we have a list of objects that have matching names but do not match in other ways
    
    if ($mismatchArr.Length -gt 0) 
    {
        $verifiedMismatches = @(); # ready to hold results of mismatch verification logic
        foreach ($mismatchObject in $mismatchArr)
        { 
            $paramArr = ($mismatchObject | where { $mismatchObject -match $paramRegex } | sls -Pattern $paramRegex).Matches.Value;
            $foundMismatch = $false;
            if ($paramArr.Length -eq $referenceParamArr.Length) 
            {
                $i = 0;
                if ($orderMatters)
                {
                    foreach ($param in $paramArr) 
                    {
                        if ($mismatchObject -ne $referenceParamArr[$i++]) 
                        {
                            $foundMismatch = $true;
                            break;
                        }
                    }
                }
                else # need to search for match order independent
                {
                    throw "OrderMatters Not Implemented"
                }
            } 
            else 
            {
                $foundMismatch = $true;
            }

            # echo $paramArr
            if ($mismatch) 
            {
                $verifiedMismatches += $mismatchObject
            }
        }
        if ($verifiedMismatches.Length -gt 0) 
        {
            echo "## Reference:  `n`t$($referenceObject -replace "`n","`n`t")";
            echo "###`tDetected the following Mismatch(es):`n";
            $verifiedMismatches | % {
                echo "`t$($mismatchObject -replace "`n","`n`t")" 
            }
        }
    }
}