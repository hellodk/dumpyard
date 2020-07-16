from scapy import srp,Ether,ARP,conf

conf.verb=0
ans,unans=srp(Ether(dst="ff:ff:ff:ff:ff:ff")/ARP(pdst="10.0.1.1"),
timeout=2)

for snd, rcv in ans:
    print rcv.sprintf(r"%Ether.src% %ARP.psrc%")