#!/usr/bin/env bash

### CONFIG ###

sudo yum install pandoc awscli -y

BUCKET_NAME="$1"
REPORT="network-report-$(date +%Y%m%d-%H%M%S).pdf"
TMP_REPORT="/tmp/network-report.txt"
NS_TEST="network-test-$(date +%s)"

if [[ -z "$BUCKET_NAME" ]]; then
  echo "Usage: $0 <s3-bucket-name>"
  exit 1
fi

echo "Running diagnostics... Please wait."
echo "Report will be saved to: $TMP_REPORT"

echo "===============================" > $TMP_REPORT
echo "   EKS NETWORK DIAGNOSTIC REPORT" >> $TMP_REPORT
echo "===============================" >> $TMP_REPORT
echo "Generated: $(date)" >> $TMP_REPORT
echo "" >> $TMP_REPORT

kubectl create ns $NS_TEST >/dev/null

kubectl run netshoot --image=nicolaka/netshoot -n $NS_TEST -- sleep 3600 >/dev/null
kubectl wait --for=condition=Ready pod/netshoot -n $NS_TEST --timeout=60s >/dev/null

TEST_POD=$(kubectl get pod -n $NS_TEST -o jsonpath='{.items[0].metadata.name}')

echo "=== POD-TO-POD PING RESULTS ===" >> $TMP_REPORT
POD_IPS=$(kubectl get pods -A -o jsonpath='{range .items[*]}{.status.podIP}{";"}{.metadata.name}{"\n"}{end}')
PING_COUNT=0

while IFS=";" read -r ip name; do
    [[ -z "$ip" || "$ip" == "None" ]] && continue
    echo -n "Ping $name ($ip): " >> $TMP_REPORT
    if kubectl exec -n $NS_TEST $TEST_POD -- ping -c1 -W1 $ip >/dev/null 2>&1; then
        echo "OK" >> $TMP_REPORT
    else
        echo "FAILED" >> $TMP_REPORT
    fi
    ((PING_COUNT++))
    [[ $PING_COUNT -ge 10 ]] && break
done <<< "$POD_IPS"

echo "" >> $TMP_REPORT

### DNS LATENCY TEST ###
echo "=== COREDNS LATENCY (dig tests) ===" >> $TMP_REPORT

for domain in kubernetes.default svc.cluster.local google.com amazon.com; do
    echo "Testing DNS latency for: $domain" >> $TMP_REPORT
    kubectl exec -n $NS_TEST $TEST_POD -- dig $domain +stats +tries=1 +timeout=1 2>/dev/null \
      | grep "Query time" >> $TMP_REPORT
    echo "" >> $TMP_REPORT
done

echo "" >> $TMP_REPORT

### CORE DNS LOG LATENCY ###
echo "=== COREDNS LOG LATENCY (kube-dns) ===" >> $TMP_REPORT

kubectl -n kube-system logs -l k8s-app=kube-dns --tail=50 \
  | grep -i "duration" \
  | tail -20 >> $TMP_REPORT

echo "" >> $TMP_REPORT

### NODE-LEVEL TEST ###
echo "=== NODE-TO-NODE LATENCY ===" >> $TMP_REPORT
NODE_IPS=$(kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}')
for nip in $NODE_IPS; do
    echo -n "Ping node $nip: " >> $TMP_REPORT
    kubectl exec -n $NS_TEST $TEST_POD -- ping -c1 -W1 $nip >/dev/null 2>&1 \
        && echo "OK" >> $TMP_REPORT || echo "FAILED" >> $TMP_REPORT
done

echo "" >> $TMP_REPORT

### DOWNSTREAM CONNECTIVITY ###
echo "=== DOWNSTREAM CONNECTIVITY RESULTS ===" >> $TMP_REPORT
for target in 8.8.8.8 1.1.1.1 google.com amazon.com; do
    for port in 80 443; do
        echo -n "$target:$port -> " >> $TMP_REPORT
        kubectl exec -n $NS_TEST $TEST_POD -- timeout 2 bash -c "cat < /dev/null > /dev/tcp/$target/$port" \
            >/dev/null 2>&1 && echo "OK" >> $TMP_REPORT || echo "FAILED" >> $TMP_REPORT
    done
done

echo "=== END OF REPORT ===" >> $TMP_REPORT

kubectl delete ns $NS_TEST >/dev/null

### GENERATE PDF ###
echo "Generating PDF report: $REPORT"
pandoc $TMP_REPORT -o $REPORT

### UPLOAD TO S3 ###
echo "Uploading to s3://$BUCKET_NAME/$REPORT"
aws s3 cp $REPORT s3://$BUCKET_NAME/$REPORT --acl private

echo ""
echo "===================================================="
echo " Report saved locally: $REPORT"
echo " Uploaded to S3 bucket: s3://$BUCKET_NAME/$REPORT"
echo "===================================================="
