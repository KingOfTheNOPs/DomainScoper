# DomainScoper
This is a simple script that will identify all domains that are within a provided scope.

## Arguments
![alt text](https://github.com/andrew-gomez/DomainScoper/blob/main/Argument.png)

This script accepts three arguments, all of which are required.
- ***domain_file*** - This should be a file that contains a list of all domains/subdomains. Each domain should be on its own line.
- ***scope_file***  - This should be a file that contains a list of all in scope IPs/Domains. Each IP Address/Domain should be on its own line. The file format allows single IPs, IP Subnets, Domains, and Root Domains. For Example:
  - 192.168.20.1
  - 192.168.20.0/24

- ***output_directory*** - Output file name will create an In Scope, Out of Scope and Unresolved Domains file with the filename appended to the end

**Example:**
```
./ScopeDomains.sh domains.txt Scope.txt results

***********RESULTS***********
Non Resolved Domains:
-------------------------------------   
test.domain.local

Out of Scope Domains:
-------------------------------------
notinscope.domain.local

In Scope Domains:
-------------------------------------
inscope.domain.local

```
