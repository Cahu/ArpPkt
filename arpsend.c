#include <stdio.h>
#include <unistd.h>
#include <libnet.h>


#define ETHLEN 6
#define IPLEN 4

void get_ip4_addr(uint8_t *, const char *);
void get_mac_addr(uint8_t *, const char *);

void usage(const char * pgrm_name) {
	printf( "Usage: %s <sha> <spa> <tha> <tpa>\n"
		"Where *ha looks like XX:XX:XX:XX:XX:XX\n"
		"and *pa looks like x.y.z.t\n", pgrm_name);
}


int main (int argc, char * argv[])
{
	if (argc < 5) {
		usage(argv[0]);
		exit(EXIT_FAILURE);
	}
	
	char ebuff[128];
	
	uint8_t sha[ETHLEN];
	uint8_t tha[ETHLEN];
	uint8_t spa[IPLEN];
	uint8_t tpa[IPLEN];	
	
	get_mac_addr(sha, argv[1]);
	get_mac_addr(tha, argv[3]);
	get_ip4_addr(spa, argv[2]);
	get_ip4_addr(tpa, argv[4]);

	libnet_t * l = libnet_init(LIBNET_LINK, "eth0", ebuff);

	if (l == NULL) perror("init");

	int arp = libnet_build_arp(ARPHRD_ETHER, ETHERTYPE_IP, ETHLEN,
				   IPLEN, ARPOP_REPLY, sha, spa, tha,
				   tpa, NULL, 0, l, 0);
					  
	if (arp == -1) {
		perror("arp");
		fprintf(stderr, "arp: %s\n", libnet_geterror(l));
		exit(EXIT_FAILURE);
	}

	int eth = libnet_build_ethernet(tha, sha, ETHERTYPE_ARP, NULL, 0, l, 0);

	if (eth == -1) {
		perror("eth");
		fprintf(stderr, "eth: %s\n", libnet_geterror(l));
		exit(EXIT_FAILURE);
	}

    libnet_write(l);

	return 0;
}

void get_ip4_addr(uint8_t *addr, const char *str)
{
	sscanf(str, "%hhu.%hhu.%hhu.%hhu", addr, addr+1, addr+2, addr+3);
}

void get_mac_addr(uint8_t *addr, const char *str)
{
	sscanf(str, "%hhx:%hhx:%hhx:%hhx:%hhx:%hhx", addr, addr+1,
	       addr+2, addr+3, addr+4, addr+5);
}
