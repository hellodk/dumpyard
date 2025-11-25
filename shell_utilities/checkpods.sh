#!/bin/bash

echo -e "POD\tNODE\tNAMESERVER(S)"

# Loop through all pods across all namespaces
kubectl get pods -A -o wide --no-headers | while read ns pod ready status rest; do
    # Extract node name from wide output (column 7)
    node=$(echo $rest | awk '{print $5}')

    # Exec into pod and read nameserver lines from /etc/resolv.conf
    nameservers=$(kubectl exec -n "$ns" "$pod" -- sh -c "grep '^nameserver' /etc/resolv.conf 2>/dev/null | awk '{print \$2}'" | tr '\n' ',')

    # Remove trailing comma
    nameservers=${nameservers%,}

    echo -e "${ns}/${pod}\t${node}\t${nameservers}"
done
