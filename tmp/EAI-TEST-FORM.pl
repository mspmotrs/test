#!/usr/bin/perl -w

use strict;
use warnings;

print "Content-type: text/html\n\n";

print '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "DTD/xhtml1-strict.dtd">';
print '<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">';
print '<head>';
print '<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />';
print '<title>Servizio esposto da EAI - TEST FORM</title>';
print '</head>';
print '<body>';
print '<form action="http://172.16.191.243:9885" method="post">';
print '<p>XML for TTActionReceiver_PMWind TEST: </p> <textarea name="MSXMLtest" rows="46" cols="80">';
print 'Inserisci XML qui...';
print '</textarea>';
print '<p><input type="submit" name="Submit" value="Invia" /></p>';
print '</form>';
print '</body>';
print '</html>';
