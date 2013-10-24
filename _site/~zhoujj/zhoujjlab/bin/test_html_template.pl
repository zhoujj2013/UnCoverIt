#!/usr/bin/perl -w
    use HTML::Template;

    # open the html template
    my $template = HTML::Template->new(filename => 'test.tmpl');

    my %aa;
    $aa{'b'} = $template;
    # fill in some parameters
    $template->param(HOME => "<div>fasdsafsadf</div><p>adfasddfsdfsadf</p>");
    $aa{'b'}->param(PATH => $ENV{PATH});

    # send the obligatory Content-Type and print the template output
    print "Content-Type: text/html\n\n", $template->output;
