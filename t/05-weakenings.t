use Text::Names qw(weakenings);
use Test::More;
use Data::Dumper;

my @w = weakenings("David J. R.", "Bourget");
print Dumper(@w);

done_testing;
