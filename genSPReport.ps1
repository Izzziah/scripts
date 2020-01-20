param(
    [Parameter()][switch]$save
    ,[Parameter()][string]$filterOn
    ,[string]$path='.'
)
# modified version of rplrpt.ps1 that looks in local dir for rpl files.
#git pull > $null;

if ($save)
{
    $savePath = "$($(pwd).path)\report_stored_procedure_reference";
    $savePath += ".txt";
    $xml = new-object -typename xml; 
    ls -Path $path -filter *.rdl | % {
        write-output "$_"; 
        $xml.load($_.fullname); 
        $tbl = $xml.Report.DataSets.DataSet.Query; 
        $tbl | % { 
            if ($_.CommandType -ne $null) {
                write-output "`t$($_.DataSourceName.toString())   $($_.CommandText.toString())";
            } 
        }
    } > $savePath;

    echo $savePath | scb;
    echo 'Save path copied to clipboard!';
}
else 
{
    $xml = new-object -typename xml; 
    ls -Path $path -filter *.rdl | % {
        write-output "$_"; 
        $xml.load($_.fullname); 
        $tbl = $xml.Report.DataSets.DataSet.Query; 
        $tbl | % { 
            if ($_.CommandType -ne $null) {
                write-output "`t$($_.DataSourceName.toString())   $($_.CommandText.toString())";
            } 
        }
    }
}