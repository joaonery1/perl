#!/usr/bin/perluse strict;
use warnings;

my @animals = ("camelo", "llama", "boi");
my @numbers = (23, 42, 69);
my @mixed = ("camelo", 42, 1.233);

#print $animals[0];
#print $animals[1];
#print $mixed[$#mixed]; #ultimo elemento
#print $#mixed; #numero de elemntos


print @animals[0,1]; #camelo llama
print "\n";
print @animals[0..2]; #camelo llama boi
print "\n";
print @animals[1..$#animals]; #llama boi
print "\n";

print "------------------------\n"; 
my @sorted = sort @animals;
print @sorted;
