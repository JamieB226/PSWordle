#PSWordle - Wordle Clone in PowerShell
[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $WordFile="",
    [Parameter()]
    [int]
    $WordLength=5
)

$WordIndex=$WordLength-1

if($wordfile -eq "")
{
    $allwords=Invoke-webrequest -Uri "https://github.com/dwyl/english-words/blob/master/words.txt?raw=true"
    $expression="^[a-zA-Z]{$($WordLength)}$"
    $wordlewords=$allwords.content -split "`n" | where-object {($_ -match $expression) -eq $true}
}
else
{
    if(Test-Path -Path $WordFile)
    {
        $wordlewords=get-content $WordFile | where-object {($_ -match $expression) -eq $true}
    }
    else
    {
        Write-Output "Word File not found"    
        $end=$true
    }
}

function ScoreWord
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $word,
        [Parameter(Mandatory=$true)]
        [string]
        $guess,
        [Parameter()]
        [switch]
        $scoreOutput
    )

    if($guess -eq $word)
    {
        if(!$scoreOutput)
        {
            Write-Host -BackgroundColor "Green" -ForegroundColor "Black" -Object $guess
            $true
        }
        else
        {
            0..$WordIndex | foreach-object {
                $bgcolor="black"
                $fgcolor="white"
                if($guess[$_] -in $word.ToCharArray())
                {
                    $bgcolor="yellow"
                    $fgcolor="black"
                }
                if($guess[$_] -eq $word[$_])
                {
                    $bgcolor="green"
                    $fgcolor="black"
                }    
                if($_ -lt $WordIndex)
                {
                    Write-Host -BackgroundColor $bgcolor -ForegroundColor "black" -Object "_" -NoNewline
                    Write-Host -BackgroundColor "black" -ForegroundColor "black" -Object "_" -NoNewline
                }
                else
                {
                    Write-Host -BackgroundColor $bgcolor -ForegroundColor "black" -Object "_"
                }
            }
        }
    }
    else
    {
        0..$WordIndex | foreach-object {
            $bgcolor="black"
            $fgcolor="white"
            if($guess[$_] -in $word.ToCharArray())
            {
                $bgcolor="yellow"
                $fgcolor="black"
            }
            if($guess[$_] -eq $word[$_])
            {
                $bgcolor="green"
                $fgcolor="black"
            }
            if(!$scoreOutput)
            {
                if($_ -lt $WordIndex)
                {
                    Write-Host -BackgroundColor $bgcolor -ForegroundColor $fgcolor -Object $guess[$_] -NoNewline
                }
                else
                {
                    Write-Host -BackgroundColor $bgcolor -ForegroundColor $fgcolor -Object $guess[$_]
                }
            }
            else 
            {
                if($_ -lt $WordIndex)
                {
                    Write-Host -BackgroundColor $bgcolor -ForegroundColor "black" -Object "_" -NoNewline
                    Write-Host -BackgroundColor "black" -ForegroundColor "black" -Object "_" -NoNewline
                }
                else
                {
                    Write-Host -BackgroundColor $bgcolor -ForegroundColor "black" -Object "_"
                }
            }
        }
        $false
    }
}

while ($end -ne $true)
{
    $word=$wordlewords | get-random
    $guesscount=0
    $guesses=@()
    $result=$false

    do
    {
        Clear-Host
        #Write-Output $word
        Write-Host "Enter your guesses one per line.  Guesses will be scored when you press Enter."
        $guesses | foreach-object{$result=ScoreWord -Word $word -guess $_}
        if(($guesscount -lt 6) -and ($result -ne $true))
        {
            $guess=(Read-host).tolower()
            if($guess -match $expression)
            {
                $guesses+=$guess
                $guesscount++
            }
        }
        else
        {
            $guesscount++    
        }
    } while (($guesscount -le 6) -and ($result -ne $true))

    if($result -ne $true)
    {
        Write-Host "Word was $word."
    }
    else
    {
        Write-Host "`nPSWordle $guesscount/6`n"
        $guesses | foreach-object{$result=ScoreWord -Word $word -guess $_ -ScoreOutput}
    }

    if((Read-Host -Prompt "`nEnter 'Y' to quit") -eq "Y")
    {
        $end=$true
    }
}
