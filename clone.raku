#!/usr/bin/env raku

enum Exits (
    'Success' => 0,
    'Error',
    'Exists'
);

sub MAIN($url) {
    my $ssh = ?($url ~~ / ^"git@" /);
    my $http-regex = /
        ["http" s? "://"]?
        $<site>=(<[a..zA..Z0..9\.\-_]>+) '/'
        $<user>=(<[a..zA..Z0..9~\.\-_]>+) '/'
        $<repo>=(<[a..zA..Z0..9~\.\-_]>+?)
        '.git'? '/'? $
    /;
    my $ssh-regex = /
        "git@"
        $<site>=(.+?) ":"
        $<user>=(<[a..zA..Z0..9~\.\-_]>+) '/'
        $<repo>=(<[a..zA..Z0..9~\.\-_]>+?)
        '.git'? '/'? $
    /;
    $url ~~ ($ssh ?? $ssh-regex !! $http-regex);
    if  !$<site> || !$<user> || !$<repo> {
        note "URL structure not supported";
        exit(Error);
    }

    my $user-dir = $*HOME.add("src/$<site>/$<user>");
    my $project-dir = $user-dir.add($<repo>);
    if $project-dir.e {
        note "Project directory already exists";
        exit(Exists);
    }
    mkdir $user-dir;
    chdir $user-dir;

    my $ret = run("git", "clone", $url).exitcode;
    if $ret != 0 {
        note "Git clone failed";
        exit(Error);
    }

    put $project-dir;
    exit(Success);
}
