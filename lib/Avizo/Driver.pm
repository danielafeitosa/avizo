package Avizo::Driver;
use Modern::Perl;

our $DEFAULT = 'Analizo';

sub EXECUTE {
  my ($self, $method, $param) = @_;
  my $DRIVER = "${self}::$DEFAULT";
  eval "use $DRIVER;";
  $DRIVER->EXECUTE($method, $param);
}

1;
