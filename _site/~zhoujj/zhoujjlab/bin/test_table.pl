use Text::MultiMarkdown 'markdown';

my $text = << "IN";

||||
software|compress time|decompress time|
SAITRandomAccess|3m7.985s|4m26.988s|
CRAM|5m3.405s|1m3.945s|
[Compress/decompress time]

IN

my $html = markdown($text);

print $html;
