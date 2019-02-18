#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <iostream>
#include <vector>
#include <sys/socket.h>
#include <pcap.h>
#include <netinet/in.h>
#include <netinet/ip.h>
#include <netinet/ip6.h>
#include <netinet/tcp.h>
#include <netinet/udp.h>
#include <netinet/ip_icmp.h>
#include <netinet/if_ether.h>
#include <arpa/inet.h>
#include <errno.h>
#include <err.h>

#ifdef __linux__
#include <netinet/ether.h>
#include <time.h>
#include <pcap/pcap.h>
#endif

#ifndef PCAP_ERRBUF_SIZE
#define PCAP_ERRBUF_SIZE (256)
#endif
#define SIZE_ETHERNET (14)
#define IPV6_BUFFER_SIZE (128)
#define PACKET_MAX_SIZE (65535)

using namespace std;

/* PACKET STRUCT */
struct packetTemplate
{
    int number;
    string timeStamp; // ok
    int length;       // ok

    string srcMac;     // ok
    string dstMac;     // ok
    string ethType[2]; // ok

    int protocol3; // ok 4/6
    string srcIp;  // ok ipv4/6
    string dstIp;  // ok ipv4/6
    string ttl;    // ok ipv4
    string maxHop; // ok ipv6

    string protocol4; // ok TCP/UDP/ICMPv4/6
    // TCP/UDP
    string srcPort;  // ok
    string dstPort;  // ok
    string seqNum;   // ok
    string ackNum;   // ok
    string flags[8]; // ok
    // ICMPv4/6
    int icmpType; // ok
    int icmpCode; // ok

    int idFrag;                     // fragment id
    bool moreFrag;                  // more fragments flag
    int offsetFrag = 0;             // fragment offset flag
    bool usedFrag;                  // fragment is used flag
    vector<unsigned char> dataFrag; // fragment data
    int dataLen;                    // length of frag data
};

/* AGGREGATED STRUCT */
struct aggrTemplate
{
    string keyValue;
    int packetNum;
    int lengthNum;
};

/* GLOBAL VARIABLES */
const u_char *packet;                    // full packet
struct ip *ipv4struct;                   // ipv4 packet struct
struct ip6_hdr *ipv6struct;              // ipv6 packet struct
u_int ethSize;                           // Ethernet size
u_int ipHeaderSize;                      // length of IP header
u_int nextHeader;                        // IPv6 next header
struct packetTemplate packetStruct;      // structure for packet
struct packetTemplate emptyPacketStruct; // empty structure
struct aggrTemplate aggrStruct;          // structure for aggragation array
vector<packetTemplate> packetArray;      // array of packets
vector<aggrTemplate> aggrArray;          // aggregated format of struct

// arguments
vector<string> fileNames;
string aggrKey;
string sortKey;
int limit;
string filterExp;

/* print error and exit */
void printErr(const char *msg)
{
    fprintf(stderr, "%s\n", msg);
    exit(1);
}

/* print help */
void printHelp()
{
    printf("isashark [-h] [-a aggr-key] [-s sort-key] [-l limit] [-f filter-expression] file ...\n");
    exit(0);
}

/* print icmp message */
void printIcmp(string version, int type, int code)
{
    if (version.compare("ICMPv4") == 0)
    {
        if (type == 3)
        {
            printf(" destination unreachable");
            if (code == 0)
                printf(" net unreachable");
            else if (code == 1)
                printf(" host unreachable");
            else if (code == 2)
                printf(" protocol unreachable");
            else if (code == 3)
                printf(" port unreachable");
            else if (code == 4)
                printf(" fragmentation needed and DF set");
            else if (code == 5)
                printf(" source route failed");
        }
        else if (type == 11)
        {
            printf(" time exceeded");
            if (code == 0)
                printf(" time to live exceeded in transit");
            else if (code == 1)
                printf(" fragment reassembly time exceeded");
        }
        else if (type == 12)
        {
            printf(" parameter problem");
            if (code == 0)
                printf(" pointer indicates the error");
        }
        else if (type == 4)
            printf(" source quench");
        else if (type == 5)
        {
            printf(" redirect");
            if (code == 0)
                printf(" redirect datagrams for the network");
            else if (code == 1)
                printf(" redirect datagrams for the host");
            else if (code == 2)
                printf(" redirect datagrams for the type of service and network");
            else if (code == 3)
                printf(" redirect datagrams for the type of service and host");
        }
        else if (type == 8)
            printf(" echo");
        else if (type == 0)
            printf(" echo reply");
        else if (type == 13)
            printf(" timestamp");
        else if (type == 14)
            printf(" timestamp reply");
        else if (type == 15)
            printf(" information request");
        else if (type == 16)
            printf(" information reply");
    }
    else if (version.compare("ICMPv6") == 0)
    {
        if (type == 1)
        {
            printf(" destination unreachable");
            if (code == 0)
                printf(" no route to destination");
            else if (code == 1)
                printf(" communication with destination administratively prohibited");
            else if (code == 2)
                printf(" beyond scope of source address");
            else if (code == 3)
                printf(" address unreachable");
            else if (code == 4)
                printf(" port unreachable");
            else if (code == 5)
                printf(" source address failed ingress/egress policy");
            else if (code == 6)
                printf(" reject route to destination");
        }
        else if (type == 2)
            printf(" packet too big");
        else if (type == 3)
        {
            printf(" time exceeded");
            if (code == 0)
                printf(" hop limit exceeded in transit");
            else if (code == 1)
                printf(" fragment reassembly time exceeded");
        }
        else if (type == 4)
        {
            printf(" parameter problem");
            if (code == 0)
                printf(" erroneous header field encountered");
            else if (code == 1)
                printf(" unrecognized next header type encountered");
            else if (code == 2)
                printf(" unrecognized IPv6 option encountered");
        }
        else if (type == 128)
            printf(" echo request");
        else if (type == 129)
            printf(" echo reply");
    }
}

/* hex to string converter */
string hexToString(int part1, int part2)
{
    unsigned pow = 10;
    while (part2 >= pow)
        pow *= 10;
    return to_string(part1 * pow + part2);
}

/* empty values in packetStruct */
void clearPacketStruct()
{
    packetStruct = emptyPacketStruct;
}

/* format mac add */
string formatMac(char *mac)
{
    char buffer[19];
    int a, b, c, d, e, f;
    if (sscanf(mac, "%x:%x:%x:%x:%x:%x", &a, &b, &c, &d, &e, &f) == 6)
        sprintf(buffer, "%02x:%02x:%02x:%02x:%02x:%02x", a, b, c, d, e, f);

    return buffer;
}

/* print aggregated array of packets with or without limit */
void printAggrArray()
{
    int records = limit && limit < aggrArray.size() ? limit : aggrArray.size();

    for (int i = 0; i < records; i++)
    {
        printf("%s: ", aggrArray[i].keyValue.c_str());
        printf("%d ", aggrArray[i].packetNum);
        printf("%d\n", aggrArray[i].lengthNum);
    }
}

/* print standard packet array with or without limit */
void printPacketArray()
{
    int records = limit && limit < packetArray.size() ? limit : packetArray.size();

    for (int i = 0; i < records; i++)
    {
        if (!sortKey.empty())
            printf("%d:", packetArray[i].number);
        else
            printf("%d:", i + 1);
        printf(" %s", packetArray[i].timeStamp.c_str());
        printf(" %d", packetArray[i].length);

        printf(" | Ethernet:");
        printf(" %s", packetArray[i].srcMac.c_str());
        printf(" %s", packetArray[i].dstMac.c_str());
        if (packetArray[i].ethType[0].length())
            printf(" %s", packetArray[i].ethType[0].c_str());
        if (packetArray[i].ethType[1].length())
            printf(" %s", packetArray[i].ethType[1].c_str());

        printf(" |");
        printf(" IPv%d:", packetArray[i].protocol3);
        printf(" %s", packetArray[i].srcIp.c_str());
        printf(" %s", packetArray[i].dstIp.c_str());
        if (packetArray[i].ttl.length())
            printf(" %s", packetArray[i].ttl.c_str());
        if (packetArray[i].maxHop.length())
            printf(" %s", packetArray[i].maxHop.c_str());

        printf(" |");
        printf(" %s:", packetArray[i].protocol4.c_str());
        if (packetArray[i].protocol4.compare("TCP") == 0 || packetArray[i].protocol4.compare("UDP") == 0)
        {
            printf(" %s", packetArray[i].srcPort.c_str());
            printf(" %s", packetArray[i].dstPort.c_str());

            if (packetArray[i].protocol4.compare("TCP") == 0)
            {
                printf(" %s", packetArray[i].seqNum.c_str());
                printf(" %s", packetArray[i].ackNum.c_str());
                printf(" ");
                for (int j = 0; j < 8; j++)
                    printf("%s", packetArray[i].flags[j].c_str());
            }
        }

        if (packetArray[i].protocol4.compare("ICMPv4") == 0 || packetArray[i].protocol4.compare("ICMPv6") == 0)
        {
            printf(" %d", packetArray[i].icmpType);
            printf(" %d", packetArray[i].icmpCode);
            printIcmp(packetArray[i].protocol4, packetArray[i].icmpType, packetArray[i].icmpCode);
        }
        printf("\n");
    }
}

void fragmentL4(packetTemplate *defragPacket)
{
    const struct tcphdr *tcpHeader; // pointer to TCP header
    const struct udphdr *udpHeader; // pointer to UDP header
    const struct icmp *icmpHeader;  // pointer to ICMP header

    if (defragPacket->protocol4.compare("ICMPv4") == 0)
    {
        icmpHeader = (struct icmp *)(&defragPacket->dataFrag[0]);

        defragPacket->icmpType = icmpHeader->icmp_type;
        defragPacket->icmpCode = icmpHeader->icmp_code;
    }
    if (defragPacket->protocol4.compare("TCP") == 0)
    {
        tcpHeader = (struct tcphdr *)(&defragPacket->dataFrag[0]);
        defragPacket->srcPort = to_string(ntohs(tcpHeader->source));
        defragPacket->dstPort = to_string(ntohs(tcpHeader->dest));
        defragPacket->seqNum = to_string(ntohl(tcpHeader->seq));
        defragPacket->ackNum = to_string(ntohl(tcpHeader->ack_seq));

        // flags CWR, ECE, URG, ACK, PSH, RST, SYN, FIN
        defragPacket->flags[0] = ".";
        defragPacket->flags[1] = ".";
        defragPacket->flags[2] = tcpHeader->urg ? "U" : ".";
        defragPacket->flags[3] = tcpHeader->ack ? "A" : ".";
        defragPacket->flags[4] = tcpHeader->psh ? "P" : ".";
        defragPacket->flags[5] = tcpHeader->rst ? "R" : ".";
        defragPacket->flags[6] = tcpHeader->syn ? "S" : ".";
        defragPacket->flags[7] = tcpHeader->fin ? "F" : ".";
    }
    if (defragPacket->protocol4.compare("UDP") == 0)
    {
        udpHeader = (struct udphdr *)(&defragPacket->dataFrag[0]);
        defragPacket->srcPort = to_string(ntohs(udpHeader->source));
        defragPacket->dstPort = to_string(ntohs(udpHeader->dest));
    }
}

/* DEFRAGMENTATION */
void packetDefragmentation()
{
    struct packetTemplate defragPacket; // structure for defragmented packet
    vector<packetTemplate> defragArray; // tmp array

    for (int i = 0; i < packetArray.size(); i++)
    {
        // not more fragments flag and not offset flag
        if (!packetArray[i].moreFrag && !packetArray[i].offsetFrag)
        {
            // its non fragmented packet
            packetArray[i].usedFrag = true;
            defragArray.push_back(packetArray[i]);
            continue;
        }
        // more fragment flag but not offset flag => its our first fragment
        else if (packetArray[i].moreFrag && !packetArray[i].offsetFrag)
        {
            // new packet record
            defragPacket = packetArray[i];
            defragPacket.dataLen = 0;

            // init buffer for packets data
            unsigned char dataBuffer[PACKET_MAX_SIZE];
            bool mask[PACKET_MAX_SIZE];
            for (int k = 0; k < PACKET_MAX_SIZE; k++)
                mask[k] = false;

            // looking for fragments that belong to first fragment
            for (int j = 0; j < packetArray.size(); j++)
            {
                // if !used && is fragment && fragment match =>  data into buffer
                if (!packetArray[j].usedFrag && (packetArray[j].offsetFrag || packetArray[j].moreFrag))
                {
                    if (defragPacket.srcIp.compare(packetArray[j].srcIp) == 0 &&
                        defragPacket.dstIp.compare(packetArray[j].dstIp) == 0 &&
                        defragPacket.protocol4.compare(packetArray[j].protocol4) == 0 &&
                        defragPacket.idFrag == packetArray[j].idFrag)
                    {
                        packetArray[j].usedFrag = true;

                        // last packet offset + its data = length of full packet
                        if (!packetArray[j].moreFrag)
                            defragPacket.dataLen = packetArray[j].offsetFrag + packetArray[j].dataLen;

                        // copy fragment data into buffer from offset position
                        for (int d = 0; d < defragPacket.dataFrag.size(); d++)
                        {
                            dataBuffer[packetArray[j].offsetFrag + d] = packetArray[j].dataFrag[d];
                            mask[packetArray[j].offsetFrag + d] = true;
                        }
                    }
                }
            }

            // if we dont have length of data we dont have last fragment
            bool isComplete = defragPacket.dataLen;

            // check if we have full packet from fragments
            for (int c = 0; c < defragPacket.dataLen; c++)
                if (!mask[c])
                    isComplete = false;

            if (isComplete)
            {
                // save buffer data
                vector<unsigned char> buffVect(dataBuffer, dataBuffer + defragPacket.dataLen);
                defragPacket.dataFrag = buffVect;
                // analyze L4 data from defragmented data
                fragmentL4(&defragPacket);
                // and push packet at defrag array
                defragArray.push_back(defragPacket);
            }

            // clear defrag struct
            defragPacket = emptyPacketStruct;
        }
    }

    // finally we have array of defragmented packets
    packetArray = defragArray;
}

/* SKIP IPv6 EXTENSION HEADER */
void skipExtHeader(int tmpHop)
{
    if (nextHeader == 0)
    {
        nextHeader = packet[tmpHop + SIZE_ETHERNET + 40];
        skipExtHeader(tmpHop + 8 + packet[tmpHop + SIZE_ETHERNET + 41]);
    }
    else if (nextHeader == 60)
    {
        nextHeader = packet[tmpHop + SIZE_ETHERNET + 40];
        skipExtHeader(tmpHop + 8 + packet[tmpHop + SIZE_ETHERNET + 41]);
    }
    else if (nextHeader == 43)
    {
        nextHeader = packet[tmpHop + SIZE_ETHERNET + 40];
        skipExtHeader(tmpHop + 8 + packet[tmpHop + SIZE_ETHERNET + 41]);
    }
    else if (nextHeader == 44)
    {
        nextHeader = packet[tmpHop + SIZE_ETHERNET + 40];
        skipExtHeader(tmpHop + 8);
    }
    else
    {
        ethSize = SIZE_ETHERNET + tmpHop;
    }
}

/* L4 analysis */
void switchL4(bool isIpv6)
{
    const struct tcphdr *tcpHeader; // pointer to TCP header
    const struct udphdr *udpHeader; // pointer to UDP header
    const struct icmp *icmpHeader;  // pointer to ICMP header

    ipHeaderSize = isIpv6 ? 40 : ipv4struct->ip_hl * 4; // header size

    // skip ipv6 extension headers
    if (isIpv6)
    {
        nextHeader = ipv6struct->ip6_ctlun.ip6_un1.ip6_un1_nxt;
        int tmpHop = ethSize - SIZE_ETHERNET;

        skipExtHeader(tmpHop);
    }

    switch (isIpv6 ? nextHeader : ipv4struct->ip_p)
    {
    case 1: // ICMPv4 protocol
        packetStruct.protocol4 = "ICMPv4";

        icmpHeader = (struct icmp *)(packet + ethSize + ipHeaderSize);

        packetStruct.icmpType = icmpHeader->icmp_type;
        packetStruct.icmpCode = icmpHeader->icmp_code;

        break;
    case 6: // TCP protocol
        packetStruct.protocol4 = "TCP";

        tcpHeader = (struct tcphdr *)(packet + ethSize + ipHeaderSize);
        packetStruct.srcPort = to_string(ntohs(tcpHeader->source));
        packetStruct.dstPort = to_string(ntohs(tcpHeader->dest));
        packetStruct.seqNum = to_string(ntohl(tcpHeader->seq));
        packetStruct.ackNum = to_string(ntohl(tcpHeader->ack_seq));

        // flags CWR, ECE, URG, ACK, PSH, RST, SYN, FIN
        // int index = isIpv6 ? ethSize + 53 : 47;
        packetStruct.flags[0] = "."; // (packet[index] & 0b10000000) == 0b10000000 ? "C" : ".";
        packetStruct.flags[1] = "."; // (packet[index] & 0b01000000) == 0b01000000 ? "E" : ".";
        packetStruct.flags[2] = tcpHeader->urg ? "U" : ".";
        packetStruct.flags[3] = tcpHeader->ack ? "A" : ".";
        packetStruct.flags[4] = tcpHeader->psh ? "P" : ".";
        packetStruct.flags[5] = tcpHeader->rst ? "R" : ".";
        packetStruct.flags[6] = tcpHeader->syn ? "S" : ".";
        packetStruct.flags[7] = tcpHeader->fin ? "F" : ".";
        break;
    case 17: // UDP protocol
        packetStruct.protocol4 = "UDP";

        udpHeader = (struct udphdr *)(packet + ethSize + ipHeaderSize);
        packetStruct.srcPort = to_string(ntohs(udpHeader->source));
        packetStruct.dstPort = to_string(ntohs(udpHeader->dest));
        break;
    case 58: // ICMPv6 protocol
        packetStruct.protocol4 = "ICMPv6";

        icmpHeader = (struct icmp *)(packet + ethSize + ipHeaderSize);

        packetStruct.icmpType = icmpHeader->icmp_type;
        packetStruct.icmpCode = icmpHeader->icmp_code;

        break;
    default:
        break;
        fprintf(stderr, " => L4 case get: %d\n", isIpv6 ? ipv6struct->ip6_ctlun.ip6_un1.ip6_un1_nxt : ipv4struct->ip_p);
    }
}

/* L3 analysis */
void switchL3()
{
    if (((packet[12] % 256) == 136) && ((packet[13] % 256) == 168))
    {
        packetStruct.protocol3 = ((packet[20] % 256) == 8) && ((packet[21] % 256) == 0) ? 4 : 6;
        packetStruct.ethType[0] = hexToString(packet[14], packet[15]);
        packetStruct.ethType[1] = hexToString(packet[18], packet[19]);
        ethSize = SIZE_ETHERNET + 8;
    }
    else if (((packet[12] % 256) == 129) && ((packet[13] % 256) == 0))
    {
        packetStruct.protocol3 = ((packet[16] % 256) == 8) && ((packet[17] % 256) == 0) ? 4 : 6;
        packetStruct.ethType[0] = hexToString(packet[14], packet[15]);
        ethSize = SIZE_ETHERNET + 4;
    }
    else
    {
        packetStruct.protocol3 = ((packet[12] % 256) == 8) && ((packet[13] % 256) == 0) ? 4 : 6;
        ethSize = SIZE_ETHERNET;
    }

    switch (packetStruct.protocol3)
    {
    case 4: // IPv4 packet
        ipv4struct = (struct ip *)(packet + ethSize);

        packetStruct.srcIp = inet_ntoa(ipv4struct->ip_src);
        packetStruct.dstIp = inet_ntoa(ipv4struct->ip_dst);
        packetStruct.ttl = to_string(ipv4struct->ip_ttl);

        // fragment parts
        packetStruct.idFrag = ipv4struct->ip_id;
        packetStruct.moreFrag = packet[20 + ethSize - SIZE_ETHERNET] & 0b00100000;
        packetStruct.offsetFrag = ((((packet[ethSize + 6] & 0b00011111) << 3) * 256) + (packet[ethSize + 7] << 3));

        // fragment data
        if (packetStruct.moreFrag || packetStruct.offsetFrag)
        {
            int ip4start = ethSize + 20;                                                                       // L4 data start bit
            packetStruct.dataLen = (packet[ethSize + 2] << 8) + (packet[ethSize + 3]) - ipv4struct->ip_hl * 4; // L4 data length
            for (int i = 0; i < packetStruct.dataLen; i++)
            {
                packetStruct.dataFrag.push_back(packet[ip4start + i]);
            }
        }

        switchL4(false);
        break;
    case 6: // IPv6 packet
        ipv6struct = (struct ip6_hdr *)(packet + ethSize);
        char ip6buff[IPV6_BUFFER_SIZE]; // tmp buffer for ipv6

        inet_ntop(AF_INET6, &(ipv6struct->ip6_src), ip6buff, IPV6_BUFFER_SIZE);
        packetStruct.srcIp = ip6buff;
        inet_ntop(AF_INET6, &(ipv6struct->ip6_dst), ip6buff, IPV6_BUFFER_SIZE);
        packetStruct.dstIp = ip6buff;
        packetStruct.maxHop = to_string(ipv6struct->ip6_ctlun.ip6_un1.ip6_un1_hlim);

        switchL4(true);
        break;
    default:
        break;
    }
}

/* AGREGATE PACKET ARRAY INTO AGGREGATED ARRAY */
void aggregatePackets()
{
    // for all packets from input
    for (int p = 0; p < packetArray.size(); p++)
    {
        // check if packet key is in aggregated array
        bool inArray = false;
        for (int a = 0; a < aggrArray.size(); a++)
        {
            bool addInArray = false; // increment count if already in array
            if (aggrKey.compare("srcmac") == 0)
            {
                if (packetArray[p].srcMac.compare(aggrArray[a].keyValue) == 0)
                    inArray = addInArray = true;
            }
            else if (aggrKey.compare("dstmac") == 0)
            {
                if (packetArray[p].dstMac.compare(aggrArray[a].keyValue) == 0)
                    inArray = addInArray = true;
            }
            else if (aggrKey.compare("srcip") == 0)
            {
                if (packetArray[p].srcIp.compare(aggrArray[a].keyValue) == 0)
                    inArray = addInArray = true;
            }
            else if (aggrKey.compare("dstip") == 0)
            {
                if (packetArray[p].dstIp.compare(aggrArray[a].keyValue) == 0)
                    inArray = addInArray = true;
            }
            else if (aggrKey.compare("srcport") == 0)
            {
                if (packetArray[p].srcPort.compare(aggrArray[a].keyValue) == 0)
                    inArray = addInArray = true;
            }
            else if (aggrKey.compare("dstport") == 0)
            {
                if (packetArray[p].dstPort.compare(aggrArray[a].keyValue) == 0)
                    inArray = addInArray = true;
            }

            if (addInArray)
            {
                aggrArray[a].packetNum++;
                aggrArray[a].lengthNum += packetArray[p].length;
            }
        }
        if (!inArray)
        {
            // add new struct record into array
            if (aggrKey.compare("srcmac") == 0)
                aggrStruct.keyValue = packetArray[p].srcMac;
            else if (aggrKey.compare("dstmac") == 0)
                aggrStruct.keyValue = packetArray[p].dstMac;
            else if (aggrKey.compare("srcip") == 0)
                aggrStruct.keyValue = packetArray[p].srcIp;
            else if (aggrKey.compare("dstip") == 0)
                aggrStruct.keyValue = packetArray[p].dstIp;
            else if (aggrKey.compare("srcport") == 0)
                aggrStruct.keyValue = packetArray[p].srcPort;
            else if (aggrKey.compare("dstport") == 0)
                aggrStruct.keyValue = packetArray[p].dstPort;

            aggrStruct.packetNum = 1;
            aggrStruct.lengthNum = packetArray[p].length;
            // push only non empty values
            if (!aggrStruct.keyValue.compare("") == 0)
                aggrArray.push_back(aggrStruct);
        }
    }
}

/* BUBBLE SORT STRUCTURE BY SORT KEY */
void sortPackets(bool isAggregated)
{
    if (isAggregated)
    {

        int n = aggrArray.size();           // array length
        struct aggrTemplate swapAggrStruct; // tmp

        if (sortKey.compare("bytes") == 0)
        { // sort by bytes
            for (int j = 0; j < (n - 1); j++)
            {
                for (int i = 0; i < n - j - 1; i++)
                {
                    if (aggrArray[i].lengthNum < aggrArray[i + 1].lengthNum)
                    {
                        swapAggrStruct = aggrArray[i];
                        aggrArray[i] = aggrArray[i + 1];
                        aggrArray[i + 1] = swapAggrStruct;
                    }
                }
            }
        }
        else if (sortKey.compare("packets") == 0)
        { // sort by packet num
            for (int j = 0; j < (n - 1); j++)
            {
                for (int i = 0; i < n - j - 1; i++)
                {
                    if (aggrArray[i].packetNum < aggrArray[i + 1].packetNum)
                    {
                        swapAggrStruct = aggrArray[i];
                        aggrArray[i] = aggrArray[i + 1];
                        aggrArray[i + 1] = swapAggrStruct;
                    }
                }
            }
        }
    }
    // non agregated struct sort only by bytes
    else if (sortKey.compare("bytes") == 0)
    {
        int n = packetArray.size();             // array length
        struct packetTemplate swapPacketStruct; // tmp

        for (int j = 0; j < (n - 1); j++)
        {
            for (int i = 0; i < n - j - 1; i++)
            {
                if (packetArray[i].length < packetArray[i + 1].length)
                {
                    swapPacketStruct = packetArray[i];
                    packetArray[i] = packetArray[i + 1];
                    packetArray[i + 1] = swapPacketStruct;
                }
            }
        }
    }
}

/* COMBINING ARGUMENTS FOR OUTPUT */
void getOutput()
{
    bool isAggregated = !aggrKey.empty();

    packetDefragmentation();

    if (isAggregated)
        aggregatePackets();
    if (!sortKey.empty())
        sortPackets(isAggregated);

    isAggregated ? printAggrArray() : printPacketArray();
}

/* PARSE ARGUMENTS */
void parseArgs(int argc, char *argv[])
{
    const string aggrKeys[6] = {"srcmac", "dstmac", "srcip", "dstip", "srcport", "dstport"};
    const string sortKeys[2] = {"packets", "bytes"};
    bool badArg = true; // looking for valid argument
    int lastArg = 0;    // start looking for filenames

    if (argc > 1)
    {
        // get switch arguments
        for (int i = 1; i < argc; i++)
        {
            if (strcmp(argv[i], "-h") == 0)
                printHelp();
            else if (strcmp(argv[i], "-a") == 0)
            {
                aggrKey = argv[i + 1];
                lastArg = i + 1;
            }
            else if (strcmp(argv[i], "-s") == 0)
            {
                sortKey = argv[i + 1];
                lastArg = i + 1;
            }
            else if (strcmp(argv[i], "-l") == 0)
            {
                limit = atoi(argv[i + 1]);
                lastArg = i + 1;
            }
            else if (strcmp(argv[i], "-f") == 0)
            {
                filterExp = argv[i + 1];
                lastArg = i + 1;
            }
        }

        // get fileNames into vector
        for (int i = lastArg + 1; i < argc; i++)
            fileNames.push_back(argv[i]);
    }
    else
        printErr("Bad arguments, try -h for help.");

    // check aggregation key
    if (!aggrKey.empty())
    {
        for (int i = 0; i < 6; i++)
            if (aggrKey.compare(aggrKeys[i]) == 0)
                badArg = false;
        if (badArg)
            printErr("Bad aggregation key.");
        badArg = true;
    }

    // check sort key
    if (!sortKey.empty())
    {
        for (int i = 0; i < 2; i++)
            if (sortKey.compare(sortKeys[i]) == 0)
                badArg = false;
        if (badArg)
            printErr("Bad sort key.");
    }

    // check limit number
    if (limit < 0)
        printErr("Bad limit number.");
}

/* MAIN */
int main(int argc, char *argv[])
{
    /* VARIABLES */
    pcap_t *hadleFile;              // file hadler
    char errbuf[PCAP_ERRBUF_SIZE];  // constant defined in pcap.h
    struct pcap_pkthdr pktHeader;   // packet header
    struct ether_header *ethHeader; // pointer to Ethernet header
    int num = 1;                    // packet number

    // parse argumnets
    parseArgs(argc, argv);

    /* PROCESSING INPUT FOR ALL FILES */
    for (int i = 0; i < fileNames.size(); i++)
    {
        if ((hadleFile = pcap_open_offline(fileNames[i].c_str(), errbuf)) == NULL)
            printErr("Can't open pcap file.");

        // filter packets by expression
        if (!filterExp.empty())
        {
            struct bpf_program fp;
            if (pcap_compile(hadleFile, &fp, filterExp.c_str(), 0, 0) == -1)
                printErr("Pcap filter compile failed.");
            if (pcap_setfilter(hadleFile, &fp) == -1)
                printErr("Pcap filter setfilter failed.");
        }

        // read packets from the file and save them into struct
        while ((packet = pcap_next(hadleFile, &pktHeader)) != NULL)
        {
            packetStruct.number = num;
            packetStruct.timeStamp = to_string((long)pktHeader.ts.tv_sec * (long)1000000 + (long)pktHeader.ts.tv_usec);
            packetStruct.length = pktHeader.len;

            // read the Ethernet header
            ethHeader = (struct ether_header *)packet;
            packetStruct.srcMac = formatMac(ether_ntoa((const struct ether_addr *)&ethHeader->ether_shost));
            packetStruct.dstMac = formatMac(ether_ntoa((const struct ether_addr *)&ethHeader->ether_dhost));

            switchL3();

            packetArray.push_back(packetStruct);
            clearPacketStruct();
            num++;
        }
    }

    // cooking output
    getOutput();

    // close the capture device and deallocate resources
    pcap_close(hadleFile);
    return 0;
}
