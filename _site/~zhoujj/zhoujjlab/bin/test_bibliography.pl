use Text::MultiMarkdown 'markdown';

my $text = << "IN";

This is a statement that should be attributed to
its source[p. 23][#Doe:2006].

And following is the description of the reference to be
used in the bibliography.

[#Doe:2006]: John Doe. *Some Big Fancy Book*. Vanity Press, 2006.

IN

my $html = markdown($text);

print $html;
