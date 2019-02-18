## Analýzátor paketov

#### MENO

isashark

#### POPIS

Isashark je offline konzolová aplikácia na analýzu, agregovanie a radenie záznamov
sieťovej prevázky obsahujúci vybrané protokoly z rodiny TCP/IP.

#### POUŽITIE

`isashark [-h] [-a aggr-key] [-s sort-key] [-l limit] [-f filter-expression] file`

- `-h` Vypísanie nápovedy a ukončenie programu.
- `-a aggr-key` Agregovanie záznamov paketov podľa agregačného kľúča. Agregčný kľúč môže byť:
    - *srcmac* - zdrojová MAC adresa
    - *dstmac* - cieľová MAC adresa
    - *srcip* - zdrojová IP adresa
    - *dstip* - cieľová IP adresa
    - *srcport* - číslo zdrojového transportného portu
    - *dstport* - číslo cieľového transportného portu
- `-s sort-key` Radenie záznamov paketov podľa kľúča:
    - *packets* - počet paketov (efekt iba pri agregovanom výpise)
    - *bytes* - počet bajtov
- `-l limit` Nezáporné celé číslo určujúce limit počtu vypísaných záznamov.
- `-f filter-expression` Program spracuje iba pakety, ktoré vyhovujú danému filter-expression.
- `file` Cesta k súboru alebo viac súborom vo formáte pcap.
 
#### PRÍKLADY

Zoradenie paketov podľa počtu bajtov a vypísanie s limitom 4

`isashark -s bytes -l 4 mix.pcap`
```
8: 1507025990199610 111 | Ethernet: 01:23:45:67:89:ad 01:23:45:67:89:ae | IPv6: 2001:db8::1 2001:db8::2 64 | UDP: 54321 666
10: 1507025992127657 104 | Ethernet: 01:23:45:67:89:ad 01:23:45:67:89:ae | IPv6: 2001:db8::1 2001:db8::2 64 | UDP: 54321 666
6: 1507025968692963 100 | Ethernet: 01:23:45:67:89:ad 01:23:45:67:89:ae | IPv6: 2001:db8::1 2001:db8::2 64 | UDP: 54321 666
5: 1507025952857185 94 | Ethernet: 01:23:45:67:89:ab 01:23:45:67:89:ac | IPv4: 192.168.1.1 192.168.1.2 64 | TCP: 54321 666 0 0 ......S.
```

Agregovanie paketov a zoradenie podľa počtu paketov v zázname

`isashark -s packets -a srcip mix.pcap`
```
192.168.1.1: 3 269
2001:db8::1: 3 315
192.168.1.2: 2 161
2001:db8::2: 2 143
```

#### AUTOR

Patrik Michalak (xmicha65)
