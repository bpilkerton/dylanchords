#!/usr/bin/perl
#
# parser_albums.pl - parse dylanchords.info static content
# Ben Pilkerton
#
# -ignoring 00_MISC for now
# -parse year from album title, add it to a new field in 'album'
#

use strict;
use DBI;

my $debug = 0;      #print parsed info to STDOUT
my $use_db = 1;     #put parsed info into db
my @albums;
my $dbh;
my $sth;

my $album_file_count;

#Open DB Connection
my $db = "dylanchords";
my $user = "";
my $pwd = "";
my $table = "album";

if ($use_db) {
    $dbh = DBI->connect('DBI:mysql:'.$db, $user, $pwd) || die "Could not connect to database: $DBI::errstr";
}

#Glob the files
my @files = <src/*>;

#Construct directory list use only those with XX_ prefix
foreach (@files) {
    if (-d $_) {
        if ($_ =~ /\/\d\d_/) {
            if ($_ =~ /00_misc/) {next;}

            push(@albums,$_);
        }
    }
}

my $album_file_count = @albums;
my $false_alarms = 0;

#Iterate through directories and extract data about album from each index.htm
for my $album (@albums) {

    my $file = $album . "/index.htm";

    #Open the source .htm file
    if (-f $file) {
        open FILE, $file or die $!;
    }

    #Read content into an array, one element per line
    my @lines = <FILE>;
    close FILE;

    #Get the Album name from <title>
    my $title;
    foreach (@lines) {
        if ($_ =~ /<title>(.*)<\/title>/) {
            $title = $1;
        }
    }

    if ($title =~ /^$/) {
        $false_alarms++;
        next;
    }

    #pull out year
    #my  $title_year;
    #if ($title =~ /(.*)\s([\d\d\d\d])/) {
    #    $title = $1;
    #    $title_year = $2;
    #}

    if ($debug == 1) {print "Found title: $title\n";}

    #Get recorded/released dates
    my $recorded;
    my $released;
    foreach (@lines) {
        if ($_ =~ /<p class="recdate">Recorded[\:]?\s(.*)<br \/>/i) {
            $recorded = $1;
        }
        if ($_ =~ /Released[\:]?\s(.*)<\/p>?/i) {
            $released = $1;
            $released =~ s/<\/p>//;
        }
    }    

    if ($debug == 1) {print "Recorded: $recorded\n";}
    if ($debug == 1) {print "Released: $released\n";}

    #Find album cover
    my $cover;
    foreach (@lines) {
        if ($_ =~ /graphics\/([\w]+\.[\w]+)/) {
            $cover = $1;
        }
    }
    
    if ($debug == 1) {print "Cover: $cover\n";}
    
    #Get intro if it exists
    my $intro;
    my $found_intro = 0;
    foreach (@lines) {
        if ($_ =~ /<div id="intro">/) {
            $intro .= $_ . "\n";
            $found_intro = 1;
        }
        
        if (($found_intro == 1) and ($_ !~ /<\/div>/)) {
            $intro .= $_ . "\n";
        }
        
        if (($found_intro == 1) and ($_ =~ /<\/div>/)) {
            $found_intro = 0;
        }
    }
    
    if ($debug == 1) {print "Intro: $intro\n";}
    
    $title =~ s/'/\\'/g;
    $title = &clean_chars($title);
    print "Found title: $title\n";
    
    $recorded =~ s/'/\\'/g;
    $released =~ s/'/\\'/g;
    $cover =~ s/'/\\'/g;
    $intro =~ s/'/\\'/g;
    
    #Put $title, $recorded, $released $cover, $intro into db
    my $sql = "INSERT INTO $table (album_name,album_recorded,album_released, album_cover,album_notes) ";
    $sql .= "VALUES ('$title','$recorded','$released','$cover','$intro');";
    
    if ($debug == 1) {print $sql . "\n";}
    
    if ($use_db) {
        $sth = $dbh->prepare($sql);
        $sth->execute();
    }
    
} #CLOSE FILE

sub clean_chars {
    my $in = shift;
    $in =~ s/&rsquo;/\\'/g;
    $in =~ s/&amp;/&/g;
    $in =~ s/&quot;/\"/g;
    
    return $in;
}

my $total_album_count = $album_file_count - $false_alarms;
print "\n\nFound " . $total_album_count  . " albums\n";
