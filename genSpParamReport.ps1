param(
    [System.String]$searchString
    ,[System.String]$path='.'
    ,[Parameter(ValueFromPipeline=$true)][System.IO.FileInfo[]]$files
)
echo "Searching for: $searchString`n`n"
$xml = new-object -typename xml; 

ls -Path $path -filter *.rdl | % {
    $writeTitle = $true;
    $title = $_.Name
    $xml.load($_.fullname); 
    $tbl = $xml.Report.DataSets.DataSet.Query; 
    $tbl | % { 
        $foundParam = $_.QueryParameters | select -ExpandProperty queryparameter  | select name  | sls $searchString
        if ($foundParam -ne $null) {
            if ($writeTitle) {
                $writeTitle = $false;
                write-output "> $title"; 
            }
            if ($_.CommandType -ne $null) {
                # storedProc?
                echo "`t###$($_.CommandType): $($_.CommandText)";
                # echo "`tfound param: '$foundParam'";
            } else {
                # non-storedProc
                echo "`t###Query: `n`t$($_.CommandText -replace '\s+',' ' -replace "from","`n`t`tfrom" -replace "where","`n`t where")";
                # echo "`tfound param: '$foundParam'";
            }
            echo "`t`t**found param**: '$foundParam'";
        }
    }
}