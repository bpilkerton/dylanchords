#!/usr/bin/perl
#
# parser_songs.pl - parse dylanchords.info static content
# Ben Pilkerton
#
# go through tree and "register" all songs in XX_ album directories
#
# Src DC Bugs (coding errors):
# the file for Waltzing With Sin has a <title> of "Still In Town"
#
# Src DC Dubs (filenames):
# *Found: Neighborhood Bully
#
# make sure the source .htm files are in the cwd in a folder called "src"
#

use strict;
use DBI;

my $debug = 1;      #print parsed info to STDOUT
my $use_db = 1;     #put parsed info into db
my @albums;
my $dbh;
my $sth;

my $album_file_count;
my $song_file_count;

#Open DB Connection
my $db = "dylanchords";
my $user = "";
my $pwd = "";
my $table = "song";

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

$album_file_count = @albums;
$song_file_count = 0;

for my $album (@albums) {
    
    my @songs = <$album/*.htm>;

    $song_file_count += @songs-1;   #omit assumed index.htm
    
    foreach my $file (@songs) {

        if ($file =~ /index\.htm/) {next;}

        #Open the source .htm file
        open FILE, $file or die $!;

        #Read content into an array, one element per line
        my @lines = <FILE>;
        close FILE;
        
        #Get the Song Title
        my $song_title = "";
        foreach (@lines) {
            my $line = $_;
            #if ($line =~ /<h1 class="songtitle">(.*)<\/h1>/) {
            if ($line =~ /<title>(.*)<\/title>/) {
                $song_title = $1;
            }
        }

        if (!$song_title) {next;}
        if ($debug == 1) {print "Found: $song_title\n";}
        
        $song_title =~ s/'/\\'/g;
        
        my $sql = "INSERT INTO $table (song) ";
        $sql .= "VALUES ('$song_title');";
        
        if ($debug == 1) {print $sql . "\n";}
        
        if ($use_db) {
            $sth = $dbh->prepare($sql);
            $sth->execute();
        }

    }

}

print "Album count: $album_file_count\n";
print "Song count: $song_file_count\n";