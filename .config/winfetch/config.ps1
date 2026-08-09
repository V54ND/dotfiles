# Compact Kanagawa-themed Winfetch configuration.

$imgwidth = 22
$cpustyle = "bartext"
$memorystyle = "bartext"
$diskstyle = "bartext"
$batterystyle = "bartext"

$ShowDisks = @($env:SystemDrive)
$ShowPkgs = @("scoop")

$esc = [char]0x1B
$reset = "$esc[0m"
$blue = "$esc[38;2;126;156;216m"
$violet = "$esc[38;2;149;127;184m"
$aqua = "$esc[38;2;106;149;137m"
$pink = "$esc[38;2;210;126;153m"
$white = "$esc[38;2;220;215;186m"

$CustomAscii = @(
    "                      "
    "   ${blue}#######${reset} ${violet}#######${reset}    "
    "   ${blue}#######${reset} ${violet}#######${reset}    "
    "   ${blue}#######${reset} ${violet}#######${reset}    "
    "                      "
    "   ${aqua}#######${reset} ${pink}#######${reset}    "
    "   ${aqua}#######${reset} ${pink}#######${reset}    "
    "   ${aqua}#######${reset} ${pink}#######${reset}    "
    "                      "
    "        ${white}WINDOWS${reset}       "
    "                      "
)

function info_clock {
    return @{
        title = "Local Time"
        content = (Get-Date -Format "ddd, dd MMM yyyy  HH:mm")
    }
}

@(
    "title"
    "dashes"
    "os"
    "computer"
    "kernel"
    "uptime"
    "clock"
    "pkgs"
    "pwsh"
    "terminal"
    "resolution"
    "cpu"
    "cpu_usage"
    "gpu"
    "memory"
    "disk"
    "blank"
    "colorbar"
)
