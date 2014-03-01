function myip {
    printf '%s\n' $(curl -s http://canihazip.com/s/)
}
