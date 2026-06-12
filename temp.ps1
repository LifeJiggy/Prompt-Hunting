# Function to write file in parts
function Write-ExpandedFile {
    param([string]$FilePath, [string]$Content)
    $Content | Out-File -FilePath $FilePath -Encoding UTF8
}

# FILE 18: PHP Unserialize
$file18Content = Get-Content "C:\Users\ADMIN\Python_Project\Prompt_AI-Support\Prompt-Hunting\Real-World-Case-Studies\18-Deserialization-PHP-Unserialize.md" -Raw
Write-ExpandedFile -FilePath "C:\Users\ADMIN\Python_Project\Prompt_AI-Support\Prompt-Hunting\Real-World-Case-Studies\18-Deserialization-PHP-Unserialize.md" -Content $file18Content
