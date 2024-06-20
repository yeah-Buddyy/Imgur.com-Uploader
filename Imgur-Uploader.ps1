# TODO
# handle video files https://parvez1487.medium.com/how-to-upload-video-using-imgur-api-phpflow-com-1cac7db37d7b

# https://github.com/bkeiren/EasyImgur/blob/master/EasyImgur/ImgurAPI.cs
$ImgurClientID = "5fae4323a27c0cf"

function Check-FileSize {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    # https://help.imgur.com/hc/en-us/articles/115000083326-What-files-can-I-upload-Is-there-a-size-limit-
    # Define maximum file sizes in bytes
    $maxSizeImage = 20MB
    $maxSizeAnimationVideo = 200MB

    # Get the file extension
    $fileExtension = [System.IO.Path]::GetExtension($FilePath).ToLower()

    # Get the file size
    $fileSize = (Get-Item $FilePath).Length

    # Check the file size based on the extension
    switch ($fileExtension) {
        ".jpg" { return $fileSize -gt $maxSizeImage }
        ".jpeg" { return $fileSize -gt $maxSizeImage }
        ".png" { return $fileSize -gt $maxSizeImage }
        ".apng" { return $fileSize -gt $maxSizeImage }
        ".tiff" { return $fileSize -gt $maxSizeImage }
        ".tif" { return $fileSize -gt $maxSizeImage }
        ".gif" { return $fileSize -gt $maxSizeAnimationVideo }
        ".mp4" { return $fileSize -gt $maxSizeAnimationVideo }
        ".avi" { return $fileSize -gt $maxSizeAnimationVideo }
        ".mpeg" { return $fileSize -gt $maxSizeAnimationVideo }
        ".webm" { return $fileSize -gt $maxSizeAnimationVideo }
        default { return "Unsupported file extension: $fileExtension" }
    }
}

function ImgurSingleUpload() {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ImageToUpload 
    )

    $base64Image = [convert]::ToBase64String(([System.IO.File]::ReadAllBytes($ImageToUpload)))

    # https://apidocs.imgur.com/
    $headers = @{"Authorization" = "Client-ID $ImgurClientID"; "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36"}
    $response = Invoke-RestMethod -DisableKeepAlive -Uri "https://api.imgur.com/3/image" -Method "POST" -Headers $headers -Body "$base64Image" -ContentType "application/base64"

    $ConvertToJson = $response | ConvertTo-Json | ConvertFrom-Json

    $ImgurStatus = $ConvertToJson.status
    $ImgurId = $ConvertToJson.data.id
    $Imgurtype = $ConvertToJson.data.type
    $ImgurSize = $ConvertToJson.data.size
    $ImgurDeleteHash = $ConvertToJson.data.deletehash
    $ImgurUrl = $ConvertToJson.data.link

    $HistoryFile = "$PSScriptRoot\Imgur-Upload-History.txt"
    if ($ImgurStatus -eq "200") { 
        Write-Output "Upload Successfully"
        if(!(Test-Path -Path "$HistoryFile")) {
            Out-File -FilePath "$HistoryFile"
            Write-Output "File "$HistoryFile" created successfully"
        }

        $TodaysDate = Get-Date
        Add-Content "$HistoryFile" "############################### Imgur Single Upload ###############################"
        Add-Content "$HistoryFile" "Date: $TodaysDate"
        Add-Content "$HistoryFile" "ID: $ImgurId"
        Add-Content "$HistoryFile" "FileName: $ImageToUpload"
        Add-Content "$HistoryFile" "FileSize: $ImgurSize"
        Add-Content "$HistoryFile" "FileType: $Imgurtype"
        Add-Content "$HistoryFile" "DeleteUrl: https://imgur.com/delete/$ImgurDeleteHash"
        Add-Content "$HistoryFile" "Url: $ImgurUrl"
        Add-Content "$HistoryFile" "############################### Imgur Single Upload ###############################"
        Add-Content "$HistoryFile" "`n"

        if ("$TempClipboardImageFolder") {
            if (Test-Path "$TempClipboardImageFolder") {
                Write-Output "Folder Exists"
                Remove-Item "$TempClipboardImageFolder" -Recurse -Force
            } else {
                Write-Output "Folder Doesn't Exists"
            }
        }

        Set-Clipboard -Value "$ImgurUrl"

        # Auto close messagebox after 3 second
        $Body = "$ImgurUrl"
        $Shell = new-object -comobject wscript.shell -ErrorAction Stop
        (New-Object Media.SoundPlayer "$Env:WinDir\Media\tada.wav").Play();
        $Disclaimer = $Shell.popup("Imgur url copied to clipboard! `n`n$Body",3,"Image Upload Successfull",0)
        $Disclaimer | Out-Null
    } else {
        Write-Output "Upload Error"
        Add-Type -AssemblyName Microsoft.VisualBasic
        $msgBoxInput = [Microsoft.VisualBasic.Interaction]::MsgBox("Imgur upload error!`n Status: $ImgurStatus`n $response","Information", "Upload failed!!!")
        exit
    }
}

function ImgurUploadAlbum() {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ImageToUpload 
    )

    # Create Imgur Album and get the Deletehash
    $Body1 = @{
        privacy = "hidden"
    }
    $response = Invoke-RestMethod  -DisableKeepAlive -Uri "https://api.imgur.com/3/album" -Method "POST" -Headers @{"Authorization" = "Client-ID $ImgurClientID"; "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36"} -Body $Body1

    $ConvertToJson = $response | ConvertTo-Json | ConvertFrom-Json

    $ImgurStatus = $ConvertToJson.status
    $ImgurAlbumID = $ConvertToJson.data.id
    $AlbumDeleteHash = $ConvertToJson.data.deletehash

    $HistoryFile = "$PSScriptRoot\Imgur-Upload-History.txt"
    if (-not [string]::IsNullOrEmpty($AlbumDeleteHash) -and $ImgurStatus -eq "200") {
        Write-Output "Album created Successfully"
        if(!(Test-Path -Path "$HistoryFile")) {
            Out-File -FilePath "$HistoryFile"
            Write-Output "File "$HistoryFile" created successfully"
        }

        # https://help.imgur.com/hc/en-us/articles/115000083326-What-files-can-I-upload-Is-there-a-size-limit-
        $filters = "*.jpeg", "*.jpg", "*.png", "*.gif", "*.apng", "*.tiff", "*.tif"
        $GetAllImagesInFolder = $filters | % { Join-Path "$ImageToUpload" $_ } | Resolve-Path

        $array = @()
        foreach ($Image in $GetAllImagesInFolder) {
            $result = Check-FileSize -FilePath "$Image"
            if ($result -is [boolean]) {
                if ($result) {
                    Write-Output "The file size exceeds the limit."
                    continue
                } else {
                    Write-Output "The file size is within the limit."
                }
            } else {
                continue
            }
            
            # Add Images to Album
            $FileBase64 = [convert]::ToBase64String(([System.IO.File]::ReadAllBytes($Image)))

            $headers = @{"Authorization" = "Client-ID $ImgurClientID"; "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36"}
            $response1 = Invoke-RestMethod -DisableKeepAlive -Uri "https://api.imgur.com/3/image" -Method "POST" -Headers $headers -Body $FileBase64 -ContentType "application/base64"

            $ConvertToJson1 = $response1 | ConvertTo-Json | ConvertFrom-Json

            $ImgurStatus1 = $ConvertToJson1.status
            $ImgurId1 = $ConvertToJson1.data.id
            $Imgurtype1 = $ConvertToJson1.data.type
            $ImgurSize1 = $ConvertToJson1.data.size
            $ImgurDeleteHash1 = $ConvertToJson1.data.deletehash
            $ImgurUrl1 = $ConvertToJson1.data.link
            if ($ImgurStatus1 -eq "200") { 
                $array += $ImgurDeleteHash1
            } else {
                Write-Output "Album upload error"
                Add-Type -AssemblyName Microsoft.VisualBasic
                $msgBoxInput = [Microsoft.VisualBasic.Interaction]::MsgBox("Imgur album upload error!`n Status: $ImgurStatus1`n $response1","Information", "Album upload failed!!!")
                exit
            }
        }

        $commaDelimitedString = $array -join ','

        $Body2 = @{
            deletehashes = $commaDelimitedString
        }
        $response2 = Invoke-RestMethod -DisableKeepAlive -Uri "https://api.imgur.com/3/album/$AlbumDeleteHash/add" -Method "POST" -Headers $headers -Body $Body2

        $TodaysDate = Get-Date
        Add-Content "$HistoryFile" "############################### Imgur Album Upload ###############################"
        Add-Content "$HistoryFile" "Date: $TodaysDate"
        Add-Content "$HistoryFile" "AlbumID: $ImgurAlbumID"
        Add-Content "$HistoryFile" "AlbumDeleteHash: $AlbumDeleteHash"
        Add-Content "$HistoryFile" "AlbumUrl: https://imgur.com/a/$ImgurAlbumID"
        Add-Content "$HistoryFile" "How to delete album: https://apidocs.imgur.com/#2a8759da-625f-4519-a8df-1b08c7377be7"
        Add-Content "$HistoryFile" "Album DeleteUrl: https://imgur.com/delete/$AlbumDeleteHash"
        Add-Content "$HistoryFile" "############################### Imgur Album Upload ###############################"
        Add-Content "$HistoryFile" "`n"
        
        Set-Clipboard -Value "https://imgur.com/a/$ImgurAlbumID"

        # Auto close messagebox after 3 second
        $Body = "https://imgur.com/a/$ImgurAlbumID"
        $Shell = new-object -comobject wscript.shell -ErrorAction Stop
        (New-Object Media.SoundPlayer "$Env:WinDir\Media\tada.wav").Play();
        $Disclaimer = $Shell.popup("Imgur album url copied to clipboard! `n`n$Body",3,"Album upload successfull",0)
        $Disclaimer | Out-Null
    } else {
        Write-Output "Album upload error"
        Add-Type -AssemblyName Microsoft.VisualBasic
        $msgBoxInput = [Microsoft.VisualBasic.Interaction]::MsgBox("Album upload error!`n Status: $ImgurStatus`n $response","Information", "Album upload failed!!!")
        exit
    }
}


# https://osd.osdeploy.com/module/functions/general/save-clipboardimage
# Save-ClipboardImage "C:\Users\PC\Desktop\test\test.png"
function Save-ClipboardImage() {
    [CmdletBinding()]
    param(
        #Path and Name of the file to save
        #PNG extension is recommend
        [Parameter(Mandatory = $true)]
        $SaveAs
    )
    #Test if the Clipboard contains an Image
    if (!(Get-Clipboard -Format Image)) {
        Write-Warning "Clipboard Image does not exist"
        Add-Type -AssemblyName Microsoft.VisualBasic
        $msgBoxInput = [Microsoft.VisualBasic.Interaction]::MsgBox("Clipboard image does not exist","Information", "Clipboard image does not exist")
        Exit
    }

    #Test if existing file is present
    if (Test-Path $SaveAs) {
        Write-Warning "Existing file '$SaveAs' will be overwritten"
    }

    Try {
        (Get-Clipboard -Format Image).Save($SaveAs)
    }
    Catch{
        Write-Warning "Clipboard Image does not exist"
        Add-Type -AssemblyName Microsoft.VisualBasic
        $msgBoxInput = [Microsoft.VisualBasic.Interaction]::MsgBox("Clipboard image does not exist","Information", "Clipboard image does not exist")
        Exit
    }

    #Make sure that a file was written
    if (!(Test-Path $SaveAs)) {
        Write-Warning "Clipboard image could not be saved to '$SaveAs'"
    }

    $result = Check-FileSize -FilePath "$SaveAs"
    if ($result -is [boolean]) {
        if ($result) {
            Write-Output "The file size exceeds the limit."
            Add-Type -AssemblyName Microsoft.VisualBasic
            $msgBoxInput = [Microsoft.VisualBasic.Interaction]::MsgBox("The file size exceeds the limit.","Information", "The file size exceeds the limit")
            exit
        } else {
            Write-Output "The file size is within the limit."
        }
    } else {
        Write-Output $result
        Add-Type -AssemblyName Microsoft.VisualBasic
        $msgBoxInput = [Microsoft.VisualBasic.Interaction]::MsgBox("$result","Information", "Error!")
        exit
    }

    #Return Get-Item Object
    # Return Get-Item -Path $SaveAs
    ImgurSingleUpload $SaveAs
}

# Function to check if a string is a valid URL
function IsUrlValid([string]$url) {
    # Define the regular expression pattern for URL with proper escaping
    $urlRegex = '[^.]+((\.[^.]{0,3})+)'

    # Check if $url matches the regex pattern
    if ($url -match $urlRegex) {
        return $true  # Valid URL
    } else {
        return $false  # Not a valid URL
    }
}

If ($Args.count -eq 0) {
    # Get the content of the clipboard
    $clipboardContent = Get-Clipboard

    # Check if clipboard content is a valid URL
    if ($clipboardContent) {
        if (IsUrlValid $clipboardContent) {
            Write-Output "Clipboard content is a valid URL: $clipboardContent"

            $TempClipboardImageFolder = "$PSScriptRoot\Temp-Clipboard-Image-Folder"
            If(!(test-path -PathType container "$TempClipboardImageFolder")) {
                New-Item -ItemType Directory -Path "$TempClipboardImageFolder" -Force
            }

            $RandomName = -join ((48..57) + (97..122) | Get-Random -Count 5 | % {[char]$_})

            try {
                $response = Invoke-RestMethod -Uri $clipboardContent -Method Get -OutFile "$TempClipboardImageFolder\$RandomName.png"
                if (Test-Path -PathType Leaf "$TempClipboardImageFolder\$RandomName.png") {
                    $fileSize = (Get-Item "$TempClipboardImageFolder\$RandomName.png").Length
                    if ($fileSize -gt 0) {
                        $result = Check-FileSize -FilePath "$TempClipboardImageFolder\$RandomName.png"
                        if ($result -is [boolean]) {
                            if ($result) {
                                Write-Output "The file size exceeds the limit."
                                Add-Type -AssemblyName Microsoft.VisualBasic
                                $msgBoxInput = [Microsoft.VisualBasic.Interaction]::MsgBox("The file size exceeds the limit.","Information", "The file size exceeds the limit")
                                exit
                            } else {
                                Write-Output "The file size is within the limit."
                            }
                        } else {
                            Write-Output $result
                            Add-Type -AssemblyName Microsoft.VisualBasic
                            $msgBoxInput = [Microsoft.VisualBasic.Interaction]::MsgBox("$result","Information", "Error!")
                            exit
                        }
                        ImgurSingleUpload "$TempClipboardImageFolder\$RandomName.png"
                        exit
                    }
                }
            } catch {
                Write-Output "Error downloading file from URL: $_"
                Write-Output $_.Exception.Message
            }
        } else {
            Write-Output "Clipboard content is not a valid URL: $clipboardContent"
        }
    } else {
        Write-Output "Clipboard is empty or does not contain text."
    }
    $TempClipboardImageFolder = "$PSScriptRoot\Temp-Clipboard-Image-Folder"
    If(!(test-path -PathType container "$TempClipboardImageFolder")) {
        New-Item -ItemType Directory -Path "$TempClipboardImageFolder" -Force
    }

    $RandomName = -join ((48..57) + (97..122) | Get-Random -Count 5 | % {[char]$_})

    Save-ClipboardImage "$TempClipboardImageFolder\$RandomName.png"
    exit
} Else {
    if ((Get-Item "$args") -isnot [System.IO.DirectoryInfo]) {
        $result = Check-FileSize -FilePath "$args"
        if ($result -is [boolean]) {
            if ($result) {
                Write-Output "The file size exceeds the limit."
                Add-Type -AssemblyName Microsoft.VisualBasic
                $msgBoxInput = [Microsoft.VisualBasic.Interaction]::MsgBox("The file size exceeds the limit.","Information", "The file size exceeds the limit")
                exit
            } else {
                Write-Output "The file size is within the limit."
            }
        } else {
            Write-Output $result
            Add-Type -AssemblyName Microsoft.VisualBasic
            $msgBoxInput = [Microsoft.VisualBasic.Interaction]::MsgBox("$result","Information", "Error!")
            exit
        }
        ImgurSingleUpload "$args"
        exit
    }
    ImgurUploadAlbum "$args"
    exit
}

exit
