use inc::Module::Install;

name            ('Log-Accounting-SVK');
abstract        ('Accounting SVK repository');
author          ('Kang-min Liu <gugod@gugod.org>');
license         ('perl');
version_from    ('lib/Log/Accounting/SVK.pm');
requires        ('Algorithm::Accounting');
requires        ('SVK');
build_requires  ('Test::More');

install_script  ('bin/svk-accounting.pl');

&WriteAll;

