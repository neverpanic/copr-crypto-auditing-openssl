#!/bin/bash
# vim: dict=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/openssl/Sanity/simple-rsapss-test
#   Description: Test if RSA-PSS signature scheme is supported
#   Author: Hubert Kario <hkario@redhat.com>
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Copyright (c) 2013 Red Hat, Inc. All rights reserved.
#
#   This copyrighted material is made available to anyone wishing
#   to use, modify, copy, or redistribute it subject to the terms
#   and conditions of the GNU General Public License version 2.
#
#   This program is distributed in the hope that it will be
#   useful, but WITHOUT ANY WARRANTY; without even the implied
#   warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
#   PURPOSE. See the GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public
#   License along with this program; if not, write to the Free
#   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
#   Boston, MA 02110-1301, USA.
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Include Beaker environment
. /usr/share/beakerlib/beakerlib.sh || exit 1

PACKAGE="openssl"

PUB_KEY="rsa_pubkey.pem"
PRIV_KEY="rsa_key.pem"
FILE="text.txt"
SIG="text.sig"

rlJournalStart
    rlPhaseStartSetup
        rlAssertRpm $PACKAGE
        rlRun "TmpDir=\$(mktemp -d)" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"
        rlRun "openssl genrsa -out $PRIV_KEY 2048" 0 "Generate RSA key"
        rlRun "openssl rsa -in $PRIV_KEY -out $PUB_KEY -pubout" 0 "Split the public key from private key"
        rlRun "echo 'sign me!' > $FILE" 0 "Create file for signing"
        rlAssertExists $FILE
        rlAssertExists $PRIV_KEY
        rlAssertExists $PUB_KEY
    rlPhaseEnd

    rlPhaseStartTest "Test RSA-PSS padding mode"
        set -o pipefail
        rlRun "openssl dgst -sha256 -sigopt rsa_padding_mode:pss -sigopt rsa_pss_saltlen:32 -out $SIG -sign $PRIV_KEY $FILE" 0 "Sign the file"
        rlRun "openssl dgst -sha256 -sigopt rsa_padding_mode:pss -sigopt rsa_pss_saltlen:32 -prverify $PRIV_KEY -signature $SIG $FILE | grep 'Verified OK'" 0 "Verify the signature using the private key file"
        rlRun "openssl dgst -sha256 -sigopt rsa_padding_mode:pss -sigopt rsa_pss_saltlen:32 -verify $PUB_KEY -signature $SIG $FILE | grep 'Verified OK'" 0 "Verify the signature using public key file"
        rlRun "openssl dgst -sha256 -sigopt rsa_padding_mode:pss -prverify $PRIV_KEY -signature $SIG $FILE | grep 'Verified OK'" 0 "Verify the signature using the private key file without specifying salt length"
        rlRun "openssl dgst -sha256 -sigopt rsa_padding_mode:pss -verify $PUB_KEY -signature $SIG $FILE | grep 'Verified OK'" 0 "Verify the signature using public key file without specifying salt length"
        set +o pipefail
        rlRun "sed -i 's/sign/Sign/' $FILE" 0 "Modify signed file"
        rlRun "openssl dgst -sha256 -sigopt rsa_padding_mode:pss -verify $PUB_KEY -signature $SIG $FILE | grep 'Verification Failure'" 0 "Verify that the signature is no longer valid"
    rlPhaseEnd

    rlPhaseStartTest "Documentation check"
        [ -e "$(rpm -ql openssl | grep dgst)"] && rlRun "man dgst | col -b | grep -- -sigopt" 0 "Check if -sigopt option is described in man page"
        rlRun "openssl dgst -help 2>&1 | grep -- -sigopt" 0 "Check if -sigopt option is present in help message"
    rlPhaseEnd

    rlPhaseStartCleanup
        rlRun "popd"
        rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
    rlPhaseEnd
rlJournalPrintText
rlJournalEnd
