package Avizo::Driver::Analizo;
use Modern::Perl;
use Analizo;

# See the codes:
# http://www.javvin.com/protocolFTP.html

sub EXECUTE {
  my ($self, $method, $param) = @_;
  given($method) {
    when('GET') {
      warn "Calling analizo download\n";
      system("~/src/analizo/analizo download $param");
      return 200;
    }
    default {
      warn "Unknow method = $method\n";
      return 500;
    }
  }
}

1;
