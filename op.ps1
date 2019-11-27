#Open .sln Project
param(
	[Parameter(Mandatory)]
	[string]
	$searchString)
start $(ls -Filter *$searchString.sln -r | select -expandprop fullname)
