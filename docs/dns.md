Domain name: gkiladze.space
Azure DNS zone name: gkiladze.space



Registrar NS updated to Azure DNS nameservers (11.01.2026):
"ns1-08.azure-dns.com.",
"ns2-08.azure-dns.net.",
"ns3-08.azure-dns.org.",
"ns4-08.azure-dns.info."



Verification: nslookup test.gkiladze.space → 1.2.3.4 (public resolution OK)



test record:
test
A
3600
1.2.3.4



nslookup test.gkiladze.space
A records
IPv4 address	Revalidate in
1.2.3.4	1h
AAAA records
No AAAA records found.
CNAME record
No CNAME record found.

TXT records
No TXT records found.



Why it matters: This enables cert-manager DNS-01 challenges using Azure DNS for automated TLS issuance/renewal.



Next: Terraform will manage the DNS zone/records; cert-manager will create temporary \_acme-challenge TXT records during issuance.

