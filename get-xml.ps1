[CmdletBinding()]
param (
    [Parameter(Mandatory=$true,
    ValueFromPipeline=$true)]
    [string]
    $XmlPath,
    [Parameter(Mandatory=$true,
    ValueFromPipeline=$true)]
    [string]
    $SearchFor
)

$xml = New-Object -TypeName XML
$xml.Load($xmlPath)


for ($dex=0; $dex -lt $SearchFor.Count; $dex++)
{
    # echo $SearchFor
    echo $(Select-Xml -Xml $xml -XPath $SearchFor) | select -ExpandProperty Node
}
