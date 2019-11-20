#Open .sln Project
param(
	[Parameter(Mandatory)]
	[string]
	$searchString)
start $(ls -Filter *$searchString | ls -Filter *.sln | select -expandprop fullname)
