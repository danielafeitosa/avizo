package Avizo::Server;
use Modern::Perl;
use Socket;
use IO::Socket::INET;
use AnyEvent;
use AnyEvent::Socket;
use AnyEvent::Handle;
use Avizo::Driver;
 
=head1 PROTOCOL

Commands:

REGISTER <url>

=cut

sub condvar {
  AnyEvent->condvar;
}
 
sub start_listen {
  my ($self, %args) = @_;
  my $handle;
  warn "listening on port $args{port}...\n";
  tcp_server undef, $args{port}, sub {
     my ($sock, $host, $port) = @_;
     print "Got new client connection: $host:$port\n";
     $handle = AnyEvent::Handle->new(
       fh => $sock,
       on_eof => sub { print "client connection $host:$port: eof\n" },
       on_error => sub { print "Client connection error: $host:$port: $!\n" }
     );
     $handle->push_write("Hello! I'm Avizo v$Avizo::VERSION.\015\012");
     $handle->push_read(line => sub {
       my (undef, $line) = @_;
       my $response = $self->process_request($line);
       $handle->push_write("$response\015\012");
       $handle->on_drain(sub { $handle->fh->close; undef $handle });
     });
  };
}

sub parse_request {
  my ($self, $line) = @_;
  my ($method, $param) = (undef, undef);
  if ($line =~ m/^(GET|DELETE) (\w+:\/\/\S+)$/o) {
    ($method, $param) = ($1, $2);
  }
  return ($method, $param);
}

sub process_request {
  my ($self, $line) = @_;
  print "Got request = $line\n";
  my ($method, $param) = $self->parse_request($line);
  my $response;
  if ($method && $param) {
    my $code = Avizo::Driver->EXECUTE($method, $param);
    $response = "method = $method, param = $param, return code = $code";
  }
  else {
    $response = "invalid request";
  }
  return $response;
}

1;
