# Target Server 이름 입력
$remote_host = Read-Host "Enter the remote computer name (target server)"

# 원격 접속
$s = New-PSSession -ComputerName $remote_host
IF (-not ($s)) {
    Write-Host "Connection Failed"
    Exit
}
ELSE {
    Write-Host("Succeed to access remote computer: " + $remote_host + "`n")
}

# 사용자 시간 입력
WHILE ($true) {
    $time = Read-Host "`nInput Total Time (ex. 1h (1 hour), 20m (20 minutes), 30s (30 seconds))"
    $time_num = [int]::Parse($time.Substring(0, $time.Length-1))
    $time_unit = $time[-1]
    IF (($time_unit -eq "h") -or ($time_unit -eq "m") -or ($time_unit -eq "s")) {
        break
    }
    Write-Host "Invalid Input `n"
}

# 시간 처리
IF ($time_unit -eq "h") {
    $total_time = $time_num.ToString() + " hours"
    Write-Host ("Total time is " + $total_time + "`n")
    $time_num *= 3600
} ELSEIF ($time_num -eq "m") {
    $total_time = $time_num.ToString() + " minutes"
    Write-Host ("Total time is " + $total_time + "`n")
    $time_num *= 60
} ELSEIF ($time_num -eq "s") {
    $total_time = $time_num.ToString() + " seconds"
    Write-Host ("Total time is " + $total_time + "`n")
}

# 파일 이름 날짜 추가
$dt = date
$strDt = $dt.ToString("yyMMdd_HHmmss")

# 사용자 파일 이름 입력 (.blg, .csv, .pnd 동일)
$file_name = $remote_host + "_" + $strDt
$file_blg = $file_name + ".blg"
Write-Host ("Perfmon will create the " + $file_blg + "`n")

# 카운터 목록
$JSON = Get-Content -Raw -Path ".\counterlist.json" | ConvertFrom-Json
$JSON_content = $JSON.Default

$CounterList = @()

FOR ($i=0; $i -lt $JSON_content.Counter.Length; $i++) {
    $counter = $JSON_content[$i].Counter
    FOR ($j=0; $j -lt $JSON_content[$i].Counter_Name.Length; $j++) {
        $temp = $counter + $JSON_content[$i].Counter_Name[$j]
        $CounterList += $temp
    }
}

Write-Host("`n==================== Counter List ====================")
FOR ($index=0; $index -lt $CounterList.Length; $index++) {
    Write-Host $CounterList[$index]
}
Write-Host("========================================================`nCheck the Counter List above `n")

# perfmon 실행
Write-Host("Start to measure the performance of the above counters for " + $total_time + " and record on " + $file_blg + "`n")
Invoke-Command -Session $s -ScriptBlock {Get-Counter -Counter $Using:CounterList -MaxSamples $Using:time_num | Export-Counter -Force -Path ($Using:file_blg)}

# 원격, 로컬 경로
$RemotePath = (Invoke-Command -Session $s -ScriptBlock {Get-Location}).ToString() + "\" + $file_blg
$LocalPath = Get-Location

# csv 파일 전송
Copy-Item -FromSession $s $RemotePath -Destination $LocalPath

IF (-not (Test-Path $file_blg)) {
    Write-Host "blg file transfer failed `n"
    Exit
}
ELSE {
    Write-Host "The blg file was transferred successfully `n"
}

# 원격 서버 종료
Remove-PSSession $s

# blg to csv
relog -f csv $file_blg -o ($file_name + ".csv")
$file_csv = $file_name + ".csv"

IF (-not (Test-Path $file_csv)) {
    Write-Host "csv file transformation failed`n"
    Exit
}
ELSE {
    Write-Host ("`nThe blg file was transformed to csv file and being preprocessed`n")
}

# csv 파일 전처리 후 json 파일로 변환
python .\preprocessing_ES.py $LocalPath $file_csv


$file_json = "D:\perfmon-test\" + $file_name + ".json"

# json 파일 전처리
$json_content = @(
    @{
        content = [io.file]::ReadAllText($file_json)
        service_name = 'perf-counter'
    }
)

$body = $json_content | ConvertTo-Json

# json 파일 ES 전송
IF($LogStashAddress){Clear-Variable -Name LogStashAddress}
$LogStashAddress = "http://{LogstashIPAddress}:5678"
Invoke-RestMethod -Uri $LogStashAddress -Method Post -Body $body -ContentType "application/json"
