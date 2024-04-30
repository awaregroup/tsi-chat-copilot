$frontendDir = $PSScriptRoot + "\webapp"
$webDir = $PSScriptRoot + "\webapi"
$publishDir = $PSScriptRoot + "\publish"

If ((test-path $publishDir) -eq $true) {
    remove-Item $publishDir -Recurse -Force
}

#build .net app
#Start-Process -NoNewWindow -Wait -FilePath "dotnet" -ArgumentList "clean" -WorkingDirectory $webDir -ErrorAction Stop
Start-Process -NoNewWindow -Wait -FilePath "dotnet" -ArgumentList "publish -c Release -r win-x64 --output $publishDir" -WorkingDirectory $webDir -ErrorAction Stop

#delete dev settings
If ((test-path $publishDir) -eq $false) {
  throw "Failed."
  return
}

Remove-Item "$PSScriptRoot\publish\appsettings.*.json" -Force -ErrorAction SilentlyContinue
Remove-Item "$PSScriptRoot\publish\Plugins\*" -Recurse -Force -ErrorAction SilentlyContinue

#build web
Set-Item -Path "Env:NODE_ENV" -Value "production"
Set-Item -Path "Env:REACT_APP_BACKEND_URI" -Value ""
Move-Item -Path "$frontendDir\.env" -Destination "$frontendDir\.tempenv" -Force -ErrorAction SilentlyContinue
Start-Process -NoNewWindow -Wait -FilePath "yarn" -ArgumentList "run build" -WorkingDirectory $frontendDir -ErrorAction Stop
Move-Item -Path "$frontendDir\.tempenv" -Destination "$frontendDir\.env" -Force -ErrorAction SilentlyContinue

#add web app outputs to main dir
Copy-Item -Path "$frontendDir\build\*" -Destination "$publishDir\wwwroot" -Recurse -Force


#build deployment payload
$gitHash = (git rev-parse --short HEAD)
$zipDirName = "tsi-chat-webapp-$gitHash-$(Get-Date -Format 'yyyyMMdd-HHmmss').zip"
Compress-Archive -Path "$PSScriptRoot\publish\*" -DestinationPath $zipDirName