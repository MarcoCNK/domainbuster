# godomainbuster
This tool use gobuster one-liners to scan subdomain recursivelly, And it will be creating files relative to this folder for each round

### Start a subdomains enumeration
I want to enumerate subdomains from example.com
```sh
sudo ~/recon/recursive_gobuster/domainbuster.sh -d example.com -w /usr/share/seclists/Discovery/DNS/bug-bounty-program-subdomains-trickest-inventory.txt
```
by default is using 10 threads and 1500ms of delay, that could be adjusted with `-t` and `-d` respectively. 

### Retaking a subdomains enumeration
The process of enumeration could be time consuming, and to retake the process use the -r flag with the interrumpted file as an argunment, the script is expecting to be like that `*.net_round_[0-9].txt`, the file must content the output from the gobuster not to completed, and the wordlist should be the same that the used during that interrumpted process, an example usage:

```sh
sudo ~/recon/recursive_gobuster/domainbuster.sh -d example.com -w /usr/share/seclists/Discovery/DNS/bug-bounty-program-subdomains-trickest-inventory.txt -r $(pwd)/example.com_round_1.txt
```


