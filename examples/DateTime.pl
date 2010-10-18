use strict;
use warnings;
use DateTime;
use lib qw(../lib lib .);
use Data::Range::Compare;

my @vpn_a=
  # outage start	 Outage End
(
  '2010-01-02 10:01:59',  '2010-01-02 10:05:47'
  ,'2010-05-02 07:41:32', '2010-05-02 08:00:16'
);
my @vpn_b=
  # outage start	  Outage End
(
  '2010-01-02 10:03:59',  '2010-01-02 10:04:37'
  ,'2010-05-02 07:41:32', '2010-05-02 07:58:13'
);
my @vpn_c=
  # outage start	  Outage End
(
  '2010-01-02 10:03:59',  '2010-01-02 10:04:37'
  ,'2010-05-02 07:41:32', '2010-05-02 07:58:13'
  ,'2010-05-02 07:59:07', '2010-05-02 08:00:16'
  ,'2010-06-18 10:58:21', '2010-06-18 22:06:55'
);
my %helper;

# create a simple function to handle comparing dates
sub cmp_values { DateTime->compare( $_[0],$_[1] ) }

# Now set cmp_values in %helper
$helper{cmp_values}=\&cmp_values;

# create a simple function to calculate the next second
sub add_one { $_[0]->clone->add(seconds=>1) }

# Now set add_one in %helper
$helper{add_one}=\&add_one;

# create a simple function to calculate the previous second
sub sub_one { $_[0]->clone->subtract(seconds=>1) }

# Now set sub_one in our %helper
$helper{sub_one}=\&sub_one;

# parse and load our data
my @parsed;
my @vpn_name=qw(vpn_a vpn_b vpn_c);
foreach my $outages (\@vpn_a,\@vpn_b,\@vpn_c) {
  my $id=shift @vpn_name;
  print "\nVPN_ID $id\n";
  my $row=[];
  push @parsed,$row;
  while(my ($start,$end)=splice(@$outages,0,2)) {
    print $start,"\t",$end,"\n";
    my %args_start=(time_zone => "EST");
    my %args_end=(time_zone => "EST");
    @args_start{qw(year month day hour minute second)}=($start=~ /(\d+)/g);
    @args_end{qw(year month day hour minute second)}=($end=~ /(\d+)/g);
    my $dt_start=DateTime->new(%args_start);
    my $dt_end=DateTime->new(%args_end);
    my $range=Data::Range::Compare->new(\%helper,$dt_start,$dt_end);
    push @$row,$range;
  }
}

# quick and dirty formatting tool
sub format_range ($) {
 my $s=$_[0];
 join ' - '
  ,$s->range_start->strftime('%F %T')
  ,$s->range_end->strftime('%F %T')
}

# now compare our outages
my $sub=Data::Range::Compare->range_compare(\%helper,\@parsed);
while(my ($vpn_a,$vpn_b,$vpn_c)=$sub->()) {
  next unless 
    !$vpn_a->missing 
     && 
    !$vpn_b->missing 
     && 
    !$vpn_c->missing;
  my $common=Data::Range::Compare->get_common_range(
    \%helper
    ,[$vpn_a,$vpn_c,$vpn_b]
  );
  my $outage=$common->range_end->subtract_datetime($common->range_start);
  print "\nCommon outage range: "
    ,format_range($common)
    ,"\n"
    ,"Total Downtime: Months: $outage->{months}"
    ," Days: $outage->{days} Minutes: $outage->{minutes}"
    ," Seconds: $outage->{seconds}\n"
    ,'vpn_a '
    ,format_range($vpn_a)
    ,' '
    ,($vpn_a->missing ? 'up' : 'down')
    ,"\n"

    ,'vpn_b '
    ,format_range($vpn_b)
    ,' '
    ,($vpn_b->missing ? 'up' : 'down')
    ,"\n"

    ,'vpn_c '
    ,format_range($vpn_c)
    ,' '
    ,($vpn_c->missing ? 'up' : 'down')
    ,"\n";
}
