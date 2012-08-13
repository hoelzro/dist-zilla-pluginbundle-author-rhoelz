## no critic (RequireUseStrict)
package Dist::Zilla::PluginBundle::Author::RHOELZ;

## use critic (RequireUseStrict)
use strict;
use warnings;

use Moose;

with 'Dist::Zilla::Role::PluginBundle::Easy';

has omissions => (
    is      => 'ro',
    default => sub { {} },
);

sub mvp_multivalue_args {
    return '-omit';
}

around add_plugins => sub {
    my ( $orig, $self, @specs ) = @_;

    foreach my $spec (@specs) {
        my $name = ref($spec) ? $spec->[0] : $spec;

        if($self->omissions->{$name}) {
            undef $spec;
        }
    }

    @_ = ( $self, grep { defined() } @specs );

    goto &$orig;
};

sub configure {
    my ( $self ) = @_;

    my $omit = $self->payload->{'-omit'};
    if($omit) {
        foreach my $plugin (@$omit) {
            $self->omissions->{$plugin} = 1;
        }
    }

    $self->add_plugins([
        GithubMeta => {
            issues => 1,
        },
    ]);

    $self->add_plugins([
        'Git::Check' => {
            allow_dirty => ['dist.ini', 'README.pod'],
        },
    ]);

    $self->add_plugins([
        NextRelease => {
            format => '%v %{MMMM dd yyyy}d',
        },
    ]);

    $self->add_plugins([
        'Git::Commit' => {
            allow_dirty => [
                'dist.ini',
                'README.pod',
                'Changes',
            ],
        },
    ]);

    $self->add_plugins([
        'Git::Tag' => {
            tag_format  => '%v',
            tag_message => '%v',
            signed      => 1,
        },
    ]);

    $self->add_plugins([
        'Git::NextVersion' => {
            first_version  => '0.01',
            version_regexp => '^(\d+\.\d+)$',
        },
    ]);

    $self->add_plugins([
        ReadmeAnyFromPod => {
            type     => 'pod',
            filename => 'README.pod',
            location => 'root',
        },
    ]);

    $self->add_plugins(
        'GatherDir',
        'PruneCruft',
        'MetaYAML',
        'License',
        'Readme',
        'ModuleBuild',
        'Manifest',
        'PodCoverageTests',
        'PodSyntaxTests',
        'Test::DistManifest',
        'Test::Kwalitee',
        'Test::Compile',
        'Test::Perl::Critic',
        'TestRelease',
    );

    $self->add_plugins([
        PruneFiles => {
            filename => ['dist.ini', 'weaver.ini'],
        },
    ]);

    $self->add_plugins(
        'Git::ExcludeUntracked',
        'CheckChangesHasContent',
        'ConfirmRelease',
        'UploadToCPAN',
        'PkgVersion',
        'PodWeaver',
    );
}

__PACKAGE__->meta->make_immutable;

1;

__END__

# ABSTRACT:  BeLike::RHOELZ when you build your distributions.

=head1 SYNOPSIS

  ; in your dist.ini
  [@Author::RHOELZ]

=head1 DESCRIPTION

This is the plugin bundle that RHOELZ uses to build distributions.  It is
equivalent to the following:

  [GithubMeta]
  issues = 1
  [Git::Check]
  allow_dirty = dist.ini
  allow_dirty = README.pod
  [NextRelease]
  format = %v %{MMMM dd yyyy}d
  [Git::Commit]
  allow_dirty = dist.ini
  allow_dirty = README.pod
  allow_dirty = Changes
  [Git::Tag]
  tag_format  = %v
  tag_message = %v
  signed      = 1
  [Git::NextVersion]
  first_version  = 0.01
  version_regexp = ^(\d+\.\d+)$
  [ReadmeAnyFromPod]
  type     = pod
  filename = README.pod
  location = root
  [GatherDir]
  [PruneCruft]
  [MetaYAML]
  [License]
  [Readme]
  [ModuleBuild]
  [Manifest]
  [PodCoverageTests]
  [PodSyntaxTests]
  [Test::DistManifest]
  [Test::Kwalitee]
  [Test::Compile]
  [Test::Perl::Critic]
  [TestRelease]
  [PruneFiles]
  filename = dist.ini
  filename = weaver.ini
  [Git::ExcludeUntracked]
  [CheckChangesHasContent]
  [ConfirmRelease]
  [UploadToCPAN]
  [PkgVersion]
  [PodWeaver]

=head1 SEE ALSO

L<Dist::Zilla>

=begin comment

=over

=item configure

=back

=end comment

=cut
