
if test (uname) != Darwin
  exit
end

# Homebrew paths (Apple Silicon + Intel)
if test -d /opt/homebrew/bin
  fish_add_path /opt/homebrew/bin /opt/homebrew/sbin
end
if test -d /usr/local/bin
  fish_add_path /usr/local/bin /usr/local/sbin
end

# macOS niceties
alias flushdns "sudo dscacheutil -flushcache; and sudo killall -HUP mDNSResponder"

# if you use gnu tools, you can add:
# fish_add_path /opt/homebrew/opt/coreutils/libexec/gnubin
