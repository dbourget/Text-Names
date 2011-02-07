package Text::Names;

use 5.010001;
use strict;
use warnings;
use Text::Capitalize qw(capitalize_title @exceptions);

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Text::Names ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	@NAME_PREFIXES 
    abbreviationOf 
    reverseName 
    cleanParseName 
    parseName 
    parseName2 
    normalizeNameWhitespace 
    samePerson 
    sameAuthors 
    parseNames 
    parseNameList 
    cleanNames 
    cleanName 
    weakenings 
    composeName
    abbreviationOf
    setNameAbbreviations
    getNameAbbreviations
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = ();

our $VERSION = '0.01';

our @NAME_PREFIXES = qw(de di du da le la van von der den des ten ter);

@Text::Capitalize::exceptions = qw(
     a an the as s
     on is its für à les des au aux o y
     and or nor for but so yet 
     to of by at for but in with has
     quot amp
  );
push @Text::Capitalize::exceptions, @NAME_PREFIXES;

$Text::Capitalize::word_rule =  qr{ ([^\w\s]*)   # $1 - leading punctuation 
                               #   (e.g. ellipsis, leading apostrophe)
                   ([\w']*)    # $2 - the word itself (includes non-leading apostrophes AND HTML ENTITIES)
                   ([^\w\s]*)  # $3 - trailing punctuation 
                               #   (e.g. comma, ellipsis, period)
                   (\s*)       # $4 - trailing whitespace 
                               #   (usually " ", though at EOL prob "")
                 }x ;


our @ABBREVIATIONS = (
'Ab' => 'Abner',
'Abbie' => 'Abigail',
'Abby' => 'Abigail',
'Abe' => 'Abel',
'Abe' => 'Abraham',
'Abe' => 'Abram',
'Acer' => 'Acera',
'Ada' => 'Adeline',
'Addie' => 'Adelaide',
'Ag' => 'Agatha',
'Aggy' => 'Agatha',
'Agnes' => 'Agatha',
'Agnes' => 'Inez',
'Al' => 'Albert',
'Al' => 'Alexander',
'Al' => 'Alfred',
'Alec' => 'Alexander',
'Alex' => 'Alexander',
'Alf' => 'Alfred',
'Amy' => 'Amanda',
'Amy' => 'Amelia',
'Andy' => 'Andreas',
'Andy' => 'Andrew',
'Angie' => 'Angeline',
'Ann' => 'Deanne',
'Ann' => 'Hannah',
'Ann' => 'Susanna',
'Anna' => 'Hannah',
'Anna' => 'Susanna',
'Anne' => 'Hannah',
'Anne' => 'Susanna',
'Annette' => 'Ann',
'Annette' => 'Anna',
'Annie' => 'Ann',
'Annie' => 'Anna',
'Annie' => 'Hannah',
'Annie' => 'Susanna',
'Appy' => 'Apollonia',
'Archy' => 'Archibald',
'Arnie' => 'Arnold',
'Arny' => 'Arnold',
'Art' => 'Artemis',
'Art' => 'Arthur',
'Arty' => 'Arthur',
'Bab' => 'Barbara',
'Babs' => 'Barbara',
'Barb' => 'Barbara',
'Barney' => 'Barnabas',
'Bart' => 'Bartholomew',
'Barty' => 'Bartholomew',
'Bass' => 'Sebastian',
'Bea' => 'Beatta',
'Bea' => 'Beatrice',
'Beattie' => 'Beatrice',
'Becky' => 'Rebecca',
'Bella' => 'Arabella',
'Bella' => 'Belinda',
'Bella' => 'Elizabeth',
'Bella' => 'Isabel',
'Bella' => 'Isabella',
'Bella' => 'Mirabel',
'Belle' => 'Mabel',
'Belle' => 'Sybil',
'Ben' => 'Benedict',
'Ben' => 'Benjamin',
'Bert' => 'Delbert',
'Bert' => 'Egbert',
'Bertie' => 'Albert',
'Bertie' => 'Gilbert',
'Bess' => 'Elizabeth',
'Bessie' => 'Elizabeth',
'Beth' => 'Elizabeth',
'Beto' => 'Alberto',
'Betsy' => 'Elizabeth',
'Betty' => 'Elizabeth',
'Bev' => 'Beverly',
'Bill' => 'William',
'Bob' => 'Robert',
'Burt' => 'Egbert',
'Cal' => 'Caleb',
'Cal' => 'Calvin',
'Carol' => 'Caroline',
'Cassie' => 'Cassandra',
'Cathy' => 'Catherine',
'Caty' => 'Catherine',
'Cecily' => 'Cecilia',
'Charlie' => 'Charles',
'Chet' => 'Chester',
'Chris' => 'Christian',
'Chris' => 'Christine',
'Chris' => 'Crystal',
'Chuck' => 'Charles',
'Cindy' => 'Cynthia',
'Cindy' => 'Lucinda',
'Cissy' => 'Cecilia',
'Cissy' => 'Clarissa',
'Claus' => 'Nicholas',
'Cleat' => 'Cleatus',
'Clem' => 'Clement',
'Clem' => 'Clementine',
'Cliff' => 'Clifford',
'Cliff' => 'Clifton',
'Clo' => 'Chloe',
'Connie' => 'Constance',
'Connie' => 'Cornelia',
'Conny' => 'Cornelia',
'Cora' => 'Corinne',
'Corky' => 'Courtney',
'Cory' => 'Cornelius',
'Creasey' => 'Lucretia',
'Crissy' => 'Christina',
'Crissy' => 'Christine',
'Cy' => 'Cyrus',
'Cyndi' => 'Cynthia',
'Daisy' => 'Margaret',
'Dan' => 'Daniel',
'Danny' => 'Daniel',
'Dave' => 'David',
'Davy' => 'David',
'Deb' => 'Deborah',
'Debby' => 'Deborah',
'Dee' => 'Deanne',
'Deedee' => 'Diedre',
'Delia' => 'Bridget',
'Delia' => 'Cordelia',
'Delia' => 'Fidelia',
'Della' => 'Delilah',
'Derick' => 'Frederick',
'Di' => 'Diana',
'Di' => 'Diane',
'Dicey' => 'Edith',
'Dicey' => 'Elizabeth',
'Dicey' => 'Eurydice',
'Dick' => 'Richard',
'Didi' => 'Diana',
'Didi' => 'Diane',
'Doc' => 'name given to 7th child',
'Doctor' => 'name given to 7th child',
'Dodie' => 'Delores',
'Dolly' => 'Dorothy',
'Dolly' => 'Margaret',
'Dolly' => 'Martha',
'Dora' => 'Dorothy',
'Dora' => 'Eudora',
'Dora' => 'Isadora',
'Dotty' => 'Dorothy',
'Doug' => 'Douglas',
'Drew' => 'Andrew',
'Eck' => 'Alexander',
'Ed' => 'Edmund',
'Ed' => 'Edward',
'Edie' => 'Edith',
'Effie' => 'Euphemia',
'Elaine' => 'Eleanor',
'Eli' => 'Elijah',
'Eli' => 'Elisha',
'Ella' => 'Eleanor',
'Ella' => 'Gabriella',
'Ella' => 'Luella',
'Ellen' => 'Eleanor',
'Ellie' => 'Danielle',
'Ellie' => 'Eleanor',
'Ellie' => 'Emily',
'Ellie' => 'Gabriella',
'Ellie' => 'Luella',
'Elly' => 'Eleanor',
'Eloise' => 'Heloise',
'Elsie' => 'Elizabeth',
'Emily' => 'Emeline',
'Emma' => 'Emily',
'Eph' => 'Ephraim',
'Erma' => 'Emily',
'Erna' => 'Earnestine',
'Ernie' => 'Earnest',
'Ernie' => 'Earnestine',
'Etta' => 'Loretta',
'Ev' => 'Evangeline',
'Ev' => 'Evelyn',
'Eve' => 'Evelyn',
'Evie' => 'Evelyn',
'Fan' => 'Frances',
'Fanny' => 'Frances',
'Fanny' => 'Veronica',
'Fay' => 'Faith',
'Fina' => 'Josephine',
'Flo' => 'Florence',
'Flora' => 'Florence',
'Flossie' => 'Florence',
'Fran' => 'Frances',
'Frances' => 'Franziska',
'Frank' => 'Francis',
'Frank' => 'Franklin',
'Frankie' => 'Frances',
'Fred' => 'Ferdinand',
'Fred' => 'Frederick',
'Fred' => 'Gottfried',
'Freddie' => 'Frederick',
'Fritz' => 'Frederick',
'Gab' => 'Gabriel',
'Gabby' => 'Gabrielle',
'Gabe' => 'Gabriel',
'Gene' => 'Eugene',
'Genny' => 'Gwenevere',
'Geoff' => 'Geoffrey',
'Gerry' => 'Gerald',
'Gus' => 'Augustus',
'Gus' => 'Gustaf',
'Ham' => 'Hamilton',
'Hank' => 'Henry',
'Hanna' => 'Johanna',
'Hans' => 'Johan',
'Hans' => 'Johannes',
'Harry' => 'Henry',
'Harry' => 'Horace',
'Helen' => 'Eleanor',
'Hester' => 'Esther',
'Ibby' => 'Elizabeth',
'Iggy' => 'Ignatius',
'Issy' => 'Isabella',
'Issy' => 'Isadora',
'Jack' => 'John',
'Jack' => 'Jackson',
'Jackie' => 'Jacqueline',
'Jake' => 'Jacob',
'Jan' => 'Jennifer',
'Jane' => 'Janet',
'Jane' => 'Virginia',
'Jed' => 'Jedediah',
'Jeff' => 'Jeffrey',
'Jennifer' => 'Winifred',
'Jenny' => 'Jennifer',
'Jeremy' => 'Jeremiah',
'Jerry' => 'Jeremiah',
'Jill' => 'Julia',
'Jim' => 'James',
'Jimmy' => 'James',
'Joe' => 'Joseph',
'Joey' => 'Joseph',
'Johnny' => 'John',
'Jon' => 'Jonathan',
'Josh' => 'Joshua',
'Josie' => 'Josephine',
'Joy' => 'Joyce',
'Judy' => 'Judith',
'Kate' => 'Catherine',
'Kathy' => 'Katherine',
'Kathy' => 'Kathlene',
'Katie' => 'Katherine',
'Kissy' => 'Calista',
'Kit' => 'Christopher',
'Kitty' => 'Catherine',
'Klaus' => 'Nicholas',
'Lana' => 'Eleanor',
'Len' => 'Leonard',
'Lena' => 'Magdalena',
'Leno' => 'Felipe',
'Lenora' => 'Eleanor',
'Leo' => 'Leonard',
'Leon' => 'Leonard',
'Lettie' => 'Letitia',
'Lew' => 'Lewis',
'Libby' => 'Elizabeth',
'Lila' => 'Delilah',
'Lisa' => 'Elisa',
'Liz' => 'Elizabeth',
'Liza' => 'Elizabeth',
'Lizzie' => 'Elizabeth',
'Lola' => 'Delores',
'Lorrie' => 'Lorraine',
'Lottie' => 'Charlotte',
'Lou' => 'Louis',
'Louie' => 'Louis',
'Lucy' => 'Lucille',
'Lucy' => 'Lucinda',
'Mabel' => 'Mehitable',
'Maddie' => 'Madeline',
'Maddy' => 'Madeline',
'Madge' => 'Margaret',
'Maggie' => 'Margaret',
'Maggy' => 'Margaret',
'Mame' => 'Margaret',
'Mame' => 'Mary',
'Mamie' => 'Margaret',
'Mamie' => 'Mary',
'Manda' => 'Amanda',
'Mandy' => 'Amanda',
'Mandy' => 'Samantha',
'Manny' => 'Emanuel',
'Manthy' => 'Samantha',
'Marcy' => 'Marcia',
'Marge' => 'Margaret',
'Marge' => 'Marjorie',
'Margie' => 'Margaret',
'Margie' => 'Marjorie',
'Marty' => 'Martha',
'Marv' => 'Marvin',
'Mat' => 'Mathew',
'Matt' => 'Mathew',
'Matt' => 'Matthias',
'Maud' => 'Magdalene',
'Maud' => 'Matilda',
'Maude' => 'Magdalene',
'Maude' => 'Matilda',
'Maury' => 'Maurice',
'Max' => 'Maximilian',
'Max' => 'Maxwell',
'May' => 'Margaret',
'Meg' => 'Margaret',
'Mel' => 'Melvin',
'Mena' => 'Philomena',
'Merv' => 'Mervin',
'Meta' => 'Margareta',
'Mick' => 'Michael',
'Mickey' => 'Michael',
'Midge' => 'Margaret',
'Mike' => 'Michael',
'Millie' => 'Emeline',
'Milly' => 'Millicent',
'Milt' => 'Milton',
'Mimi' => 'Mary',
'Mimi' => 'Wilhelmina',
'Mina' => 'Wilhelmina',
'Mini' => 'Minerva',
'Minnie' => 'Minerva',
'Mira' => 'Elmira',
'Mira' => 'Mirabel',
'Mischa' => 'Michael',
'Mitch' => 'Mitchell',
'Moll' => 'Martha',
'Moll' => 'Mary',
'Molly' => 'Martha',
'Molly' => 'Mary',
'Mona' => 'Ramona',
'Mort' => 'Mortimer',
'Mort' => 'Morton',
'Morty' => 'Mortimer',
'Morty' => 'Morton',
'Mur' => 'Muriel',
'Myra' => 'Almira',
'Nab' => 'Abel',
'Nabby' => 'Abigail',
'Nacho' => 'Ignacio',
'Nadia' => 'Nadine',
'Nan' => 'Ann',
'Nan' => 'Hannah',
'Nan' => 'Nancy',
'Nana' => 'Ann',
'Nana' => 'Hannah',
'Nana' => 'Nancy',
'Nate' => 'Nathan',
'Nate' => 'Nathaniel',
'Ned' => 'Edmund',
'Ned' => 'Edward',
'Ned' => 'Norton',
'Neely' => 'Cornelia',
'Neil' => 'Cornelius',
'Neil' => 'Edward',
'Nell' => 'Cornelia',
'Nell' => 'Eleanor',
'Nell' => 'Ellen',
'Nell' => 'Helen',
'Nellie' => 'Helen',
'Nelly' => 'Cornelia',
'Nelly' => 'Eleanor',
'Nelly' => 'Helen',
'Nessie' => 'Agnes',
'Nettie' => 'Jeanette',
'Netty' => 'Henrietta',
'Nicie' => 'Eunice',
'Nick' => 'Dominic',
'Nick' => 'Nicholas',
'Nicy' => 'Eunice',
'Nikki' => 'Nicole',
'Nina' => 'Ann',
'Nita' => 'Anita',
'Nita' => 'Juanita',
'Noni' => 'Ione',
'Noni' => 'Nora',
'Noni' => 'Eleanor',
'Noni' => 'Elnora',
'Nora' => 'Eleanor',
'Nora' => 'Elnora',
'Nora' => 'Honora',
'Norm' => 'Norman',
'Obed' => 'Obediah',
'Ollie' => 'Oliver',
'Ora' => 'Aurillia',
'Ora' => 'Corinne',
'Pablo' => 'Paul',
'Pacho' => 'Francisco',
'Paco' => 'Francisco',
'Paddy' => 'Patrick',
'Pam' => 'Pamela',
'Pancho' => 'Francisco',
'Pat' => 'Martha',
'Pat' => 'Matilda',
'Pat' => 'Patricia',
'Pat' => 'Patrick',
'Patsy' => 'Martha',
'Patsy' => 'Matilda',
'Patsy' => 'Patricia',
'Patty' => 'Martha',
'Patty' => 'Matilda',
'Patty' => 'Patricia',
'Peg' => 'Margaret',
'Peggy' => 'Margaret',
'Penny' => 'Penelope',
'Pepa' => 'Josefa',
'Pepe' => 'Jose',
'Percy' => 'Percival',
'Pete' => 'Peter',
'Phelia' => 'Orphelia',
'Phil' => 'Philip',
'Polly' => 'Mary',
'Polly' => 'Paula',
'Prissy' => 'Priscilla',
'Prudy' => 'Prudence',
'Quil' => 'Aquilla',
'Quillie' => 'Aquilla',
'Rafe' => 'Raphael',
'Randy' => 'Miranda',
'Randy' => 'Randall',
'Randy' => 'Randolph',
'Rasmus' => 'Erasmus',
'Ray' => 'Raymond',
'Reba' => 'Rebecca',
'Reg' => 'Reginald',
'Reggie' => 'Reginald',
'Rena' => 'Irene',
'Rich' => 'Richard',
'Rick' => 'Eric',
'Rick' => 'Frederick',
'Rick' => 'Garrick',
'Rick' => 'Patrick',
'Rick' => 'Richard',
'Rita' => 'Clarita',
'Rita' => 'Margaret',
'Rita' => 'Margarita',
'Rita' => 'Norita',
'Rob' => 'Robert',
'Rod' => 'Roderick',
'Rod' => 'Rodney',
'Rod' => 'Rodrigo',
'Rodie' => 'Rhoda',
'Ron' => 'Aaron',
'Ron' => 'Reginald',
'Ron' => 'Ronald',
'Ronnie' => 'Veronica',
'Ronny' => 'Ronald',
'Rosie' => 'Rosalind',
'Rosie' => 'Rosemary',
'Rosie' => 'Rosetta',
'Roxy' => 'Roxanne',
'Roy' => 'Leroy',
'Rudy' => 'Rudolph',
'Russ' => 'Russell',
'Sadie' => 'Sally',
'Sadie' => 'Sarah',
'Sal' => 'Sarah',
'Sally' => 'Sarah',
'Sam' => 'Samuel',
'Sandy' => 'Alexander',
'Sandy' => 'Sandra',
'Sene' => 'Asenath',
'Senga' => 'Agnes',
'Senie' => 'Asenath',
'Sherm' => 'Sherman',
'Si' => 'Cyrus',
'Si' => 'Matthias',
'Si' => 'Silas',
'Sibella' => 'Isabella',
'Sid' => 'Sidney',
'Silla' => 'Drusilla',
'Silla' => 'Priscilla',
'Silvie' => 'Silvia',
'Sis' => 'Cecilia',
'Sis' => 'Frances',
'Sissy' => 'Cecilia',
'Sol' => 'Solomon',
'Stacia' => 'Eustacia',
'Stacy' => 'Anastasia',
'Stacy' => 'Eustacia',
'Stan' => 'Stanislas',
'Stan' => 'Stanly',
'Stella' => 'Estella',
'Stella' => 'Esther',
'Steve' => 'Steven',
'Steven' => 'Stephen',
'Stew' => 'Stewart',
'Sue' => 'Susan',
'Sue' => 'Suzanne',
'Sukey' => 'Suzanna',
'Susie' => 'Susan',
'Susie' => 'Suzanne',
'Suzy' => 'Susan',
'Suzy' => 'Suzanne',
'Tad' => 'Edward',
'Tad' => 'Thadeus',
'Ted' => 'Edmund',
'Ted' => 'Edward',
'Ted' => 'Theodore',
'Teddy' => 'Edward',
'Teddy' => 'Theodore',
'Telly' => 'Aristotle',
'Terry' => 'Theresa',
'Terza' => 'Theresa',
'Tess' => 'Elizabeth',
'Tess' => 'Theresa',
'Theo' => 'Theobald',
'Theo' => 'Theodore',
'Tia' => 'Antonia',
'Tibbie' => 'Isabella',
'Tilda' => 'Matilda',
'Tilly' => 'Matilda',
'Tilly' => 'Otilia',
'Tim' => 'Timothy',
'Timmy' => 'Timothy',
'Tina' => 'Albertina',
'Tina' => 'Augustina',
'Tina' => 'Christina',
'Tina' => 'Christine',
'Tina' => 'Earnestine',
'Tina' => 'Justina',
'Tina' => 'Martina',
'Tish' => 'Letitia',
'Toby' => 'Tobias',
'Tom' => 'Thomas',
'Tony' => 'Anthony',
'Tracy' => 'Theresa',
'Trina' => 'Katherina',
'Trixie' => 'Beatrice',
'Trudi' => 'Gertrude',
'Trudy' => 'Gertrude',
'Ursie' => 'Ursula',
'Ursy' => 'Ursula',
'Vangie' => 'Evangeline',
'Vern' => 'Vernon',
'Vi' => 'Viola',
'Vi' => 'Violet',
'Vic' => 'Victor',
'Vicky' => 'Victoria',
'Vin' => 'Galvin',
'Vin' => 'Vincent',
'Vina' => 'Alvina',
'Vina' => 'Lavina',
'Vinny' => 'Vincent',
'Virg' => 'Virgil',
'Virgie' => 'Virginia',
'Viv' => 'Vivian',
'Vonnie' => 'Yvonne',
'Wally' => 'Wallace',
'Wally' => 'Walter',
'Walt' => 'Walter',
'Web' => 'Webster',
'Wendy' => 'Gwendolen',
'Wes' => 'Wesley',
'Will' => 'William',
'Willie' => 'Wilhelmina',
'Willy' => 'William',
'Winn' => 'Edwin',
'Winnie' => 'Edwina',
'Winnie' => 'Winifred',
'Woody' => 'Woodrow',
'Xina' => 'Christina',
'Yost' => 'Josef',
'Zac' => 'Isaac',
'Zach' => 'Zachariah',
'Zak' => 'Isaac',
'Zeb' => 'Zebulon',
'Zed' => 'Zedekiah',
'Zeke' => 'Ezekiel',
'Zena' => 'Albertina',
'Zeph' => 'Zephaniah'
);
my %ABBREVIATIONS;
my %ABBREVIATIONS_LC;
setNameAbbreviations(@ABBREVIATIONS);

my $AND = '(?:\s+(?:and|&|&amp;|with)\s+)';
my $MERE_COMMA = '(?:\s*,\s*)';
my $MERE_SEMI = '(?:\s*(?:;|<br>|<p>|<\/p>)\s*)';
my $SEMI_AND = "(?:$MERE_SEMI|$AND)";
my $COMMA_AND = "(?:$MERE_COMMA$AND|$AND|$MERE_COMMA)";
my $SPACE = '(?:\s|\&nbsp;|\n|\r)';
my @NAME_PREFIXES_RE;
for (my $i=0; $i<=$#NAME_PREFIXES; $i++) {
    $NAME_PREFIXES_RE[$i] = '(?:$|^|\W)' . $NAME_PREFIXES[$i] . '(?:$|^|\W)';
}
my $PREFIXES = "(?:" . join('|',@NAME_PREFIXES_RE) . ")";

sub setNameAbbreviations {
    while (my $a = shift @_) {
        my $b = shift;
        $ABBREVIATIONS{$a} ||= {};
        $ABBREVIATIONS{$a}->{$b} = 1;
        $ABBREVIATIONS_LC{lc $a} ||= {};
        $ABBREVIATIONS_LC{lc $a}->{lc $b} = 1;
    }
}

sub getNameAbbreviations {
    return \%ABBREVIATIONS;
}

sub reverseName {
    my @n = split(/,\s*/,shift());
    return "$n[1] $n[0]";
}

sub composeName {
    my ($given,$last) = @_;
    my $r = $last;
    $r .= ", $given" if $given;
    return $r;
}


sub normalizeNameWhitespace {

    my $in = shift;

    #print "in: $in\n";
    # this used to be optional, but then we never know in advance
    #my $initialsCanBeLowerCase = shift;
    #if ($initialsCanBeLowerCase) {
        $in =~ s/\b([a-z])\b/uc $1/ge;
    #}


    $in =~ s/^\s+//g; # remove initial spaces
    $in =~ s/\s+$//g; # remove term spaces
    $in =~ s/\s+,/,/g; # remove spaces before coma
    $in =~ s/,\s*/, /g; # normalize spaces after coma
    $in =~ s/\.\s*([A-Z])/. $1/g; # adjust spacing between initials
    #print "in: $in\n";
    $in =~ s/([A-Z])\.\s([A-Z])\./$1. $2./g;
    $in =~ s/\b([A-Z])\b(?![\.'])/$1./g;
    while ($in =~ s/([\.\s][A-Z])(\s|$)/$1.$2/g) {};
    $in =~ s/\.\s*([A-Z])/. $1/g; # adjust spacing between initials

    #print "normalized: $in\n";
    $in;

}
sub parseName {
 	my $in = shift;

 	#print "-->parseName in: $in\n";
    
    $in =~ s/^\s*and\s+//; 
    my $jr = ($in =~ s/,?\sJr\.?(\s|$)//i);
    $in =~ s/^\s*by\s+//;
    $in =~ s/\W*et\.? al\.?\W*//;
    $in =~ s/\.\s*$//; # remove . at the end
 	#print "$in -->";
    $in = normalizeNameWhitespace($in);
    #print "name cleaned:'$in'\n";

    # check if we have a case of Lastname I. without comma
    if ($in=~ /^([^,]+?\s)+?((?:[A-Z][\-\.\s]{0,2}){1,3})$/) {
        
        #warn "Got a reversed name without comma";
        my $init = $2;
        my $rest = $1;
        #print "\n\nmatched, rest:$rest--$2\n";
        # add . as needed
#        if ($init !~ /\./) {
            $init =~ s/([A-Z])([^.]|$)/$1.$2/g;
            $init =~ s/([A-Z])([^.]|$)/$1.$2/g;
#        }
        $rest =~ s/\s$//;
        $in = normalizeNameWhitespace("$rest, $init");
    } elsif ($in =~ /^[^,]+\s\w\.?$/) {
        #print "case\n";
        $in =~ s/^(.+?)\s((?:[A-Z]\.?-?\s?){1,3})$/$1,$2/;
    } 
    #print "now:$in\n";
    # standard cases
 	if ($in =~ /(.*),\s*(.*)/) {
    	return ($2, $1);
 	} else {
	 	my @bits = split(' ',$in);
        if ($#bits == -1) {
            return ($in,"");
        }
        my $lastname = splice(@bits,-1,1);
        if ($lastname =~ /^Jr\.?$/i and $#bits > -1) {
            $lastname = $bits[-1] . " $lastname";
            splice(@bits,-1,1);
        }
        $lastname = "$lastname Jr" if $jr;
        # add prefixes or Jr to lastname
        #warn join(" - ",@bits);
        while (defined $bits[-1] and $bits[-1] =~ /^$PREFIXES$/i) {
            #warn "GOT PREFIX: $bits[-1]";
            $lastname = splice(@bits,-1,1) . " $lastname";
        }
        return (join(' ',@bits),$lastname);
		#my $firstname = splice(@bits,0,1);
		#while ($#bits > -1 and $bits[0] =~ /^\s*\w\.?\s*$/) {
        # 	$firstname .= " ".splice(@bits,0,1);
		#}
		#my $lastname = join(' ', @bits);
		#return ($firstname, join(' ',@bits));
 	}

}

sub parseNames {

    my $in = shift;
    my $reverse = shift; # means names are stupidly written like this: David, Bourget
    while($in =~ s/(^|\W)(dr|prof\.? em\.?|prof|profdr|prof|sir|mrs|ms|mr)\.?(\W)/$1 $3/gi) {}
    $in =~ s/^\s+//;
    $in =~ s/([^A-Z]{2,2})\.\s*/$1/; # remove . at the end
    $in =~ s/\(.+\)\s*$//; # remove trailing parens
    $in =~ s/(,\s*)?\d\d\d\d-$//;
    $in =~ s/^\s*[bB]y(\W)/$1/; #remove "By ";
    $in =~ s/,?\s*et\.? al\.?\s*$//; # et al
    $in =~ s/^\W+//;

    #print "== $in\n";
    # semi-colon separated
    if ($in =~ /;/) {
        return parseNameList(split(/$SEMI_AND/i,$in),$reverse);
    } 
    
    # no comma and no semi-colon, so one or two not-reversed names 
    elsif ($in !~ /,/) {
        return parseNameList(split(/$AND/i,$in),$reverse);
    } 
   
    # now that's messy: one or more commas, no semi
    else {

        # is there a "and"?
        #print "$in\n";
        if ($in =~ /$AND/i) {

            #print "AND:$in\n";
            # now we check for double duty for commas
            # We fix what would be missing commas on this hypothesis
            my $t = $in;
            $t =~ s/([a-z])\s+([A-Z])(\.|\s|$)/$1, $2$3/g;
            # we check if it's a silly case of commas playing double duty
            if ($t =~ /,.+,.+,.+$AND/) {
                #print "SILLY: $t\n";
                my @to;
                my @tokens = split(/$COMMA_AND/i,$t);
                for (my $ti=0; $ti <= $#tokens;$ti+=2) {
                    push @to, join(", ",@tokens[$ti..$ti+1]); 
                }
                return parseNameList(@to,$reverse);
            } 

            # no silliness. what's after the AND will tell us the format 
            # if there's a comma after, it's probably reversed
            if ($in =~ /$AND.*,/i) {

                return parseNameList(split(/$SEMI_AND/i,$in),$reverse);
            } 

            # if there is no comma after, it's not-reversed, comma separated.  
            else {
                return parseNameList(split(/$COMMA_AND/i,$in),$reverse);
            }

        } else {
            #print "- no and\n";
            # no semi, no and, and one or more comma
            # if 2 or more commas
            if ($in =~ /,.+,/) {
                # need to check if this is a silly case of commas with reversed names
                # check that by looking for two or more ,token, with only one part, and odd number of ,
                my @tokens = split(/$MERE_COMMA/i,$in);
                my $silly = 0;
                for my $tok (@tokens) {
                    $silly++ unless $tok =~ m/[\w\.]$SPACE[\w\.]/i;
                }
                # if silly combination, every other comma separates two names
                if ($silly >=2 and $#tokens %2 ==1) {
                    my @to;
                    for (my $ti=0; $ti <= $#tokens;$ti+=2) {
                        push @to, join(", ",@tokens[$ti..$ti+1]); 
                    }
                    @tokens = @to;
                } 
                return parseNameList(@tokens,$reverse);
            }
            # else, one comma, no semi, and no and
            else {
                # now that's ambiguous between "Doe, John" and "John Doe, John Doe"
                # but we assume there are no names like "Herrera Abreu, Maria Teresa"
                # (which there are, this is a real one). that is, if the comma separates
                # two tokens on each side (not counting de,di,von, etc.), we suppose
                # these tokens make distinct names
                my @toks = split(/,/,$in);
                my @copy = @toks;
                foreach (@copy) {
                    s/$PREFIXES|(\WJr(\W|$))/ /ig;
                    my @bits = split(' ',$_);
                    if ($#bits <= 0) {
                        # found one side with only one non-trivial token
                        # so there is only one author in $in
                        return parseNameList(($in),$reverse);
                    }
                }
                return parseNameList(@toks,$reverse);
            }
        }

    }

	return ();
}

sub parseNameList {
    my @auths;
    #print "Got: " . join("---", @auths) . "\n";
    my $reverse;
    if (defined($_[-1]) and $_[-1] eq 'reverse') {
        pop @_; 
        $reverse = 1;

    }
    foreach my $a (@_) {
        next unless $a;
        my ($f,$l) = parseName($a);
        push @auths, ($reverse ? "$f, $l" : "$l, $f");
    }
    return @auths;
}

sub parseName2 {
    my $in = shift;
    my ($i,$s);
    my ($l,$f) = split(/,\s*/,$in);
    # get suffix
    if ($l =~ s/\s+(Jr\.?|[IV]{2,10})\s*$//) {
        $s = $1;
    }
    #print "f: $f\nl:$l\n";
    # separate firstname/initial
    # if has only initials
    if ($f =~ /^\s*([A-Z](?:\.|\s|$))(.+)$/) {
       $f = $1;
       $i = $2; 
       $i =~ s/^\s*//;
    } 
    # has a full firstname
    else {
        if ($f =~ /^([^\s]+?)\s+((?:[A-Z](?:\.|\s+|$)\s*)+)$/) {
            $f = $1; 
            $i = $2;
        }
    }
    return ($f,$i,$l,$s);
}


sub abbreviationOf {
    my ($a,$b) = @_;
    return 0 unless $ABBREVIATIONS_LC{lc $a};
    return $ABBREVIATIONS_LC{lc $a}->{lc $b} ? 1 : 0;
}

# if the two names passed as params are such that they could belong to the same person, returns a merged name
sub samePerson {
 	my ($a,$b) = @_; #name1,name2
	my $a_expd = 0;
	my $b_expd = 0;
	my ($lasta,$firsta) = split(',',cleanName($a,' ','reparse'));
	my ($lastb,$firstb) = split(',',cleanName($b,' ','reparse'));
	#print "here '$lasta'-'$lastb'\n";
    $lasta =~ s/\s+Jr\.?$//;
    $lastb =~ s/\s+Jr\.?$//;
	return undef unless lc $lasta eq lc $lastb;
=old
	# regimentation
	$firsta =~ s/\./ /g;
	$firstb =~ s/\./ /g;
	$firsta =~ s/\s+/ /g;
	$firstb =~ s/\s+/ /g;
=cut
	my @at = split(" ",$firsta || '');
	my @bt = split(" ",$firstb || '');
	#print "AT: " . join("-",@at) . "\n";
	#print "BT: " . join("-",@bt) . "\n";
	# compare each token pair as follows:
	# if reached the end of tokens on either side, compat
	# if both are greater than 1 char and diff, not compat
	# if they don't start by the same letter, not compat
	# else merge the tokens, compat so far, move on to next token pair
	#
	my $merged = "$lasta,";
	for (my $i=0; $i <= $#at || $i <= $#bt; $i++) {
		#print "$i ($merged):" . $at[$i] . "-" . $bt[$i]. "-\n";
		# end of tokens reached on one side

		if ($i > $#at) {
			#print "END ($merged)\n";
			#return undef if $b_expd;
			$merged .= " ". join(" ",@bt[$i..$#bt]);
			return cleanName($merged,'');
		} elsif ($i > $#bt) {
			#print "END ($merged)\n";
			#return undef if $a_expd;
			$merged .= " ". join(" ",@at[$i..$#at]);
			return cleanName($merged,'');
		}
		# if different tokens 
		if ($at[$i] ne $bt[$i]) {

			# if different first letters, not compat
			return undef if (lc substr($at[$i],0,1) ne lc substr($bt[$i],0,1));

			# otherwise they might be compatible 
			
			# token a is full word
			if (length($at[$i]) > 2) {
				# b is too, they are not compat unless one is a short for the other
				if (length($bt[$i]) > 2) { 
					if ( abbreviationOf($at[$i],$bt[$i]) ) {
						$merged .= " " . $bt[$i];
						next;
					} elsif ( abbreviationOf($bt[$i],$at[$i]) ) {
						$merged .= " " . $at[$i];
						next;
					} else {
						return undef;
					}
				} 
				# b is initial, they are compat so far
				else {
					$b_expd = 1;
					$merged .= " " . $at[$i];
				}
			# a is initial
			} else {
				# b is full word 
				$a_expd = 1 if length($bt[$i]) > 2;
				# keep going
				$merged .= " " . $bt[$i];
			}
			
		}
		# otherwise move on to next token pair straight
		else {
			$merged .= " " .$at[$i];
		}
	}
	# if we get there, the two names are compatible and $merged contains the richest name from the two
#	print "merged: $merged\n";
	return cleanName($merged,'');
   
}

sub cleanParseName {
    my $n = shift;
    # I think that one is overkill..
    return parseName(cleanName(composeName(parseName($n))));
}

sub cleanName {
	my ($n, $space, $reparse) = @_;

    # Some of the cleaning-up here is redundant because also in parseName, which is called last. But it doesn't hurt.. If it works don't try and fix it.

    #print "Cleaning name: $n\n";

    # if ", john doe"
    if ($n =~ s/^\s*,\s+//) { }

    # if 'john doe,'
    if ($n =~ s/^([^,]+?)\s*,\s*$/$1/) { }

    $n =~ s/Get checked abstract//g;
    $n = rmTags($n);
    $n =~ s/, By$//i;
    #if ($reparse and $n =~ s/,/) {
    #    my ($l,$f) = split(/,\s*/,$n);
    #    my ($f,$l) = parseName(join(' ',($f,$l)));
    #    $n = "$l, $f";
    #}

    # Fix for O'Something => O.'Something
    #$n =~ s/O\.'/O'/;

    $n =~ s/[\r\n]/ /gsm;
    $n =~ s/(\w)\s*,/$1,/g;
	$n =~ s/([a-z]{2,})\./$1/gi; #remove unwanted .
	$n =~ s/(\W|\.|\s)([A-Z])(\s|$)/$1$2.$3/g; #add . to initials
	$n =~ s/(\W|\.|\s)([A-Z])(\s|$)/$1$2.$3/g; #add . to initials (repeat for overlaps)
	$n =~ s/\.\s*([A-Z])/". " . uc $1/ieg; # adjust spacing between initials
	$n =~ s/\W*\d{4,4}\W*//g; # misplaced dates
	$n =~ s/\(.*$//; #parentheses
	# misplaced jr
	$n =~ s/([\w'-])\s*,(.*)\sJr(\s.*|$)/$1 Jr,$2 $3/i;
	# misplaced prefixe
    #warn $n;
	#$n =~ s/([\w'-])\s*,(.*)\s(van|von|von\sder|van\sder|di|de|del|du|da)(\s.*|$)/(lc $3) . $1 . "," . $2 . $4/ie;
    #warn $n;
    # replace Iep by UNKNOWN
    $n =~ s/^Iep,$/Unknown, Unknown/;
    #links aren't names
    $n = "Unknown, Unknown" if $n =~ /http:\/\//;

	# de-expand middle names 
	# TODO more elegant regexp that doesn't have to be repeated to get all middle names?
	#$n =~ s/(,\s*[A-Z][\w'-]+\s+.*?[A-Z])[\w'-]+(\s*)/$1.$2/g;
	#$n =~ s/(,\s*[A-Z][\w'-]+\s+.*?[A-Z])[\w'-]+(\s*)/$1.$2/g;
	#$n =~ s/(,\s*[A-Z][\w'-]+\s+.*?[A-Z])[\w'-]+(\s*)/$1.$2/g;

   	#print "res: $n\n";
 # capitalize if nocaps
    if ($n !~ /[A-Z]/) {
        $n = capitalize($n,notSentence=>1);#_title($n, PRESERVE_ANYCAPS=>1, NOT_CAPITALIZED=>\@PREFIXES);	
    }

	#print "pos caps: $n\n";
    $n = composeName(parseName($n));
    # now final capitalization
    $n = capitalize($n,notSentence=>1); #,PRESERVE_ANYCAPS=>1, NOT_CAPITALIZED=>\@PREFIXES);	
    return $n;
}

sub weakenings {
    my( $firstname, $lastname ) = @_;
    my @warnings;
    # default firstname aliases: every middle name can be either in full, initialized, or absent
    my @first_parts = split(/\s+/,normalizeNameWhitespace($firstname));
    my $reduced = 0;
    if( scalar @first_parts > 3 ){
        $reduced = 1;
        splice( @first_parts, 3 ); 
        push @warnings, "Too many parts in first name: '$firstname'\n";
    }
    my $first = shift @first_parts;
    for my $i (0..$#first_parts) {
        my $value = $first_parts[$i];
        $first_parts[$i] = [$value]; # the default value is good
        # try downgrading to initial
        push @{$first_parts[$i]}, $value if ($value =~ s/(\w)[^\s\.]+/$1./);
    }
    my @first_aliases = ( $first );
    push @first_aliases, "$1." if $first =~ /(\w)[^\s\.]+/;
    #print Dumper(\@first_parts);
    for my $i (0..$#first_parts) {
        my @new;
        for my $current (@first_aliases) {
            for (@{$first_parts[$i]}) {
                push @new, "$current $_";
            }
            push @new, $current;
        }
        @first_aliases = @new;
    }
    #print Dumper(\@first_aliases);
    $lastname = normalizeNameWhitespace($lastname);
    my @prefixes = map "\\b$_\\b", @NAME_PREFIXES, 'y', 'los';
    my $prefixes = join '|', @prefixes;
    $lastname =~ s/($prefixes) /$1+/ig;
    my @parts = reverse ( ( split(/\s+/,$lastname) ) );
    my @last_aliases;
    my $lastlast = shift @parts;
    for my $variation ( variations( $lastlast ) ){
        push @last_aliases, $variation;
    }
    if( scalar @parts < 3 ){
        for my $lpart ( @parts ){
            my @curr = @last_aliases;
            for my $variation ( variations( $lpart ) ){
                for my $alias ( @curr ){
                    next if $variation =~ /-/ && $alias =~ / /;
                    next if $variation =~ / / && $alias =~ /-/;
                    push @last_aliases, "$variation $alias" if $variation !~ /-/ && $alias !~ /-/;
                    push @last_aliases, "$variation-$alias" if $variation !~ / / && $alias !~ / /;
                }
            }
        }
    }
    else{
        push @warnings, "Too many parts in last name: '$lastname'\n";
        push @last_aliases, $lastname;
    }
    my @aliases;
    unshift @first_aliases, $firstname if $reduced;
    ALIAS:
    for my $f ( @first_aliases ) {
        for my $l (@last_aliases) {
            push @aliases, { firstname => $f, lastname => $l };
            if( scalar @aliases > 25 ){
                push @warnings, 'More than 25 aliases';
                last ALIAS;
            }
        }
    }
    return \@warnings, @aliases;
}

sub variations {
    my $part = shift;
    my @parts = split /\+/, $part;
    if( scalar @parts <= 1 ){
        return $part;
    }
    else{
        return join( ' ', @parts ), $parts[-1];
    }
}

sub rmTags {
    my $in = shift;
    while ($in =~ s/(<|(?:\&lt;))\/?[^>]*?(>|(?:\&gt;))/ /g) {};
    return $in;
}

sub capitalize {
    my $txt = shift;
    my %args = @_; 
    #print "bef: $txt\n";
    my $t = capitalize_title($txt, PRESERVE_ANYCAPS=>1);
    if ($args{notSentence}) {
        $t =~ s/^($PREFIXES)/lc $1/ie;
    }
    #fix for bug in text::capitalize
    $t =~ s/&Quot;?(\.?)$/&quot;$1/g;

    return $t;
}


1;
__END__

=head1 NAME

Text::Names - Perl extension for name parsing and normalization

=head1 SYNOPSIS

    use Text::Names qw/parseNames samePerson/;

    my @authors = parseNames("D Bourget, Zbigniew Z Lukasiak and John Doe");

    # @authors = ('Bourget, D.','Lukasiak Z., Zbigniew','Doe, John')

    print "same!" if samePerson("Dave Bourget","David F. Bourget");

    # same!

=head1 DESCRIPTION

This modules provides a number of name normalization routines, plus high-level parsing and name comparison utilities such as those illustrated in the synopsis.

While it tries to accommodate non-Western names, this module definitely works better with Western names, especially English-style names.

No subroutine is exported by default.

This modules normalizes names to this format:

Lastname(s) [Jr], Given name(s)

=head1 SUBROUTINES

=head2 parseNames(string names): array

Takes a string of names as parameters and returns an array of normalized representations of the names in the string. This routines understands a wide variety of formattings for names and lists of names. 

=head2 parseNameList(array names): array

Takes an array of names (as strings) and returns an array of normalized representations of the names in the array.

=head2 parseName(string name): string

Takes a name in one of the multiple formats that one can write a name in, and returns it in a normalized form.

=head2 cleanName(string name): string

Likes parseName, but does additional cleaning-up. To be prefered to parseName in most cases.

=head2 parseName2(string name): array

Use on already-normalized names to split them into four parts: full given names, initials, last names, and suffix. The only 'suffix' recognied is 'Jr'.

=head2 abbreviationOf(string name1,string name2): boolean

Returns true iff name1 is a common abbreviation of name2 in English. For example, 'Dave' is a common abbreviation of 'David'. The list of abbreviations used includes a number of old abbreviations such as 'Davy' for 'David'.

=head2 setAbbreviations(array): undef

Sets the abbreviation mapping used to determine whether, say, 'David' and 'Dave' are compatible name parts. The mapping is also use by abbreviationOf(). The format of the array should be: 'Dave', 'David', 'Davy', 'David', etc, otherwise representable in Perl as 'Dave' => 'David', 'Davy' => 'David', etc.

=head2 weakenings(string name): array

Returns an array of normalizations names which are weakenings of the name passed as argument. Substituting a given names by an initial, or removing an initial, for example, are operations which generate weakenings of a name. Such operations are applied with arbitrary depth, until the name has been reduced to a single initial followed by the lastname, and all intermediary steps returned. 

=head2 samePerson(string name1, string name2): string

Returns a true value iff name1 and name2 could reasonably be two writings of the same name. For example, 'D J Bourget' could reasonably be a writing of 'David Joseph Bourget'. So could 'D Bourget'. But 'D F Bourget' is not a reasonable writing of 'David Joseph Bourget'. The value returned is a (potentially new) name string which combines the most complete tokens of the two submitted name strings.

Contrary to what one might expect, this subroutine does not use weakenings() behind the scenes. Another way to check for name compatibility would be to check that two names have a weakening in common (probably too permissive for most purposes) or that one name is a weakening of the other.

=head2 composeName(string given, string last): string

Returns the name in the "last, given" format.

=head2 reverseName(string name): string

Given a normalized name of the form "last, given", returns "given last".

=head2 normalizeNameWithspace(string name): string

Normalizes the withspace within a name.

=head2 EXPORT

None by default.

=head1 SEE ALSO

The xPapers application framework from which this has been extracted, www.xpapers.org

The related L<Biblio::Citation::Compare> module.

=head1 AUTHOR

David Bourget

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by David Bourget

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.1 or,
at your option, any later version of Perl 5 you may have available.


=cut
