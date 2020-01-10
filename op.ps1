#Open .sln Project
param(
	[Parameter(Mandatory)]
	[string]
	$searchString)
start $(ls -Filter *$searchString.sln -r -Depth 2 | select -expandprop fullname)
