#!/usr/bin/perl -w
use strict;

sub convert($){
        my($bytes) = shift;
        #megs for memory < 512MB
        if($bytes/1024 < 512){
                return(sprintf "%.2f MB\n", $bytes/1024);
        #default is GBs
        }else{
                return(sprintf "%.2f GB\n", $bytes/(1024*1024));
        }
}
sub nfs_storage(){
        my(@df_nfs);
        if(`uname -s` eq "SunOS\n"){
                @df_nfs = `df -k -F nfs`;
        }elsif(`uname -s` eq "Linux\n"){
                @df_nfs = `df -k -P -F nfs | grep -vi 'pharos_core'`;
        }
        my($total) = 0;
        foreach(@df_nfs){
                if(m/((\d+\s+){3})(\d+)\%/){
                        my($used) = split(' ', $1);
                        $total += $used;
                }
        }
        print "NFS Storage: ", convert($total);
}
sub block_storage(){
        my(@df_block, @df_local);
        if(`uname -s` eq "SunOS\n"){
                @df_local = `df -kl -F ufs`;
                @df_block = `df -kl -F vxfs`;
        }elsif(`uname -s` eq "Linux\n"){
                @df_block = `df -kl -P -x tmpfs`;
                @df_local = grep {m{/$|/var$|/boot$}} @df_block;
        }
        my($total) = 0;
        my($local) = 0;
        foreach(@df_block){
                if(m/((\d+\s+){3})(\d+)\%/){
                        my($used) = split(' ', $1);
                        $total += $used;
                }
        }
        foreach(@df_local){
                if(m/((\d+\s+){3})(\d+)\%/){
                        my($used) = split(' ', $1);
                        $local += $used;
                }
        }
       print "Local Storage: ", convert($local);
        if(`uname -s` eq "Linux\n"){
                print "SAN(minus ASM) Storage: ", convert($total - $local);
        }else{
                print "SAN(minus ASM) Storage: ", convert($total);
        }
}
nfs_storage;
block_storage;

