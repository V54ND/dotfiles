# Detect Windows-ish environments in Fish
set os (uname)
if not string match -qr 'MINGW|MSYS|CYGWIN|NT' -- $os
  exit
end

# Common Windows PATH additions (подстрой под себя)
# Пример: если есть user bin
if test -d $HOME/bin
  fish_add_path $HOME/bin
end

# Handy aliases
alias open "explorer.exe"
alias clip "clip.exe"

# If you're using Git for Windows and want its ssh etc:
# fish_add_path /c/Program\ Files/Git/usr/bin

