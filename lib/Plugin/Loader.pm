package Plugin::Loader;

use 5.006;
use Moo;
use File::Spec::Functions qw/ catfile splitdir /;
use Path::Iterator::Rule;
use Carp qw/ croak /;

sub find_modules
{
    my ($self, $base) = @_;
    my @baseparts     = split(/::/, $base);
    my ($modpath, $module);
    my %modules;

    foreach my $directory (@INC) {
        my $path = catfile($directory, @baseparts);
        next unless -d $path;

        my $rule = Path::Iterator::Rule->new;
        $rule->perl_module;
        foreach my $file ($rule->all($path)) {
            my $modpath = $file;

            $modpath =~ s!^\Q$directory\E|\.pm$!!g;
            my @parts = splitdir($modpath);
            shift @parts;
            $modules{ join('::', @parts) }++;
        }
    }
    return keys(%modules);
}

sub load
{
    my ($self, @modules) = @_;

    require Module::Runtime;
    foreach my $module (@modules) {
        if (!Module::Runtime::require_module($module)) {
            croak "failed to load module '$module'";
        }
    }
}

1;

=encoding utf8

=head1 NAME

Plugin::Loader - finding and loading modules in a given namespace

=head1 SYNOPSIS

 use Plugin::Loader;

 my $loader = Plugin::Loader->new;

 my @plugins = $loader->find_modules('MyApp::Plugin');

 foreach my $plugin (@plugins) {
    $loader->load($plugin);
 }

=head1 DESCRIPTION

This module provides methods for finding modules in a given namespace,
and then loading them. It is intended for use in situations where
you're looking for plugins, and then loading one or more of them.

This module was inspired by L<Mojo::Loader>, which I have used in
a number of projects. But some people were wary of requiring L<Mojolicious>
just to get a module loader, which prompted me to create C<Plugin::Loader>.

=head1 METHODS

=head2 find_modules

Takes a namespace, and returns all installed modules in that namespace,
that were found in C<@INC>. For example:

 @plugins = $loader->find_modules('Template::Plugin');

This will find all modules in the given namespace, regardless of depth.
For example, it will find L<Template::Plugin::File>
and L<Template::Plugin::Filter::Minify::JavaScript>.

=head2 load_module

Takes a module name and tries to load the module.
If loading fails, then we C<croak>.

=head1 SEE ALSO

L<Mojo::Loader>, L<all>, L<lib::require::all>, L<MAD::Loader>,
L<Module::Find>, L<Module::Recursive::Require>, L<Module::Require>.

=head1 REPOSITORY

L<https://github.com/neilbowers/Plugin-Loader>

=head1 AUTHOR

Neil Bowers E<lt>neilb@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Neil Bowers <neilb@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

