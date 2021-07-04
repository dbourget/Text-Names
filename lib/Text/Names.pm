package Text::Names;

use 5.0;
use strict;
use warnings;
use Text::Capitalize qw(capitalize_title @exceptions);
use Text::LevenshteinXS qw(distance);
use Unicode::Normalize;
use utf8;


require Exporter;

our @ISA = qw(Exporter);

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
    isCommonSurname
    isCommonFirstname
    guessGender
    firstnamePrevalence
    surnamePrevalence
    isMisparsed
    isLikelyMisparsed
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = ();

our $VERSION = '0.46';


#
# Follows a ton of data this module uses and makes available
# Search for 'CODE' (all caps) to skip ahead to the code
#

our @NAME_PREFIXES = qw(de di du da le la van von der den des ten ter y e);

@Text::Capitalize::exceptions = qw(
     a an the as s
     on is its für à les des au aux o y
     and or nor for but so yet 
     to of by at for but in with has
     quot amp
  );
push @Text::Capitalize::exceptions, @NAME_PREFIXES;

my $APOST = "(?:’|')";

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
'Phil' => 'Phillip',
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


#
# CODE STARTS HERE
#

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

our %commonSurnames;
our %commonMaleFirstnames;
our %commonFemaleFirstnames;
our $namesInitialized = 0;
# These three variables initialized below
my $COMMON_SURNAMES;
my $COMMON_MALE_FIRSTNAMES;
my $COMMON_FEMALE_FIRSTNAMES;

sub firstnamePrevalence {
    my $name = uc shift;
    prepareCommonNames() unless $namesInitialized; 
    return (($commonMaleFirstnames{$name} || 0) + ($commonFemaleFirstnames{$name} || 0))/2;
}
sub surnamePrevalence {
    my $name = uc shift;
    prepareCommonNames() unless $namesInitialized; 
    return $commonSurnames{$name} || 0;
}

sub isCommonFirstname {
    my ($name, $percentLimit) = @_;
    $percentLimit ||= 0;
    return firstnamePrevalence($name) > $percentLimit;
}
sub isCommonSurname {
    my ($name, $percentLimit) = @_;
    $percentLimit ||= 0;
    return surnamePrevalence($name) > $percentLimit;
}

sub isMisparsed {
    my ($name) = @_;
    $name = lc $name;
    return 1 if $name !~ /\w.*,.*\w/;
    for my $prefix ((@NAME_PREFIXES,'dr','dr.','prof','prof.','jr','jr.')) {
        #warn "check prefix: $prefix";
        return 1 if $name =~ /\b$prefix$/i;        
    }
    return 1 if $name =~ /^\w\b/;
    return 0;
}

sub isLikelyMisparsed {
    my ($name) = @_;
    my @parts = parseName2($name);
    for my $p (@parts) {
        next unless $p;
        my @sub_parts = split(/\s+/,$p);
        return 1 if $#sub_parts >= 2; # three or more subparts likely a mess
    }
    # also likely misparsed if firstname containg a likely lastname AND surname contains a likely firstname
    my @firstname_parts = split(/\s+/, $parts[0]);
    my @first_surname = grep { isCommonSurname($_) } @firstname_parts;
    my @surname_parts = split(/\s/, $parts[2]);
    my @surname_first = grep { isCommonFirstname($_) } @surname_parts;
    return 1 if $#first_surname > -1 and $#surname_first > -1;
    return isMisparsed($name);

}




my $fem_ending = qr/(ette|ne|a)$/i;

sub guessGender {
    my ($name) = @_;
    $name = uc $name;
    prepareCommonNames() unless $namesInitialized; 
    # extract firstname part if necessary
    if ($name =~ /[,\s]/) {
       my @parts = parseName($name);
       $name = $parts[0];
    }

    my $fscore = $commonFemaleFirstnames{$name};
    my $mscore = $commonMaleFirstnames{$name};
    return undef if !($fscore || $mscore);
    return 'F' if $fscore and !$mscore;
    return 'M' if $mscore and !$fscore;
    #warn "M: $mscore vs F: $fscore";

    my $threshold = 20;

    # now the name exist in both. we make a decision if the percentage is very different
    # now in both
    return 'F' if $fscore / $mscore >= $threshold;
    return 'M' if $mscore / $fscore >= $threshold;

    # adjust threashold based on common female name endings
    my $fem_end = ($name =~ $fem_ending);
    if ($fem_end) {
        return 'F' if $fscore / $mscore >= ($threshold/4);
    } else {
        return 'M' if $mscore / $fscore >= ($threshold/4);
    }

    return undef;
}

sub prepareCommonNames {
    for my $n (split(/\n/,$COMMON_SURNAMES)) {
        next unless $n =~ /^(.+?)\s+(.+?)\s/;
        $commonSurnames{uc $1} = $2;
    }
    for my $n (split(/\n/,$COMMON_MALE_FIRSTNAMES)) {
        next unless $n =~ /^(.+?)\s+(.+?)\s/;
        $commonMaleFirstnames{$1} = $2;
    }
    for my $n (split(/\n/,$COMMON_FEMALE_FIRSTNAMES)) {
        next unless $n =~ /^(.+?)\s+(.+?)\s/;
        $commonFemaleFirstnames{$1} = $2;
    }
    $namesInitialized = 1;
}

sub reverseName {
    my $n = shift();
    return undef unless defined($n);
    my @n = split(/,\s*/,$n);
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
    
    return undef unless defined $in;
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
    $in =~ s/\b([A-Z])\b(?![\.'’])/$1./g;
    while ($in =~ s/([\.\s][A-Z])(\s|$)/$1.$2/g) {};
    $in =~ s/\.\s*([A-Z])/. $1/g; # adjust spacing between initials

    #print "normalized: $in\n";
    $in;

}
sub parseName {
 	my $in = shift;

    return undef unless defined $in;
 	#print "-->parseName in: $in\n";
    
    $in =~ s/^\s*and\s+//; 
    my $jr = ($in =~ s/,?\sJr\.?(\s|$)//i);
    $in =~ s/^\s*by\s+//;
    $in =~ s/\W*et\.? al\.?\W*//;
    $in =~ s/\.\s*$//; # remove . at the end
 	#print "$in -->";
    $in = normalizeNameWhitespace($in);
    #print "$in'\n";

    # check if we have a case of Lastname I. without comma
    if ($in !~ /,/ and $in=~ /^(.*?\s)((?:[A-Z][\-\.\s]{0,2}){1,3})$/) {
        
        #warn "Got a reversed name without comma: $1, $2";
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
        #print join(" - ", @bits);
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
=crap
        my @surnames = $#bits > 1 ? @bits[1,$#bits] : ($bits[1]);

        #warn "doing " . join(" ",@bits);
        #while ($#bits > 0) {
        #    @surnames = pop @bits; 
        #}
        #my $surname = pop @bits;
        return ($bits[0], join(' ',@surnames));
=cut
 	}

}

sub parseNames {

    my $in = shift;
    my $reverse = shift; # means names are stupidly written like this: David, Bourget
    return undef if !defined $in;
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

            #warn "AND:$in\n";
            # now we check for double duty for commas
            # We fix what would be missing commas on this hypothesis
            my $t = $in;
            $t =~ s/([a-z])\s+([A-Z])(\.|\s|$)/$1, $2$3/g;
            # we check if it's a silly case of commas playing double duty
            if ($t =~ /,.+,.+,.+$AND/) {
                #warn "SILLY: $t\n";
                my @to;
                my @tokens = split(/$COMMA_AND/i,$t);
                for (my $ti=0; $ti <= $#tokens;$ti+=2) {
	                  my @extract = grep { $_ } @tokens[$ti..$ti+1];
                    push @to, join(", ",@extract); 
                }
                return parseNameList(@to,$reverse);
            } 

            # no silliness. what's after the AND will tell us the format 
            # if there's a comma after, it's probably reversed
            if ($in =~ /$AND.*,/i) {
                #warn "AND:$in\n";
                return parseNameList(split(/$SEMI_AND/i,$in),$reverse);
            } 

            else {
                #warn "neither";
                my @parts = split(/$COMMA_AND/i,$in);
                return parseNameList(@parts,$reverse);
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
    #warn "Got: " . join("---", @_) . "\n";
    my $reverse;
    if (defined($_[-1]) and $_[-1] eq 'reverse') {
        pop @_; 
        $reverse = 1;

    }
    # first we correct for overly split names like 'Bourget; D; John Doe'
    my @new;
    #print Dumper(\@_); use Data::Dumper;
    for (@_) {
        # if the part looks like an initial, we add it to the previous name part
        next unless $_;
        if (/^([A-Z](\.|\s|$)\s?)+$/ and $#new > -1) {
            if ($new[-1] =~ /,/) {
                $new[-1] = "$new[-1] $_";
            } else {
                $new[-1] = "$new[-1], $_";
            }
        } else {
            push @new, $_;
        }
    }
    foreach my $a (@new) {
        next unless $a;
        my ($f,$l) = parseName($a);
        #$l =~ s/^\s+//;
        #$f =~ s/^\s+//;
        push @auths, ($reverse ? "$f, $l" : "$l, $f");
    }
    return @auths;
}

sub parseName2 {
    my $in = shift;
    my ($i,$s);
    return ("","") unless defined $in;
    my ($l,$f) = split(/,\s*/,$in);
    $f ||= '';
    $l ||= '';
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
 	my ($a,$b, %opts) = @_; #name1,name2
    return undef if !defined($a) or !defined($b);
	my $a_expd = 0;
	my $b_expd = 0;
	my ($lasta,$firsta) = split(',',cleanName($a,' ','reparse'));
	my ($lastb,$firstb) = split(',',cleanName($b,' ','reparse'));
   # return undef if defined($firsta) and !defined($firstb);
   # return undef if defined($firstb) and !defined($firsta);
   # return undef if defined($lasta) and !defined($lastb);
   # return undef if defined($lastb) and !defined($lasta);
	#print "here '$lasta'-'$lastb'\n";
    $firsta = "" unless defined $firsta;
    $firstb = "" unless defined $firstb;
    $lasta = "" unless defined $lasta;
    $lastb = "" unless defined $lastb;
    $lasta =~ s/\s+Jr\.?$//;
    $lastb =~ s/\s+Jr\.?$//;
    # check for reversed name if loose
    if (!equivtext($lasta,$lastb)) {
        if (!$opts{loose}) {
            return undef;
        } else {
            
            return samePerson("$firsta, $lasta", "$lastb, $firstb", loose=>0) || samePerson("$firsta $lasta","$firstb $lastb", loose=>0);
        }
    }
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
		if (!equivtext($at[$i],$bt[$i])) {

			# if different first letters, not compat
			return undef if !equivtext(substr($at[$i],0,1),substr($bt[$i],0,1));

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

sub equivtext {
    my ($a,$b) = @_;
    #warn "equivtext: $a ~ $b";
    $a = lc rmDiacritics($a); 
    $b = lc rmDiacritics($b);
    $a =~ s/\.\s*$//;
    $b =~ s/\.\s*$//;
    #warn "$a == $b == " . distance($a,$b);
    # we allow one character difference, except for initial tokens. this is because some diacritics change the underlying letter when removed, e.g. Björklund -> Bjarklund, even though one might naturally write 'Bjorklund'
    return (length($a) > 1 && length($b) > 1) ? distance($a,$b) <= 1 : $a eq $b;
}

sub cleanParseName {
    my $n = shift;
    # I think that one is overkill..
    return parseName(cleanName(composeName(parseName($n))));
}

sub cleanName {
	my ($n, $space, $reparse) = @_;

    # Some of the cleaning-up here is redundant because also in parseName, which is called last. But it doesn't hurt.. If it works don't try and fix it.

    return undef unless defined $n;

    #print "Cleaning name: $n\n";

    $n =~ s/\.( \.)+/./g;
    $n =~ s/\.($APOST)/'/g;


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
    # replace Iep by UNKNOWN (for PP)
    $n =~ s/^Iep,$/Unknown, Unknown/;
    #links aren't names
    $n = "Unknown, Unknown" if $n =~ /http:\/\//;

    # name like DavidBourget
    if ($n =~ /(\p{L}*\p{Ll})(\p{Lu})/) {
        #warn $n;
        # don't intervene if there are some spaces or the first stuck bit is 'mac'
        unless ($1 =~ /^(Mac|Mc|$PREFIXES)$/i or $n =~ /[\p{L},\.] \p{L}/ ) {
            $n =~ s/(\p{Ll})(\p{Lu})/$1 $2/g 
        }
    }

    # capitalize if nocaps
    if ($n !~ /[A-Z]/) {
        $n = capitalize($n,notSentence=>1);#_title($n, PRESERVE_ANYCAPS=>1, NOT_CAPITALIZED=>\@PREFIXES);	
    }

    # do we have initials stuck on the surname like so: RawlsJ. 
    unless ($n =~ /,/ or $n =~ /\w \w/) {
        $n =~ s/([A-Z][a-z]{1,})((?:[A-Z](?:$|\.|\s|)\s*)+)\s*$/$1, $2/g;
    }

    #warn "$n";
    #unless it's all caps, the caps are initials. we unstuck them and add .
    if ($n =~ /[a-z]/ and $n !~ /[A-Z]{2,} [A-Z]{2,}/) {
        $n =~ s/(\s|^)([A-Z]{2,3})(\.|\s|$)/$1 . toInitials($2) . $3/ge;
    } else {
    }
    #warn $n;

    my ($f,$l) = parseName($n);

    #warn "** $l, $f";
    #warn "$l, $f";
    $n = composeName($f,$l);
    # now final capitalization
    $n = capitalize($n,notSentence=>1); #,PRESERVE_ANYCAPS=>1, NOT_CAPITALIZED=>\@PREFIXES);	
    return $n;
}

sub toInitials {
    my $s = shift;
    #warn "init: $s";
    return $s if grep { lc $_ eq lc $s } @NAME_PREFIXES;
    $s =~ s/^([A-Z])([A-Z])([A-Z])$/$1. $2. $3./;
    $s =~ s/^([A-Z])([A-Z])$/$1. $2./;
    return $s;

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

sub rmDiacritics {
    my $str = shift;
    my $nstr = ''; 
    for ( $str ) {  # the variable we work on
    ##  convert to Unicode first
    ##  if your data comes in Latin-1, then uncomment:
    #$_ = Encode::decode( 'iso-8859-1', $_ );  
    return "" if !defined $_;
    $_ = NFD( $_ );   ##  decompose
    s/\pM//g;         ##  strip combining characters
    s/[^\0-\x80]//g;  ##  clear everything else
    $nstr .= $_;
    }
    $nstr;
}

sub rmDiacriticsNOTGOOD {

    my $str = shift;
    my $nstr = '';

    #
    # This code (c) Ivan Kurmanov, http://ahinea.com/en/tech/accented-translate.html
    #

    for ( $str ) {  # the variable we work on

        ##  convert to Unicode first
        ##  if your data comes in Latin-1, then uncomment:
        #$_ = Encode::decode( 'iso-8859-1', $_ );  

        s/\xe4/ae/g;  ##  treat characters Ã¤ Ã± Ã¶ Ã¼ Ã¿
        s/\xf1/ny/g;  ##  this was wrong in previous version of this doc    
        s/\xf6/oe/g;
        s/\xfc/ue/g;
        s/\xff/yu/g;

        $_ = NFD( $_ );   ##  decompose (Unicode Normalization Form D)
        s/\pM//g;         ##  strip combining characters

        # additional normalizations:

        s/\x{00df}/ss/g;  ##  German beta â<80><9c>Ã<9f>â<80><9d> -> â<80><9c>ssâ<80><9d>
        s/\x{00c6}/AE/g;  ##  Ã<86>
        s/\x{00e6}/ae/g;  ##  Ã¦
        s/\x{0132}/IJ/g;  ##  Ä²
        s/\x{0133}/ij/g;  ##  Ä³
        s/\x{0152}/Oe/g;  ##  Å<92>
        s/\x{0153}/oe/g;  ##  Å<93>

        tr/\x{00d0}\x{0110}\x{00f0}\x{0111}\x{0126}\x{0127}/DDddHh/; # Ã<90>Ä<90>Ã°Ä<91>Ä¦Ä§
        tr/\x{0131}\x{0138}\x{013f}\x{0141}\x{0140}\x{0142}/ikLLll/; # Ä±Ä¸Ä¿Å<81>Å<80>Å<82>
        tr/\x{014a}\x{0149}\x{014b}\x{00d8}\x{00f8}\x{017f}/NnnOos/; # Å<8a>Å<89>Å<8b>Ã<98>Ã¸Å¿
        tr/\x{00de}\x{0166}\x{00fe}\x{0167}/TTtt/;                   # Ã<9e>Å¦Ã¾Å§

        s/[^\0-\x80]/ /g;  ##  space for everything else; optional

        $nstr .= $_;
    }

    $nstr;

}


sub capitalize {
    my $txt = shift;
    my %args = @_; 
    #print "bef: $txt\n";
    # we don't want to recapitalize when it look ok
    # what doesn't look ok is a token with all lowercase (4 or more chars) or allcaps (2 or more chars)
    return $txt unless $txt =~ /\b[A-Z]{2,}\b/ or $txt =~ /\b[a-z]{4,}\b/;
    my $t = capitalize_title($txt);
    if ($args{notSentence}) {
        $t =~ s/^($PREFIXES)/lc $1/ie;
    }
    #fix for bug in text::capitalize
    $t =~ s/&Quot;?(\.?)$/&quot;$1/g;

    return $t;
}


#
# Top 1000 most common male first names in the US according to the 1990 US survey, with relative frequency (%, first column)
#

$COMMON_MALE_FIRSTNAMES = <<ENDNAMES;
JAMES          3.318  3.318      1
JOHN           3.271  6.589      2
ROBERT         3.143  9.732      3
MICHAEL        2.629 12.361      4
WILLIAM        2.451 14.812      5
DAVID          2.363 17.176      6
RICHARD        1.703 18.878      7
CHARLES        1.523 20.401      8
JOSEPH         1.404 21.805      9
THOMAS         1.380 23.185     10
CHRISTOPHER    1.035 24.220     11
DANIEL         0.974 25.194     12
PAUL           0.948 26.142     13
MARK           0.938 27.081     14
DONALD         0.931 28.012     15
GEORGE         0.927 28.939     16
KENNETH        0.826 29.766     17
STEVEN         0.780 30.546     18
EDWARD         0.779 31.325     19
BRIAN          0.736 32.061     20
RONALD         0.725 32.787     21
ANTHONY        0.721 33.508     22
KEVIN          0.671 34.179     23
JASON          0.660 34.839     24
MATTHEW        0.657 35.496     25
GARY           0.650 36.147     26
TIMOTHY        0.640 36.786     27
JOSE           0.613 37.399     28
LARRY          0.598 37.997     29
JEFFREY        0.591 38.588     30
FRANK          0.581 39.169     31
SCOTT          0.546 39.715     32
ERIC           0.544 40.259     33
STEPHEN        0.540 40.799     34
ANDREW         0.537 41.335     35
RAYMOND        0.488 41.824     36
GREGORY        0.441 42.265     37
JOSHUA         0.435 42.700     38
JERRY          0.432 43.132     39
DENNIS         0.415 43.547     40
WALTER         0.399 43.946     41
PATRICK        0.389 44.335     42
PETER          0.381 44.716     43
HAROLD         0.371 45.087     44
DOUGLAS        0.367 45.454     45
HENRY          0.365 45.819     46
CARL           0.346 46.165     47
ARTHUR         0.335 46.500     48
RYAN           0.328 46.828     49
ROGER          0.322 47.150     50
JOE            0.321 47.471     51
JUAN           0.316 47.786     52
JACK           0.315 48.102     53
ALBERT         0.314 48.415     54
JONATHAN       0.313 48.729     55
JUSTIN         0.311 49.040     56
TERRY          0.311 49.351     57
GERALD         0.309 49.660     58
KEITH          0.308 49.968     59
SAMUEL         0.306 50.274     60
WILLIE         0.302 50.576     61
RALPH          0.282 50.859     62
LAWRENCE       0.282 51.141     63
NICHOLAS       0.275 51.415     64
ROY            0.273 51.688     65
BENJAMIN       0.270 51.958     66
BRUCE          0.263 52.221     67
BRANDON        0.260 52.480     68
ADAM           0.259 52.740     69
HARRY          0.251 52.991     70
FRED           0.251 53.241     71
WAYNE          0.249 53.490     72
BILLY          0.248 53.738     73
STEVE          0.246 53.984     74
LOUIS          0.243 54.227     75
JEREMY         0.242 54.469     76
AARON          0.240 54.710     77
RANDY          0.232 54.942     78
HOWARD         0.230 55.172     79
EUGENE         0.230 55.402     80
CARLOS         0.229 55.630     81
RUSSELL        0.224 55.854     82
BOBBY          0.223 56.077     83
VICTOR         0.222 56.299     84
MARTIN         0.216 56.515     85
ERNEST         0.215 56.730     86
PHILLIP        0.213 56.942     87
TODD           0.213 57.155     88
JESSE          0.209 57.364     89
CRAIG          0.206 57.570     90
ALAN           0.204 57.774     91
SHAWN          0.200 57.973     92
CLARENCE       0.197 58.170     93
SEAN           0.197 58.368     94
PHILIP         0.197 58.565     95
CHRIS          0.197 58.761     96
JOHNNY         0.195 58.957     97
EARL           0.193 59.149     98
JIMMY          0.191 59.340     99
ANTONIO        0.190 59.531    100
DANNY          0.190 59.720    101
BRYAN          0.190 59.910    102
TONY           0.190 60.100    103
LUIS           0.189 60.289    104
MIKE           0.189 60.478    105
STANLEY        0.186 60.665    106
LEONARD        0.186 60.850    107
NATHAN         0.185 61.035    108
DALE           0.184 61.219    109
MANUEL         0.181 61.400    110
RODNEY         0.180 61.581    111
CURTIS         0.180 61.761    112
NORMAN         0.177 61.938    113
ALLEN          0.174 62.112    114
MARVIN         0.171 62.283    115
VINCENT        0.168 62.450    116
GLENN          0.167 62.617    117
JEFFERY        0.166 62.783    118
TRAVIS         0.166 62.949    119
JEFF           0.166 63.114    120
CHAD           0.165 63.279    121
JACOB          0.165 63.444    122
LEE            0.162 63.606    123
MELVIN         0.162 63.768    124
ALFRED         0.162 63.930    125
KYLE           0.160 64.090    126
FRANCIS        0.160 64.250    127
BRADLEY        0.159 64.409    128
JESUS          0.155 64.564    129
HERBERT        0.155 64.719    130
FREDERICK      0.154 64.873    131
RAY            0.153 65.026    132
JOEL           0.152 65.177    133
EDWIN          0.148 65.326    134
DON            0.145 65.471    135
EDDIE          0.144 65.615    136
RICKY          0.141 65.756    137
TROY           0.138 65.895    138
RANDALL        0.138 66.032    139
BARRY          0.134 66.167    140
ALEXANDER      0.132 66.299    141
BERNARD        0.127 66.427    142
MARIO          0.125 66.552    143
LEROY          0.125 66.676    144
FRANCISCO      0.124 66.801    145
MARCUS         0.124 66.925    146
MICHEAL        0.123 67.048    147
THEODORE       0.123 67.171    148
CLIFFORD       0.123 67.293    149
MIGUEL         0.122 67.415    150
OSCAR          0.122 67.538    151
JAY            0.118 67.656    152
JIM            0.118 67.773    153
TOM            0.117 67.890    154
CALVIN         0.115 68.006    155
ALEX           0.115 68.120    156
JON            0.115 68.235    157
RONNIE         0.113 68.348    158
BILL           0.112 68.461    159
LLOYD          0.112 68.573    160
TOMMY          0.112 68.685    161
LEON           0.112 68.797    162
DEREK          0.112 68.908    163
WARREN         0.110 69.018    164
DARRELL        0.108 69.126    165
JEROME         0.108 69.234    166
FLOYD          0.107 69.340    167
LEO            0.106 69.446    168
ALVIN          0.105 69.551    169
TIM            0.104 69.656    170
WESLEY         0.104 69.760    171
GORDON         0.104 69.864    172
DEAN           0.104 69.968    173
GREG           0.104 70.071    174
JORGE          0.104 70.175    175
DUSTIN         0.103 70.278    176
PEDRO          0.103 70.381    177
DERRICK        0.103 70.484    178
DAN            0.101 70.585    179
LEWIS          0.099 70.684    180
ZACHARY        0.099 70.782    181
COREY          0.098 70.880    182
HERMAN         0.097 70.977    183
MAURICE        0.097 71.074    184
VERNON         0.097 71.171    185
ROBERTO        0.097 71.268    186
CLYDE          0.095 71.363    187
GLEN           0.094 71.457    188
HECTOR         0.094 71.551    189
SHANE          0.093 71.645    190
RICARDO        0.093 71.738    191
SAM            0.092 71.830    192
RICK           0.091 71.921    193
LESTER         0.091 72.011    194
BRENT          0.090 72.102    195
RAMON          0.090 72.192    196
CHARLIE        0.090 72.281    197
TYLER          0.089 72.371    198
GILBERT        0.089 72.460    199
GENE           0.087 72.547    200
MARC           0.087 72.634    201
REGINALD       0.084 72.717    202
RUBEN          0.082 72.800    203
BRETT          0.082 72.882    204
ANGEL          0.082 72.964    205
NATHANIEL      0.081 73.045    206
RAFAEL         0.081 73.126    207
LESLIE         0.081 73.207    208
EDGAR          0.080 73.287    209
MILTON         0.080 73.367    210
RAUL           0.079 73.446    211
BEN            0.078 73.524    212
CHESTER        0.078 73.602    213
CECIL          0.078 73.680    214
DUANE          0.077 73.757    215
FRANKLIN       0.077 73.834    216
ANDRE          0.076 73.910    217
ELMER          0.074 73.984    218
BRAD           0.073 74.057    219
GABRIEL        0.073 74.130    220
RON            0.072 74.202    221
MITCHELL       0.072 74.274    222
ROLAND         0.072 74.347    223
ARNOLD         0.072 74.419    224
HARVEY         0.072 74.491    225
JARED          0.071 74.562    226
ADRIAN         0.069 74.631    227
KARL           0.069 74.699    228
CORY           0.068 74.767    229
CLAUDE         0.068 74.835    230
ERIK           0.068 74.903    231
DARRYL         0.067 74.970    232
JAMIE          0.066 75.037    233
NEIL           0.066 75.102    234
JESSIE         0.065 75.168    235
CHRISTIAN      0.065 75.233    236
JAVIER         0.065 75.297    237
FERNANDO       0.065 75.362    238
CLINTON        0.065 75.427    239
TED            0.064 75.491    240
MATHEW         0.064 75.555    241
TYRONE         0.064 75.619    242
DARREN         0.064 75.683    243
LONNIE         0.064 75.746    244
LANCE          0.063 75.810    245
CODY           0.063 75.873    246
JULIO          0.063 75.936    247
KELLY          0.063 75.998    248
KURT           0.062 76.061    249
ALLAN          0.061 76.122    250
NELSON         0.061 76.182    251
GUY            0.060 76.243    252
CLAYTON        0.060 76.303    253
HUGH           0.060 76.363    254
MAX            0.059 76.421    255
DWAYNE         0.059 76.480    256
DWIGHT         0.058 76.538    257
ARMANDO        0.058 76.596    258
FELIX          0.058 76.654    259
JIMMIE         0.058 76.711    260
EVERETT        0.057 76.768    261
JORDAN         0.056 76.824    262
IAN            0.056 76.880    263
WALLACE        0.056 76.936    264
KEN            0.055 76.991    265
BOB            0.055 77.047    266
JAIME          0.055 77.102    267
CASEY          0.054 77.156    268
ALFREDO        0.054 77.210    269
ALBERTO        0.053 77.263    270
DAVE           0.053 77.316    271
IVAN           0.053 77.369    272
JOHNNIE        0.052 77.421    273
SIDNEY         0.052 77.474    274
BYRON          0.052 77.526    275
JULIAN         0.052 77.578    276
ISAAC          0.051 77.629    277
MORRIS         0.051 77.680    278
CLIFTON        0.050 77.730    279
WILLARD        0.050 77.780    280
DARYL          0.050 77.831    281
ROSS           0.050 77.880    282
VIRGIL         0.049 77.929    283
ANDY           0.049 77.979    284
MARSHALL       0.049 78.028    285
SALVADOR       0.049 78.077    286
PERRY          0.049 78.126    287
KIRK           0.049 78.175    288
SERGIO         0.049 78.224    289
MARION         0.048 78.272    290
TRACY          0.048 78.320    291
SETH           0.048 78.368    292
KENT           0.048 78.416    293
TERRANCE       0.048 78.464    294
RENE           0.048 78.512    295
EDUARDO        0.047 78.559    296
TERRENCE       0.047 78.606    297
ENRIQUE        0.046 78.652    298
FREDDIE        0.046 78.698    299
WADE           0.045 78.743    300
AUSTIN         0.044 78.786    301
STUART         0.044 78.830    302
FREDRICK       0.043 78.873    303
ARTURO         0.043 78.917    304
ALEJANDRO      0.043 78.960    305
JACKIE         0.043 79.002    306
JOEY           0.043 79.045    307
NICK           0.043 79.088    308
LUTHER         0.043 79.130    309
WENDELL        0.042 79.172    310
JEREMIAH       0.042 79.215    311
EVAN           0.042 79.257    312
JULIUS         0.042 79.298    313
DANA           0.042 79.340    314
DONNIE         0.041 79.381    315
OTIS           0.041 79.422    316
SHANNON        0.040 79.462    317
TREVOR         0.040 79.503    318
OLIVER         0.040 79.543    319
LUKE           0.040 79.583    320
HOMER          0.040 79.623    321
GERARD         0.040 79.663    322
DOUG           0.040 79.703    323
KENNY          0.039 79.742    324
HUBERT         0.039 79.782    325
ANGELO         0.039 79.821    326
SHAUN          0.039 79.859    327
LYLE           0.038 79.898    328
MATT           0.038 79.936    329
LYNN           0.038 79.974    330
ALFONSO        0.038 80.012    331
ORLANDO        0.037 80.049    332
REX            0.037 80.086    333
CARLTON        0.037 80.123    334
ERNESTO        0.037 80.160    335
CAMERON        0.037 80.197    336
NEAL           0.037 80.233    337
PABLO          0.036 80.270    338
LORENZO        0.036 80.306    339
OMAR           0.036 80.342    340
WILBUR         0.036 80.378    341
BLAKE          0.036 80.414    342
GRANT          0.036 80.450    343
HORACE         0.036 80.486    344
RODERICK       0.036 80.521    345
KERRY          0.036 80.557    346
ABRAHAM        0.035 80.592    347
WILLIS         0.035 80.627    348
RICKEY         0.035 80.662    349
JEAN           0.035 80.696    350
IRA            0.035 80.731    351
ANDRES         0.034 80.766    352
CESAR          0.034 80.800    353
JOHNATHAN      0.034 80.834    354
MALCOLM        0.034 80.868    355
RUDOLPH        0.034 80.902    356
DAMON          0.034 80.936    357
KELVIN         0.034 80.970    358
RUDY           0.034 81.004    359
PRESTON        0.034 81.037    360
ALTON          0.033 81.071    361
ARCHIE         0.033 81.104    362
MARCO          0.033 81.137    363
WM             0.033 81.170    364
PETE           0.032 81.202    365
RANDOLPH       0.032 81.234    366
GARRY          0.032 81.267    367
GEOFFREY       0.032 81.299    368
JONATHON       0.032 81.331    369
FELIPE         0.032 81.363    370
BENNIE         0.032 81.395    371
GERARDO        0.032 81.427    372
ED             0.032 81.458    373
DOMINIC        0.032 81.490    374
ROBIN          0.032 81.522    375
LOREN          0.032 81.553    376
DELBERT        0.031 81.585    377
COLIN          0.031 81.616    378
GUILLERMO      0.031 81.647    379
EARNEST        0.031 81.678    380
LUCAS          0.031 81.709    381
BENNY          0.030 81.739    382
NOEL           0.030 81.769    383
SPENCER        0.030 81.799    384
RODOLFO        0.030 81.828    385
MYRON          0.030 81.858    386
EDMUND         0.030 81.887    387
GARRETT        0.029 81.917    388
SALVATORE      0.029 81.946    389
CEDRIC         0.029 81.975    390
LOWELL         0.029 82.004    391
GREGG          0.029 82.032    392
SHERMAN        0.028 82.061    393
WILSON         0.028 82.089    394
DEVIN          0.028 82.117    395
SYLVESTER      0.028 82.145    396
KIM            0.028 82.173    397
ROOSEVELT      0.028 82.201    398
ISRAEL         0.028 82.229    399
JERMAINE       0.028 82.257    400
FORREST        0.027 82.284    401
WILBERT        0.027 82.310    402
LELAND         0.027 82.337    403
SIMON          0.026 82.363    404
GUADALUPE      0.026 82.390    405
CLARK          0.026 82.416    406
IRVING         0.026 82.442    407
CARROLL        0.026 82.468    408
BRYANT         0.026 82.494    409
OWEN           0.026 82.519    410
RUFUS          0.025 82.545    411
WOODROW        0.025 82.570    412
SAMMY          0.025 82.595    413
KRISTOPHER     0.025 82.620    414
MACK           0.025 82.645    415
LEVI           0.025 82.670    416
MARCOS         0.025 82.695    417
GUSTAVO        0.025 82.720    418
JAKE           0.025 82.744    419
LIONEL         0.024 82.769    420
MARTY          0.024 82.793    421
TAYLOR         0.024 82.817    422
ELLIS          0.024 82.842    423
DALLAS         0.024 82.866    424
GILBERTO       0.024 82.890    425
CLINT          0.024 82.914    426
NICOLAS        0.024 82.938    427
LAURENCE       0.024 82.962    428
ISMAEL         0.024 82.985    429
ORVILLE        0.024 83.009    430
DREW           0.024 83.033    431
JODY           0.024 83.056    432
ERVIN          0.023 83.080    433
DEWEY          0.023 83.103    434
AL             0.023 83.126    435
WILFRED        0.023 83.150    436
JOSH           0.023 83.173    437
HUGO           0.023 83.196    438
IGNACIO        0.023 83.219    439
CALEB          0.023 83.241    440
TOMAS          0.023 83.264    441
SHELDON        0.023 83.287    442
ERICK          0.023 83.310    443
FRANKIE        0.023 83.332    444
STEWART        0.022 83.354    445
DOYLE          0.022 83.377    446
DARREL         0.022 83.399    447
ROGELIO        0.022 83.421    448
TERENCE        0.022 83.443    449
SANTIAGO       0.022 83.465    450
ALONZO         0.022 83.487    451
ELIAS          0.022 83.508    452
BERT           0.022 83.530    453
ELBERT         0.022 83.552    454
RAMIRO         0.022 83.573    455
CONRAD         0.022 83.595    456
PAT            0.022 83.616    457
NOAH           0.022 83.638    458
GRADY          0.021 83.659    459
PHIL           0.021 83.681    460
CORNELIUS      0.021 83.702    461
LAMAR          0.021 83.723    462
ROLANDO        0.021 83.744    463
CLAY           0.021 83.765    464
PERCY          0.021 83.786    465
DEXTER         0.021 83.806    466
BRADFORD       0.021 83.827    467
MERLE          0.021 83.848    468
DARIN          0.020 83.868    469
AMOS           0.020 83.888    470
TERRELL        0.020 83.909    471
MOSES          0.020 83.929    472
IRVIN          0.020 83.949    473
SAUL           0.020 83.968    474
ROMAN          0.020 83.988    475
DARNELL        0.020 84.008    476
RANDAL         0.020 84.027    477
TOMMIE         0.020 84.047    478
TIMMY          0.019 84.066    479
DARRIN         0.019 84.086    480
WINSTON        0.019 84.105    481
BRENDAN        0.019 84.124    482
TOBY           0.019 84.144    483
VAN            0.019 84.163    484
ABEL           0.019 84.182    485
DOMINICK       0.019 84.201    486
BOYD           0.019 84.220    487
COURTNEY       0.019 84.240    488
JAN            0.019 84.259    489
EMILIO         0.019 84.277    490
ELIJAH         0.019 84.296    491
CARY           0.019 84.315    492
DOMINGO        0.019 84.334    493
SANTOS         0.019 84.353    494
AUBREY         0.019 84.372    495
EMMETT         0.019 84.390    496
MARLON         0.019 84.409    497
EMANUEL        0.019 84.428    498
JERALD         0.019 84.446    499
EDMOND         0.019 84.465    500
EMIL           0.019 84.483    501
DEWAYNE        0.018 84.502    502
WILL           0.018 84.520    503
OTTO           0.018 84.538    504
TEDDY          0.018 84.556    505
REYNALDO       0.018 84.574    506
BRET           0.018 84.592    507
MORGAN         0.018 84.610    508
JESS           0.018 84.628    509
TRENT          0.018 84.646    510
HUMBERTO       0.018 84.664    511
EMMANUEL       0.018 84.681    512
STEPHAN        0.018 84.699    513
LOUIE          0.018 84.717    514
VICENTE        0.017 84.734    515
LAMONT         0.017 84.751    516
STACY          0.017 84.769    517
GARLAND        0.017 84.786    518
MILES          0.017 84.803    519
MICAH          0.017 84.820    520
EFRAIN         0.017 84.837    521
BILLIE         0.017 84.854    522
LOGAN          0.017 84.871    523
HEATH          0.017 84.887    524
RODGER         0.017 84.904    525
HARLEY         0.017 84.921    526
DEMETRIUS      0.017 84.937    527
ETHAN          0.017 84.954    528
ELDON          0.017 84.970    529
ROCKY          0.016 84.987    530
PIERRE         0.016 85.003    531
JUNIOR         0.016 85.020    532
FREDDY         0.016 85.036    533
ELI            0.016 85.052    534
BRYCE          0.016 85.068    535
ANTOINE        0.016 85.084    536
ROBBIE         0.016 85.100    537
KENDALL        0.016 85.116    538
ROYCE          0.016 85.132    539
STERLING       0.016 85.148    540
MICKEY         0.016 85.164    541
CHASE          0.016 85.180    542
GROVER         0.016 85.196    543
ELTON          0.016 85.212    544
CLEVELAND      0.016 85.228    545
DYLAN          0.016 85.243    546
CHUCK          0.016 85.259    547
DAMIAN         0.016 85.274    548
REUBEN         0.015 85.290    549
STAN           0.015 85.305    550
AUGUST         0.015 85.321    551
LEONARDO       0.015 85.336    552
JASPER         0.015 85.351    553
RUSSEL         0.015 85.367    554
ERWIN          0.015 85.382    555
BENITO         0.015 85.397    556
HANS           0.015 85.412    557
MONTE          0.015 85.427    558
BLAINE         0.015 85.442    559
ERNIE          0.015 85.456    560
CURT           0.015 85.471    561
QUENTIN        0.015 85.486    562
AGUSTIN        0.015 85.500    563
MURRAY         0.015 85.515    564
JAMAL          0.014 85.529    565
DEVON          0.014 85.544    566
ADOLFO         0.014 85.558    567
HARRISON       0.014 85.573    568
TYSON          0.014 85.587    569
BURTON         0.014 85.601    570
BRADY          0.014 85.616    571
ELLIOTT        0.014 85.630    572
WILFREDO       0.014 85.644    573
BART           0.014 85.658    574
JARROD         0.014 85.672    575
VANCE          0.014 85.686    576
DENIS          0.014 85.700    577
DAMIEN         0.014 85.714    578
JOAQUIN        0.014 85.728    579
HARLAN         0.014 85.742    580
DESMOND        0.014 85.756    581
ELLIOT         0.014 85.770    582
DARWIN         0.014 85.783    583
ASHLEY         0.014 85.797    584
GREGORIO       0.014 85.811    585
BUDDY          0.014 85.824    586
XAVIER         0.013 85.838    587
KERMIT         0.013 85.851    588
ROSCOE         0.013 85.865    589
ESTEBAN        0.013 85.878    590
ANTON          0.013 85.891    591
SOLOMON        0.013 85.904    592
SCOTTY         0.013 85.917    593
NORBERT        0.013 85.930    594
ELVIN          0.013 85.943    595
WILLIAMS       0.013 85.956    596
NOLAN          0.013 85.969    597
CAREY          0.013 85.982    598
ROD            0.013 85.994    599
QUINTON        0.013 86.007    600
HAL            0.013 86.020    601
BRAIN          0.013 86.033    602
ROB            0.013 86.045    603
ELWOOD         0.013 86.058    604
KENDRICK       0.013 86.070    605
DARIUS         0.013 86.083    606
MOISES         0.013 86.096    607
SON            0.012 86.108    608
MARLIN         0.012 86.120    609
FIDEL          0.012 86.133    610
THADDEUS       0.012 86.145    611
CLIFF          0.012 86.158    612
MARCEL         0.012 86.170    613
ALI            0.012 86.182    614
JACKSON        0.012 86.195    615
RAPHAEL        0.012 86.207    616
BRYON          0.012 86.219    617
ARMAND         0.012 86.231    618
ALVARO         0.012 86.244    619
JEFFRY         0.012 86.256    620
DANE           0.012 86.268    621
JOESPH         0.012 86.280    622
THURMAN        0.012 86.292    623
NED            0.012 86.304    624
SAMMIE         0.012 86.316    625
RUSTY          0.012 86.328    626
MICHEL         0.012 86.339    627
MONTY          0.012 86.351    628
RORY           0.012 86.363    629
FABIAN         0.012 86.374    630
REGGIE         0.012 86.386    631
MASON          0.012 86.397    632
GRAHAM         0.012 86.409    633
KRIS           0.011 86.420    634
ISAIAH         0.011 86.432    635
VAUGHN         0.011 86.443    636
GUS            0.011 86.454    637
AVERY          0.011 86.466    638
LOYD           0.011 86.477    639
DIEGO          0.011 86.488    640
ALEXIS         0.011 86.499    641
ADOLPH         0.011 86.511    642
NORRIS         0.011 86.522    643
MILLARD        0.011 86.533    644
ROCCO          0.011 86.544    645
GONZALO        0.011 86.555    646
DERICK         0.011 86.566    647
RODRIGO        0.011 86.577    648
GERRY          0.011 86.588    649
STACEY         0.011 86.599    650
CARMEN         0.011 86.610    651
WILEY          0.011 86.621    652
RIGOBERTO      0.011 86.632    653
ALPHONSO       0.011 86.643    654
TY             0.011 86.654    655
SHELBY         0.011 86.664    656
RICKIE         0.011 86.675    657
NOE            0.011 86.686    658
VERN           0.010 86.696    659
BOBBIE         0.010 86.707    660
REED           0.010 86.717    661
JEFFERSON      0.010 86.727    662
ELVIS          0.010 86.738    663
BERNARDO       0.010 86.748    664
MAURICIO       0.010 86.758    665
HIRAM          0.010 86.768    666
DONOVAN        0.010 86.778    667
BASIL          0.010 86.789    668
RILEY          0.010 86.799    669
OLLIE          0.010 86.809    670
NICKOLAS       0.010 86.819    671
MAYNARD        0.010 86.829    672
SCOT           0.010 86.840    673
VINCE          0.010 86.850    674
QUINCY         0.010 86.860    675
EDDY           0.010 86.870    676
SEBASTIAN      0.010 86.880    677
FEDERICO       0.010 86.890    678
ULYSSES        0.010 86.900    679
HERIBERTO      0.010 86.910    680
DONNELL        0.010 86.920    681
COLE           0.010 86.929    682
DENNY          0.010 86.939    683
DAVIS          0.010 86.949    684
GAVIN          0.010 86.959    685
EMERY          0.010 86.969    686
WARD           0.010 86.979    687
ROMEO          0.010 86.989    688
JAYSON         0.010 86.998    689
DION           0.010 87.008    690
DANTE          0.010 87.018    691
CLEMENT        0.010 87.028    692
COY            0.010 87.037    693
ODELL          0.010 87.047    694
MAXWELL        0.010 87.057    695
JARVIS         0.010 87.066    696
BRUNO          0.010 87.076    697
ISSAC          0.010 87.086    698
MARY           0.009 87.095    699
DUDLEY         0.009 87.104    700
BROCK          0.009 87.114    701
SANFORD        0.009 87.123    702
COLBY          0.009 87.133    703
CARMELO        0.009 87.142    704
BARNEY         0.009 87.152    705
NESTOR         0.009 87.161    706
HOLLIS         0.009 87.170    707
STEFAN         0.009 87.180    708
DONNY          0.009 87.189    709
ART            0.009 87.198    710
LINWOOD        0.009 87.208    711
BEAU           0.009 87.217    712
WELDON         0.009 87.226    713
GALEN          0.009 87.235    714
ISIDRO         0.009 87.244    715
TRUMAN         0.009 87.253    716
DELMAR         0.009 87.262    717
JOHNATHON      0.009 87.271    718
SILAS          0.009 87.280    719
FREDERIC       0.009 87.289    720
DICK           0.009 87.298    721
KIRBY          0.009 87.307    722
IRWIN          0.009 87.316    723
CRUZ           0.009 87.325    724
MERLIN         0.009 87.334    725
MERRILL        0.009 87.343    726
CHARLEY        0.009 87.351    727
MARCELINO      0.009 87.360    728
LANE           0.009 87.369    729
HARRIS         0.009 87.378    730
CLEO           0.009 87.386    731
CARLO          0.009 87.395    732
TRENTON        0.009 87.404    733
KURTIS         0.009 87.413    734
HUNTER         0.009 87.421    735
AURELIO        0.009 87.430    736
WINFRED        0.009 87.438    737
VITO           0.009 87.447    738
COLLIN         0.009 87.456    739
DENVER         0.009 87.464    740
CARTER         0.009 87.473    741
LEONEL         0.008 87.481    742
EMORY          0.008 87.490    743
PASQUALE       0.008 87.498    744
MOHAMMAD       0.008 87.506    745
MARIANO        0.008 87.514    746
DANIAL         0.008 87.523    747
BLAIR          0.008 87.531    748
LANDON         0.008 87.539    749
DIRK           0.008 87.548    750
BRANDEN        0.008 87.556    751
ADAN           0.008 87.564    752
NUMBERS        0.008 87.572    753
CLAIR          0.008 87.581    754
BUFORD         0.008 87.589    755
GERMAN         0.008 87.597    756
BERNIE         0.008 87.605    757
WILMER         0.008 87.613    758
JOAN           0.008 87.621    759
EMERSON        0.008 87.629    760
ZACHERY        0.008 87.637    761
FLETCHER       0.008 87.645    762
JACQUES        0.008 87.653    763
ERROL          0.008 87.661    764
DALTON         0.008 87.669    765
MONROE         0.008 87.676    766
JOSUE          0.008 87.684    767
DOMINIQUE      0.008 87.692    768
EDWARDO        0.008 87.700    769
BOOKER         0.008 87.708    770
WILFORD        0.008 87.715    771
SONNY          0.008 87.723    772
SHELTON        0.008 87.731    773
CARSON         0.008 87.739    774
THERON         0.008 87.746    775
RAYMUNDO       0.008 87.754    776
DAREN          0.008 87.762    777
TRISTAN        0.008 87.769    778
HOUSTON        0.008 87.777    779
ROBBY          0.008 87.785    780
LINCOLN        0.008 87.792    781
JAME           0.008 87.800    782
GENARO         0.008 87.807    783
GALE           0.008 87.815    784
BENNETT        0.008 87.822    785
OCTAVIO        0.008 87.830    786
CORNELL        0.008 87.838    787
LAVERNE        0.008 87.845    788
HUNG           0.008 87.853    789
ARRON          0.008 87.860    790
ANTONY         0.008 87.868    791
HERSCHEL       0.007 87.875    792
ALVA           0.007 87.883    793
GIOVANNI       0.007 87.890    794
GARTH          0.007 87.897    795
CYRUS          0.007 87.905    796
CYRIL          0.007 87.912    797
RONNY          0.007 87.920    798
STEVIE         0.007 87.927    799
LON            0.007 87.934    800
FREEMAN        0.007 87.941    801
ERIN           0.007 87.949    802
DUNCAN         0.007 87.956    803
KENNITH        0.007 87.963    804
CARMINE        0.007 87.970    805
AUGUSTINE      0.007 87.978    806
YOUNG          0.007 87.985    807
ERICH          0.007 87.992    808
CHADWICK       0.007 87.999    809
WILBURN        0.007 88.006    810
RUSS           0.007 88.013    811
REID           0.007 88.021    812
MYLES          0.007 88.028    813
ANDERSON       0.007 88.035    814
MORTON         0.007 88.042    815
JONAS          0.007 88.049    816
FOREST         0.007 88.056    817
MITCHEL        0.007 88.063    818
MERVIN         0.007 88.070    819
ZANE           0.007 88.077    820
RICH           0.007 88.084    821
JAMEL          0.007 88.091    822
LAZARO         0.007 88.098    823
ALPHONSE       0.007 88.105    824
RANDELL        0.007 88.112    825
MAJOR          0.007 88.119    826
JOHNIE         0.007 88.126    827
JARRETT        0.007 88.133    828
BROOKS         0.007 88.140    829
ARIEL          0.007 88.147    830
ABDUL          0.007 88.154    831
DUSTY          0.007 88.161    832
LUCIANO        0.007 88.168    833
LINDSEY        0.007 88.174    834
TRACEY         0.007 88.181    835
SEYMOUR        0.007 88.188    836
SCOTTIE        0.007 88.195    837
EUGENIO        0.007 88.202    838
MOHAMMED       0.007 88.208    839
SANDY          0.007 88.215    840
VALENTIN       0.007 88.222    841
CHANCE         0.007 88.228    842
ARNULFO        0.007 88.235    843
LUCIEN         0.007 88.242    844
FERDINAND      0.007 88.248    845
THAD           0.007 88.255    846
EZRA           0.007 88.262    847
SYDNEY         0.007 88.268    848
ALDO           0.007 88.275    849
RUBIN          0.006 88.281    850
ROYAL          0.006 88.288    851
MITCH          0.006 88.294    852
EARLE          0.006 88.301    853
ABE            0.006 88.307    854
WYATT          0.006 88.314    855
MARQUIS        0.006 88.320    856
LANNY          0.006 88.326    857
KAREEM         0.006 88.333    858
JAMAR          0.006 88.339    859
BORIS          0.006 88.346    860
ISIAH          0.006 88.352    861
EMILE          0.006 88.358    862
ELMO           0.006 88.365    863
ARON           0.006 88.371    864
LEOPOLDO       0.006 88.377    865
EVERETTE       0.006 88.384    866
JOSEF          0.006 88.390    867
GAIL           0.006 88.396    868
ELOY           0.006 88.403    869
DORIAN         0.006 88.409    870
RODRICK        0.006 88.415    871
REINALDO       0.006 88.421    872
LUCIO          0.006 88.427    873
JERROD         0.006 88.434    874
WESTON         0.006 88.440    875
HERSHEL        0.006 88.446    876
BARTON         0.006 88.452    877
PARKER         0.006 88.458    878
LEMUEL         0.006 88.464    879
LAVERN         0.006 88.470    880
BURT           0.006 88.477    881
JULES          0.006 88.483    882
GIL            0.006 88.489    883
ELISEO         0.006 88.495    884
AHMAD          0.006 88.501    885
NIGEL          0.006 88.507    886
EFREN          0.006 88.513    887
ANTWAN         0.006 88.519    888
ALDEN          0.006 88.525    889
MARGARITO      0.006 88.531    890
COLEMAN        0.006 88.537    891
REFUGIO        0.006 88.543    892
DINO           0.006 88.549    893
OSVALDO        0.006 88.555    894
LES            0.006 88.560    895
DEANDRE        0.006 88.566    896
NORMAND        0.006 88.572    897
KIETH          0.006 88.578    898
IVORY          0.006 88.584    899
ANDREA         0.006 88.590    900
TREY           0.006 88.595    901
NORBERTO       0.006 88.601    902
NAPOLEON       0.006 88.607    903
JEROLD         0.006 88.613    904
FRITZ          0.006 88.619    905
ROSENDO        0.006 88.624    906
MILFORD        0.006 88.630    907
SANG           0.006 88.636    908
DEON           0.006 88.641    909
CHRISTOPER     0.006 88.647    910
ALFONZO        0.006 88.653    911
LYMAN          0.006 88.658    912
JOSIAH         0.006 88.664    913
BRANT          0.006 88.670    914
WILTON         0.006 88.675    915
RICO           0.006 88.681    916
JAMAAL         0.006 88.687    917
DEWITT         0.006 88.692    918
CAROL          0.006 88.698    919
BRENTON        0.006 88.704    920
YONG           0.006 88.709    921
OLIN           0.006 88.715    922
FOSTER         0.006 88.720    923
FAUSTINO       0.006 88.726    924
CLAUDIO        0.006 88.731    925
JUDSON         0.006 88.737    926
GINO           0.006 88.743    927
EDGARDO        0.006 88.748    928
BERRY          0.006 88.754    929
ALEC           0.006 88.759    930
TANNER         0.006 88.765    931
JARRED         0.006 88.770    932
DONN           0.006 88.776    933
TRINIDAD       0.005 88.781    934
TAD            0.005 88.787    935
SHIRLEY        0.005 88.792    936
PRINCE         0.005 88.798    937
PORFIRIO       0.005 88.803    938
ODIS           0.005 88.809    939
MARIA          0.005 88.814    940
LENARD         0.005 88.820    941
CHAUNCEY       0.005 88.825    942
CHANG          0.005 88.831    943
TOD            0.005 88.836    944
MEL            0.005 88.842    945
MARCELO        0.005 88.847    946
KORY           0.005 88.853    947
AUGUSTUS       0.005 88.858    948
KEVEN          0.005 88.864    949
HILARIO        0.005 88.869    950
BUD            0.005 88.874    951
SAL            0.005 88.880    952
ROSARIO        0.005 88.885    953
ORVAL          0.005 88.891    954
MAURO          0.005 88.896    955
DANNIE         0.005 88.901    956
ZACHARIAH      0.005 88.907    957
OLEN           0.005 88.912    958
ANIBAL         0.005 88.917    959
MILO           0.005 88.923    960
JED            0.005 88.928    961
FRANCES        0.005 88.933    962
THANH          0.005 88.939    963
DILLON         0.005 88.944    964
AMADO          0.005 88.949    965
NEWTON         0.005 88.955    966
CONNIE         0.005 88.960    967
LENNY          0.005 88.965    968
TORY           0.005 88.970    969
RICHIE         0.005 88.975    970
LUPE           0.005 88.981    971
HORACIO        0.005 88.986    972
BRICE          0.005 88.991    973
MOHAMED        0.005 88.996    974
DELMER         0.005 89.001    975
DARIO          0.005 89.006    976
REYES          0.005 89.012    977
DEE            0.005 89.017    978
MAC            0.005 89.022    979
JONAH          0.005 89.027    980
JERROLD        0.005 89.032    981
ROBT           0.005 89.037    982
HANK           0.005 89.042    983
SUNG           0.005 89.047    984
RUPERT         0.005 89.052    985
ROLLAND        0.005 89.057    986
KENTON         0.005 89.062    987
DAMION         0.005 89.067    988
CHI            0.005 89.072    989
ANTONE         0.005 89.077    990
WALDO          0.005 89.082    991
FREDRIC        0.005 89.087    992
BRADLY         0.005 89.092    993
QUINN          0.005 89.097    994
KIP            0.005 89.102    995
BURL           0.005 89.107    996
WALKER         0.005 89.112    997
TYREE          0.005 89.117    998
JEFFEREY       0.005 89.122    999
AHMED          0.005 89.127   1000
WILLY          0.005 89.132   1001
STANFORD       0.005 89.137   1002
OREN           0.005 89.142   1003
NOBLE          0.005 89.146   1004
MOSHE          0.005 89.151   1005
MIKEL          0.005 89.156   1006
ENOCH          0.005 89.161   1007
BRENDON        0.005 89.166   1008
QUINTIN        0.005 89.171   1009
JAMISON        0.005 89.176   1010
FLORENCIO      0.005 89.181   1011
DARRICK        0.005 89.185   1012
TOBIAS         0.005 89.190   1013
MINH           0.005 89.195   1014
HASSAN         0.005 89.200   1015
GIUSEPPE       0.005 89.205   1016
DEMARCUS       0.005 89.210   1017
CLETUS         0.005 89.214   1018
TYRELL         0.005 89.219   1019
LYNDON         0.005 89.224   1020
KEENAN         0.005 89.229   1021
WERNER         0.005 89.234   1022
THEO           0.005 89.238   1023
GERALDO        0.005 89.243   1024
LOU            0.005 89.248   1025
COLUMBUS       0.005 89.253   1026
CHET           0.005 89.257   1027
BERTRAM        0.005 89.262   1028
MARKUS         0.005 89.267   1029
HUEY           0.005 89.271   1030
HILTON         0.005 89.276   1031
DWAIN          0.005 89.281   1032
DONTE          0.005 89.285   1033
TYRON          0.005 89.290   1034
OMER           0.005 89.295   1035
ISAIAS         0.005 89.299   1036
HIPOLITO       0.005 89.304   1037
FERMIN         0.005 89.309   1038
CHUNG          0.005 89.313   1039
ADALBERTO      0.005 89.318   1040
VALENTINE      0.005 89.323   1041
JAMEY          0.005 89.327   1042
BO             0.005 89.332   1043
BARRETT        0.005 89.336   1044
WHITNEY        0.005 89.341   1045
TEODORO        0.005 89.345   1046
MCKINLEY       0.005 89.350   1047
MAXIMO         0.005 89.355   1048
GARFIELD       0.005 89.359   1049
SOL            0.005 89.364   1050
RALEIGH        0.005 89.368   1051
LAWERENCE      0.005 89.373   1052
ABRAM          0.005 89.377   1053
RASHAD         0.004 89.382   1054
KING           0.004 89.386   1055
EMMITT         0.004 89.391   1056
DARON          0.004 89.395   1057
CHONG          0.004 89.400   1058
SAMUAL         0.004 89.404   1059
PARIS          0.004 89.409   1060
OTHA           0.004 89.413   1061
MIQUEL         0.004 89.418   1062
LACY           0.004 89.422   1063
EUSEBIO        0.004 89.426   1064
DONG           0.004 89.431   1065
DOMENIC        0.004 89.435   1066
DARRON         0.004 89.440   1067
BUSTER         0.004 89.444   1068
ANTONIA        0.004 89.449   1069
WILBER         0.004 89.453   1070
RENATO         0.004 89.458   1071
JC             0.004 89.462   1072
HOYT           0.004 89.466   1073
HAYWOOD        0.004 89.471   1074
EZEKIEL        0.004 89.475   1075
CHAS           0.004 89.480   1076
FLORENTINO     0.004 89.484   1077
ELROY          0.004 89.489   1078
CLEMENTE       0.004 89.493   1079
ARDEN          0.004 89.497   1080
NEVILLE        0.004 89.502   1081
KELLEY         0.004 89.506   1082
EDISON         0.004 89.510   1083
DESHAWN        0.004 89.515   1084
CARROL         0.004 89.519   1085
SHAYNE         0.004 89.523   1086
NATHANIAL      0.004 89.528   1087
JORDON         0.004 89.532   1088
DANILO         0.004 89.536   1089
CLAUD          0.004 89.541   1090
VAL            0.004 89.545   1091
SHERWOOD       0.004 89.549   1092
RAYMON         0.004 89.554   1093
RAYFORD        0.004 89.558   1094
CRISTOBAL      0.004 89.562   1095
AMBROSE        0.004 89.567   1096
TITUS          0.004 89.571   1097
HYMAN          0.004 89.575   1098
FELTON         0.004 89.579   1099
EZEQUIEL       0.004 89.584   1100
ERASMO         0.004 89.588   1101
STANTON        0.004 89.592   1102
LONNY          0.004 89.596   1103
LEN            0.004 89.601   1104
IKE            0.004 89.605   1105
MILAN          0.004 89.609   1106
LINO           0.004 89.613   1107
JAROD          0.004 89.617   1108
HERB           0.004 89.622   1109
ANDREAS        0.004 89.626   1110
WALTON         0.004 89.630   1111
RHETT          0.004 89.634   1112
PALMER         0.004 89.638   1113
JUDE           0.004 89.642   1114
DOUGLASS       0.004 89.647   1115
CORDELL        0.004 89.651   1116
OSWALDO        0.004 89.655   1117
ELLSWORTH      0.004 89.659   1118
VIRGILIO       0.004 89.663   1119
TONEY          0.004 89.667   1120
NATHANAEL      0.004 89.671   1121
DEL            0.004 89.675   1122
BRITT          0.004 89.679   1123
BENEDICT       0.004 89.684   1124
MOSE           0.004 89.688   1125
HONG           0.004 89.692   1126
LEIGH          0.004 89.696   1127
JOHNSON        0.004 89.700   1128
ISREAL         0.004 89.704   1129
GAYLE          0.004 89.708   1130
GARRET         0.004 89.712   1131
FAUSTO         0.004 89.716   1132
ASA            0.004 89.720   1133
ARLEN          0.004 89.724   1134
ZACK           0.004 89.728   1135
WARNER         0.004 89.732   1136
MODESTO        0.004 89.736   1137
FRANCESCO      0.004 89.740   1138
MANUAL         0.004 89.744   1139
JAE            0.004 89.748   1140
GAYLORD        0.004 89.752   1141
GASTON         0.004 89.756   1142
FILIBERTO      0.004 89.759   1143
DEANGELO       0.004 89.763   1144
MICHALE        0.004 89.767   1145
GRANVILLE      0.004 89.771   1146
WES            0.004 89.775   1147
MALIK          0.004 89.779   1148
ZACKARY        0.004 89.783   1149
TUAN           0.004 89.787   1150
NICKY          0.004 89.790   1151
ELDRIDGE       0.004 89.794   1152
CRISTOPHER     0.004 89.798   1153
CORTEZ         0.004 89.802   1154
ANTIONE        0.004 89.806   1155
MALCOM         0.004 89.809   1156
LONG           0.004 89.813   1157
KOREY          0.004 89.817   1158
JOSPEH         0.004 89.821   1159
COLTON         0.004 89.825   1160
WAYLON         0.004 89.828   1161
VON            0.004 89.832   1162
HOSEA          0.004 89.836   1163
SHAD           0.004 89.840   1164
SANTO          0.004 89.843   1165
RUDOLF         0.004 89.847   1166
ROLF           0.004 89.851   1167
REY            0.004 89.855   1168
RENALDO        0.004 89.858   1169
MARCELLUS      0.004 89.862   1170
LUCIUS         0.004 89.866   1171
LESLEY         0.004 89.870   1172
KRISTOFER      0.004 89.873   1173
BOYCE          0.004 89.877   1174
BENTON         0.004 89.881   1175
MAN            0.004 89.884   1176
KASEY          0.004 89.888   1177
JEWELL         0.004 89.892   1178
HAYDEN         0.004 89.895   1179
HARLAND        0.004 89.899   1180
ARNOLDO        0.004 89.903   1181
RUEBEN         0.004 89.907   1182
LEANDRO        0.004 89.910   1183
KRAIG          0.004 89.914   1184
JERRELL        0.004 89.918   1185
JEROMY         0.004 89.921   1186
HOBERT         0.004 89.925   1187
CEDRICK        0.004 89.929   1188
ARLIE          0.004 89.932   1189
WINFORD        0.004 89.936   1190
WALLY          0.004 89.939   1191
PATRICIA       0.004 89.943   1192
LUIGI          0.004 89.947   1193
KENETH         0.004 89.950   1194
JACINTO        0.004 89.954   1195
GRAIG          0.004 89.958   1196
FRANKLYN       0.004 89.961   1197
EDMUNDO        0.004 89.965   1198
SID            0.004 89.968   1199
PORTER         0.004 89.972   1200
LEIF           0.004 89.976   1201
LAUREN         0.004 89.979   1202
JERAMY         0.004 89.983   1203
ELISHA         0.004 89.986   1204
BUCK           0.004 89.990   1205
WILLIAN        0.004 89.994   1206
VINCENZO       0.004 89.997   1207
SHON           0.004 90.001   1208
MICHAL         0.004 90.004   1209
LYNWOOD        0.004 90.008   1210
LINDSAY        0.004 90.011   1211
JEWEL          0.004 90.015   1212
JERE           0.004 90.018   1213
HAI            0.004 90.022   1214
ELDEN          0.004 90.026   1215
DORSEY         0.004 90.029   1216
DARELL         0.004 90.033   1217
BRODERICK      0.004 90.036   1218
ALONSO         0.004 90.040   1219
ENDNAMES

$COMMON_FEMALE_FIRSTNAMES = <<ENDNAMES;
MARY           2.629  2.629      1
PATRICIA       1.073  3.702      2
LINDA          1.035  4.736      3
BARBARA        0.980  5.716      4
ELIZABETH      0.937  6.653      5
JENNIFER       0.932  7.586      6
MARIA          0.828  8.414      7
SUSAN          0.794  9.209      8
MARGARET       0.768  9.976      9
DOROTHY        0.727 10.703     10
LISA           0.704 11.407     11
NANCY          0.669 12.075     12
KAREN          0.667 12.742     13
BETTY          0.666 13.408     14
HELEN          0.663 14.071     15
SANDRA         0.629 14.700     16
DONNA          0.583 15.282     17
CAROL          0.565 15.848     18
RUTH           0.562 16.410     19
SHARON         0.522 16.932     20
MICHELLE       0.519 17.451     21
LAURA          0.510 17.961     22
SARAH          0.508 18.469     23
KIMBERLY       0.504 18.973     24
DEBORAH        0.494 19.467     25
JESSICA        0.490 19.958     26
SHIRLEY        0.482 20.439     27
CYNTHIA        0.469 20.908     28
ANGELA         0.468 21.376     29
MELISSA        0.462 21.839     30
BRENDA         0.455 22.293     31
AMY            0.451 22.745     32
ANNA           0.440 23.185     33
REBECCA        0.430 23.615     34
VIRGINIA       0.430 24.044     35
KATHLEEN       0.424 24.468     36
PAMELA         0.416 24.884     37
MARTHA         0.412 25.297     38
DEBRA          0.408 25.704     39
AMANDA         0.404 26.108     40
STEPHANIE      0.400 26.508     41
CAROLYN        0.385 26.893     42
CHRISTINE      0.382 27.275     43
MARIE          0.379 27.655     44
JANET          0.379 28.034     45
CATHERINE      0.373 28.408     46
FRANCES        0.370 28.777     47
ANN            0.364 29.141     48
JOYCE          0.364 29.505     49
DIANE          0.359 29.864     50
ALICE          0.357 30.221     51
JULIE          0.348 30.568     52
HEATHER        0.337 30.905     53
TERESA         0.336 31.241     54
DORIS          0.335 31.577     55
GLORIA         0.335 31.912     56
EVELYN         0.322 32.233     57
JEAN           0.315 32.548     58
CHERYL         0.315 32.863     59
MILDRED        0.313 33.176     60
KATHERINE      0.313 33.489     61
JOAN           0.306 33.795     62
ASHLEY         0.303 34.098     63
JUDITH         0.297 34.395     64
ROSE           0.296 34.691     65
JANICE         0.285 34.975     66
KELLY          0.283 35.258     67
NICOLE         0.281 35.539     68
JUDY           0.276 35.815     69
CHRISTINA      0.275 36.090     70
KATHY          0.272 36.362     71
THERESA        0.271 36.633     72
BEVERLY        0.267 36.900     73
DENISE         0.264 37.164     74
TAMMY          0.259 37.423     75
IRENE          0.252 37.675     76
JANE           0.250 37.925     77
LORI           0.248 38.173     78
RACHEL         0.242 38.415     79
MARILYN        0.241 38.657     80
ANDREA         0.236 38.893     81
KATHRYN        0.234 39.127     82
LOUISE         0.229 39.356     83
SARA           0.229 39.584     84
ANNE           0.228 39.812     85
JACQUELINE     0.228 40.040     86
WANDA          0.226 40.266     87
BONNIE         0.223 40.489     88
JULIA          0.223 40.711     89
RUBY           0.221 40.932     90
LOIS           0.220 41.153     91
TINA           0.220 41.372     92
PHYLLIS        0.219 41.591     93
NORMA          0.218 41.809     94
PAULA          0.217 42.026     95
DIANA          0.216 42.242     96
ANNIE          0.216 42.458     97
LILLIAN        0.211 42.669     98
EMILY          0.208 42.877     99
ROBIN          0.208 43.085    100
PEGGY          0.208 43.293    101
CRYSTAL        0.207 43.500    102
GLADYS         0.205 43.705    103
RITA           0.204 43.908    104
DAWN           0.202 44.111    105
CONNIE         0.200 44.311    106
FLORENCE       0.200 44.511    107
TRACY          0.197 44.708    108
EDNA           0.197 44.904    109
TIFFANY        0.195 45.100    110
CARMEN         0.195 45.295    111
ROSA           0.194 45.489    112
CINDY          0.192 45.681    113
GRACE          0.189 45.869    114
WENDY          0.185 46.055    115
VICTORIA       0.180 46.235    116
EDITH          0.179 46.414    117
KIM            0.178 46.592    118
SHERRY         0.178 46.770    119
SYLVIA         0.177 46.947    120
JOSEPHINE      0.177 47.123    121
THELMA         0.175 47.298    122
SHANNON        0.175 47.473    123
SHEILA         0.175 47.648    124
ETHEL          0.174 47.822    125
ELLEN          0.173 47.995    126
ELAINE         0.173 48.168    127
MARJORIE       0.173 48.341    128
CARRIE         0.171 48.512    129
CHARLOTTE      0.169 48.680    130
MONICA         0.166 48.847    131
ESTHER         0.166 49.013    132
PAULINE        0.165 49.178    133
EMMA           0.165 49.342    134
JUANITA        0.164 49.506    135
ANITA          0.162 49.669    136
RHONDA         0.162 49.830    137
HAZEL          0.161 49.991    138
AMBER          0.160 50.151    139
EVA            0.159 50.310    140
DEBBIE         0.157 50.467    141
APRIL          0.154 50.621    142
LESLIE         0.154 50.775    143
CLARA          0.153 50.928    144
LUCILLE        0.153 51.081    145
JAMIE          0.153 51.235    146
JOANNE         0.150 51.385    147
ELEANOR        0.150 51.535    148
VALERIE        0.149 51.684    149
DANIELLE       0.149 51.833    150
MEGAN          0.147 51.981    151
ALICIA         0.146 52.126    152
SUZANNE        0.145 52.272    153
MICHELE        0.145 52.417    154
GAIL           0.145 52.562    155
BERTHA         0.143 52.704    156
DARLENE        0.142 52.847    157
VERONICA       0.142 52.989    158
JILL           0.142 53.131    159
ERIN           0.141 53.272    160
GERALDINE      0.141 53.413    161
LAUREN         0.137 53.550    162
CATHY          0.137 53.687    163
JOANN          0.136 53.823    164
LORRAINE       0.135 53.958    165
LYNN           0.135 54.093    166
SALLY          0.135 54.228    167
REGINA         0.133 54.360    168
ERICA          0.130 54.490    169
BEATRICE       0.130 54.620    170
DOLORES        0.129 54.749    171
BERNICE        0.128 54.877    172
AUDREY         0.127 55.003    173
YVONNE         0.126 55.129    174
ANNETTE        0.125 55.255    175
JUNE           0.125 55.380    176
SAMANTHA       0.124 55.504    177
MARION         0.122 55.626    178
DANA           0.122 55.748    179
STACY          0.121 55.869    180
ANA            0.120 55.989    181
RENEE          0.120 56.109    182
IDA            0.118 56.227    183
VIVIAN         0.118 56.346    184
ROBERTA        0.117 56.463    185
HOLLY          0.117 56.580    186
BRITTANY       0.117 56.697    187
MELANIE        0.116 56.813    188
LORETTA        0.115 56.928    189
YOLANDA        0.115 57.043    190
JEANETTE       0.115 57.158    191
LAURIE         0.114 57.271    192
KATIE          0.113 57.385    193
KRISTEN        0.111 57.496    194
VANESSA        0.111 57.607    195
ALMA           0.111 57.718    196
SUE            0.111 57.829    197
ELSIE          0.110 57.939    198
BETH           0.110 58.049    199
JEANNE         0.109 58.158    200
VICKI          0.109 58.267    201
CARLA          0.107 58.374    202
TARA           0.107 58.482    203
ROSEMARY       0.107 58.589    204
EILEEN         0.105 58.694    205
TERRI          0.105 58.799    206
GERTRUDE       0.103 58.902    207
LUCY           0.103 59.005    208
TONYA          0.102 59.107    209
ELLA           0.101 59.208    210
STACEY         0.101 59.308    211
WILMA          0.099 59.408    212
GINA           0.099 59.506    213
KRISTIN        0.099 59.605    214
JESSIE         0.098 59.703    215
NATALIE        0.098 59.801    216
AGNES          0.098 59.899    217
VERA           0.098 59.997    218
WILLIE         0.097 60.094    219
CHARLENE       0.097 60.191    220
BESSIE         0.096 60.287    221
DELORES        0.095 60.382    222
MELINDA        0.094 60.477    223
PEARL          0.094 60.571    224
ARLENE         0.094 60.665    225
MAUREEN        0.092 60.757    226
COLLEEN        0.092 60.849    227
ALLISON        0.092 60.941    228
TAMARA         0.092 61.033    229
JOY            0.091 61.124    230
GEORGIA        0.091 61.215    231
CONSTANCE      0.091 61.305    232
LILLIE         0.090 61.396    233
CLAUDIA        0.090 61.485    234
JACKIE         0.090 61.575    235
MARCIA         0.090 61.665    236
TANYA          0.089 61.754    237
NELLIE         0.089 61.843    238
MINNIE         0.089 61.931    239
MARLENE        0.088 62.020    240
HEIDI          0.088 62.108    241
GLENDA         0.088 62.195    242
LYDIA          0.086 62.281    243
VIOLA          0.086 62.367    244
COURTNEY       0.086 62.453    245
MARIAN         0.086 62.539    246
STELLA         0.085 62.623    247
CAROLINE       0.085 62.708    248
DORA           0.084 62.792    249
JO             0.083 62.875    250
VICKIE         0.082 62.957    251
MATTIE         0.081 63.038    252
TERRY          0.080 63.118    253
MAXINE         0.079 63.198    254
IRMA           0.079 63.277    255
MABEL          0.078 63.355    256
MARSHA         0.078 63.434    257
MYRTLE         0.078 63.511    258
LENA           0.077 63.589    259
CHRISTY        0.077 63.665    260
DEANNA         0.076 63.742    261
PATSY          0.076 63.818    262
HILDA          0.075 63.893    263
GWENDOLYN      0.074 63.967    264
JENNIE         0.073 64.040    265
NORA           0.073 64.113    266
MARGIE         0.072 64.185    267
NINA           0.072 64.257    268
CASSANDRA      0.072 64.329    269
LEAH           0.072 64.401    270
PENNY          0.071 64.472    271
KAY            0.071 64.543    272
PRISCILLA      0.071 64.614    273
NAOMI          0.071 64.684    274
CAROLE         0.071 64.755    275
BRANDY         0.070 64.825    276
OLGA           0.070 64.895    277
BILLIE         0.069 64.964    278
DIANNE         0.069 65.033    279
TRACEY         0.069 65.102    280
LEONA          0.069 65.171    281
JENNY          0.068 65.239    282
FELICIA        0.068 65.307    283
SONIA          0.068 65.374    284
MIRIAM         0.066 65.440    285
VELMA          0.066 65.506    286
BECKY          0.066 65.572    287
BOBBIE         0.065 65.637    288
VIOLET         0.065 65.702    289
KRISTINA       0.065 65.767    290
TONI           0.064 65.831    291
MISTY          0.063 65.894    292
MAE            0.063 65.957    293
SHELLY         0.062 66.019    294
DAISY          0.062 66.081    295
RAMONA         0.062 66.143    296
SHERRI         0.062 66.205    297
ERIKA          0.061 66.267    298
KATRINA        0.061 66.328    299
CLAIRE         0.061 66.388    300
LINDSEY        0.060 66.448    301
LINDSAY        0.060 66.507    302
GENEVA         0.059 66.567    303
GUADALUPE      0.059 66.626    304
BELINDA        0.059 66.685    305
MARGARITA      0.059 66.743    306
SHERYL         0.059 66.802    307
CORA           0.058 66.860    308
FAYE           0.058 66.917    309
ADA            0.057 66.975    310
NATASHA        0.057 67.032    311
SABRINA        0.057 67.089    312
ISABEL         0.057 67.146    313
MARGUERITE     0.056 67.202    314
HATTIE         0.056 67.257    315
HARRIET        0.056 67.313    316
MOLLY          0.055 67.368    317
CECILIA        0.055 67.424    318
KRISTI         0.055 67.479    319
BRANDI         0.055 67.534    320
BLANCHE        0.055 67.589    321
SANDY          0.055 67.644    322
ROSIE          0.055 67.699    323
JOANNA         0.055 67.754    324
IRIS           0.055 67.808    325
EUNICE         0.054 67.863    326
ANGIE          0.054 67.917    327
INEZ           0.053 67.970    328
LYNDA          0.053 68.023    329
MADELINE       0.052 68.075    330
AMELIA         0.052 68.127    331
ALBERTA        0.052 68.179    332
GENEVIEVE      0.051 68.230    333
MONIQUE        0.051 68.282    334
JODI           0.051 68.333    335
JANIE          0.051 68.385    336
MAGGIE         0.051 68.436    337
KAYLA          0.051 68.487    338
SONYA          0.051 68.538    339
JAN            0.051 68.589    340
LEE            0.051 68.641    341
KRISTINE       0.051 68.691    342
CANDACE        0.051 68.742    343
FANNIE         0.050 68.792    344
MARYANN        0.050 68.843    345
OPAL           0.050 68.893    346
ALISON         0.050 68.943    347
YVETTE         0.050 68.993    348
MELODY         0.050 69.043    349
LUZ            0.049 69.092    350
SUSIE          0.049 69.142    351
OLIVIA         0.049 69.191    352
FLORA          0.049 69.240    353
SHELLEY        0.049 69.288    354
KRISTY         0.048 69.337    355
MAMIE          0.048 69.385    356
LULA           0.048 69.433    357
LOLA           0.048 69.482    358
VERNA          0.048 69.530    359
BEULAH         0.048 69.577    360
ANTOINETTE     0.048 69.625    361
CANDICE        0.046 69.671    362
JUANA          0.046 69.717    363
JEANNETTE      0.046 69.763    364
PAM            0.046 69.809    365
KELLI          0.046 69.854    366
HANNAH         0.045 69.899    367
WHITNEY        0.045 69.944    368
BRIDGET        0.045 69.989    369
KARLA          0.044 70.034    370
CELIA          0.044 70.078    371
LATOYA         0.043 70.121    372
PATTY          0.043 70.165    373
SHELIA         0.043 70.208    374
GAYLE          0.043 70.251    375
DELLA          0.043 70.294    376
VICKY          0.043 70.336    377
LYNNE          0.043 70.379    378
SHERI          0.042 70.421    379
MARIANNE       0.042 70.463    380
KARA           0.041 70.504    381
JACQUELYN      0.041 70.544    382
ERMA           0.041 70.585    383
BLANCA         0.041 70.626    384
MYRA           0.040 70.666    385
LETICIA        0.040 70.706    386
PAT            0.040 70.746    387
KRISTA         0.040 70.786    388
ROXANNE        0.040 70.826    389
ANGELICA       0.039 70.865    390
JOHNNIE        0.039 70.905    391
ROBYN          0.039 70.944    392
FRANCIS        0.039 70.983    393
ADRIENNE       0.039 71.022    394
ROSALIE        0.039 71.061    395
ALEXANDRA      0.039 71.100    396
BROOKE         0.039 71.139    397
BETHANY        0.039 71.177    398
SADIE          0.039 71.216    399
BERNADETTE     0.039 71.254    400
TRACI          0.038 71.293    401
JODY           0.038 71.331    402
KENDRA         0.038 71.369    403
JASMINE        0.038 71.407    404
NICHOLE        0.038 71.445    405
RACHAEL        0.038 71.483    406
CHELSEA        0.038 71.520    407
MABLE          0.038 71.558    408
ERNESTINE      0.038 71.596    409
MURIEL         0.038 71.634    410
MARCELLA       0.037 71.671    411
ELENA          0.037 71.708    412
KRYSTAL        0.037 71.745    413
ANGELINA       0.037 71.781    414
NADINE         0.036 71.818    415
KARI           0.036 71.853    416
ESTELLE        0.036 71.889    417
DIANNA         0.036 71.925    418
PAULETTE       0.036 71.961    419
LORA           0.036 71.996    420
MONA           0.035 72.032    421
DOREEN         0.035 72.067    422
ROSEMARIE      0.035 72.102    423
ANGEL          0.035 72.137    424
DESIREE        0.035 72.172    425
ANTONIA        0.035 72.207    426
HOPE           0.034 72.241    427
GINGER         0.034 72.274    428
JANIS          0.034 72.308    429
BETSY          0.034 72.342    430
CHRISTIE       0.034 72.375    431
FREDA          0.034 72.409    432
MERCEDES       0.033 72.442    433
MEREDITH       0.033 72.475    434
LYNETTE        0.033 72.508    435
TERI           0.033 72.541    436
CRISTINA       0.033 72.573    437
EULA           0.033 72.606    438
LEIGH          0.032 72.638    439
MEGHAN         0.032 72.670    440
SOPHIA         0.032 72.702    441
ELOISE         0.032 72.734    442
ROCHELLE       0.032 72.766    443
GRETCHEN       0.032 72.798    444
CECELIA        0.032 72.829    445
RAQUEL         0.031 72.860    446
HENRIETTA      0.031 72.891    447
ALYSSA         0.031 72.922    448
JANA           0.031 72.953    449
KELLEY         0.031 72.983    450
GWEN           0.031 73.014    451
KERRY          0.031 73.044    452
JENNA          0.030 73.075    453
TRICIA         0.030 73.105    454
LAVERNE        0.030 73.135    455
OLIVE          0.030 73.165    456
ALEXIS         0.030 73.195    457
TASHA          0.030 73.225    458
SILVIA         0.029 73.254    459
ELVIRA         0.029 73.284    460
CASEY          0.029 73.313    461
DELIA          0.029 73.342    462
SOPHIE         0.029 73.372    463
KATE           0.029 73.401    464
PATTI          0.029 73.430    465
LORENA         0.029 73.459    466
KELLIE         0.029 73.488    467
SONJA          0.029 73.517    468
LILA           0.029 73.546    469
LANA           0.029 73.575    470
DARLA          0.029 73.604    471
MAY            0.029 73.633    472
MINDY          0.029 73.661    473
ESSIE          0.029 73.690    474
MANDY          0.029 73.719    475
LORENE         0.028 73.747    476
ELSA           0.028 73.775    477
JOSEFINA       0.028 73.804    478
JEANNIE        0.028 73.832    479
MIRANDA        0.028 73.860    480
DIXIE          0.028 73.888    481
LUCIA          0.028 73.916    482
MARTA          0.028 73.944    483
FAITH          0.028 73.972    484
LELA           0.028 73.999    485
JOHANNA        0.028 74.027    486
SHARI          0.028 74.055    487
CAMILLE        0.028 74.082    488
TAMI           0.027 74.110    489
SHAWNA         0.027 74.137    490
ELISA          0.027 74.164    491
EBONY          0.027 74.192    492
MELBA          0.027 74.219    493
ORA            0.027 74.246    494
NETTIE         0.027 74.273    495
TABITHA        0.027 74.300    496
OLLIE          0.027 74.327    497
JAIME          0.027 74.354    498
WINIFRED       0.027 74.381    499
KRISTIE        0.027 74.408    500
MARINA         0.027 74.435    501
ALISHA         0.027 74.462    502
AIMEE          0.027 74.488    503
RENA           0.027 74.515    504
MYRNA          0.026 74.541    505
MARLA          0.026 74.567    506
TAMMIE         0.026 74.593    507
LATASHA        0.026 74.619    508
BONITA         0.026 74.645    509
PATRICE        0.026 74.671    510
RONDA          0.026 74.697    511
SHERRIE        0.026 74.722    512
ADDIE          0.026 74.748    513
FRANCINE       0.025 74.773    514
DELORIS        0.025 74.799    515
STACIE         0.025 74.824    516
ADRIANA        0.025 74.849    517
CHERI          0.025 74.874    518
SHELBY         0.025 74.899    519
ABIGAIL        0.025 74.924    520
CELESTE        0.025 74.949    521
JEWEL          0.025 74.974    522
CARA           0.025 74.999    523
ADELE          0.025 75.024    524
REBEKAH        0.025 75.048    525
LUCINDA        0.025 75.073    526
DORTHY         0.025 75.097    527
CHRIS          0.024 75.122    528
EFFIE          0.024 75.146    529
TRINA          0.024 75.171    530
REBA           0.024 75.195    531
SHAWN          0.024 75.219    532
SALLIE         0.024 75.244    533
AURORA         0.024 75.268    534
LENORA         0.024 75.292    535
ETTA           0.024 75.317    536
LOTTIE         0.024 75.341    537
KERRI          0.024 75.365    538
TRISHA         0.024 75.389    539
NIKKI          0.024 75.413    540
ESTELLA        0.024 75.438    541
FRANCISCA      0.024 75.461    542
JOSIE          0.024 75.485    543
TRACIE         0.024 75.509    544
MARISSA        0.024 75.533    545
KARIN          0.024 75.557    546
BRITTNEY       0.024 75.580    547
JANELLE        0.024 75.604    548
LOURDES        0.024 75.628    549
LAUREL         0.024 75.651    550
HELENE         0.024 75.675    551
FERN           0.024 75.698    552
ELVA           0.024 75.722    553
CORINNE        0.024 75.745    554
KELSEY         0.024 75.769    555
INA            0.023 75.792    556
BETTIE         0.023 75.816    557
ELISABETH      0.023 75.839    558
AIDA           0.023 75.862    559
CAITLIN        0.023 75.886    560
INGRID         0.023 75.909    561
IVA            0.023 75.932    562
EUGENIA        0.023 75.955    563
CHRISTA        0.023 75.978    564
GOLDIE         0.023 76.000    565
CASSIE         0.023 76.023    566
MAUDE          0.023 76.046    567
JENIFER        0.023 76.068    568
THERESE        0.022 76.091    569
FRANKIE        0.022 76.113    570
DENA           0.022 76.136    571
LORNA          0.022 76.158    572
JANETTE        0.022 76.180    573
LATONYA        0.022 76.202    574
CANDY          0.022 76.224    575
MORGAN         0.022 76.247    576
CONSUELO       0.022 76.269    577
TAMIKA         0.022 76.291    578
ROSETTA        0.022 76.313    579
DEBORA         0.022 76.334    580
CHERIE         0.022 76.356    581
POLLY          0.022 76.378    582
DINA           0.022 76.400    583
JEWELL         0.021 76.421    584
FAY            0.021 76.442    585
JILLIAN        0.021 76.464    586
DOROTHEA       0.021 76.485    587
NELL           0.021 76.506    588
TRUDY          0.021 76.527    589
ESPERANZA      0.021 76.548    590
PATRICA        0.021 76.570    591
KIMBERLEY      0.021 76.591    592
SHANNA         0.021 76.611    593
HELENA         0.021 76.632    594
CAROLINA       0.021 76.653    595
CLEO           0.021 76.674    596
STEFANIE       0.021 76.694    597
ROSARIO        0.020 76.715    598
OLA            0.020 76.735    599
JANINE         0.020 76.756    600
MOLLIE         0.020 76.776    601
LUPE           0.020 76.796    602
ALISA          0.020 76.816    603
LOU            0.020 76.836    604
MARIBEL        0.020 76.856    605
SUSANNE        0.020 76.875    606
BETTE          0.019 76.895    607
SUSANA         0.019 76.914    608
ELISE          0.019 76.933    609
CECILE         0.019 76.953    610
ISABELLE       0.019 76.972    611
LESLEY         0.019 76.991    612
JOCELYN        0.019 77.010    613
PAIGE          0.019 77.030    614
JONI           0.019 77.049    615
RACHELLE       0.019 77.068    616
LEOLA          0.019 77.087    617
DAPHNE         0.019 77.106    618
ALTA           0.019 77.125    619
ESTER          0.019 77.144    620
PETRA          0.019 77.162    621
GRACIELA       0.019 77.181    622
IMOGENE        0.019 77.200    623
JOLENE         0.019 77.219    624
KEISHA         0.019 77.237    625
LACEY          0.018 77.256    626
GLENNA         0.018 77.274    627
GABRIELA       0.018 77.293    628
KERI           0.018 77.311    629
URSULA         0.018 77.329    630
LIZZIE         0.018 77.347    631
KIRSTEN        0.018 77.366    632
SHANA          0.018 77.384    633
ADELINE        0.018 77.402    634
MAYRA          0.018 77.420    635
JAYNE          0.018 77.438    636
JACLYN         0.018 77.456    637
GRACIE         0.018 77.474    638
SONDRA         0.018 77.492    639
CARMELA        0.018 77.509    640
MARISA         0.018 77.527    641
ROSALIND       0.018 77.545    642
CHARITY        0.018 77.563    643
TONIA          0.018 77.580    644
BEATRIZ        0.018 77.598    645
MARISOL        0.018 77.616    646
CLARICE        0.018 77.633    647
JEANINE        0.017 77.651    648
SHEENA         0.017 77.668    649
ANGELINE       0.017 77.685    650
FRIEDA         0.017 77.703    651
LILY           0.017 77.720    652
ROBBIE         0.017 77.737    653
SHAUNA         0.017 77.754    654
MILLIE         0.017 77.771    655
CLAUDETTE      0.017 77.788    656
CATHLEEN       0.017 77.805    657
ANGELIA        0.017 77.822    658
GABRIELLE      0.017 77.839    659
AUTUMN         0.017 77.856    660
KATHARINE      0.017 77.873    661
SUMMER         0.017 77.890    662
JODIE          0.017 77.907    663
STACI          0.017 77.923    664
LEA            0.017 77.940    665
CHRISTI        0.017 77.957    666
JIMMIE         0.017 77.974    667
JUSTINE        0.017 77.990    668
ELMA           0.017 78.007    669
LUELLA         0.017 78.023    670
MARGRET        0.017 78.040    671
DOMINIQUE      0.016 78.056    672
SOCORRO        0.016 78.073    673
RENE           0.016 78.089    674
MARTINA        0.016 78.105    675
MARGO          0.016 78.122    676
MAVIS          0.016 78.138    677
CALLIE         0.016 78.154    678
BOBBI          0.016 78.170    679
MARITZA        0.016 78.186    680
LUCILE         0.016 78.202    681
LEANNE         0.016 78.219    682
JEANNINE       0.016 78.235    683
DEANA          0.016 78.251    684
AILEEN         0.016 78.267    685
LORIE          0.016 78.282    686
LADONNA        0.016 78.298    687
WILLA          0.016 78.314    688
MANUELA        0.016 78.330    689
GALE           0.016 78.346    690
SELMA          0.016 78.361    691
DOLLY          0.016 78.377    692
SYBIL          0.016 78.393    693
ABBY           0.016 78.408    694
LARA           0.016 78.424    695
DALE           0.016 78.440    696
IVY            0.016 78.455    697
DEE            0.016 78.471    698
WINNIE         0.016 78.486    699
MARCY          0.016 78.502    700
LUISA          0.016 78.517    701
JERI           0.015 78.533    702
MAGDALENA      0.015 78.548    703
OFELIA         0.015 78.563    704
MEAGAN         0.015 78.579    705
AUDRA          0.015 78.594    706
MATILDA        0.015 78.609    707
LEILA          0.015 78.624    708
CORNELIA       0.015 78.639    709
BIANCA         0.015 78.654    710
SIMONE         0.015 78.669    711
BETTYE         0.015 78.684    712
RANDI          0.015 78.699    713
VIRGIE         0.015 78.713    714
LATISHA        0.015 78.728    715
BARBRA         0.015 78.743    716
GEORGINA       0.015 78.758    717
ELIZA          0.015 78.772    718
LEANN          0.015 78.787    719
BRIDGETTE      0.015 78.801    720
RHODA          0.014 78.816    721
HALEY          0.014 78.830    722
ADELA          0.014 78.845    723
NOLA           0.014 78.859    724
BERNADINE      0.014 78.873    725
FLOSSIE        0.014 78.887    726
ILA            0.014 78.902    727
GRETA          0.014 78.916    728
RUTHIE         0.014 78.930    729
NELDA          0.014 78.944    730
MINERVA        0.014 78.958    731
LILLY          0.014 78.973    732
TERRIE         0.014 78.987    733
LETHA          0.014 79.001    734
HILARY         0.014 79.015    735
ESTELA         0.014 79.029    736
VALARIE        0.014 79.043    737
BRIANNA        0.014 79.057    738
ROSALYN        0.014 79.071    739
EARLINE        0.014 79.085    740
CATALINA       0.014 79.099    741
AVA            0.014 79.113    742
MIA            0.014 79.127    743
CLARISSA       0.014 79.141    744
LIDIA          0.014 79.155    745
CORRINE        0.014 79.169    746
ALEXANDRIA     0.014 79.183    747
CONCEPCION     0.014 79.196    748
TIA            0.014 79.210    749
SHARRON        0.014 79.224    750
RAE            0.014 79.238    751
DONA           0.014 79.251    752
ERICKA         0.014 79.265    753
JAMI           0.014 79.278    754
ELNORA         0.014 79.292    755
CHANDRA        0.014 79.306    756
LENORE         0.014 79.319    757
NEVA           0.013 79.333    758
MARYLOU        0.013 79.346    759
MELISA         0.013 79.360    760
TABATHA        0.013 79.373    761
SERENA         0.013 79.386    762
AVIS           0.013 79.400    763
ALLIE          0.013 79.413    764
SOFIA          0.013 79.426    765
JEANIE         0.013 79.439    766
ODESSA         0.013 79.453    767
NANNIE         0.013 79.466    768
HARRIETT       0.013 79.479    769
LORAINE        0.013 79.492    770
PENELOPE       0.013 79.505    771
MILAGROS       0.013 79.518    772
EMILIA         0.013 79.531    773
BENITA         0.013 79.544    774
ALLYSON        0.013 79.557    775
ASHLEE         0.013 79.570    776
TANIA          0.013 79.583    777
TOMMIE         0.013 79.596    778
ESMERALDA      0.013 79.608    779
KARINA         0.013 79.621    780
EVE            0.013 79.634    781
PEARLIE        0.013 79.647    782
ZELMA          0.013 79.659    783
MALINDA        0.013 79.672    784
NOREEN         0.013 79.684    785
TAMEKA         0.013 79.697    786
SAUNDRA        0.013 79.710    787
HILLARY        0.013 79.722    788
AMIE           0.013 79.735    789
ALTHEA         0.012 79.747    790
ROSALINDA      0.012 79.760    791
JORDAN         0.012 79.772    792
LILIA          0.012 79.784    793
ALANA          0.012 79.797    794
GAY            0.012 79.809    795
CLARE          0.012 79.821    796
ALEJANDRA      0.012 79.834    797
ELINOR         0.012 79.846    798
MICHAEL        0.012 79.858    799
LORRIE         0.012 79.870    800
JERRI          0.012 79.882    801
DARCY          0.012 79.895    802
EARNESTINE     0.012 79.907    803
CARMELLA       0.012 79.919    804
TAYLOR         0.012 79.931    805
NOEMI          0.012 79.943    806
MARCIE         0.012 79.954    807
LIZA           0.012 79.966    808
ANNABELLE      0.012 79.978    809
LOUISA         0.012 79.990    810
EARLENE        0.012 80.002    811
MALLORY        0.012 80.014    812
CARLENE        0.012 80.025    813
NITA           0.012 80.037    814
SELENA         0.012 80.049    815
TANISHA        0.012 80.060    816
KATY           0.012 80.072    817
JULIANNE       0.012 80.083    818
JOHN           0.012 80.095    819
LAKISHA        0.011 80.106    820
EDWINA         0.011 80.118    821
MARICELA       0.011 80.129    822
MARGERY        0.011 80.141    823
KENYA          0.011 80.152    824
DOLLIE         0.011 80.164    825
ROXIE          0.011 80.175    826
ROSLYN         0.011 80.187    827
KATHRINE       0.011 80.198    828
NANETTE        0.011 80.209    829
CHARMAINE      0.011 80.221    830
LAVONNE        0.011 80.232    831
ILENE          0.011 80.243    832
KRIS           0.011 80.255    833
TAMMI          0.011 80.266    834
SUZETTE        0.011 80.277    835
CORINE         0.011 80.288    836
KAYE           0.011 80.300    837
JERRY          0.011 80.311    838
MERLE          0.011 80.322    839
CHRYSTAL       0.011 80.333    840
LINA           0.011 80.344    841
DEANNE         0.011 80.355    842
LILIAN         0.011 80.366    843
JULIANA        0.011 80.377    844
ALINE          0.011 80.388    845
LUANN          0.011 80.399    846
KASEY          0.011 80.410    847
MARYANNE       0.011 80.421    848
EVANGELINE     0.011 80.432    849
COLETTE        0.011 80.443    850
MELVA          0.011 80.453    851
LAWANDA        0.011 80.464    852
YESENIA        0.011 80.475    853
NADIA          0.011 80.486    854
MADGE          0.011 80.497    855
KATHIE         0.011 80.507    856
EDDIE          0.011 80.518    857
OPHELIA        0.011 80.529    858
VALERIA        0.011 80.539    859
NONA           0.011 80.550    860
MITZI          0.011 80.561    861
MARI           0.011 80.571    862
GEORGETTE      0.011 80.582    863
CLAUDINE       0.011 80.592    864
FRAN           0.011 80.603    865
ALISSA         0.011 80.613    866
ROSEANN        0.010 80.624    867
LAKEISHA       0.010 80.634    868
SUSANNA        0.010 80.645    869
REVA           0.010 80.655    870
DEIDRE         0.010 80.665    871
CHASITY        0.010 80.676    872
SHEREE         0.010 80.686    873
CARLY          0.010 80.697    874
JAMES          0.010 80.707    875
ELVIA          0.010 80.717    876
ALYCE          0.010 80.728    877
DEIRDRE        0.010 80.738    878
GENA           0.010 80.748    879
BRIANA         0.010 80.758    880
ARACELI        0.010 80.769    881
KATELYN        0.010 80.779    882
ROSANNE        0.010 80.789    883
WENDI          0.010 80.799    884
TESSA          0.010 80.810    885
BERTA          0.010 80.820    886
MARVA          0.010 80.830    887
IMELDA         0.010 80.840    888
MARIETTA       0.010 80.850    889
MARCI          0.010 80.860    890
LEONOR         0.010 80.870    891
ARLINE         0.010 80.880    892
SASHA          0.010 80.890    893
MADELYN        0.010 80.900    894
JANNA          0.010 80.910    895
JULIETTE       0.010 80.920    896
DEENA          0.010 80.929    897
AURELIA        0.010 80.939    898
JOSEFA         0.010 80.949    899
AUGUSTA        0.010 80.959    900
LILIANA        0.010 80.968    901
YOUNG          0.010 80.978    902
CHRISTIAN      0.010 80.988    903
LESSIE         0.010 80.997    904
AMALIA         0.010 81.007    905
SAVANNAH       0.010 81.017    906
ANASTASIA      0.010 81.026    907
VILMA          0.010 81.036    908
NATALIA        0.010 81.045    909
ROSELLA        0.010 81.055    910
LYNNETTE       0.010 81.064    911
CORINA         0.010 81.074    912
ALFREDA        0.009 81.083    913
LEANNA         0.009 81.093    914
CAREY          0.009 81.102    915
AMPARO         0.009 81.112    916
COLEEN         0.009 81.121    917
TAMRA          0.009 81.131    918
AISHA          0.009 81.140    919
WILDA          0.009 81.149    920
KARYN          0.009 81.159    921
CHERRY         0.009 81.168    922
QUEEN          0.009 81.177    923
MAURA          0.009 81.187    924
MAI            0.009 81.196    925
EVANGELINA     0.009 81.205    926
ROSANNA        0.009 81.214    927
HALLIE         0.009 81.224    928
ERNA           0.009 81.233    929
ENID           0.009 81.242    930
MARIANA        0.009 81.251    931
LACY           0.009 81.260    932
JULIET         0.009 81.270    933
JACKLYN        0.009 81.279    934
FREIDA         0.009 81.288    935
MADELEINE      0.009 81.297    936
MARA           0.009 81.306    937
HESTER         0.009 81.315    938
CATHRYN        0.009 81.324    939
LELIA          0.009 81.333    940
CASANDRA       0.009 81.343    941
BRIDGETT       0.009 81.352    942
ANGELITA       0.009 81.361    943
JANNIE         0.009 81.370    944
DIONNE         0.009 81.379    945
ANNMARIE       0.009 81.388    946
KATINA         0.009 81.397    947
BERYL          0.009 81.405    948
PHOEBE         0.009 81.414    949
MILLICENT      0.009 81.423    950
KATHERYN       0.009 81.432    951
DIANN          0.009 81.441    952
CARISSA        0.009 81.450    953
MARYELLEN      0.009 81.459    954
LIZ            0.009 81.468    955
LAURI          0.009 81.476    956
HELGA          0.009 81.485    957
GILDA          0.009 81.494    958
ADRIAN         0.009 81.503    959
RHEA           0.009 81.511    960
MARQUITA       0.009 81.520    961
HOLLIE         0.009 81.529    962
TISHA          0.009 81.538    963
TAMERA         0.009 81.546    964
ANGELIQUE      0.009 81.555    965
FRANCESCA      0.009 81.564    966
BRITNEY        0.009 81.573    967
KAITLIN        0.009 81.581    968
LOLITA         0.009 81.590    969
FLORINE        0.009 81.599    970
ROWENA         0.009 81.607    971
REYNA          0.009 81.616    972
TWILA          0.009 81.624    973
FANNY          0.009 81.633    974
JANELL         0.009 81.641    975
INES           0.009 81.650    976
CONCETTA       0.009 81.658    977
BERTIE         0.009 81.667    978
ALBA           0.009 81.676    979
BRIGITTE       0.009 81.684    980
ALYSON         0.009 81.693    981
VONDA          0.008 81.701    982
PANSY          0.008 81.710    983
ELBA           0.008 81.718    984
NOELLE         0.008 81.726    985
LETITIA        0.008 81.735    986
KITTY          0.008 81.743    987
DEANN          0.008 81.752    988
BRANDIE        0.008 81.760    989
LOUELLA        0.008 81.769    990
LETA           0.008 81.777    991
FELECIA        0.008 81.786    992
SHARLENE       0.008 81.794    993
LESA           0.008 81.802    994
BEVERLEY       0.008 81.811    995
ROBERT         0.008 81.819    996
ISABELLA       0.008 81.827    997
HERMINIA       0.008 81.836    998
TERRA          0.008 81.844    999
CELINA         0.008 81.852   1000
TORI           0.008 81.861   1001
OCTAVIA        0.008 81.869   1002
JADE           0.008 81.877   1003
DENICE         0.008 81.885   1004
GERMAINE       0.008 81.894   1005
SIERRA         0.008 81.902   1006
MICHELL        0.008 81.910   1007
CORTNEY        0.008 81.918   1008
NELLY          0.008 81.926   1009
DORETHA        0.008 81.934   1010
SYDNEY         0.008 81.943   1011
DEIDRA         0.008 81.951   1012
MONIKA         0.008 81.959   1013
LASHONDA       0.008 81.967   1014
JUDI           0.008 81.975   1015
CHELSEY        0.008 81.983   1016
ANTIONETTE     0.008 81.991   1017
MARGOT         0.008 81.999   1018
BOBBY          0.008 82.007   1019
ADELAIDE       0.008 82.015   1020
NAN            0.008 82.023   1021
LEEANN         0.008 82.030   1022
ELISHA         0.008 82.038   1023
DESSIE         0.008 82.046   1024
LIBBY          0.008 82.054   1025
KATHI          0.008 82.062   1026
GAYLA          0.008 82.070   1027
LATANYA        0.008 82.078   1028
MINA           0.008 82.086   1029
MELLISA        0.008 82.093   1030
KIMBERLEE      0.008 82.101   1031
JASMIN         0.008 82.109   1032
RENAE          0.008 82.117   1033
ZELDA          0.008 82.125   1034
ELDA           0.008 82.132   1035
MA             0.008 82.140   1036
JUSTINA        0.008 82.148   1037
GUSSIE         0.008 82.156   1038
EMILIE         0.008 82.163   1039
CAMILLA        0.008 82.171   1040
ABBIE          0.008 82.179   1041
ROCIO          0.008 82.186   1042
KAITLYN        0.008 82.194   1043
JESSE          0.008 82.202   1044
EDYTHE         0.008 82.209   1045
ASHLEIGH       0.008 82.217   1046
SELINA         0.008 82.225   1047
LAKESHA        0.008 82.232   1048
GERI           0.008 82.240   1049
ALLENE         0.008 82.248   1050
PAMALA         0.008 82.255   1051
MICHAELA       0.008 82.263   1052
DAYNA          0.008 82.270   1053
CARYN          0.008 82.278   1054
ROSALIA        0.008 82.286   1055
SUN            0.007 82.293   1056
JACQULINE      0.007 82.301   1057
REBECA         0.007 82.308   1058
MARYBETH       0.007 82.315   1059
KRYSTLE        0.007 82.323   1060
IOLA           0.007 82.330   1061
DOTTIE         0.007 82.338   1062
BENNIE         0.007 82.345   1063
BELLE          0.007 82.353   1064
AUBREY         0.007 82.360   1065
GRISELDA       0.007 82.367   1066
ERNESTINA      0.007 82.375   1067
ELIDA          0.007 82.382   1068
ADRIANNE       0.007 82.390   1069
DEMETRIA       0.007 82.397   1070
DELMA          0.007 82.404   1071
CHONG          0.007 82.412   1072
JAQUELINE      0.007 82.419   1073
DESTINY        0.007 82.427   1074
ARLEEN         0.007 82.434   1075
VIRGINA        0.007 82.441   1076
RETHA          0.007 82.448   1077
FATIMA         0.007 82.456   1078
TILLIE         0.007 82.463   1079
ELEANORE       0.007 82.470   1080
CARI           0.007 82.478   1081
TREVA          0.007 82.485   1082
BIRDIE         0.007 82.492   1083
WILHELMINA     0.007 82.499   1084
ROSALEE        0.007 82.506   1085
MAURINE        0.007 82.514   1086
LATRICE        0.007 82.521   1087
YONG           0.007 82.528   1088
JENA           0.007 82.535   1089
TARYN          0.007 82.542   1090
ELIA           0.007 82.549   1091
DEBBY          0.007 82.556   1092
MAUDIE         0.007 82.564   1093
JEANNA         0.007 82.571   1094
DELILAH        0.007 82.578   1095
CATRINA        0.007 82.585   1096
SHONDA         0.007 82.592   1097
HORTENCIA      0.007 82.599   1098
THEODORA       0.007 82.606   1099
TERESITA       0.007 82.613   1100
ROBBIN         0.007 82.620   1101
DANETTE        0.007 82.627   1102
MARYJANE       0.007 82.634   1103
FREDDIE        0.007 82.641   1104
DELPHINE       0.007 82.648   1105
BRIANNE        0.007 82.655   1106
NILDA          0.007 82.662   1107
DANNA          0.007 82.669   1108
CINDI          0.007 82.676   1109
BESS           0.007 82.683   1110
IONA           0.007 82.690   1111
HANNA          0.007 82.697   1112
ARIEL          0.007 82.704   1113
WINONA         0.007 82.711   1114
VIDA           0.007 82.718   1115
ROSITA         0.007 82.725   1116
MARIANNA       0.007 82.731   1117
WILLIAM        0.007 82.738   1118
RACHEAL        0.007 82.745   1119
GUILLERMINA    0.007 82.752   1120
ELOISA         0.007 82.759   1121
CELESTINE      0.007 82.766   1122
CAREN          0.007 82.773   1123
MALISSA        0.007 82.780   1124
LONA           0.007 82.786   1125
CHANTEL        0.007 82.793   1126
SHELLIE        0.007 82.800   1127
MARISELA       0.007 82.807   1128
LEORA          0.007 82.814   1129
AGATHA         0.007 82.820   1130
SOLEDAD        0.007 82.827   1131
MIGDALIA       0.007 82.834   1132
IVETTE         0.007 82.840   1133
CHRISTEN       0.007 82.847   1134
ATHENA         0.007 82.854   1135
JANEL          0.007 82.861   1136
CHLOE          0.007 82.867   1137
VEDA           0.007 82.874   1138
PATTIE         0.007 82.881   1139
TESSIE         0.007 82.887   1140
TERA           0.007 82.894   1141
MARILYNN       0.007 82.901   1142
LUCRETIA       0.007 82.907   1143
KARRIE         0.007 82.914   1144
DINAH          0.007 82.920   1145
DANIELA        0.007 82.927   1146
ALECIA         0.007 82.934   1147
ADELINA        0.007 82.940   1148
VERNICE        0.007 82.947   1149
SHIELA         0.007 82.953   1150
PORTIA         0.007 82.960   1151
MERRY          0.007 82.967   1152
LASHAWN        0.007 82.973   1153
DEVON          0.007 82.980   1154
DARA           0.007 82.986   1155
TAWANA         0.007 82.993   1156
OMA            0.007 82.999   1157
VERDA          0.007 83.006   1158
CHRISTIN       0.007 83.012   1159
ALENE          0.007 83.019   1160
ZELLA          0.006 83.025   1161
SANDI          0.006 83.032   1162
RAFAELA        0.006 83.038   1163
MAYA           0.006 83.045   1164
KIRA           0.006 83.051   1165
CANDIDA        0.006 83.058   1166
ALVINA         0.006 83.064   1167
SUZAN          0.006 83.071   1168
SHAYLA         0.006 83.077   1169
LYN            0.006 83.083   1170
LETTIE         0.006 83.090   1171
ALVA           0.006 83.096   1172
SAMATHA        0.006 83.103   1173
ORALIA         0.006 83.109   1174
MATILDE        0.006 83.115   1175
MADONNA        0.006 83.122   1176
LARISSA        0.006 83.128   1177
VESTA          0.006 83.134   1178
RENITA         0.006 83.141   1179
INDIA          0.006 83.147   1180
DELOIS         0.006 83.153   1181
SHANDA         0.006 83.159   1182
PHILLIS        0.006 83.166   1183
LORRI          0.006 83.172   1184
ERLINDA        0.006 83.178   1185
CRUZ           0.006 83.185   1186
CATHRINE       0.006 83.191   1187
BARB           0.006 83.197   1188
ZOE            0.006 83.203   1189
ISABELL        0.006 83.210   1190
IONE           0.006 83.216   1191
GISELA         0.006 83.222   1192
CHARLIE        0.006 83.228   1193
VALENCIA       0.006 83.235   1194
ROXANNA        0.006 83.241   1195
MAYME          0.006 83.247   1196
KISHA          0.006 83.253   1197
ELLIE          0.006 83.259   1198
MELLISSA       0.006 83.266   1199
DORRIS         0.006 83.272   1200
DALIA          0.006 83.278   1201
BELLA          0.006 83.284   1202
ANNETTA        0.006 83.290   1203
ZOILA          0.006 83.296   1204
RETA           0.006 83.302   1205
REINA          0.006 83.308   1206
LAURETTA       0.006 83.315   1207
KYLIE          0.006 83.321   1208
CHRISTAL       0.006 83.327   1209
PILAR          0.006 83.333   1210
CHARLA         0.006 83.339   1211
ELISSA         0.006 83.345   1212
TIFFANI        0.006 83.351   1213
TANA           0.006 83.357   1214
PAULINA        0.006 83.363   1215
LEOTA          0.006 83.369   1216
BREANNA        0.006 83.375   1217
JAYME          0.006 83.381   1218
CARMEL         0.006 83.387   1219
VERNELL        0.006 83.393   1220
TOMASA         0.006 83.399   1221
MANDI          0.006 83.405   1222
DOMINGA        0.006 83.411   1223
SANTA          0.006 83.417   1224
MELODIE        0.006 83.423   1225
LURA           0.006 83.429   1226
ALEXA          0.006 83.435   1227
TAMELA         0.006 83.441   1228
RYAN           0.006 83.447   1229
MIRNA          0.006 83.453   1230
KERRIE         0.006 83.458   1231
VENUS          0.006 83.464   1232
NOEL           0.006 83.470   1233
FELICITA       0.006 83.476   1234
CRISTY         0.006 83.482   1235
CARMELITA      0.006 83.488   1236
BERNIECE       0.006 83.494   1237
ANNEMARIE      0.006 83.500   1238
TIARA          0.006 83.505   1239
ROSEANNE       0.006 83.511   1240
MISSY          0.006 83.517   1241
CORI           0.006 83.523   1242
ROXANA         0.006 83.529   1243
PRICILLA       0.006 83.535   1244
KRISTAL        0.006 83.540   1245
JUNG           0.006 83.546   1246
ELYSE          0.006 83.552   1247
HAYDEE         0.006 83.558   1248
ALETHA         0.006 83.564   1249
BETTINA        0.006 83.569   1250
MARGE          0.006 83.575   1251
GILLIAN        0.006 83.581   1252
FILOMENA       0.006 83.586   1253
CHARLES        0.006 83.592   1254
ZENAIDA        0.006 83.598   1255
HARRIETTE      0.006 83.603   1256
CARIDAD        0.006 83.609   1257
VADA           0.006 83.615   1258
UNA            0.006 83.620   1259
ARETHA         0.006 83.626   1260
PEARLINE       0.006 83.632   1261
MARJORY        0.006 83.637   1262
MARCELA        0.006 83.643   1263
FLOR           0.006 83.648   1264
EVETTE         0.006 83.654   1265
ELOUISE        0.006 83.659   1266
ALINA          0.006 83.665   1267
TRINIDAD       0.006 83.671   1268
DAVID          0.006 83.676   1269
DAMARIS        0.006 83.682   1270
CATHARINE      0.006 83.687   1271
CARROLL        0.006 83.693   1272
BELVA          0.006 83.698   1273
NAKIA          0.005 83.704   1274
MARLENA        0.005 83.709   1275
LUANNE         0.005 83.715   1276
LORINE         0.005 83.720   1277
KARON          0.005 83.726   1278
DORENE         0.005 83.731   1279
DANITA         0.005 83.737   1280
BRENNA         0.005 83.742   1281
TATIANA        0.005 83.748   1282
SAMMIE         0.005 83.753   1283
LOUANN         0.005 83.759   1284
LOREN          0.005 83.764   1285
JULIANNA       0.005 83.770   1286
ANDRIA         0.005 83.775   1287
PHILOMENA      0.005 83.780   1288
LUCILA         0.005 83.786   1289
LEONORA        0.005 83.791   1290
DOVIE          0.005 83.797   1291
ROMONA         0.005 83.802   1292
MIMI           0.005 83.808   1293
JACQUELIN      0.005 83.813   1294
GAYE           0.005 83.818   1295
TONJA          0.005 83.824   1296
MISTI          0.005 83.829   1297
JOE            0.005 83.835   1298
GENE           0.005 83.840   1299
CHASTITY       0.005 83.845   1300
STACIA         0.005 83.851   1301
ROXANN         0.005 83.856   1302
MICAELA        0.005 83.861   1303
NIKITA         0.005 83.867   1304
MEI            0.005 83.872   1305
VELDA          0.005 83.877   1306
MARLYS         0.005 83.882   1307
JOHNNA         0.005 83.888   1308
AURA           0.005 83.893   1309
LAVERN         0.005 83.898   1310
IVONNE         0.005 83.903   1311
HAYLEY         0.005 83.909   1312
NICKI          0.005 83.914   1313
MAJORIE        0.005 83.919   1314
HERLINDA       0.005 83.924   1315
GEORGE         0.005 83.930   1316
ALPHA          0.005 83.935   1317
YADIRA         0.005 83.940   1318
PERLA          0.005 83.945   1319
GREGORIA       0.005 83.950   1320
DANIEL         0.005 83.955   1321
ANTONETTE      0.005 83.961   1322
SHELLI         0.005 83.966   1323
MOZELLE        0.005 83.971   1324
MARIAH         0.005 83.976   1325
JOELLE         0.005 83.981   1326
CORDELIA       0.005 83.986   1327
JOSETTE        0.005 83.992   1328
CHIQUITA       0.005 83.997   1329
TRISTA         0.005 84.002   1330
LOUIS          0.005 84.007   1331
LAQUITA        0.005 84.012   1332
GEORGIANA      0.005 84.017   1333
CANDI          0.005 84.022   1334
SHANON         0.005 84.027   1335
LONNIE         0.005 84.032   1336
HILDEGARD      0.005 84.037   1337
CECIL          0.005 84.042   1338
VALENTINA      0.005 84.047   1339
STEPHANY       0.005 84.052   1340
MAGDA          0.005 84.057   1341
KAROL          0.005 84.062   1342
GERRY          0.005 84.067   1343
GABRIELLA      0.005 84.072   1344
TIANA          0.005 84.077   1345
ROMA           0.005 84.082   1346
RICHELLE       0.005 84.087   1347
RAY            0.005 84.092   1348
PRINCESS       0.005 84.097   1349
OLETA          0.005 84.102   1350
JACQUE         0.005 84.107   1351
IDELLA         0.005 84.112   1352
ALAINA         0.005 84.117   1353
SUZANNA        0.005 84.122   1354
JOVITA         0.005 84.127   1355
BLAIR          0.005 84.132   1356
TOSHA          0.005 84.137   1357
RAVEN          0.005 84.142   1358
NEREIDA        0.005 84.147   1359
MARLYN         0.005 84.152   1360
KYLA           0.005 84.157   1361
JOSEPH         0.005 84.162   1362
DELFINA        0.005 84.167   1363
TENA           0.005 84.172   1364
STEPHENIE      0.005 84.177   1365
SABINA         0.005 84.182   1366
NATHALIE       0.005 84.186   1367
MARCELLE       0.005 84.191   1368
GERTIE         0.005 84.196   1369
DARLEEN        0.005 84.201   1370
THEA           0.005 84.206   1371
SHARONDA       0.005 84.211   1372
SHANTEL        0.005 84.216   1373
BELEN          0.005 84.221   1374
VENESSA        0.005 84.225   1375
ROSALINA       0.005 84.230   1376
ONA            0.005 84.235   1377
GENOVEVA       0.005 84.240   1378
COREY          0.005 84.245   1379
CLEMENTINE     0.005 84.250   1380
ROSALBA        0.005 84.254   1381
RENATE         0.005 84.259   1382
RENATA         0.005 84.264   1383
MI             0.005 84.269   1384
IVORY          0.005 84.274   1385
GEORGIANNA     0.005 84.278   1386
FLOY           0.005 84.283   1387
DORCAS         0.005 84.288   1388
ARIANA         0.005 84.293   1389
TYRA           0.005 84.298   1390
THEDA          0.005 84.302   1391
MARIAM         0.005 84.307   1392
JULI           0.005 84.312   1393
JESICA         0.005 84.317   1394
DONNIE         0.005 84.321   1395
VIKKI          0.005 84.326   1396
VERLA          0.005 84.331   1397
ROSELYN        0.005 84.336   1398
MELVINA        0.005 84.340   1399
JANNETTE       0.005 84.345   1400
GINNY          0.005 84.350   1401
DEBRAH         0.005 84.355   1402
CORRIE         0.005 84.359   1403
ASIA           0.005 84.364   1404
VIOLETA        0.005 84.369   1405
MYRTIS         0.005 84.374   1406
LATRICIA       0.005 84.378   1407
COLLETTE       0.005 84.383   1408
CHARLEEN       0.005 84.388   1409
ANISSA         0.005 84.392   1410
VIVIANA        0.005 84.397   1411
TWYLA          0.005 84.402   1412
PRECIOUS       0.005 84.406   1413
NEDRA          0.005 84.411   1414
LATONIA        0.005 84.416   1415
LAN            0.005 84.420   1416
HELLEN         0.005 84.425   1417
FABIOLA        0.005 84.430   1418
ANNAMARIE      0.005 84.435   1419
ADELL          0.005 84.439   1420
SHARYN         0.005 84.444   1421
CHANTAL        0.005 84.448   1422
NIKI           0.005 84.453   1423
MAUD           0.005 84.458   1424
LIZETTE        0.005 84.462   1425
LINDY          0.005 84.467   1426
KIA            0.005 84.472   1427
KESHA          0.005 84.476   1428
JEANA          0.005 84.481   1429
DANELLE        0.005 84.485   1430
CHARLINE       0.005 84.490   1431
CHANEL         0.005 84.495   1432
CARROL         0.005 84.499   1433
VALORIE        0.005 84.504   1434
LIA            0.005 84.508   1435
DORTHA         0.005 84.513   1436
CRISTAL        0.005 84.518   1437
SUNNY          0.005 84.522   1438
LEONE          0.005 84.527   1439
LEILANI        0.005 84.531   1440
GERRI          0.005 84.536   1441
DEBI           0.005 84.540   1442
ANDRA          0.005 84.545   1443
KESHIA         0.005 84.549   1444
IMA            0.005 84.554   1445
EULALIA        0.005 84.558   1446
EASTER         0.005 84.563   1447
DULCE          0.005 84.568   1448
NATIVIDAD      0.004 84.572   1449
LINNIE         0.004 84.577   1450
KAMI           0.004 84.581   1451
GEORGIE        0.004 84.586   1452
CATINA         0.004 84.590   1453
BROOK          0.004 84.594   1454
ALDA           0.004 84.599   1455
WINNIFRED      0.004 84.603   1456
SHARLA         0.004 84.608   1457
RUTHANN        0.004 84.612   1458
MEAGHAN        0.004 84.617   1459
MAGDALENE      0.004 84.621   1460
LISSETTE       0.004 84.626   1461
ADELAIDA       0.004 84.630   1462
VENITA         0.004 84.635   1463
TRENA          0.004 84.639   1464
SHIRLENE       0.004 84.643   1465
SHAMEKA        0.004 84.648   1466
ELIZEBETH      0.004 84.652   1467
DIAN           0.004 84.657   1468
SHANTA         0.004 84.661   1469
MICKEY         0.004 84.666   1470
LATOSHA        0.004 84.670   1471
CARLOTTA       0.004 84.674   1472
WINDY          0.004 84.679   1473
SOON           0.004 84.683   1474
ROSINA         0.004 84.687   1475
MARIANN        0.004 84.692   1476
LEISA          0.004 84.696   1477
JONNIE         0.004 84.701   1478
DAWNA          0.004 84.705   1479
CATHIE         0.004 84.709   1480
BILLY          0.004 84.714   1481
ASTRID         0.004 84.718   1482
SIDNEY         0.004 84.722   1483
LAUREEN        0.004 84.726   1484
JANEEN         0.004 84.731   1485
HOLLI          0.004 84.735   1486
FAWN           0.004 84.739   1487
VICKEY         0.004 84.744   1488
TERESSA        0.004 84.748   1489
SHANTE         0.004 84.752   1490
RUBYE          0.004 84.756   1491
MARCELINA      0.004 84.761   1492
CHANDA         0.004 84.765   1493
CARY           0.004 84.769   1494
TERESE         0.004 84.774   1495
SCARLETT       0.004 84.778   1496
MARTY          0.004 84.782   1497
MARNIE         0.004 84.786   1498
LULU           0.004 84.790   1499
LISETTE        0.004 84.795   1500
JENIFFER       0.004 84.799   1501
ELENOR         0.004 84.803   1502
DORINDA        0.004 84.807   1503
DONITA         0.004 84.812   1504
CARMAN         0.004 84.816   1505
BERNITA        0.004 84.820   1506
ALTAGRACIA     0.004 84.824   1507
ALETA          0.004 84.829   1508
ADRIANNA       0.004 84.833   1509
ZORAIDA        0.004 84.837   1510
RONNIE         0.004 84.841   1511
NICOLA         0.004 84.845   1512
LYNDSEY        0.004 84.850   1513
KENDALL        0.004 84.854   1514
JANINA         0.004 84.858   1515
CHRISSY        0.004 84.862   1516
AMI            0.004 84.867   1517
STARLA         0.004 84.871   1518
PHYLIS         0.004 84.875   1519
PHUONG         0.004 84.879   1520
KYRA           0.004 84.883   1521
CHARISSE       0.004 84.887   1522
BLANCH         0.004 84.892   1523
SANJUANITA     0.004 84.896   1524
RONA           0.004 84.900   1525
NANCI          0.004 84.904   1526
MARILEE        0.004 84.908   1527
MARANDA        0.004 84.912   1528
CORY           0.004 84.916   1529
BRIGETTE       0.004 84.921   1530
SANJUANA       0.004 84.925   1531
MARITA         0.004 84.929   1532
KASSANDRA      0.004 84.933   1533
JOYCELYN       0.004 84.937   1534
IRA            0.004 84.941   1535
FELIPA         0.004 84.945   1536
CHELSIE        0.004 84.949   1537
BONNY          0.004 84.954   1538
MIREYA         0.004 84.958   1539
LORENZA        0.004 84.962   1540
KYONG          0.004 84.966   1541
ILEANA         0.004 84.970   1542
CANDELARIA     0.004 84.974   1543
TONY           0.004 84.978   1544
TOBY           0.004 84.982   1545
SHERIE         0.004 84.986   1546
OK             0.004 84.990   1547
MARK           0.004 84.994   1548
LUCIE          0.004 84.998   1549
LEATRICE       0.004 85.002   1550
LAKESHIA       0.004 85.006   1551
GERDA          0.004 85.010   1552
EDIE           0.004 85.014   1553
BAMBI          0.004 85.018   1554
MARYLIN        0.004 85.023   1555
LAVON          0.004 85.027   1556
HORTENSE       0.004 85.031   1557
GARNET         0.004 85.035   1558
EVIE           0.004 85.039   1559
TRESSA         0.004 85.043   1560
SHAYNA         0.004 85.047   1561
LAVINA         0.004 85.051   1562
KYUNG          0.004 85.055   1563
JEANETTA       0.004 85.059   1564
SHERRILL       0.004 85.062   1565
SHARA          0.004 85.066   1566
PHYLISS        0.004 85.070   1567
MITTIE         0.004 85.074   1568
ANABEL         0.004 85.078   1569
ALESIA         0.004 85.082   1570
THUY           0.004 85.086   1571
TAWANDA        0.004 85.090   1572
RICHARD        0.004 85.094   1573
JOANIE         0.004 85.098   1574
TIFFANIE       0.004 85.102   1575
LASHANDA       0.004 85.106   1576
KARISSA        0.004 85.110   1577
ENRIQUETA      0.004 85.114   1578
DARIA          0.004 85.117   1579
DANIELLA       0.004 85.121   1580
CORINNA        0.004 85.125   1581
ALANNA         0.004 85.129   1582
ABBEY          0.004 85.133   1583
ROXANE         0.004 85.137   1584
ROSEANNA       0.004 85.141   1585
MAGNOLIA       0.004 85.145   1586
LIDA           0.004 85.148   1587
KYLE           0.004 85.152   1588
JOELLEN        0.004 85.156   1589
ERA            0.004 85.160   1590
CORAL          0.004 85.164   1591
CARLEEN        0.004 85.168   1592
TRESA          0.004 85.172   1593
PEGGIE         0.004 85.175   1594
NOVELLA        0.004 85.179   1595
NILA           0.004 85.183   1596
MAYBELLE       0.004 85.187   1597
JENELLE        0.004 85.191   1598
CARINA         0.004 85.195   1599
NOVA           0.004 85.198   1600
MELINA         0.004 85.202   1601
MARQUERITE     0.004 85.206   1602
MARGARETTE     0.004 85.210   1603
JOSEPHINA      0.004 85.214   1604
EVONNE         0.004 85.217   1605
DEVIN          0.004 85.221   1606
CINTHIA        0.004 85.225   1607
ALBINA         0.004 85.229   1608
TOYA           0.004 85.233   1609
TAWNYA         0.004 85.236   1610
SHERITA        0.004 85.240   1611
SANTOS         0.004 85.244   1612
MYRIAM         0.004 85.248   1613
LIZABETH       0.004 85.251   1614
LISE           0.004 85.255   1615
KEELY          0.004 85.259   1616
JENNI          0.004 85.263   1617
GISELLE        0.004 85.266   1618
CHERYLE        0.004 85.270   1619
ARDITH         0.004 85.274   1620
ARDIS          0.004 85.278   1621
ALESHA         0.004 85.282   1622
ADRIANE        0.004 85.285   1623
SHAINA         0.004 85.289   1624
LINNEA         0.004 85.293   1625
KAROLYN        0.004 85.297   1626
HONG           0.004 85.300   1627
FLORIDA        0.004 85.304   1628
FELISHA        0.004 85.308   1629
DORI           0.004 85.311   1630
DARCI          0.004 85.315   1631
ARTIE          0.004 85.319   1632
ARMIDA         0.004 85.323   1633
ZOLA           0.004 85.326   1634
XIOMARA        0.004 85.330   1635
VERGIE         0.004 85.334   1636
SHAMIKA        0.004 85.338   1637
NENA           0.004 85.341   1638
NANNETTE       0.004 85.345   1639
MAXIE          0.004 85.349   1640
LOVIE          0.004 85.352   1641
JEANE          0.004 85.356   1642
JAIMIE         0.004 85.360   1643
INGE           0.004 85.363   1644
FARRAH         0.004 85.367   1645
ELAINA         0.004 85.371   1646
CAITLYN        0.004 85.375   1647
STARR          0.004 85.378   1648
FELICITAS      0.004 85.382   1649
CHERLY         0.004 85.386   1650
CARYL          0.004 85.389   1651
YOLONDA        0.004 85.393   1652
YASMIN         0.004 85.397   1653
TEENA          0.004 85.400   1654
PRUDENCE       0.004 85.404   1655
PENNIE         0.004 85.407   1656
NYDIA          0.004 85.411   1657
MACKENZIE      0.004 85.415   1658
ORPHA          0.004 85.418   1659
MARVEL         0.004 85.422   1660
LIZBETH        0.004 85.426   1661
LAURETTE       0.004 85.429   1662
JERRIE         0.004 85.433   1663
HERMELINDA     0.004 85.436   1664
CAROLEE        0.004 85.440   1665
TIERRA         0.004 85.444   1666
MIRIAN         0.004 85.447   1667
META           0.004 85.451   1668
MELONY         0.004 85.454   1669
KORI           0.004 85.458   1670
JENNETTE       0.004 85.462   1671
JAMILA         0.004 85.465   1672
ENA            0.004 85.469   1673
ANH            0.004 85.472   1674
YOSHIKO        0.004 85.476   1675
SUSANNAH       0.004 85.479   1676
SALINA         0.004 85.483   1677
RHIANNON       0.004 85.486   1678
JOLEEN         0.004 85.490   1679
CRISTINE       0.004 85.494   1680
ASHTON         0.004 85.497   1681
ARACELY        0.004 85.501   1682
TOMEKA         0.004 85.504   1683
SHALONDA       0.004 85.508   1684
MARTI          0.004 85.511   1685
LACIE          0.004 85.515   1686
KALA           0.004 85.518   1687
JADA           0.004 85.522   1688
ILSE           0.004 85.525   1689
HAILEY         0.004 85.529   1690
BRITTANI       0.004 85.532   1691
ZONA           0.003 85.536   1692
SYBLE          0.003 85.539   1693
SHERRYL        0.003 85.543   1694
RANDY          0.003 85.546   1695
NIDIA          0.003 85.550   1696
MARLO          0.003 85.553   1697
KANDICE        0.003 85.557   1698
KANDI          0.003 85.560   1699
DEB            0.003 85.564   1700
DEAN           0.003 85.567   1701
AMERICA        0.003 85.571   1702
ALYCIA         0.003 85.574   1703
TOMMY          0.003 85.578   1704
RONNA          0.003 85.581   1705
NORENE         0.003 85.585   1706
MERCY          0.003 85.588   1707
JOSE           0.003 85.591   1708
INGEBORG       0.003 85.595   1709
GIOVANNA       0.003 85.598   1710
GEMMA          0.003 85.602   1711
CHRISTEL       0.003 85.605   1712
AUDRY          0.003 85.609   1713
ZORA           0.003 85.612   1714
VITA           0.003 85.616   1715
VAN            0.003 85.619   1716
TRISH          0.003 85.622   1717
STEPHAINE      0.003 85.626   1718
SHIRLEE        0.003 85.629   1719
SHANIKA        0.003 85.633   1720
MELONIE        0.003 85.636   1721
MAZIE          0.003 85.639   1722
JAZMIN         0.003 85.643   1723
INGA           0.003 85.646   1724
HOA            0.003 85.650   1725
HETTIE         0.003 85.653   1726
GERALYN        0.003 85.657   1727
FONDA          0.003 85.660   1728
ESTRELLA       0.003 85.663   1729
ADELLA         0.003 85.667   1730
SU             0.003 85.670   1731
SARITA         0.003 85.674   1732
RINA           0.003 85.677   1733
MILISSA        0.003 85.680   1734
MARIBETH       0.003 85.684   1735
GOLDA          0.003 85.687   1736
EVON           0.003 85.691   1737
ETHELYN        0.003 85.694   1738
ENEDINA        0.003 85.697   1739
CHERISE        0.003 85.701   1740
CHANA          0.003 85.704   1741
VELVA          0.003 85.708   1742
TAWANNA        0.003 85.711   1743
SADE           0.003 85.714   1744
MIRTA          0.003 85.718   1745
LI             0.003 85.721   1746
KARIE          0.003 85.724   1747
JACINTA        0.003 85.728   1748
ELNA           0.003 85.731   1749
DAVINA         0.003 85.734   1750
CIERRA         0.003 85.738   1751
ASHLIE         0.003 85.741   1752
ALBERTHA       0.003 85.744   1753
TANESHA        0.003 85.748   1754
STEPHANI       0.003 85.751   1755
NELLE          0.003 85.754   1756
MINDI          0.003 85.758   1757
LU             0.003 85.761   1758
LORINDA        0.003 85.764   1759
LARUE          0.003 85.768   1760
FLORENE        0.003 85.771   1761
DEMETRA        0.003 85.774   1762
DEDRA          0.003 85.778   1763
CIARA          0.003 85.781   1764
CHANTELLE      0.003 85.784   1765
ASHLY          0.003 85.788   1766
SUZY           0.003 85.791   1767
ROSALVA        0.003 85.794   1768
NOELIA         0.003 85.798   1769
LYDA           0.003 85.801   1770
LEATHA         0.003 85.804   1771
KRYSTYNA       0.003 85.808   1772
KRISTAN        0.003 85.811   1773
KARRI          0.003 85.814   1774
DARLINE        0.003 85.817   1775
DARCIE         0.003 85.821   1776
CINDA          0.003 85.824   1777
CHEYENNE       0.003 85.827   1778
CHERRIE        0.003 85.831   1779
AWILDA         0.003 85.834   1780
ALMEDA         0.003 85.837   1781
ROLANDA        0.003 85.840   1782
LANETTE        0.003 85.844   1783
JERILYN        0.003 85.847   1784
GISELE         0.003 85.850   1785
EVALYN         0.003 85.854   1786
CYNDI          0.003 85.857   1787
CLETA          0.003 85.860   1788
CARIN          0.003 85.863   1789
ZINA           0.003 85.867   1790
ZENA           0.003 85.870   1791
VELIA          0.003 85.873   1792
TANIKA         0.003 85.876   1793
PAUL           0.003 85.880   1794
CHARISSA       0.003 85.883   1795
THOMAS         0.003 85.886   1796
TALIA          0.003 85.889   1797
MARGARETE      0.003 85.892   1798
LAVONDA        0.003 85.896   1799
KAYLEE         0.003 85.899   1800
KATHLENE       0.003 85.902   1801
JONNA          0.003 85.905   1802
IRENA          0.003 85.908   1803
ILONA          0.003 85.912   1804
IDALIA         0.003 85.915   1805
CANDIS         0.003 85.918   1806
CANDANCE       0.003 85.921   1807
BRANDEE        0.003 85.924   1808
ANITRA         0.003 85.928   1809
ALIDA          0.003 85.931   1810
SIGRID         0.003 85.934   1811
NICOLETTE      0.003 85.937   1812
MARYJO         0.003 85.940   1813
LINETTE        0.003 85.944   1814
HEDWIG         0.003 85.947   1815
CHRISTIANA     0.003 85.950   1816
CASSIDY        0.003 85.953   1817
ALEXIA         0.003 85.956   1818
TRESSIE        0.003 85.959   1819
MODESTA        0.003 85.962   1820
LUPITA         0.003 85.966   1821
LITA           0.003 85.969   1822
GLADIS         0.003 85.972   1823
EVELIA         0.003 85.975   1824
DAVIDA         0.003 85.978   1825
CHERRI         0.003 85.981   1826
CECILY         0.003 85.984   1827
ASHELY         0.003 85.988   1828
ANNABEL        0.003 85.991   1829
AGUSTINA       0.003 85.994   1830
WANITA         0.003 85.997   1831
SHIRLY         0.003 86.000   1832
ROSAURA        0.003 86.003   1833
HULDA          0.003 86.006   1834
EUN            0.003 86.009   1835
BAILEY         0.003 86.013   1836
YETTA          0.003 86.016   1837
VERONA         0.003 86.019   1838
THOMASINA      0.003 86.022   1839
SIBYL          0.003 86.025   1840
SHANNAN        0.003 86.028   1841
MECHELLE       0.003 86.031   1842
LUE            0.003 86.034   1843
LEANDRA        0.003 86.037   1844
LANI           0.003 86.040   1845
KYLEE          0.003 86.043   1846
KANDY          0.003 86.046   1847
JOLYNN         0.003 86.049   1848
FERNE          0.003 86.053   1849
EBONI          0.003 86.056   1850
CORENE         0.003 86.059   1851
ALYSIA         0.003 86.062   1852
ZULA           0.003 86.065   1853
NADA           0.003 86.068   1854
MOIRA          0.003 86.071   1855
LYNDSAY        0.003 86.074   1856
LORRETTA       0.003 86.077   1857
JUAN           0.003 86.080   1858
JAMMIE         0.003 86.083   1859
HORTENSIA      0.003 86.086   1860
GAYNELL        0.003 86.089   1861
CAMERON        0.003 86.092   1862
ADRIA          0.003 86.095   1863
VINA           0.003 86.098   1864
VICENTA        0.003 86.101   1865
TANGELA        0.003 86.104   1866
STEPHINE       0.003 86.107   1867
NORINE         0.003 86.110   1868
NELLA          0.003 86.113   1869
LIANA          0.003 86.116   1870
LESLEE         0.003 86.119   1871
KIMBERELY      0.003 86.122   1872
ILIANA         0.003 86.125   1873
GLORY          0.003 86.128   1874
FELICA         0.003 86.131   1875
EMOGENE        0.003 86.134   1876
ELFRIEDE       0.003 86.137   1877
EDEN           0.003 86.140   1878
EARTHA         0.003 86.144   1879
CARMA          0.003 86.147   1880
BEA            0.003 86.150   1881
OCIE           0.003 86.153   1882
MARRY          0.003 86.156   1883
LENNIE         0.003 86.158   1884
KIARA          0.003 86.161   1885
JACALYN        0.003 86.164   1886
CARLOTA        0.003 86.167   1887
ARIELLE        0.003 86.170   1888
YU             0.003 86.173   1889
STAR           0.003 86.176   1890
OTILIA         0.003 86.179   1891
KIRSTIN        0.003 86.182   1892
KACEY          0.003 86.185   1893
JOHNETTA       0.003 86.188   1894
JOEY           0.003 86.191   1895
JOETTA         0.003 86.194   1896
JERALDINE      0.003 86.197   1897
JAUNITA        0.003 86.200   1898
ELANA          0.003 86.203   1899
DORTHEA        0.003 86.206   1900
CAMI           0.003 86.209   1901
AMADA          0.003 86.212   1902
ADELIA         0.003 86.215   1903
VERNITA        0.003 86.218   1904
TAMAR          0.003 86.221   1905
SIOBHAN        0.003 86.223   1906
RENEA          0.003 86.226   1907
RASHIDA        0.003 86.229   1908
OUIDA          0.003 86.232   1909
ODELL          0.003 86.235   1910
NILSA          0.003 86.238   1911
MERYL          0.003 86.241   1912
KRISTYN        0.003 86.244   1913
JULIETA        0.003 86.247   1914
DANICA         0.003 86.250   1915
BREANNE        0.003 86.253   1916
AUREA          0.003 86.256   1917
ANGLEA         0.003 86.259   1918
SHERRON        0.003 86.261   1919
ODETTE         0.003 86.264   1920
MALIA          0.003 86.267   1921
LORELEI        0.003 86.270   1922
LIN            0.003 86.273   1923
LEESA          0.003 86.276   1924
KENNA          0.003 86.279   1925
KATHLYN        0.003 86.282   1926
FIONA          0.003 86.285   1927
CHARLETTE      0.003 86.287   1928
SUZIE          0.003 86.290   1929
SHANTELL       0.003 86.293   1930
SABRA          0.003 86.296   1931
RACQUEL        0.003 86.299   1932
MYONG          0.003 86.302   1933
MIRA           0.003 86.305   1934
MARTINE        0.003 86.307   1935
LUCIENNE       0.003 86.310   1936
LAVADA         0.003 86.313   1937
JULIANN        0.003 86.316   1938
JOHNIE         0.003 86.319   1939
ELVERA         0.003 86.322   1940
DELPHIA        0.003 86.325   1941
CLAIR          0.003 86.327   1942
CHRISTIANE     0.003 86.330   1943
CHAROLETTE     0.003 86.333   1944
CARRI          0.003 86.336   1945
AUGUSTINE      0.003 86.339   1946
ASHA           0.003 86.342   1947
ANGELLA        0.003 86.345   1948
PAOLA          0.003 86.347   1949
NINFA          0.003 86.350   1950
LEDA           0.003 86.353   1951
LAI            0.003 86.356   1952
EDA            0.003 86.359   1953
SUNSHINE       0.003 86.361   1954
STEFANI        0.003 86.364   1955
SHANELL        0.003 86.367   1956
PALMA          0.003 86.370   1957
MACHELLE       0.003 86.373   1958
LISSA          0.003 86.375   1959
KECIA          0.003 86.378   1960
KATHRYNE       0.003 86.381   1961
KARLENE        0.003 86.384   1962
JULISSA        0.003 86.387   1963
JETTIE         0.003 86.389   1964
JENNIFFER      0.003 86.392   1965
HUI            0.003 86.395   1966
CORRINA        0.003 86.398   1967
CHRISTOPHER    0.003 86.401   1968
CAROLANN       0.003 86.403   1969
ALENA          0.003 86.406   1970
TESS           0.003 86.409   1971
ROSARIA        0.003 86.412   1972
MYRTICE        0.003 86.414   1973
MARYLEE        0.003 86.417   1974
LIANE          0.003 86.420   1975
KENYATTA       0.003 86.423   1976
JUDIE          0.003 86.426   1977
JANEY          0.003 86.428   1978
IN             0.003 86.431   1979
ELMIRA         0.003 86.434   1980
ELDORA         0.003 86.437   1981
DENNA          0.003 86.439   1982
CRISTI         0.003 86.442   1983
CATHI          0.003 86.445   1984
ZAIDA          0.003 86.448   1985
VONNIE         0.003 86.450   1986
VIVA           0.003 86.453   1987
VERNIE         0.003 86.456   1988
ROSALINE       0.003 86.459   1989
MARIELA        0.003 86.461   1990
LUCIANA        0.003 86.464   1991
LESLI          0.003 86.467   1992
KARAN          0.003 86.469   1993
FELICE         0.003 86.472   1994
DENEEN         0.003 86.475   1995
ADINA          0.003 86.478   1996
WYNONA         0.003 86.480   1997
TARSHA         0.003 86.483   1998
SHERON         0.003 86.486   1999
SHASTA         0.003 86.488   2000
SHANITA        0.003 86.491   2001
SHANI          0.003 86.494   2002
SHANDRA        0.003 86.497   2003
RANDA          0.003 86.499   2004
PINKIE         0.003 86.502   2005
PARIS          0.003 86.505   2006
NELIDA         0.003 86.507   2007
MARILOU        0.003 86.510   2008
LYLA           0.003 86.513   2009
LAURENE        0.003 86.515   2010
LACI           0.003 86.518   2011
JOI            0.003 86.521   2012
JANENE         0.003 86.524   2013
DOROTHA        0.003 86.526   2014
DANIELE        0.003 86.529   2015
DANI           0.003 86.532   2016
CAROLYNN       0.003 86.534   2017
CARLYN         0.003 86.537   2018
BERENICE       0.003 86.540   2019
AYESHA         0.003 86.542   2020
ANNELIESE      0.003 86.545   2021
ALETHEA        0.003 86.548   2022
THERSA         0.003 86.551   2023
TAMIKO         0.003 86.553   2024
RUFINA         0.003 86.556   2025
OLIVA          0.003 86.559   2026
MOZELL         0.003 86.561   2027
MARYLYN        0.003 86.564   2028
MADISON        0.003 86.567   2029
KRISTIAN       0.003 86.569   2030
KATHYRN        0.003 86.572   2031
KASANDRA       0.003 86.575   2032
KANDACE        0.003 86.577   2033
JANAE          0.003 86.580   2034
GABRIEL        0.003 86.583   2035
DOMENICA       0.003 86.585   2036
DEBBRA         0.003 86.588   2037
DANNIELLE      0.003 86.591   2038
CHUN           0.003 86.593   2039
BUFFY          0.003 86.596   2040
BARBIE         0.003 86.599   2041
ARCELIA        0.003 86.601   2042
AJA            0.003 86.604   2043
ZENOBIA        0.003 86.607   2044
SHAREN         0.003 86.609   2045
SHAREE         0.003 86.612   2046
PATRICK        0.003 86.614   2047
PAGE           0.003 86.617   2048
MY             0.003 86.620   2049
LAVINIA        0.003 86.622   2050
KUM            0.003 86.625   2051
KACIE          0.003 86.628   2052
JACKELINE      0.003 86.630   2053
HUONG          0.003 86.633   2054
FELISA         0.003 86.636   2055
EMELIA         0.003 86.638   2056
ELEANORA       0.003 86.641   2057
CYTHIA         0.003 86.644   2058
CRISTIN        0.003 86.646   2059
CLYDE          0.003 86.649   2060
CLARIBEL       0.003 86.651   2061
CARON          0.003 86.654   2062
ANASTACIA      0.003 86.657   2063
ZULMA          0.003 86.659   2064
ZANDRA         0.003 86.662   2065
YOKO           0.003 86.665   2066
TENISHA        0.003 86.667   2067
SUSANN         0.003 86.670   2068
SHERILYN       0.003 86.672   2069
SHAY           0.003 86.675   2070
SHAWANDA       0.003 86.678   2071
SABINE         0.003 86.680   2072
ROMANA         0.003 86.683   2073
MATHILDA       0.003 86.685   2074
LINSEY         0.003 86.688   2075
KEIKO          0.003 86.691   2076
JOANA          0.003 86.693   2077
ISELA          0.003 86.696   2078
GRETTA         0.003 86.698   2079
GEORGETTA      0.003 86.701   2080
EUGENIE        0.003 86.704   2081
DUSTY          0.003 86.706   2082
DESIRAE        0.003 86.709   2083
DELORA         0.003 86.711   2084
CORAZON        0.003 86.714   2085
ANTONINA       0.003 86.717   2086
ANIKA          0.003 86.719   2087
WILLENE        0.003 86.722   2088
TRACEE         0.003 86.724   2089
TAMATHA        0.003 86.727   2090
REGAN          0.003 86.730   2091
NICHELLE       0.003 86.732   2092
MICKIE         0.003 86.735   2093
MAEGAN         0.003 86.737   2094
LUANA          0.003 86.740   2095
LANITA         0.003 86.742   2096
KELSIE         0.003 86.745   2097
EDELMIRA       0.003 86.748   2098
BREE           0.003 86.750   2099
AFTON          0.003 86.753   2100
TEODORA        0.003 86.755   2101
TAMIE          0.003 86.758   2102
SHENA          0.003 86.760   2103
MEG            0.003 86.763   2104
LINH           0.003 86.765   2105
KELI           0.003 86.768   2106
KACI           0.003 86.771   2107
DANYELLE       0.003 86.773   2108
BRITT          0.003 86.776   2109
ARLETTE        0.003 86.778   2110
ALBERTINE      0.003 86.781   2111
ADELLE         0.003 86.783   2112
TIFFINY        0.003 86.786   2113
STORMY         0.003 86.788   2114
SIMONA         0.003 86.791   2115
NUMBERS        0.003 86.793   2116
NICOLASA       0.003 86.796   2117
NICHOL         0.003 86.798   2118
NIA            0.003 86.801   2119
NAKISHA        0.003 86.803   2120
MEE            0.003 86.806   2121
MAIRA          0.003 86.808   2122
LOREEN         0.003 86.811   2123
KIZZY          0.003 86.813   2124
JOHNNY         0.003 86.816   2125
JAY            0.003 86.818   2126
FALLON         0.003 86.821   2127
CHRISTENE      0.003 86.823   2128
BOBBYE         0.003 86.826   2129
ANTHONY        0.003 86.828   2130
YING           0.002 86.831   2131
VINCENZA       0.002 86.833   2132
TANJA          0.002 86.836   2133
RUBIE          0.002 86.838   2134
RONI           0.002 86.841   2135
QUEENIE        0.002 86.843   2136
MARGARETT      0.002 86.846   2137
KIMBERLI       0.002 86.848   2138
IRMGARD        0.002 86.851   2139
IDELL          0.002 86.853   2140
HILMA          0.002 86.856   2141
EVELINA        0.002 86.858   2142
ESTA           0.002 86.861   2143
EMILEE         0.002 86.863   2144
DENNISE        0.002 86.866   2145
DANIA          0.002 86.868   2146
CARL           0.002 86.871   2147
CARIE          0.002 86.873   2148
ANTONIO        0.002 86.876   2149
WAI            0.002 86.878   2150
SANG           0.002 86.881   2151
RISA           0.002 86.883   2152
RIKKI          0.002 86.885   2153
PARTICIA       0.002 86.888   2154
MUI            0.002 86.890   2155
MASAKO         0.002 86.893   2156
MARIO          0.002 86.895   2157
LUVENIA        0.002 86.898   2158
LOREE          0.002 86.900   2159
LONI           0.002 86.903   2160
LIEN           0.002 86.905   2161
KEVIN          0.002 86.907   2162
GIGI           0.002 86.910   2163
FLORENCIA      0.002 86.912   2164
DORIAN         0.002 86.915   2165
DENITA         0.002 86.917   2166
DALLAS         0.002 86.920   2167
CHI            0.002 86.922   2168
BILLYE         0.002 86.925   2169
ALEXANDER      0.002 86.927   2170
TOMIKA         0.002 86.929   2171
SHARITA        0.002 86.932   2172
RANA           0.002 86.934   2173
NIKOLE         0.002 86.937   2174
NEOMA          0.002 86.939   2175
MARGARITE      0.002 86.942   2176
MADALYN        0.002 86.944   2177
LUCINA         0.002 86.946   2178
LAILA          0.002 86.949   2179
KALI           0.002 86.951   2180
JENETTE        0.002 86.954   2181
GABRIELE       0.002 86.956   2182
EVELYNE        0.002 86.958   2183
ELENORA        0.002 86.961   2184
CLEMENTINA     0.002 86.963   2185
ALEJANDRINA    0.002 86.966   2186
ZULEMA         0.002 86.968   2187
VIOLETTE       0.002 86.971   2188
VANNESSA       0.002 86.973   2189
THRESA         0.002 86.975   2190
RETTA          0.002 86.978   2191
PIA            0.002 86.980   2192
PATIENCE       0.002 86.982   2193
NOELLA         0.002 86.985   2194
NICKIE         0.002 86.987   2195
JONELL         0.002 86.990   2196
DELTA          0.002 86.992   2197
CHUNG          0.002 86.994   2198
CHAYA          0.002 86.997   2199
CAMELIA        0.002 86.999   2200
BETHEL         0.002 87.002   2201
ANYA           0.002 87.004   2202
ANDREW         0.002 87.006   2203
THANH          0.002 87.009   2204
SUZANN         0.002 87.011   2205
SPRING         0.002 87.013   2206
SHU            0.002 87.016   2207
MILA           0.002 87.018   2208
LILLA          0.002 87.020   2209
LAVERNA        0.002 87.023   2210
KEESHA         0.002 87.025   2211
KATTIE         0.002 87.028   2212
GIA            0.002 87.030   2213
GEORGENE       0.002 87.032   2214
EVELINE        0.002 87.035   2215
ESTELL         0.002 87.037   2216
ELIZBETH       0.002 87.039   2217
VIVIENNE       0.002 87.042   2218
VALLIE         0.002 87.044   2219
TRUDIE         0.002 87.046   2220
STEPHANE       0.002 87.049   2221
MICHEL         0.002 87.051   2222
MAGALY         0.002 87.053   2223
MADIE          0.002 87.056   2224
KENYETTA       0.002 87.058   2225
KARREN         0.002 87.060   2226
JANETTA        0.002 87.063   2227
HERMINE        0.002 87.065   2228
HARMONY        0.002 87.067   2229
DRUCILLA       0.002 87.069   2230
DEBBI          0.002 87.072   2231
CELESTINA      0.002 87.074   2232
CANDIE         0.002 87.076   2233
BRITNI         0.002 87.079   2234
BECKIE         0.002 87.081   2235
AMINA          0.002 87.083   2236
ZITA           0.002 87.086   2237
YUN            0.002 87.088   2238
YOLANDE        0.002 87.090   2239
VIVIEN         0.002 87.093   2240
VERNETTA       0.002 87.095   2241
TRUDI          0.002 87.097   2242
SOMMER         0.002 87.099   2243
PEARLE         0.002 87.102   2244
PATRINA        0.002 87.104   2245
OSSIE          0.002 87.106   2246
NICOLLE        0.002 87.109   2247
LOYCE          0.002 87.111   2248
LETTY          0.002 87.113   2249
LARISA         0.002 87.116   2250
KATHARINA      0.002 87.118   2251
JOSELYN        0.002 87.120   2252
JONELLE        0.002 87.122   2253
JENELL         0.002 87.125   2254
IESHA          0.002 87.127   2255
HEIDE          0.002 87.129   2256
FLORINDA       0.002 87.132   2257
FLORENTINA     0.002 87.134   2258
FLO            0.002 87.136   2259
ELODIA         0.002 87.138   2260
DORINE         0.002 87.141   2261
BRUNILDA       0.002 87.143   2262
BRIGID         0.002 87.145   2263
ASHLI          0.002 87.148   2264
ARDELLA        0.002 87.150   2265
TWANA          0.002 87.152   2266
THU            0.002 87.154   2267
TARAH          0.002 87.157   2268
SUNG           0.002 87.159   2269
SHEA           0.002 87.161   2270
SHAVON         0.002 87.163   2271
SHANE          0.002 87.166   2272
SERINA         0.002 87.168   2273
RAYNA          0.002 87.170   2274
RAMONITA       0.002 87.173   2275
NGA            0.002 87.175   2276
MARGURITE      0.002 87.177   2277
LUCRECIA       0.002 87.179   2278
KOURTNEY       0.002 87.182   2279
KATI           0.002 87.184   2280
JESUS          0.002 87.186   2281
JESENIA        0.002 87.188   2282
DIAMOND        0.002 87.191   2283
CRISTA         0.002 87.193   2284
AYANA          0.002 87.195   2285
ALICA          0.002 87.197   2286
ALIA           0.002 87.200   2287
VINNIE         0.002 87.202   2288
SUELLEN        0.002 87.204   2289
ROMELIA        0.002 87.206   2290
RACHELL        0.002 87.209   2291
PIPER          0.002 87.211   2292
OLYMPIA        0.002 87.213   2293
MICHIKO        0.002 87.215   2294
KATHALEEN      0.002 87.217   2295
JOLIE          0.002 87.220   2296
JESSI          0.002 87.222   2297
JANESSA        0.002 87.224   2298
HANA           0.002 87.226   2299
HA             0.002 87.229   2300
ELEASE         0.002 87.231   2301
CARLETTA       0.002 87.233   2302
BRITANY        0.002 87.235   2303
SHONA          0.002 87.238   2304
SALOME         0.002 87.240   2305
ROSAMOND       0.002 87.242   2306
REGENA         0.002 87.244   2307
RAINA          0.002 87.246   2308
NGOC           0.002 87.249   2309
NELIA          0.002 87.251   2310
LOUVENIA       0.002 87.253   2311
LESIA          0.002 87.255   2312
LATRINA        0.002 87.257   2313
LATICIA        0.002 87.260   2314
LARHONDA       0.002 87.262   2315
JINA           0.002 87.264   2316
JACKI          0.002 87.266   2317
HOLLIS         0.002 87.268   2318
HOLLEY         0.002 87.271   2319
EMMY           0.002 87.273   2320
DEEANN         0.002 87.275   2321
CORETTA        0.002 87.277   2322
ARNETTA        0.002 87.279   2323
VELVET         0.002 87.281   2324
THALIA         0.002 87.284   2325
SHANICE        0.002 87.286   2326
NETA           0.002 87.288   2327
MIKKI          0.002 87.290   2328
MICKI          0.002 87.292   2329
LONNA          0.002 87.294   2330
LEANA          0.002 87.297   2331
LASHUNDA       0.002 87.299   2332
KILEY          0.002 87.301   2333
JOYE           0.002 87.303   2334
JACQULYN       0.002 87.305   2335
IGNACIA        0.002 87.307   2336
HYUN           0.002 87.310   2337
HIROKO         0.002 87.312   2338
HENRY          0.002 87.314   2339
HENRIETTE      0.002 87.316   2340
ELAYNE         0.002 87.318   2341
DELINDA        0.002 87.320   2342
DARNELL        0.002 87.323   2343
DAHLIA         0.002 87.325   2344
COREEN         0.002 87.327   2345
CONSUELA       0.002 87.329   2346
CONCHITA       0.002 87.331   2347
CELINE         0.002 87.333   2348
BABETTE        0.002 87.336   2349
AYANNA         0.002 87.338   2350
ANETTE         0.002 87.340   2351
ALBERTINA      0.002 87.342   2352
SKYE           0.002 87.344   2353
SHAWNEE        0.002 87.346   2354
SHANEKA        0.002 87.349   2355
QUIANA         0.002 87.351   2356
PAMELIA        0.002 87.353   2357
MIN            0.002 87.355   2358
MERRI          0.002 87.357   2359
MERLENE        0.002 87.359   2360
MARGIT         0.002 87.361   2361
KIESHA         0.002 87.363   2362
KIERA          0.002 87.366   2363
KAYLENE        0.002 87.368   2364
JODEE          0.002 87.370   2365
JENISE         0.002 87.372   2366
ERLENE         0.002 87.374   2367
EMMIE          0.002 87.376   2368
ELSE           0.002 87.378   2369
DARYL          0.002 87.381   2370
DALILA         0.002 87.383   2371
DAISEY         0.002 87.385   2372
CODY           0.002 87.387   2373
CASIE          0.002 87.389   2374
BELIA          0.002 87.391   2375
BABARA         0.002 87.393   2376
VERSIE         0.002 87.395   2377
VANESA         0.002 87.398   2378
SHELBA         0.002 87.400   2379
SHAWNDA        0.002 87.402   2380
SAM            0.002 87.404   2381
NORMAN         0.002 87.406   2382
NIKIA          0.002 87.408   2383
NAOMA          0.002 87.410   2384
MARNA          0.002 87.412   2385
MARGERET       0.002 87.414   2386
MADALINE       0.002 87.417   2387
LAWANA         0.002 87.419   2388
KINDRA         0.002 87.421   2389
JUTTA          0.002 87.423   2390
JAZMINE        0.002 87.425   2391
JANETT         0.002 87.427   2392
HANNELORE      0.002 87.429   2393
GLENDORA       0.002 87.431   2394
GERTRUD        0.002 87.433   2395
GARNETT        0.002 87.435   2396
FREEDA         0.002 87.438   2397
FREDERICA      0.002 87.440   2398
FLORANCE       0.002 87.442   2399
FLAVIA         0.002 87.444   2400
DENNIS         0.002 87.446   2401
CARLINE        0.002 87.448   2402
BEVERLEE       0.002 87.450   2403
ANJANETTE      0.002 87.452   2404
VALDA          0.002 87.454   2405
TRINITY        0.002 87.456   2406
TAMALA         0.002 87.459   2407
STEVIE         0.002 87.461   2408
SHONNA         0.002 87.463   2409
SHA            0.002 87.465   2410
SARINA         0.002 87.467   2411
ONEIDA         0.002 87.469   2412
MICAH          0.002 87.471   2413
MERILYN        0.002 87.473   2414
MARLEEN        0.002 87.475   2415
LURLINE        0.002 87.477   2416
LENNA          0.002 87.479   2417
KATHERIN       0.002 87.481   2418
JIN            0.002 87.483   2419
JENI           0.002 87.485   2420
HAE            0.002 87.488   2421
GRACIA         0.002 87.490   2422
GLADY          0.002 87.492   2423
FARAH          0.002 87.494   2424
ERIC           0.002 87.496   2425
ENOLA          0.002 87.498   2426
EMA            0.002 87.500   2427
DOMINQUE       0.002 87.502   2428
DEVONA         0.002 87.504   2429
DELANA         0.002 87.506   2430
CECILA         0.002 87.508   2431
CAPRICE        0.002 87.510   2432
ALYSHA         0.002 87.512   2433
ALI            0.002 87.514   2434
ALETHIA        0.002 87.517   2435
VENA           0.002 87.519   2436
THERESIA       0.002 87.521   2437
TAWNY          0.002 87.523   2438
SONG           0.002 87.525   2439
SHAKIRA        0.002 87.527   2440
SAMARA         0.002 87.529   2441
SACHIKO        0.002 87.531   2442
RACHELE        0.002 87.533   2443
PAMELLA        0.002 87.535   2444
NICKY          0.002 87.537   2445
MARNI          0.002 87.539   2446
MARIEL         0.002 87.541   2447
MAREN          0.002 87.543   2448
MALISA         0.002 87.545   2449
LIGIA          0.002 87.547   2450
LERA           0.002 87.549   2451
LATORIA        0.002 87.551   2452
LARAE          0.002 87.553   2453
KIMBER         0.002 87.555   2454
KATHERN        0.002 87.557   2455
KAREY          0.002 87.559   2456
JENNEFER       0.002 87.561   2457
JANETH         0.002 87.563   2458
HALINA         0.002 87.566   2459
FREDIA         0.002 87.568   2460
DELISA         0.002 87.570   2461
DEBROAH        0.002 87.572   2462
CIERA          0.002 87.574   2463
CHIN           0.002 87.576   2464
ANGELIKA       0.002 87.578   2465
ANDREE         0.002 87.580   2466
ALTHA          0.002 87.582   2467
YEN            0.002 87.584   2468
VIVAN          0.002 87.586   2469
TERRESA        0.002 87.588   2470
TANNA          0.002 87.590   2471
SUK            0.002 87.592   2472
SUDIE          0.002 87.594   2473
SOO            0.002 87.596   2474
SIGNE          0.002 87.598   2475
SALENA         0.002 87.600   2476
RONNI          0.002 87.602   2477
REBBECCA       0.002 87.604   2478
MYRTIE         0.002 87.606   2479
MCKENZIE       0.002 87.608   2480
MALIKA         0.002 87.610   2481
MAIDA          0.002 87.612   2482
LOAN           0.002 87.614   2483
LEONARDA       0.002 87.616   2484
KAYLEIGH       0.002 87.618   2485
FRANCE         0.002 87.620   2486
ETHYL          0.002 87.622   2487
ELLYN          0.002 87.624   2488
DAYLE          0.002 87.626   2489
CAMMIE         0.002 87.628   2490
BRITTNI        0.002 87.630   2491
BIRGIT         0.002 87.632   2492
AVELINA        0.002 87.634   2493
ASUNCION       0.002 87.636   2494
ARIANNA        0.002 87.638   2495
AKIKO          0.002 87.640   2496
VENICE         0.002 87.642   2497
TYESHA         0.002 87.644   2498
TONIE          0.002 87.646   2499
TIESHA         0.002 87.648   2500
TAKISHA        0.002 87.650   2501
STEFFANIE      0.002 87.652   2502
SINDY          0.002 87.654   2503
SANTANA        0.002 87.656   2504
MEGHANN        0.002 87.658   2505
MANDA          0.002 87.660   2506
MACIE          0.002 87.662   2507
LADY           0.002 87.664   2508
KELLYE         0.002 87.666   2509
KELLEE         0.002 87.668   2510
JOSLYN         0.002 87.670   2511
JASON          0.002 87.672   2512
INGER          0.002 87.674   2513
INDIRA         0.002 87.676   2514
GLINDA         0.002 87.678   2515
GLENNIS        0.002 87.680   2516
FERNANDA       0.002 87.682   2517
FAUSTINA       0.002 87.684   2518
ENEIDA         0.002 87.686   2519
ELICIA         0.002 87.688   2520
DOT            0.002 87.690   2521
DIGNA          0.002 87.692   2522
DELL           0.002 87.694   2523
ARLETTA        0.002 87.696   2524
ANDRE          0.002 87.698   2525
WILLIA         0.002 87.699   2526
TAMMARA        0.002 87.701   2527
TABETHA        0.002 87.703   2528
SHERRELL       0.002 87.705   2529
SARI           0.002 87.707   2530
REFUGIO        0.002 87.709   2531
REBBECA        0.002 87.711   2532
PAULETTA       0.002 87.713   2533
NIEVES         0.002 87.715   2534
NATOSHA        0.002 87.717   2535
NAKITA         0.002 87.719   2536
MAMMIE         0.002 87.721   2537
KENISHA        0.002 87.723   2538
KAZUKO         0.002 87.725   2539
KASSIE         0.002 87.727   2540
GARY           0.002 87.729   2541
EARLEAN        0.002 87.731   2542
DAPHINE        0.002 87.733   2543
CORLISS        0.002 87.735   2544
CLOTILDE       0.002 87.736   2545
CAROLYNE       0.002 87.738   2546
BERNETTA       0.002 87.740   2547
AUGUSTINA      0.002 87.742   2548
AUDREA         0.002 87.744   2549
ANNIS          0.002 87.746   2550
ANNABELL       0.002 87.748   2551
YAN            0.002 87.750   2552
TENNILLE       0.002 87.752   2553
TAMICA         0.002 87.754   2554
SELENE         0.002 87.756   2555
SEAN           0.002 87.758   2556
ROSANA         0.002 87.760   2557
REGENIA        0.002 87.762   2558
QIANA          0.002 87.763   2559
MARKITA        0.002 87.765   2560
MACY           0.002 87.767   2561
LEEANNE        0.002 87.769   2562
LAURINE        0.002 87.771   2563
KYM            0.002 87.773   2564
JESSENIA       0.002 87.775   2565
JANITA         0.002 87.777   2566
GEORGINE       0.002 87.779   2567
GENIE          0.002 87.781   2568
EMIKO          0.002 87.783   2569
ELVIE          0.002 87.785   2570
DEANDRA        0.002 87.786   2571
DAGMAR         0.002 87.788   2572
CORIE          0.002 87.790   2573
COLLEN         0.002 87.792   2574
CHERISH        0.002 87.794   2575
ROMAINE        0.002 87.796   2576
PORSHA         0.002 87.798   2577
PEARLENE       0.002 87.800   2578
MICHELINE      0.002 87.802   2579
MERNA          0.002 87.804   2580
MARGORIE       0.002 87.805   2581
MARGARETTA     0.002 87.807   2582
LORE           0.002 87.809   2583
KENNETH        0.002 87.811   2584
JENINE         0.002 87.813   2585
HERMINA        0.002 87.815   2586
FREDERICKA     0.002 87.817   2587
ELKE           0.002 87.819   2588
DRUSILLA       0.002 87.820   2589
DORATHY        0.002 87.822   2590
DIONE          0.002 87.824   2591
DESIRE         0.002 87.826   2592
CELENA         0.002 87.828   2593
BRIGIDA        0.002 87.830   2594
ANGELES        0.002 87.832   2595
ALLEGRA        0.002 87.834   2596
THEO           0.002 87.836   2597
TAMEKIA        0.002 87.837   2598
SYNTHIA        0.002 87.839   2599
STEPHEN        0.002 87.841   2600
SOOK           0.002 87.843   2601
SLYVIA         0.002 87.845   2602
ROSANN         0.002 87.847   2603
REATHA         0.002 87.849   2604
RAYE           0.002 87.850   2605
MARQUETTA      0.002 87.852   2606
MARGART        0.002 87.854   2607
LING           0.002 87.856   2608
LAYLA          0.002 87.858   2609
KYMBERLY       0.002 87.860   2610
KIANA          0.002 87.861   2611
KAYLEEN        0.002 87.863   2612
KATLYN         0.002 87.865   2613
KARMEN         0.002 87.867   2614
JOELLA         0.002 87.869   2615
IRINA          0.002 87.871   2616
EMELDA         0.002 87.873   2617
ELENI          0.002 87.874   2618
DETRA          0.002 87.876   2619
CLEMMIE        0.002 87.878   2620
CHERYLL        0.002 87.880   2621
CHANTELL       0.002 87.882   2622
CATHEY         0.002 87.884   2623
ARNITA         0.002 87.886   2624
ARLA           0.002 87.887   2625
ANGLE          0.002 87.889   2626
ANGELIC        0.002 87.891   2627
ALYSE          0.002 87.893   2628
ZOFIA          0.002 87.895   2629
THOMASINE      0.002 87.897   2630
TENNIE         0.002 87.898   2631
SON            0.002 87.900   2632
SHERLY         0.002 87.902   2633
SHERLEY        0.002 87.904   2634
SHARYL         0.002 87.906   2635
REMEDIOS       0.002 87.908   2636
PETRINA        0.002 87.909   2637
NICKOLE        0.002 87.911   2638
MYUNG          0.002 87.913   2639
MYRLE          0.002 87.915   2640
MOZELLA        0.002 87.917   2641
LOUANNE        0.002 87.918   2642
LISHA          0.002 87.920   2643
LATIA          0.002 87.922   2644
LANE           0.002 87.924   2645
KRYSTA         0.002 87.926   2646
JULIENNE       0.002 87.928   2647
JOEL           0.002 87.929   2648
JEANENE        0.002 87.931   2649
JACQUALINE     0.002 87.933   2650
ISAURA         0.002 87.935   2651
GWENDA         0.002 87.937   2652
EARLEEN        0.002 87.939   2653
DONALD         0.002 87.940   2654
CLEOPATRA      0.002 87.942   2655
CARLIE         0.002 87.944   2656
AUDIE          0.002 87.946   2657
ANTONIETTA     0.002 87.948   2658
ALISE          0.002 87.949   2659
ALEX           0.002 87.951   2660
VERDELL        0.002 87.953   2661
VAL            0.002 87.955   2662
TYLER          0.002 87.957   2663
TOMOKO         0.002 87.958   2664
THAO           0.002 87.960   2665
TALISHA        0.002 87.962   2666
STEVEN         0.002 87.964   2667
SO             0.002 87.966   2668
SHEMIKA        0.002 87.967   2669
SHAUN          0.002 87.969   2670
SCARLET        0.002 87.971   2671
SAVANNA        0.002 87.973   2672
SANTINA        0.002 87.975   2673
ROSIA          0.002 87.976   2674
RAEANN         0.002 87.978   2675
ODILIA         0.002 87.980   2676
NANA           0.002 87.982   2677
MINNA          0.002 87.983   2678
MAGAN          0.002 87.985   2679
LYNELLE        0.002 87.987   2680
LE             0.002 87.989   2681
KARMA          0.002 87.991   2682
JOEANN         0.002 87.992   2683
IVANA          0.002 87.994   2684
INELL          0.002 87.996   2685
ILANA          0.002 87.998   2686
HYE            0.002 88.000   2687
HONEY          0.002 88.001   2688
HEE            0.002 88.003   2689
GUDRUN         0.002 88.005   2690
FRANK          0.002 88.007   2691
DREAMA         0.002 88.009   2692
CRISSY         0.002 88.010   2693
CHANTE         0.002 88.012   2694
CARMELINA      0.002 88.014   2695
ARVILLA        0.002 88.016   2696
ARTHUR         0.002 88.017   2697
ANNAMAE        0.002 88.019   2698
ALVERA         0.002 88.021   2699
ALEIDA         0.002 88.023   2700
AARON          0.002 88.025   2701
YEE            0.002 88.026   2702
YANIRA         0.002 88.028   2703
VANDA          0.002 88.030   2704
TIANNA         0.002 88.032   2705
TAM            0.002 88.033   2706
STEFANIA       0.002 88.035   2707
SHIRA          0.002 88.037   2708
PERRY          0.002 88.039   2709
NICOL          0.002 88.040   2710
NANCIE         0.002 88.042   2711
MONSERRATE     0.002 88.044   2712
MINH           0.002 88.046   2713
MELYNDA        0.002 88.048   2714
MELANY         0.002 88.049   2715
MATTHEW        0.002 88.051   2716
LOVELLA        0.002 88.053   2717
LAURE          0.002 88.055   2718
KIRBY          0.002 88.056   2719
KACY           0.002 88.058   2720
JACQUELYNN     0.002 88.060   2721
HYON           0.002 88.062   2722
GERTHA         0.002 88.063   2723
FRANCISCO      0.002 88.065   2724
ELIANA         0.002 88.067   2725
CHRISTENA      0.002 88.069   2726
CHRISTEEN      0.002 88.070   2727
CHARISE        0.002 88.072   2728
CATERINA       0.002 88.074   2729
CARLEY         0.002 88.076   2730
CANDYCE        0.002 88.077   2731
ARLENA         0.002 88.079   2732
AMMIE          0.002 88.081   2733
YANG           0.002 88.083   2734
WILLETTE       0.002 88.084   2735
VANITA         0.002 88.086   2736
TUYET          0.002 88.088   2737
TINY           0.002 88.090   2738
SYREETA        0.002 88.091   2739
SILVA          0.002 88.093   2740
SCOTT          0.002 88.095   2741
RONALD         0.002 88.096   2742
PENNEY         0.002 88.098   2743
NYLA           0.002 88.100   2744
MICHAL         0.002 88.102   2745
MAURICE        0.002 88.103   2746
MARYAM         0.002 88.105   2747
MARYA          0.002 88.107   2748
MAGEN          0.002 88.109   2749
LUDIE          0.002 88.110   2750
LOMA           0.002 88.112   2751
LIVIA          0.002 88.114   2752
LANELL         0.002 88.115   2753
KIMBERLIE      0.002 88.117   2754
JULEE          0.002 88.119   2755
DONETTA        0.002 88.121   2756
DIEDRA         0.002 88.122   2757
DENISHA        0.002 88.124   2758
DEANE          0.002 88.126   2759
DAWNE          0.002 88.128   2760
CLARINE        0.002 88.129   2761
CHERRYL        0.002 88.131   2762
BRONWYN        0.002 88.133   2763
BRANDON        0.002 88.134   2764
ALLA           0.002 88.136   2765
VALERY         0.002 88.138   2766
TONDA          0.002 88.140   2767
SUEANN         0.002 88.141   2768
SORAYA         0.002 88.143   2769
SHOSHANA       0.002 88.145   2770
SHELA          0.002 88.146   2771
SHARLEEN       0.002 88.148   2772
SHANELLE       0.002 88.150   2773
NERISSA        0.002 88.151   2774
MICHEAL        0.002 88.153   2775
MERIDITH       0.002 88.155   2776
MELLIE         0.002 88.157   2777
MAYE           0.002 88.158   2778
MAPLE          0.002 88.160   2779
MAGARET        0.002 88.162   2780
LUIS           0.002 88.163   2781
LILI           0.002 88.165   2782
LEONILA        0.002 88.167   2783
LEONIE         0.002 88.168   2784
LEEANNA        0.002 88.170   2785
LAVONIA        0.002 88.172   2786
LAVERA         0.002 88.173   2787
KRISTEL        0.002 88.175   2788
KATHEY         0.002 88.177   2789
KATHE          0.002 88.179   2790
JUSTIN         0.002 88.180   2791
JULIAN         0.002 88.182   2792
JIMMY          0.002 88.184   2793
JANN           0.002 88.185   2794
ILDA           0.002 88.187   2795
HILDRED        0.002 88.189   2796
HILDEGARDE     0.002 88.190   2797
GENIA          0.002 88.192   2798
FUMIKO         0.002 88.194   2799
EVELIN         0.002 88.196   2800
ERMELINDA      0.002 88.197   2801
ELLY           0.002 88.199   2802
DUNG           0.002 88.201   2803
DOLORIS        0.002 88.202   2804
DIONNA         0.002 88.204   2805
DANAE          0.002 88.206   2806
BERNEICE       0.002 88.207   2807
ANNICE         0.002 88.209   2808
ALIX           0.002 88.211   2809
VERENA         0.002 88.212   2810
VERDIE         0.002 88.214   2811
TRISTAN        0.002 88.216   2812
SHAWNNA        0.002 88.217   2813
SHAWANA        0.002 88.219   2814
SHAUNNA        0.002 88.221   2815
ROZELLA        0.002 88.222   2816
RANDEE         0.002 88.224   2817
RANAE          0.002 88.226   2818
MILAGRO        0.002 88.227   2819
LYNELL         0.002 88.229   2820
LUISE          0.002 88.231   2821
LOUIE          0.002 88.232   2822
LOIDA          0.002 88.234   2823
LISBETH        0.002 88.236   2824
KARLEEN        0.002 88.237   2825
JUNITA         0.002 88.239   2826
JONA           0.002 88.241   2827
ISIS           0.002 88.242   2828
HYACINTH       0.002 88.244   2829
HEDY           0.002 88.246   2830
GWENN          0.002 88.247   2831
ETHELENE       0.002 88.249   2832
ERLINE         0.002 88.251   2833
EDWARD         0.002 88.252   2834
DONYA          0.002 88.254   2835
DOMONIQUE      0.002 88.256   2836
DELICIA        0.002 88.257   2837
DANNETTE       0.002 88.259   2838
CICELY         0.002 88.261   2839
BRANDA         0.002 88.262   2840
BLYTHE         0.002 88.264   2841
BETHANN        0.002 88.266   2842
ASHLYN         0.002 88.267   2843
ANNALEE        0.002 88.269   2844
ALLINE         0.002 88.271   2845
YUKO           0.002 88.272   2846
VELLA          0.002 88.274   2847
TRANG          0.002 88.276   2848
TOWANDA        0.002 88.277   2849
TESHA          0.002 88.279   2850
SHERLYN        0.002 88.281   2851
NARCISA        0.002 88.282   2852
MIGUELINA      0.002 88.284   2853
MERI           0.002 88.285   2854
MAYBELL        0.002 88.287   2855
MARLANA        0.002 88.289   2856
MARGUERITA     0.002 88.290   2857
MADLYN         0.002 88.292   2858
LUNA           0.002 88.294   2859
LORY           0.002 88.295   2860
LORIANN        0.002 88.297   2861
LIBERTY        0.002 88.298   2862
LEONORE        0.002 88.300   2863
LEIGHANN       0.002 88.302   2864
LAURICE        0.002 88.303   2865
LATESHA        0.002 88.305   2866
LARONDA        0.002 88.307   2867
KATRICE        0.002 88.308   2868
KASIE          0.002 88.310   2869
KARL           0.002 88.312   2870
KALEY          0.002 88.313   2871
JADWIGA        0.002 88.315   2872
GLENNIE        0.002 88.316   2873
GEARLDINE      0.002 88.318   2874
FRANCINA       0.002 88.320   2875
EPIFANIA       0.002 88.321   2876
DYAN           0.002 88.323   2877
DORIE          0.002 88.325   2878
DIEDRE         0.002 88.326   2879
DENESE         0.002 88.328   2880
DEMETRICE      0.002 88.330   2881
DELENA         0.002 88.331   2882
DARBY          0.002 88.333   2883
CRISTIE        0.002 88.334   2884
CLEORA         0.002 88.336   2885
CATARINA       0.002 88.338   2886
CARISA         0.002 88.339   2887
BERNIE         0.002 88.341   2888
BARBERA        0.002 88.343   2889
ALMETA         0.002 88.344   2890
TRULA          0.002 88.346   2891
TEREASA        0.002 88.347   2892
SOLANGE        0.002 88.349   2893
SHEILAH        0.002 88.351   2894
SHAVONNE       0.002 88.352   2895
SANORA         0.002 88.354   2896
ROCHELL        0.002 88.355   2897
MATHILDE       0.002 88.357   2898
MARGARETA      0.002 88.359   2899
MAIA           0.002 88.360   2900
LYNSEY         0.002 88.362   2901
LAWANNA        0.002 88.363   2902
LAUNA          0.002 88.365   2903
KENA           0.002 88.367   2904
KEENA          0.002 88.368   2905
KATIA          0.002 88.370   2906
JAMEY          0.002 88.371   2907
GLYNDA         0.002 88.373   2908
GAYLENE        0.002 88.375   2909
ELVINA         0.002 88.376   2910
ELANOR         0.002 88.378   2911
DANUTA         0.002 88.379   2912
DANIKA         0.002 88.381   2913
CRISTEN        0.002 88.383   2914
CORDIE         0.002 88.384   2915
COLETTA        0.002 88.386   2916
CLARITA        0.002 88.387   2917
CARMON         0.002 88.389   2918
BRYNN          0.002 88.391   2919
AZUCENA        0.002 88.392   2920
AUNDREA        0.002 88.394   2921
ANGELE         0.002 88.395   2922
YI             0.002 88.397   2923
WALTER         0.002 88.399   2924
VERLIE         0.002 88.400   2925
VERLENE        0.002 88.402   2926
TAMESHA        0.002 88.403   2927
SILVANA        0.002 88.405   2928
SEBRINA        0.002 88.406   2929
SAMIRA         0.002 88.408   2930
REDA           0.002 88.410   2931
RAYLENE        0.002 88.411   2932
PENNI          0.002 88.413   2933
PANDORA        0.002 88.414   2934
NORAH          0.002 88.416   2935
NOMA           0.002 88.417   2936
MIREILLE       0.002 88.419   2937
MELISSIA       0.002 88.421   2938
MARYALICE      0.002 88.422   2939
LARAINE        0.002 88.424   2940
KIMBERY        0.002 88.425   2941
KARYL          0.002 88.427   2942
KARINE         0.002 88.428   2943
KAM            0.002 88.430   2944
JOLANDA        0.002 88.432   2945
JOHANA         0.002 88.433   2946
JESUSA         0.002 88.435   2947
JALEESA        0.002 88.436   2948
JAE            0.002 88.438   2949
JACQUELYNE     0.002 88.439   2950
IRISH          0.002 88.441   2951
ILUMINADA      0.002 88.443   2952
HILARIA        0.002 88.444   2953
HANH           0.002 88.446   2954
GENNIE         0.002 88.447   2955
FRANCIE        0.002 88.449   2956
FLORETTA       0.002 88.450   2957
EXIE           0.002 88.452   2958
EDDA           0.002 88.454   2959
DREMA          0.002 88.455   2960
DELPHA         0.002 88.457   2961
BEV            0.002 88.458   2962
BARBAR         0.002 88.460   2963
ASSUNTA        0.002 88.461   2964
ARDELL         0.002 88.463   2965
ANNALISA       0.002 88.465   2966
ALISIA         0.002 88.466   2967
YUKIKO         0.002 88.468   2968
YOLANDO        0.002 88.469   2969
WONDA          0.002 88.471   2970
WEI            0.002 88.472   2971
WALTRAUD       0.002 88.474   2972
VETA           0.002 88.475   2973
TEQUILA        0.002 88.477   2974
TEMEKA         0.002 88.478   2975
TAMEIKA        0.002 88.480   2976
SHIRLEEN       0.002 88.481   2977
SHENITA        0.002 88.483   2978
PIEDAD         0.002 88.485   2979
OZELLA         0.002 88.486   2980
MIRTHA         0.002 88.488   2981
MARILU         0.002 88.489   2982
KIMIKO         0.002 88.491   2983
JULIANE        0.002 88.492   2984
JENICE         0.002 88.494   2985
JEN            0.002 88.495   2986
JANAY          0.002 88.497   2987
JACQUILINE     0.002 88.498   2988
HILDE          0.002 88.500   2989
FE             0.002 88.502   2990
FAE            0.002 88.503   2991
EVAN           0.002 88.505   2992
EUGENE         0.002 88.506   2993
ELOIS          0.002 88.508   2994
ECHO           0.002 88.509   2995
DEVORAH        0.002 88.511   2996
CHAU           0.002 88.512   2997
BRINDA         0.002 88.514   2998
BETSEY         0.002 88.515   2999
ARMINDA        0.002 88.517   3000
ARACELIS       0.002 88.518   3001
APRYL          0.002 88.520   3002
ANNETT         0.002 88.522   3003
ALISHIA        0.002 88.523   3004
VEOLA          0.002 88.525   3005
USHA           0.002 88.526   3006
TOSHIKO        0.002 88.528   3007
THEOLA         0.002 88.529   3008
TASHIA         0.002 88.531   3009
TALITHA        0.002 88.532   3010
SHERY          0.002 88.534   3011
RUDY           0.002 88.535   3012
RENETTA        0.002 88.537   3013
REIKO          0.002 88.538   3014
RASHEEDA       0.002 88.540   3015
OMEGA          0.002 88.541   3016
OBDULIA        0.002 88.543   3017
MIKA           0.002 88.544   3018
MELAINE        0.002 88.546   3019
MEGGAN         0.002 88.547   3020
MARTIN         0.002 88.549   3021
MARLEN         0.002 88.550   3022
MARGET         0.002 88.552   3023
MARCELINE      0.002 88.553   3024
MANA           0.002 88.555   3025
MAGDALEN       0.002 88.556   3026
LIBRADA        0.002 88.558   3027
LEZLIE         0.002 88.559   3028
LEXIE          0.002 88.561   3029
LATASHIA       0.002 88.562   3030
LASANDRA       0.002 88.564   3031
KELLE          0.002 88.565   3032
ISIDRA         0.002 88.567   3033
ISA            0.002 88.568   3034
INOCENCIA      0.002 88.570   3035
GWYN           0.002 88.571   3036
FRANCOISE      0.002 88.573   3037
ERMINIA        0.002 88.574   3038
ERINN          0.002 88.576   3039
DIMPLE         0.002 88.577   3040
DEVORA         0.002 88.579   3041
CRISELDA       0.002 88.580   3042
ARMANDA        0.002 88.582   3043
ARIE           0.002 88.583   3044
ARIANE         0.002 88.585   3045
ANGELO         0.002 88.586   3046
ANGELENA       0.002 88.588   3047
ALLEN          0.002 88.589   3048
ALIZA          0.002 88.591   3049
ADRIENE        0.002 88.592   3050
ADALINE        0.002 88.594   3051
XOCHITL        0.001 88.595   3052
TWANNA         0.001 88.597   3053
TRAN           0.001 88.598   3054
TOMIKO         0.001 88.600   3055
TAMISHA        0.001 88.601   3056
TAISHA         0.001 88.603   3057
SUSY           0.001 88.604   3058
SIU            0.001 88.606   3059
RUTHA          0.001 88.607   3060
ROXY           0.001 88.609   3061
RHONA          0.001 88.610   3062
RAYMOND        0.001 88.612   3063
OTHA           0.001 88.613   3064
NORIKO         0.001 88.615   3065
NATASHIA       0.001 88.616   3066
MERRIE         0.001 88.618   3067
MELVIN         0.001 88.619   3068
MARINDA        0.001 88.620   3069
MARIKO         0.001 88.622   3070
MARGERT        0.001 88.623   3071
LORIS          0.001 88.625   3072
LIZZETTE       0.001 88.626   3073
LEISHA         0.001 88.628   3074
KAILA          0.001 88.629   3075
KA             0.001 88.631   3076
JOANNIE        0.001 88.632   3077
JERRICA        0.001 88.634   3078
JENE           0.001 88.635   3079
JANNET         0.001 88.637   3080
JANEE          0.001 88.638   3081
JACINDA        0.001 88.640   3082
HERTA          0.001 88.641   3083
ELENORE        0.001 88.643   3084
DORETTA        0.001 88.644   3085
DELAINE        0.001 88.646   3086
DANIELL        0.001 88.647   3087
CLAUDIE        0.001 88.649   3088
CHINA          0.001 88.650   3089
BRITTA         0.001 88.651   3090
APOLONIA       0.001 88.653   3091
AMBERLY        0.001 88.654   3092
ALEASE         0.001 88.656   3093
YURI           0.001 88.657   3094
YUK            0.001 88.659   3095
WEN            0.001 88.660   3096
WANETA         0.001 88.662   3097
UTE            0.001 88.663   3098
TOMI           0.001 88.665   3099
SHARRI         0.001 88.666   3100
SANDIE         0.001 88.667   3101
ROSELLE        0.001 88.669   3102
REYNALDA       0.001 88.670   3103
RAGUEL         0.001 88.672   3104
PHYLICIA       0.001 88.673   3105
PATRIA         0.001 88.675   3106
OLIMPIA        0.001 88.676   3107
ODELIA         0.001 88.678   3108
MITZIE         0.001 88.679   3109
MITCHELL       0.001 88.680   3110
MISS           0.001 88.682   3111
MINDA          0.001 88.683   3112
MIGNON         0.001 88.685   3113
MICA           0.001 88.686   3114
MENDY          0.001 88.688   3115
MARIVEL        0.001 88.689   3116
MAILE          0.001 88.691   3117
LYNETTA        0.001 88.692   3118
LAVETTE        0.001 88.693   3119
LAURYN         0.001 88.695   3120
LATRISHA       0.001 88.696   3121
LAKIESHA       0.001 88.698   3122
KIERSTEN       0.001 88.699   3123
KARY           0.001 88.701   3124
JOSPHINE       0.001 88.702   3125
JOLYN          0.001 88.704   3126
JETTA          0.001 88.705   3127
JANISE         0.001 88.706   3128
JACQUIE        0.001 88.708   3129
IVELISSE       0.001 88.709   3130
GLYNIS         0.001 88.711   3131
GIANNA         0.001 88.712   3132
GAYNELLE       0.001 88.714   3133
EMERALD        0.001 88.715   3134
DEMETRIUS      0.001 88.717   3135
DANYELL        0.001 88.718   3136
DANILLE        0.001 88.719   3137
DACIA          0.001 88.721   3138
CORALEE        0.001 88.722   3139
CHER           0.001 88.724   3140
CEOLA          0.001 88.725   3141
BRETT          0.001 88.727   3142
BELL           0.001 88.728   3143
ARIANNE        0.001 88.730   3144
ALESHIA        0.001 88.731   3145
YUNG           0.001 88.732   3146
WILLIEMAE      0.001 88.734   3147
TROY           0.001 88.735   3148
TRINH          0.001 88.737   3149
THORA          0.001 88.738   3150
TAI            0.001 88.739   3151
SVETLANA       0.001 88.741   3152
SHERIKA        0.001 88.742   3153
SHEMEKA        0.001 88.744   3154
SHAUNDA        0.001 88.745   3155
ROSELINE       0.001 88.747   3156
RICKI          0.001 88.748   3157
MELDA          0.001 88.749   3158
MALLIE         0.001 88.751   3159
LAVONNA        0.001 88.752   3160
LATINA         0.001 88.754   3161
LARRY          0.001 88.755   3162
LAQUANDA       0.001 88.756   3163
LALA           0.001 88.758   3164
LACHELLE       0.001 88.759   3165
KLARA          0.001 88.761   3166
KANDIS         0.001 88.762   3167
JOHNA          0.001 88.763   3168
JEANMARIE      0.001 88.765   3169
JAYE           0.001 88.766   3170
HANG           0.001 88.768   3171
GRAYCE         0.001 88.769   3172
GERTUDE        0.001 88.771   3173
EMERITA        0.001 88.772   3174
EBONIE         0.001 88.773   3175
CLORINDA       0.001 88.775   3176
CHING          0.001 88.776   3177
CHERY          0.001 88.778   3178
CAROLA         0.001 88.779   3179
BREANN         0.001 88.780   3180
BLOSSOM        0.001 88.782   3181
BERNARDINE     0.001 88.783   3182
BECKI          0.001 88.785   3183
ARLETHA        0.001 88.786   3184
ARGELIA        0.001 88.788   3185
ARA            0.001 88.789   3186
ALITA          0.001 88.790   3187
YULANDA        0.001 88.792   3188
YON            0.001 88.793   3189
YESSENIA       0.001 88.794   3190
TOBI           0.001 88.796   3191
TASIA          0.001 88.797   3192
SYLVIE         0.001 88.799   3193
SHIRL          0.001 88.800   3194
SHIRELY        0.001 88.801   3195
SHERIDAN       0.001 88.803   3196
SHELLA         0.001 88.804   3197
SHANTELLE      0.001 88.806   3198
SACHA          0.001 88.807   3199
ROYCE          0.001 88.808   3200
REBECKA        0.001 88.810   3201
REAGAN         0.001 88.811   3202
PROVIDENCIA    0.001 88.812   3203
PAULENE        0.001 88.814   3204
MISHA          0.001 88.815   3205
MIKI           0.001 88.817   3206
MARLINE        0.001 88.818   3207
MARICA         0.001 88.819   3208
LORITA         0.001 88.821   3209
LATOYIA        0.001 88.822   3210
LASONYA        0.001 88.824   3211
KERSTIN        0.001 88.825   3212
KENDA          0.001 88.826   3213
KEITHA         0.001 88.828   3214
KATHRIN        0.001 88.829   3215
JAYMIE         0.001 88.830   3216
JACK           0.001 88.832   3217
GRICELDA       0.001 88.833   3218
GINETTE        0.001 88.835   3219
ERYN           0.001 88.836   3220
ELINA          0.001 88.837   3221
ELFRIEDA       0.001 88.839   3222
DANYEL         0.001 88.840   3223
CHEREE         0.001 88.841   3224
CHANELLE       0.001 88.843   3225
BARRIE         0.001 88.844   3226
AVERY          0.001 88.846   3227
AURORE         0.001 88.847   3228
ANNAMARIA      0.001 88.848   3229
ALLEEN         0.001 88.850   3230
AILENE         0.001 88.851   3231
AIDE           0.001 88.853   3232
YASMINE        0.001 88.854   3233
VASHTI         0.001 88.855   3234
VALENTINE      0.001 88.857   3235
TREASA         0.001 88.858   3236
TORY           0.001 88.859   3237
TIFFANEY       0.001 88.861   3238
SHERYLL        0.001 88.862   3239
SHARIE         0.001 88.863   3240
SHANAE         0.001 88.865   3241
SAU            0.001 88.866   3242
RAISA          0.001 88.867   3243
PA             0.001 88.869   3244
NEDA           0.001 88.870   3245
MITSUKO        0.001 88.871   3246
MIRELLA        0.001 88.873   3247
MILDA          0.001 88.874   3248
MARYANNA       0.001 88.875   3249
MARAGRET       0.001 88.877   3250
MABELLE        0.001 88.878   3251
LUETTA         0.001 88.880   3252
LORINA         0.001 88.881   3253
LETISHA        0.001 88.882   3254
LATARSHA       0.001 88.884   3255
LANELLE        0.001 88.885   3256
LAJUANA        0.001 88.886   3257
KRISSY         0.001 88.888   3258
KARLY          0.001 88.889   3259
KARENA         0.001 88.890   3260
JON            0.001 88.892   3261
JESSIKA        0.001 88.893   3262
JERICA         0.001 88.894   3263
JEANELLE       0.001 88.896   3264
JANUARY        0.001 88.897   3265
JALISA         0.001 88.898   3266
JACELYN        0.001 88.900   3267
IZOLA          0.001 88.901   3268
IVEY           0.001 88.902   3269
GREGORY        0.001 88.904   3270
EUNA           0.001 88.905   3271
ETHA           0.001 88.907   3272
DREW           0.001 88.908   3273
DOMITILA       0.001 88.909   3274
DOMINICA       0.001 88.911   3275
DAINA          0.001 88.912   3276
CREOLA         0.001 88.913   3277
CARLI          0.001 88.915   3278
CAMIE          0.001 88.916   3279
BUNNY          0.001 88.917   3280
BRITTNY        0.001 88.919   3281
ASHANTI        0.001 88.920   3282
ANISHA         0.001 88.921   3283
ALEEN          0.001 88.923   3284
ADAH           0.001 88.924   3285
YASUKO         0.001 88.925   3286
WINTER         0.001 88.927   3287
VIKI           0.001 88.928   3288
VALRIE         0.001 88.929   3289
TONA           0.001 88.931   3290
TINISHA        0.001 88.932   3291
THI            0.001 88.933   3292
TERISA         0.001 88.935   3293
TATUM          0.001 88.936   3294
TANEKA         0.001 88.937   3295
SIMONNE        0.001 88.939   3296
SHALANDA       0.001 88.940   3297
SERITA         0.001 88.941   3298
RESSIE         0.001 88.943   3299
REFUGIA        0.001 88.944   3300
PAZ            0.001 88.945   3301
OLENE          0.001 88.947   3302
NA             0.001 88.948   3303
MERRILL        0.001 88.949   3304
MARGHERITA     0.001 88.950   3305
MANDIE         0.001 88.952   3306
MAN            0.001 88.953   3307
MAIRE          0.001 88.954   3308
LYNDIA         0.001 88.956   3309
LUCI           0.001 88.957   3310
LORRIANE       0.001 88.958   3311
LORETA         0.001 88.960   3312
LEONIA         0.001 88.961   3313
LAVONA         0.001 88.962   3314
LASHAWNDA      0.001 88.964   3315
LAKIA          0.001 88.965   3316
KYOKO          0.001 88.966   3317
KRYSTINA       0.001 88.968   3318
KRYSTEN        0.001 88.969   3319
KENIA          0.001 88.970   3320
KELSI          0.001 88.972   3321
JUDE           0.001 88.973   3322
JEANICE        0.001 88.974   3323
ISOBEL         0.001 88.976   3324
GEORGIANN      0.001 88.977   3325
GENNY          0.001 88.978   3326
FELICIDAD      0.001 88.979   3327
EILENE         0.001 88.981   3328
DEON           0.001 88.982   3329
DELOISE        0.001 88.983   3330
DEEDEE         0.001 88.985   3331
DANNIE         0.001 88.986   3332
CONCEPTION     0.001 88.987   3333
CLORA          0.001 88.989   3334
CHERILYN       0.001 88.990   3335
CHANG          0.001 88.991   3336
CALANDRA       0.001 88.993   3337
BERRY          0.001 88.994   3338
ARMANDINA      0.001 88.995   3339
ANISA          0.001 88.997   3340
ULA            0.001 88.998   3341
TIMOTHY        0.001 88.999   3342
TIERA          0.001 89.000   3343
THERESSA       0.001 89.002   3344
STEPHANIA      0.001 89.003   3345
SIMA           0.001 89.004   3346
SHYLA          0.001 89.006   3347
SHONTA         0.001 89.007   3348
SHERA          0.001 89.008   3349
SHAQUITA       0.001 89.010   3350
SHALA          0.001 89.011   3351
SAMMY          0.001 89.012   3352
ROSSANA        0.001 89.013   3353
NOHEMI         0.001 89.015   3354
NERY           0.001 89.016   3355
MORIAH         0.001 89.017   3356
MELITA         0.001 89.019   3357
MELIDA         0.001 89.020   3358
MELANI         0.001 89.021   3359
MARYLYNN       0.001 89.022   3360
MARISHA        0.001 89.024   3361
MARIETTE       0.001 89.025   3362
MALORIE        0.001 89.026   3363
MADELENE       0.001 89.028   3364
LUDIVINA       0.001 89.029   3365
LORIA          0.001 89.030   3366
LORETTE        0.001 89.031   3367
LORALEE        0.001 89.033   3368
LIANNE         0.001 89.034   3369
LEON           0.001 89.035   3370
LAVENIA        0.001 89.037   3371
LAURINDA       0.001 89.038   3372
LASHON         0.001 89.039   3373
KIT            0.001 89.040   3374
KIMI           0.001 89.042   3375
KEILA          0.001 89.043   3376
KATELYNN       0.001 89.044   3377
KAI            0.001 89.046   3378
JONE           0.001 89.047   3379
JOANE          0.001 89.048   3380
JI             0.001 89.049   3381
JAYNA          0.001 89.051   3382
JANELLA        0.001 89.052   3383
JA             0.001 89.053   3384
HUE            0.001 89.055   3385
HERTHA         0.001 89.056   3386
FRANCENE       0.001 89.057   3387
ELINORE        0.001 89.058   3388
DESPINA        0.001 89.060   3389
DELSIE         0.001 89.061   3390
DEEDRA         0.001 89.062   3391
CLEMENCIA      0.001 89.064   3392
CARRY          0.001 89.065   3393
CAROLIN        0.001 89.066   3394
CARLOS         0.001 89.067   3395
BULAH          0.001 89.069   3396
BRITTANIE      0.001 89.070   3397
BOK            0.001 89.071   3398
BLONDELL       0.001 89.073   3399
BIBI           0.001 89.074   3400
BEAULAH        0.001 89.075   3401
BEATA          0.001 89.076   3402
ANNITA         0.001 89.078   3403
AGRIPINA       0.001 89.079   3404
VIRGEN         0.001 89.080   3405
VALENE         0.001 89.082   3406
UN             0.001 89.083   3407
TWANDA         0.001 89.084   3408
TOMMYE         0.001 89.085   3409
TOI            0.001 89.087   3410
TARRA          0.001 89.088   3411
TARI           0.001 89.089   3412
TAMMERA        0.001 89.090   3413
SHAKIA         0.001 89.092   3414
SADYE          0.001 89.093   3415
RUTHANNE       0.001 89.094   3416
ROCHEL         0.001 89.095   3417
RIVKA          0.001 89.097   3418
PURA           0.001 89.098   3419
NENITA         0.001 89.099   3420
NATISHA        0.001 89.100   3421
MING           0.001 89.102   3422
MERRILEE       0.001 89.103   3423
MELODEE        0.001 89.104   3424
MARVIS         0.001 89.105   3425
LUCILLA        0.001 89.107   3426
LEENA          0.001 89.108   3427
LAVETA         0.001 89.109   3428
LARITA         0.001 89.110   3429
LANIE          0.001 89.112   3430
KEREN          0.001 89.113   3431
ILEEN          0.001 89.114   3432
GEORGEANN      0.001 89.115   3433
GENNA          0.001 89.117   3434
GENESIS        0.001 89.118   3435
FRIDA          0.001 89.119   3436
EWA            0.001 89.120   3437
EUFEMIA        0.001 89.122   3438
EMELY          0.001 89.123   3439
ELA            0.001 89.124   3440
EDYTH          0.001 89.126   3441
DEONNA         0.001 89.127   3442
DEADRA         0.001 89.128   3443
DARLENA        0.001 89.129   3444
CHANELL        0.001 89.131   3445
CHAN           0.001 89.132   3446
CATHERN        0.001 89.133   3447
CASSONDRA      0.001 89.134   3448
CASSAUNDRA     0.001 89.136   3449
BERNARDA       0.001 89.137   3450
BERNA          0.001 89.138   3451
ARLINDA        0.001 89.139   3452
ANAMARIA       0.001 89.141   3453
ALBERT         0.001 89.142   3454
WESLEY         0.001 89.143   3455
VERTIE         0.001 89.144   3456
VALERI         0.001 89.146   3457
TORRI          0.001 89.147   3458
TATYANA        0.001 89.148   3459
STASIA         0.001 89.149   3460
SHERISE        0.001 89.150   3461
SHERILL        0.001 89.152   3462
SEASON         0.001 89.153   3463
SCOTTIE        0.001 89.154   3464
SANDA          0.001 89.155   3465
RUTHE          0.001 89.157   3466
ROSY           0.001 89.158   3467
ROBERTO        0.001 89.159   3468
ROBBI          0.001 89.160   3469
RANEE          0.001 89.161   3470
QUYEN          0.001 89.163   3471
PEARLY         0.001 89.164   3472
PALMIRA        0.001 89.165   3473
ONITA          0.001 89.166   3474
NISHA          0.001 89.168   3475
NIESHA         0.001 89.169   3476
NIDA           0.001 89.170   3477
NEVADA         0.001 89.171   3478
NAM            0.001 89.172   3479
MERLYN         0.001 89.174   3480
MAYOLA         0.001 89.175   3481
MARYLOUISE     0.001 89.176   3482
MARYLAND       0.001 89.177   3483
MARX           0.001 89.179   3484
MARTH          0.001 89.180   3485
MARGENE        0.001 89.181   3486
MADELAINE      0.001 89.182   3487
LONDA          0.001 89.183   3488
LEONTINE       0.001 89.185   3489
LEOMA          0.001 89.186   3490
LEIA           0.001 89.187   3491
LAWRENCE       0.001 89.188   3492
LAURALEE       0.001 89.190   3493
LANORA         0.001 89.191   3494
LAKITA         0.001 89.192   3495
KIYOKO         0.001 89.193   3496
KETURAH        0.001 89.195   3497
KATELIN        0.001 89.196   3498
KAREEN         0.001 89.197   3499
JONIE          0.001 89.198   3500
JOHNETTE       0.001 89.199   3501
JENEE          0.001 89.201   3502
JEANETT        0.001 89.202   3503
IZETTA         0.001 89.203   3504
HIEDI          0.001 89.204   3505
HEIKE          0.001 89.206   3506
HASSIE         0.001 89.207   3507
HAROLD         0.001 89.208   3508
GIUSEPPINA     0.001 89.209   3509
GEORGANN       0.001 89.210   3510
FIDELA         0.001 89.212   3511
FERNANDE       0.001 89.213   3512
ELWANDA        0.001 89.214   3513
ELLAMAE        0.001 89.215   3514
ELIZ           0.001 89.217   3515
DUSTI          0.001 89.218   3516
DOTTY          0.001 89.219   3517
CYNDY          0.001 89.220   3518
CORALIE        0.001 89.221   3519
CELESTA        0.001 89.223   3520
ARGENTINA      0.001 89.224   3521
ALVERTA        0.001 89.225   3522
XENIA          0.001 89.226   3523
WAVA           0.001 89.228   3524
VANETTA        0.001 89.229   3525
TORRIE         0.001 89.230   3526
TASHINA        0.001 89.231   3527
TANDY          0.001 89.232   3528
TAMBRA         0.001 89.233   3529
TAMA           0.001 89.235   3530
STEPANIE       0.001 89.236   3531
SHILA          0.001 89.237   3532
SHAUNTA        0.001 89.238   3533
SHARAN         0.001 89.239   3534
SHANIQUA       0.001 89.241   3535
SHAE           0.001 89.242   3536
SETSUKO        0.001 89.243   3537
SERAFINA       0.001 89.244   3538
SANDEE         0.001 89.245   3539
ROSAMARIA      0.001 89.247   3540
PRISCILA       0.001 89.248   3541
OLINDA         0.001 89.249   3542
NADENE         0.001 89.250   3543
MUOI           0.001 89.251   3544
MICHELINA      0.001 89.253   3545
MERCEDEZ       0.001 89.254   3546
MARYROSE       0.001 89.255   3547
MARIN          0.001 89.256   3548
MARCENE        0.001 89.257   3549
MAO            0.001 89.259   3550
MAGALI         0.001 89.260   3551
MAFALDA        0.001 89.261   3552
LOGAN          0.001 89.262   3553
LINN           0.001 89.263   3554
LANNIE         0.001 89.265   3555
KAYCE          0.001 89.266   3556
KAROLINE       0.001 89.267   3557
KAMILAH        0.001 89.268   3558
KAMALA         0.001 89.269   3559
JUSTA          0.001 89.270   3560
JOLINE         0.001 89.272   3561
JENNINE        0.001 89.273   3562
JACQUETTA      0.001 89.274   3563
IRAIDA         0.001 89.275   3564
GERALD         0.001 89.276   3565
GEORGEANNA     0.001 89.278   3566
FRANCHESCA     0.001 89.279   3567
FAIRY          0.001 89.280   3568
EMELINE        0.001 89.281   3569
ELANE          0.001 89.282   3570
EHTEL          0.001 89.284   3571
EARLIE         0.001 89.285   3572
DULCIE         0.001 89.286   3573
DALENE         0.001 89.287   3574
CRIS           0.001 89.288   3575
CLASSIE        0.001 89.290   3576
CHERE          0.001 89.291   3577
CHARIS         0.001 89.292   3578
CAROYLN        0.001 89.293   3579
CARMINA        0.001 89.294   3580
CARITA         0.001 89.296   3581
BRIAN          0.001 89.297   3582
BETHANIE       0.001 89.298   3583
AYAKO          0.001 89.299   3584
ARICA          0.001 89.300   3585
AN             0.001 89.301   3586
ALYSA          0.001 89.303   3587
ALESSANDRA     0.001 89.304   3588
AKILAH         0.001 89.305   3589
ADRIEN         0.001 89.306   3590
ZETTA          0.001 89.307   3591
YOULANDA       0.001 89.309   3592
YELENA         0.001 89.310   3593
YAHAIRA        0.001 89.311   3594
XUAN           0.001 89.312   3595
WENDOLYN       0.001 89.313   3596
VICTOR         0.001 89.314   3597
TIJUANA        0.001 89.316   3598
TERRELL        0.001 89.317   3599
TERINA         0.001 89.318   3600
TERESIA        0.001 89.319   3601
SUZI           0.001 89.320   3602
SUNDAY         0.001 89.321   3603
SHERELL        0.001 89.323   3604
SHAVONDA       0.001 89.324   3605
SHAUNTE        0.001 89.325   3606
SHARDA         0.001 89.326   3607
SHAKITA        0.001 89.327   3608
SENA           0.001 89.328   3609
RYANN          0.001 89.330   3610
RUBI           0.001 89.331   3611
RIVA           0.001 89.332   3612
REGINIA        0.001 89.333   3613
REA            0.001 89.334   3614
RACHAL         0.001 89.335   3615
PARTHENIA      0.001 89.336   3616
PAMULA         0.001 89.338   3617
MONNIE         0.001 89.339   3618
MONET          0.001 89.340   3619
MICHAELE       0.001 89.341   3620
MELIA          0.001 89.342   3621
MARINE         0.001 89.343   3622
MALKA          0.001 89.345   3623
MAISHA         0.001 89.346   3624
LISANDRA       0.001 89.347   3625
LEO            0.001 89.348   3626
LEKISHA        0.001 89.349   3627
LEAN           0.001 89.350   3628
LAURENCE       0.001 89.352   3629
LAKENDRA       0.001 89.353   3630
KRYSTIN        0.001 89.354   3631
KORTNEY        0.001 89.355   3632
KIZZIE         0.001 89.356   3633
KITTIE         0.001 89.357   3634
KERA           0.001 89.359   3635
KENDAL         0.001 89.360   3636
KEMBERLY       0.001 89.361   3637
KANISHA        0.001 89.362   3638
JULENE         0.001 89.363   3639
JULE           0.001 89.364   3640
JOSHUA         0.001 89.366   3641
JOHANNE        0.001 89.367   3642
JEFFREY        0.001 89.368   3643
JAMEE          0.001 89.369   3644
HAN            0.001 89.370   3645
HALLEY         0.001 89.371   3646
GIDGET         0.001 89.373   3647
GALINA         0.001 89.374   3648
FREDRICKA      0.001 89.375   3649
FLETA          0.001 89.376   3650
FATIMAH        0.001 89.377   3651
EUSEBIA        0.001 89.378   3652
ELZA           0.001 89.379   3653
ELEONORE       0.001 89.381   3654
DORTHEY        0.001 89.382   3655
DORIA          0.001 89.383   3656
DONELLA        0.001 89.384   3657
DINORAH        0.001 89.385   3658
DELORSE        0.001 89.386   3659
CLARETHA       0.001 89.388   3660
CHRISTINIA     0.001 89.389   3661
CHARLYN        0.001 89.390   3662
BONG           0.001 89.391   3663
BELKIS         0.001 89.392   3664
AZZIE          0.001 89.393   3665
ANDERA         0.001 89.395   3666
AIKO           0.001 89.396   3667
ADENA          0.001 89.397   3668
YER            0.001 89.398   3669
YAJAIRA        0.001 89.399   3670
WAN            0.001 89.400   3671
VANIA          0.001 89.401   3672
ULRIKE         0.001 89.403   3673
TOSHIA         0.001 89.404   3674
TIFANY         0.001 89.405   3675
STEFANY        0.001 89.406   3676
SHIZUE         0.001 89.407   3677
SHENIKA        0.001 89.408   3678
SHAWANNA       0.001 89.409   3679
SHAROLYN       0.001 89.410   3680
SHARILYN       0.001 89.412   3681
SHAQUANA       0.001 89.413   3682
SHANTAY        0.001 89.414   3683
SEE            0.001 89.415   3684
ROZANNE        0.001 89.416   3685
ROSELEE        0.001 89.417   3686
RICKIE         0.001 89.418   3687
REMONA         0.001 89.420   3688
REANNA         0.001 89.421   3689
RAELENE        0.001 89.422   3690
QUINN          0.001 89.423   3691
PHUNG          0.001 89.424   3692
PETRONILA      0.001 89.425   3693
NATACHA        0.001 89.426   3694
NANCEY         0.001 89.427   3695
MYRL           0.001 89.429   3696
MIYOKO         0.001 89.430   3697
MIESHA         0.001 89.431   3698
MERIDETH       0.001 89.432   3699
MARVELLA       0.001 89.433   3700
MARQUITTA      0.001 89.434   3701
MARHTA         0.001 89.435   3702
MARCHELLE      0.001 89.436   3703
LIZETH         0.001 89.438   3704
LIBBIE         0.001 89.439   3705
LAHOMA         0.001 89.440   3706
LADAWN         0.001 89.441   3707
KINA           0.001 89.442   3708
KATHELEEN      0.001 89.443   3709
KATHARYN       0.001 89.444   3710
KARISA         0.001 89.446   3711
KALEIGH        0.001 89.447   3712
JUNIE          0.001 89.448   3713
JULIEANN       0.001 89.449   3714
JOHNSIE        0.001 89.450   3715
JANEAN         0.001 89.451   3716
JAIMEE         0.001 89.452   3717
JACKQUELINE    0.001 89.453   3718
HISAKO         0.001 89.455   3719
HERMA          0.001 89.456   3720
HELAINE        0.001 89.457   3721
GWYNETH        0.001 89.458   3722
GLENN          0.001 89.459   3723
GITA           0.001 89.460   3724
EUSTOLIA       0.001 89.461   3725
EMELINA        0.001 89.462   3726
ELIN           0.001 89.464   3727
EDRIS          0.001 89.465   3728
DONNETTE       0.001 89.466   3729
DONNETTA       0.001 89.467   3730
DIERDRE        0.001 89.468   3731
DENAE          0.001 89.469   3732
DARCEL         0.001 89.470   3733
CLAUDE         0.001 89.472   3734
CLARISA        0.001 89.473   3735
CINDERELLA     0.001 89.474   3736
CHIA           0.001 89.475   3737
CHARLESETTA    0.001 89.476   3738
CHARITA        0.001 89.477   3739
CELSA          0.001 89.478   3740
CASSY          0.001 89.479   3741
CASSI          0.001 89.481   3742
CARLEE         0.001 89.482   3743
BRUNA          0.001 89.483   3744
BRITTANEY      0.001 89.484   3745
BRANDE         0.001 89.485   3746
BILLI          0.001 89.486   3747
BAO            0.001 89.487   3748
ANTONETTA      0.001 89.488   3749
ANGLA          0.001 89.490   3750
ANGELYN        0.001 89.491   3751
ANALISA        0.001 89.492   3752
ALANE          0.001 89.493   3753
WENONA         0.001 89.494   3754
WENDIE         0.001 89.495   3755
VERONIQUE      0.001 89.496   3756
VANNESA        0.001 89.497   3757
TOBIE          0.001 89.498   3758
TEMPIE         0.001 89.500   3759
SUMIKO         0.001 89.501   3760
SULEMA         0.001 89.502   3761
SPARKLE        0.001 89.503   3762
SOMER          0.001 89.504   3763
SHEBA          0.001 89.505   3764
SHAYNE         0.001 89.506   3765
SHARICE        0.001 89.507   3766
SHANEL         0.001 89.508   3767
SHALON         0.001 89.509   3768
SAGE           0.001 89.511   3769
ROY            0.001 89.512   3770
ROSIO          0.001 89.513   3771
ROSELIA        0.001 89.514   3772
RENAY          0.001 89.515   3773
REMA           0.001 89.516   3774
REENA          0.001 89.517   3775
PORSCHE        0.001 89.518   3776
PING           0.001 89.519   3777
PEG            0.001 89.520   3778
OZIE           0.001 89.522   3779
ORETHA         0.001 89.523   3780
ORALEE         0.001 89.524   3781
ODA            0.001 89.525   3782
NU             0.001 89.526   3783
NGAN           0.001 89.527   3784
NAKESHA        0.001 89.528   3785
MILLY          0.001 89.529   3786
MARYBELLE      0.001 89.530   3787
MARLIN         0.001 89.531   3788
MARIS          0.001 89.533   3789
MARGRETT       0.001 89.534   3790
MARAGARET      0.001 89.535   3791
MANIE          0.001 89.536   3792
LURLENE        0.001 89.537   3793
LILLIA         0.001 89.538   3794
LIESELOTTE     0.001 89.539   3795
LAVELLE        0.001 89.540   3796
LASHAUNDA      0.001 89.541   3797
LAKEESHA       0.001 89.542   3798
KEITH          0.001 89.544   3799
KAYCEE         0.001 89.545   3800
KALYN          0.001 89.546   3801
JOYA           0.001 89.547   3802
JOETTE         0.001 89.548   3803
JENAE          0.001 89.549   3804
JANIECE        0.001 89.550   3805
ILLA           0.001 89.551   3806
GRISEL         0.001 89.552   3807
GLAYDS         0.001 89.553   3808
GENEVIE        0.001 89.555   3809
GALA           0.001 89.556   3810
FREDDA         0.001 89.557   3811
FRED           0.001 89.558   3812
ELMER          0.001 89.559   3813
ELEONOR        0.001 89.560   3814
DEBERA         0.001 89.561   3815
DEANDREA       0.001 89.562   3816
DAN            0.001 89.563   3817
CORRINNE       0.001 89.564   3818
CORDIA         0.001 89.566   3819
CONTESSA       0.001 89.567   3820
COLENE         0.001 89.568   3821
CLEOTILDE      0.001 89.569   3822
CHARLOTT       0.001 89.570   3823
CHANTAY        0.001 89.571   3824
CECILLE        0.001 89.572   3825
BEATRIS        0.001 89.573   3826
AZALEE         0.001 89.574   3827
ARLEAN         0.001 89.575   3828
ARDATH         0.001 89.577   3829
ANJELICA       0.001 89.578   3830
ANJA           0.001 89.579   3831
ALFREDIA       0.001 89.580   3832
ALEISHA        0.001 89.581   3833
ADAM           0.001 89.582   3834
ZADA           0.001 89.583   3835
YUONNE         0.001 89.584   3836
XIAO           0.001 89.585   3837
WILLODEAN      0.001 89.586   3838
WHITLEY        0.001 89.587   3839
VENNIE         0.001 89.588   3840
VANNA          0.001 89.589   3841
TYISHA         0.001 89.591   3842
TOVA           0.001 89.592   3843
TORIE          0.001 89.593   3844
TONISHA        0.001 89.594   3845
TILDA          0.001 89.595   3846
TIEN           0.001 89.596   3847
TEMPLE         0.001 89.597   3848
SIRENA         0.001 89.598   3849
SHERRIL        0.001 89.599   3850
SHANTI         0.001 89.600   3851
SHAN           0.001 89.601   3852
SENAIDA        0.001 89.602   3853
SAMELLA        0.001 89.603   3854
ROBBYN         0.001 89.604   3855
RENDA          0.001 89.606   3856
REITA          0.001 89.607   3857
PHEBE          0.001 89.608   3858
PAULITA        0.001 89.609   3859
NOBUKO         0.001 89.610   3860
NGUYET         0.001 89.611   3861
NEOMI          0.001 89.612   3862
MOON           0.001 89.613   3863
MIKAELA        0.001 89.614   3864
MELANIA        0.001 89.615   3865
MAXIMINA       0.001 89.616   3866
MARG           0.001 89.617   3867
MAISIE         0.001 89.618   3868
LYNNA          0.001 89.619   3869
LILLI          0.001 89.620   3870
LAYNE          0.001 89.622   3871
LASHAUN        0.001 89.623   3872
LAKENYA        0.001 89.624   3873
LAEL           0.001 89.625   3874
KIRSTIE        0.001 89.626   3875
KATHLINE       0.001 89.627   3876
KASHA          0.001 89.628   3877
KARLYN         0.001 89.629   3878
KARIMA         0.001 89.630   3879
JOVAN          0.001 89.631   3880
JOSEFINE       0.001 89.632   3881
JENNELL        0.001 89.633   3882
JACQUI         0.001 89.634   3883
JACKELYN       0.001 89.635   3884
HYO            0.001 89.636   3885
HIEN           0.001 89.638   3886
GRAZYNA        0.001 89.639   3887
FLORRIE        0.001 89.640   3888
FLORIA         0.001 89.641   3889
ELEONORA       0.001 89.642   3890
DWANA          0.001 89.643   3891
DORLA          0.001 89.644   3892
DONG           0.001 89.645   3893
DELMY          0.001 89.646   3894
DEJA           0.001 89.647   3895
DEDE           0.001 89.648   3896
DANN           0.001 89.649   3897
CRYSTA         0.001 89.650   3898
CLELIA         0.001 89.651   3899
CLARIS         0.001 89.652   3900
CLARENCE       0.001 89.654   3901
CHIEKO         0.001 89.655   3902
CHERLYN        0.001 89.656   3903
CHERELLE       0.001 89.657   3904
CHARMAIN       0.001 89.658   3905
CHARA          0.001 89.659   3906
CAMMY          0.001 89.660   3907
BEE            0.001 89.661   3908
ARNETTE        0.001 89.662   3909
ARDELLE        0.001 89.663   3910
ANNIKA         0.001 89.664   3911
AMIEE          0.001 89.665   3912
AMEE           0.001 89.666   3913
ALLENA         0.001 89.667   3914
YVONE          0.001 89.668   3915
YUKI           0.001 89.670   3916
YOSHIE         0.001 89.671   3917
YEVETTE        0.001 89.672   3918
YAEL           0.001 89.673   3919
WILLETTA       0.001 89.674   3920
VONCILE        0.001 89.675   3921
VENETTA        0.001 89.676   3922
TULA           0.001 89.677   3923
TONETTE        0.001 89.678   3924
TIMIKA         0.001 89.679   3925
TEMIKA         0.001 89.680   3926
TELMA          0.001 89.681   3927
TEISHA         0.001 89.682   3928
TAREN          0.001 89.683   3929
TA             0.001 89.684   3930
STACEE         0.001 89.685   3931
SHIN           0.001 89.686   3932
SHAWNTA        0.001 89.687   3933
SATURNINA      0.001 89.688   3934
RICARDA        0.001 89.689   3935
POK            0.001 89.690   3936
PASTY          0.001 89.691   3937
ONIE           0.001 89.692   3938
NUBIA          0.001 89.693   3939
MORA           0.001 89.694   3940
MIKE           0.001 89.695   3941
MARIELLE       0.001 89.696   3942
MARIELLA       0.001 89.697   3943
MARIANELA      0.001 89.699   3944
MARDELL        0.001 89.700   3945
MANY           0.001 89.701   3946
LUANNA         0.001 89.702   3947
LOISE          0.001 89.703   3948
LISABETH       0.001 89.704   3949
LINDSY         0.001 89.705   3950
LILLIANA       0.001 89.706   3951
LILLIAM        0.001 89.707   3952
LELAH          0.001 89.708   3953
LEIGHA         0.001 89.709   3954
LEANORA        0.001 89.710   3955
LANG           0.001 89.711   3956
KRISTEEN       0.001 89.712   3957
KHALILAH       0.001 89.713   3958
KEELEY         0.001 89.714   3959
KANDRA         0.001 89.715   3960
JUNKO          0.001 89.716   3961
JOAQUINA       0.001 89.717   3962
JERLENE        0.001 89.718   3963
JANI           0.001 89.719   3964
JAMIKA         0.001 89.720   3965
JAME           0.001 89.721   3966
HSIU           0.001 89.722   3967
HERMILA        0.001 89.723   3968
GOLDEN         0.001 89.724   3969
GENEVIVE       0.001 89.725   3970
EVIA           0.001 89.727   3971
EUGENA         0.001 89.728   3972
EMMALINE       0.001 89.729   3973
ELFREDA        0.001 89.730   3974
ELENE          0.001 89.731   3975
DONETTE        0.001 89.732   3976
DELCIE         0.001 89.733   3977
DEEANNA        0.001 89.734   3978
DARCEY         0.001 89.735   3979
CUC            0.001 89.736   3980
CLARINDA       0.001 89.737   3981
CIRA           0.001 89.738   3982
CHAE           0.001 89.739   3983
CELINDA        0.001 89.740   3984
CATHERYN       0.001 89.741   3985
CATHERIN       0.001 89.742   3986
CASIMIRA       0.001 89.743   3987
CARMELIA       0.001 89.744   3988
CAMELLIA       0.001 89.745   3989
BREANA         0.001 89.746   3990
BOBETTE        0.001 89.747   3991
BERNARDINA     0.001 89.748   3992
BEBE           0.001 89.749   3993
BASILIA        0.001 89.750   3994
ARLYNE         0.001 89.751   3995
AMAL           0.001 89.752   3996
ALAYNA         0.001 89.753   3997
ZONIA          0.001 89.754   3998
ZENIA          0.001 89.755   3999
YURIKO         0.001 89.756   4000
YAEKO          0.001 89.757   4001
WYNELL         0.001 89.758   4002
WILLOW         0.001 89.759   4003
WILLENA        0.001 89.760   4004
VERNIA         0.001 89.761   4005
TU             0.001 89.762   4006
TRAVIS         0.001 89.764   4007
TORA           0.001 89.765   4008
TERRILYN       0.001 89.766   4009
TERICA         0.001 89.767   4010
TENESHA        0.001 89.768   4011
TAWNA          0.001 89.769   4012
TAJUANA        0.001 89.770   4013
TAINA          0.001 89.771   4014
STEPHNIE       0.001 89.772   4015
SONA           0.001 89.773   4016
SOL            0.001 89.774   4017
SINA           0.001 89.775   4018
SHONDRA        0.001 89.776   4019
SHIZUKO        0.001 89.777   4020
SHERLENE       0.001 89.778   4021
SHERICE        0.001 89.779   4022
SHARIKA        0.001 89.780   4023
ROSSIE         0.001 89.781   4024
ROSENA         0.001 89.782   4025
RORY           0.001 89.783   4026
RIMA           0.001 89.784   4027
RIA            0.001 89.785   4028
RHEBA          0.001 89.786   4029
RENNA          0.001 89.787   4030
PETER          0.001 89.788   4031
NATALYA        0.001 89.789   4032
NANCEE         0.001 89.790   4033
MELODI         0.001 89.791   4034
MEDA           0.001 89.792   4035
MAXIMA         0.001 89.793   4036
MATHA          0.001 89.794   4037
MARKETTA       0.001 89.795   4038
MARICRUZ       0.001 89.796   4039
MARCELENE      0.001 89.797   4040
MALVINA        0.001 89.798   4041
LUBA           0.001 89.799   4042
LOUETTA        0.001 89.800   4043
LEIDA          0.001 89.801   4044
LECIA          0.001 89.802   4045
LAURAN         0.001 89.803   4046
LASHAWNA       0.001 89.804   4047
LAINE          0.001 89.805   4048
KHADIJAH       0.001 89.806   4049
KATERINE       0.001 89.807   4050
KASI           0.001 89.808   4051
KALLIE         0.001 89.809   4052
JULIETTA       0.001 89.810   4053
JESUSITA       0.001 89.811   4054
JESTINE        0.001 89.812   4055
JESSIA         0.001 89.813   4056
JEREMY         0.001 89.814   4057
JEFFIE         0.001 89.815   4058
JANYCE         0.001 89.816   4059
ISADORA        0.001 89.817   4060
GEORGIANNE     0.001 89.818   4061
FIDELIA        0.001 89.819   4062
EVITA          0.001 89.820   4063
EURA           0.001 89.821   4064
EULAH          0.001 89.822   4065
ESTEFANA       0.001 89.823   4066
ELSY           0.001 89.824   4067
ELIZABET       0.001 89.825   4068
ELADIA         0.001 89.826   4069
DODIE          0.001 89.827   4070
DION           0.001 89.828   4071
DIA            0.001 89.829   4072
DENISSE        0.001 89.830   4073
DELORAS        0.001 89.831   4074
DELILA         0.001 89.832   4075
DAYSI          0.001 89.833   4076
DAKOTA         0.001 89.834   4077
CURTIS         0.001 89.835   4078
CRYSTLE        0.001 89.836   4079
CONCHA         0.001 89.837   4080
COLBY          0.001 89.838   4081
CLARETTA       0.001 89.839   4082
CHU            0.001 89.840   4083
CHRISTIA       0.001 89.841   4084
CHARLSIE       0.001 89.842   4085
CHARLENA       0.001 89.843   4086
CARYLON        0.001 89.844   4087
BETTYANN       0.001 89.845   4088
ASLEY          0.001 89.846   4089
ASHLEA         0.001 89.847   4090
AMIRA          0.001 89.848   4091
AI             0.001 89.849   4092
AGUEDA         0.001 89.850   4093
AGNUS          0.001 89.851   4094
YUETTE         0.001 89.852   4095
VINITA         0.001 89.853   4096
VICTORINA      0.001 89.854   4097
TYNISHA        0.001 89.855   4098
TREENA         0.001 89.856   4099
TOCCARA        0.001 89.857   4100
TISH           0.001 89.858   4101
THOMASENA      0.001 89.859   4102
TEGAN          0.001 89.860   4103
SOILA          0.001 89.861   4104
SHILOH         0.001 89.862   4105
SHENNA         0.001 89.863   4106
SHARMAINE      0.001 89.864   4107
SHANTAE        0.001 89.865   4108
SHANDI         0.001 89.866   4109
SEPTEMBER      0.001 89.867   4110
SARAN          0.001 89.867   4111
SARAI          0.001 89.868   4112
SANA           0.001 89.869   4113
SAMUEL         0.001 89.870   4114
SALLEY         0.001 89.871   4115
ROSETTE        0.001 89.872   4116
ROLANDE        0.001 89.873   4117
REGINE         0.001 89.874   4118
OTELIA         0.001 89.875   4119
OSCAR          0.001 89.876   4120
OLEVIA         0.001 89.877   4121
NICHOLLE       0.001 89.878   4122
NECOLE         0.001 89.879   4123
NAIDA          0.001 89.880   4124
MYRTA          0.001 89.881   4125
MYESHA         0.001 89.882   4126
MITSUE         0.001 89.883   4127
MINTA          0.001 89.884   4128
MERTIE         0.001 89.885   4129
MARGY          0.001 89.886   4130
MAHALIA        0.001 89.887   4131
MADALENE       0.001 89.888   4132
LOVE           0.001 89.889   4133
LOURA          0.001 89.890   4134
LOREAN         0.001 89.891   4135
LEWIS          0.001 89.892   4136
LESHA          0.001 89.893   4137
LEONIDA        0.001 89.894   4138
LENITA         0.001 89.895   4139
LAVONE         0.001 89.896   4140
LASHELL        0.001 89.897   4141
LASHANDRA      0.001 89.898   4142
LAMONICA       0.001 89.899   4143
KIMBRA         0.001 89.900   4144
KATHERINA      0.001 89.901   4145
KARRY          0.001 89.902   4146
KANESHA        0.001 89.903   4147
JULIO          0.001 89.903   4148
JONG           0.001 89.904   4149
JENEVA         0.001 89.905   4150
JAQUELYN       0.001 89.906   4151
HWA            0.001 89.907   4152
GILMA          0.001 89.908   4153
GHISLAINE      0.001 89.909   4154
GERTRUDIS      0.001 89.910   4155
FRANSISCA      0.001 89.911   4156
FERMINA        0.001 89.912   4157
ETTIE          0.001 89.913   4158
ETSUKO         0.001 89.914   4159
ELLIS          0.001 89.915   4160
ELLAN          0.001 89.916   4161
ELIDIA         0.001 89.917   4162
EDRA           0.001 89.918   4163
DORETHEA       0.001 89.919   4164
DOREATHA       0.001 89.920   4165
DENYSE         0.001 89.921   4166
DENNY          0.001 89.922   4167
DEETTA         0.001 89.923   4168
DAINE          0.001 89.924   4169
CYRSTAL        0.001 89.925   4170
CORRIN         0.001 89.926   4171
CAYLA          0.001 89.927   4172
CARLITA        0.001 89.928   4173
CAMILA         0.001 89.929   4174
BURMA          0.001 89.930   4175
BULA           0.001 89.931   4176
BUENA          0.001 89.932   4177
BLAKE          0.001 89.933   4178
BARABARA       0.001 89.934   4179
AVRIL          0.001 89.935   4180
AUSTIN         0.001 89.936   4181
ALAINE         0.001 89.937   4182
ZANA           0.001 89.938   4183
WILHEMINA      0.001 89.938   4184
WANETTA        0.001 89.939   4185
VIRGIL         0.001 89.940   4186
VI             0.001 89.941   4187
VERONIKA       0.001 89.942   4188
VERNON         0.001 89.943   4189
VERLINE        0.001 89.944   4190
VASILIKI       0.001 89.945   4191
TONITA         0.001 89.946   4192
TISA           0.001 89.947   4193
TEOFILA        0.001 89.948   4194
TAYNA          0.001 89.949   4195
TAUNYA         0.001 89.950   4196
TANDRA         0.001 89.951   4197
TAKAKO         0.001 89.952   4198
SUNNI          0.001 89.953   4199
SUANNE         0.001 89.954   4200
SIXTA          0.001 89.954   4201
SHARELL        0.001 89.955   4202
SEEMA          0.001 89.956   4203
RUSSELL        0.001 89.957   4204
ROSENDA        0.001 89.958   4205
ROBENA         0.001 89.959   4206
RAYMONDE       0.001 89.960   4207
PEI            0.001 89.961   4208
PAMILA         0.001 89.962   4209
OZELL          0.001 89.963   4210
NEIDA          0.001 89.964   4211
NEELY          0.001 89.965   4212
MISTIE         0.001 89.966   4213
MICHA          0.001 89.967   4214
MERISSA        0.001 89.968   4215
MAURITA        0.001 89.969   4216
MARYLN         0.001 89.970   4217
MARYETTA       0.001 89.971   4218
MARSHALL       0.001 89.971   4219
MARCELL        0.001 89.972   4220
MALENA         0.001 89.973   4221
MAKEDA         0.001 89.974   4222
MADDIE         0.001 89.975   4223
LOVETTA        0.001 89.976   4224
LOURIE         0.001 89.977   4225
LORRINE        0.001 89.978   4226
LORILEE        0.001 89.979   4227
LESTER         0.001 89.980   4228
LAURENA        0.001 89.981   4229
LASHAY         0.001 89.982   4230
LARRAINE       0.001 89.983   4231
LAREE          0.001 89.984   4232
LACRESHA       0.001 89.985   4233
KRISTLE        0.001 89.986   4234
KRISHNA        0.001 89.987   4235
KEVA           0.001 89.987   4236
KEIRA          0.001 89.988   4237
KAROLE         0.001 89.989   4238
JOIE           0.001 89.990   4239
JINNY          0.001 89.991   4240
JEANNETTA      0.001 89.992   4241
JAMA           0.001 89.993   4242
HEIDY          0.001 89.994   4243
GILBERTE       0.001 89.995   4244
GEMA           0.001 89.996   4245
FAVIOLA        0.001 89.997   4246
EVELYNN        0.001 89.998   4247
ENDA           0.001 89.999   4248
ELLI           0.001 90.000   4249
ELLENA         0.001 90.001   4250
DIVINA         0.001 90.002   4251
DAGNY          0.001 90.003   4252
COLLENE        0.001 90.003   4253
CODI           0.001 90.004   4254
CINDIE         0.001 90.005   4255
CHASSIDY       0.001 90.006   4256
CHASIDY        0.001 90.007   4257
CATRICE        0.001 90.008   4258
CATHERINA      0.001 90.009   4259
CASSEY         0.001 90.010   4260
CAROLL         0.001 90.011   4261
CARLENA        0.001 90.012   4262
CANDRA         0.001 90.013   4263
CALISTA        0.001 90.014   4264
BRYANNA        0.001 90.015   4265
BRITTENY       0.001 90.016   4266
BEULA          0.001 90.017   4267
BARI           0.001 90.018   4268
AUDRIE         0.001 90.019   4269
AUDRIA         0.001 90.019   4270
ARDELIA        0.001 90.020   4271
ANNELLE        0.001 90.021   4272
ANGILA         0.001 90.022   4273
ALONA          0.001 90.023   4274
ALLYN          0.001 90.024   4275
ENDNAMES

$COMMON_SURNAMES = <<ENDNAMES;
SMITH          1.006  1.006      1 
JOHNSON        0.810  1.816      2
WILLIAMS       0.699  2.515      3
JONES          0.621  3.136      4
BROWN          0.621  3.757      5
DAVIS          0.480  4.237      6
MILLER         0.424  4.660      7
WILSON         0.339  5.000      8
MOORE          0.312  5.312      9
TAYLOR         0.311  5.623     10
ANDERSON       0.311  5.934     11
THOMAS         0.311  6.245     12
JACKSON        0.310  6.554     13
WHITE          0.279  6.834     14
HARRIS         0.275  7.109     15
MARTIN         0.273  7.382     16
THOMPSON       0.269  7.651     17
GARCIA         0.254  7.905     18
MARTINEZ       0.234  8.140     19
ROBINSON       0.233  8.372     20
CLARK          0.231  8.603     21
RODRIGUEZ      0.229  8.832     22
LEWIS          0.226  9.058     23
LEE            0.220  9.278     24
WALKER         0.219  9.497     25
HALL           0.200  9.698     26
ALLEN          0.199  9.897     27
YOUNG          0.193 10.090     28
HERNANDEZ      0.192 10.282     29
KING           0.190 10.472     30
WRIGHT         0.189 10.662     31
LOPEZ          0.187 10.849     32
HILL           0.187 11.035     33
SCOTT          0.185 11.220     34
GREEN          0.183 11.403     35
ADAMS          0.174 11.577     36
BAKER          0.171 11.748     37
GONZALEZ       0.166 11.915     38
NELSON         0.162 12.077     39
CARTER         0.162 12.239     40
MITCHELL       0.160 12.399     41
PEREZ          0.155 12.554     42
ROBERTS        0.153 12.707     43
TURNER         0.152 12.859     44
PHILLIPS       0.149 13.008     45
CAMPBELL       0.149 13.157     46
PARKER         0.146 13.302     47
EVANS          0.141 13.443     48
EDWARDS        0.137 13.580     49
COLLINS        0.134 13.714     50
STEWART        0.133 13.847     51
SANCHEZ        0.130 13.977     52
MORRIS         0.125 14.102     53
ROGERS         0.123 14.225     54
REED           0.122 14.347     55
COOK           0.120 14.467     56
MORGAN         0.118 14.585     57
BELL           0.117 14.702     58
MURPHY         0.117 14.819     59
BAILEY         0.115 14.934     60
RIVERA         0.113 15.047     61
COOPER         0.113 15.160     62
RICHARDSON     0.112 15.272     63
COX            0.110 15.382     64
HOWARD         0.110 15.492     65
WARD           0.108 15.600     66
TORRES         0.108 15.708     67
PETERSON       0.107 15.815     68
GRAY           0.106 15.921     69
RAMIREZ        0.105 16.026     70
JAMES          0.105 16.131     71
WATSON         0.103 16.233     72
BROOKS         0.103 16.336     73
KELLY          0.102 16.438     74
SANDERS        0.100 16.537     75
PRICE          0.099 16.637     76
BENNETT        0.099 16.736     77
WOOD           0.098 16.834     78
BARNES         0.097 16.931     79
ROSS           0.096 17.027     80
HENDERSON      0.095 17.122     81
COLEMAN        0.095 17.217     82
JENKINS        0.095 17.312     83
PERRY          0.094 17.406     84
POWELL         0.093 17.499     85
LONG           0.092 17.591     86
PATTERSON      0.092 17.684     87
HUGHES         0.092 17.776     88
FLORES         0.092 17.868     89
WASHINGTON     0.092 17.959     90
BUTLER         0.091 18.050     91
SIMMONS        0.091 18.141     92
FOSTER         0.091 18.231     93
GONZALES       0.087 18.318     94
BRYANT         0.087 18.405     95
ALEXANDER      0.085 18.490     96
RUSSELL        0.085 18.574     97
GRIFFIN        0.084 18.659     98
DIAZ           0.084 18.742     99
HAYES          0.083 18.825    100
MYERS          0.083 18.908    101
FORD           0.082 18.990    102
HAMILTON       0.082 19.072    103
GRAHAM         0.082 19.154    104
SULLIVAN       0.081 19.234    105
WALLACE        0.081 19.315    106
WOODS          0.080 19.395    107
COLE           0.080 19.476    108
WEST           0.080 19.555    109
JORDAN         0.078 19.634    110
OWENS          0.078 19.711    111
REYNOLDS       0.078 19.789    112
FISHER         0.077 19.866    113
ELLIS          0.077 19.943    114
HARRISON       0.076 20.019    115
GIBSON         0.075 20.094    116
MCDONALD       0.075 20.169    117
CRUZ           0.075 20.244    118
MARSHALL       0.075 20.319    119
ORTIZ          0.075 20.394    120
GOMEZ          0.075 20.468    121
MURRAY         0.074 20.543    122
FREEMAN        0.074 20.617    123
WELLS          0.073 20.690    124
WEBB           0.072 20.762    125
SIMPSON        0.070 20.832    126
STEVENS        0.070 20.902    127
TUCKER         0.070 20.971    128
PORTER         0.069 21.041    129
HUNTER         0.069 21.110    130
HICKS          0.069 21.178    131
CRAWFORD       0.068 21.246    132
HENRY          0.068 21.314    133
BOYD           0.068 21.381    134
MASON          0.068 21.449    135
MORALES        0.067 21.516    136
KENNEDY        0.067 21.582    137
WARREN         0.067 21.649    138
DIXON          0.066 21.715    139
RAMOS          0.066 21.782    140
REYES          0.066 21.848    141
BURNS          0.065 21.913    142
GORDON         0.065 21.978    143
SHAW           0.065 22.043    144
HOLMES         0.065 22.108    145
RICE           0.064 22.172    146
ROBERTSON      0.064 22.236    147
HUNT           0.063 22.299    148
BLACK          0.063 22.362    149
DANIELS        0.062 22.425    150
PALMER         0.062 22.487    151
MILLS          0.061 22.547    152
NICHOLS        0.060 22.607    153
GRANT          0.060 22.667    154
KNIGHT         0.060 22.727    155
FERGUSON       0.059 22.786    156
ROSE           0.059 22.845    157
STONE          0.059 22.904    158
HAWKINS        0.059 22.963    159
DUNN           0.058 23.022    160
PERKINS        0.058 23.079    161
HUDSON         0.058 23.137    162
SPENCER        0.057 23.194    163
GARDNER        0.057 23.251    164
STEPHENS       0.057 23.308    165
PAYNE          0.057 23.365    166
PIERCE         0.056 23.421    167
BERRY          0.056 23.477    168
MATTHEWS       0.056 23.533    169
ARNOLD         0.056 23.589    170
WAGNER         0.055 23.645    171
WILLIS         0.055 23.700    172
RAY            0.055 23.755    173
WATKINS        0.055 23.811    174
OLSON          0.055 23.866    175
CARROLL        0.055 23.921    176
DUNCAN         0.055 23.976    177
SNYDER         0.055 24.031    178
HART           0.054 24.086    179
CUNNINGHAM     0.054 24.140    180
BRADLEY        0.054 24.194    181
LANE           0.054 24.247    182
ANDREWS        0.054 24.301    183
RUIZ           0.054 24.355    184
HARPER         0.054 24.408    185
FOX            0.053 24.462    186
RILEY          0.053 24.515    187
ARMSTRONG      0.053 24.568    188
CARPENTER      0.053 24.621    189
WEAVER         0.053 24.673    190
GREENE         0.053 24.726    191
LAWRENCE       0.052 24.779    192
ELLIOTT        0.052 24.831    193
CHAVEZ         0.052 24.883    194
SIMS           0.052 24.936    195
AUSTIN         0.052 24.988    196
PETERS         0.052 25.040    197
KELLEY         0.052 25.092    198
FRANKLIN       0.051 25.143    199
LAWSON         0.051 25.195    200
FIELDS         0.051 25.246    201
GUTIERREZ      0.051 25.297    202
RYAN           0.051 25.348    203
SCHMIDT        0.051 25.400    204
CARR           0.051 25.451    205
VASQUEZ        0.051 25.502    206
CASTILLO       0.051 25.552    207
WHEELER        0.051 25.603    208
CHAPMAN        0.050 25.653    209
OLIVER         0.050 25.703    210
MONTGOMERY     0.049 25.753    211
RICHARDS       0.049 25.802    212
WILLIAMSON     0.049 25.851    213
JOHNSTON       0.049 25.900    214
BANKS          0.048 25.948    215
MEYER          0.048 25.996    216
BISHOP         0.048 26.045    217
MCCOY          0.048 26.093    218
HOWELL         0.048 26.140    219
ALVAREZ        0.048 26.188    220
MORRISON       0.048 26.235    221
HANSEN         0.047 26.283    222
FERNANDEZ      0.047 26.330    223
GARZA          0.047 26.377    224
HARVEY         0.047 26.424    225
LITTLE         0.046 26.470    226
BURTON         0.046 26.516    227
STANLEY        0.046 26.562    228
NGUYEN         0.046 26.608    229
GEORGE         0.046 26.653    230
JACOBS         0.046 26.699    231
REID           0.046 26.745    232
KIM            0.045 26.790    233
FULLER         0.045 26.835    234
LYNCH          0.045 26.880    235
DEAN           0.045 26.925    236
GILBERT        0.045 26.970    237
GARRETT        0.045 27.015    238
ROMERO         0.045 27.059    239
WELCH          0.044 27.104    240
LARSON         0.044 27.148    241
FRAZIER        0.044 27.192    242
BURKE          0.044 27.235    243
HANSON         0.043 27.279    244
DAY            0.043 27.322    245
MENDOZA        0.043 27.365    246
MORENO         0.043 27.407    247
BOWMAN         0.043 27.450    248
MEDINA         0.042 27.492    249
FOWLER         0.042 27.535    250
BREWER         0.042 27.577    251
HOFFMAN        0.042 27.619    252
CARLSON        0.042 27.661    253
SILVA          0.042 27.703    254
PEARSON        0.042 27.744    255
HOLLAND        0.042 27.786    256
DOUGLAS        0.041 27.827    257
FLEMING        0.041 27.868    258
JENSEN         0.041 27.909    259
VARGAS         0.041 27.950    260
BYRD           0.041 27.991    261
DAVIDSON       0.041 28.032    262
HOPKINS        0.041 28.072    263
MAY            0.040 28.113    264
TERRY          0.040 28.153    265
HERRERA        0.040 28.193    266
WADE           0.040 28.233    267
SOTO           0.040 28.273    268
WALTERS        0.040 28.313    269
CURTIS         0.040 28.352    270
NEAL           0.039 28.392    271
CALDWELL       0.039 28.431    272
LOWE           0.039 28.471    273
JENNINGS       0.039 28.510    274
BARNETT        0.039 28.549    275
GRAVES         0.039 28.588    276
JIMENEZ        0.039 28.628    277
HORTON         0.039 28.667    278
SHELTON        0.039 28.706    279
BARRETT        0.039 28.745    280
OBRIEN         0.039 28.783    281
CASTRO         0.039 28.822    282
SUTTON         0.038 28.860    283
GREGORY        0.038 28.899    284
MCKINNEY       0.038 28.937    285
LUCAS          0.038 28.975    286
MILES          0.038 29.013    287
CRAIG          0.038 29.051    288
RODRIQUEZ      0.037 29.088    289
CHAMBERS       0.037 29.126    290
HOLT           0.037 29.163    291
LAMBERT        0.037 29.200    292
FLETCHER       0.037 29.237    293
WATTS          0.037 29.274    294
BATES          0.037 29.311    295
HALE           0.037 29.348    296
RHODES         0.037 29.385    297
PENA           0.037 29.421    298
BECK           0.037 29.458    299
NEWMAN         0.036 29.494    300
HAYNES         0.036 29.531    301
MCDANIEL       0.036 29.567    302
MENDEZ         0.036 29.603    303
BUSH           0.036 29.639    304
VAUGHN         0.036 29.675    305
PARKS          0.035 29.711    306
DAWSON         0.035 29.746    307
SANTIAGO       0.035 29.781    308
NORRIS         0.035 29.817    309
HARDY          0.035 29.852    310
LOVE           0.035 29.887    311
STEELE         0.035 29.921    312
CURRY          0.035 29.956    313
POWERS         0.035 29.991    314
SCHULTZ        0.035 30.025    315
BARKER         0.035 30.060    316
GUZMAN         0.034 30.094    317
PAGE           0.034 30.129    318
MUNOZ          0.034 30.163    319
BALL           0.034 30.197    320
KELLER         0.034 30.231    321
CHANDLER       0.034 30.265    322
WEBER          0.034 30.299    323
LEONARD        0.034 30.333    324
WALSH          0.033 30.366    325
LYONS          0.033 30.400    326
RAMSEY         0.033 30.433    327
WOLFE          0.033 30.466    328
SCHNEIDER      0.033 30.499    329
MULLINS        0.033 30.532    330
BENSON         0.033 30.565    331
SHARP          0.033 30.598    332
BOWEN          0.033 30.631    333
DANIEL         0.033 30.663    334
BARBER         0.032 30.696    335
CUMMINGS       0.032 30.728    336
HINES          0.032 30.760    337
BALDWIN        0.032 30.793    338
GRIFFITH       0.032 30.824    339
VALDEZ         0.032 30.856    340
HUBBARD        0.032 30.888    341
SALAZAR        0.032 30.920    342
REEVES         0.032 30.951    343
WARNER         0.031 30.983    344
STEVENSON      0.031 31.014    345
BURGESS        0.031 31.045    346
SANTOS         0.031 31.076    347
TATE           0.031 31.107    348
CROSS          0.031 31.138    349
GARNER         0.031 31.169    350
MANN           0.031 31.200    351
MACK           0.031 31.231    352
MOSS           0.031 31.262    353
THORNTON       0.031 31.292    354
DENNIS         0.031 31.323    355
MCGEE          0.031 31.354    356
FARMER         0.030 31.384    357
DELGADO        0.030 31.415    358
AGUILAR        0.030 31.445    359
VEGA           0.030 31.475    360
GLOVER         0.030 31.505    361
MANNING        0.030 31.535    362
COHEN          0.030 31.566    363
HARMON         0.030 31.596    364
RODGERS        0.030 31.626    365
ROBBINS        0.030 31.656    366
NEWTON         0.030 31.686    367
TODD           0.030 31.716    368
BLAIR          0.030 31.746    369
HIGGINS        0.030 31.776    370
INGRAM         0.030 31.806    371
REESE          0.030 31.836    372
CANNON         0.030 31.865    373
STRICKLAND     0.030 31.895    374
TOWNSEND       0.030 31.925    375
POTTER         0.030 31.955    376
GOODWIN        0.030 31.984    377
WALTON         0.030 32.014    378
ROWE           0.029 32.043    379
HAMPTON        0.029 32.073    380
ORTEGA         0.029 32.102    381
PATTON         0.029 32.131    382
SWANSON        0.029 32.161    383
JOSEPH         0.029 32.190    384
FRANCIS        0.029 32.219    385
GOODMAN        0.029 32.248    386
MALDONADO      0.029 32.277    387
YATES          0.029 32.305    388
BECKER         0.029 32.334    389
ERICKSON       0.029 32.363    390
HODGES         0.029 32.392    391
RIOS           0.029 32.421    392
CONNER         0.029 32.449    393
ADKINS         0.029 32.478    394
WEBSTER        0.028 32.506    395
NORMAN         0.028 32.535    396
MALONE         0.028 32.563    397
HAMMOND        0.028 32.591    398
FLOWERS        0.028 32.620    399
COBB           0.028 32.648    400
MOODY          0.028 32.676    401
QUINN          0.028 32.704    402
BLAKE          0.028 32.732    403
MAXWELL        0.028 32.759    404
POPE           0.028 32.787    405
FLOYD          0.027 32.814    406
OSBORNE        0.027 32.842    407
PAUL           0.027 32.869    408
MCCARTHY       0.027 32.896    409
GUERRERO       0.027 32.924    410
LINDSEY        0.027 32.951    411
ESTRADA        0.027 32.978    412
SANDOVAL       0.027 33.005    413
GIBBS          0.027 33.032    414
TYLER          0.027 33.059    415
GROSS          0.027 33.086    416
FITZGERALD     0.027 33.113    417
STOKES         0.027 33.140    418
DOYLE          0.027 33.167    419
SHERMAN        0.027 33.193    420
SAUNDERS       0.027 33.220    421
WISE           0.027 33.247    422
COLON          0.027 33.274    423
GILL           0.027 33.300    424
ALVARADO       0.027 33.327    425
GREER          0.026 33.353    426
PADILLA        0.026 33.380    427
SIMON          0.026 33.406    428
WATERS         0.026 33.432    429
NUNEZ          0.026 33.459    430
BALLARD        0.026 33.485    431
SCHWARTZ       0.026 33.511    432
MCBRIDE        0.026 33.536    433
HOUSTON        0.026 33.562    434
CHRISTENSEN    0.026 33.588    435
KLEIN          0.026 33.614    436
PRATT          0.026 33.640    437
BRIGGS         0.026 33.666    438
PARSONS        0.026 33.692    439
MCLAUGHLIN     0.026 33.717    440
ZIMMERMAN      0.026 33.743    441
FRENCH         0.026 33.769    442
BUCHANAN       0.026 33.794    443
MORAN          0.026 33.820    444
COPELAND       0.025 33.845    445
ROY            0.025 33.871    446
PITTMAN        0.025 33.896    447
BRADY          0.025 33.922    448
MCCORMICK      0.025 33.947    449
HOLLOWAY       0.025 33.972    450
BROCK          0.025 33.998    451
POOLE          0.025 34.023    452
FRANK          0.025 34.048    453
LOGAN          0.025 34.073    454
OWEN           0.025 34.098    455
BASS           0.025 34.122    456
MARSH          0.025 34.147    457
DRAKE          0.025 34.172    458
WONG           0.025 34.197    459
JEFFERSON      0.025 34.221    460
PARK           0.025 34.246    461
MORTON         0.025 34.271    462
ABBOTT         0.025 34.295    463
SPARKS         0.025 34.320    464
PATRICK        0.024 34.344    465
NORTON         0.024 34.369    466
HUFF           0.024 34.393    467
CLAYTON        0.024 34.417    468
MASSEY         0.024 34.442    469
LLOYD          0.024 34.466    470
FIGUEROA       0.024 34.490    471
CARSON         0.024 34.514    472
BOWERS         0.024 34.538    473
ROBERSON       0.024 34.563    474
BARTON         0.024 34.587    475
TRAN           0.024 34.611    476
LAMB           0.024 34.635    477
HARRINGTON     0.024 34.659    478
CASEY          0.024 34.683    479
BOONE          0.024 34.706    480
CORTEZ         0.024 34.730    481
CLARKE         0.024 34.754    482
MATHIS         0.024 34.778    483
SINGLETON      0.024 34.801    484
WILKINS        0.024 34.825    485
CAIN           0.024 34.849    486
BRYAN          0.024 34.872    487
UNDERWOOD      0.024 34.896    488
HOGAN          0.024 34.920    489
MCKENZIE       0.023 34.943    490
COLLIER        0.023 34.966    491
LUNA           0.023 34.990    492
PHELPS         0.023 35.013    493
MCGUIRE        0.023 35.036    494
ALLISON        0.023 35.059    495
BRIDGES        0.023 35.083    496
WILKERSON      0.023 35.106    497
NASH           0.023 35.129    498
SUMMERS        0.023 35.152    499
ATKINS         0.023 35.175    500
WILCOX         0.023 35.198    501
PITTS          0.023 35.221    502
CONLEY         0.023 35.244    503
MARQUEZ        0.023 35.267    504
BURNETT        0.023 35.290    505
RICHARD        0.023 35.313    506
COCHRAN        0.023 35.335    507
CHASE          0.023 35.358    508
DAVENPORT      0.023 35.381    509
HOOD           0.023 35.404    510
GATES          0.023 35.427    511
CLAY           0.023 35.449    512
AYALA          0.023 35.472    513
SAWYER         0.023 35.495    514
ROMAN          0.023 35.517    515
VAZQUEZ        0.023 35.540    516
DICKERSON      0.023 35.562    517
HODGE          0.022 35.585    518
ACOSTA         0.022 35.607    519
FLYNN          0.022 35.630    520
ESPINOZA       0.022 35.652    521
NICHOLSON      0.022 35.675    522
MONROE         0.022 35.697    523
WOLF           0.022 35.719    524
MORROW         0.022 35.741    525
KIRK           0.022 35.763    526
RANDALL        0.022 35.785    527
ANTHONY        0.022 35.807    528
WHITAKER       0.022 35.829    529
OCONNOR        0.022 35.851    530
SKINNER        0.022 35.873    531
WARE           0.022 35.895    532
MOLINA         0.022 35.916    533
KIRBY          0.022 35.938    534
HUFFMAN        0.022 35.960    535
BRADFORD       0.022 35.982    536
CHARLES        0.022 36.003    537
GILMORE        0.022 36.025    538
DOMINGUEZ      0.022 36.046    539
ONEAL          0.022 36.068    540
BRUCE          0.022 36.090    541
LANG           0.021 36.111    542
COMBS          0.021 36.132    543
KRAMER         0.021 36.154    544
HEATH          0.021 36.175    545
HANCOCK        0.021 36.196    546
GALLAGHER      0.021 36.218    547
GAINES         0.021 36.239    548
SHAFFER        0.021 36.260    549
SHORT          0.021 36.281    550
WIGGINS        0.021 36.302    551
MATHEWS        0.021 36.323    552
MCCLAIN        0.021 36.344    553
FISCHER        0.021 36.365    554
WALL           0.021 36.386    555
SMALL          0.021 36.407    556
MELTON         0.021 36.428    557
HENSLEY        0.021 36.449    558
BOND           0.021 36.470    559
DYER           0.021 36.491    560
CAMERON        0.021 36.511    561
GRIMES         0.021 36.532    562
CONTRERAS      0.021 36.553    563
CHRISTIAN      0.021 36.573    564
WYATT          0.021 36.594    565
BAXTER         0.021 36.615    566
SNOW           0.021 36.635    567
MOSLEY         0.021 36.656    568
SHEPHERD       0.021 36.677    569
LARSEN         0.021 36.697    570
HOOVER         0.021 36.718    571
BEASLEY        0.020 36.738    572
GLENN          0.020 36.758    573
PETERSEN       0.020 36.779    574
WHITEHEAD      0.020 36.799    575
MEYERS         0.020 36.819    576
KEITH          0.020 36.840    577
GARRISON       0.020 36.860    578
VINCENT        0.020 36.880    579
SHIELDS        0.020 36.900    580
HORN           0.020 36.920    581
SAVAGE         0.020 36.941    582
OLSEN          0.020 36.961    583
SCHROEDER      0.020 36.981    584
HARTMAN        0.020 37.001    585
WOODARD        0.020 37.021    586
MUELLER        0.020 37.041    587
KEMP           0.020 37.061    588
DELEON         0.020 37.081    589
BOOTH          0.020 37.101    590
PATEL          0.020 37.121    591
CALHOUN        0.020 37.140    592
WILEY          0.020 37.160    593
EATON          0.020 37.180    594
CLINE          0.020 37.200    595
NAVARRO        0.020 37.220    596
HARRELL        0.020 37.240    597
LESTER         0.020 37.259    598
HUMPHREY       0.020 37.279    599
PARRISH        0.020 37.299    600
DURAN          0.020 37.318    601
HUTCHINSON     0.020 37.338    602
HESS           0.020 37.358    603
DORSEY         0.020 37.377    604
BULLOCK        0.020 37.397    605
ROBLES         0.020 37.416    606
BEARD          0.019 37.436    607
DALTON         0.019 37.455    608
AVILA          0.019 37.475    609
VANCE          0.019 37.494    610
RICH           0.019 37.514    611
BLACKWELL      0.019 37.533    612
YORK           0.019 37.552    613
JOHNS          0.019 37.572    614
BLANKENSHIP    0.019 37.591    615
TREVINO        0.019 37.610    616
SALINAS        0.019 37.630    617
CAMPOS         0.019 37.649    618
PRUITT         0.019 37.668    619
MOSES          0.019 37.688    620
CALLAHAN       0.019 37.707    621
GOLDEN         0.019 37.726    622
MONTOYA        0.019 37.745    623
HARDIN         0.019 37.764    624
GUERRA         0.019 37.783    625
MCDOWELL       0.019 37.802    626
CAREY          0.019 37.821    627
STAFFORD       0.019 37.840    628
GALLEGOS       0.019 37.859    629
HENSON         0.019 37.878    630
WILKINSON      0.019 37.897    631
BOOKER         0.019 37.916    632
MERRITT        0.019 37.935    633
MIRANDA        0.019 37.953    634
ATKINSON       0.019 37.972    635
ORR            0.019 37.991    636
DECKER         0.019 38.010    637
HOBBS          0.019 38.028    638
PRESTON        0.019 38.047    639
TANNER         0.019 38.066    640
KNOX           0.019 38.084    641
PACHECO        0.019 38.103    642
STEPHENSON     0.018 38.121    643
GLASS          0.018 38.140    644
ROJAS          0.018 38.158    645
SERRANO        0.018 38.176    646
MARKS          0.018 38.195    647
HICKMAN        0.018 38.213    648
ENGLISH        0.018 38.231    649
SWEENEY        0.018 38.249    650
STRONG         0.018 38.267    651
PRINCE         0.018 38.285    652
MCCLURE        0.018 38.304    653
CONWAY         0.018 38.322    654
WALTER         0.018 38.340    655
ROTH           0.018 38.358    656
MAYNARD        0.018 38.376    657
FARRELL        0.018 38.394    658
LOWERY         0.018 38.411    659
HURST          0.018 38.429    660
NIXON          0.018 38.447    661
WEISS          0.018 38.465    662
TRUJILLO       0.018 38.483    663
ELLISON        0.018 38.500    664
SLOAN          0.018 38.518    665
JUAREZ         0.018 38.536    666
WINTERS        0.018 38.553    667
MCLEAN         0.018 38.571    668
RANDOLPH       0.018 38.588    669
LEON           0.018 38.606    670
BOYER          0.018 38.624    671
VILLARREAL     0.018 38.641    672
MCCALL         0.018 38.659    673
GENTRY         0.018 38.676    674
CARRILLO       0.017 38.694    675
KENT           0.017 38.711    676
AYERS          0.017 38.729    677
LARA           0.017 38.746    678
SHANNON        0.017 38.763    679
SEXTON         0.017 38.781    680
PACE           0.017 38.798    681
HULL           0.017 38.815    682
LEBLANC        0.017 38.833    683
BROWNING       0.017 38.850    684
VELASQUEZ      0.017 38.867    685
LEACH          0.017 38.884    686
CHANG          0.017 38.901    687
HOUSE          0.017 38.918    688
SELLERS        0.017 38.936    689
HERRING        0.017 38.953    690
NOBLE          0.017 38.970    691
FOLEY          0.017 38.987    692
BARTLETT       0.017 39.004    693
MERCADO        0.017 39.021    694
LANDRY         0.017 39.037    695
DURHAM         0.017 39.054    696
WALLS          0.017 39.071    697
BARR           0.017 39.088    698
MCKEE          0.017 39.105    699
BAUER          0.017 39.122    700
RIVERS         0.017 39.139    701
EVERETT        0.017 39.155    702
BRADSHAW       0.017 39.172    703
PUGH           0.017 39.189    704
VELEZ          0.017 39.206    705
RUSH           0.017 39.222    706
ESTES          0.017 39.239    707
DODSON         0.017 39.255    708
MORSE          0.017 39.272    709
SHEPPARD       0.017 39.289    710
WEEKS          0.017 39.305    711
CAMACHO        0.017 39.322    712
BEAN           0.017 39.338    713
BARRON         0.017 39.355    714
LIVINGSTON     0.017 39.371    715
MIDDLETON      0.016 39.388    716
SPEARS         0.016 39.404    717
BRANCH         0.016 39.420    718
BLEVINS        0.016 39.437    719
CHEN           0.016 39.453    720
KERR           0.016 39.469    721
MCCONNELL      0.016 39.486    722
HATFIELD       0.016 39.502    723
HARDING        0.016 39.518    724
ASHLEY         0.016 39.535    725
SOLIS          0.016 39.551    726
HERMAN         0.016 39.567    727
FROST          0.016 39.583    728
GILES          0.016 39.599    729
BLACKBURN      0.016 39.616    730
WILLIAM        0.016 39.632    731
PENNINGTON     0.016 39.648    732
WOODWARD       0.016 39.664    733
FINLEY         0.016 39.680    734
MCINTOSH       0.016 39.696    735
KOCH           0.016 39.713    736
BEST           0.016 39.729    737
SOLOMON        0.016 39.745    738
MCCULLOUGH     0.016 39.761    739
DUDLEY         0.016 39.777    740
NOLAN          0.016 39.793    741
BLANCHARD      0.016 39.809    742
RIVAS          0.016 39.825    743
BRENNAN        0.016 39.841    744
MEJIA          0.016 39.856    745
KANE           0.016 39.872    746
BENTON         0.016 39.888    747
JOYCE          0.016 39.904    748
BUCKLEY        0.016 39.920    749
HALEY          0.016 39.936    750
VALENTINE      0.016 39.952    751
MADDOX         0.016 39.967    752
RUSSO          0.016 39.983    753
MCKNIGHT       0.016 39.999    754
BUCK           0.016 40.015    755
MOON           0.016 40.030    756
MCMILLAN       0.016 40.046    757
CROSBY         0.016 40.062    758
BERG           0.016 40.077    759
DOTSON         0.016 40.093    760
MAYS           0.016 40.109    761
ROACH          0.016 40.124    762
CHURCH         0.016 40.140    763
CHAN           0.016 40.155    764
RICHMOND       0.016 40.171    765
MEADOWS        0.016 40.187    766
FAULKNER       0.016 40.202    767
ONEILL         0.016 40.218    768
KNAPP          0.016 40.233    769
KLINE          0.015 40.248    770
BARRY          0.015 40.264    771
OCHOA          0.015 40.279    772
JACOBSON       0.015 40.295    773
GAY            0.015 40.310    774
AVERY          0.015 40.326    775
HENDRICKS      0.015 40.341    776
HORNE          0.015 40.356    777
SHEPARD        0.015 40.372    778
HEBERT         0.015 40.387    779
CHERRY         0.015 40.402    780
CARDENAS       0.015 40.418    781
MCINTYRE       0.015 40.433    782
WHITNEY        0.015 40.448    783
WALLER         0.015 40.463    784
HOLMAN         0.015 40.478    785
DONALDSON      0.015 40.494    786
CANTU          0.015 40.509    787
TERRELL        0.015 40.524    788
MORIN          0.015 40.539    789
GILLESPIE      0.015 40.555    790
FUENTES        0.015 40.570    791
TILLMAN        0.015 40.585    792
SANFORD        0.015 40.600    793
BENTLEY        0.015 40.615    794
PECK           0.015 40.630    795
KEY            0.015 40.645    796
SALAS          0.015 40.660    797
ROLLINS        0.015 40.676    798
GAMBLE         0.015 40.691    799
DICKSON        0.015 40.706    800
BATTLE         0.015 40.721    801
SANTANA        0.015 40.736    802
CABRERA        0.015 40.751    803
CERVANTES      0.015 40.766    804
HOWE           0.015 40.781    805
HINTON         0.015 40.796    806
HURLEY         0.015 40.811    807
SPENCE         0.015 40.825    808
ZAMORA         0.015 40.840    809
YANG           0.015 40.855    810
MCNEIL         0.015 40.870    811
SUAREZ         0.015 40.885    812
CASE           0.015 40.900    813
PETTY          0.015 40.915    814
GOULD          0.015 40.929    815
MCFARLAND      0.015 40.944    816
SAMPSON        0.015 40.959    817
CARVER         0.015 40.974    818
BRAY           0.015 40.989    819
ROSARIO        0.015 41.003    820
MACDONALD      0.015 41.018    821
STOUT          0.015 41.033    822
HESTER         0.015 41.047    823
MELENDEZ       0.015 41.062    824
DILLON         0.015 41.077    825
FARLEY         0.015 41.091    826
HOPPER         0.015 41.106    827
GALLOWAY       0.015 41.121    828
POTTS          0.015 41.135    829
BERNARD        0.015 41.150    830
JOYNER         0.014 41.164    831
STEIN          0.014 41.179    832
AGUIRRE        0.014 41.193    833
OSBORN         0.014 41.208    834
MERCER         0.014 41.222    835
BENDER         0.014 41.236    836
FRANCO         0.014 41.251    837
ROWLAND        0.014 41.265    838
SYKES          0.014 41.280    839
BENJAMIN       0.014 41.294    840
TRAVIS         0.014 41.308    841
PICKETT        0.014 41.323    842
CRANE          0.014 41.337    843
SEARS          0.014 41.351    844
MAYO           0.014 41.365    845
DUNLAP         0.014 41.379    846
HAYDEN         0.014 41.394    847
WILDER         0.014 41.408    848
MCKAY          0.014 41.422    849
COFFEY         0.014 41.436    850
MCCARTY        0.014 41.450    851
EWING          0.014 41.464    852
COOLEY         0.014 41.478    853
VAUGHAN        0.014 41.492    854
BONNER         0.014 41.506    855
COTTON         0.014 41.520    856
HOLDER         0.014 41.534    857
STARK          0.014 41.548    858
FERRELL        0.014 41.562    859
CANTRELL       0.014 41.575    860
FULTON         0.014 41.589    861
LYNN           0.014 41.603    862
LOTT           0.014 41.617    863
CALDERON       0.014 41.631    864
ROSA           0.014 41.644    865
POLLARD        0.014 41.658    866
HOOPER         0.014 41.672    867
BURCH          0.014 41.686    868
MULLEN         0.014 41.700    869
FRY            0.014 41.713    870
RIDDLE         0.014 41.727    871
LEVY           0.014 41.741    872
DAVID          0.014 41.754    873
DUKE           0.014 41.768    874
ODONNELL       0.014 41.782    875
GUY            0.014 41.795    876
MICHAEL        0.014 41.809    877
BRITT          0.014 41.823    878
FREDERICK      0.014 41.836    879
DAUGHERTY      0.014 41.850    880
BERGER         0.014 41.864    881
DILLARD        0.014 41.877    882
ALSTON         0.014 41.891    883
JARVIS         0.014 41.904    884
FRYE           0.014 41.918    885
RIGGS          0.014 41.932    886
CHANEY         0.014 41.945    887
ODOM           0.013 41.959    888
DUFFY          0.013 41.972    889
FITZPATRICK    0.013 41.986    890
VALENZUELA     0.013 41.999    891
MERRILL        0.013 42.012    892
MAYER          0.013 42.026    893
ALFORD         0.013 42.039    894
MCPHERSON      0.013 42.053    895
ACEVEDO        0.013 42.066    896
DONOVAN        0.013 42.079    897
BARRERA        0.013 42.093    898
ALBERT         0.013 42.106    899
COTE           0.013 42.119    900
REILLY         0.013 42.133    901
COMPTON        0.013 42.146    902
RAYMOND        0.013 42.159    903
MOONEY         0.013 42.173    904
MCGOWAN        0.013 42.186    905
CRAFT          0.013 42.199    906
CLEVELAND      0.013 42.212    907
CLEMONS        0.013 42.226    908
WYNN           0.013 42.239    909
NIELSEN        0.013 42.252    910
BAIRD          0.013 42.265    911
STANTON        0.013 42.278    912
SNIDER         0.013 42.292    913
ROSALES        0.013 42.305    914
BRIGHT         0.013 42.318    915
WITT           0.013 42.331    916
STUART         0.013 42.344    917
HAYS           0.013 42.357    918
HOLDEN         0.013 42.371    919
RUTLEDGE       0.013 42.384    920
KINNEY         0.013 42.397    921
CLEMENTS       0.013 42.410    922
CASTANEDA      0.013 42.423    923
SLATER         0.013 42.436    924
HAHN           0.013 42.449    925
EMERSON        0.013 42.462    926
CONRAD         0.013 42.475    927
BURKS          0.013 42.488    928
DELANEY        0.013 42.501    929
PATE           0.013 42.514    930
LANCASTER      0.013 42.527    931
SWEET          0.013 42.540    932
JUSTICE        0.013 42.552    933
TYSON          0.013 42.565    934
SHARPE         0.013 42.578    935
WHITFIELD      0.013 42.591    936
TALLEY         0.013 42.604    937
MACIAS         0.013 42.617    938
IRWIN          0.013 42.629    939
BURRIS         0.013 42.642    940
RATLIFF        0.013 42.655    941
MCCRAY         0.013 42.668    942
MADDEN         0.013 42.681    943
KAUFMAN        0.013 42.693    944
BEACH          0.013 42.706    945
GOFF           0.013 42.719    946
CASH           0.013 42.732    947
BOLTON         0.013 42.744    948
MCFADDEN       0.013 42.757    949
LEVINE         0.013 42.770    950
GOOD           0.013 42.782    951
BYERS          0.013 42.795    952
KIRKLAND       0.013 42.808    953
KIDD           0.013 42.821    954
WORKMAN        0.013 42.833    955
CARNEY         0.013 42.846    956
DALE           0.013 42.859    957
MCLEOD         0.013 42.871    958
HOLCOMB        0.013 42.884    959
ENGLAND        0.013 42.896    960
FINCH          0.013 42.909    961
HEAD           0.012 42.921    962
BURT           0.012 42.934    963
HENDRIX        0.012 42.946    964
SOSA           0.012 42.959    965
HANEY          0.012 42.971    966
FRANKS         0.012 42.984    967
SARGENT        0.012 42.996    968
NIEVES         0.012 43.009    969
DOWNS          0.012 43.021    970
RASMUSSEN      0.012 43.033    971
BIRD           0.012 43.046    972
HEWITT         0.012 43.058    973
LINDSAY        0.012 43.071    974
LE             0.012 43.083    975
FOREMAN        0.012 43.095    976
VALENCIA       0.012 43.108    977
ONEIL          0.012 43.120    978
DELACRUZ       0.012 43.132    979
VINSON         0.012 43.145    980
DEJESUS        0.012 43.157    981
HYDE           0.012 43.169    982
FORBES         0.012 43.182    983
GILLIAM        0.012 43.194    984
GUTHRIE        0.012 43.206    985
WOOTEN         0.012 43.218    986
HUBER          0.012 43.231    987
BARLOW         0.012 43.243    988
BOYLE          0.012 43.255    989
MCMAHON        0.012 43.267    990
BUCKNER        0.012 43.279    991
ROCHA          0.012 43.291    992
PUCKETT        0.012 43.303    993
LANGLEY        0.012 43.315    994
KNOWLES        0.012 43.328    995
COOKE          0.012 43.340    996
VELAZQUEZ      0.012 43.352    997
WHITLEY        0.012 43.364    998
NOEL           0.012 43.376    999
VANG           0.012 43.388   1000
ENDNAMES

1;
__END__

=head1 NAME

Text::Names - Perl extension for proper name parsing, normalization, recognition, and classification

=head1 SYNOPSIS

    use Text::Names qw/parseNames samePerson/;

    my @authors = parseNames("D Bourget, Zbigniew Z Lukasiak and John Doe");

    # @authors = ('Bourget, D.','Lukasiak, Zbigniew Z.','Doe, John')

    print "same!" if samePerson("Dave Bourget","David F. Bourget");

    # same!

    print guessGender("David");

    # "M"


=head1 DESCRIPTION

This modules provides a number of name normalization routines, plus high-level parsing and name comparison utilities such as those illustrated in the synopsis.

While it tries to accommodate non-Western names, this module definitely works better with Western names, especially English-style names.

No subroutine is exported by default.

This modules normalizes names to this format:

Lastname(s) [Jr], Given name(s)

Some examples:

1) Bourget, David Joseph Richard

2) Bourget Jr, David

3) Bourget, D. J. R.

These are all normalized names. This format is what is referred to as the normalized representation of a name here. 

=head1 SUBROUTINES

=head2 abbreviationOf(string name1,string name2): boolean

Returns true iff name1 is a common abbreviation of name2 in English. For example, 'Dave' is a common abbreviation of 'David'. The list of abbreviations used includes a number of old abbreviations such as 'Davy' for 'David'.

=head2 cleanName(string name): string

Like parseName, but a) returns the normalized form of the name instead of an array, and b) does additional cleaning-up. To be prefered to parseName in most cases and by default if processing variable or dubious data.

=head2 composeName(string given, string last): string

Returns the name in the "last, given" format.

=head2 isCommonFirstname(string name, [float threshold]): boolean

Returns true if the name is among the 1000 most popular firstnames (male or female) according to the 1990 US Census. If a threshold percentage is passed, the name must have at least this frequency for the subroutine to return true. See http://www.census.gov/genealogy/www/data/1990surnames/names_files.html.

=head2 isCommonSurname(string name, [float threshold]): boolean

Returns true if the name is among the 1000 most popular surnames according to the 1990 US Census. If a threshold percentage is passed, the name must have at least this frequency for the subroutine to return true. See http://www.census.gov/genealogy/www/data/1990surnames/names_files.html.

=head2 firstnamePrevalence(string name): float [0-100]

Returns a float between 0 and 100 indicating how common the firstname is according to the 1990 US Census. Names that are not in the top 1000 return 0.

=head2 surnamePrevalence(string name): float [0-100]

Returns a float between 0 and 100 indicating how common the surname is according to the 1990 US Census. Names that are not in the top 1000 return 0.

=head2 normalizeNameWhitespace(string name): string

Normalizes the whitespace within a name. This is mainly for internal usage.

=head2 parseName(string name): array

Takes a name in one of the multiple formats that one can write a name in, and returns it as an array representing the post-comma and pre-comma parts of its normalized form (in that order). For example, parseName("David Bourget") returns ('David','Bourget').

=head2 parseName2(string name): array

Use on already-normalized names to split them into four parts: full given names, initials, last names, and suffix. The only 'suffix' recognied is 'Jr'.

=head2 parseNameList(array names): array

Takes an array of names (as strings) and returns an array of normalized representations of the names in the array.


=head2 parseNames(string names): array

Takes a string of names as parameter and returns an array of normalized representations of the names in the string. This routine understands a wide variety of formattings for names and lists of names typically found as list of authors in bibliographic citations. See the test 03-parseNames.t for multiple examples.

=head2 reverseName(string name): string

Given a normalized name of the form "last, given", returns "given last".

=head2 samePerson(string name1, string name2): string

Returns a true value iff name1 and name2 could reasonably be two writings of the same name. For example, 'D J Bourget' could reasonably be a writing of 'David Joseph Bourget'. So could 'D Bourget'. But 'D F Bourget' is not a reasonable writing of 'David Joseph Bourget'. The value returned is a (potentially new) name string which combines the most complete tokens of the two submitted name strings.

Contrary to what one might expect, this subroutine does not use weakenings() behind the scenes. Another way to check for name compatibility would be to check that two names have a weakening in common (probably too permissive for most purposes) or that one name is a weakening of the other.

=head2 setNameAbbreviations(array): undef

Sets the abbreviation mapping used to determine whether, say, 'David' and 'Dave' are compatible name parts. The mapping is also used by abbreviationOf(). The format of the array should be: 'Dave', 'David', 'Davy', 'David', etc, otherwise representable in Perl as 'Dave' => 'David', 'Davy' => 'David', etc.

=head2 getNameAbbreviations

Returns the abbreviation mapping.

=head2 weakenings(string first_name, string last_name): array

Returns an array of normalized names which are weakenings of the first and last name passed as argument. Substituting a given names by an initial, or removing an initial, for example, are operations which generate weakenings of a name. Such operations are applied with arbitrary depth, until the name has been reduced to a single initial followed by the lastname, and all intermediary steps returned. 

You can use weakenings(parseName("Lastname, Firstname")) to weaken a first and last name as a single string.

=head2 guessGender(string firstname, [float threshold]): string

Returns 'F' if someone with the provided firstname is likely female, 'M' if likely male, and undef otherwise. A frequency threshold (default = 0) can be specified so that a gender is returned only if the name is found with at least this frequency among people with this gender (according to the US census). A threshold of 0.1 (which means 0.1%) ensures very reliable results (precision above 99%) with a recall of about 60%. When the threshold is lower, this function has a tendency to overestimate the number of females.

=head1 EXPORT

None by default.

=head1 KNOWN ISSUES

This module currently overwrites @Text::Capitalize::exceptions globally, which can have unintended side-effects.

=head1 SEE ALSO

The xPapers application framework from which this has been extracted, http://www.xpapers.org

The related L<Biblio::Citation::Compare> module.

=head1 AUTHOR

David Bourget, http://www.dbourget.com, with contributions by Zbigniew Lukasiak

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011-2013 by David Bourget and University of London

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.1 or,
at your option, any later version of Perl 5 you may have available.


=cut


1;
