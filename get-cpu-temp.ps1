#Credit is due to links in comments
#For Hashtable example, used it.  

#Download https://github.com/LibreHardwareMonitor/LibreHardwareMonitor 
#copy LibreHardwareMonitorLib.dll to script DIR


function get-tempcpu{
#https://www.reddit.com/r/PowerShell/comments/pjvoxm/get_cpu_temperature_wo_wmi/
Add-Type -Path LibreHardwareMonitorLib.dll
$computer = New-Object LibreHardwareMonitor.Hardware.Computer
$computer.IsCpuEnabled = $TRUE
#add catch error
$computer.Open();
    foreach ($hardware in $computer.Hardware)
    {  
        foreach ($sensor in $hardware.Sensors)
        { 
            if($sensor.Name -eq "Core Average")
                {
                Write-host $sensor.Name $sensor.Value
                $tempHastTable.add($stopwatch.Elapsed.totalseconds,$sensor.Value)
               }   
        }        
    }
    #write-host "CLOSE"
    #$computer.close();
}

#Start of Script
$stopwatch = [system.diagnostics.stopwatch]::StartNew()
$filename=(Get-date).tostring("MMddyyyy-HHmmss")
#$computer.IsGPUEnabled = $TRUE
$scriptpath = Split-Path -parent $MyInvocation.MyCommand.Definition
$tempHastTable = [ordered]@{}
#$tempHastTable.add($key,$value)
#start-sleep -second 2

if ($args.count -eq 2)
{
 $timer = $args[0]
 $poller = $args[1]
}
else
{
write-host "Example collect data for ~360 seconds, polling 1 second .\get-cpu-temp.ps1 360 1"
Write-host "default is 60 seconds"
Write-host "default polling is  1 second"
$poller = 1
$timer = 60
}
Do
{
#calling function     
get-tempcpu  
start-sleep $poller
#write-host $stopwatch.Elapsed.totalseconds
}While([math]::Round($stopwatch.Elapsed.totalseconds) -le $timer )



#CREATING A CHART! - - https://www.reddit.com/r/PowerShell/comments/1wnr7i/line_chart_graphing_help/ 
#Make Function Later 
[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms.DataVisualization")

# chart object
    $chart1 = New-object System.Windows.Forms.DataVisualization.Charting.Chart
    $chart1.Width = 3840
    $chart1.Height = 2160
    $chart1.BackColor = [System.Drawing.Color]::White

# title 
   [void]$chart1.Titles.Add("CPU Temperature Average")
   $chart1.Titles[0].Font = "Arial,18pt"
   $chart1.Titles[0].Alignment = "topLeft"

# legend 
   $legend = New-Object system.Windows.Forms.DataVisualization.Charting.Legend
   $legend.name = "Legend1"
   $chart1.Legends.Add($legend)

# chart area 
   $chartarea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
   $chartarea.Name = "ChartArea1"
   $chartarea.AxisY.Title = "temperature"
   $chartarea.AxisX.Title = "totalseconds"
   $chartarea.AxisY.Interval = 1
   $chartarea.AxisX.Interval = 5
   $chart1.ChartAreas.Add($chartarea)
   $chart1.Series.Add('CPU-Temperature')
# dump hash table into chart   
   $tempHastTable.GetEnumerator() | ForEach-Object{
    $x = [double][math]::round(($_.key),2)
    $y = [double][math]::round(($_.Value),2)
    $chart1.Series["CPU-Temperature"].Points.addxy($x,$y) 
    }
# data series
   $Chart1.Series["CPU-Temperature"].ChartType = "Line"
   $chart1.Series["CPU-Temperature"].IsVisibleInLegend = $true
   $chart1.Series["CPU-Temperature"].BorderWidth  = 3
   $chart1.Series["CPU-Temperature"].chartarea = "ChartArea1"
   $chart1.Series["CPU-Temperature"].Legend = "Legend1"
   $chart1.Series["CPU-Temperature"].color = "red"
  
# save chart
$chart1.SaveImage("$scriptpath\temperaturechart-$filename.png","png") 
$chart1.SaveImage("$scriptpath\temperaturechart-$filename.emf","Emf") 

# echo hashtable  secondds , C temp
Write-host "export data to screen, copy and paste save as csv"
#$tempHastTable.GetEnumerator() | ForEach-Object{
#    $message = '{0} , {1}' -f $_.key, $_.value
#    Write-Output $message
#}


$stopwatch.stop()
Write-host "Chart saved to $scriptpath\temperaturechart-$filename.png"
Write-host "TotalSeconds:" $stopwatch.Elapsed.totalseconds
mspaint.exe "$scriptpath\temperaturechart-$filename.emf"

   

