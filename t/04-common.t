use Test::More;
use Text::Names qw/isCommonSurname isCommonFirstname guessGender/; 

ok(isCommonSurname('Smith'),'No threshold test, positive');
ok(isCommonSurname('Kennedy'),'No threshold test, positive');
ok(!isCommonSurname('Sdakljdslkafdjdfsa'),'No threshold test, negative');
ok(isCommonSurname('Smith',0.01),'Threshold test, positive');
ok(!isCommonSurname('Smith',5),'Threshold test, negative');
ok(isCommonFirstname('Mary'),'Firstname no threshold test, positive');
ok(isCommonFirstname('David'),'Firstname no threshold test, positive');
ok(!isCommonFirstname('Aklajldkfsjfd'),'Firstname no threshold test, negative');
ok(isCommonFirstname('Mary',0.5),'Firstname threshold test, positive');
ok(isCommonFirstname('John',1),'Firstname threshold test, positive');
ok(!isCommonFirstname('Mark',3),'Firstname threshold test, negative');
ok(guessGender('David') == 'M');
ok(guessGender('lkjasdf') == undef);
ok(guessGender('Mary') == 'F');
ok(guessGender('Arthur') == 'M');

done_testing;
