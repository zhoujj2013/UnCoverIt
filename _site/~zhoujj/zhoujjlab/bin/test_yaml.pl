use YAML;
#use YAML::Loader;
#use YAML::XS qw(LoadFile);
use Data::Dumper;
    
# Load a YAML stream of 3 YAML documents into Perl data structures.
=cut
my ($hashref, $arrayref, $string, $inter, $inter2) = Load(<<'...');
#asfasdjfl
---
name: ingy
age: old
weight: heavy
---
favorite colors/1sfd:
 - red
 - green
 - blue
---
- Clark Evans
- Oren Ben-Kiki
- Ingy döt Net
---
hr:  65    # Home runs
avg: 0.278 # Batting average
rbi: 147   # Runs Batted In
---
-
  name: Mark McGwire
  hr:   65
  avg:  0.278
-
  name: Sammy Sosa
  hr:   63
  avg:  0.288
...

    # I should comment that I also like pink, but don't tell anybody.
    favorite colors:
        - red
        - green
        - blue
    ---
    - Clark Evans
    - Oren Ben-Kiki
    - Ingy döt Net
    --- >
    You probably think YAML stands for "Yet Another Markup Language". It
    ain't! YAML is really a data serialization language. But if you want
    to think of it as a markup, that's OK with me. A lot of people try
    to use XML as a serialization format.
    
    "YAML" is catchy and fun to say. Try it. "YAML, YAML, YAML!!!"
    ...


open my $fh,"<","$ARGV[0]" || die $!;
#my $config = YAML::LoadFile($fh);
my $yaml = do { local $/; <$fh> };
my $config = Load($yaml);
#my ($string, $arrayref, $hashref, $inter, $inter2) = Load($yaml);
#use Data::Dumper;
print  Dump($config);

# Dump the Perl data structures back into YAML.
#print Dump($string, $arrayref, $hashref);
    
# YAML::Dump is used the same way you'd use Data::Dumper::Dumper
#use Data::Dumper;
#print Dumper($string, $arrayref, $hashref, $inter, $inter2);
=cut




use YAML qw(Dump Bless);
$hash = {apple => 'good', banana => 'bad', cauliflower => 'ugly'};
print Dump $hash;
Bless($hash)->keys(['banana', 'apple']);
print Dump $hash;


