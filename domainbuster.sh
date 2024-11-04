#!/bin/bash
green="\e[0;32m\033[1m"
end="\033[0m\e[0m"
red="\e[0;31m\033[1m"
blue="\e[0;34m\033[1m"
yellow="\e[0;33m\033[1m"
purple="\e[0;35m\033[1m"
gray="\e[0;37m\033[1m"

delay=1500ms
threads=10
wordlist="/usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt"
output_dir="./gobuster_output"
mkdir -p "$output_dir"

usage() {
    echo -e "Usage: $0 -d <domain> -s <speed> -t <threads>"
    echo -e " ${purple} -d ${end}  Domain to start subdomain enumeration."
    echo -e " ${purple} -s  ${end} Speed level (1: fast, 2: moderate, 3: slow)."
    echo -e " ${purple} -t  ${end} Threads (10, 100, or 200)."
    exit 1
}

while getopts ":d:s:t:" opt; do
  case $opt in
    d) domain="$OPTARG" ;;
    s) speed="$OPTARG" ;;
    t) threads="$OPTARG" ;;
    *) usage ;;
  esac
done

if [[ -z "$domain" ]]; then
    usage
fi

case $speed in
  1) delay=500ms ;;
  2) delay=1500ms ;;  # Default speed
  3) delay=3000ms ;;
  "") ;;  
  *) echo -e "${red}Invalid speed level. Use 1 (fast), 2 (moderate), or 3 (slow). ${end}" >&2; exit 1 ;;
esac

threads=${threads:-10}  

recursive_gobuster() {
    local domain="$1"
    local round=1
    local input_file="$output_dir/${domain}_round_${round}.txt"

    echo -e "Starting recursive gobuster search on domain: ${purple} $domain ${end} with delay: ${purple} $delay ${end}, threads: ${purple} $threads ${end}"

    gobuster fuzz --url "https://FUZZ.$domain" --delay "$delay" -w "$wordlist" -t "$threads" --no-error > "$input_file"

    while :; do
        echo "Processing round $round for domain: $domain"

        new_subdomains=$(awk '{print $5}' "$input_file" | sed 's|https://||' | sort -u)

        if [[ -z "$new_subdomains" ]]; then
            echo "${red}No new subdomains found in round ${end} ${purple} $round ${end} ${red} Ending recursion.${end}"

            break
        fi

        round=$((round + 1))
        input_file="$output_dir/${domain}_round_${round}.txt"

        echo "$new_subdomains" | xargs -I {} bash -c \
            "gobuster fuzz --url 'https://FUZZ.{}' --delay '$delay' -w '$wordlist' -t '$threads' --no-error >> '$input_file'"

        if [[ ! -s "$input_file" ]]; then
          echo "${red}No new subdomains discovered in round ${end} ${purple} $round ${end} ${red} Stopping further processing. ${end}"
            break
        fi

        sort -u -o "$input_file" "$input_file"
    done

    echo "Recursive gobuster search completed. Results saved in $output_dir"
}

recursive_gobuster "$domain"