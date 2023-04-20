#!/bin/bash

# Input files
domain_file="$1"
scope_file="$2"
output_dir="$3"

# Output file names
in_scope_file="in_scope.txt"
out_of_scope_file="out_of_scope.txt"
unresolved_file="unresolved.txt"
multi_array_file="multi_array.txt"

rm -f "$output_dir/$in_scope_file"
rm -f "$output_dir/$unresolved_file"
rm -f "$output_dir/$out_of_scope_file"
rm -f "$output_dir/$multi_array_file"

touch "$output_dir/$in_scope_file"
touch "$output_dir/$unresolved_file"
touch "$output_dir/$out_of_scope_file"
touch "$output_dir/$multi_array_file"

# DNS resolvers
dns_resolvers=("8.8.8.8" "8.8.4.4" "208.67.222.222" "208.67.220.220")

# Arrays to store results
in_scope=()
out_of_scope=()
unresolved=()
multi_array=()

# Loop through each domain in the domain file
while read -r domain || [[ -n "$domain" ]]; do
  # Perform nslookup only if domain has not been resolved already
  if ! grep -q "^$domain" "${output_dir}/${in_scope_file}" "${output_dir}/${out_of_scope_file}" "${output_dir}/${unresolved_file}"; then
    resolved=0  # Flag to track if domain has been resolved
    # Perform nslookup for each DNS resolver
    for resolver in "${dns_resolvers[@]}"; do
      nslookup_output=$(nslookup "$domain" "$resolver" | awk '/^Address: / { print $2 }' )
      ipv4_addresses=$(echo "$nslookup_output" | grep -E -o '([0-9]{1,3}\.){3}[0-9]{1,3}')

      # Check if any IPv4 addresses were resolved
      if [ -n "$ipv4_addresses" ]; then
        resolved=1  # Set resolved flag to true
        # Loop through each resolved IPv4 address
        while read -r ipv4_address || [[ -n "$ipv4_address" ]]; do
          # Check if the resolved IPv4 address falls within the scope
          grep_result=$(grep -w "$ipv4_address" "$scope_file")
          if [ -n "$grep_result" ]; then
            # Add to in_scope array
            in_scope+=("$domain - $ipv4_address")
          else
            # Add to out_of_scope array
            out_of_scope+=("$domain - $ipv4_address")
          fi
        done <<< "$ipv4_addresses"
      else
        # Add to unresolved array
        unresolved+=("$domain")
      fi
    done

    # Print status update when domain is finished being tested
    if [ "$resolved" -eq 1 ]; then
      if [ "${#in_scope[@]}" -gt 0 ]; then
        echo -e "\033[32mDomain: $domain, Status: Resolved (In Scope)"
      else
        echo -e "\033[31mDomain: $domain, Status: Resolved (Out of Scope)"
      fi
    else
      echo -e "\033[31mDomain: $domain, Status: Unresolved"
    fi
  fi
done < "$domain_file"

# Check for multi_array
for domain_in_scope in "${in_scope[@]}"; do
  for domain_out_of_scope in "${out_of_scope[@]}"; do
    if [[ "$domain_in_scope" == *"${domain_out_of_scope%% -*}"* ]]; then
      multi_array+=("${domain_out_of_scope%% -*}")
    fi
  done
done

# Create output directory if it doesn't exist
mkdir -p "$output_dir"

# sort unique each array
sorted_unresolved=()
for entry in "${unresolved[@]}"; do
  # Check if the entry is not already in the unique_entries array
  if [[ ! " ${sorted_unresolved[@]} " =~ " ${entry} " ]]; then
    sorted_unresolved+=("$entry") # Add the entry to the unique_entries array
  fi
done
sorted_out_of_scope=()
for entry in "${out_of_scope[@]}"; do
  # Check if the entry is not already in the unique_entries array
  if [[ ! " ${sorted_out_of_scope[@]} " =~ " ${entry} " ]]; then
    sorted_out_of_scope+=("$entry") # Add the entry to the unique_entries array
  fi
done
sorted_in_scope=()
for entry in "${in_scope[@]}"; do
  # Check if the entry is not already in the unique_entries array
  if [[ ! " ${sorted_in_scope[@]} " =~ " ${entry} " ]]; then
    sorted_in_scope+=("$entry") # Add the entry to the unique_entries array
  fi
done
sorted_multi_array=()
for entry in "${multi_array[@]}"; do
  # Check if the entry is not already in the unique_entries array
  if [[ ! " ${sorted_multi_array[@]} " =~ " ${entry} " ]]; then
    sorted_multi_array+=("$entry") # Add the entry to the unique_entries array
  fi
done


# Print and write to files
echo ""
echo "***********RESULTS***********"
echo -e "\033[31m"
echo "Non Resolved Domains:"
echo "-------------------------------------"
for domain in "${sorted_unresolved[@]}"; do
    echo $domain
    echo $domain >> "$output_dir/$unresolved_file"
done
echo ""
echo "Out of Scope Domains:"
echo "-------------------------------------"
for domain in "${sorted_out_of_scope[@]}"; do
    echo $domain
    echo $domain >> "$output_dir/$out_of_scope_file"
done
echo -e "\033[32m"
echo "In Scope Domains:"
echo "-------------------------------------"
for domain in "${sorted_in_scope[@]}"; do
    echo $domain
    echo $domain >> "$output_dir/$in_scope_file"
done
echo "-------------------------------------"
echo -e "\033[32m"
echo "Domains with both In Scope and Out of Scope IPs:"
echo "-------------------------------------"
for domain in "${sorted_multi_array[@]}"; do
    echo $domain
    echo $domain >> "$output_dir/$multi_array_file"
done
echo "-------------------------------------"
