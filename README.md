# DomainScoper
This is a simple script that will identify all domains that are within a provided scope.

## Arguments
![alt text](https://github.com/antroguy/DomainScoper/blob/main/images/Arguments.png)

This script accepts three arguments, all of which are required.
- ***domain_file*** - This should be a file that contains a list of all domains/subdomains
- ***scope_file***  - This should be a file that contains a list of all in scope IPs/Domains. The file format allows single IPs, IP Subnets, Domains, and Root Domains. For Example:
                                                192.168.20.1
                                                192.168.20.0/24
                                                Domain
                                                *.RootDomain
- ***output_file*** - The name of the file where  in scope domains will be saved.

**Example:**
```
./ScopeDomains.sh domains.txt Scope.txt results.txt
```
