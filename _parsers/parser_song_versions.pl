#!/usr/bin/perl
#
# parser_song_version.pl - parse dylanchords.info static content
# Ben Pilkerton
#
# make sure the source .htm files are in the cwd in a folder called "src"
#

use strict;
no strict 'refs';
use DBI;

my $debug = 0;                                      #print parsed/info to STDOUT
my $table_song_version = "song_version";            #table we are writing to for song_versions
my $table_song = "song";                            #table for summary insert
my $table_album_songversion = "album_song_version"; #table to insert album-songversion link
my $table_album = "album";
my $use_db = 1;                                     #put parsed info into db. select queries 
                                                    #to $table_song for lookup are always run
my $db = "dylanchords";
my $user = "";
my $pwd = "";

my @albums;
my $dbh;
my $sth;

#Open DB Connection
$dbh = DBI->connect('DBI:mysql:'.$db, $user, $pwd) || die "Could not connect to database: $DBI::errstr";

#Glob the directories
my @files = <src/*>;

#Construct directory list. use only those with XX_ prefix
foreach (@files) {
    if (-d $_) {
        if ($_ =~ /\/\d\d_/) {
            if ($_ =~ /00_misc/) {next;}

            push(@albums,$_);
        }
    }
}

for my $album (@albums) {
    
    next if (! -d $album);
    my @songs = <$album/*.htm>;

    ###################################################
    #Pull out the index to get album name, lookup 
    # it's id to link to song_versions
    ###################################################
    my $file = $album . "/index.htm";
    
    #Open the source .htm file
    if (-f $file) {
        open FILE, $file or die $!;
    }
    
    my @lines = <FILE>;
    close FILE;
    
    #Get the Album name from <title> same as in parser_albums.pl
    my $album_title;
    foreach (@lines) {
        if ($_ =~ /<title>(.*)<\/title>/) {
            $album_title = $1;
        }
    }
    
    $album_title =~ s/&rsquo;/\'/g;
    $album_title =~ s/&amp;/&/g;
    $album_title =~ s/&quot;/\"/g;
    
    undef @lines;
    print "Album: $album_title\n";
    my $ref_album_id = &lookup_album_id($album_title);

    ###################################################
    # Main song file loop
    ###################################################
    foreach my $file (@songs) {

        if ($file =~ /index\.htm/) {next;}

        #Open the source .htm file
        open FILE, $file or die $!;

        #Read content into an array, one element per line
        my @lines = <FILE>;
        close FILE;
        
        #Get the Song Title
        my $song_title = 0;
        foreach (@lines) {
            my $line = $_;
            #if ($line =~ /<h1 class="songtitle">(.*)<\/h1>/) {
            if ($line =~ /<title>(.*)<\/title>/) {
                $song_title = $1;
            }
        }

        print "\t Song: " . $song_title . "\n";
        
        # lookup song.id in song table.  will have to use %like%?
        $song_title =~ s/'/\\'/g;
        my $sql = "SELECT id FROM $table_song WHERE song like '%$song_title%'";
        if ($debug == 1) {print $sql . "\n";}
        $sth = $dbh->prepare($sql);
        $sth->execute();

        my @lookup;
        my $ref_song_id = 0;
        while (@lookup = $sth->fetchrow_array()) {
            $ref_song_id = $lookup[0];
        }
        
        if (!$ref_song_id) {die "NO REFERNECE ID FOUND FOR $song_title\n";}

        #GET EVERYTHING BETWEEN HR/
        # hr1 is likely to be the summary
        # hr2 has a chance of being a preamble (notes and chords and discussion)
        # subsequent hrX is likely to be a version
        #
        my $hr_count = 0;
        my @data;
        foreach (@lines) {
            my $line = $_;
            if ($line =~ /<hr \/>/) {
                $hr_count++;
            } else {
                if (@data[$hr_count]) {
                    @data[$hr_count] .= $line;
                } else {
                    @data[$hr_count] = $line;
                }
            }
        }

        #Do something with each data between hr/s
        my $n = 0;
        foreach (@data) {
            &parse_hr_chunk($_,$ref_song_id,$n,$ref_album_id);
            $n++;
        }

    } #song
} #album

#
# Handle an hr chunk
#In: a string of a <hr /> chunk
#
sub parse_hr_chunk {
    my $hr_chunk = shift;
    my $ref_song_id  = shift;
    my $n = shift;
    my $ref_album_id = shift;

    #convert song_version string to array by newline
    my @version = split(/\n/,$hr_chunk);

    #Assume first element is the summary, but check
    if ($n == 0) {
        @version = &song_clean_head(\@version);

        #Some parsed @summary's are really song_versions with no summary
        #IF they have 'Tabbed by' we'll assume they are a summary
        my $summary_check = &check_summary(\@version);

        if ($summary_check) {
            &insert_summary($ref_song_id,\@version);
        } else {
            my $song_version = &get_song_version(\@version,$n);
            &insert_song_version($ref_song_id,$song_version,\@version,$ref_album_id)
        }
        return;
    }

    #Figure out the rest by seeing if this chunk is a song version
    #if not, we'll call it the preamble
    if ($n > 0) {
        my $song_version = &get_song_version(\@version,$n);
        if ($song_version) {
            &insert_song_version($ref_song_id,$song_version,\@version,$ref_album_id);
        } else {
            &insert_preamble($ref_song_id,\@version);
        }
    }

}

#
# confirm the chunk we're looking at is a summary by the presence
# of "Tabbed By", if this string occurs, it's always in the summary
#
sub check_summary {
    my ($chunk,$n) = @_;

    foreach (@$chunk) {
        my $line = $_;
        
        if ($line =~ /Tabbed by/i) {
            return 1;
        }
    }

    return 0;
}


#
# extract the name of the song_version from a chunk
#
sub get_song_version {
    my ($chunk,$n) = @_;
    my $song_version;

    foreach (@$chunk) {
        my $line = $_;

        #This may be a stretch, but seems to work for most cases
        if ($line =~ /class="verse">/) {
            $song_version = "Album Version";
            return $song_version;
        }

        if ($line =~ /<h2 class="songversion">(.*)<\/h2>/) {
            $song_version = $1;
            return $song_version;
        }
    }

    return 0;
}

#
# remove the data from <?xml till first <h1>
# IN: array reference
# OUT: cleaned array
#
sub song_clean_head {
    my ($version_in) = @_;
    my $found_h1 = 0;
    my @version_out;

    foreach (@$version_in) {
        my $line = $_;
        
        if (($found_h1 == 1)) {
            push(@version_out,$line);
        }

        if ($line =~ /<h1 class="songtitle">(.*)<\/h1>/) {
            $found_h1 = 1;
        }
    }

    return @version_out;

}

#
# Insert parsed summary data to the DB
#
sub insert_summary {
    my ($song_id,$chunk) = @_;

    #put chunk into string for db insertion, add \n
    my $string = '';
    foreach (@$chunk) {
        $string .= $_ . "\n";
    }
    
    $string =~ s/'/\\'/g;
    my $sql = "UPDATE $table_song SET song_summary= '$string' WHERE id=$song_id;";

    if ($use_db) {
        $sth = $dbh->prepare($sql);
        $sth->execute();
    }

}

#
# Insert parsed preamble data to the DB
#
sub insert_preamble {
    my ($song_id,$chunk) = @_;
    
    #put chunk into string for db insertion, add \n
    my $string = '';
    foreach (@$chunk) {
        $string .= $_ . "\n";
    }
    
    $string =~ s/'/\\'/g;
    my $sql = "UPDATE $table_song SET song_preamble= '$string' WHERE id=$song_id;";

    if ($use_db) {
        $sth = $dbh->prepare($sql);
        $sth->execute();
    }

}

#
# Insert parsed song version data to the DB
#
sub insert_song_version {
    my ($song_id,$song_version,$chunk,$ref_album_id) = @_;
    
    #put chunk into string for db insertion, add \n
    my $string = '';
    foreach (@$chunk) {
        $string .= $_ . "\n";
    }

    $song_version =~ s/'/\\'/g;    
    $string =~ s/'/\\'/g;
    
    my $sql = "INSERT INTO $table_song_version (song,song_version,song_version_content) VALUES ($song_id,'$song_version','$string');";

    if ($use_db) {
        $sth = $dbh->prepare($sql);
        $sth->execute();
    }

    #Lookup the id of the song_version we just inserted
    my $ref_song_version_id = &lookup_last_song_id();
    
    #Now create album song_version link with $ref_album_id and song_version id
    my $sql = "INSERT INTO $table_album_songversion (album,song_id,song_version) VALUES ('$ref_album_id','$song_id','$ref_song_version_id');";
    if ($use_db) {
        $sth = $dbh->prepare($sql);
        $sth->execute();
    }
}

sub lookup_album_id {
    my $album_title = shift;

    $album_title =~ s/'/\\'/g;
    
    my $sql = "SELECT id FROM $table_album WHERE album_name like '%$album_title%'";
        if ($debug == 1) {print $sql . "\n";}
        $sth = $dbh->prepare($sql);
        $sth->execute();

        my @lookup;
        my $ref_album_id = 0;
        while (@lookup = $sth->fetchrow_array()) {
            $ref_album_id = $lookup[0];
        }
        
        if (!$ref_album_id) {die "NO REFERNECE ID FOUND FOR $album_title\n";}
        
        return $ref_album_id;
}

sub lookup_last_song_id {
    #(NONE OF THE DBI METHODS WORKED)
    my $sql = "SELECT * FROM $table_song_version ORDER BY id DESC LIMIT 1;";
    if ($debug == 1) {print $sql . "\n";}
    $sth = $dbh->prepare($sql);
    $sth->execute();

    my @lookup;
    my $ref_song_version_id = 0;
    while (@lookup = $sth->fetchrow_array()) {
        $ref_song_version_id = $lookup[0];
    }
        
    if (!$ref_song_version_id) {die "COULD NOT GET LAST SONG_VERSION ID\n";}
        
    return $ref_song_version_id;
    
}