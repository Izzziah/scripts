using namespace System.Text.RegularExpressions;

param(
    # [switch]$orderMatters,
    # [switch]$byName,
    # [switch]$unique
    [int]$minSignatures = 1
)
$path = '.\full_stored_proc_reference_parameter_report.report.md';
$objectRegex = 'StoredProcedure:\s.+\n.*(?=\s+StoredProcedure|###|\sQuery)';
$objectNameRegex = "(?<=StoredProcedure:\s)\S+(?=\s*\n\s+')";
$paramRegex = '\{.+\}';
# $paramSplitRegex = ' ';
$rawText = cat $path -Raw;
$objectArray = @(@($rawText | sls $objectRegex -AllMatches).Matches.Value);
# $byName = $true;
# $unique = $true;
# $orderMatters = $false;

#Notes:
# 1. Order of parameters does not matter by default
# 1. setting $byName parameter to $true results in duplicate listings of storedProcs

# TODO: Record line number for each object
$objectNameArray = @($objectArray | sort -Unique | sls -Pattern $objectNameRegex).Matches.Value

[hashtable]$objectHashTable = @{};

$objectNameArray | % { $objectHashTable[$_] = @{} }

foreach ($object in $objectArray)
{
    $objectName = ($object | sls $objectNameRegex).Matches.Value;
    
    $paramString = ($object | sls $paramRegex -AllMatches).Matches.Value;
    # [MatchCollection]$params = [System.Text.RegularExpressions.Regex]::Matches($paramString, $paramRegex);

    $objectHashTable[$objectName][$paramString] += 1;
}

foreach ($objectName in $objectHashTable.Keys)
{
    $objectReport = $objectHashTable[$objectName];
    if ($objectReport.Count -ge $minSignatures)
    {
        echo "## $objectName";
        foreach ($paramsId in $objectReport.Keys | sort)
        {
            echo "`t[$($objectReport[$paramsId])] $paramsId"
        }
    }
}
