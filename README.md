# DomainScoper
This is a simple script that will identify all domains that are within a provided scope.

## Arguments
![alt text](https://github.com/antroguy/DomainScoper/blob/main/images/Arguments.png)

This script accepts three arguments, all of which are required.
- ***domain_file*** - This should be a file that contains a list of all domains/subdomains. Each domain should be on its own line.
- ***scope_file***  - This should be a file that contains a list of all in scope IPs/Domains. Each IP Address/Domain should be on its own line. The file format allows single IPs, IP Subnets, Domains, and Root Domains. For Example:
  - 192.168.20.1
  - 192.168.20.0/24
  - Domain
  -  *.RootDomain
- ***output_file*** - Output file name will create an In Scope, Out of Scope and Unresolved Domains file with the filename appended to the end

**Example:**
```
./ScopeDomains.sh domains.txt Scope.txt results.txt

Results 
-----------------
OUTPUT HAS BEEN SAVED TO inscope_results.txt, out_of_scope_results.txt, and nonresolved_results.txt
```
