#!/bin/bash

# check if the number of arguments is correct
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 domains_file scope_file output_file"
    echo    "           domains_file    -   File that contains a list of Domains"
    echo    "           scope_file      -   File that contains a list of In Scope IPs/Domains. The file format allows single IPs, IP Subnets, Domains, and Root Domains. For Example:
                                                192.168.20.1
                                                192.168.20.0/24
                                                Domain
                                                *.RootDomain"
    echo    "           output_file_name     -   Output file name will create an In Scope, Out of Scope and Unresolved Domains file with the filename appended to the end"
    exit 1
fi

# check if ipcalc is installed
if ! [ -x "$(command -v grepcidr)" ]; then
    echo "ipcalc not found, installing..."
    sudo apt-get install -y grepcidr
fi

# assign input file names to variables
domains_file=$1
ips_file=$2
output=$3

inscope_output=inscope_$3
nonresolved_output=unresolved_$3
out_of_scope_output=out_of_scope_$3

rm -f $inscope_output
rm -f $nonresolved_output
rm -f $out_of_scope_output

touch $inscope_output
touch $nonresolved_output
touch $out_of_scope_output


# Create an empty array for domains that are in scope
in_scope_domains=()
# Create an empty array for domains that are not in scope
out_of_scope_domains=()
#Create an empty array of unresolved IP Addresses
non_resolved_domains=()

# iterate through each domain
while read -r domain; do
    in_scope=false
    resolved=false
    ip_output=""
    # Define a list of DNS resolvers
    resolvers=("8.8.8.8" "8.8.4.4" "208.67.222.222" "208.67.220.220")
    # resolvers=("8.8.8.8")
    for resolver in "${resolvers[@]}"; do
        ip_output=$(nslookup ${domain} ${resolver} | awk '/^Address: / { print $2 }')
        #Validate ip_output returned a valid response
        if [ -n "$ip_output" ]; then
            resolved=true
            break;
        fi
    done

    if [[ $resolved == true ]]; then
        if ! [[ $ip_output =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
            echo -e "\033[31mError: ${domain} did not produce a valid IPv4 address\033[0m"
            non_resolved_domains+=($domain)
            continue
        fi
    else
        echo -e "\033[31mError: Failed to resolve IP for domain ${domain}\033[0m"
        non_resolved_domains+=($domain)
        continue
    fi

    # check if domain is within scope list
    while read -r ip_subnet; do
        if [ ! -z $(grep -x ${domain} ${ips_file}) ]; then
            in_scope=true
            break
        fi
        # check if the IP is a single IP, a subnet or a root domain
        if echo $ip_subnet | grep -q '/'; then
            # IP is a subnet
            grepcidr_output=$( grepcidr ${ip_subnet} <(echo ${ip_output}))
            if [[ -n $grepcidr_output ]]; then
                in_scope=true
                break
            fi

        elif [[ ${ip_subnet} == "*"* ]]; then
            ip_subnet_root="${ip_subnet#*.}"
            if [[ $domain == *$ip_subnet_root ]] || [[ $domain == $ip_subnet_root ]]; then
                # IP is a root domain
                in_scope=true
                break
            fi
        else
            # IP is a single IP
            if [[ $ip_output == $ip_subnet ]]; then
                in_scope=true
                break
            fi

        fi
    done < $ips_file

    #Check if domain was in scope
    if [ $in_scope = true ]; then
        echo -e "\033[32mIn Scope: ${domain} - ${ip_output}\033[0m"
        in_scope_domains+=($domain)
        #echo $domain >> $output
    else
        echo -e "\033[31mOut of Scope: ${domain} - ${ip_output}\033[0m"
        out_of_scope_domains+=($domain)
    fi

done < $domains_file

#format files
echo "Non Resolved Domains:" >> $nonresolved_output
echo "-------------------------------------" >> $nonresolved_output
echo "Out of Scope Domains:" >> $out_of_scope_output
echo "-------------------------------------" >> $out_of_scope_output
echo "In Scope Domains:" >> $inscope_output
echo "-------------------------------------" >> $inscope_output


echo ""
echo "***********RESULTS***********"
echo -e "\033[31m"
echo "Non Resolved Domains:"
echo "-------------------------------------"
for domain in "${non_resolved_domains[@]}"; do
    echo $domain
    echo $domain >> $nonresolved_output
done
echo ""
echo "Out of Scope Domains:"
echo "-------------------------------------"
for domain in "${out_of_scope_domains[@]}"; do
    echo $domain
    echo $domain >> $out_of_scope_output
done
echo -e "\033[32m"
echo "In Scope Domains:"
echo "-------------------------------------"
for domain in "${in_scope_domains[@]}"; do
    echo $domain
    echo $domain >> $inscope_output
done
echo "-------------------------------------"

echo "OUTPUT HAS BEEN SAVED TO ${inscope_output}, ${out_of_scope_output}, and ${nonresolved_output}"
