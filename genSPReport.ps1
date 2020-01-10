param(
    [Parameter()][switch]$save
)
# modified version of rplrpt.ps1 that looks in local dir for rpl files.
$savePath = "$($(pwd).path)\report_stored_procedure_reference";
$savePath += ".txt";
#git pull > $null;

if ($save)
{
    $xml = new-object -typename xml; ls -filter *.rdl | % {write-output "$_"; $xml.load($_.fullname); $tbl = $xml.Report.DataSets.DataSet.Query; $tbl | % { if ($_.CommandType -ne $null) {write-output "`t$($_.DataSourceName.toString())   $($_.CommandText.toString())"} }} > $savePath
    echo $savePath | scb
    echo 'Save path copied to clipboard!'    
}
else 
{
    $xml = new-object -typename xml; ls -filter *.rdl | % {write-output "$_"; $xml.load($_.fullname); $tbl = $xml.Report.DataSets.DataSet.Query; $tbl | % { if ($_.CommandType -ne $null) {write-output "`t$($_.DataSourceName.toString())   $($_.CommandText.toString())"} }}
}