package Scripts::insLisp::Eval;

use Scripts::Base;

use Scripts::insLisp::Types;

sub getValue
{
    my ($expr, $scope) = @_;
    if (isArray($expr)) { # to eval
        my @list = @$expr;
        my $cmd = shift @list;
        my $vCmd = getValue($cmd, $scope);
        if (isLambda($vCmd)) {
            my @vList = map { getValue($_, $scope) } @list;
            my %vars = $cmd->pairKV(@vList);
            my $newScope = Scripts::insLisp::Scope->new($vCmd->defScope, \%vars);
            my $res;
            for ($vCmd->exprs) {
                $res = getValue($_, $newScope);
            }
            $res;
        } elsif (isFunc($vCmd)) {
            if ($vCmd->quoted) {
                $vCmd->call($scope, [@list]);
            } else {
                my @vList = map { getValue($_, $scope) } @list;
                $vCmd->call($scope, [@vList]);
            }
        } else {
            die dd($cmd)." is not callable\n";
        }
    } elsif (isSymbol($expr)) {
        $scope->var($expr->name);
    } else {
        $expr;
    }
}

1;
