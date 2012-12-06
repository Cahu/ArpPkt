use 5.010;
use strict;
use warnings;

use Socket qw(SOCK_RAW);
use Socket::Packet qw(
    pack_sockaddr_ll
    PF_PACKET
    ETH_P_ALL
    PACKET_OUTGOING
);


use constant {
    ARPOP_REQUEST  => 1,
    ARPOP_REPLY    => 2,

    ETHERTYPE_ARP => 0x0806,
    ARPHDR_ETHER  => 1,         # see linux/if_arp.h

    HTYPE => 1,      # Ethernet
    PTYPE => 0x0800, # IPv4 
    HLEN  => 6,      # MAC addr length
    PLEN  => 4,      # IP addr length
};


my $sha = $ARGV[0];
my $spa = $ARGV[1];
my $tha = $ARGV[2];
my $tpa = $ARGV[3];


$spa = Socket::inet_aton($spa);
$tpa = Socket::inet_aton($tpa);
$sha = pack ('H2' x HLEN, split(/:/, $sha));
$tha = pack ('H2' x HLEN, split(/:/, $tha));

my $ifindex = ifname_to_index("eth0");

# Are all these options really necessary?
my $addr = pack_sockaddr_ll (ETH_P_ALL, $ifindex, ARPHDR_ETHER,
                             PACKET_OUTGOING, $tha);

my $pkt = pack ('a6a6nnnCCna6a4a6a4A*',
                $tha, $sha, ETHERTYPE_ARP,               # ETH header
                HTYPE, PTYPE, HLEN, PLEN, ARPOP_REPLY,   # ARP header
                $sha, $spa, $sha, $spa, "What's up doc?"); # Gratuitous packet


socket (RAW, PF_PACKET, SOCK_RAW, ETH_P_ALL) or die "Socket: $!";
send (RAW, $pkt, 0, $addr) or warn $!;
close RAW;

# Ugly but simple way to get the interface index from its name
sub ifname_to_index {
    my $ifname = shift;
    open (FH, "< /sys/class/net/$ifname/ifindex") or die "ifindex open: $!";
    chomp (my $ifindex = <FH>);
    close FH;
    return $ifindex;
}
