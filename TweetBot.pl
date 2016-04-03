#!/usr/bin/perl
# author: gbarosio@gmail.com
# -------------------------------->

$|=1;

use strict;
use Net::Twitter;
use Scalar::Util 'blessed';
use DBI;
use Getopt::Std;

use vars qw/%options $database/;

getopts('hvf:',\%options); # -h for help, -v for verbosity, -f quotes db

print "$options{f} is our database\n" if defined $options{f};
print "$options{v}" if defined $options{v};


# $quote contains a quote that you pushed as a parameter instead of using the quotes database
my $quote = $ARGV[0];

# Here you put all your tokens and stuff from app.twitter.com
# In the event you want to use this bot for another purpose, just change the tokens and cnsumers keys and you will have a new bot
my $consumer_key 			='';
my $consumer_secret 		='';
my $token 					='';
my $token_secret    		='';

# Here we load some libraries required that allow the bot to post to twitter
#my $nt = Net::Twitter->new(legacy => 0);
my $nt = Net::Twitter->new(
      traits   => [qw/API::RESTv1_1/],
      consumer_key        => $consumer_key,
      consumer_secret     => $consumer_secret,
      access_token        => $token,
      access_token_secret => $token_secret,
  );

# I call the __init() function in order to kick off everything, it's a matter of purely being ordered in our code.
__init();

# This is where the #magic starts
# if there is a quote passed as an argument instead of using the quotes database, then the program will use that quote
sub __init {
	if (!defined $options{f})  {
		printHelp();
	} else {
		$database = $options{f};
	}

	if ($quote) {
		main($quote);
	# BUT if there is no quote passed as an argument, then the program will use the quotes database in the file quotes.txt
	} else {
		main();
	}
}

# this is where it actually gets executed, a function called main
# where you find an action called $nt->update($text);
# $nt->update() is a function that receives text, and using the twitter credentials that you provided previously in the code, will update the tweeter feed

sub main {
	my $flag = shift;
	my ($text,$result)=(undef,undef);

	# There is a quote as a parameter, let's got!
	if ($flag) { 
		$text = $flag;
	} else {
		$text = getFileQuote(); # in the case there is no quote, we look at the quotes database through the function getText();
	}

	# update twitter
	#$result = $nt->update($text);  # here is where the post happens
}


# This particular function will review the file quotes.txt and extract, using random criteria, a quote
# once a quote has been fetched, it will return the value to the function main()  so it can process the post. 
sub getFileQuote {
	print "here\n";
	if (-r $database) {
		my $file = '$database';
		open FILE, "<$file" or die "Could not open $file: $!\n";
		my @array=<FILE>;
		close FILE;
		my $randomline=$array[rand @array];
		chomp $randomline;
		return $randomline;
	} else {
			printHelp();
	}
}

sub printHelp {
	print "$0 -f <filename>\n";
	print "$0 -v -f <filename>\n";
	print "$0 -h\n";
	exit;
}

1;
