{#
 # Copyright (C) 2026 KSA Technologies, LLC
 # All rights reserved.
 #
 # Redistribution and use in source and binary forms, with or without
 # modification, are permitted provided that the following conditions are met:
 #
 # 1. Redistributions of source code must retain the above copyright notice,
 #    this list of conditions and the following disclaimer.
 #
 # 2. Redistributions in binary form must reproduce the above copyright
 #    notice, this list of conditions and the following disclaimer in the
 #    documentation and/or other materials provided with the distribution.
 #
 # THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
 # INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 # AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 # AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
 # OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 # SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 # INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 # CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 # ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 # POSSIBILITY OF SUCH DAMAGE.
 #}

<script>
    $(document).ready(function () {
        mapDataToFormUI({'frm_general': '/api/sbc/settings/get'}).done(function () {
            formatTokenizersUI();
            $('.selectpicker').selectpicker('refresh');
        });

        $('#saveAct').click(function () {
            $('#saveAct_progress').addClass('fa fa-spinner fa-pulse');
            saveFormToEndpoint('/api/sbc/settings/set', 'frm_general', function () {
                $('#saveAct_progress').removeClass('fa fa-spinner fa-pulse');
                $('#saveAct_done').show().delay(2000).fadeOut();
            }, true, function () {
                $('#saveAct_progress').removeClass('fa fa-spinner fa-pulse');
            });
        });
    });
</script>

<div class="alert alert-info" role="alert">
    {{ lang._('os-sbc is in early development. These settings are saved, but no service uses them yet: Kamailio and rtpproxy stay stopped. Follow progress at %sgithub.com/TheGrandWazoo/os-SBC%s.') | format('<a href="https://github.com/TheGrandWazoo/os-SBC" target="_blank" rel="noopener noreferrer">', '</a>') }}
</div>

<div class="content-box">
    {{ partial('layout_partials/base_form', ['fields': generalForm, 'id': 'frm_general']) }}
    <div class="col-md-12">
        <hr/>
        <button class="btn btn-primary" id="saveAct" type="button">
            <b>{{ lang._('Save') }}</b> <i id="saveAct_progress"></i>
        </button>
        <span id="saveAct_done" style="display: none;">&nbsp;<i class="fa fa-check text-success"></i> {{ lang._('Saved') }}</span>
        <br/><br/>
    </div>
</div>
