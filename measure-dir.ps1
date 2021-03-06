param($path=$home)
$size = get-childitem -recurse $path | Measure-Object -property length -sum;

$total = $size.sum;
$gb = [math]::floor($total / 1GB);
$total = $total - $gb*1GB
$mb = [math]::floor($total / 1MB);
$total = $total - $mb*1MB
$kb = [math]::floor($total / 1KB);

echo $path
if ($gb -gt 0) { echo "`t$gb GB" }
if ($mb -gt 0) { echo "`t$mb MB" }
if ($kb -gt 0) { echo "`t$kb KB" }