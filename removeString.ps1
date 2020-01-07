param(
    $remove,
    $file
)
$(cat $file) -replace $remove, ''  | Out-File $file