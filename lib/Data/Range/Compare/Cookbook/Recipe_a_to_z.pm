=head1 NAME

Data::Range::Compare::Cookbook -- Tutorial a to z example

=head1 SYNOPSIS

 use strict;   # not needed but saves time
 use warnings; # not needed but saves time

 use lib qw(lib ../lib .);
 use Data::Range::Compare;
 use vars qw(@list %ids %helper);

 # create the global list
 @list=('a' .. 'z');

 # create key ids so we know where we are
 my $id=-1;
 %ids=map { ($_,++$id) } @list;
 undef $id;

 # used to calculate the next value
 sub add_one {
  my $here=$ids{$_[0]};
  ++$here;
  return 'z' if $#list<$here;
  $list[$here]
 }
 # used to calculate the previous value
 sub sub_one {
  my $here=$ids{$_[0]};
  --$here;
  return 'a' if $here<0;
  $list[$here]
 }

 # used to compare 2 values
 sub cmp_values { $_[0] cmp $_[1] }

 # Populate our Helper
 %helper=(
   add_one=>\&add_one
   ,sub_one=>\&sub_one
   ,cmp_values=>\&cmp_values
 );

 my $obj_a=Data::Range::Compare->new(\%helper,qw(c f));
 my $obj_b=Data::Range::Compare->new(\%helper,qw(a z));

 if($obj_a->cmp_ranges($obj_b)==1) {
   print "range_b comes before range_a\n";
 }

 # create a list of lists
 my $list=[ [$obj_a] ,[$obj_b] ];
 my $sub=Data::Range::Compare->range_compare(\%helper,$list);

 while(my @row=$sub->()) {
  my $common_range=Data::Range::Compare->get_common_range(\%helper,\@row);
  print "\n";
  print "Common Range: $common_range\n";
  my ($obj_a,$obj_b)=@row;
  my $range_a_state=$obj_a->missing ?
    'Not in set a'
    :
    'in set a';
  my $range_b_state=$obj_b->missing ?
    'Not in set b'
    :
    'in set b';

  print "Range_a: $obj_a is $range_a_state\n";
  print "Range_b: $obj_b is $range_b_state\n";
 }

 Output:
 range_b comes before range_a

 Common Range: a - b
 Range_a: a - b is Not in set a
 Range_b: a - z is in set b

 Common Range: c - f
 Range_a: c - f is in set a
 Range_b: a - z is in set b

 Common Range: g - z
 Range_a: g - z is Not in set a
 Range_b: a - z is in set b

=head1 DESCRIPTION

This recipe demonstrates how to use the Data::Range::Compare package to manipulate ranges represented as lettters a-z.

=head1 AUTHOR

Michael Shipper

=head1 COPYRIGHT

Copyright 2010 Michael Shipper.  All rights reserved.

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

Data::Range::Compare::Cookbook

=cut

