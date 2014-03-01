# Show which commands you use the most often
function freq_commands {
    history | awk '{$1 = ""; print}' | sort | uniq -c | sort -nr | less
}
