function logpipe
    argparse n/numbers p/prefix= t/tee h/help -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: command | logpipe [-n] [-p prefix] [-t]"
        return 0
    end

    set counter 1
    while read -l line
        set line (string trim -- $line)
        if test -n "$line"
            if set -q _flag_numbers
                echo "$counter. $_flag_prefix$line"
                set counter (math $counter + 1)
            else
                echo "- $_flag_prefix$line"
            end
        end
    end
end

