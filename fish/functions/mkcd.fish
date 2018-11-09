function mkcd
    command mkdir $argv
    if test $status = 0
        cd $argv[(count $argv)]
        return
    end
end
