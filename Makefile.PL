use inc::Module::Install;

name            ('Log-Accounting-SVK');
abstract        ('Accounting SVK repository');
author          ('Kang-min Liu <gugod@gugod.org>');
license         ('perl');
version_from    ('lib/Log/Accounting/SVK.pm');
requires        ('Algorithm::Accounting');
requires        ('SVK');
requires        ('Spiffy');
requires        ('Graph::SocialMap' => 0.10);
requires        ('Graph::Writer::GraphViz' => 0.08);
build_requires  ('Test::More');

install_script  ('bin/svk-accounting.pl');
install_script  ('bin/svk-developer-graph.pl');

&WriteAll;

