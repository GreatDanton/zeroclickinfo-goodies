package DDG::Goodie::BRT;
# ABSTRACT: Track a shipment from BRT (formerly Bartolini)

use strict;
use DDG::Goodie;
with 'DDG::GoodieRole::WhatIs';

zci answer_type => "brt";
zci is_cached   => 1;

triggers start => "brt";

my $matcher = wi_custom(
    groups => ['imperative', 'prefix'],
    options => {
        prefix_command => qr/brt/i,
        primary => qr/(?:(?<c_brt>[0-9]{12})|(?<c_brtcode>[0-9]{19}))/,
    },
);

handle query_lc => sub {
    my $query = shift;
    my $match = $matcher->full_match($query) or return;
    my $brt_num = $match->{c_brt};
    my $brtcode_num = $match->{c_brtcode};

    # BRT Shipment Tracking (using 12 digits basic code)
    if ( $brt_num ) {
        my $result_text    = $brt_num;
        my $operation_text = qq|Shipment tracking available at <a href="http://as777.brt.it/vas/sped_det_show.htm?referer=sped_numspe_par.htm&Nspediz=$brt_num&RicercaNumeroSpedizione=Ricerca">BRT</a>.|;

        return $result_text,
            structured_answer => {
                input     => [],
                operation => $operation_text,
                result    => $result_text,
            };
    }
    # BRT Shipment Tracking (using 19 digits "BRTcode")
    if ( $brtcode_num ) {
        my $result_text    = $brtcode_num;
        my $operation_text = qq|Shipment tracking available at <a href="http://as777.brt.it/vas/sped_det_show.htm?brtCode=$brtcode_num&urltype=a">BRT</a>.|;

        return $result_text,
            structured_answer => {
                input     => [],
                operation => $operation_text,
                result    => $result_text,
            };
    }
    return;
};

1;
