#!/usr/bin/env perl

until ($_[0]=~/^Server:/)
{
    @_ = `nslookup -timeout=1 -retry=1 google.com`;
}
